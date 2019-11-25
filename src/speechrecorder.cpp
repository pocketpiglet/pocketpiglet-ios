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

#include "speechrecorder.h"

SpeechRecorder::SpeechRecorder(QObject *parent) : QObject(parent)
{
    Active               = false;
    VoiceDetected        = false;
    SampleRate           = 0;
    MinVoiceDuration     = 1000;
    MinSilenceDuration   = 1000;
    SilenceSize          = 0;
    Volume               = 1.0;
    SampleRateMultiplier = 1.0;
    VadInstance          = nullptr;

    QString tmp_dir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);

    if (tmp_dir != QStringLiteral("")) {
        QDir().mkpath(tmp_dir);
    }

    VoiceFilePath = QDir(tmp_dir).filePath(QStringLiteral("voice.wav"));
}

SpeechRecorder::~SpeechRecorder() noexcept
{
    if (VadInstance != nullptr) {
        WebRtcVad_Free(VadInstance);
    }
}

bool SpeechRecorder::active() const
{
    return Active;
}

void SpeechRecorder::setActive(bool active)
{
    if (Active != active) {
        Active = active;

        emit activeChanged(Active);

        Cleanup();

        if (Active && SampleRate != 0) {
            CreateVAD();
            CreateAudioInput();
        } else {
            DeleteAudioInput();
            DeleteVAD();
        }
    }
}

int SpeechRecorder::sampleRate() const
{
    return SampleRate;
}

void SpeechRecorder::setSampleRate(int sample_rate)
{
    if (SampleRate != sample_rate) {
        SampleRate = sample_rate;

        emit sampleRateChanged(SampleRate);

        Cleanup();

        if (Active && SampleRate != 0) {
            CreateVAD();
            CreateAudioInput();
        } else {
            DeleteAudioInput();
            DeleteVAD();
        }
    }
}

int SpeechRecorder::minVoiceDuration() const
{
    return MinVoiceDuration;
}

void SpeechRecorder::setMinVoiceDuration(int duration)
{
    if (MinVoiceDuration != duration) {
        MinVoiceDuration = duration;

        emit minVoiceDurationChanged(MinVoiceDuration);
    }
}

int SpeechRecorder::minSilenceDuration() const
{
    return MinSilenceDuration;
}

void SpeechRecorder::setMinSilenceDuration(int duration)
{
    if (MinSilenceDuration != duration) {
        MinSilenceDuration = duration;

        emit minSilenceDurationChanged(MinSilenceDuration);
    }
}

qreal SpeechRecorder::volume() const
{
    return Volume;
}

void SpeechRecorder::setVolume(qreal volume)
{
    if (Volume != volume) {
        Volume = volume;

        emit volumeChanged(Volume);

        if (AudioInput) {
            AudioInput->setVolume(Volume);
        }
    }
}

qreal SpeechRecorder::sampleRateMultiplier() const
{
    return SampleRateMultiplier;
}

void SpeechRecorder::setSampleRateMultiplier(qreal multiplier)
{
    if (SampleRateMultiplier != multiplier) {
        SampleRateMultiplier = multiplier;

        emit sampleRateMultiplierChanged(SampleRateMultiplier);
    }
}

QString SpeechRecorder::voiceFileURL() const
{
    return QUrl::fromLocalFile(VoiceFilePath).toString();
}

void SpeechRecorder::handleAudioInputDeviceReadyRead()
{
    auto audio_input_device = qobject_cast<QIODevice *>(QObject::sender());

    if (audio_input_device != nullptr && SampleRate != 0 && VadInstance != nullptr && AudioInput) {
        QAudioFormat::SampleType sample_type  = AudioInput->format().sampleType();
        int                      sample_size  = AudioInput->format().sampleSize();
        int                      frame_length = (SampleRate / 1000) * 30;
        int                      frame_bytes  = frame_length * (sample_size / 8);

        AudioBuffer.append(audio_input_device->readAll());

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

                    if (WebRtcVad_Process(VadInstance, SampleRate, audio_data_16bit.data(), frame_length) > 0) {
                        VoiceBuffer.append(AudioBuffer.mid(p, frame_bytes));

                        SilenceSize = 0;

                        if (VoiceBuffer.size() > (SampleRate / 1000) * MinVoiceDuration && !VoiceDetected) {
                            VoiceDetected = true;

                            emit voiceFound();
                        }
                    } else {
                        SilenceSize = SilenceSize + frame_length;

                        if (VoiceDetected) {
                            VoiceBuffer.append(AudioBuffer.mid(p, frame_bytes));
                        } else {
                            VoiceBuffer.clear();
                        }

                        if (SilenceSize > (SampleRate / 1000) * MinSilenceDuration) {
                            if (VoiceDetected) {
                                VoiceDetected = false;

                                SaveVoice();

                                emit voiceRecorded();
                            }

                            SilenceSize = 0;

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
    }
}

void SpeechRecorder::Cleanup()
{
    if (VoiceDetected) {
        emit voiceReset();
    }

    VoiceDetected = false;
    SilenceSize   = 0;

    AudioBuffer.clear();
    VoiceBuffer.clear();
}

void SpeechRecorder::CreateAudioInput()
{
    QAudioFormat format, supported_format;

    format.setSampleRate(SampleRate);
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

    if (supported_format.sampleRate()   == format.sampleRate() &&
        supported_format.channelCount() == format.channelCount() &&
        supported_format.codec()        == format.codec() &&
        supported_format.byteOrder()    == format.byteOrder() && ((supported_format.sampleSize() == 8  && supported_format.sampleType() == QAudioFormat::UnSignedInt) ||
                                                                  (supported_format.sampleSize() == 16 && supported_format.sampleType() == QAudioFormat::SignedInt))) {
        AudioInput = std::make_unique<QAudioInput>(supported_format);

        AudioInput->setVolume(Volume);

        connect(AudioInput->start(), &QIODevice::readyRead, this, &SpeechRecorder::handleAudioInputDeviceReadyRead);
    } else {
        emit error(QStringLiteral("Format is not suitable for recording"));
    }
}

void SpeechRecorder::DeleteAudioInput()
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

void SpeechRecorder::CreateVAD()
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

void SpeechRecorder::DeleteVAD()
{
    if (VadInstance != nullptr) {
        WebRtcVad_Free(VadInstance);

        VadInstance = nullptr;
    }
}

void SpeechRecorder::SaveVoice()
{
    if (AudioInput) {
        auto bits_per_sample = static_cast<quint16>(AudioInput->format().sampleSize());

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
            auto sample_rate_multiplied = static_cast<quint32>(qFloor(SampleRate * SampleRateMultiplier)); // To change voice pitch

            memcpy(wav_header.chunk_id,       "RIFF", sizeof(wav_header.chunk_id));
            memcpy(wav_header.format,         "WAVE", sizeof(wav_header.format));
            memcpy(wav_header.sub_chunk_1_id, "fmt ", sizeof(wav_header.sub_chunk_1_id));
            memcpy(wav_header.sub_chunk_2_id, "data", sizeof(wav_header.sub_chunk_2_id));

            wav_header.chunk_size       = qToLittleEndian<quint32>(4 + (8 + 16) + (8 + static_cast<quint32>(VoiceBuffer.size()))); // 4 + (8 + sub_chunk_1_size) + (8 + sub_chunk_2_size)

            wav_header.sub_chunk_1_size = qToLittleEndian<quint32>(16); // For PCM
            wav_header.audio_format     = qToLittleEndian<quint16>(1); // PCM
            wav_header.num_channels     = qToLittleEndian<quint16>(1);
            wav_header.sample_rate      = qToLittleEndian<quint32>(sample_rate_multiplied);
            wav_header.byte_rate        = qToLittleEndian<quint32>(sample_rate_multiplied * 1 * bits_per_sample / 8); // sample_rate * num_channels * bits_per_sample / 8
            wav_header.block_align      = qToLittleEndian<quint16>(1 * bits_per_sample / 8); // num_channels * bits_per_sample / 8
            wav_header.bits_per_sample  = qToLittleEndian<quint16>(bits_per_sample);

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
