#import "TGModernGalleryImageItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGUser;

@interface TGGenericPeerMediaGalleryImageItem : TGModernGalleryImageItem <TGGenericPeerGalleryItem>

@property (nonatomic, strong) TGUser *author;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;

@end
