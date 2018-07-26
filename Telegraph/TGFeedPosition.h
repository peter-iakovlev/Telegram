#import <Foundation/Foundation.h>
#import <LegacyComponents/PSKeyValueCoder.h>

@class TLFeedPosition;

@interface TGFeedPosition : NSObject <NSCoding, PSCoding>

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t mid;
@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithDate:(int32_t)date mid:(int32_t)mid peerId:(int64_t)peerId;
- (instancetype)initWithTelegraphDesc:(TLFeedPosition *)desc;

@end
