#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

@interface TGShareContactUserInfoCell : UITableViewCell

- (void)setName:(NSString *)name avatarSignal:(SSignal *)avatarSignal;

@end
