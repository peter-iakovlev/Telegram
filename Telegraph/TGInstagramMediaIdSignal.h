#import <SSignalKit/SSignalKit.h>

@interface TGInstagramMediaIdSignal : NSObject

+ (SSignal *)instagramMediaIdForShortcode:(NSString *)shortcode;

+ (NSString *)instagramShortcodeFromText:(NSString *)text;

@end
