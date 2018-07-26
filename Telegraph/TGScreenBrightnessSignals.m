#import "TGScreenBrightnessSignals.h"

@implementation TGScreenBrightnessSignals

+ (SSignal *)brightnessSignal
{
    SSignal *updateSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenBrightnessDidChangeNotification object:nil queue:nil usingBlock:^(__unused NSNotification * _Nonnull note)
        {
            [subscriber putNext:@([UIScreen mainScreen].brightness)];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    }];
    
    return [[SSignal defer:^SSignal *{
        return [SSignal single:@([UIScreen mainScreen].brightness)];
    }] then:updateSignal];
}

@end
