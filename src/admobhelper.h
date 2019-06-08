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

private:
    explicit AdMobHelper(QObject *parent = nullptr);
    ~AdMobHelper() noexcept override;

public:
    static const QString ADMOB_APP_ID,
                         ADMOB_REWARDBASEDVIDEOAD_UNIT_ID,
                         ADMOB_TEST_DEVICE_ID;

    AdMobHelper(const AdMobHelper&) = delete;
    AdMobHelper(AdMobHelper&&) noexcept = delete;

    AdMobHelper &operator=(const AdMobHelper&) = delete;
    AdMobHelper &operator=(AdMobHelper&&) noexcept = delete;

    static AdMobHelper &GetInstance();

    bool rewardBasedVideoAdReady() const;
    bool rewardBasedVideoAdActive() const;

    Q_INVOKABLE void showRewardBasedVideoAd();

    void setRewardBasedVideoAdActive(bool active);
    void rewardBasedVideoAdDidReward(const QString &type, int amount);

signals:
    void rewardBasedVideoAdActiveChanged(bool rewardBasedVideoAdActive);
    void rewardBasedVideoAdNewReward(const QString &type, int amount);

private:
    bool                        RewardBasedVideoAdActive;
#ifdef __OBJC__
    RewardBasedVideoAdDelegate *RewardBasedVideoAdDelegateInstance;
#else
    void                       *RewardBasedVideoAdDelegateInstance;
#endif
};

#endif // ADMOBHELPER_H
