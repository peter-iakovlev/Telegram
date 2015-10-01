#import "TGNeoViewModel.h"

@class TGBridgeUser;

@interface TGNeoAttachmentViewModel : TGNeoViewModel

@property (nonatomic, readonly) bool inhibitsInitials;

- (instancetype)initWithAttachments:(NSArray *)attachments author:(TGBridgeUser *)author forChannel:(bool)forChannel users:(NSDictionary *)users font:(UIFont *)font subTitleColor:(UIColor *)subTitleColor normalColor:(UIColor *)normalColor compact:(bool)compact;

@end
