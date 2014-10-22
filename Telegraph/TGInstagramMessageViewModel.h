#import "TGImageMessageViewModel.h"

@interface TGInstagramMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithShortcode:(NSString *)shortcode message:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context;

@end
