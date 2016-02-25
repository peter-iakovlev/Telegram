#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGStickerPreviewPage : UIView

@property (nonatomic) NSUInteger pageIndex;

- (void)setDocuments:(NSArray *)documents stickerAssociations:(NSArray *)stickerAssociations;
- (TGDocumentMediaAttachment *)documentAtPoint:(CGPoint)point;

- (void)prepareForReuse;

@end
