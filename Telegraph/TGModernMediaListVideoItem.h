#import <Foundation/Foundation.h>

#import "TGModernMediaListItem.h"

@interface TGModernMediaListVideoItem : NSObject <TGModernMediaListItem>

@property (nonatomic, strong, readonly) NSString *imageUri;

- (instancetype)initWithImageUri:(NSString *)imageUri;

@end
