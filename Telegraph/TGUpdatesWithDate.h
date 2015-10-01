#import <Foundation/Foundation.h>

@interface TGUpdatesWithDate : NSObject

@property (nonatomic, strong, readonly) NSArray *updates;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong, readonly) NSArray *chats;

- (instancetype)initWithUpdates:(NSArray *)updates date:(int32_t)date users:(NSArray *)users chats:(NSArray *)chats;

@end
