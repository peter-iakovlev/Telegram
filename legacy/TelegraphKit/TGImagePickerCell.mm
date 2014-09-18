#import "TGImagePickerCell.h"

#import "TGRemoteImageView.h"
#import "TGImagePickerCellCheckButton.h"

#import "TGImageUtils.h"

#import <vector>

@interface TGImagePickerCell ()
{
    std::vector<int> _searchIds;
}

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *buttonViews;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *assetsSelected;

@property (nonatomic) bool selectionControls;

@property (nonatomic) int imagesInRow;
@property (nonatomic) CGFloat imageSize;
@property (nonatomic) CGFloat inset;

@end

@implementation TGImagePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectionControls:(bool)selectionControls imageSize:(float)imageSize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _selectionControls = selectionControls;
        _imageSize = imageSize;
        
        _imageViews = [[NSMutableArray alloc] init];
        _buttonViews = [[NSMutableArray alloc] init];
        _assets = [[NSMutableArray alloc] init];
        _assetsSelected = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetImages:(int)imagesInRow imageSize:(CGFloat)imageSize inset:(CGFloat)inset
{
    _imagesInRow = imagesInRow;
    _imageSize = imageSize;
    _inset = inset;
    
    [_assets removeAllObjects];
    [_assetsSelected removeAllObjects];
    _searchIds.clear();
    
    for (UIImageView *imageView in _imageViews)
    {
        imageView.hidden = true;
    }
    
    if (_selectionControls)
    {
        for (UIButton *button in _buttonViews)
        {
            button.hidden = true;
        }
    }
}

- (void)addAsset:(TGImagePickerAsset *)asset isSelected:(bool)isSelected withImage:(UIImage *)image
{
    [self _addItem:asset argument:image intArgument:0 isSelected:isSelected];
}

- (void)addImage:(TGImageInfo *)imageInfo searchId:(int)searchId isSelected:(bool)isSelected
{
    [self _addItem:imageInfo argument:[NSNull null] intArgument:searchId isSelected:isSelected];
}

- (void)_addItem:(id)data argument:(id)argument intArgument:(int)intArgument isSelected:(bool)isSelected
{
    TGRemoteImageView *imageView = nil;
    TGImagePickerCellCheckButton *buttonView = nil;
    
    if (_imageViews.count <= _assets.count)
    {
        imageView = [[TGRemoteImageView alloc] initWithFrame:CGRectZero];
        imageView.fadeTransition = true;
        imageView.clipsToBounds = true;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        imageView.userInteractionEnabled = true;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)]];
        [_imageViews addObject:imageView];
        [self.contentView addSubview:imageView];
        
        if (_selectionControls)
        {
            buttonView = [[TGImagePickerCellCheckButton alloc] init];
            [buttonView addTarget:self action:@selector(checkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonViews addObject:buttonView];
            [self.contentView addSubview:buttonView];
        }
    }
    else
    {
        imageView = [_imageViews objectAtIndex:_assets.count];
        
        if (_selectionControls)
            buttonView = [_buttonViews objectAtIndex:_assets.count];
    }
    
    if ([data isKindOfClass:[TGImagePickerAsset class]])
    {
        UIImage *image = argument;
        
        if ([image isKindOfClass:[UIImage class]])
            [imageView loadImage:image];
        else
            [imageView loadImage:nil];
    }
    else
    {
        static UIImage *placeholder = nil;
        if (placeholder == nil)
            placeholder = [UIImage imageNamed:@"FlatImagePlaceholder.png"];
        
        TGImageInfo *imageInfo = data;
        
        NSString *url = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        [imageView loadImage:url filter:_imageSize > 85 ? @"mediaGridImageLarge" : @"mediaGridImage" placeholder:placeholder];
    }
    
    imageView.hidden = false;
    buttonView.hidden = false;
    
    [buttonView setChecked:isSelected animated:false];
    
    [_assets addObject:data];
    [_assetsSelected addObject:[[NSNumber alloc] initWithBool:isSelected]];
    _searchIds.push_back(intArgument);
}

- (void)animateImageSelected:(id)itemId isSelected:(bool)isSelected
{
    [self _updateImageSelected:itemId isSelected:isSelected animated:true];
}

- (void)updateImageSelected:(id)itemId isSelected:(bool)isSelected
{
    [self _updateImageSelected:itemId isSelected:isSelected animated:false];
}

- (void)_updateImageSelected:(id)itemId isSelected:(bool)isSelected animated:(bool)animated
{
    if (itemId == nil)
        return;
    
    if ([itemId isKindOfClass:[NSString class]])
    {
        NSString *assetUrl = itemId;
        
        for (int i = 0; i < (int)_assets.count; i++)
        {
            TGImagePickerAsset *asset = [_assets objectAtIndex:i];
            if ([assetUrl isEqualToString:asset.assetUrl])
            {
                [_assetsSelected replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithBool:isSelected]];
                
                if (_selectionControls)
                {
                    TGImagePickerCellCheckButton *buttonView = [_buttonViews objectAtIndex:i];
                    [buttonView setChecked:isSelected animated:animated];
                }
                
                break;
            }
        }
    }
    else if ([itemId isKindOfClass:[NSNumber class]])
    {
        int searchId = [itemId intValue];
        
        for (int i = 0; i < _searchIds.size(); i++)
        {
            if (_searchIds[i] == searchId)
            {
                [_assetsSelected replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithBool:isSelected]];
                
                if (_selectionControls)
                {
                    TGImagePickerCellCheckButton *buttonView = [_buttonViews objectAtIndex:i];
                    [buttonView setChecked:isSelected animated:animated];
                }
                
                break;
            }
        }
    }
}

- (NSString *)assetUrlAtPoint:(CGPoint)point
{
    for (int i = 0; i < (int)_assets.count; i++)
    {
        TGRemoteImageView *imageView = [_imageViews objectAtIndex:i];
        if (CGRectContainsPoint(imageView.frame, point))
        {
            TGImagePickerAsset *asset = [_assets objectAtIndex:i];
            return asset.assetUrl;
        }
    }
    
    return nil;
}

- (CGRect)rectForAsset:(NSString *)assetUrl
{
    if (assetUrl == nil)
        return CGRectZero;
    
    for (int i = 0; i < (int)_assets.count; i++)
    {
        TGImagePickerAsset *asset = [_assets objectAtIndex:i];
        if ([assetUrl isEqualToString:asset.assetUrl])
        {
            return [[_imageViews objectAtIndex:i] frame];
        }
    }
    
    return CGRectZero;
}

- (CGRect)rectForSearchId:(int)searchId
{
    for (int i = 0; i < _searchIds.size(); i++)
    {
        if (_searchIds[i] == searchId)
        {
            return [[_imageViews objectAtIndex:i] frame];
        }
    }
    
    return CGRectZero;
}

- (UIView *)hideImage:(id)itemId hide:(bool)hide
{
    if (itemId == nil)
        return nil;
    
    if ([itemId isKindOfClass:[NSString class]])
    {
        NSString *assetUrl = itemId;

        for (int i = 0; i < (int)_assets.count; i++)
        {
            TGImagePickerAsset *asset = [_assets objectAtIndex:i];
            if ([assetUrl isEqualToString:asset.assetUrl])
            {
                [[_imageViews objectAtIndex:i] setHidden:hide];
                
                if (_selectionControls)
                    [[_buttonViews objectAtIndex:i] setHidden:hide];
                
                return [_imageViews objectAtIndex:i];
            }
        }
    }
    else
    {
        int searchId = [itemId intValue];
        
        for (int i = 0; i < _searchIds.size(); i++)
        {
            if (_searchIds[i] == searchId)
            {
                [[_imageViews objectAtIndex:i] setHidden:hide];
                
                if (_selectionControls)
                    [[_buttonViews objectAtIndex:i] setHidden:hide];
                
                return [_imageViews objectAtIndex:i];
            }
        }
    }
    
    return nil;
}

- (UIImage *)imageForSearchId:(int)searchId
{
    for (int i = 0; i < _searchIds.size(); i++)
    {
        if (_searchIds[i] == searchId)
        {
            return [_imageViews[i] currentImage];
        }
    }
    
    return nil;
}

- (NSString *)currentImageUrlForSearchId:(int)searchId
{
    for (int i = 0; i < _searchIds.size(); i++)
    {
        if (_searchIds[i] == searchId)
        {
            return [_imageViews[i] currentUrl];
        }
    }
    
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat availableWidth = self.frame.size.width;
    
    int imageCount = _assets.count;
    
    CGFloat currentX = 0.0f;
    CGFloat startX = 0.0f;
    
    if (TGIsPad())
    {
        availableWidth -= 18.0f;
        startX = 9.0f;
    }
    else
    {
        availableWidth -= _inset * 2.0f;
        startX = _inset;
    }
    
    currentX = startX;
    
    CGSize imageSize = CGSizeMake(_imageSize, _imageSize);
    CGFloat widthSpacing = TGRetinaFloor((availableWidth - _imagesInRow * _imageSize) / (_imagesInRow - 1.0f));

    int count = _imageViews.count;
    int limit = MAX(count, imageCount);
    for (int i = 0; i < limit; i++)
    {
        UIImageView *imageView = [_imageViews objectAtIndex:i];
        
        TGImagePickerCellCheckButton *buttonView = _selectionControls ? [_buttonViews objectAtIndex:i] : nil;
        
        CGFloat effectiveX = (imageCount == _imagesInRow && i == limit - 1) ? (startX + availableWidth - imageSize.width) : currentX;
        
        if (i < imageCount)
        {
            if (_selectionControls)
                buttonView.frame = CGRectMake(effectiveX + imageSize.width - 32, 1 + TGRetinaPixel, 33, 33);
            
            imageView.frame = CGRectMake(effectiveX, 2.0f, imageSize.width, imageSize.height);
            currentX += imageSize.width + widthSpacing;
        }
        else
        {
            imageView.image = nil;
        }
    }
}

#pragma mark -

- (void)checkButtonPressed:(id)button
{
    TGImagePickerCellCheckButton *buttonView = button;
    for (int i = 0; i < (int)_assets.count; i++)
    {
        if (buttonView == [_buttonViews objectAtIndex:i])
        {
            UIView *superview = self.superview;
            if (![superview isKindOfClass:[UITableView class]])
                superview = superview.superview;
            
            if ([superview isKindOfClass:[UITableView class]])
            {
                id asset = _assets[i];
                if ([asset isKindOfClass:[TGImagePickerAsset class]])
                {
                    id delegate = ((UITableView *)superview).delegate;
                    if ([delegate respondsToSelector:@selector(assetSelected:imageCell:)])
                        [delegate performSelector:@selector(assetSelected:imageCell:) withObject:[_assets objectAtIndex:i] withObject:self];
                }
                else if ([asset isKindOfClass:[TGImageInfo class]])
                {
                    id delegate = ((UITableView *)superview).delegate;
                    if ([delegate respondsToSelector:@selector(imagePickerCell:selectedSearchId:imageInfo:)])
                        [(id<TGImagePickerCellDelegate>)delegate imagePickerCell:self selectedSearchId:_searchIds[i] imageInfo:asset];
                }
            }
            
            break;
        }
    }
}

- (void)imageTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        UIView *view = [recognizer view];
        for (int i = 0; i < (int)_assets.count; i++)
        {
            if ([_imageViews objectAtIndex:i] == view)
            {
                UIView *superview = self.superview;
                if (![superview isKindOfClass:[UITableView class]])
                    superview = superview.superview;
                
                if ([superview isKindOfClass:[UITableView class]])
                {
                    id asset = _assets[i];
                    if ([asset isKindOfClass:[TGImagePickerAsset class]])
                    {
                        id delegate = ((UITableView *)superview).delegate;
                        if ([delegate respondsToSelector:@selector(assetTapped:imageCell:)])
                            [delegate performSelector:@selector(assetTapped:imageCell:) withObject:[_assets objectAtIndex:i] withObject:self];
                    }
                    else if ([asset isKindOfClass:[TGImageInfo class]])
                    {
                        UIImage *thumbnailImage = [[TGRemoteImageView sharedCache] cachedImage:[(TGRemoteImageView *)view currentUrl] availability:TGCacheBoth];
                        if (thumbnailImage == nil)
                            thumbnailImage = [(TGRemoteImageView *)view currentImage];
                        
                        if (thumbnailImage != nil)
                        {
                            id delegate = ((UITableView *)superview).delegate;
                            if ([delegate respondsToSelector:@selector(imagePickerCell:tappedSearchId:imageInfo:thumbnailImage:)])
                                [(id<TGImagePickerCellDelegate>)delegate imagePickerCell:self tappedSearchId:_searchIds[i] imageInfo:asset thumbnailImage:thumbnailImage];
                        }
                    }
                }
                
                break;
            }
        }
    }
}

@end
