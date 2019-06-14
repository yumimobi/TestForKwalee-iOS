//
//  YumiMobileTools.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/6.
//

#import "YumiMobileTools.h"
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>

@interface YumiMobileTools ()
@property (nonatomic) NSString *model;
@end

@implementation YumiMobileTools
+ (instancetype)sharedTool {
    static YumiMobileTools *sharedTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTool = [[self alloc] init];
    });
    return sharedTool;
}

- (NSString *)model {
    if (!_model) {
        int mib[2];
        size_t len;
        char *machine;
        mib[0] = CTL_HW;
        mib[1] = HW_MACHINE;
        sysctl(mib, 2, NULL, &len, NULL, 0);
        machine = malloc(len);
        sysctl(mib, 2, machine, &len, NULL, 0);
        _model = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding] ?: @"";
        free(machine);
    }
    
    return _model;
}

- (BOOL)isiPhone {
    return [self.model hasPrefix:@"iPhone"];
}

- (BOOL)isiPad {
    return [self.model hasPrefix:@"iPad"];
}

- (BOOL)isiPod {
    return [self.model hasPrefix:@"iPod"];
}

- (BOOL)isSimulator {
    return [self.model isEqualToString:@"i386"] || [self.model isEqualToString:@"x86_64"];
}

- (BOOL)isInterfaceOrientationPortrait {
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        return isPortrait;
    } else {
        __block BOOL isPortrait;
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        });
        
        return isPortrait;
    }
}

#pragma mark - Helper methods
- (BOOL)isiPhoneX {
    // iPhone X
    if (!self.isInterfaceOrientationPortrait) {
        return kSCREEN_WIDTH == kIPHONEXHEIGHT && kSCREEN_HEIGHT == kIPHONEXWIDTH;
    }
    return kSCREEN_WIDTH == kIPHONEXWIDTH && kSCREEN_HEIGHT == kIPHONEXHEIGHT;
}

- (BOOL)isiPhoneXR {
    if (!self.isInterfaceOrientationPortrait) {
        return kSCREEN_WIDTH == kIPHONEXRHEIGHT && kSCREEN_HEIGHT == kIPHONEXRWIDTH;
    }
    return kSCREEN_WIDTH == kIPHONEXRWIDTH && kSCREEN_HEIGHT == kIPHONEXRHEIGHT;
}

- (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (NSString *)timestamp {
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%f", a];
}

- (CGFloat)adaptedValue6:(CGFloat)size {
    if ([self isiPad]) {
        return 1.5 * size;
    }
    if ([self isInterfaceOrientationPortrait]) {
        return round((size) * (kSCREEN_WIDTH / 375.0f));
    }
    return round((size) * (kSCREEN_HEIGHT / 375.0f));
}
@end
