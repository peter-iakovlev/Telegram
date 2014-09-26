#import "TGGenericPeerMediaGalleryVideoItemView.h"

#import "TGGenericPeerMediaGalleryVideoItem.h"

#import "TGDatabase.h"

@implementation TGGenericPeerMediaGalleryVideoItemView

- (void)_willPlay
{
    if ([self.item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        TGGenericPeerMediaGalleryVideoItem *item = (TGGenericPeerMediaGalleryVideoItem *)self.item;
        int messageId = item.messageId;
        [TGDatabaseInstance() updateLastUseDateForMediaType:1 mediaId:item.videoMedia.videoId messageId:messageId];
    }
}

@end
