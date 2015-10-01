#import <UIKit/UIKit.h>

@interface TGStickerPreviewPage : UIView

@property (nonatomic) NSUInteger pageIndex;

- (void)setDocuments:(NSArray *)documents stickerAssociations:(NSArray *)stickerAssociations;

- (void)prepareForReuse;

@end
