#import "TGWidget.h"

@interface TGWidget ()
{
    SMulticastSignalManager *_signalManager;
    SQueue *_queue;
    SVariable *_shareContext;
    SVariable *_database;
}
@end

@implementation TGWidget

- (SMulticastSignalManager *)tasksSignalManager
{
    if (_signalManager == nil) {
        _signalManager = [[SMulticastSignalManager alloc] init];
    }
    return _signalManager;
}

- (SQueue *)queue
{
    if (_queue == nil) {
        _queue = [[SQueue alloc] init];
    }
    return _queue;
}

- (SSignal *)shareContext
{
    if (_shareContext == nil) {
        _shareContext = [[SVariable alloc] init];
        [_shareContext set:[TGShareContextSignal shareContext]];
    }
    return [[_shareContext signal] deliverOn:[self queue]];
}

- (SSignal *)database
{
    if (_database == nil) {
        _database = [[SVariable alloc] init];
        [_database set:[[self shareContext] mapToSignal:^id(TGShareContext *context) {
            return [context legacyDatabase];
        }]];
    }
    return [[_database signal] deliverOn:[self queue]];
}

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static TGWidget *widget;
    dispatch_once(&onceToken, ^
    {
        widget = [[TGWidget alloc] init];
    });
    return widget;
}

@end
