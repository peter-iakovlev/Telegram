#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class CKNotification;

@interface TGICloudEmergencyDataSignals : NSObject

+ (SSignal *)fetchBackupAddressInfo:(NSString *)prefix phoneNumber:(NSString *)phoneNumber;
+ (SSignal *)updateSubscription;
+ (void)processNotification:(CKNotification *)notification;

@end
