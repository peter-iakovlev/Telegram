#import "TGPhotoGridCell.h"

#import "TGRemoteImageView.h"

#import "TGInterfaceAssets.h"

#import "TGVideoMediaAttachment.h"

#import "TGImageUtils.h"

@interface TGPhotoGridCell ()

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *imageShadows;

@end

@implementation TGPhotoGridCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _imageViews = [[NSMutableArray alloc] init];
        _imageShadows = [[NSMutableArray alloc] init];
        _imageUrls = [[NSMutableArray alloc] init];
        _imageTags = [[NSMutableArray alloc] init];
        _imageAttachments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)collectCachedPhotos:(NSMutableDictionary *)dict
{
    for (TGRemoteImageView *imageView in _imageViews)
    {
        [imageView tryFillCache:dict];
    }
}

- (CGRect)rectForImageWithTag:(id)tag
{
    for (int i = 0; i < (int)_imageTags.count; i++)
    {
        if ([[_imageTags objectAtIndex:i] isEqual:tag])
        {
            if (i < (int)_imageViews.count)
            {
                TGRemoteImageView *imageView = [_imageViews objectAtIndex:i];
                return imageView.frame;
            }
            break;
        }
    }
    
    return CGRectZero;
}

- (UIView *)viewForImageWithTag:(id)tag
{
    for (int i = 0; i < (int)_imageTags.count; i++)
    {
        if ([[_imageTags objectAtIndex:i] isEqual:tag])
        {
            if (i < (int)_imageViews.count)
            {
                TGRemoteImageView *imageView = [_imageViews objectAtIndex:i];
                return imageView;
            }
            break;
        }
    }
    
    return nil;
}

- (void)reloadImagesWithUrl:(NSString *)url
{
    for (TGRemoteImageView *imageView in _imageViews)
    {
        if ([imageView.currentUrl isEqualToString:url])
        {
            UIImage *image = imageView.currentImage;
            if (image == nil)
                image = [imageView currentPlaceholderImage];
            
            imageView.placeholderOverlay.hidden = image != nil;
            [imageView loadImage:url filter:imageView.currentFilter placeholder:image forceFade:image != nil];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat side = TGIsRetina() ? 78.5f : 78.0f;
    CGSize imageSize = CGSizeMake(side, side);
    int widthSpacing = 2;
    CGFloat currentX = 0.0f;
    
    UIImage *placeholder = [TGInterfaceAssets mediaGridImagePlaceholder];
    
    int urlCount = (int)_imageUrls.count;
    int count = (int)_imageViews.count;
    int limit = MAX(_numberOfImagePlaces, count);
    for (int i = 0; i < limit; i++)
    {
        TGRemoteImageView *imageView = nil;
        if (i >= count)
        {
            imageView = [[TGRemoteImageView alloc] initWithFrame:CGRectZero];
            imageView.contentHints = TGRemoteImageContentHintBlurRemote;
            imageView.fadeTransition = true;
            imageView.clipsToBounds = true;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentView addSubview:imageView];
            [_imageViews addObject:imageView];
            imageView.userInteractionEnabled = true;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)]];
            
            count++;
        }
        else
            imageView = [_imageViews objectAtIndex:i];
        
        imageView.frame = CGRectMake(urlCount == limit && i == limit - 1 ? self.frame.size.width - imageSize.width : currentX, 2, imageSize.width, imageSize.height);
        currentX += imageSize.width + widthSpacing;
        
        if (i >= urlCount)
        {
            [imageView loadImage:nil];
            imageView.hidden = true;
        }
        else
        {
            imageView.hidden = false;
            if (imageView.currentUrl == nil || ![imageView.currentUrl isEqualToString:[_imageUrls objectAtIndex:i]])
            {
                [imageView loadImage:[_imageUrls objectAtIndex:i] filter:@"mediaGridImage" placeholder:placeholder];
                
                UIView *mediaBar = [imageView viewWithTag:201];
                
                TGMediaAttachment *attachment = [_imageAttachments objectAtIndex:i];
                if (attachment.type == TGVideoMediaAttachmentType)
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                    if (mediaBar == nil)
                    {
                        static UIImage *videoIconImage = nil;
                        static UIFont *labelFont = nil;
                        static UIColor *barColor = nil;
                        if (videoIconImage == nil)
                        {
                            videoIconImage = [UIImage imageNamed:@"MessageInlineVideoIcon.png"];
                            labelFont = [UIFont boldSystemFontOfSize:10];
                            barColor = UIColorRGBA(0x000000, 0.6f);
                        }
                        
                        mediaBar = [[UIView alloc] initWithFrame:CGRectMake(0, side - 19, side, 19)];
                        mediaBar.userInteractionEnabled = false;
                        mediaBar.tag = 201;
                        mediaBar.backgroundColor = barColor;
                        
                        UIImageView *iconView = [[UIImageView alloc] initWithImage:videoIconImage];
                        iconView.frame = CGRectOffset(iconView.frame, 4, 5);
                        [mediaBar addSubview:iconView];
                        
                        UILabel *videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(side - 56 - 3, 0, 56, 19)];
                        videoLabel.tag = 202;
                        videoLabel.backgroundColor = [UIColor clearColor];
                        videoLabel.textColor = [UIColor whiteColor];
                        videoLabel.font = labelFont;
                        videoLabel.textAlignment = NSTextAlignmentRight;
                        [mediaBar addSubview:videoLabel];
                        
                        [imageView addSubview:mediaBar];
                    }
                    
                    mediaBar.hidden = false;
                    mediaBar.alpha = 1.0f;
                    UILabel *videoLabel = (UILabel *)[mediaBar viewWithTag:202];
                    
                    int minutes = videoAttachment.duration / 60;
                    int seconds = videoAttachment.duration % 60;
                    videoLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
                }
                else
                {
                    mediaBar.hidden = true;
                }
            }
        }
    }
}

- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        TGRemoteImageView *remoteImageView = (TGRemoteImageView *)recognizer.view;
        if (![remoteImageView isKindOfClass:[TGRemoteImageView class]])
            return;
        
        UIImage *currentImage = [remoteImageView currentImage];
        if (currentImage == nil)
            return;
        
        int imageIndex = (int)[_imageViews indexOfObject:recognizer.view];
        id tag = nil;
        if (imageIndex >= 0 && imageIndex < (int)_imageTags.count)
            tag = [_imageTags objectAtIndex:imageIndex];
        
        if (imageIndex >= 0 && imageIndex < (int)_imageUrls.count && tag != nil)
        {
            
            id<ASWatcher> watcher = _watcherHandle.delegate;
            if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
            {
                [watcher actionStageActionRequested:@"openImage" options:[[NSDictionary alloc] initWithObjectsAndKeys:currentImage, @"image", [NSValue valueWithCGRect:[remoteImageView convertRect:remoteImageView.bounds toView:self.window]], @"rectInWindowCoords", tag, @"tag", nil]];
            }
        }
    }
}

@end
