#import "TGModernGalleryVideoItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGUser;

@interface TGGenericPeerMediaGalleryVideoItem : TGModernGalleryVideoItem <TGGenericPeerGalleryItem>

@property (nonatomic, strong) TGUser *author;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;

@end
