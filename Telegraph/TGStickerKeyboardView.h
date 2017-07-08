#import "TGModernConversationKeyboardView.h"

@class TGViewController;
@class TGDocumentMediaAttachment;

typedef enum
{
    TGStickerKeyboardViewDefaultStyle,
    TGStickerKeyboardViewDarkBlurredStyle,
    TGStickerKeyboardViewPaintStyle,
    TGStickerKeyboardViewPaintDarkStyle
} TGStickerKeyboardViewStyle;

@interface TGStickerKeyboardView : UIView <TGModernConversationKeyboardView>

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic) bool enableAnimation;

@property (nonatomic, readonly) bool isGif;

@property (nonatomic, weak) TGViewController *parentViewController;
@property (nonatomic, copy) void (^stickerSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifTabActive)(bool active);

@property (nonatomic, copy) void (^requestedExpand)(bool expand);
@property (nonatomic, copy) void (^expandInteraction)(CGFloat offset);

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style;

- (void)sizeToFitForWidth:(CGFloat)width;
- (void)updateIfNeeded;

- (void)updateExpanded;

@end
