#import "TGHttpServerActor.h"

#import <thirdparty/AsyncSocket/GCDAsyncSocket.h>

#import "ActionStage.h"

static const char *serverQueueSpecific = "ph.telegra.serverqueue";

static dispatch_queue_t serverQueue()
{
    static dispatch_queue_t queue = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = dispatch_queue_create("ph.telegra.serverqueue", 0);
        if (dispatch_queue_set_specific != NULL)
            dispatch_queue_set_specific(queue, serverQueueSpecific, (void *)serverQueueSpecific, NULL);
    });
    
    return queue;
}

static void dispatchOnServerQueue(dispatch_block_t block, bool synchronous)
{
    if (block == NULL)
        return;
    
    bool currentQueueIsServerQueue = false;
    currentQueueIsServerQueue = dispatch_get_specific(serverQueueSpecific) == serverQueueSpecific;
    
    if (currentQueueIsServerQueue)
        block();
    else
    {
        if (synchronous)
            dispatch_sync(serverQueue(), block);
        else
            dispatch_async(serverQueue(), block);
    }
}

@interface TGHttpServerActor ()

@property (nonatomic, strong) NSString *serverUrl;

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *clientSockets;

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) int fileSize;

@end

@implementation TGHttpServerActor

@synthesize actionHandle = _actionHandle;

@synthesize serverUrl = _serverUrl;

@synthesize serverSocket = _serverSocket;
@synthesize clientSockets = _clientSockets;

@synthesize filePath = _filePath;
@synthesize fileSize = _fileSize;

+ (NSString *)genericPath
{
    return @"/as/streamingProxy/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        _clientSockets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    _actionHandle = nil;
    
    [self closeSockets];
}

- (void)execute:(NSDictionary *)__unused options
{
    NSString *url = [self.path substringWithRange:NSMakeRange(@"/as/streamingProxy/(".length, self.path.length - 1 - @"/as/streamingProxy/(".length)];
    if ([url hasPrefix:@"video"])
    {
        NSFileManager *fileManager = [ActionStageInstance() globalFileManager];
        
        static NSString *videosPath = nil;
        if (videosPath == nil)
        {
            videosPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0] stringByAppendingPathComponent:@"video"];
            if (![fileManager fileExistsAtPath:videosPath])
            {
                NSError *error = nil;
                [fileManager createDirectoryAtPath:videosPath withIntermediateDirectories:true attributes:nil error:&error];
                if (error != nil)
                {
                    TGLog(@"%@", error);
                    
                    [ActionStageInstance() actionFailed:self.path reason:-1];
                    return;
                }
            }
        }
        
        NSArray *urlComponents = [url componentsSeparatedByString:@":"];
        int64_t videoId = [[urlComponents objectAtIndex:1] longLongValue];
        _filePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]];
        _fileSize = [[urlComponents objectAtIndex:4] intValue];
        
        dispatchOnServerQueue(^
        {
            int port = 12001;
            
            _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:serverQueue()];
            NSError *error = nil;
            [_serverSocket acceptOnPort:(uint16_t)port error:&error];
            
            if (error != nil)
            {
                [ActionStageInstance() actionFailed:self.path reason:-1];
                return;
            }
            
            _serverUrl = [[NSString alloc] initWithFormat:@"http://localhost:%d/video.mp4", port];
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"url" message:_serverUrl];
        }, false);
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    dispatchOnServerQueue(^
    {
        [watcherHandle receiveActorMessage:self.path messageType:@"url" message:_serverUrl];
    }, false);
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    if (socket == _serverSocket)
    {
        [_clientSockets addObject:newSocket];
        [newSocket readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 maxLength:10 * 1024 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)__unused tag
{
    if (socket != _serverSocket)
    {
        NSString *request = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        TGLog(@"%@", request);
        
        NSArray *components = [request componentsSeparatedByString:@"\r\n"];
        
        for (NSString *component in components)
        {
            if ([component hasPrefix:@"Range:"])
            {
                NSString *range = [[component substringFromIndex:@"Range:".length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([range hasPrefix:@"bytes="])
                {
                    NSArray *rangeComponents = [[range substringFromIndex:@"bytes=".length] componentsSeparatedByString:@"-"];
                    if (rangeComponents.count == 2)
                    {
                        int startIndex = [[rangeComponents objectAtIndex:0] intValue];
                        int endIndex = [[rangeComponents objectAtIndex:1] intValue];
                        
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
                        [fileHandle seekToFileOffset:startIndex];
                        NSData *data = [fileHandle readDataOfLength:endIndex - startIndex + 1];
                        [fileHandle closeFile];
                        
                        NSMutableString *responseHeader = [[NSMutableString alloc] init];
                        [responseHeader appendFormat:@"HTTP/1.1 206 Partial content\r\n"];
                        [responseHeader appendFormat:@"Accept-Ranges: 0-%d\r\n", _fileSize];
                        [responseHeader appendString:@"Connection: close\r\n"];
                        [responseHeader appendString:@"Content-Type: video/mp4\r\n"];
                        [responseHeader appendString:@"Content-Disposition: inline;\r\n"];
                        [responseHeader appendFormat:@"Content-Range: bytes %d-%d/%d\r\n", startIndex, endIndex, _fileSize];
                        [responseHeader appendFormat:@"Content-Length: %d\r\n", (int)data.length];
                        [responseHeader appendString:@"\r\n"];
                        
                        TGLog(@"Response:\n%@", responseHeader);
                        
                        [socket writeData:[responseHeader dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                        [socket writeData:data withTimeout:-1 tag:0];
                    }
                }
                
                break;
            }
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error
{
    TGLog(@"Socket disconnected with error: %@", error);
    if (socket != _serverSocket)
        [_clientSockets removeObject:socket];
}

- (void)closeSockets
{
    GCDAsyncSocket *serverSocket = _serverSocket;
    _serverSocket = nil;
    
    NSMutableArray *clientSockets = _clientSockets;
    _clientSockets = nil;
    
    dispatchOnServerQueue(^
    {
        [serverSocket disconnect];
        
        for (GCDAsyncSocket *clientSocket in clientSockets)
        {
            [clientSocket synchronouslySetDelegate:nil];
            [clientSocket disconnect];
        }
        
        [clientSockets removeAllObjects];
    }, true);
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    [self closeSockets];
}

@end
