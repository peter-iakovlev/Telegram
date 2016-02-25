#import <Foundation/Foundation.h>

@class TGVTPlayerView;

@interface TGVTPlayer : NSObject

- (instancetype)initWithUrl:(NSURL *)url;

- (void)play;
- (void)stop;

- (void)_setOutput:(TGVTPlayerView *)playerView;

@end
