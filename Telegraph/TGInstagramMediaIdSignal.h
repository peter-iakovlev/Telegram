#import <SSignalKit/SSignalKit.h>

@interface TGInstagramMediaIdSignal : NSObject

+ (SSignal *)instagramMediaIdForShortcode:(NSString *)shortcode;

@end
