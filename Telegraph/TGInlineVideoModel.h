#import "TGModernViewModel.h"

#import <SSignalKit/SSignalKit.h>

@interface TGInlineVideoModel : TGModernViewModel

@property (nonatomic, strong) SSignal *videoPathSignal;

@end
