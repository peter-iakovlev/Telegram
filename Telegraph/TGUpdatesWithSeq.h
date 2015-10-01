#import <Foundation/Foundation.h>

@interface TGUpdatesWithSeq : NSObject

@property (nonatomic, strong, readonly) NSArray *updates;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t seqStart;
@property (nonatomic, readonly) int32_t seqEnd;
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong, readonly) NSArray *chats;

- (instancetype)initWithUpdates:(NSArray *)updates date:(int32_t)date seqStart:(int32_t)seqStart seqEnd:(int32_t)seqEnd users:(NSArray *)users chats:(NSArray *)chats;

@end
