#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGEncryptionKeyViewController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId userId:(int)userId;

@end
