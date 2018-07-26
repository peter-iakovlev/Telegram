#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

@class TGTermsOfService;

@interface TGLoginProfileController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (id)initWithShowKeyboard:(bool)showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode termsOfService:(TGTermsOfService *)termsOfService;

@end
