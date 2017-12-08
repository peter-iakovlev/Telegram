#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

@interface TGLoginProfileController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (id)initWithShowKeyboard:(bool)showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode;

@end
