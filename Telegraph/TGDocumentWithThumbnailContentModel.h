#import "TGContentBubbleEmbeddedMediaModel.h"

@class TGDocumentMediaAttachment;

@interface TGDocumentWithThumbnailContentModel : TGContentBubbleEmbeddedMediaModel

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document incomingAppearance:(bool)incomingAppearance;

@end
