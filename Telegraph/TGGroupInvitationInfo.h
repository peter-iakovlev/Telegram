#import <Foundation/Foundation.h>

@interface TGGroupInvitationInfo : NSObject

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) bool alreadyAccepted;
@property (nonatomic, readonly) bool left;
@property (nonatomic, readonly) bool isChannel;

- (instancetype)initWithTitle:(NSString *)title alreadyAccepted:(bool)alreadyAccepted left:(bool)left isChannel:(bool)isChannel;

@end
