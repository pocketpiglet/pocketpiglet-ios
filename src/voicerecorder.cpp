#include <QtCore/QtMath>
#include <QtCore/QtEndian>
#include <QtCore/QVarLengthArray>
#include <QtCore/QIODevice>
#include <QtCore/QDataStream>
#include <QtCore/QFile>
#include <QtCore/QDir>
#include <QtCore/QStandardPaths>
#include <QtCore/QUrl>
#include <QtMultimedia/QAudioFormat>
#include <QtMultimedia/QAudioDeviceInfo>

#include "voicerecorder.h"

VoiceRecorder::VoiceRecorder(QObject *parent) : QObject(parent)
{
    Active               = false;
    VoiceDetected        = false;
    MinVoiceDuration     = 1000;
    MinSilenceDuration   = 1000;
    SilenceLength        = 0;
    Volume               = 1.0;
    SampleRateMultiplier = 1.0;
    VadInstance          = nullptr;

    QString tmp_dir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);

    if (tmp_dir != QStringLiteral("")) {
        QDir().mkpath(tmp_dir);
    }

    VoiceFilePath = QDir(tmp_dir).filePath(QStringLiteral("voice.wav"));
}

VoiceRecorder::~VoiceRecorder() noexcept
{
    if (VadInstance != nullptr) {
        WebRtcVad_Free(VadInstance);
    }
}

bool VoiceRecorder::active() const
{
    return Active;
}

void VoiceRecorder::setActive(bool active)
{
    if (Active != active) {
        Active = active;

        emit activeChanged(Active);

        Cleanup();

        if (Active) {
            CreateVAD();
            CreateAudioInput();
        } else {
            DeleteAudioInput();
            DeleteVAD();
        }
    }
}

int VoiceRecorder::minVoiceDuration() const
{
    return MinVoiceDuration;
}

void VoiceRecorder::setMinVoiceDuration(int duration)
{
    if (MinVoiceDuration != duration) {
        MinVoiceDuration = duration;

        emit minVoiceDurationChanged(MinVoiceDuration);

        Cleanup();
    }
}

int VoiceRecorder::minSilenceDuration() const
{
    return MinSilenceDuration;
}

void VoiceRecorder::setMinSilenceDuration(int duration)
{
    if (MinSilenceDuration != duration) {
        MinSilenceDuration = duration;

        emit minSilenceDurationChanged(MinSilenceDuration);

        Cleanup();
    }
}

qreal VoiceRecorder::volume() const
{
    return Volume;
}

void VoiceRecorder::setVolume(qreal volume)
{
    if (Volume != volume) {
        Volume = volume;

        emit volumeChanged(Volume);

        if (AudioInput) {
            AudioInput->setVolume(Volume);
        }
    }
}

qreal VoiceRecorder::sampleRateMultiplier() const
{
    return SampleRateMultiplier;
}

void VoiceRecorder::setSampleRateMultiplier(qreal multiplier)
{
    if (SampleRateMultiplier != multiplier) {
        SampleRateMultiplier = multiplier;

        emit sampleRateMultiplierChanged(SampleRateMultiplier);
    }
}

QString VoiceRecorder::voiceFileURL() const
{
    return QUrl::fromLocalFile(VoiceFilePath).toString();
}

void VoiceRecorder::handleAudioInputDeviceReadyRead()
{
    auto audio_input_device = qobject_cast<QIODevice *>(QObject::sender());

    if (audio_input_device != nullptr) {
        AudioBuffer.append(audio_input_device->readAll());

        if (VadInstance != nullptr && AudioInput) {
            int                      sample_rate  = AudioInput->format().sampleRate();
            int                      sample_size  = AudioInput->format().sampleSize();
            QAudioFormat::SampleType sample_type  = AudioInput->format().sampleType();
            int                      frame_length = (sample_rate / 1000) * 30;
            int                      frame_bytes  = frame_length * (sample_size / 8);

            if (AudioBuffer.size() >= frame_bytes) {
                int p = 0;

                while (p < AudioBuffer.size()) {
                    if (p + frame_bytes <= AudioBuffer.size()) {
                        QVarLengthArray<int16_t, 1024>audio_data_16bit(frame_length);

                        for (int i = 0; i < frame_length; i++) {
                            if (sample_type == QAudioFormat::UnSignedInt && sample_size == 8) {
                                audio_data_16bit[i] = (static_cast<quint8>(AudioBuffer[p + i]) - 128) * 256;
                            } else if (sample_type == QAudioFormat::SignedInt && sample_size == 16) {
                                audio_data_16bit[i] = static_cast<int16_t>((static_cast<quint16>(AudioBuffer[p + i * 2 + 1]) * 256) + static_cast<quint8>(AudioBuffer[p + i * 2]));
                            } else {
                                audio_data_16bit[i] = 0;
                            }
                        }

                        if (WebRtcVad_Process(VadInstance, sample_rate, audio_data_16bit.data(), frame_length) > 0) {
                            VoiceBuffer.append(AudioBuffer.mid(p, frame_bytes));

                            SilenceLength = 0;

                            if (VoiceBuffer.size() > (sample_rate / 1000) * MinVoiceDuration && !VoiceDetected) {
                                VoiceDetected = true;

                                emit voiceFound();
                            }
                        } else {
                            if (VoiceDetected) {
                                VoiceBuffer.append(AudioBuffer.mid(p, frame_bytes));

                                SilenceLength = SilenceLength + frame_length;

                                if (SilenceLength > (sample_rate / 1000) * MinSilenceDuration) {
                                    VoiceDetected = false;
                                    SilenceLength = 0;

                                    SaveVoice();

                                    emit voiceRecorded();

                                    VoiceBuffer.clear();
                                }
                            } else {
                                VoiceBuffer.clear();
                            }
                        }

                        p = p + frame_bytes;
                    } else {
                        break;
                    }
                }

                AudioBuffer = AudioBuffer.mid(p);
            }
        } else {
            Cleanup();
        }
    }
}

void VoiceRecorder::Cleanup()
{
    if (VoiceDetected) {
        emit voiceReset();
    }

    VoiceDetected = false;
    SilenceLength = 0;

    AudioBuffer.clear();
    VoiceBuffer.clear();
}

void VoiceRecorder::CreateAudioInput()
{
    //
    // Workaround for Qt for Android - app should have permission
    // to access microphone to get valid info about audio formats,
    // so let's request required permission first.
    //
    {
        QAudioInput input(QAudioDeviceInfo::defaultInputDevice().preferredFormat());

        input.start();
    }
    // -------------------------------------------------------------

    QAudioFormat format, supported_format;

    format.setSampleRate(16000);
    format.setChannelCount(1);
    format.setSampleSize(8);
    format.setCodec(QStringLiteral("audio/pcm"));
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::UnSignedInt);

    QAudioDeviceInfo info = QAudioDeviceInfo::defaultInputDevice();

    if (info.isFormatSupported(format)) {
        supported_format = format;
    } else {
        supported_format = info.nearestFormat(format);
    }

    if (supported_format.channelCount() == format.channelCount() &&
        supported_format.codec()        == format.codec() &&
        supported_format.byteOrder()    == format.byteOrder() &&
       (supported_format.sampleRate() == 8000  || supported_format.sampleRate() == 16000 ||
        supported_format.sampleRate() == 32000 || supported_format.sampleRate() == 48000) &&
      ((supported_format.sampleSize() == 8  && supported_format.sampleType() == QAudioFormat::UnSignedInt) ||
       (supported_format.sampleSize() == 16 && supported_format.sampleType() == QAudioFormat::SignedInt))) {
        AudioInput = std::make_unique<QAudioInput>(supported_format);

        AudioInput->setVolume(Volume);

        connect(AudioInput->start(), &QIODevice::readyRead, this, &VoiceRecorder::handleAudioInputDeviceReadyRead);
    } else {
        emit error(QStringLiteral("Format is not suitable for recording"));
    }
}

void VoiceRecorder::DeleteAudioInput()
{
    AudioInput.reset();

    //
    // Workaround for Qt for IOS bug with low playback volume when
    // recording is enabled. See qt-patches contents for details.
    //
    QAudioDeviceInfo info = QAudioDeviceInfo::defaultOutputDevice();

    if (info.isNull()) {
        emit error(QStringLiteral("QAudioDeviceInfo::defaultOutputDevice() returned null"));
    }
    // -------------------------------------------------------------
}

void VoiceRecorder::CreateVAD()
{
    if (VadInstance != nullptr) {
        WebRtcVad_Free(VadInstance);

        VadInstance = nullptr;
    }

    if (WebRtcVad_Create(&VadInstance)) {
        emit error(QStringLiteral("Cannot create WebRtcVad instance"));
    } else if (WebRtcVad_Init(VadInstance)) {
        emit error(QStringLiteral("Cannot initialize WebRtcVad instance"));
    } else if (WebRtcVad_set_mode(VadInstance, 3)) {
        emit error(QStringLiteral("Cannot set mode for WebRtcVad instance"));
    }
}

void VoiceRecorder::DeleteVAD()
{
    if (VadInstance != nullptr) {
        WebRtcVad_Free(VadInstance);

        VadInstance = nullptr;
    }
}

void VoiceRecorder::SaveVoice()
{
    if (AudioInput) {
        int  sample_rate = AudioInput->format().sampleRate();
        auto sample_size = static_cast<quint16>(AudioInput->format().sampleSize());

        struct {
            char    chunk_id[4];
            quint32 chunk_size;
            char    format[4];

            char    sub_chunk_1_id[4];
            quint32 sub_chunk_1_size;
            quint16 audio_format;
            quint16 num_channels;
            quint32 sample_rate;
            quint32 byte_rate;
            quint16 block_align;
            quint16 bits_per_sample;

            char    sub_chunk_2_id[4];
            quint32 sub_chunk_2_size;
        } wav_header = {};

        QFile voice_file(VoiceFilePath);

        if (voice_file.open(QIODevice::WriteOnly)) {
            auto sample_rate_multiplied = static_cast<quint32>(qFloor(sample_rate * SampleRateMultiplier)); // To change voice pitch

            memcpy(wav_header.chunk_id,       "RIFF", sizeof(wav_header.chunk_id));
            memcpy(wav_header.format,         "WAVE", sizeof(wav_header.format));
            memcpy(wav_header.sub_chunk_1_id, "fmt ", sizeof(wav_header.sub_chunk_1_id));
            memcpy(wav_header.sub_chunk_2_id, "data", sizeof(wav_header.sub_chunk_2_id));

            wav_header.chunk_size       = qToLittleEndian<quint32>(4 + (8 + 16) + (8 + static_cast<quint32>(VoiceBuffer.size()))); // 4 + (8 + sub_chunk_1_size) + (8 + sub_chunk_2_size)

            wav_header.sub_chunk_1_size = qToLittleEndian<quint32>(16); // For PCM
            wav_header.audio_format     = qToLittleEndian<quint16>(1); // PCM
            wav_header.num_channels     = qToLittleEndian<quint16>(1);
            wav_header.sample_rate      = qToLittleEndian<quint32>(sample_rate_multiplied);
            wav_header.byte_rate        = qToLittleEndian<quint32>(sample_rate_multiplied * 1 * sample_size / 8); // sample_rate * num_channels * bits_per_sample / 8
            wav_header.block_align      = qToLittleEndian<quint16>(1 * sample_size / 8); // num_channels * bits_per_sample / 8
            wav_header.bits_per_sample  = qToLittleEndian<quint16>(sample_size);

            wav_header.sub_chunk_2_size = qToLittleEndian<quint32>(static_cast<quint32>(VoiceBuffer.size()));

            QDataStream voice_file_stream(&voice_file);

            voice_file_stream.writeRawData(wav_header.chunk_id,                              sizeof(wav_header.chunk_id));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.chunk_size), sizeof(wav_header.chunk_size));
            voice_file_stream.writeRawData(wav_header.format,                                sizeof(wav_header.format));

            voice_file_stream.writeRawData(wav_header.sub_chunk_1_id,                              sizeof(wav_header.sub_chunk_1_id));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.sub_chunk_1_size), sizeof(wav_header.sub_chunk_1_size));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.audio_format),     sizeof(wav_header.audio_format));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.num_channels),     sizeof(wav_header.num_channels));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.sample_rate),      sizeof(wav_header.sample_rate));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.byte_rate),        sizeof(wav_header.byte_rate));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.block_align),      sizeof(wav_header.block_align));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.bits_per_sample),  sizeof(wav_header.bits_per_sample));

            voice_file_stream.writeRawData(wav_header.sub_chunk_2_id,                              sizeof(wav_header.sub_chunk_2_id));
            voice_file_stream.writeRawData(reinterpret_cast<char *>(&wav_header.sub_chunk_2_size), sizeof(wav_header.sub_chunk_2_size));

            voice_file_stream.writeRawData(VoiceBuffer.data(), VoiceBuffer.size());
        } else {
            emit error(QStringLiteral("Cannot create voice file %1: %2").arg(VoiceFilePath).arg(voice_file.errorString()));
        }
    } else {
        emit error(QStringLiteral("AudioInput is null"));
    }
}
