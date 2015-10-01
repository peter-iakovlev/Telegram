#import "TGStoredSecretAction.h"

#import "PSKeyValueCoder.h"

TGStoredSecretActionWithSeqActionId TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdType type, int32_t value)
{
    return (TGStoredSecretActionWithSeqActionId){.type = type, .value = value};
}

@implementation TGStoredSecretActionWithSeq

- (instancetype)initWithActionId:(TGStoredSecretActionWithSeqActionId)actionId action:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut
{
    self = [super init];
    if (self != nil)
    {
        _actionId = actionId;
        _action = action;
        _seqIn = seqIn;
        _seqOut = seqOut;
    }
    return self;
}

@end

@implementation TGStoredSecretIncomingActionWithSeq

- (instancetype)initWithAction:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut layer:(NSUInteger)layer
{
    self = [super init];
    if (self != nil)
    {
        _action = action;
        _seqIn = seqIn;
        _seqOut = seqOut;
        _layer = layer;
    }
    return self;
}

@end

@implementation TGStoredOutgoingMessageSecretAction

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer keyId:(int64_t)keyId data:(NSData *)data fileInfo:(TGStoredOutgoingMessageFileInfo *)fileInfo
{
    self = [super init];
    if (self != nil)
    {
        _randomId = randomId;
        _layer = layer;
        _keyId = keyId;
        _data = data;
        _fileInfo = fileInfo;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithRandomId:[coder decodeInt64ForCKey:"randomId"] layer:(NSUInteger)[coder decodeInt32ForCKey:"layer"] keyId:[coder decodeInt64ForCKey:"keyId"] data:[coder decodeDataCorCKey:"data"] fileInfo:[coder decodeObjectForCKey:"fileInfo"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_randomId forCKey:"randomId"];
    [coder encodeInt32:(int32_t)_layer forCKey:"layer"];
    [coder encodeInt64:_keyId forCKey:"keyId"];
    [coder encodeData:_data forCKey:"data"];
    [coder encodeObject:_fileInfo forCKey:"fileInfo"];
}

@end

@implementation TGStoredOutgoingServiceMessageSecretAction

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer keyId:(int64_t)keyId data:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _randomId = randomId;
        _layer = layer;
        _keyId = keyId;
        _data = data;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithRandomId:[coder decodeInt64ForCKey:"randomId"] layer:(NSUInteger)[coder decodeInt32ForCKey:"layer"] keyId:[coder decodeInt64ForCKey:"keyId"] data:[coder decodeDataCorCKey:"data"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_randomId forCKey:"randomId"];
    [coder encodeInt32:(int32_t)_layer forCKey:"layer"];
    [coder encodeInt64:_keyId forCKey:"keyId"];
    [coder encodeData:_data forCKey:"data"];
}

@end

@implementation TGStoredIncomingMessageSecretAction

- (instancetype)initWithLayer:(NSUInteger)layer data:(NSData *)data date:(int32_t)date fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo
{
    self = [super init];
    if (self != nil)
    {
        _layer = layer;
        _data = data;
        _date = date;
        _fileInfo = fileInfo;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithLayer:(NSUInteger)[coder decodeInt32ForCKey:"layer"] data:[coder decodeDataCorCKey:"data"] date:[coder decodeInt32ForCKey:"date"] fileInfo:[coder decodeObjectForCKey:"fileInfo"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:(int32_t)_layer forCKey:"layer"];
    [coder encodeData:_data forCKey:"data"];
    [coder encodeInt32:_date forCKey:"date"];
    [coder encodeObject:_fileInfo forCKey:"fileInfo"];
}

@end

@implementation TGStoredIncomingEncryptedDataSecretAction

- (instancetype)initWithKeyId:(int64_t)keyId randomId:(int64_t)randomId chatId:(int32_t)chatId date:(int32_t)date encryptedData:(NSData *)encryptedData fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo
{
    self = [super init];
    if (self != nil)
    {
        _keyId = keyId;
        _randomId = randomId;
        _chatId = chatId;
        _date = date;
        _encryptedData = encryptedData;
        _fileInfo = fileInfo;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithKeyId:[coder decodeInt64ForCKey:"keyId"] randomId:[coder decodeInt64ForCKey:"randomId"] chatId:[coder decodeInt32ForCKey:"chatId"] date:[coder decodeInt32ForCKey:"date"] encryptedData:[coder decodeDataCorCKey:"encryptedData"] fileInfo:[coder decodeObjectForCKey:"fileInfo"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_keyId forCKey:"keyId"];
    [coder encodeInt64:_randomId forCKey:"randomId"];
    [coder encodeInt32:_chatId forCKey:"chatId"];
    [coder encodeInt32:_date forCKey:"date"];
    [coder encodeData:_encryptedData forCKey:"encryptedData"];
    [coder encodeObject:_fileInfo forCKey:"fileInfo"];
}

@end

@implementation TGStoredIncomingEncryptedDataSecretActionWithActionId

- (instancetype)initWithActionId:(int32_t)actionId action:(TGStoredIncomingEncryptedDataSecretAction *)action
{
    self = [super init];
    if (self != nil)
    {
        _actionId = actionId;
        _action = action;
    }
    return self;
}

@end
