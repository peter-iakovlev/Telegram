#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGSingleStickerPreviewView : UIView

@property (nonatomic, copy) CGPoint(^sourcePointForDocument)(TGDocumentMediaAttachment *document);

@property (nonatomic, assign) bool eccentric;
@property (nonatomic, strong) TGDocumentMediaAttachment *document;

- (void)setDocument:(TGDocumentMediaAttachment *)document associations:(NSArray *)associations;

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

@end
