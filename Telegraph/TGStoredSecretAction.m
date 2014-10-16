#import "TGStoredSecretAction.h"

#import "PSKeyValueCoder.h"

@implementation TGStoredSecretActionWithSeq

- (instancetype)initWithActionId:(int32_t)actionId action:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut
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

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer data:(NSData *)data fileInfo:(TGStoredOutgoingMessageFileInfo *)fileInfo
{
    self = [super init];
    if (self != nil)
    {
        _randomId = randomId;
        _layer = layer;
        _data = data;
        _fileInfo = fileInfo;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithRandomId:[coder decodeInt64ForCKey:"randomId"] layer:(NSUInteger)[coder decodeInt32ForCKey:"layer"] data:[coder decodeDataCorCKey:"data"] fileInfo:[coder decodeObjectForCKey:"fileInfo"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_randomId forCKey:"randomId"];
    [coder encodeInt32:(int32_t)_layer forCKey:"layer"];
    [coder encodeData:_data forCKey:"data"];
    [coder encodeObject:_fileInfo forCKey:"fileInfo"];
}

@end

@implementation TGStoredOutgoingServiceMessageSecretAction

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer data:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _randomId = randomId;
        _layer = layer;
        _data = data;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithRandomId:[coder decodeInt64ForCKey:"randomId"] layer:(NSUInteger)[coder decodeInt32ForCKey:"layer"] data:[coder decodeDataCorCKey:"data"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_randomId forCKey:"randomId"];
    [coder encodeInt32:(int32_t)_layer forCKey:"layer"];
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
