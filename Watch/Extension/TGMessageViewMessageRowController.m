#import "TGMessageViewMessageRowController.h"

#import "TGDateUtils.h"
#import "TGStringUtils.h"
#import "TGLocationUtils.h"

#import "WKInterfaceGroup+Signals.h"
#import "TGMessageViewModel.h"

#import "TGBridgeMediaSignals.h"

#import "TGBridgeUser.h"
#import "TGBridgeMessage.h"
#import "TGBridgeUserCache.h"

#import "TGBridgeContext.h"

NSString *const TGMessageViewMessageRowIdentifier = @"TGMessageViewMessageRow";

@interface TGMessageViewMessageRowController ()
{
    NSString *_currentAvatarPhoto;
    int64_t _currentDocumentId;
    int64_t _currentPhotoId;
    int64_t _currentReplyPhotoId;
}
@end

@implementation TGMessageViewMessageRowController

- (IBAction)forwardButtonPressedAction
{
    if (self.forwardPressed != nil)
        self.forwardPressed();
}

- (IBAction)playButtonPressedAction
{
    if (self.playPressed != nil)
        self.playPressed();
}

- (IBAction)contactButtonPressedAction
{
    if (self.contactPressed != nil)
        self.contactPressed();
}

- (void)updateWithMessage:(TGBridgeMessage *)message context:(TGBridgeContext *)context
{
    bool mediaGroupHidden = true;
    bool mapGroupHidden = true;
    bool fileGroupHidden = true;
    bool stickerGroupHidden = true;
    bool contactButtonHidden = true;
    
    TGBridgeForwardedMessageMediaAttachment *forwardAttachment = nil;
    TGBridgeReplyMessageMediaAttachment *replyAttachment = nil;
    NSString *messageText = nil;
    
    for (TGBridgeMediaAttachment *attachment in message.media)
    {
        if ([attachment isKindOfClass:[TGBridgeForwardedMessageMediaAttachment class]])
        {
            forwardAttachment = (TGBridgeForwardedMessageMediaAttachment *)attachment;
        }
        else if ([attachment isKindOfClass:[TGBridgeReplyMessageMediaAttachment class]])
        {
            replyAttachment = (TGBridgeReplyMessageMediaAttachment *)attachment;
        }
        else if ([attachment isKindOfClass:[TGBridgeImageMediaAttachment class]])
        {
            mediaGroupHidden = false;
            
            TGBridgeImageMediaAttachment *imageAttachment = (TGBridgeImageMediaAttachment *)attachment;
            
            if (imageAttachment.caption.length > 0)
                messageText = imageAttachment.caption;
            
            CGSize imageSize = CGSizeZero;
            
            [TGMessageViewModel updateMediaGroup:self.mediaGroup activityIndicator:self.activityIndicator mediaAttachment:imageAttachment currentPhoto:&_currentPhotoId standalone:true margin:0 imageSize:&imageSize isVisible:self.isVisible completion:nil];
            
            self.mediaGroup.width = imageSize.width;
            self.mediaGroup.height = imageSize.height;
            
            self.playButton.hidden = true;
            self.durationGroup.hidden = true;
        }
        else if ([attachment isKindOfClass:[TGBridgeVideoMediaAttachment class]])
        {
            mediaGroupHidden = false;

            TGBridgeVideoMediaAttachment *videoAttachment = (TGBridgeVideoMediaAttachment *)attachment;
            
            if (videoAttachment.caption.length > 0)
                messageText = videoAttachment.caption;
            
            CGSize imageSize = CGSizeZero;
            
            [TGMessageViewModel updateMediaGroup:self.mediaGroup activityIndicator:self.activityIndicator mediaAttachment:videoAttachment currentPhoto:NULL standalone:true margin:0 imageSize:&imageSize isVisible:self.isVisible completion:nil];
            
            self.mediaGroup.width = imageSize.width;
            self.mediaGroup.height = imageSize.height;
            
            self.playButton.hidden = false;
            self.durationGroup.hidden = false;
            
            NSInteger durationMinutes = floor(videoAttachment.duration / 60.0);
            NSInteger durationSeconds = videoAttachment.duration % 60;
            self.durationLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)durationMinutes, (long)durationSeconds];
        }
        else if ([attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
        {
            TGBridgeDocumentMediaAttachment *documentAttachment = (TGBridgeDocumentMediaAttachment *)attachment;
         
            if (documentAttachment.isSticker)
            {
                stickerGroupHidden = false;
                
                [TGStickerViewModel updateWithMessage:message isGroup:false context:context currentDocumentId:&_currentDocumentId authorLabel:nil imageGroup:self.stickerGroup isVisible:self.isVisible completion:nil];
            }
            else
            {
                fileGroupHidden = false;
                
                NSString *extension = [[documentAttachment.fileName pathExtension] lowercaseString];
                if (extension.length == 0)
                    extension = @"file";
                                
                self.extensionLabel.text = extension;
                self.titleLabel.text = documentAttachment.fileName;
                self.subtitleLabel.text = [TGStringUtils stringForFileSize:documentAttachment.fileSize precision:2];
                
                self.fileIconGroup.hidden = false;
                self.audioButton.hidden = true;
                self.venueIcon.hidden = true;
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
        {
            fileGroupHidden = false;
            
            TGBridgeAudioMediaAttachment *audioAttachment = (TGBridgeAudioMediaAttachment *)attachment;
            
            self.titleLabel.text = TGLocalized(@"Message.Audio");
            
            NSInteger durationMinutes = floor(audioAttachment.duration / 60.0);
            NSInteger durationSeconds = audioAttachment.duration % 60;
            self.subtitleLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)durationMinutes, (long)durationSeconds];
            
            self.audioButton.hidden = false;
            self.fileIconGroup.hidden = true;
            self.venueIcon.hidden = true;
        }
        else if ([attachment isKindOfClass:[TGBridgeLocationMediaAttachment class]])
        {
            mapGroupHidden = false;
            
            TGBridgeLocationMediaAttachment *locationAttachment = (TGBridgeLocationMediaAttachment *)attachment;
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([TGLocationUtils adjustGMapLatitude:locationAttachment.latitude withPixelOffset:-10 zoom:15], locationAttachment.longitude);
            self.map.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.003, 0.003));
            self.map.centerPinCoordinate = CLLocationCoordinate2DMake(locationAttachment.latitude, locationAttachment.longitude);
            
            if (locationAttachment.venue != nil)
            {
                fileGroupHidden = false;
                
                self.titleLabel.text = locationAttachment.venue.title;
                self.subtitleLabel.text = locationAttachment.venue.address;
            }
            
            self.audioButton.hidden = true;
            self.fileIconGroup.hidden = true;
            self.venueIcon.hidden = false;
        }
        else if ([attachment isKindOfClass:[TGBridgeContactMediaAttachment class]])
        {
            contactButtonHidden = false;
            
            TGBridgeContactMediaAttachment *contactAttachment = (TGBridgeContactMediaAttachment *)attachment;
            
            TGBridgeUser *user = [[TGBridgeUserCache instance] userWithId:contactAttachment.uid];
            
            self.avatarGroup.hidden = false;
            
            if (user != nil)
            {
                self.contactButton.enabled = true;
                
                if (user.photoSmall.length > 0)
                {
                    self.avatarInitialsLabel.hidden = true;
                    self.avatarGroup.backgroundColor = [UIColor hexColor:0x222223];
                    if (![_currentAvatarPhoto isEqualToString:user.photoSmall])
                    {
                        _currentAvatarPhoto = user.photoSmall;
                        
                        __weak TGMessageViewMessageRowController *weakSelf = self;
                        [self.avatarGroup setBackgroundImageSignal:[[TGBridgeMediaSignals avatarWithUrl:_currentAvatarPhoto type:TGBridgeMediaAvatarTypeSmall] onNext:^(id next)
                        {
                            __strong TGMessageViewMessageRowController *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                strongSelf->_currentAvatarPhoto = nil;
                        }] isVisible:self.isVisible];
                    }
                }
                else
                {
                    self.avatarInitialsLabel.hidden = false;
                    self.avatarGroup.backgroundColor = [TGColor colorForUserId:user.identifier myUserId:context.userId];
                    self.avatarInitialsLabel.text = [TGStringUtils initialsForFirstName:user.firstName lastName:user.lastName single:true];
                    
                    [self.avatarGroup setBackgroundImageSignal:nil isVisible:self.isVisible];
                    _currentAvatarPhoto = nil;
                }
            }
            else
            {
                self.contactButton.enabled = false;

                self.avatarInitialsLabel.hidden = false;                
                self.avatarGroup.backgroundColor = [UIColor grayColor];
                self.avatarInitialsLabel.text = [TGStringUtils initialsForFirstName:contactAttachment.firstName lastName:contactAttachment.lastName single:true];
            }
            
            self.nameLabel.text = [contactAttachment displayName];
            self.phoneLabel.text = contactAttachment.prettyPhoneNumber;
        }
    }
    
    if (messageText == nil)
        messageText = message.text;
    
    [TGMessageViewModel updateForwardHeaderGroup:self.forwardHeaderButton titleLabel:self.forwardTitleLabel fromLabel:self.forwardFromLabel forwardAttachment:forwardAttachment textColor:[UIColor whiteColor]];
    
    [TGMessageViewModel updateReplyHeaderGroup:self.replyHeaderGroup authorLabel:self.replyAuthorNameLabel imageGroup:self.replyHeaderImageGroup textLabel:self.replyMessageTextLabel titleColor:[UIColor whiteColor] subtitleColor:[UIColor hexColor:0x7e7e81] replyAttachment:replyAttachment currentReplyPhoto:&_currentReplyPhotoId isVisible:self.isVisible completion:nil];
    
    self.mediaGroup.hidden = mediaGroupHidden;
    self.mapGroup.hidden = mapGroupHidden;
    self.fileGroup.hidden = fileGroupHidden;
    self.contactButton.hidden = contactButtonHidden;
    self.stickerGroup.hidden = stickerGroupHidden;
    
    self.messageTextLabel.hidden = (messageText.length == 0);
    if (!self.messageTextLabel.hidden)
        self.messageTextLabel.text = messageText;
}

- (void)notifyVisiblityChange
{
    [self.replyHeaderImageGroup updateIfNeeded];
    [self.mediaGroup updateIfNeeded];
    [self.avatarGroup updateIfNeeded];
    [self.stickerGroup updateIfNeeded];
}

+ (NSString *)identifier
{
    return TGMessageViewMessageRowIdentifier;
}

@end