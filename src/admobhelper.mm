#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include <QtCore/QDebug>

#include "admobhelper.h"

const QString AdMobHelper::ADMOB_APP_ID                    ("ca-app-pub-2455088855015693~5306005769");
const QString AdMobHelper::ADMOB_REWARDBASEDVIDEOAD_UNIT_ID("ca-app-pub-2455088855015693/5886144590");
const QString AdMobHelper::ADMOB_TEST_DEVICE_ID            ("");

@interface RewardBasedVideoAdDelegate : NSObject<GADRewardBasedVideoAdDelegate>

- (id)init;
- (void)dealloc;
- (void)loadAd;

@end

@implementation RewardBasedVideoAdDelegate

- (id)init
{
    self = [super init];

    if (self) {
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
    }

    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [super dealloc];
}

- (void)loadAd
{
    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                            withAdUnitID:AdMobHelper::ADMOB_REWARDBASEDVIDEOAD_UNIT_ID.toNSString()];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::setRewardBasedVideoAdActive(true);
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::setRewardBasedVideoAdActive(false);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:0.0];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward
{
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::rewardBasedVideoAdDidReward(QString::fromNSString(reward.type), reward.amount.intValue);
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error
{
    Q_UNUSED(rewardBasedVideoAd)

    qWarning() << QString::fromNSString(error.localizedDescription);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

AdMobHelper::AdMobHelper(QObject *parent) : QObject(parent)
{
    [GADMobileAds configureWithApplicationID:ADMOB_APP_ID.toNSString()];

    RewardBasedVideoAdActive           = false;
    RewardBasedVideoAdDelegateInstance = [[RewardBasedVideoAdDelegate alloc] init];

    [RewardBasedVideoAdDelegateInstance loadAd];
}

AdMobHelper::~AdMobHelper() noexcept
{
    [RewardBasedVideoAdDelegateInstance release];
}

AdMobHelper &AdMobHelper::GetInstance()
{
    static AdMobHelper instance;

    return instance;
}

bool AdMobHelper::rewardBasedVideoAdReady() const
{
    return [GADRewardBasedVideoAd sharedInstance].ready;
}

bool AdMobHelper::rewardBasedVideoAdActive() const
{
    return RewardBasedVideoAdActive;
}

void AdMobHelper::showRewardBasedVideoAd()
{
    UIViewController * __block root_view_controller = nil;

    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = window.rootViewController;

        *stop = (root_view_controller != nil);
    }];

    if ([GADRewardBasedVideoAd sharedInstance].ready) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:root_view_controller];
    }
}

void AdMobHelper::setRewardBasedVideoAdActive(bool active)
{
    GetInstance().RewardBasedVideoAdActive = active;

    emit GetInstance().rewardBasedVideoAdActiveChanged(GetInstance().RewardBasedVideoAdActive);
}

void AdMobHelper::rewardBasedVideoAdDidReward(const QString &type, int amount)
{
    emit GetInstance().rewardBasedVideoAdNewReward(type, amount);
}
