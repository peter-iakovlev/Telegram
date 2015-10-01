#import "TGBridgeLocationMediaAttachment+TGLocationMediaAttachment.h"

@implementation TGBridgeLocationMediaAttachment (TGLocationMediaAttachment)

+ (TGBridgeLocationMediaAttachment *)attachmentWithTGLocationMediaAttachment:(TGLocationMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeLocationMediaAttachment *bridgeAttachment = [[TGBridgeLocationMediaAttachment alloc] init];
    bridgeAttachment.latitude = attachment.latitude;
    bridgeAttachment.longitude = attachment.longitude;
    
    if (attachment.venue != nil)
    {
        TGBridgeVenueAttachment *bridgeVenue = [[TGBridgeVenueAttachment alloc] init];
        bridgeVenue.title = attachment.venue.title;
        bridgeVenue.address = attachment.venue.address;
        bridgeVenue.provider = attachment.venue.provider;
        bridgeVenue.venueId = attachment.venue.venueId;
        
        bridgeAttachment.venue = bridgeVenue;
    }
    
    return bridgeAttachment;
}

+ (TGLocationMediaAttachment *)tgLocationMediaAttachmentWithBridgeLocationMediaAttachment:(TGBridgeLocationMediaAttachment *)bridgeAttachment
{
    if (bridgeAttachment == nil)
        return nil;
    
    TGLocationMediaAttachment *attachment = [[TGLocationMediaAttachment alloc] init];
    attachment.latitude = bridgeAttachment.latitude;
    attachment.longitude = bridgeAttachment.longitude;
    
    if (bridgeAttachment.venue != nil)
    {
        TGVenueAttachment *venue = [[TGVenueAttachment alloc] initWithTitle:bridgeAttachment.venue.title address:bridgeAttachment.venue.address provider:bridgeAttachment.venue.provider venueId:bridgeAttachment.venue.venueId];
        
        attachment.venue = venue;
    }
    
    return attachment;
}

@end
