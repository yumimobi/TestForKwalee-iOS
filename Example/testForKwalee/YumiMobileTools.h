//
//  YumiMobileTools.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/6.
//

#import <Foundation/Foundation.h>

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// iPhone X / XS
#define kIPHONEXHEIGHT 812.0
#define kIPHONEXHOMEINDICATOR 34.0
#define kIPHONEXSTATUSBAR 44.0
#define kIPHONEXWIDTH 375.0
// iPhone XR / XS MAX
#define kIPHONEXRHEIGHT 896.0
#define kIPHONEXRHOMEINDICATOR 34.0
#define kIPHONEXRSTATUSBAR 44.0
#define kIPHONEXRWIDTH 414.0
// iPhone X / XS / XR / XS MAX Landscape
#define kIPHONEXLANDSCAPEHOMEINDICATOR 21

NS_ASSUME_NONNULL_BEGIN
@interface YumiMobileTools : NSObject
+ (instancetype _Nonnull)sharedTool;

- (BOOL)isiPhone;
- (BOOL)isiPad;
- (BOOL)isiPod;
- (BOOL)isSimulator;
- (BOOL)isInterfaceOrientationPortrait;
- (BOOL)isiPhoneX;
- (BOOL)isiPhoneXR;
- (UIViewController *)topMostController;
- (NSString *)timestamp;
- (CGFloat)adaptedValue6:(CGFloat)size;
@end
NS_ASSUME_NONNULL_END
