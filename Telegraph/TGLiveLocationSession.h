#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGLiveLocationSession : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) int32_t expires;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId expires:(int32_t)expires;

@end
