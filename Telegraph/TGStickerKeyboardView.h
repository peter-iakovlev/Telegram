#import <UIKit/UIKit.h>

@class TGViewController;
@class TGDocumentMediaAttachment;

typedef enum
{
    TGStickerKeyboardViewDefaultStyle,
    TGStickerKeyboardViewDarkBlurredStyle
} TGStickerKeyboardViewStyle;

@interface TGStickerKeyboardView : UIView

@property (nonatomic) bool enableAnimation;

@property (nonatomic, weak) TGViewController *parentViewController;
@property (nonatomic, copy) void (^stickerSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifTabActive)(bool active);

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style;

- (void)sizeToFitForWidth:(CGFloat)width;
- (void)updateIfNeeded;

@end
