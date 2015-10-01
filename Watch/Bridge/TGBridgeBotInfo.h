#import <Foundation/Foundation.h>

@interface TGBridgeBotInfo : NSObject <NSCoding>
{
    int32_t _version;
    int32_t _userId;
    NSString *_shortDescription;
    NSString *_botDescription;
    NSArray *_commandList;
}

@property (nonatomic, readonly) int32_t version;
@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) NSString *shortDescription;
@property (nonatomic, readonly) NSString *botDescription;
@property (nonatomic, readonly) NSArray *commandList;

@end
