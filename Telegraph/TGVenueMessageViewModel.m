#import "TGVenueMessageViewModel.h"

#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

#import "TGModernFlatteningViewModel.h"
#import "TGTextMessageBackgroundViewModel.h"

#import "TGReplyHeaderModel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGMessageImageView.h"

#import "TGReusableLabel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGLocationMediaAttachment.h"

#import "TGDoubleTapGestureRecognizer.h"
#import "TGUser.h"

@interface TGVenueMessageViewModel () <TGMessageImageViewDelegate>
{
    TGMessageImageViewModel *_imageModel;
    TGModernTextViewModel *_venueNameModel;
    TGModernTextViewModel *_venueAddressModel;
}
@end

@implementation TGVenueMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue message:(TGMessage *)message authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer viaUser:viaUser context:context];
    if (self != nil)
    {
        static UIColor *incomingAddressColor = nil;
        static UIColor *outgoingAddressColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingAddressColor = UIColorRGB(0x999999);
            outgoingAddressColor = UIColorRGB(0x2da32e);
        });
        
        _venueNameModel = [[TGModernTextViewModel alloc] initWithText:venue.title font:TGCoreTextMediumFontOfSize(14.0f)];
        _venueNameModel.maxNumberOfLines = 2;
        _venueNameModel.textColor = [UIColor blackColor];
        [_contentModel addSubmodel:_venueNameModel];
        
        _venueAddressModel = [[TGModernTextViewModel alloc] initWithText:venue.address font:TGCoreTextSystemFontOfSize(14.0f)];
        _venueAddressModel.maxNumberOfLines = 2;
        _venueAddressModel.textColor = _incomingAppearance ? incomingAddressColor : outgoingAddressColor;
        [_contentModel addSubmodel:_venueAddressModel];
        
        CGSize mapImageSize = CGSizeMake(75.0f, 75.0f);
        NSString *mapUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1", latitude, longitude, (int)mapImageSize.width, (int)mapImageSize.height];
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:mapUri];
        _imageModel.skipDrawInContext = true;
        _imageModel.timestampHidden = true;
        _imageModel.frame = CGRectMake(0.0f, 0.0f, 75.0f, 75.0f);
        _imageModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_imageModel];
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    CGFloat verticalOffset = 0.0f;
    verticalOffset += (_viaUser != nil ? 2.0f : 0.0f);
    _venueNameModel.frame = CGRectMake(_imageModel.frame.size.width + 6.0f, headerHeight + 4.0f + verticalOffset, _venueNameModel.frame.size.width, _venueNameModel.frame.size.height);
    
    CGRect addressFrame = _venueAddressModel.frame;
    addressFrame.origin = CGPointMake(_venueNameModel.frame.origin.x, _venueNameModel.frame.origin.y + _venueNameModel.frame.size.height + 2.0f);
    _venueAddressModel.frame = addressFrame;
    
    _imageModel.frame = CGRectMake(_backgroundModel.frame.origin.x + 6.0f + (_incomingAppearance ? 5.0f : 0.0f), _backgroundModel.frame.origin.y + 6.0f + headerHeight + verticalOffset, _imageModel.frame.size.width, _imageModel.frame.size.height);
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)__unused infoWidth
{
    CGSize imageSize = _imageModel.frame.size;
    
    int layoutFlags = TGReusableLabelLayoutMultiline;
    
    CGSize nameContainerSize = CGSizeMake(MIN(200, containerSize.width - imageSize.width - 18), containerSize.height);
    bool updateNameContents = [_venueNameModel layoutNeedsUpdatingForContainerSize:nameContainerSize additionalTrailingWidth:0.0f layoutFlags:layoutFlags];
    _venueNameModel.layoutFlags = layoutFlags;
    if (updateNameContents)
        [_venueNameModel layoutForContainerSize:nameContainerSize];
    
    NSInteger addressNumberOfLines = [_venueNameModel measuredNumberOfLines] < 2 ? 2 : 1;
    _venueAddressModel.maxNumberOfLines = addressNumberOfLines;
    
    CGSize addressContainerSize = CGSizeMake(MAX(_venueNameModel.frame.size.width, containerSize.width - imageSize.width - 30.0f), containerSize.height);
    bool updateAddressContents = [_venueAddressModel layoutNeedsUpdatingForContainerSize:addressContainerSize additionalTrailingWidth:0.0f layoutFlags:layoutFlags];
    _venueAddressModel.layoutFlags = layoutFlags;
    if (updateAddressContents)
        [_venueAddressModel layoutForContainerSize:addressContainerSize];
    
    CGFloat nameWidth = _venueNameModel.frame.size.width;
    CGFloat venueWidth = _venueAddressModel.frame.size.width;
    
    *needsContentsUpdate = updateNameContents || updateAddressContents;
    
    return CGSizeMake(MAX(nameWidth, venueWidth) + imageSize.width + 14.0f, imageSize.height + 2.0f + (_viaUser != nil ? 2.0f : 0.0f));
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)__unused messageImageView withAction:(TGMessageImageViewActionType)__unused action
{
    [self activateMedia];
}

- (void)activateMedia
{
    [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 3;
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
                if (_viaUser != nil && [_forwardedHeaderModel linkAtPoint:CGPointMake(point.x - _forwardedHeaderModel.frame.origin.x, point.y - _forwardedHeaderModel.frame.origin.y) regionData:NULL]) {
                    [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
                } else {
                    if (TGPeerIdIsChannel(_forwardedPeerId)) {
                        [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                    } else {
                        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                    }
                }
            }
            else if (_viaUserModel != nil && CGRectContainsPoint(_viaUserModel.frame, point)) {
                [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
            else
                [self activateMedia];
        }
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    return CGRectContainsPoint(self.bounds, point);
}

@end
