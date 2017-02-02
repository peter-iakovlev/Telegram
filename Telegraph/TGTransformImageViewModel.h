#import "TGModernViewModel.h"

#import <SSignalKit/SSignalKit.h>

@class TransformImageArguments;

@interface TGTransformImageViewModel : TGModernViewModel

@property (nonatomic, strong) TransformImageArguments *arguments;

- (void)setSignalGenerator:(SSignal *(^)())signalGenerator identifier:(NSString *)identifier;

@end
