#import "TGPassportGalleryItem.h"

#import "TGPassportGalleryItemView.h"

@implementation TGPassportGalleryItem

- (instancetype)initWithIndex:(int32_t)index file:(id)file
{
    self = [super init];
    if (self != nil)
    {
        _index = index;
        _file = file;
    }
    return self;
}

- (Class)viewClass {
    return [TGPassportGalleryItemView class];
}

@end
