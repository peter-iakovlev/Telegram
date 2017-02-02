#import "TGItemCollectionGalleryItem.h"

#import "TGItemCollectionGalleryItemView.h"
#import "TGItemCollectionGalleryVideoItemView.h"

#import "TGVideoMediaAttachment.h"

@implementation TGItemCollectionGalleryItem

- (instancetype)initWithMedia:(TGInstantPageMedia *)media {
    self = [super init];
    if (self != nil) {
        _media = media;
    }
    return self;
}

- (Class)viewClass {
    if ([_media.media isKindOfClass:[TGVideoMediaAttachment class]] && !((TGVideoMediaAttachment *)_media.media).loopVideo) {
        return [TGItemCollectionGalleryVideoItemView class];
    } else {
        return [TGItemCollectionGalleryItemView class];
    }
}

@end
