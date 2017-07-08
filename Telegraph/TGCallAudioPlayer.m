#import "TGCallAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface TGCallAudioPlayer () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *_player;
}

@property (nonatomic, copy) void (^completionBlock)(void);

@end

@implementation TGCallAudioPlayer

- (instancetype)initWithURL:(NSURL *)url loops:(NSInteger)loops
{
    self = [super init];
    if (self != nil)
    {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        _player.numberOfLoops = loops;
        _player.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self stop];
}

- (void)play
{
    [_player play];
}

- (void)stop
{
    [_player stop];
    _player.delegate = nil;
    _player = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)__unused player successfully:(BOOL)__unused flag
{
    TGDispatchOnMainThread(^
    {
        if (self.completionBlock != nil)
            self.completionBlock();
        
        _player.delegate = nil;
    });
}

+ (instancetype)playFileURL:(NSURL *)url loops:(NSInteger)loops completion:(void (^)(void))completion
{
    TGCallAudioPlayer *player = [[TGCallAudioPlayer alloc] initWithURL:url loops:loops];
    player.completionBlock = completion;
    [player play];
    return player;
}

@end
