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

    if (audio_input_device != nullptr && SampleRate != 0 && VadInstance != nullptr) {
        int frame_length = (SampleRate / 1000) * 30;

        AudioBuffer.append(audio_input_device->readAll());

        if (AudioBuffer.size() >= frame_length) {
            int p = 0;

            while (p < AudioBuffer.size()) {
                if (p + frame_length <= AudioBuffer.size()) {
                    QVarLengthArray<int16_t, 1024>audio_data_16bit(frame_length);

                    for (int i = 0; i < frame_length; i++) {
                        audio_data_16bit[i] = (static_cast<uint8_t>(AudioBuffer[p + i]) - 0x80) * 256;
                    }

                    if (WebRtcVad_Process(VadInstance, SampleRate, audio_data_16bit.data(), frame_length) > 0) {
                        VoiceBuffer.append(AudioBuffer.mid(p, frame_length));

                        SilenceSize = 0;

                        if (VoiceBuffer.size() > (SampleRate / 1000) * MinVoiceDuration && !VoiceDetected) {
                            VoiceDetected = true;

                            emit voiceFound();
                        }
                    } else {
                        SilenceSize = SilenceSize + frame_length;

                        if (VoiceDetected) {
                            VoiceBuffer.append(AudioBuffer.mid(p, frame_length));
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

                    p = p + frame_length;
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
    QAudioFormat format;

    format.setSampleRate(SampleRate);
    format.setChannelCount(1);
    format.setSampleSize(8);
    format.setCodec(QStringLiteral("audio/pcm"));
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::UnSignedInt);

    QAudioDeviceInfo info = QAudioDeviceInfo::defaultInputDevice();

    if (!info.isFormatSupported(format)) {
        emit error(QStringLiteral("Default format not supported, trying to use the nearest"));

        format = info.nearestFormat(format);
    }

    AudioInput = std::make_unique<QAudioInput>(format);

    AudioInput->setVolume(Volume);

    connect(AudioInput->start(), &QIODevice::readyRead, this, &SpeechRecorder::handleAudioInputDeviceReadyRead);
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
    struct {
        char     chunk_id[4];
        uint32_t chunk_size;
        char     format[4];

        char     sub_chunk_1_id[4];
        uint32_t sub_chunk_1_size;
        uint16_t audio_format;
        uint16_t num_channels;
        uint32_t sample_rate;
        uint32_t byte_rate;
        uint16_t block_align;
        uint16_t bits_per_sample;

        char     sub_chunk_2_id[4];
        uint32_t sub_chunk_2_size;
    } wav_header = {};

    QFile voice_file(VoiceFilePath);

    if (voice_file.open(QIODevice::WriteOnly)) {
        auto sample_rate_multiplied = static_cast<uint32_t>(qFloor(SampleRate * SampleRateMultiplier)); // To change voice pitch

        memcpy(wav_header.chunk_id,       "RIFF", sizeof(wav_header.chunk_id));
        memcpy(wav_header.format,         "WAVE", sizeof(wav_header.format));
        memcpy(wav_header.sub_chunk_1_id, "fmt ", sizeof(wav_header.sub_chunk_1_id));
        memcpy(wav_header.sub_chunk_2_id, "data", sizeof(wav_header.sub_chunk_2_id));

        wav_header.chunk_size       = qToLittleEndian<uint32_t>(4 + (8 + 16) + (8 + static_cast<uint32_t>(VoiceBuffer.size()))); // 4 + (8 + sub_chunk_1_size) + (8 + sub_chunk_2_size)

        wav_header.sub_chunk_1_size = qToLittleEndian<uint32_t>(16); // For PCM
        wav_header.audio_format     = qToLittleEndian<uint16_t>(1); // PCM
        wav_header.num_channels     = qToLittleEndian<uint16_t>(1);
        wav_header.sample_rate      = qToLittleEndian<uint32_t>(sample_rate_multiplied);
        wav_header.byte_rate        = qToLittleEndian<uint32_t>(sample_rate_multiplied * 1 * 8 / 8); // sample_rate * num_channels * bits_per_sample / 8
        wav_header.block_align      = qToLittleEndian<uint16_t>(1 * 8 / 8); // num_channels * bits_per_sample / 8
        wav_header.bits_per_sample  = qToLittleEndian<uint16_t>(8);

        wav_header.sub_chunk_2_size = qToLittleEndian<uint32_t>(static_cast<uint32_t>(VoiceBuffer.size()));

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
}
