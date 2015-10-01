#import "TGBridgeContactMediaAttachment+TGContactMediaAttachment.h"

#import "TGPhoneUtils.h"

@implementation TGBridgeContactMediaAttachment (TGContactMediaAttachment)

+ (TGBridgeContactMediaAttachment *)attachmentWithTGContactMediaAttachment:(TGContactMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeContactMediaAttachment *bridgeAttachment = [[TGBridgeContactMediaAttachment alloc] init];
    bridgeAttachment.uid = attachment.uid;
    bridgeAttachment.firstName = attachment.firstName;
    bridgeAttachment.lastName = attachment.lastName;
    bridgeAttachment.phoneNumber = attachment.phoneNumber;
    bridgeAttachment.prettyPhoneNumber = [TGPhoneUtils formatPhone:attachment.phoneNumber forceInternational:false];
    
    return bridgeAttachment;
}

@end
