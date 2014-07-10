#import "TGPhotoMessageViewModel.h"

#import "TGModernViewContext.h"

#import "TGModernRemoteImageView.h"
#import "TGMessageImageViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernColorViewModel.h"
#import "TGInstantPreviewTouchAreaModel.h"
#import "TGModernButtonViewModel.h"

#import "TGMessage.h"

#import "TGStringUtils.h"

@interface TGPhotoMessageViewModel ()
{
    TGImageMediaAttachment *_imageMedia;
    
    int _messageLifetime;
    
    TGModernImageViewModel *_overlayIconModel;
    TGModernImageViewModel *_overlayIconMaskLeftModel;
    TGModernImageViewModel *_overlayIconMaskRightModel;
    TGModernColorViewModel *_overlayIconMaskTopModel;
    TGModernColorViewModel *_overlayIconMaskBottomModel;
    
    TGInstantPreviewTouchAreaModel *_touchAreaModel;
}

@end

@implementation TGPhotoMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageMedia:(TGImageMediaAttachment *)imageMedia author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *previewImageInfo = imageMedia.imageInfo;
    
    CGSize largestSize = CGSizeZero;
    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
    NSString *legacyThumbnailCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    int64_t localImageId = 0;
    if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
    {
        localImageId = murMurHash32(legacyCacheUrl);
    }
    
    if (legacyCacheUrl != nil && (imageMedia.imageId != 0 || localImageId != 0))
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
        if (imageMedia.imageId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", imageMedia.imageId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", localImageId];
        
        CGSize thumbnailSize = CGSizeZero;
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        NSString *legacyFilePath = nil;
        if ([legacyCacheUrl hasPrefix:@"file://"])
            legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
        else
            legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
        
        if (legacyFilePath != nil)
            [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
        
        if (legacyThumbnailCacheUrl != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo author:author context:context];
    if (self != nil)
    {
        _imageMedia = imageMedia;
        
        _messageLifetime = message.messageLifetime;
        
        if (_messageLifetime != 0)
        {
            static const CGFloat dimAlpha = 0.2f;
            
            static UIImage *overlayIconImage = nil;
            static UIImage *overlayIconMaskLeftImage = nil;
            static UIImage *overlayIconMaskRightImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                overlayIconImage = [UIImage imageNamed:@"ModernMessageSecretPhotoOverlayIcon.png"];
                
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(14.0f, 28.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, dimAlpha).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 28.0f, 28.0f));
                    
                    overlayIconMaskLeftImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:27 topCapHeight:14];
                    UIGraphicsEndImageContext();
                }
                
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(14.0f, 28.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, dimAlpha).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(-14.0f, 0.0f, 28.0f, 28.0f));
                    
                    overlayIconMaskRightImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:1 topCapHeight:14];
                    UIGraphicsEndImageContext();
                }
            });
            _overlayIconModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconImage];
            _overlayIconModel.skipDrawInContext = true;
            _overlayIconModel.viewUserInteractionDisabled = true;
            [_overlayIconModel sizeToFit];
            [self insertSubmodel:_overlayIconModel aboveSubmodel:self.imageModel];
            
            _overlayIconMaskLeftModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconMaskLeftImage];
            _overlayIconMaskLeftModel.skipDrawInContext = true;
            _overlayIconMaskLeftModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskLeftModel aboveSubmodel:self.imageModel];
            
            _overlayIconMaskRightModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconMaskRightImage];
            _overlayIconMaskRightModel.skipDrawInContext = true;
            _overlayIconMaskRightModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskRightModel aboveSubmodel:self.imageModel];
            
            UIColor *dimColor = UIColorRGBA(0x000000, dimAlpha);
            _overlayIconMaskTopModel = [[TGModernColorViewModel alloc] initWithColor:dimColor];
            _overlayIconMaskTopModel.skipDrawInContext = true;
            _overlayIconMaskTopModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskTopModel aboveSubmodel:self.imageModel];
            _overlayIconMaskBottomModel = [[TGModernColorViewModel alloc] initWithColor:dimColor];
            _overlayIconMaskBottomModel.skipDrawInContext = true;
            _overlayIconMaskBottomModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskBottomModel aboveSubmodel:self.imageModel];
            
            if (message.outgoing)
            {
            }
            else
            {
                _touchAreaModel = [[TGInstantPreviewTouchAreaModel alloc] init];
                _touchAreaModel.notificationHandle = context.companionHandle;
                _touchAreaModel.touchesBeganAction = @"openMediaRequested";
                _touchAreaModel.touchesBeganOptions = @{@"mid": @(message.mid)};
                _touchAreaModel.touchesCompletedAction = @"closeMediaRequested";
                _touchAreaModel.touchesCompletedOptions = @{@"mid": @(message.mid)};
                [self addSubmodel:_touchAreaModel];
            }
        }
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    TGImageMediaAttachment *imageMedia = nil;
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        {
            imageMedia = attachment;
            break;
        }
    }
    
    if (imageMedia != nil)
    {
        TGImageInfo *previewImageInfo = imageMedia.imageInfo;
        
        CGSize largestSize = CGSizeZero;
        NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
        NSString *legacyThumbnailCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        int64_t localImageId = 0;
        if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
        {
            localImageId = murMurHash32(legacyCacheUrl);
        }
        
        if (legacyCacheUrl != nil && (imageMedia.imageId != 0 || localImageId != 0))
        {
            previewImageInfo = [[TGImageInfo alloc] init];
            
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
            if (imageMedia.imageId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", imageMedia.imageId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", localImageId];
            
            CGSize thumbnailSize = CGSizeZero;
            CGSize renderSize = CGSizeZero;
            [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            NSString *legacyFilePath = nil;
            if ([legacyCacheUrl hasPrefix:@"file://"])
                legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
            else
                legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
            
            if (legacyFilePath != nil)
                [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
            
            if (legacyThumbnailCacheUrl != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        [self updateImageInfo:previewImageInfo];
    }
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
    
    _overlayIconModel.hidden = [_context isSecretMessageViewed:_mid];
    _overlayIconMaskLeftModel.hidden = [_context isSecretMessageScreenshotted:_mid];
    _overlayIconMaskRightModel.hidden = _overlayIconMaskLeftModel.hidden;
    _overlayIconMaskTopModel.hidden = _overlayIconMaskLeftModel.hidden;
    _overlayIconMaskBottomModel.hidden = _overlayIconMaskLeftModel.hidden;
}

- (NSString *)filterForMessage:(TGMessage *)message imageSize:(CGSize)imageSize sourceSize:(CGSize)sourceSize
{
    if (message.messageLifetime == 0)
        return [super filterForMessage:message imageSize:imageSize sourceSize:sourceSize];
    
    return [[NSString alloc] initWithFormat:@"%@:%dx%d,%dx%d", @"secretAttachmentImageOutgoing", (int)imageSize.width, (int)imageSize.height, (int)sourceSize.width, (int)sourceSize.height];
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)message
{
    if (message.messageLifetime == 0)
        return [super minimumImageSizeForMessage:message];
    
    return CGSizeMake(120, 120);
}

- (bool)instantPreviewGesture
{
    return _messageLifetime != 0;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_overlayIconModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconModel boundView].frame = CGRectOffset([_overlayIconModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskLeftModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskLeftModel boundView].frame = CGRectOffset([_overlayIconMaskLeftModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskRightModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskRightModel boundView].frame = CGRectOffset([_overlayIconMaskRightModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskTopModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskTopModel boundView].frame = CGRectOffset([_overlayIconMaskTopModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskBottomModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskBottomModel boundView].frame = CGRectOffset([_overlayIconMaskBottomModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    if (_overlayIconModel != nil)
    {
        CGRect imageFrame = self.imageModel.frame;
        
        _touchAreaModel.frame = imageFrame;
        
        CGRect iconFrame = _overlayIconModel.frame;
        iconFrame = CGRectMake(imageFrame.origin.x + CGFloor((imageFrame.size.width - _overlayIconModel.frame.size.width) / 2.0f), imageFrame.origin.y + CGFloor((imageFrame.size.height - _overlayIconModel.frame.size.height) / 2.0f), iconFrame.size.width, iconFrame.size.height);
        _overlayIconModel.frame = iconFrame;
        
        _overlayIconMaskLeftModel.frame = CGRectMake(imageFrame.origin.x + 2.0f, imageFrame.origin.y + 2.0f, iconFrame.origin.x - imageFrame.origin.x - 2.0f, imageFrame.size.height - 4.0f);
        _overlayIconMaskRightModel.frame = CGRectMake(iconFrame.origin.x + iconFrame.size.width, imageFrame.origin.y + 2.0f, imageFrame.origin.x + imageFrame.size.width - 2.0f - iconFrame.origin.x - iconFrame.size.width, imageFrame.size.height - 4.0f);
        
        _overlayIconMaskTopModel.frame = CGRectMake(iconFrame.origin.x, imageFrame.origin.y + 2.0f, iconFrame.size.width, iconFrame.origin.y - imageFrame.origin.y - 2.0f);
        _overlayIconMaskBottomModel.frame = CGRectMake(iconFrame.origin.x, iconFrame.origin.y + iconFrame.size.height, iconFrame.size.width, imageFrame.origin.y + imageFrame.size.height - 2.0f - iconFrame.origin.y - iconFrame.size.height);
    }
}

@end
