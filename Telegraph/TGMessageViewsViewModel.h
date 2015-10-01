#import "TGModernViewModel.h"

typedef enum {
    TGMessageViewsViewTypeIncoming,
    TGMessageViewsViewTypeOutgoing,
    TGMessageViewsViewTypeMedia
} TGMessageViewsViewType;

@interface TGMessageViewsViewModel : TGModernViewModel

@property (nonatomic) int32_t count;
@property (nonatomic) TGMessageViewsViewType type;

@end
