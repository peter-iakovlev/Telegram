#import <Foundation/Foundation.h>

@class TGUser;

@protocol TGGenericPeerGalleryItem <NSObject>

@required

- (id)authorPeer;
- (NSTimeInterval)date;
- (int32_t)messageId;

@end
