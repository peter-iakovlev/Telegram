#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGSingleStickerPreviewView : UIView

@property (nonatomic, strong) TGDocumentMediaAttachment *document;

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

@end
