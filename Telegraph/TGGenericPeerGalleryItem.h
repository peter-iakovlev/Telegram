#import <Foundation/Foundation.h>

@class TGUser;
@class TGGenericPeerGalleryGroupItem;

@protocol TGGenericPeerGalleryItem <NSObject>

@optional

- (int64_t)groupedId;
@property (nonatomic, strong) NSArray<TGGenericPeerGalleryGroupItem *> *groupItems;

@required

- (id)media;
- (id)authorPeer;
- (NSString *)author;
- (NSTimeInterval)date;
- (int32_t)messageId;
- (int64_t)peerId;

@end
