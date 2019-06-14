//
//  YumiViewController.m
//  testForKwalee
//
//  Created by wzy2010416033@163.com on 06/13/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiViewController.h"

@interface YumiViewController ()

@end

@implementation YumiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
- (void)setUpUI {
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    CGFloat buttonWidth = [tool adaptedValue6:200];
    CGFloat buttonHeight = [tool adaptedValue6:50];
    CGFloat margin = [tool adaptedValue6:10];
    CGFloat topMargin = [tool adaptedValue6:10];
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
    self.console = [[UITextView alloc] initWithFrame:CGRectMake(0, topMargin + buttonHeight * 3 + margin * 3, screenWidth, screenHeight*0.7 - 100)];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
