#import "TGAttachmentSheetRecentAssetCell.h"

#import "TGImageView.h"
#import "TGImagePickerCellCheckButton.h"

#import "TGMediaPickerItem.h"
#import "TGMediaPickerAsset.h"
#import "TGAssetImageManager.h"

#import "TGImageUtils.h"

#import "PGPhotoEditorValues.h"
#import "TGModernMediaListEditableItem.h"
#import "TGEditablePhotoItem.h"

@interface TGAttachmentSheetRecentAssetCell ()
{
    TGImageView *_imageView;
    TGImagePickerCellCheckButton *_checkButton;
    NSUInteger _loadToken;
    int32_t _requestId;
    
    bool (^_isItemSelected)(TGMediaPickerItem *);
    bool (^_isItemHidden)(TGMediaPickerItem *);
    void (^_changeItemSelection)(TGMediaPickerItem *);
    void (^_openItem)(TGMediaPickerItem *);
}

@end

@implementation TGAttachmentSheetRecentAssetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {        
        _imageView = [[TGImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapGesture:)]];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_checkButton.frame, point))
        return _checkButton;
    if (CGRectContainsPoint(_imageView.frame, point))
        return _imageView;
    
    return [super hitTest:point withEvent:event];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (_loadToken != 0)
    {
        [TGAssetImageManager cancelRequestWithToken:_loadToken];
        _loadToken = 0;
    }
}

- (void)imageTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_openItem)
            _openItem(_item);
    }
}

- (void)checkButtonPressed
{
    if (_changeItemSelection)
        _changeItemSelection(_item);
    if (_isItemSelected)
        [_checkButton setChecked:_isItemSelected(_item) animated:true];
}

- (void)setItem:(TGMediaPickerItem *)item isItemSelected:(bool (^)(id<TGModernMediaListItem>))isItemSelected isItemHidden:(bool (^)(id<TGModernMediaListItem>))isItemHidden changeItemSelection:(void (^)(id<TGModernMediaListItem>))changeItemSelection openItem:(void (^)(TGMediaPickerItem *))openItem
{
    _isItemSelected = [isItemSelected copy];
    _isItemHidden = [isItemHidden copy];
    _changeItemSelection = [changeItemSelection copy];
    _openItem = [openItem copy];
    _item = item;

    [self updateSelection];
    [self updateHidden:false];
    
    [self updateItem];
}

- (void)updateItem
{
    _requestId++;
    
    id<TGEditablePhotoItem> editableMediaItem = _item.editableMediaItem;
    if (editableMediaItem.fetchEditorValues != nil)
    {
        id<TGMediaEditAdjustments> editorValues = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (editorValues != nil && editableMediaItem.fetchThumbnailImage != nil)
        {
            UIImage *image = editableMediaItem.fetchThumbnailImage(editableMediaItem);
            TGDispatchOnMainThread(^
            {
                if (image != nil)
                    [_imageView loadUri:@"embedded://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
                else
                    [_imageView reset];
            });
        }
        else
            [self loadFromAsset];
    }
    else
        [self loadFromAsset];
}

- (void)loadFromAsset
{
    _requestId++;
    int32_t requestId = _requestId;
    __weak TGAttachmentSheetRecentAssetCell *weakSelf = self;
    CGSize requestedSize = CGSizeMake(157, 157);
    
    _loadToken = [TGAssetImageManager requestImageWithAsset:_item.asset imageType:TGAssetImageTypeThumbnail size:requestedSize synchronous:false progressBlock:nil completionBlock:^(UIImage *image, __unused NSError *error)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGAttachmentSheetRecentAssetCell *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_requestId == requestId)
                {
                    if (image != nil)
                        [strongSelf->_imageView loadUri:@"embedded://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
                    else
                        [strongSelf->_imageView reset];
                    
                    strongSelf->_loadToken = 0;
                }
            }
        });
    }];
}

- (UIView *)referenceViewForAsset:(TGMediaPickerAsset *)asset
{
    if ([asset isEqual:_item.asset])
        return _imageView;
    
    return nil;
}

- (UIImage *)imageForAsset:(TGMediaPickerAsset *)asset
{
    if ([asset isEqual:_item.asset])
        return _imageView.image;
    
    return nil;
}

- (void)updateSelection
{
    if (_isItemSelected)
    {
        if (_checkButton == nil)
        {
            _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 33.0f - 0.0f, self.frame.size.height - 33.0f + 1.0f, 33.0f, 33.0f)];
            _checkButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            [_checkButton setChecked:false animated:false];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_checkButton];
        }
        
        bool checked = _isItemSelected(_item);
        if (checked != _checkButton.checked)
            [_checkButton setChecked:checked animated:false];
    }
}

- (void)updateHidden:(bool)animated
{
    if (_isItemHidden)
    {
        bool hidden = _isItemHidden(_item);
        if (hidden != _imageView.hidden)
        {
            _imageView.hidden = hidden;
            
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
                _imageView.hidden = hidden;
                _checkButton.alpha = hidden ? 0.0f : 1.0f;
            }
        }
    }
}

@end
