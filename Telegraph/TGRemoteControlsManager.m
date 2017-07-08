#import "TGRemoteControlsManager.h"

#import <pthread.h>

#import <MediaPlayer/MediaPlayer.h>

@interface TGRemoteControlsClient : NSObject

@property (nonatomic, readonly) int32_t clientId;
@property (nonatomic, copy, readonly) void (^previous)();
@property (nonatomic, copy, readonly) void (^next)();
@property (nonatomic, copy, readonly) void (^play)();
@property (nonatomic, copy, readonly) void (^pause)();
@property (nonatomic, copy, readonly) void (^position)(NSTimeInterval);

@end

@implementation TGRemoteControlsClient

- (instancetype)initWithId:(int32_t)clientId previous:(void (^)())previous next:(void (^)())next play:(void (^)())play pause:(void (^)())pause position:
(void (^)(NSTimeInterval))position
{
    self = [super init];
    if (self != nil)
    {
        _clientId = clientId;
        _previous = [previous copy];
        _next = [next copy];
        _play = [play copy];
        _pause = [pause copy];
        _position = [position copy];
    }
    return self;
}

@end

@interface TGRemoteControlsManager ()
{
    pthread_mutex_t _mutex;
    int32_t _clientId;
    
    NSMutableArray *_currentClients;
}

@end

@implementation TGRemoteControlsManager

+ (TGRemoteControlsManager *)instance
{
    static TGRemoteControlsManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGRemoteControlsManager alloc] init];
    });
    
    return singleton;
}

- (bool)isEnabled
{
    return iosMajorVersion() > 7 || (iosMajorVersion() == 7 && iosMinorVersion() >= 1);
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        pthread_mutex_init(&_mutex, NULL);
        _currentClients = [[NSMutableArray alloc] init];
        
        if ([self isEnabled])
        {
            MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
            [commandCenter.playCommand addTarget:self action:@selector(playCommandEvent:)];
            [commandCenter.pauseCommand addTarget:self action:@selector(pauseCommandEvent:)];
            [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackCommandEvent:)];
            [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackCommandEvent:)];
            [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(togglePlayPauseCommandEvent:)];
            
            if (iosMajorVersion() > 9 || (iosMajorVersion() == 9 && iosMinorVersion() >= 1))
                [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(changePlaybackPositionCommandEvent:)];
        }
    }
    return self;
}

- (void)dealloc
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.playCommand removeTarget:self];
    [commandCenter.pauseCommand removeTarget:self];
    [commandCenter.previousTrackCommand removeTarget:self];
    [commandCenter.nextTrackCommand removeTarget:self];
    [commandCenter.togglePlayPauseCommand removeTarget:self];
    
    if (iosMajorVersion() > 9 || (iosMajorVersion() == 9 && iosMinorVersion() >= 1))
        [commandCenter.changePlaybackPositionCommand removeTarget:self];
}

- (void)previousTrackCommandEvent:(id)__unused event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.previous)
            client.previous();
    }
}

- (void)nextTrackCommandEvent:(id)__unused event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.next)
            client.next();
    }
}

- (void)playCommandEvent:(id)__unused event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.play)
            client.play();
        else if (client.pause)
            client.pause();
    }
}

- (void)pauseCommandEvent:(id)__unused event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.pause)
            client.pause();
    }
}

- (void)togglePlayPauseCommandEvent:(id)__unused event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.play)
            client.play();
        else if (client.pause)
            client.pause();
    }
}

- (MPRemoteCommandHandlerStatus)changePlaybackPositionCommandEvent:(MPChangePlaybackPositionCommandEvent *)event
{
    NSArray *clients = nil;
    pthread_mutex_lock(&_mutex);
    clients = [[NSArray alloc] initWithArray:_currentClients];
    pthread_mutex_unlock(&_mutex);
    
    for (TGRemoteControlsClient *client in clients)
    {
        if (client.position)
            client.position(event.positionTime);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (id<SDisposable>)requestControlsWithPrevious:(void (^)())previous next:(void (^)())next play:(void (^)())play pause:(void (^)())pause position:(void (^)(NSTimeInterval position))position
{
    id<SDisposable> result = nil;
    
    pthread_mutex_lock(&_mutex);
    {
        int32_t clientId = _clientId++;
        
        if (_currentClients.count == 0)
        {
            TGLog(@"(TGRemoteControlsManager requesting remote controls)");
        }
        
        [_currentClients removeAllObjects];
        [_currentClients addObject:[[TGRemoteControlsClient alloc] initWithId:clientId previous:previous next:next play:play pause:pause position:position]];
        
        MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        commandCenter.playCommand.enabled = play != nil;
        commandCenter.pauseCommand.enabled = pause != nil;
        commandCenter.previousTrackCommand.enabled = previous != nil;
        commandCenter.nextTrackCommand.enabled = next != nil;
        commandCenter.togglePlayPauseCommand.enabled = play != nil || pause != nil;
        
        if (iosMajorVersion() > 9 || (iosMajorVersion() == 9 && iosMinorVersion() >= 1))
            commandCenter.changePlaybackPositionCommand.enabled = position != nil;
        
        __weak TGRemoteControlsManager *weakSelf = self;
        result = [[SBlockDisposable alloc] initWithBlock:^
        {
            __strong TGRemoteControlsManager *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf endControlsForClientId:clientId];
        }];
    }
    pthread_mutex_unlock(&_mutex);
    
    return result;
}

- (void)endControlsForClientId:(int32_t)clientId
{
    pthread_mutex_lock(&_mutex);
    {
        bool previousHadClients = _currentClients.count != 0;
        
        for (NSUInteger i = 0; i < _currentClients.count; i++)
        {
            if (((TGRemoteControlsClient *)_currentClients[i]).clientId == clientId)
            {
                [_currentClients removeObjectAtIndex:i];
                break;
            }
        }
        
        if (_currentClients.count == 0 && previousHadClients)
        {
            TGLog(@"(TGRemoteControlsManager revoking remote controls)");
            
            MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
            commandCenter.playCommand.enabled = false;
            commandCenter.pauseCommand.enabled = false;
            commandCenter.previousTrackCommand.enabled = false;
            commandCenter.nextTrackCommand.enabled = false;
            commandCenter.togglePlayPauseCommand.enabled = false;
            
            if (iosMajorVersion() > 9 || (iosMajorVersion() == 9 && iosMinorVersion() >= 1))
                commandCenter.changePlaybackPositionCommand.enabled = false;
        }
    }
    pthread_mutex_unlock(&_mutex);
}

@end
