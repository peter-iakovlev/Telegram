#import "TGScreenCaptureSignals.h"
#import <LegacyComponents/TGObserverProxy.h>

@interface TGScreenCaptureAdapter : NSObject
{
    UIScreen *_screen;
    void (^_updated)(bool isCaptured);
}

- (instancetype)initWithScreen:(UIScreen *)screen updated:(void (^)(bool isCaptured))updated;

@end

@implementation TGScreenCaptureSignals

+ (SSignal *)screenshotTakenSignal
{
    if (iosMajorVersion() < 7)
        return [SSignal complete];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:nil usingBlock:^(__unused NSNotification * _Nonnull note)
        {
            [subscriber putNext:@true];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    }];
}

+ (SSignal *)screenCapturedSignal
{
    if (![[UIScreen mainScreen] respondsToSelector:@selector(isCaptured)])
        return [SSignal complete];
    
    SSignal *initialSignal = [UIScreen mainScreen].isCaptured ? [SSignal single:@true] : [SSignal complete];
    SSignal *updateSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGScreenCaptureAdapter *adapter = [[TGScreenCaptureAdapter alloc] initWithScreen:[UIScreen mainScreen] updated:^(bool isCaptured)
        {
            if (isCaptured)
                [subscriber putNext:@true];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [adapter description];
        }];
    }];
    return [initialSignal then:updateSignal];
}

@end


@implementation TGScreenCaptureAdapter

- (instancetype)initWithScreen:(UIScreen *)screen updated:(void (^)(bool))updated
{
    self = [super init];
    if (self != nil)
    {
        _screen = screen;
        _updated = updated;
        [_screen addObserver:self forKeyPath:@"captured" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [_screen removeObserver:self forKeyPath:@"captured"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)change context:(void *)__unused context
{
    if ([keyPath isEqualToString:@"captured"])
    {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (_updated != nil)
            _updated([newValue boolValue]);
    }
}

@end
