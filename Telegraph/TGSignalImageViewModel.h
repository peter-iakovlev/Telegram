#import "TGModernViewModel.h"

#import <SSignalKit/SSignalKit.h>

@interface TGSignalImageViewModel : TGModernViewModel

@property (nonatomic) bool showProgress;
@property (nonatomic) CGRect transitionContentRect;

- (void)setSignalGenerator:(SSignal *(^)())signalGenerator identifier:(NSString *)identifier;

@end
