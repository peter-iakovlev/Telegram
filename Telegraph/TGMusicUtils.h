#import <Foundation/Foundation.h>

@interface TGMusicUtils : NSObject

+ (void)albumArtworkForURL:(NSURL *)url completion:(void (^)(UIImage *))completion;

@end
