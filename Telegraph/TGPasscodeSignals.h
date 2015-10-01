#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGPasscodeStatus : NSObject

@property (nonatomic, readonly) bool enabled;
@property (nonatomic, readonly) bool encrypted;

@end

@interface TGPasscodeSignals : NSObject

+ (SSignal *)passcodeStatus;

@end
