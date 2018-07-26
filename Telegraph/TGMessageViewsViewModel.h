#import "TGModernViewModel.h"

@class TGPresentation;

typedef enum {
    TGMessageViewsViewTypeIncoming,
    TGMessageViewsViewTypeOutgoing,
    TGMessageViewsViewTypeMedia
} TGMessageViewsViewType;

@interface TGMessageViewsViewModel : TGModernViewModel

@property (nonatomic) int32_t count;
@property (nonatomic) TGMessageViewsViewType type;
@property (nonatomic, strong) TGPresentation *presentation;

@end
