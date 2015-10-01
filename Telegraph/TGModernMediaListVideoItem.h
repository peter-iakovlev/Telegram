#import <Foundation/Foundation.h>

#import "TGModernMediaListItem.h"

@interface TGModernMediaListVideoItem : NSObject <TGModernMediaListItem>

@property (nonatomic, strong, readonly) NSString *imageUri;
@property (nonatomic, readonly) NSTimeInterval duration;

- (instancetype)initWithImageUri:(NSString *)imageUri duration:(NSTimeInterval)duration;

@end
