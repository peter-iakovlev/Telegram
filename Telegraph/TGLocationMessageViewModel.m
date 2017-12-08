#import "TGLocationMessageViewModel.h"

#import <LegacyComponents/LegacyComponents.h>
#import "TGTelegramNetworking.h"

#import "TGModernViewContext.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernDataImageViewModel.h"
#import "TGModernFlatteningViewModel.h"

#import <LegacyComponents/TGLocationSignals.h>

@interface TGLocationMessageViewModel ()
{
    TGModernTextViewModel *_venueAddressModel;
    TGVenueAttachment *_venue;
    
    TGModernImageViewModel *_pinShadowModel;
    TGModernImageViewModel *_pinBackgroundModel;
    TGModernDataImageViewModel *_pinIconModel;
}
@end

@implementation TGLocationMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue message:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGSize size;
    CGSize renderSize;
    [TGImageMessageViewModel calculateImageSizesForImageSize:CGSizeMake(1280, 720) thumbnailSize:&size renderSize:&renderSize squareAspect:false];
    
    NSString *title = nil;
    NSString *subtitle = nil;
    
    if (venue != nil)
    {
        title = venue.title;
        subtitle = venue.address;
    }
    
    [imageInfo addImageWithSize:size url:[[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&noPin=1&offset=-18", latitude, longitude, (int)size.width, (int)size.height]];
    
    _ignoreMessageLifetime = true;
    _ignoreEditing = true;
    _captionFont = TGCoreTextMediumFontOfSize(16.0f);
    self = [super initWithMessage:message imageInfo:imageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor viaUser:viaUser caption:title textCheckingResults:nil webPage:nil];
    
    if (self != nil)
    {
        _venue = venue;
        
        self.imageModel.ignoresInvertColors = false;
        self.imageModel.frame = CGRectMake(0, 0, size.width, size.height);
        _textModel.maxNumberOfLines = 1;
        
        static UIColor *incomingAddressColor = nil;
        static UIColor *outgoingAddressColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingAddressColor = UIColorRGB(0x999999);
            outgoingAddressColor = UIColorRGB(0x2da32e);
        });
        
        if (subtitle.length > 0)
        {
            _venueAddressModel = [[TGModernTextViewModel alloc] initWithText:subtitle font:TGCoreTextSystemFontOfSize(14.0f)];
            _venueAddressModel.maxNumberOfLines = 1;
            _venueAddressModel.textColor = _incomingAppearance ? incomingAddressColor : outgoingAddressColor;
            [_contentModel addSubmodel:_venueAddressModel];
        }
        
        _pinShadowModel = [[TGModernImageViewModel alloc] initWithImage:TGComponentsImageNamed(@"LocationMessagePinShadow")];
        [_pinShadowModel setViewUserInteractionDisabled:true];
        [self addSubmodel:_pinShadowModel];
        
        UIColor *pinColor = UIColorRGB(0x008df2);
        _pinBackgroundModel = [[TGModernImageViewModel alloc] initWithImage:TGTintedImage(TGComponentsImageNamed(@"LocationMessagePinBackground"), pinColor)];
        [_pinBackgroundModel setViewUserInteractionDisabled:true];
        [self addSubmodel:_pinBackgroundModel];
        
        _pinIconModel = [[TGModernDataImageViewModel alloc] init];
        _pinIconModel.contentMode = UIViewContentModeCenter;
        [_pinIconModel setViewUserInteractionDisabled:true];
        if (venue == nil || venue.type.length == 0 || ![venue.provider isEqualToString:@"foursquare"])
        {
            [_pinIconModel setUri:@"embedded-image://" options:@{TGImageViewOptionEmbeddedImage: TGComponentsImageNamed(@"LocationMessagePinIcon")}];
        }
        else
        {
            [_pinIconModel setUri:[NSString stringWithFormat:@"location-venue-icon://type=%@&width=%d&height=%d&color=%d", venue.type, 48, 48, 0xffffff] options:@{}];
        }
        [self addSubmodel:_pinIconModel];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    TGLocationMediaAttachment *location = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGLocationMediaAttachmentType)
        {
            location = (TGLocationMediaAttachment *)attachment;
            break;
        }
    }
    
    _nextCaption = location.venue.title;
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    CGRect addressFrame = _venueAddressModel.frame;
    addressFrame.origin = CGPointMake(_textModel.frame.origin.x, _textModel.frame.origin.y + _textModel.frame.size.height);
    _venueAddressModel.frame = addressFrame;
    
    _pinShadowModel.frame = CGRectMake(self.imageModel.frame.origin.x + self.imageModel.frame.size.width / 2.0f - 31.0f, self.imageModel.frame.origin.y + self.imageModel.frame.size.height / 2.0f - 34.0f, 62.0f, 65.0f);
    _pinBackgroundModel.frame = CGRectMake(self.imageModel.frame.origin.x + self.imageModel.frame.size.width / 2.0f - 31.0f, self.imageModel.frame.origin.y + self.imageModel.frame.size.height / 2.0f - 35.0f, 62.0f, 65.0f);
    
    _pinIconModel.frame = CGRectMake(self.imageModel.frame.origin.x + self.imageModel.frame.size.width / 2.0f - 24.0f, self.imageModel.frame.origin.y + self.imageModel.frame.size.height / 2.0f - 32.0f, 48.0f, 48.0f);
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth
{
    if (_venueAddressModel != nil)
        infoWidth = 0.0f;
    
    CGSize size = [super contentSizeForContainerSize:containerSize needsContentsUpdate:needsContentsUpdate infoWidth:infoWidth];
    if (_venueAddressModel != nil)
    {
        int layoutFlags = 0;
        CGSize addressContainerSize = CGSizeMake(containerSize.width - 50.0f, containerSize.height);
        bool updateContents = [_venueAddressModel layoutNeedsUpdatingForContainerSize:addressContainerSize additionalTrailingWidth:0.0f layoutFlags:layoutFlags];
        _venueAddressModel.layoutFlags = layoutFlags;
        _venueAddressModel.additionalTrailingWidth = infoWidth;
        if (updateContents)
            [_venueAddressModel layoutForContainerSize:addressContainerSize];
        
        if (needsContentsUpdate != NULL && updateContents)
            *needsContentsUpdate = updateContents;

        size.height += 21.0f;
    }
    return size;
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    return CGRectContainsPoint(self.imageModel.frame, point);
}

@end
