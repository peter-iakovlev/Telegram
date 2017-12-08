#import "TGItemCollectionGalleryItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGItemCollectionGalleryItemView.h"
#import "TGItemCollectionGalleryVideoItemView.h"

@implementation TGItemCollectionGalleryItem

- (instancetype)initWithIndex:(int32_t)index media:(TGInstantPageMedia *)media {
    self = [super init];
    if (self != nil) {
        _index = index;
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
