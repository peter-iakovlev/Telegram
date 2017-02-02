#import "TGMenuSheetItemView.h"

@class TGWebPageMediaAttachment;
@class TGLocationMediaAttachment;
@class TGDocumentMediaAttachment;

@interface TGPreviewAboutItemView : TGMenuSheetItemView

- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)attachment;
- (instancetype)initWithLocationAttachment:(TGLocationMediaAttachment *)attachment;
- (instancetype)initWithDocumentAttachment:(TGDocumentMediaAttachment *)attachment;

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
