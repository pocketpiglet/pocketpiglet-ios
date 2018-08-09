#ifndef ADMOBHELPER_H
#define ADMOBHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

#ifdef __OBJC__
@class RewardBasedVideoAdDelegate;
#endif

class AdMobHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool rewardBasedVideoAdReady  READ rewardBasedVideoAdReady)
    Q_PROPERTY(bool rewardBasedVideoAdActive READ rewardBasedVideoAdActive NOTIFY rewardBasedVideoAdActiveChanged)

public:
    static const QString ADMOB_APP_ID,
                         ADMOB_REWARDBASEDVIDEOAD_UNIT_ID,
                         ADMOB_TEST_DEVICE_ID;

    explicit AdMobHelper(QObject *parent = nullptr);
    virtual ~AdMobHelper();

    bool rewardBasedVideoAdReady() const;
    bool rewardBasedVideoAdActive() const;

    Q_INVOKABLE void showRewardBasedVideoAd();

    static void setRewardBasedVideoAdActive(bool active);
    static void rewardBasedVideoAdDidReward(QString type, int amount);

signals:
    void rewardBasedVideoAdActiveChanged(bool rewardBasedVideoAdActive);
    void rewardBasedVideoAdNewReward(QString type, int amount);

private:
    bool                        RewardBasedVideoAdActive;
    static AdMobHelper         *Instance;
#ifdef __OBJC__
    RewardBasedVideoAdDelegate *RewardBasedVideoAdDelegateInstance;
#else
    void                       *RewardBasedVideoAdDelegateInstance;
#endif
};

#endif // ADMOBHELPER_H
