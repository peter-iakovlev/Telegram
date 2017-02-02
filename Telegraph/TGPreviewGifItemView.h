#import "TGMenuSheetItemView.h"

@class TGDocumentMediaAttachment;
@class TGBotContextExternalResult;

@interface TGPreviewGifItemView : TGMenuSheetItemView

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document;
- (instancetype)initWithBotContextExternalResult:(TGBotContextExternalResult *)result;

@end
