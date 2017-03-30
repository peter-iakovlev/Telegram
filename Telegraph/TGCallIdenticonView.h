#import <UIKit/UIKit.h>

@interface TGCallIdenticonView : UIImageView

@property (nonatomic, copy) void (^onTap)(void);
- (void)setSha1:(NSData *)sha1 sha256:(NSData *)sha256;

@end
