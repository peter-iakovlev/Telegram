#import <Foundation/Foundation.h>

@interface TGBotContextResults : NSObject

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) bool isMedia;
@property (nonatomic, readonly) NSString *query;
@property (nonatomic, readonly) NSString *nextOffset;
@property (nonatomic, strong, readonly) NSArray *results;

- (instancetype)initWithUserId:(int32_t)userId isMedia:(bool)isMedia query:(NSString *)query nextOffset:(NSString *)nextOffset results:(NSArray *)results;

@end
