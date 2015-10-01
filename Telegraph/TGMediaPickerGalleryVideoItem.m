#import "TGMediaPickerGalleryVideoItem.h"

#import "TGMediaPickerGalleryVideoItemView.h"

#import "TGMediaPickerAsset+TGEditablePhotoItem.h"
#import "AVURLAsset+TGEditablePhotoItem.h"

@interface TGMediaPickerGalleryVideoItem ()
{
    CGSize _dimensions;
    NSTimeInterval _duration;
}
@end

@implementation TGMediaPickerGalleryVideoItem

@synthesize itemSelected = _itemSelected;

- (instancetype)initWithFileURL:(NSURL *)fileURL dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self != nil)
    {
        _avAsset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
        _dimensions = dimensions;
        _duration = duration;
    }
    return self;
}

- (CGSize)dimensions
{
    if (self.asset != nil)
        return self.asset.dimensions;
    
    return _dimensions;
}

- (NSTimeInterval)duration
{
    if (self.asset != nil)
        return self.asset.actualVideoDuration;
    
    return _duration;
}

- (NSString *)uniqueId
{
    if (self.asset != nil)
        return self.asset.uniqueId;
    else if (self.avAsset != nil)
        return self.avAsset.URL.absoluteString;
    
    return nil;
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    if (self.asset != nil)
        return self.asset;
    else if (self.avAsset != nil)
        return self.avAsset;
    
    return nil;
}

- (Class)viewClass
{
    return [TGMediaPickerGalleryVideoItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGMediaPickerGalleryVideoItem class]]
    && ((self.asset != nil && TGObjectCompare(self.asset, ((TGMediaPickerGalleryItem *)object).asset)) ||
    (self.avAsset != nil && TGObjectCompare(self.avAsset.URL, ((TGMediaPickerGalleryVideoItem *)object).avAsset.URL)));
}

@end
