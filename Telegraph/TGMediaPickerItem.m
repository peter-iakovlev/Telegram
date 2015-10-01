#import "TGMediaPickerItem.h"

#import "TGMediaPickerAsset+TGEditablePhotoItem.h"

#import "TGMediaPickerPhotoItemView.h"
#import "TGMediaPickerVideoItemView.h"

@implementation TGMediaPickerItem

@synthesize itemSelected = _itemSelected;
@synthesize isItemSelected = _isItemSelected;
@synthesize isItemHidden = _isItemHidden;

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset itemSelected:(void (^)(id<TGModernMediaListItem>, bool))itemSelected isItemSelected:(bool (^)(id<TGModernMediaListItem>))isItemSelected isItemHidden:(bool (^)(id<TGModernMediaListItem>))isItemHidden
{
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
        
        _itemSelected = [itemSelected copy];
        _isItemSelected = [isItemSelected copy];
        _isItemHidden = [isItemHidden copy];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    TGMediaPickerItem *item = [[TGMediaPickerItem alloc] initWithAsset:self.asset
                                                          itemSelected:nil
                                                        isItemSelected:nil
                                                          isItemHidden:nil];
    return item;
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    return self.asset;
}

- (NSString *)uniqueId
{
    return self.asset.uniqueId;
}

- (Class)viewClass
{
    if (self.asset.isVideo)
        return [TGMediaPickerVideoItemView class];
    else
        return [TGMediaPickerPhotoItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGMediaPickerItem class]] && TGObjectCompare(_asset, ((TGMediaPickerItem *)object)->_asset);
}

@end
