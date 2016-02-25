#import <Foundation/Foundation.h>

@interface TGBotContextResult : NSObject

@property (nonatomic, readonly) int64_t queryId;
@property (nonatomic, strong, readonly) NSString *resultId;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) id sendMessage;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type sendMessage:(id)sendMessage;

@end
