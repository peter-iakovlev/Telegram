#import <Foundation/Foundation.h>

@class TGUser;

@protocol TGGenericPeerGalleryItem <NSObject>

@required

- (TGUser *)author;
- (NSTimeInterval)date;
- (int32_t)messageId;

@end
