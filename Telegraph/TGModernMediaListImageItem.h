#import "TGModernMediaListItem.h"

@interface TGModernMediaListImageItem : NSObject <TGModernMediaListItem>

@property (nonatomic, strong, readonly) NSString *imageUri;

- (instancetype)initWithImageUri:(NSString *)imageUri;

@end
