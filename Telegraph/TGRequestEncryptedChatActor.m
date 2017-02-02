#import "TGRequestEncryptedChatActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import <CommonCrypto/CommonCrypto.h>
#import <MTProtoKit/MTProtoKit.h>
#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTKeychain.h>

#import "TGConversation+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

#import "TGStringUtils.h"

#import "TGAppDelegate.h"

@interface TGRequestEncryptedChatActor ()
{
    int _uid;
    
    NSData *_aBytes;
    TLmessages_DhConfig$messages_dhConfig *_currentConfig;
}

@end

@implementation TGRequestEncryptedChatActor

+ (NSString *)genericPath
{
    return @"/tg/encrypted/createChat/@";
}

- (void)execute:(NSDictionary *)options
{
    _uid = [options[@"uid"] intValue];
    
    _currentConfig = [TGRequestEncryptedChatActor cachedEncryptionConfig];
#ifdef DEBUG
    self.cancelToken = [TGTelegraphInstance doRequestEncryptionConfig:self version:0];
#else
    self.cancelToken = [TGTelegraphInstance doRequestEncryptionConfig:self version:_currentConfig.version];
#endif
}

- (void)dhRequestSuccess:(TLmessages_DhConfig *)config
{
    if ([config isKindOfClass:[TLmessages_DhConfig$messages_dhConfig class]])
    {
        TLmessages_DhConfig$messages_dhConfig *concreteConfig = (TLmessages_DhConfig$messages_dhConfig *)config;
        
        if (!MTCheckIsSafeG(concreteConfig.g))
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            return;
        }
        
        if (!MTCheckMod(concreteConfig.p, concreteConfig.g, [MTFileBasedKeychain keychainWithName:@"legacyPrimes" documentsPath:[TGAppDelegate documentsPath]]))
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            return;
        }
        
        if (!MTCheckIsSafePrime(concreteConfig.p, [MTFileBasedKeychain keychainWithName:@"legacyPrimes" documentsPath:[TGAppDelegate documentsPath]]))
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            return;
        }
        
        _currentConfig = (TLmessages_DhConfig$messages_dhConfig *)config;
        [TGRequestEncryptedChatActor setCachedEncryptionConfig:_currentConfig];
    }
    
    uint8_t rawABytes[256];
    SecRandomCopyBytes(kSecRandomDefault, 256, rawABytes);
    
    for (int i = 0; i < 256 && i < (int)config.random.length; i++)
    {
        uint8_t currentByte = ((uint8_t *)config.random.bytes)[i];
        rawABytes[i] ^= currentByte;
    }
    
    _aBytes = [[NSData alloc] initWithBytes:rawABytes length:256];
    
    int32_t tmpG = _currentConfig.g;
    tmpG = NSSwapInt(tmpG);
    NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
    
    NSData *g_a = MTExp(g, _aBytes, _currentConfig.p);
    
    if (!MTCheckIsSafeGAOrB(g_a, _currentConfig.p))
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    
    self.cancelToken = [TGTelegraphInstance doRequestEncryptedChat:_uid randomId:randomId gABytes:g_a actor:self];
}

- (void)dhRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)encryptedChatRequestSuccess:(TLEncryptedChat *)encryptedChat date:(int)date
{
    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphEncryptedChatDesc:encryptedChat];
    
    if (conversation != nil && conversation.conversationId != 0)
    {
        [TGDatabaseInstance() setConversationCustomProperty:conversation.conversationId name:murMurHash32(@"a") value:_aBytes];
        
        conversation.messageDate = date;
        conversation.encryptedData.handshakeState = 1;
        
        [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
        
        [ActionStageInstance() actionCompleted:self.path result:@{@"conversation": conversation}];
    }
    else
        [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)encryptedChatRequestFailed:(bool)versionOutdated
{
    [ActionStageInstance() actionFailed:self.path reason:versionOutdated ? -2 : -1];
}

+ (TLmessages_DhConfig$messages_dhConfig *)cachedEncryptionConfig
{
    NSData *encryptionConfig = [TGDatabaseInstance() customProperty:@"encryptionConfig2"];
    if (encryptionConfig != nil)
    {
        NSInputStream *is = [[NSInputStream alloc] initWithData:encryptionConfig];
        [is open];
        
        uint8_t version = 0;
        [is read:&version maxLength:1];
        
        if (version != 1)
        {
            TGLog(@"***** Invalid encryption config version");
            return nil;
        }
        
        int32_t configVersion = 0;
        [is read:(uint8_t *)&configVersion maxLength:4];
        
        int32_t g = 0;
        [is read:(uint8_t *)&g maxLength:4];
        
        NSData *primeBytes = nil;
        int32_t length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        if (length != 0)
        {
            uint8_t *bytes = malloc(length);
            [is read:bytes maxLength:length];
            primeBytes = [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:true];
        }
        
        [is close];
        
        TLmessages_DhConfig$messages_dhConfig *config = [[TLmessages_DhConfig$messages_dhConfig alloc] init];
        config.g = g;
        config.p = primeBytes;
        config.version = configVersion;
        
        return config;
    }
    
    return nil;
}

+ (void)setCachedEncryptionConfig:(TLmessages_DhConfig$messages_dhConfig *)config
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    uint8_t version = 1;
    [data appendBytes:&version length:1];
    
    int32_t configVersion = config.version;
    [data appendBytes:&configVersion length:4];
    
    int32_t g = config.g;
    [data appendBytes:&g length:4];
    
    int32_t length = (int32_t)config.p.length;
    [data appendBytes:&length length:4];
    if (config.p != nil)
        [data appendData:config.p];
    
    [TGDatabaseInstance() setCustomProperty:@"encryptionConfig2" value:data];
}

@end
