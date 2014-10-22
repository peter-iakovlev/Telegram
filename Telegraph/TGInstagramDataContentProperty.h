#import "PSCoding.h"

@interface TGInstagramDataContentProperty : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *imageUrl;

- (instancetype)initWithImageUrl:(NSString *)imageUrl;

@end
