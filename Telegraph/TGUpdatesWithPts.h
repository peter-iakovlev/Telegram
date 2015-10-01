#import <Foundation/Foundation.h>

@interface TGUpdatesWithPts : NSObject

@property (nonatomic, strong, readonly) NSArray *updates;
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong, readonly) NSArray *chats;

- (instancetype)initWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats;

@end
