#import <Foundation/Foundation.h>

@interface TGBotContextResultsSwitchPm : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *startParam;

- (instancetype)initWithText:(NSString *)text startParam:(NSString *)startParam;

@end

@interface TGBotContextResults : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;

@property (nonatomic, readonly) bool isMedia;
@property (nonatomic, readonly) NSString *query;
@property (nonatomic, readonly) NSString *nextOffset;
@property (nonatomic, strong, readonly) NSArray *results;
@property (nonatomic, strong, readonly) TGBotContextResultsSwitchPm *switchPm;

- (instancetype)initWithUserId:(int32_t)userId peerId:(int64_t)peerId accessHash:(int64_t)accessHash isMedia:(bool)isMedia query:(NSString *)query nextOffset:(NSString *)nextOffset results:(NSArray *)results switchPm:(TGBotContextResultsSwitchPm *)switchPm;

@end
