#import "TGMapMessageViewModel.h"

#import "TGUser.h"
#import "TGMessage.h"

#import "TGModernViewContext.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGMessageImageViewModel.h"

@interface TGMapMessageViewModel ()

@end

@implementation TGMapMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude message:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGSize size = CGSizeMake(160.0f, 110.0f);
    
    [imageInfo addImageWithSize:CGSizeMake(140, 120) url:[[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d", latitude, longitude, (int)size.width, (int)size.height]];
    
    self = [super initWithMessage:message imageInfo:imageInfo authorPeer:authorPeer context:context forwardPeer:nil forwardMessageId:0 replyHeader:replyHeader replyAuthor:replyAuthor];
    if (self != nil)
    {
        self.imageModel.frame = CGRectMake(0, 0, 160, 110);
    }
    return self;
}

@end
