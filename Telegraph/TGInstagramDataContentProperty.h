#import "PSCoding.h"

@interface TGInstagramDataContentProperty : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *imageUrl;
@property (nonatomic, strong, readonly) NSString *mediaId;

- (instancetype)initWithImageUrl:(NSString *)imageUrl mediaId:(NSString *)mediaId;

@end
