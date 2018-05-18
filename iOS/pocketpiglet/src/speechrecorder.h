#ifndef SPEECHRECORDER_H
#define SPEECHRECORDER_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QByteArray>
#include <QtCore/QIODevice>
#include <QtMultimedia/QAudioInput>

#include "webrtc/common_audio/vad/include/webrtc_vad.h"

class SpeechRecorder : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool    active               READ active               WRITE setActive               NOTIFY activeChanged)
    Q_PROPERTY(int     sampleRate           READ sampleRate           WRITE setSampleRate           NOTIFY sampleRateChanged)
    Q_PROPERTY(int     minVoiceDuration     READ minVoiceDuration     WRITE setMinVoiceDuration     NOTIFY minVoiceDurationChanged)
    Q_PROPERTY(int     minSilenceDuration   READ minSilenceDuration   WRITE setMinSilenceDuration   NOTIFY minSilenceDurationChanged)
    Q_PROPERTY(qreal   volume               READ volume               WRITE setVolume               NOTIFY volumeChanged)
    Q_PROPERTY(qreal   sampleRateMultiplier READ sampleRateMultiplier WRITE setSampleRateMultiplier NOTIFY sampleRateMultiplierChanged)

    Q_PROPERTY(QString voiceFileURL         READ voiceFileURL)

public:
    explicit SpeechRecorder(QObject *parent = 0);
    virtual ~SpeechRecorder();

    bool active() const;
    void setActive(bool active);

    int sampleRate() const;
    void setSampleRate(int sample_rate);

    int minVoiceDuration() const;
    void setMinVoiceDuration(int duration);

    int minSilenceDuration() const;
    void setMinSilenceDuration(int duration);

    qreal volume() const;
    void setVolume(qreal vol);

    qreal sampleRateMultiplier() const;
    void setSampleRateMultiplier(qreal multiplier);

    QString voiceFileURL() const;

private slots:
    void audioInputDeviceReadyRead();

signals:
    void activeChanged(bool active);
    void sampleRateChanged(int sampleRate);
    void minVoiceDurationChanged(int minVoiceDuration);
    void minSilenceDurationChanged(int minSilenceDuration);
    void volumeChanged(qreal volume);
    void sampleRateMultiplierChanged(qreal sampleRateMultiplier);
    void error(QString errorString);
    void voiceFound();
    void voiceRecorded();
    void voiceReset();

private:
    void CreateAudioInput();
    void DeleteAudioInput();

    void CreateVAD();
    void DeleteVAD();

    void SaveVoice();

    bool         Active, VoiceDetected;
    int          SampleRate, MinVoiceDuration, MinSilenceDuration, SilenceSize;
    qreal        Volume, SampleRateMultiplier;
    QString      VoiceFilePath;
    QByteArray   AudioBuffer, VoiceBuffer;
    VadInst     *VadInstance;
    QAudioInput *AudioInput;
    QIODevice   *AudioInputDevice;
};

#endif // SPEECHRECORDER_H
