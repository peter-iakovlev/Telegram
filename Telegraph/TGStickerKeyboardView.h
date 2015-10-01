#import <UIKit/UIKit.h>

@class TGViewController;
@class TGDocumentMediaAttachment;

@interface TGStickerKeyboardView : UIView

@property (nonatomic, weak) TGViewController *parentViewController;
@property (nonatomic, copy) void (^stickerSelected)(TGDocumentMediaAttachment *);

- (void)sizeToFitForWidth:(CGFloat)width;
- (void)updateIfNeeded;

@end
