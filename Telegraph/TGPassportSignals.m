#import "TGPassportSignals.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import <MTProtoKit/MTProtoKit.h>

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <LegacyComponents/TGStringUtils.h>

#import "TLRPCaccount_getAllSecureValues.h"
#import "TLRPCaccount_getSecureValue.h"
#import "TLRPCaccount_saveSecureValue.h"
#import "TLRPCaccount_deleteSecureValue.h"
#import "TLRPCaccount_getAuthorizationForm.h"
#import "TLRPCaccount_acceptAuthorization.h"

#import "TLRPCaccount_sendVerifyPhoneCode.h"
#import "TLRPCaccount_verifyPhone.h"
#import "TLRPCaccount_sendVerifyEmailCode.h"
#import "TLRPCaccount_verifyEmail.h"

#import "TLInputSecureValue$inputSecureValue.h"

#import "MediaBox.h"
#import "TelegramMediaResources.h"
#import "TGPassportFile.h"

#import "TGTwoStepConfigSignal.h"
#import "TGUserDataRequestBuilder.h"
#import "TGUploadFileSignals.h"

@implementation TGPassportSignals

static SPipe *passportPipe;

+ (void)load
{
    passportPipe = [[SPipe alloc] init];
}

+ (SSignal *)hasPassport
{
    SSignal *initialSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [TGDatabaseInstance() customProperty:@"hasPassport" completion:^(NSData *value)
         {
             int32_t hasPassport = false;
             if (value.length == 4) {
                 [value getBytes:&hasPassport];
             }
             [subscriber putNext:@(hasPassport)];
             [subscriber putCompletion];
         }];
        return nil;
    }];
    initialSignal = [initialSignal mapToSignal:^SSignal *(NSNumber *value)
    {
        if ([value boolValue]) {
            return [SSignal single:value];
        }
        else {
            return [[SSignal single:value] then:[[[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *config)
            {
                if (config.hasSecureValues) {
                    return [SSignal single:@true];
                } else {
                    return [[SSignal single:@false] then:[passportPipe.signalProducer() take:1]];
                }
            }] onNext:^(NSNumber *next) {
                if (next.boolValue) {
                    bool value = next.boolValue;
                    [TGDatabaseInstance() setCustomProperty:@"hasPassport" value:[[NSData alloc] initWithBytes:&value length:4]];
                }
            }]];
        }
    }];
    
    return [initialSignal ignoreRepeated];
}

+ (SSignal *)allSecureValuesWithSecret:(NSData *)secret
{
    return [[self allSecureValues] map:^id(NSArray *secureValues)
    {
        return [[TGPassportDecryptedForm alloc] initWithForm:nil values:[self decryptedSecureValues:secureValues secret:secret]];
    }];
}

+ (SSignal *)authorizationFormForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey
{
    TLRPCaccount_getAuthorizationForm *getAuthorizationForm = [[TLRPCaccount_getAuthorizationForm alloc] init];
    getAuthorizationForm.bot_id = botId;
    getAuthorizationForm.scope = scope;
    getAuthorizationForm.public_key = publicKey;
    
    return [[[TGTelegramNetworking instance] requestSignal:getAuthorizationForm] map:^id(TLaccount_AuthorizationForm$account_authorizationFormMeta *result)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        return [[TGPassportForm alloc] initWithTL:result];
    }];
}

+ (SSignal *)acceptAuthorizationForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey finalForm:(TGPassportDecryptedForm *)finalForm payload:(NSString *)payload
{
    TLRPCaccount_acceptAuthorization *acceptAuthorization = [[TLRPCaccount_acceptAuthorization alloc] init];
    acceptAuthorization.bot_id = botId;
    acceptAuthorization.scope = scope;
    acceptAuthorization.public_key = publicKey;
    
    NSMutableArray *valueHashes = [[NSMutableArray alloc] init];
    for (TGPassportDecryptedValue *value in finalForm.values)
    {
        TLSecureValueHash$secureValueHash *valueHash = [[TLSecureValueHash$secureValueHash alloc] init];
        valueHash.type = [self secureValueTypeForType:value.type];
        valueHash.n_hash = value.valueHash;
        [valueHashes addObject:valueHash];
    }
    acceptAuthorization.value_hashes = valueHashes;
    
    NSData *credentialsData = [finalForm credentialsDataWithPayload:payload];
    NSData *credentialsSecret = [self secretWithSecretRandom:nil];

    NSData *paddedData = [self paddedDataForEncryption:credentialsData];
    NSData *credentialsHash = MTSha256(paddedData);
    NSData *encryptedData = [self encrypted:true data:paddedData hash:credentialsHash secret:credentialsSecret];
    
    SecKeyRef key = [self addPublicKey:publicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    SecKeyEncrypt(key, kSecPaddingOAEP, credentialsSecret.bytes, credentialsSecret.length, &cipherBuffer[0], &cipherBufferSize);
    
    NSData *encryptedCredentialsSecret = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    TLSecureCredentialsEncrypted$secureCredentialsEncrypted *encryptedCredentials = [[TLSecureCredentialsEncrypted$secureCredentialsEncrypted alloc] init];
    encryptedCredentials.data = encryptedData;
    encryptedCredentials.secret = encryptedCredentialsSecret;
    encryptedCredentials.n_hash = credentialsHash;
    acceptAuthorization.credentials = encryptedCredentials;
    
    return [[TGTelegramNetworking instance] requestSignal:acceptAuthorization];
}

+ (SSignal *)sendPhoneVerificationCode:(NSString *)phoneNumber
{
    TLRPCaccount_sendVerifyPhoneCode *sendVerifyPhoneCode = [[TLRPCaccount_sendVerifyPhoneCode alloc] init];
    sendVerifyPhoneCode.phone_number = phoneNumber;
    return [[TGTelegramNetworking instance] requestSignal:sendVerifyPhoneCode];
}

+ (SSignal *)verifyPhone:(NSString *)phoneNumber code:(NSString *)code hash:(NSString *)hash
{
    TLRPCaccount_verifyPhone *verifyPhone = [[TLRPCaccount_verifyPhone alloc] init];
    verifyPhone.phone_number = phoneNumber;
    verifyPhone.phone_code = code;
    verifyPhone.phone_code_hash = hash;
    return [[TGTelegramNetworking instance] requestSignal:verifyPhone];
}

+ (SSignal *)sendEmailVerificationCode:(NSString *)email
{
    TLRPCaccount_sendVerifyEmailCode *sendVerifyEmailCode = [[TLRPCaccount_sendVerifyEmailCode alloc] init];
    sendVerifyEmailCode.email = email;
    return [[TGTelegramNetworking instance] requestSignal:sendVerifyEmailCode continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true];
}

+ (SSignal *)verifyEmail:(NSString *)email code:(NSString *)code
{
    TLRPCaccount_verifyEmail *verifyEmail = [[TLRPCaccount_verifyEmail alloc] init];
    verifyEmail.email = email;
    verifyEmail.code = code;
    return [[TGTelegramNetworking instance] requestSignal:verifyEmail continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true];
}

+ (NSData *)encrypted:(bool)encrypted data:(NSData *)data hash:(NSData *)hash secret:(NSData *)secret
{
    NSMutableData *secretHashData = [[NSMutableData alloc] init];
    [secretHashData appendData:secret];
    [secretHashData appendData:hash];
    NSData *secretHash = [TGTwoStepConfigSignal TGSha512:secretHashData];
    NSData *secretKey = [secretHash subdataWithRange:NSMakeRange(0, 32)];
    NSData *secretIv = [secretHash subdataWithRange:NSMakeRange(32, 16)];
    
    return [self aes256CBC:data key:secretKey iv:secretIv decrypt:!encrypted];
}

+ (NSData *)decryptedDataWithData:(NSData *)data dataHash:(NSData *)dataHash dataSecret:(NSData *)dataSecret keepPadding:(bool)keepPadding
{
    NSData *decryptedData = [self encrypted:false data:data hash:dataHash secret:dataSecret];
    uint8_t paddingLength;
    [decryptedData getBytes:&paddingLength length:sizeof(uint8_t)];
    
    if (paddingLength >= decryptedData.length)
        return nil;
    
    if (!keepPadding)
        decryptedData = [decryptedData subdataWithRange:NSMakeRange(paddingLength, decryptedData.length - paddingLength)];
    return decryptedData;
}

+ (NSArray *)decryptedSecureValues:(NSArray *)values secret:(NSData *)secret
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TLSecureValue *value in values)
    {
        if ([value isKindOfClass:[TLSecureValue$secureValueMeta class]])
        {
            TGPassportType type = [self typeForSecureValueType:value.type];
            TGPassportSecureData *data = nil;
            TGPassportFile *frontSide = nil;
            TGPassportFile *reverseSide = nil;
            TGPassportFile *selfie = nil;
            NSMutableArray *files = nil;
            TGPassportPlainData *plainData = nil;
            
            if (value.data != nil)
            {
                NSData *dataSecret = [self encrypted:false data:value.data.secret hash:value.data.data_hash secret:secret];
                if (dataSecret == nil)
                    continue;
                
                NSData *paddedData = [self decryptedDataWithData:value.data.data dataHash:value.data.data_hash dataSecret:dataSecret keepPadding:true];
                if (paddedData == nil)
                    continue;
                
                if (paddedData.length > 0)
                {
                    switch (type) {
                        case TGPassportTypePersonalDetails:
                            data = [[TGPassportPersonalDetailsData alloc] initWithPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:value.data.secret];
                            break;
                            
                        case TGPassportTypePassport:
                        case TGPassportTypeIdentityCard:
                        case TGPassportTypeDriversLicense:
                        case TGPassportTypeInternalPassport:
                            data = [[TGPassportDocumentData alloc] initWithPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:value.data.secret];
                            break;
                            
                        case TGPassportTypeAddress:
                            data = [[TGPassportAddressData alloc] initWithPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:value.data.secret];
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            
            if ([value.front_side isKindOfClass:[TLSecureFile$secureFile class]])
            {
                TLSecureFile$secureFile *secureFile = (TLSecureFile$secureFile *)value.front_side;
                frontSide = [[TGPassportFile alloc] initWithTL:secureFile fileSecret:[self encrypted:false data:secureFile.secret hash:secureFile.file_hash secret:secret]];
            }
            
            if ([value.reverse_side isKindOfClass:[TLSecureFile$secureFile class]])
            {
                TLSecureFile$secureFile *secureFile = (TLSecureFile$secureFile *)value.reverse_side;
                reverseSide = [[TGPassportFile alloc] initWithTL:secureFile fileSecret:[self encrypted:false data:secureFile.secret hash:secureFile.file_hash secret:secret]];
            }
            
            if ([value.selfie isKindOfClass:[TLSecureFile$secureFile class]])
            {
                TLSecureFile$secureFile *secureFile = (TLSecureFile$secureFile *)value.selfie;
                selfie = [[TGPassportFile alloc] initWithTL:secureFile fileSecret:[self encrypted:false data:secureFile.secret hash:secureFile.file_hash secret:secret]];
            }
            
            if (value.files != nil)
            {
                files = [[NSMutableArray alloc] init];
                for (TLSecureFile$secureFile *secureFile in value.files)
                {
                    if (![secureFile isKindOfClass:[TLSecureFile$secureFile class]])
                        continue;
                    
                    NSData *fileSecret = [self encrypted:false data:secureFile.secret hash:secureFile.file_hash secret:secret];
                    if (fileSecret == nil)
                        continue;
                    TGPassportFile *file = [[TGPassportFile alloc] initWithTL:secureFile fileSecret:fileSecret];
                    [files addObject:file];
                }
            }
            
            if (value.plain_data != nil)
            {
                if ([value.plain_data isKindOfClass:[TLSecurePlainData$securePlainPhone class]])
                {
                    plainData = [[TGPassportPhoneData alloc] initWithPhone:((TLSecurePlainData$securePlainPhone *)value.plain_data).phone];
                }
                else if ([value.plain_data isKindOfClass:[TLSecurePlainData$securePlainEmail class]])
                {
                    plainData = [[TGPassportEmailData alloc] initWithEmail:((TLSecurePlainData$securePlainEmail *)value.plain_data).email];
                }
            }
            
            TGPassportDecryptedValue *decryptedValue = [[TGPassportDecryptedValue alloc] initWithType:type data:data frontSide:frontSide reverseSide:reverseSide selfie:selfie files:files plainData:plainData];
            decryptedValue = [decryptedValue updateWithValueHash:value.n_hash];
            if (decryptedValue != nil)
                [result addObject:decryptedValue];
        }
    }
    return result;
}

+ (TGPassportDecryptedForm *)decryptedForm:(TGPassportForm *)form secret:(NSData *)secret
{
    TLaccount_AuthorizationForm$account_authorizationFormMeta *tlForm = (TLaccount_AuthorizationForm$account_authorizationFormMeta *)form->_tl;
    return [[TGPassportDecryptedForm alloc] initWithForm:form values:[self decryptedSecureValues:tlForm.values secret:secret]];
}

+ (TGPassportType)typeForSecureValueType:(TLSecureValueType *)valueType
{
    TGPassportType type = TGPassportTypeUndefined;
    if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypePersonalDetails class]])
        type = TGPassportTypePersonalDetails;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypePassport class]])
        type = TGPassportTypePassport;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeDriverLicense class]])
        type = TGPassportTypeDriversLicense;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeIdentityCard class]])
        type = TGPassportTypeIdentityCard;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeInternalPassport class]])
        type = TGPassportTypeInternalPassport;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeAddress class]])
        type = TGPassportTypeAddress;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeUtilityBill class]])
        type = TGPassportTypeUtilityBill;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeBankStatement class]])
        type = TGPassportTypeBankStatement;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeRentalAgreement class]])
        type = TGPassportTypeRentalAgreement;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypePassportRegistration class]])
        type = TGPassportTypePassportRegistration;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeTemporaryRegistration class]])
        type = TGPassportTypeTemporaryRegistration;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypePhone class]])
        type = TGPassportTypePhone;
    else if ([valueType isKindOfClass:[TLSecureValueType$secureValueTypeEmail class]])
        type = TGPassportTypeEmail;
    return type;
}

+ (NSArray *)typesForSecureValueTypes:(NSArray *)valueTypes
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (TLSecureValueType *valueType in valueTypes)
    {
        TGPassportType type = [self typeForSecureValueType:valueType];
        if (type != TGPassportTypeUndefined)
            [types addObject:@(type)];
    }
    return types;
}

+ (TLSecureValueType *)secureValueTypeForType:(TGPassportType)valueType
{
    switch (valueType)
    {
        case TGPassportTypePersonalDetails:
            return [[TLSecureValueType$secureValueTypePersonalDetails alloc] init];
            
        case TGPassportTypePassport:
            return [[TLSecureValueType$secureValueTypePassport alloc] init];

        case TGPassportTypeDriversLicense:
            return [[TLSecureValueType$secureValueTypeDriverLicense alloc] init];
            
        case TGPassportTypeIdentityCard:
            return [[TLSecureValueType$secureValueTypeIdentityCard alloc] init];
            
        case TGPassportTypeInternalPassport:
            return [[TLSecureValueType$secureValueTypeInternalPassport alloc] init];
            
        case TGPassportTypeAddress:
            return [[TLSecureValueType$secureValueTypeAddress alloc] init];
            
        case TGPassportTypeUtilityBill:
            return [[TLSecureValueType$secureValueTypeUtilityBill alloc] init];
            
        case TGPassportTypeBankStatement:
            return [[TLSecureValueType$secureValueTypeBankStatement alloc] init];
            
        case TGPassportTypeRentalAgreement:
            return [[TLSecureValueType$secureValueTypeRentalAgreement alloc] init];
            
        case TGPassportTypePassportRegistration:
            return [[TLSecureValueType$secureValueTypePassportRegistration alloc] init];
            
        case TGPassportTypeTemporaryRegistration:
            return [[TLSecureValueType$secureValueTypeTemporaryRegistration alloc] init];
            
        case TGPassportTypePhone:
            return [[TLSecureValueType$secureValueTypePhone alloc] init];
            
        case TGPassportTypeEmail:
            return [[TLSecureValueType$secureValueTypeEmail alloc] init];
            
        default:
             return nil;
    }
}

+ (NSArray *)secureValueTypesForTypes:(NSArray *)types
{
    NSMutableArray *secureValueTypes = [[NSMutableArray alloc] init];
    for (NSNumber *type in types)
    {
        TGPassportType valueType = (TGPassportType)type.intValue;
        TLSecureValueType *type = [self secureValueTypeForType:valueType];
        if (type != nil)
            [secureValueTypes addObject:type];
    }
    return secureValueTypes;
}

+ (SSignal *)deleteSecureValueTypes:(NSArray *)types
{
    TLRPCaccount_deleteSecureValue *deleteSecureValue = [[TLRPCaccount_deleteSecureValue alloc] init];
    deleteSecureValue.types = [self secureValueTypesForTypes:types];
    
    return [[TGTelegramNetworking instance] requestSignal:deleteSecureValue];
}

+ (SSignal *)deleteAllSecureValues
{
    NSArray *types = @[
        @(TGPassportTypePersonalDetails),
        @(TGPassportTypePassport),
        @(TGPassportTypeDriversLicense),
        @(TGPassportTypeIdentityCard),
        @(TGPassportTypeInternalPassport),
        @(TGPassportTypeAddress),
        @(TGPassportTypeUtilityBill),
        @(TGPassportTypeBankStatement),
        @(TGPassportTypeRentalAgreement),
        @(TGPassportTypePassportRegistration),
        @(TGPassportTypeTemporaryRegistration),
        @(TGPassportTypePhone),
        @(TGPassportTypeEmail)
    ];
    return [self deleteSecureValueTypes:types];
}

+ (SSignal *)secureValueTypes:(NSArray *)types
{
    TLRPCaccount_getSecureValue *getSecureValue = [[TLRPCaccount_getSecureValue alloc] init];
    getSecureValue.types = [self secureValueTypesForTypes:types];
    
    return [[TGTelegramNetworking instance] requestSignal:getSecureValue];
}

+ (SSignal *)allSecureValues
{
    TLRPCaccount_getAllSecureValues *getAllSecureValues = [[TLRPCaccount_getAllSecureValues alloc] init];
    return [[TGTelegramNetworking instance] requestSignal:getAllSecureValues];
}

+ (SSignal *)saveSecureValue:(TGPassportDecryptedValue *)value secret:(NSData *)secret
{
    TLRPCaccount_saveSecureValue *saveSecureValue = [[TLRPCaccount_saveSecureValue alloc] init];
    
    TLInputSecureValue$inputSecureValue *inputSecureValue = [[TLInputSecureValue$inputSecureValue alloc] init];
    inputSecureValue.type = [self secureValueTypeForType:value.type];
    if (inputSecureValue.type == nil)
        return [SSignal fail:nil];
    
    if (value.data != nil)
    {
        NSData *encryptedData = [self encrypted:true data:value.data.paddedData hash:value.data.dataHash secret:value.data.dataSecret];
        
        TLSecureData$secureData *secureData = [[TLSecureData$secureData alloc] init];
        secureData.data = encryptedData;
        secureData.data_hash = value.data.dataHash;
        secureData.secret = value.data.encryptedDataSecret;
        
        inputSecureValue.flags |= (1 << 0);
        inputSecureValue.data = secureData;
    }
    
    if (value.frontSide != nil)
    {
        TLInputSecureFile *frontSide = nil;
        TGPassportFile *file = value.frontSide;
        if (file.uploaded)
        {
            TLInputSecureFile$inputSecureFileUploaded *inputSecureFileUploaded = [[TLInputSecureFile$inputSecureFileUploaded alloc] init];
            inputSecureFileUploaded.n_id = file.fileId;
            inputSecureFileUploaded.parts = file.parts;
            inputSecureFileUploaded.md5_checksum = file.md5Checksum;
            inputSecureFileUploaded.file_hash = file.fileHash;
            inputSecureFileUploaded.secret = file.encryptedFileSecret;
            frontSide = inputSecureFileUploaded;
        }
        else
        {
            TLInputSecureFile$inputSecureFile *inputSecureFile = [[TLInputSecureFile$inputSecureFile alloc] init];
            inputSecureFile.n_id = file.fileId;
            inputSecureFile.access_hash = file.accessHash;
            frontSide = inputSecureFile;
        }
        
        inputSecureValue.flags |= (1 << 1);
        inputSecureValue.front_side = frontSide;
    }
    
    if (value.reverseSide != nil)
    {
        TLInputSecureFile *reverseSide = nil;
        TGPassportFile *file = value.reverseSide;
        if (file.uploaded)
        {
            TLInputSecureFile$inputSecureFileUploaded *inputSecureFileUploaded = [[TLInputSecureFile$inputSecureFileUploaded alloc] init];
            inputSecureFileUploaded.n_id = file.fileId;
            inputSecureFileUploaded.parts = file.parts;
            inputSecureFileUploaded.md5_checksum = file.md5Checksum;
            inputSecureFileUploaded.file_hash = file.fileHash;
            inputSecureFileUploaded.secret = file.encryptedFileSecret;
            reverseSide = inputSecureFileUploaded;
        }
        else
        {
            TLInputSecureFile$inputSecureFile *inputSecureFile = [[TLInputSecureFile$inputSecureFile alloc] init];
            inputSecureFile.n_id = file.fileId;
            inputSecureFile.access_hash = file.accessHash;
            reverseSide = inputSecureFile;
        }
        
        inputSecureValue.flags |= (1 << 2);
        inputSecureValue.reverse_side = reverseSide;
    }
    
    if (value.selfie != nil)
    {
        TLInputSecureFile *selfie = nil;
        TGPassportFile *file = value.selfie;
        if (file.uploaded)
        {
            TLInputSecureFile$inputSecureFileUploaded *inputSecureFileUploaded = [[TLInputSecureFile$inputSecureFileUploaded alloc] init];
            inputSecureFileUploaded.n_id = file.fileId;
            inputSecureFileUploaded.parts = file.parts;
            inputSecureFileUploaded.md5_checksum = file.md5Checksum;
            inputSecureFileUploaded.file_hash = file.fileHash;
            inputSecureFileUploaded.secret = file.encryptedFileSecret;
            selfie = inputSecureFileUploaded;
        }
        else
        {
            TLInputSecureFile$inputSecureFile *inputSecureFile = [[TLInputSecureFile$inputSecureFile alloc] init];
            inputSecureFile.n_id = file.fileId;
            inputSecureFile.access_hash = file.accessHash;
            selfie = inputSecureFile;
        }
        
        inputSecureValue.flags |= (1 << 3);
        inputSecureValue.selfie = selfie;
    }
    
    if (value.files.count > 0)
    {
        NSMutableArray *inputFiles = [[NSMutableArray alloc] init];
        for (TGPassportFile *file in value.files)
        {
            if (file.uploaded)
            {
                TLInputSecureFile$inputSecureFileUploaded *inputSecureFileUploaded = [[TLInputSecureFile$inputSecureFileUploaded alloc] init];
                inputSecureFileUploaded.n_id = file.fileId;
                inputSecureFileUploaded.parts = file.parts;
                inputSecureFileUploaded.md5_checksum = file.md5Checksum;
                inputSecureFileUploaded.file_hash = file.fileHash;
                inputSecureFileUploaded.secret = file.encryptedFileSecret;
                [inputFiles addObject:inputSecureFileUploaded];
            }
            else
            {
                TLInputSecureFile$inputSecureFile *inputSecureFile = [[TLInputSecureFile$inputSecureFile alloc] init];
                inputSecureFile.n_id = file.fileId;
                inputSecureFile.access_hash = file.accessHash;
                [inputFiles addObject:inputSecureFile];
            }
        }
        
        inputSecureValue.flags |= (1 << 4);
        inputSecureValue.files = inputFiles;
    }
    
    if (value.plainData != nil)
    {
        TLSecurePlainData *securePlainData = nil;
        
        if ([value.plainData isKindOfClass:[TGPassportPhoneData class]])
        {
            TLSecurePlainData$securePlainPhone *securePlainPhone = [[TLSecurePlainData$securePlainPhone alloc] init];
            securePlainPhone.phone = ((TGPassportPhoneData *)value.plainData).phone;
            securePlainData = securePlainPhone;
        }
        else if ([value.plainData isKindOfClass:[TGPassportEmailData class]])
        {
            TLSecurePlainData$securePlainEmail *securePlainEmail = [[TLSecurePlainData$securePlainEmail alloc] init];
            securePlainEmail.email = ((TGPassportEmailData *)value.plainData).email;
            securePlainData = securePlainEmail;
        }
        
        inputSecureValue.flags |= (1 << 5);
        inputSecureValue.plain_data = securePlainData;
    }
    
    saveSecureValue.value = inputSecureValue;
    saveSecureValue.secure_secret_id = [self secureSecretId:secret];
    
    return [[[TGTelegramNetworking instance] requestSignal:saveSecureValue] onNext:^(NSNumber *next) {
        if ([next isKindOfClass:[TLSecureValue class]]) {
            bool value = true;
            [TGDatabaseInstance() setCustomProperty:@"hasPassport" value:[[NSData alloc] initWithBytes:&value length:4]];
            passportPipe.sink(@true);
        }
    }];
}

+ (SSignal *)uploadSecureData:(NSData *)data thumbnailData:(NSData *)thumbnailData secret:(NSData *)secret
{
    NSData *paddedData = [self paddedDataForEncryption:data];
    NSData *fileHash = MTSha256(paddedData);
    NSData *fileSecret = [self secretWithSecretRandom:nil];
    NSData *encryptedData = [self encrypted:true data:paddedData hash:fileHash secret:fileSecret];
    NSData *encryptedFileSecret = [self encrypted:true data:fileSecret hash:fileHash secret:secret];
    
    NSData *paddedThumbnailData = [self paddedDataForEncryption:thumbnailData];
    NSData *encryptedThumbnailData = [self encrypted:true data:paddedThumbnailData hash:fileHash secret:fileSecret];
    
    CloudSecureMediaResource *resource = [[CloudSecureMediaResource alloc] initWithDatacenterId:0 fileId:0 accessHash:0 size:@(paddedData.length) fileHash:fileHash thumbnail:false mediaType:@(TGNetworkMediaTypeTagDocument)];
    ResourceStorePaths *paths = [TGTelegraphInstance.mediaBox storePathsForId:resource.resourceId];
    [encryptedData writeToFile:paths.complete atomically:true];
    
    resource = [[CloudSecureMediaResource alloc] initWithDatacenterId:0 fileId:0 accessHash:0 size:@(encryptedThumbnailData.length) fileHash:fileHash thumbnail:true mediaType:@(TGNetworkMediaTypeTagDocument)];
    paths = [TGTelegraphInstance.mediaBox storePathsForId:resource.resourceId];
    [encryptedThumbnailData writeToFile:paths.complete atomically:true];
    
    return [[TGUploadFileSignals uploadedSecureFileWithData:encryptedData mediaTypeTag:TGNetworkMediaTypeTagDocument] map:^id(id value)
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            return [[TGPassportFile alloc] initForUploadedFileWithId:[value[@"fileId"] int64Value] parts:[value[@"parts"] int32Value] md5Checksum:value[@"md5Checksum"] fileHash:fileHash fileSecret:fileSecret encryptedFileSecret:encryptedFileSecret date:(int32_t)[[NSDate date] timeIntervalSince1970]];
        }
        return value;
    }];
}

+ (NSData *)paddedDataForEncryption:(NSData *)data
{
    NSMutableData *padding = [[NSMutableData alloc] initWithCapacity:255];
    uint8_t bytesToAdd = 32 + (uint8_t)arc4random_uniform(255 - 32 - 16);
    while ((data.length + bytesToAdd) % 16 != 0)
    {
        bytesToAdd++;
    }
    [padding appendBytes:&bytesToAdd length:sizeof(uint8_t)];
    
    uint8_t randomData[bytesToAdd - 1];
    __unused int result = SecRandomCopyBytes(kSecRandomDefault, bytesToAdd - 1, randomData);
    [padding appendBytes:&randomData length:bytesToAdd - 1];
    
    NSMutableData *paddedData = [[NSMutableData alloc] init];
    [paddedData appendData:padding];
    [paddedData appendData:data];
    
    return paddedData;
}

+ (NSData *)secretWithSecretRandom:(NSData *)secretRandom
{
    uint8_t randomData[32];
    __unused int result = SecRandomCopyBytes(kSecRandomDefault, 32, randomData);
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:randomData length:32];
    if (secretRandom != nil) {}
    
    uint8_t *bytes = (uint8_t *)[data mutableBytes];
    NSInteger bytesSum = 0;
    for (NSUInteger i = 0; i < data.length; i++)
    {
        uint8_t byte = *(bytes + i);
        bytesSum += byte;
    }
    bytesSum = bytesSum % 255;
    int32_t diff = 239 - (int32_t)bytesSum;
    uint8_t randomByteIndex = (uint8_t)arc4random_uniform(32);
    int32_t randomByteValue = (*(bytes + randomByteIndex) + diff);
    if (randomByteValue < 0)
        randomByteValue = 255 + randomByteValue;
    randomByteValue %= 255;
    *(bytes + randomByteIndex) = (uint8_t)randomByteValue;
    
    return data;
}

+ (int64_t)secureSecretId:(NSData *)secureSecret
{
    NSData *secureSecretId = MTSha256(secureSecret);
    int64_t hash = 0;
    //[[NSData alloc] initWithBytes:(((int8_t *)messageKeyFull.bytes) + messageKeyFull.length - 16) length:16]
    [secureSecretId getBytes:&hash length:8];
    return hash;
}

+ (NSData *)encryptedSecureSecretWithData:(NSData *)data passord:(NSString *)password nextSecureSalt:(NSData *)nextSecureSalt secureSaltOut:(NSData *__autoreleasing *)secureSaltOut
{
    NSMutableData *finalSecureSalt = [[NSMutableData alloc] initWithData:nextSecureSalt];
    
    uint8_t randomData[8];
    __unused int result = SecRandomCopyBytes(kSecRandomDefault, 8, randomData);
    [finalSecureSalt appendBytes:randomData length:8];
    
    if (secureSaltOut != NULL)
        *secureSaltOut = finalSecureSalt;
    
    NSMutableData *passwordHashData = [[NSMutableData alloc] init];
    [passwordHashData appendData:finalSecureSalt];
    [passwordHashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [passwordHashData appendData:finalSecureSalt];
    
    NSData *passwordHash = [TGTwoStepConfigSignal TGSha512:passwordHashData];
    NSData *secretKey = [passwordHash subdataWithRange:NSMakeRange(0, 32)];
    NSData *iv = [passwordHash subdataWithRange:NSMakeRange(32, 16)];
    
    NSData *encryptedSecret = [self aes256CBC:data key:secretKey iv:iv decrypt:false];
    return encryptedSecret;
}

+ (NSData *)decryptedSecureSecretWithData:(NSData *)data passord:(NSString *)password secureSalt:(NSData *)secureSalt
{
    NSMutableData *passwordHashData = [[NSMutableData alloc] init];
    [passwordHashData appendData:secureSalt];
    [passwordHashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [passwordHashData appendData:secureSalt];
    
    NSData *passwordHash = [TGTwoStepConfigSignal TGSha512:passwordHashData];
    NSData *secretKey = [passwordHash subdataWithRange:NSMakeRange(0, 32)];
    NSData *iv = [passwordHash subdataWithRange:NSMakeRange(32, 16)];
    
    NSData *decryptedSecret = [self aes256CBC:data key:secretKey iv:iv decrypt:true];
    return decryptedSecret;
}

+ (NSData *)decryptedSecureSecretWithData:(NSData *)data passwordHash:(NSData *)passwordHash
{
    NSData *secretKey = [passwordHash subdataWithRange:NSMakeRange(0, 32)];
    NSData *iv = [passwordHash subdataWithRange:NSMakeRange(32, 16)];
    
    NSData *decryptedSecret = [self aes256CBC:data key:secretKey iv:iv decrypt:true];
    return decryptedSecret;
}

+ (NSData *)aes256CBC:(NSData *)data key:(NSData *)key iv:(NSData *)iv decrypt:(bool)decrypt
{
    CCOperation operation = decrypt ? kCCDecrypt : kCCEncrypt;
    size_t bufferSize = data.length;
    void *buffer = malloc(bufferSize);
    
    size_t length = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES, 0, key.bytes, kCCKeySizeAES256, iv.bytes, data.bytes, data.length, buffer, bufferSize, &length);
    
    if (cryptStatus == kCCSuccess)
        return [NSData dataWithBytesNoCopy:buffer length:length];

    free(buffer);
    return nil;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx] == 0x02)
        return d_key;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (SecKeyRef)addPublicKey:(NSString *)key
{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound)
    {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    NSData *data = iosMajorVersion() >= 7 ? [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters] : [[NSData alloc] initWithBase64Encoding:key];
    data = [self stripPublicKeyHeader:data];
    
    if (data == nil)
        return nil;
    
    NSString *tag = @"TGPassport_PubKey";
    NSData *d_tag = [NSData dataWithBytes:tag.UTF8String length:tag.length];
    
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil)
        CFRelease(persistKey);
    if ((status != noErr) && (status != errSecDuplicateItem))
        return nil;
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr)
        return nil;
    return keyRef;
}

static NSData *storedPasswordHash;
static NSData *storedSecretPasswordHash;
static SMetaDisposable *forgetPasswordDisposable;

+ (void)storePasswordHash:(NSData *)passwordHash secretPasswordHash:(NSData *)secretPasswordHash
{
    NSData *previousPasswordHash = storedPasswordHash;
    NSData *previousSecretPasswordHash = storedSecretPasswordHash;

    storedPasswordHash = passwordHash;
    storedSecretPasswordHash = secretPasswordHash;
    
    if (!TGObjectCompare(storedPasswordHash, previousPasswordHash) || !TGObjectCompare(storedSecretPasswordHash, previousSecretPasswordHash))
    {
        if (forgetPasswordDisposable == nil)
            forgetPasswordDisposable = [[SMetaDisposable alloc] init];
        
        NSTimeInterval interval = 30.0 * 60.0;
    #ifdef DEBUG
        interval = 30.0;
    #endif
        [forgetPasswordDisposable setDisposable:[[[SSignal complete] delay:interval onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
            [self clearStoredPasswordHashes];
        }]];
    }
}

+ (void)clearStoredPasswordHashes
{
    storedPasswordHash = nil;
    storedSecretPasswordHash = nil;
}

+ (NSData *)storedPasswordHash
{
    return storedPasswordHash;
}

+ (NSData *)storedSecretPasswordHash
{
    return storedSecretPasswordHash;
}

@end
