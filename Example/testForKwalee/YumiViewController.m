//
//  YumiViewController.m
//  testForKwalee
//
//  Created by wzy2010416033@163.com on 06/13/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiViewController.h"
#import <IronSource/IronSource.h>
#import <YumiMediationSDK/YumiMediationVideo.h>
#import "YumiMobileTools.h"
#import <YumiMediationSDK/YumiMediationBannerView.h>
#import <YumiMediationSDK/YumiMediationInterstitial.h>
#import <YumiMediationSDK/YumiMediationVideo.h>

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define bannerInterval 30
@interface YumiViewController ()<ISRewardedVideoDelegate,ISInterstitialDelegate,ISBannerDelegate,YumiMediationVideoDelegate,YumiMediationBannerViewDelegate,YumiMediationInterstitialDelegate>
@property (nonatomic) UITextView *console;
@property (nonatomic) UIButton *requestBannerBtn;
@property (nonatomic) UIButton *requestInterstitialBtn;
@property (nonatomic) UIButton *presentInterstitialBtn;
@property (nonatomic) UIButton *presentRewardVideoBtn;

// Yumi
@property (nonatomic) YumiMediationBannerView *yumiBanner;
@property (nonatomic) YumiMediationBannerView *yumiBannerView;
@property (nonatomic) YumiMediationInterstitial *yumiInterstitial;
// IS
@property (nonatomic) ISBannerView *ironBanner;

@end

@implementation YumiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpUI];
    [self initSDK];
}

- (void)initSDK {
    // init yumi banner
    self.yumiBanner = [[YumiMediationBannerView alloc] initWithPlacementID:@"l6ibkpae" channelID:@"" versionID:@"" position:YumiMediationBannerPositionBottom rootViewController:self];
    self.yumiBanner.delegate = self;
    self.yumiBanner.isIntegrated = YES;
    [self.yumiBanner disableAutoRefresh];
    // init and load yumi interstitial (auto cache)
    self.yumiInterstitial = [[YumiMediationInterstitial alloc] initWithPlacementID:@"onkkeg5i" channelID:@"" versionID:@"" rootViewController:self];
    self.yumiInterstitial.delegate = self;
    // init yumi video
    [[YumiMediationVideo sharedInstance] loadAdWithPlacementID:@"5xmpgti4" channelID:@"" versionID:@""];
    [YumiMediationVideo sharedInstance].delegate = self;
    
    // iron
    [IronSource setRewardedVideoDelegate:self];
    [IronSource setInterstitialDelegate:self];
    [IronSource setBannerDelegate:self];
    [IronSource initWithAppKey:@"96054175" adUnits:@[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL,IS_BANNER]];
    [ISIntegrationHelper validateIntegration];
}

- (void)requestBannerAd {
    [self.yumiBanner loadAd:YES];
    [self addLog:@"request yumi banner"];
    // iron banner disable auto refresh in dashboard
}

- (void)updateBanner:(NSTimeInterval)interval {
    if (!interval) {
        [self requestBannerAd];
    }
    interval = MAX(bannerInterval, interval);
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf requestBannerAd];
    });
}

- (void)requestInterstitialAd {
    [IronSource loadInterstitial];
}

- (void)presentInterstitialAd {
    if ([self.yumiInterstitial isReady]) {
        [self.yumiInterstitial present];
    } else if ([IronSource hasInterstitial]) {
        [IronSource showInterstitialWithViewController:self];
    }
}

- (void)presentRewardVideo {
    if ([[YumiMediationVideo sharedInstance] isReady]) {
        [self addLog:@"yumi video is ready"];
        [[YumiMediationVideo sharedInstance] presentFromRootViewController:self];
        return;
    } else {
        [self addLog:@"yumi video not ready"];
    }
        
    if ([IronSource hasRewardedVideo]) {
        [IronSource showRewardedVideoWithViewController:self];
        [self addLog:@"iron video is ready"];
    } else {
        [self addLog:@"iron video not ready"];
    }
}
#pragma mark - YumiBannerDelegate
- (void)yumiMediationBannerViewDidLoad:(YumiMediationBannerView *)adView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.view.subviews containsObject:self.ironBanner]) {
            [self.ironBanner removeFromSuperview];
        }
        if ([self.view.subviews containsObject:self.yumiBannerView]) {
            [self.yumiBannerView removeFromSuperview];
        }
        self.yumiBannerView = adView;
        CGFloat y = self.view.frame.size.height - (self.yumiBannerView.frame.size.height / 2);
        if (@available(ios 11.0, *)) {
            y -= self.view.safeAreaInsets.bottom;
        }
        self.yumiBannerView.center = CGPointMake(self.view.frame.size.width / 2, y);
        [self.view addSubview:self.yumiBannerView];
    });
    [self updateBanner:bannerInterval];
    [self addLog:@"yumi banner is received"];
}
- (void)yumiMediationBannerView:(YumiMediationBannerView *)adView didFailWithError:(YumiMediationError *)error {
    // load iron banner
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    [IronSource loadBannerWithViewController:self size:ISBannerSize_BANNER];
    [self addLog:@"yumi banner fail to load"];
    [self addLog:@"request iron banner"];
}
- (void)yumiMediationBannerViewDidClick:(YumiMediationBannerView *)adView {
    [self addLog:@"yumi banner is clicked"];
}
#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.view.subviews containsObject:self.ironBanner]) {
            [self.ironBanner removeFromSuperview];
        }
        if ([self.view.subviews containsObject:self.yumiBannerView]) {
            [self.yumiBannerView removeFromSuperview];
        }
        self.ironBanner = bannerView;
        CGFloat y = self.view.frame.size.height - (self.ironBanner.frame.size.height / 2);
        if (@available(ios 11.0, *)) {
            y -= self.view.safeAreaInsets.bottom;
        }
        self.ironBanner.center = CGPointMake(self.view.frame.size.width / 2, y);
        [self.view addSubview:self.ironBanner];
    });
    [self updateBanner:bannerInterval];
    [self addLog:@"iron banner is received"];
}
- (void)bannerDidFailToLoadWithError:(NSError *)error {
    [self addLog:@"iron banner fail to load"];
    [self updateBanner:0];
}
- (void)didClickBanner {
    [self addLog:@"iron banner is clicked"];
}
- (void)bannerWillPresentScreen {}
- (void)bannerDidDismissScreen {}
- (void)bannerWillLeaveApplication {}
#pragma mark - Yumi video delegate
- (void)yumiMediationVideoDidOpen:(YumiMediationVideo *)video {
    [self addLog:@"yumi video did open"];
}
- (void)yumiMediationVideoDidStartPlaying:(YumiMediationVideo *)video {
}
- (void)yumiMediationVideoDidClose:(YumiMediationVideo *)video {
    [self addLog:@"yumi video did close"];
}
- (void)yumiMediationVideoDidReward:(YumiMediationVideo *)video {
    [self addLog:@"yumi video did reward"];
}
#pragma mark - ISRewardedVideoDelegate
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
}
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    [self addLog:@"iron video did reward"];
}
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
}
- (void)rewardedVideoDidOpen {
    [self addLog:@"iron video did open"];
}
- (void)rewardedVideoDidClose {
    [self addLog:@"iron video did close"];
}
- (void)rewardedVideoDidStart {
}
- (void)rewardedVideoDidEnd {
}
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
}
#pragma mark - Yumi Interstitial Delegate
- (void)yumiMediationInterstitialDidReceiveAd:(YumiMediationInterstitial *)interstitial {
    [self addLog:@"yumi interstitial is received"];
}
- (void)yumiMediationInterstitial:(YumiMediationInterstitial *)interstitial
                 didFailWithError:(YumiMediationError *)error {
    [self addLog:@"yumi interstitial fail to load"];
}
- (void)yumiMediationInterstitialWillDismissScreen:(YumiMediationInterstitial *)interstitial {
    [self addLog:@"yumi interstitial is dismissed"];
}
- (void)yumiMediationInterstitialDidClick:(YumiMediationInterstitial *)interstitial {
    [self addLog:@"yumi interstitial is clicked"];
}
#pragma mark - ISInterstitialDelegate
- (void)interstitialDidLoad {
    [self addLog:@"iron interstitial is received"];
}
- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    [self addLog:@"iron interstitial fail to load"];
}
- (void)interstitialDidOpen {
}
- (void)interstitialDidClose {
    [self addLog:@"iron interstitial is dismissed"];
}
- (void)interstitialDidShow {
}
- (void)interstitialDidFailToShowWithError:(NSError *)error {
}
- (void)didClickInterstitial {
    [self addLog:@"iron interstitial is clicked"];
}

#pragma mark - Orientation delegate
- (void)orientationChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.ironBanner) {
            CGFloat y = self.view.frame.size.height - (self.ironBanner.frame.size.height / 2);
            if (@available(ios 11.0, *)) {
                y -= self.view.safeAreaInsets.bottom;
            }
            self.ironBanner.center = CGPointMake(self.view.frame.size.width / 2, y);
        }
    });
}

- (void)setUpUI {
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    CGFloat buttonWidth = [tool adaptedValue6:200];
    CGFloat buttonHeight = [tool adaptedValue6:35];
    CGFloat margin = [tool adaptedValue6:5];
    CGFloat topMargin = [tool adaptedValue6:5];
    if ([tool isiPhoneX]) {
        topMargin += kIPHONEXSTATUSBAR;
    }
    if ([tool isiPhoneXR]) {
        topMargin += kIPHONEXRSTATUSBAR;
    }
    // request banner
    self.requestBannerBtn = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin, buttonWidth, buttonHeight)];
    [self.requestBannerBtn addTarget:self action:@selector(requestBannerAd) forControlEvents:UIControlEventTouchUpInside];
    self.requestBannerBtn.backgroundColor = [UIColor blackColor];
    self.requestBannerBtn.layer.cornerRadius = 10;
    self.requestBannerBtn.layer.masksToBounds = YES;
    [self.requestBannerBtn setTitle:@"Request Banner" forState:UIControlStateNormal];
    [self.view addSubview:self.requestBannerBtn];
    // request interstitial
    self.requestInterstitialBtn = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin + buttonHeight + margin, buttonWidth, buttonHeight)];
    [self.requestInterstitialBtn addTarget:self action:@selector(requestInterstitialAd) forControlEvents:UIControlEventTouchUpInside];
    self.requestInterstitialBtn.backgroundColor = [UIColor blackColor];
    self.requestInterstitialBtn.layer.cornerRadius = 10;
    self.requestInterstitialBtn.layer.masksToBounds = YES;
    [self.requestInterstitialBtn setTitle:@"Request Interstitial" forState:UIControlStateNormal];
    [self.view addSubview:self.requestInterstitialBtn];
    // present interstitial
    self.presentInterstitialBtn = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin + buttonHeight * 2 + margin * 2, buttonWidth, buttonHeight)];
    [self.presentInterstitialBtn addTarget:self action:@selector(presentInterstitialAd) forControlEvents:UIControlEventTouchUpInside];
    self.presentInterstitialBtn.backgroundColor = [UIColor blackColor];
    self.presentInterstitialBtn.layer.cornerRadius = 10;
    self.presentInterstitialBtn.layer.masksToBounds = YES;
    [self.presentInterstitialBtn setTitle:@"Present Interstitial" forState:UIControlStateNormal];
    [self.view addSubview:self.presentInterstitialBtn];
    // present reward video
    self.presentRewardVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin + buttonHeight * 3 + margin * 3, buttonWidth, buttonHeight)];
    [self.presentRewardVideoBtn addTarget:self action:@selector(presentRewardVideo) forControlEvents:UIControlEventTouchUpInside];
    self.presentRewardVideoBtn.backgroundColor = [UIColor blackColor];
    self.presentRewardVideoBtn.layer.cornerRadius = 10;
    self.presentRewardVideoBtn.layer.masksToBounds = YES;
    [self.presentRewardVideoBtn setTitle:@"Present RewardVideo" forState:UIControlStateNormal];
    [self.view addSubview:self.presentRewardVideoBtn];
    // console
    self.console = [[UITextView alloc] initWithFrame:CGRectMake(0, topMargin + buttonHeight * 4 + margin * 4, screenWidth, screenHeight*0.7 - 100)];
    self.console.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.console];
}

- (void)addLog:(NSString *)newLog {
    NSDate *date = [NSDate date];
    NSDateFormatter *formateDate = [[NSDateFormatter alloc] init];
    [formateDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dataString = [formateDate stringFromDate:date];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.console.layoutManager.allowsNonContiguousLayout = NO;
        NSString *oldLog = weakSelf.console.text;
        NSString *text = [NSString stringWithFormat:@"%@\n%@: %@", oldLog, dataString, newLog];
        if (oldLog.length == 0) {
            text = [NSString stringWithFormat:@"%@: %@", dataString, newLog];
        }
        [weakSelf.console scrollRangeToVisible:NSMakeRange(text.length, 1)];
        weakSelf.console.text = text;
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
