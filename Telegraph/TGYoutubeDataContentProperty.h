#import "PSCoding.h"

@interface TGYoutubeDataContentProperty : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger duration;

- (instancetype)initWithTitle:(NSString *)title duration:(NSUInteger)duration;

@end
