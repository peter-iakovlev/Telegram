#import "TGModernViewModel.h"

@class SSignal;

@interface TGModernDataImageViewModel : TGModernViewModel

@property (nonatomic, assign) UIViewContentMode contentMode;
- (instancetype)initWithUri:(NSString *)uri options:(NSDictionary *)options;

- (void)setUri:(NSString *)uri options:(NSDictionary *)options;

@end
