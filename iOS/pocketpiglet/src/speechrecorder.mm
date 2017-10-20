#import <Foundation/Foundation.h>

#include <QtCore/QtEndian>
#include <QtCore/QDir>
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
    VoiceFilePath        = QDir(QString::fromNSString(NSTemporaryDirectory())).filePath("voice.wav");
    VadInstance          = NULL;
    AudioInput           = NULL;
    AudioInputDevice     = NULL;
}

SpeechRecorder::~SpeechRecorder()
{
    if (VadInstance != NULL) {
        WebRtcVad_Free(VadInstance);
    }
}

bool SpeechRecorder::active() const
{
    return Active;
}

void SpeechRecorder::setActive(const bool &active)
{
    Active = active;

    if (Active && SampleRate != 0) {
        CreateVAD();
        CreateAudioInput();
    } else {
        DeleteAudioInput();
        DeleteVAD();
    }

    emit activeChanged(Active);
}

int SpeechRecorder::sampleRate() const
{
    return SampleRate;
}

void SpeechRecorder::setSampleRate(const int &sample_rate)
{
    SampleRate = sample_rate;

    if (Active && SampleRate != 0) {
        CreateVAD();
        CreateAudioInput();
    } else {
        DeleteAudioInput();
        DeleteVAD();
    }

    emit sampleRateChanged(SampleRate);
}

int SpeechRecorder::minVoiceDuration() const
{
    return MinVoiceDuration;
}

void SpeechRecorder::setMinVoiceDuration(const int &duration)
{
    MinVoiceDuration = duration;

    emit minVoiceDurationChanged(MinVoiceDuration);
}

int SpeechRecorder::minSilenceDuration() const
{
    return MinSilenceDuration;
}

void SpeechRecorder::setMinSilenceDuration(const int &duration)
{
    MinSilenceDuration = duration;

    emit minSilenceDurationChanged(MinSilenceDuration);
}

qreal SpeechRecorder::volume() const
{
    return Volume;
}

void SpeechRecorder::setVolume(const qreal &vol)
{
    Volume = vol;

    if (AudioInput != NULL) {
        AudioInput->setVolume(Volume);
    }

    emit volumeChanged(Volume);
}

qreal SpeechRecorder::sampleRateMultiplier() const
{
    return SampleRateMultiplier;
}

void SpeechRecorder::setSampleRateMultiplier(const qreal &multiplier)
{
    SampleRateMultiplier = multiplier;

    emit sampleRateMultiplierChanged(SampleRateMultiplier);
}

QString SpeechRecorder::voiceFileURL() const
{
    return QUrl::fromLocalFile(VoiceFilePath).toString();
}

void SpeechRecorder::audioInputDeviceReadyRead()
{
    if (SampleRate != 0 && VadInstance != NULL) {
        int frame_length = (SampleRate / 1000) * 30;

        AudioBuffer.append(AudioInputDevice->readAll());

        if (AudioBuffer.size() >= frame_length) {
            int p = 0;

            while (p < AudioBuffer.size()) {
                if (p + frame_length <= AudioBuffer.size()) {
                    int16_t audio_data_16bit[frame_length];

                    for (int i = 0; i < frame_length; i++) {
                        audio_data_16bit[i] = ((uint8_t)(AudioBuffer[p + i]) - 0x80) << 8;
                    }

                    if (WebRtcVad_Process(VadInstance, SampleRate, audio_data_16bit, frame_length) > 0) {
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

void SpeechRecorder::CreateAudioInput()
{
    if (AudioInput != NULL) {
        AudioInput->stop();
        AudioInput->deleteLater();
    }

    QAudioFormat format;

    format.setSampleRate(SampleRate);
    format.setChannelCount(1);
    format.setSampleSize(8);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::UnSignedInt);

    QAudioDeviceInfo info = QAudioDeviceInfo::defaultInputDevice();

    if (!info.isFormatSupported(format)) {
        emit error("Default format not supported, trying to use the nearest");

        format = info.nearestFormat(format);
    }

    AudioInput = new QAudioInput(format, this);

    AudioInput->setVolume(Volume);

    AudioInputDevice = AudioInput->start();

    connect(AudioInputDevice, SIGNAL(readyRead()), this, SLOT(audioInputDeviceReadyRead()));
}

void SpeechRecorder::DeleteAudioInput()
{
    if (AudioInput != NULL) {
        AudioInput->stop();
        AudioInput->deleteLater();
    }

    //
    // Workaround for Qt for IOS bug with low playback volume when
    // recording is enabled. See qt-patches contents for details.
    //
    QAudioDeviceInfo info = QAudioDeviceInfo::defaultOutputDevice();

    if (info.isNull()) {
        emit error("QAudioDeviceInfo::defaultOutputDevice() returned null");
    }
    //
    // -------------------------------------------------------------
    //

    if (VoiceDetected) {
        emit voiceReset();
    }

    VoiceDetected = false;
    SilenceSize   = 0;

    AudioBuffer.clear();
    VoiceBuffer.clear();

    AudioInput       = NULL;
    AudioInputDevice = NULL;
}

void SpeechRecorder::CreateVAD()
{
    if (WebRtcVad_Create(&VadInstance)) {
        emit error("Cannot create WebRtcVad instance");
    }
    if (WebRtcVad_Init(VadInstance)) {
        emit error("Cannot initialize WebRtcVad instance");
    }
    if (WebRtcVad_set_mode(VadInstance, 3)) {
        emit error("Cannot set mode for WebRtcVad instance");
    }
}

void SpeechRecorder::DeleteVAD()
{
    if (VadInstance != NULL) {
        WebRtcVad_Free(VadInstance);
    }

    if (VoiceDetected) {
        emit voiceReset();
    }

    VoiceDetected = false;
    SilenceSize   = 0;

    AudioBuffer.clear();
    VoiceBuffer.clear();

    VadInstance = NULL;
}

void SpeechRecorder::SaveVoice()
{
    union {
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
        };
        char raw_header[44];
    } wav_header;

    QFile voice_file(VoiceFilePath);

    if (voice_file.open(QIODevice::WriteOnly)) {
        int sample_rate_high_tone = SampleRate * SampleRateMultiplier; // To make voice funny

        memset(wav_header.raw_header, 0, sizeof(wav_header.raw_header));

        memcpy(wav_header.chunk_id,       "RIFF", sizeof(wav_header.chunk_id));
        memcpy(wav_header.format,         "WAVE", sizeof(wav_header.format));
        memcpy(wav_header.sub_chunk_1_id, "fmt ", sizeof(wav_header.sub_chunk_1_id));
        memcpy(wav_header.sub_chunk_2_id, "data", sizeof(wav_header.sub_chunk_2_id));

        wav_header.chunk_size       = qToLittleEndian<uint32_t>(4 + (8 + 16) + (8 + VoiceBuffer.size())); // 4 + (8 + sub_chunk_1_size) + (8 + sub_chunk_2_size)

        wav_header.sub_chunk_1_size = qToLittleEndian<uint32_t>(16); // For PCM
        wav_header.audio_format     = qToLittleEndian<uint16_t>(1); // PCM
        wav_header.num_channels     = qToLittleEndian<uint16_t>(1);
        wav_header.sample_rate      = qToLittleEndian<uint32_t>(sample_rate_high_tone);
        wav_header.byte_rate        = qToLittleEndian<uint32_t>(sample_rate_high_tone * 1 * 8 / 8); // sample_rate * num_channels * bits_per_sample / 8
        wav_header.block_align      = qToLittleEndian<uint16_t>(1 * 8 / 8); // num_channels * bits_per_sample / 8
        wav_header.bits_per_sample  = qToLittleEndian<uint16_t>(8);

        wav_header.sub_chunk_2_size = qToLittleEndian<uint32_t>(VoiceBuffer.size());

        voice_file.write(wav_header.raw_header, sizeof(wav_header.raw_header));
        voice_file.write(VoiceBuffer);

        voice_file.close();
    } else {
        emit error(QString("Cannot create voice file %1: %2").arg(VoiceFilePath).arg(voice_file.errorString()));
    }
}
