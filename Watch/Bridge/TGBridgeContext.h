#import <Foundation/Foundation.h>

@interface TGBridgeContext : NSObject

@property (nonatomic, assign) bool authorized;
@property (nonatomic, assign) int32_t userId;

@property (nonatomic, assign) bool passcodeEnabled;
@property (nonatomic, assign) bool passcodeEncrypted;

@property (nonatomic, readonly) NSDictionary *startupData;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)setStartupData:(NSDictionary *)startupData version:(int32_t)version;
- (NSInteger)startupDataVersion;

- (NSDictionary *)encodeWithStartupData:(bool)withStartupData;

+ (int32_t)versionWithCurrentDate;

@end

extern NSString *const TGBridgeContextStartupDataVersion;
