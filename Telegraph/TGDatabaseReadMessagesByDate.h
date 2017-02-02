#import <Foundation/Foundation.h>

@interface TGDatabaseReadMessagesByDate : NSObject

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t referenceDateForTimers;

- (instancetype)initWithDate:(int32_t)date referenceDateForTimers:(int32_t)referenceDateForTimers;

@end
