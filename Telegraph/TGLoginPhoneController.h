#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

@interface TGLoginPhoneController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)setPhoneNumber:(NSString *)phoneNumber;

@end
