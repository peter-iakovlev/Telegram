#import <Foundation/Foundation.h>

@interface TGAuthSession : NSObject

@property (nonatomic, readonly) int64_t sessionHash;
@property (nonatomic, readonly) int32_t flags;
@property (nonatomic, strong, readonly) NSString *deviceModel;
@property (nonatomic, strong, readonly) NSString *platform;
@property (nonatomic, strong, readonly) NSString *systemVersion;
@property (nonatomic, readonly) int32_t apiId;
@property (nonatomic, strong, readonly) NSString *appName;
@property (nonatomic, strong, readonly) NSString *appVersion;
@property (nonatomic, readonly) int32_t dateCreated;
@property (nonatomic, readonly) int32_t dateActive;
@property (nonatomic, strong, readonly) NSString *ip;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *region;

- (instancetype)initWithSessionHash:(int64_t)sessionHash flags:(int32_t)flags deviceModel:(NSString *)deviceModel platform:(NSString *)platform systemVersion:(NSString *)systemVersion apiId:(int32_t)apiId appName:(NSString *)appName appVersion:(NSString *)appVersion dateCreated:(int32_t)dateCreated dateActive:(int32_t)dateActive ip:(NSString *)ip country:(NSString *)country region:(NSString *)region;

@end
