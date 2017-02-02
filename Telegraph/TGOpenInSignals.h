#import <SSignalKit/SSignalKit.h>

@class TGOpenInAppItem;

@interface TGOpenInSignals : NSObject

+ (SSignal *)iconForAppItem:(TGOpenInAppItem *)appItem;

@end
