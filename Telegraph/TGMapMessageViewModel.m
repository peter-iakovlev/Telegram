#import "TGMapMessageViewModel.h"

#import "TGUser.h"
#import "TGMessage.h"

#import "TGModernViewContext.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGMessageImageViewModel.h"

@interface TGMapMessageViewModel ()

@end

@implementation TGMapMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude message:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGSize size = CGSizeMake(210.0f, 144.0f);
    
    [imageInfo addImageWithSize:CGSizeMake(190, 124) url:[[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d", latitude, longitude, (int)size.width, (int)size.height]];
    
    self = [super initWithMessage:message imageInfo:imageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor viaUser:viaUser];
    if (self != nil)
    {
        self.imageModel.frame = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    return CGRectContainsPoint(self.imageModel.frame, point);
}

@end
