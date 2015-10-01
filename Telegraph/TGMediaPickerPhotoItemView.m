#import "TGMediaPickerPhotoItemView.h"

#import "TGMediaPickerItem.h"

#import "TGStringUtils.h"

#import "TGImagePickerCellCheckButton.h"

#import "PGPhotoEditorValues.h"
#import "TGModernMediaListEditableItem.h"
#import "TGEditablePhotoItem.h"

#import "TGAssetImageView.h"

@interface TGMediaPickerPhotoItemView ()

@property (nonatomic, strong) TGMediaPickerItem *item;

@end

@implementation TGMediaPickerPhotoItemView

@dynamic item;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (void)updateItem
{
    id<TGEditablePhotoItem> editableMediaItem = self.item.editableMediaItem;
    if (editableMediaItem.fetchEditorValues != nil)
    {
        id<TGMediaEditAdjustments> adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (adjustments != nil && editableMediaItem.fetchThumbnailImage != nil)
        {
            UIImage *image = editableMediaItem.fetchThumbnailImage(editableMediaItem);
            TGDispatchOnMainThread(^
            {
                if (image != nil)
                    [self setImage:image];
            });
        }
        else
        {
            [self setAsset:self.item.asset];
        }
    }
    else
    {
        [self setAsset:self.item.asset];
    }
}

- (void)updateHiddenAnimated:(bool)animated
{
    if (_isItemHidden)
    {
        bool hidden = _isItemHidden(self.item);
        if (hidden != self.imageView.hidden)
        {
            self.imageView.hidden = hidden;
            
            if (animated)
            {
                if (!hidden)
                    _checkButton.alpha = 0.0f;
                [UIView animateWithDuration:0.2 animations:^
                {
                    if (!hidden)
                        _checkButton.alpha = 1.0f;
                }];
            }
            else
            {
                self.imageView.hidden = hidden;
                _checkButton.alpha = hidden ? 0.0f : 1.0f;
            }
        }
    }
}

@end
