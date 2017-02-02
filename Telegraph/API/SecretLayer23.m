#import "SecretLayer23.h"
#import <objc/runtime.h>

static const char *Secret23__Serializer_Key = "Secret23__Serializer";

@interface Secret23__Number : NSNumber
{
    NSNumber *_value;
}

@end

@implementation Secret23__Number

- (instancetype)initWithNumber:(NSNumber *)number
{
    self = [super init];
    if (self != nil)
    {
        _value = number;
    }
    return self;
}

- (char)charValue
{
    return [_value charValue];
}

- (unsigned char)unsignedCharValue
{
    return [_value unsignedCharValue];
}

- (short)shortValue
{
    return [_value shortValue];
}

- (unsigned short)unsignedShortValue
{
    return [_value unsignedShortValue];
}

- (int)intValue
{
    return [_value intValue];
}

- (unsigned int)unsignedIntValue
{
    return [_value unsignedIntValue];
}

- (long)longValue
{
    return [_value longValue];
}

- (unsigned long)unsignedLongValue
{
    return [_value unsignedLongValue];
}

- (long long)longLongValue
{
    return [_value longLongValue];
}

- (unsigned long long)unsignedLongLongValue
{
    return [_value unsignedLongLongValue];
}

- (float)floatValue
{
    return [_value floatValue];
}

- (double)doubleValue
{
    return [_value doubleValue];
}

- (BOOL)boolValue
{
    return [_value boolValue];
}

- (NSInteger)integerValue
{
    return [_value integerValue];
}

- (NSUInteger)unsignedIntegerValue
{
    return [_value unsignedIntegerValue];
}

- (NSString *)stringValue
{
    return [_value stringValue];
}

- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
    return [_value compare:otherNumber];
}

- (BOOL)isEqualToNumber:(NSNumber *)number
{
    return [_value isEqualToNumber:number];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [_value descriptionWithLocale:locale];
}

- (void)getValue:(void *)value
{
    [_value getValue:value];
}

- (const char *)objCType
{
    return [_value objCType];
}

- (NSUInteger)hash
{
    return [_value hash];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end

@interface Secret23__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret23__Serializer

- (instancetype)initWithConstructorSignature:(int32_t)constructorSignature serializeBlock:(bool (^)(id, NSMutableData *))serializeBlock
{
    self = [super init];
    if (self != nil)
    {
        self.constructorSignature = constructorSignature;
        self.serializeBlock = serializeBlock;
    }
    return self;
}

+ (id)addSerializerToObject:(id)object withConstructorSignature:(int32_t)constructorSignature serializeBlock:(bool (^)(id, NSMutableData *))serializeBlock
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret23__Serializer_Key, [[Secret23__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret23__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret23__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret23__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret23__UnboxedTypeMetaInfo

- (instancetype)initWithConstructorSignature:(int32_t)constructorSignature
{
    self = [super init];
    if (self != nil)
    {
        _constructorSignature = constructorSignature;
    }
    return self;
}

@end

@interface Secret23__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret23__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret23__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret23__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret23__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret23__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret23__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret23__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret23__Environment

+ (id (^)(NSData *data, NSUInteger *offset, id metaInfo))parserByConstructorSignature:(int32_t)constructorSignature
{
    static NSMutableDictionary *parsers = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        parsers = [[NSMutableDictionary alloc] init];

        parsers[@((int32_t)0xA8509BDA)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 4 > data.length)
                return nil;
            int32_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 4)];
            *offset += 4;
            return @(value);
        } copy];

        parsers[@((int32_t)0x22076CBA)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 8 > data.length)
                return nil;
            int64_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0x2210C154)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 8 > data.length)
                return nil;
            double value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0xB5286E24)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 1 > data.length)
                return nil;
            uint8_t tmp = 0;
            [data getBytes:(void *)&tmp range:NSMakeRange(*offset, 1)];
            *offset += 1;

            int paddingBytes = 0;

            int32_t length = tmp;
            if (length == 254)
            {
                length = 0;
                if (*offset + 3 > data.length)
                    return nil;
                [data getBytes:((uint8_t *)&length) + 1 range:NSMakeRange(*offset, 3)];
                *offset += 3;
                length >>= 8;

                paddingBytes = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
            }
            else
                paddingBytes = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);

            bool isData = [metaInfo isKindOfClass:[Secret23__PreferNSDataTypeMetaInfo class]];
            id object = nil;

            if (length > 0)
            {
                if (*offset + length > data.length)
                    return nil;
                if (isData)
                    object = [[NSData alloc] initWithBytes:((uint8_t *)data.bytes) + *offset length:length];
                else
                    object = [[NSString alloc] initWithBytes:((uint8_t *)data.bytes) + *offset length:length encoding:NSUTF8StringEncoding];

                *offset += length;
            }

            *offset += paddingBytes;

            return object == nil ? (isData ? [NSData data] : @"") : object;
        } copy];

        parsers[@((int32_t)0x1cb5c415)] = [^id (NSData *data, NSUInteger *offset, id metaInfo)
        {
            if (*offset + 4 > data.length)
                return nil;

            int32_t count = 0;
            [data getBytes:(void *)&count range:NSMakeRange(*offset, 4)];
            *offset += 4;

            if (count < 0)
                return nil;

            bool isBoxed = false;
            int32_t unboxedConstructorSignature = 0;
            if ([metaInfo isKindOfClass:[Secret23__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret23__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret23__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
            else
                return nil;

            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
            for (int32_t i = 0; i < count; i++)
            {
                int32_t itemConstructorSignature = 0;
                if (isBoxed)
                {
                    if (*offset + 4 > data.length)
                        return nil;
                    [data getBytes:(void *)&itemConstructorSignature range:NSMakeRange(*offset, 4)];
                    *offset += 4;
                }
                else
                    itemConstructorSignature = unboxedConstructorSignature;
                id item = [Secret23__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttlSeconds = nil;
            if ((ttlSeconds = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:ttlSeconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret23__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret23__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret23__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
        } copy];
        parsers[@((int32_t)0xccb27641)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            Secret23_SendMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret23__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionTypingWithAction:action];
        } copy];
        parsers[@((int32_t)0x511110b0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * startSeqNo = nil;
            if ((startSeqNo = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * endSeqNo = nil;
            if ((endSeqNo = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:startSeqNo endSeqNo:endSeqNo];
        } copy];
        parsers[@((int32_t)0xf3c9611b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gA = nil;
            if ((gA = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:exchangeId gA:gA];
        } copy];
        parsers[@((int32_t)0x6fe1735b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gB = nil;
            if ((gB = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:exchangeId gB:gB keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xec2e0b9b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:exchangeId keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xdd05ec6b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:exchangeId];
        } copy];
        parsers[@((int32_t)0xa82fdd63)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageAction decryptedMessageActionNoop];
        } copy];
        parsers[@((int32_t)0x16bf744e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageTypingAction];
        } copy];
        parsers[@((int32_t)0xfd5ec8f5)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageCancelAction];
        } copy];
        parsers[@((int32_t)0xa187d66f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageRecordVideoAction];
        } copy];
        parsers[@((int32_t)0x92042ff7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadVideoAction];
        } copy];
        parsers[@((int32_t)0xd52f73f7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageRecordAudioAction];
        } copy];
        parsers[@((int32_t)0xe6ac8a6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadAudioAction];
        } copy];
        parsers[@((int32_t)0x990a3c1a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadPhotoAction];
        } copy];
        parsers[@((int32_t)0x8faee98e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadDocumentAction];
        } copy];
        parsers[@((int32_t)0x176f8ba1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageGeoLocationAction];
        } copy];
        parsers[@((int32_t)0x628cbc6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageChooseContactAction];
        } copy];
        parsers[@((int32_t)0xe17e23c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_PhotoSize photoSizeEmptyWithType:type];
        } copy];
        parsers[@((int32_t)0x77bfb61b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret23__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_PhotoSize photoSizeWithType:type location:location w:w h:h size:size];
        } copy];
        parsers[@((int32_t)0xe9a734fa)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret23__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_PhotoSize photoCachedSizeWithType:type location:location w:w h:h bytes:bytes];
        } copy];
        parsers[@((int32_t)0x7c596b46)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_FileLocation fileLocationUnavailableWithVolumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * dcId = nil;
            if ((dcId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_FileLocation fileLocationWithDcId:dcId volumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x1be31789)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * randomBytes = nil;
            if ((randomBytes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * layer = nil;
            if ((layer = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * inSeqNo = nil;
            if ((inSeqNo = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * outSeqNo = nil;
            if ((outSeqNo = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret23__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandomBytes:randomBytes layer:layer inSeqNo:inSeqNo outSeqNo:outSeqNo message:message];
        } copy];
        parsers[@((int32_t)0x204d3878)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * ttl = nil;
            if ((ttl = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret23__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessage decryptedMessageWithRandomId:randomId ttl:ttl message:message media:media];
        } copy];
        parsers[@((int32_t)0x73164160)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret23__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:randomId action:action];
        } copy];
        parsers[@((int32_t)0x6c37c15c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeImageSizeWithW:w h:h];
        } copy];
        parsers[@((int32_t)0x11b58939)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DocumentAttribute documentAttributeAnimated];
        } copy];
        parsers[@((int32_t)0xfb0a5727)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DocumentAttribute documentAttributeSticker];
        } copy];
        parsers[@((int32_t)0x5910cccb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeVideoWithDuration:duration w:w h:h];
        } copy];
        parsers[@((int32_t)0x51448e5)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeAudioWithDuration:duration];
        } copy];
        parsers[@((int32_t)0x15590068)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * fileName = nil;
            if ((fileName = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeFilenameWithFileName:fileName];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumbW:thumbW thumbH:thumbH w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phoneNumber = nil;
            if ((phoneNumber = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * firstName = nil;
            if ((firstName = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * lastName = nil;
            if ((lastName = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * userId = nil;
            if ((userId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaContactWithPhoneNumber:phoneNumber firstName:firstName lastName:lastName userId:userId];
        } copy];
        parsers[@((int32_t)0xb095434b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * fileName = nil;
            if ((fileName = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumbW:thumbW thumbH:thumbH fileName:fileName mimeType:mimeType size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x524a415d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumbW:thumbW thumbH:thumbH duration:duration mimeType:mimeType w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mimeType:mimeType size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xfa95b0dd)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * pid = nil;
            if ((pid = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * accessHash = nil;
            if ((accessHash = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret23_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:thumb_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * dcId = nil;
            if ((dcId = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret23__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:pid accessHash:accessHash date:date mimeType:mimeType size:size thumb:thumb dcId:dcId attributes:attributes];
        } copy];
});

    return parsers[@(constructorSignature)];
}

+ (NSData *)serializeObject:(id)object
{
    NSMutableData *data = [[NSMutableData alloc] init];
    if ([self serializeObject:object data:data addSignature:true])
        return data;
    return nil;
}

+ (bool)serializeObject:(id)object data:(NSMutableData *)data addSignature:(bool)addSignature
{
     Secret23__Serializer *serializer = objc_getAssociatedObject(object, Secret23__Serializer_Key);
     if (serializer == nil)
         return false;
     if (addSignature)
     {
         int32_t value = serializer.constructorSignature;
         [data appendBytes:(void *)&value length:4];
     }
     return serializer.serializeBlock(object, data);
}

+ (id)parseObject:(NSData *)data
{
    if (data.length < 4)
        return nil;
    int32_t constructorSignature = 0;
    [data getBytes:(void *)&constructorSignature length:4];
    NSUInteger offset = 4;
    return [self parseObject:data offset:&offset implicitSignature:constructorSignature metaInfo:nil];
}

+ (id)parseObject:(NSData *)data offset:(NSUInteger *)offset implicitSignature:(int32_t)implicitSignature metaInfo:(id)metaInfo
{
    id (^parser)(NSData *data, NSUInteger *offset, id metaInfo) = [self parserByConstructorSignature:implicitSignature];
    if (parser)
        return parser(data, offset, metaInfo);
    return nil;
}

@end

@interface Secret23_BuiltinSerializer_Int : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xA8509BDA serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        int32_t value = (int32_t)[object intValue];
        [data appendBytes:(void *)&value length:4];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Long : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Long

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x22076CBA serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        int64_t value = (int64_t)[object longLongValue];
        [data appendBytes:(void *)&value length:8];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Double : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Double

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x2210C154 serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        double value = (double)[object doubleValue];
        [data appendBytes:(void *)&value length:8];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_String : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_String

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSString *object, NSMutableData *data)
    {
        NSData *value = [object dataUsingEncoding:NSUTF8StringEncoding];
        int32_t length = (int32_t)value.length;
        int32_t padding = 0;
        if (length >= 254)
        {
            uint8_t tmp = 254;
            [data appendBytes:&tmp length:1];
            [data appendBytes:(void *)&length length:3];
            padding = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
        }
        else
        {
            [data appendBytes:(void *)&length length:1];
            padding = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);
        }
        [data appendData:value];
        for (int i = 0; i < padding; i++)
        {
            uint8_t tmp = 0;
            [data appendBytes:(void *)&tmp length:1];
        }

        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Bytes : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Bytes

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        NSData *value = object;
        int32_t length = (int32_t)value.length;
        int32_t padding = 0;
        if (length >= 254)
        {
            uint8_t tmp = 254;
            [data appendBytes:&tmp length:1];
            [data appendBytes:(void *)&length length:3];
            padding = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
        }
        else
        {
            [data appendBytes:(void *)&length length:1];
            padding = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);
        }
        [data appendData:value];
        for (int i = 0; i < padding; i++)
        {
            uint8_t tmp = 0;
            [data appendBytes:(void *)&tmp length:1];
        }

        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Int128 : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int128

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x4BB5362B serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        if (object.length != 16)
            return false;
        [data appendData:object];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Int256 : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int256

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x0929C32F serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        if (object.length != 32)
            return false;
        [data appendData:object];
        return true;
    }];
}

@end



@implementation Secret23_FunctionContext

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata
{
    self = [super init];
    if (self != nil)
    {
        _payload = payload;
        _responseParser = [responseParser copy];
        _metadata = metadata;
    }
    return self;
}

@end

@interface Secret23_DecryptedMessageAction ()

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttlSeconds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionTyping ()

@property (nonatomic, strong) Secret23_SendMessageAction * action;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionResend ()

@property (nonatomic, strong) NSNumber * startSeqNo;
@property (nonatomic, strong) NSNumber * endSeqNo;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gA;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gB;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey ()

@property (nonatomic, strong) NSNumber * exchangeId;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNoop ()

@end

@implementation Secret23_DecryptedMessageAction

+ (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds
{
    Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttlSeconds = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:ttlSeconds] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret23__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret23__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret23__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:layer] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret23_SendMessageAction *)action
{
    Secret23_DecryptedMessageAction_decryptedMessageActionTyping *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionTyping alloc] init];
    _object.action = action;
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo
{
    Secret23_DecryptedMessageAction_decryptedMessageActionResend *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionResend alloc] init];
    _object.startSeqNo = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:startSeqNo] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.endSeqNo = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:endSeqNo] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA
{
    Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey alloc] init];
    _object.exchangeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:exchangeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.gA = [Secret23__Serializer addSerializerToObject:[gA copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey alloc] init];
    _object.exchangeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:exchangeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.gB = [Secret23__Serializer addSerializerToObject:[gB copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.keyFingerprint = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey alloc] init];
    _object.exchangeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:exchangeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.keyFingerprint = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId
{
    Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey alloc] init];
    _object.exchangeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:exchangeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop
{
    Secret23_DecryptedMessageAction_decryptedMessageActionNoop *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionNoop alloc] init];
    return _object;
}


@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.ttlSeconds data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionSetMessageTTL ttl_seconds:%@)", self.ttlSeconds];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionReadMessages random_ids:%@)", self.randomIds];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionDeleteMessages random_ids:%@)", self.randomIds];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionScreenshotMessages random_ids:%@)", self.randomIds];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionFlushHistory)"];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionNotifyLayer layer:%@)", self.layer];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xccb27641 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionTyping action:%@)", self.action];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionResend

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x511110b0 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionResend *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.startSeqNo data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.endSeqNo data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionResend start_seq_no:%@ end_seq_no:%@)", self.startSeqNo, self.endSeqNo];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xf3c9611b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.gA data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionRequestKey exchange_id:%@ g_a:%d)", self.exchangeId, (int)[self.gA length]];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6fe1735b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.gB data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAcceptKey exchange_id:%@ g_b:%d key_fingerprint:%@)", self.exchangeId, (int)[self.gB length], self.keyFingerprint];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xec2e0b9b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionCommitKey exchange_id:%@ key_fingerprint:%@)", self.exchangeId, self.keyFingerprint];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xdd05ec6b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAbortKey exchange_id:%@)", self.exchangeId];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionNoop

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa82fdd63 serializeBlock:^bool (__unused Secret23_DecryptedMessageAction_decryptedMessageActionNoop *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionNoop)"];
}

@end




@interface Secret23_SendMessageAction ()

@end

@interface Secret23_SendMessageAction_sendMessageTypingAction ()

@end

@interface Secret23_SendMessageAction_sendMessageCancelAction ()

@end

@interface Secret23_SendMessageAction_sendMessageRecordVideoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadVideoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageRecordAudioAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadAudioAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadPhotoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadDocumentAction ()

@end

@interface Secret23_SendMessageAction_sendMessageGeoLocationAction ()

@end

@interface Secret23_SendMessageAction_sendMessageChooseContactAction ()

@end

@implementation Secret23_SendMessageAction

+ (Secret23_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction
{
    Secret23_SendMessageAction_sendMessageTypingAction *_object = [[Secret23_SendMessageAction_sendMessageTypingAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction
{
    Secret23_SendMessageAction_sendMessageCancelAction *_object = [[Secret23_SendMessageAction_sendMessageCancelAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction
{
    Secret23_SendMessageAction_sendMessageRecordVideoAction *_object = [[Secret23_SendMessageAction_sendMessageRecordVideoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction
{
    Secret23_SendMessageAction_sendMessageUploadVideoAction *_object = [[Secret23_SendMessageAction_sendMessageUploadVideoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction
{
    Secret23_SendMessageAction_sendMessageRecordAudioAction *_object = [[Secret23_SendMessageAction_sendMessageRecordAudioAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction
{
    Secret23_SendMessageAction_sendMessageUploadAudioAction *_object = [[Secret23_SendMessageAction_sendMessageUploadAudioAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction
{
    Secret23_SendMessageAction_sendMessageUploadPhotoAction *_object = [[Secret23_SendMessageAction_sendMessageUploadPhotoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction
{
    Secret23_SendMessageAction_sendMessageUploadDocumentAction *_object = [[Secret23_SendMessageAction_sendMessageUploadDocumentAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction
{
    Secret23_SendMessageAction_sendMessageGeoLocationAction *_object = [[Secret23_SendMessageAction_sendMessageGeoLocationAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction
{
    Secret23_SendMessageAction_sendMessageChooseContactAction *_object = [[Secret23_SendMessageAction_sendMessageChooseContactAction alloc] init];
    return _object;
}


@end

@implementation Secret23_SendMessageAction_sendMessageTypingAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x16bf744e serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageTypingAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageTypingAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageCancelAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfd5ec8f5 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageCancelAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageCancelAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageRecordVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa187d66f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageRecordVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageRecordVideoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x92042ff7 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadVideoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageRecordAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xd52f73f7 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageRecordAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageRecordAudioAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe6ac8a6f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadAudioAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadPhotoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x990a3c1a serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadPhotoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadPhotoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadDocumentAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x8faee98e serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadDocumentAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadDocumentAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageGeoLocationAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x176f8ba1 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageGeoLocationAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageGeoLocationAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageChooseContactAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x628cbc6f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageChooseContactAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageChooseContactAction)"];
}

@end




@interface Secret23_PhotoSize ()

@property (nonatomic, strong) NSString * type;

@end

@interface Secret23_PhotoSize_photoSizeEmpty ()

@end

@interface Secret23_PhotoSize_photoSize ()

@property (nonatomic, strong) Secret23_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;

@end

@interface Secret23_PhotoSize_photoCachedSize ()

@property (nonatomic, strong) Secret23_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSData * bytes;

@end

@implementation Secret23_PhotoSize

+ (Secret23_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type
{
    Secret23_PhotoSize_photoSizeEmpty *_object = [[Secret23_PhotoSize_photoSizeEmpty alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret23_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size
{
    Secret23_PhotoSize_photoSize *_object = [[Secret23_PhotoSize_photoSize alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes
{
    Secret23_PhotoSize_photoCachedSize *_object = [[Secret23_PhotoSize_photoCachedSize alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [Secret23__Serializer addSerializerToObject:[bytes copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret23_PhotoSize_photoSizeEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe17e23c serializeBlock:^bool (Secret23_PhotoSize_photoSizeEmpty *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSizeEmpty type:%d)", (int)[self.type length]];
}

@end

@implementation Secret23_PhotoSize_photoSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x77bfb61b serializeBlock:^bool (Secret23_PhotoSize_photoSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSize type:%d location:%@ w:%@ h:%@ size:%@)", (int)[self.type length], self.location, self.w, self.h, self.size];
}

@end

@implementation Secret23_PhotoSize_photoCachedSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe9a734fa serializeBlock:^bool (Secret23_PhotoSize_photoCachedSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoCachedSize type:%d location:%@ w:%@ h:%@ bytes:%d)", (int)[self.type length], self.location, self.w, self.h, (int)[self.bytes length]];
}

@end




@interface Secret23_FileLocation ()

@property (nonatomic, strong) NSNumber * volumeId;
@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface Secret23_FileLocation_fileLocationUnavailable ()

@end

@interface Secret23_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dcId;

@end

@implementation Secret23_FileLocation

+ (Secret23_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret23_FileLocation_fileLocationUnavailable *_object = [[Secret23_FileLocation_fileLocationUnavailable alloc] init];
    _object.volumeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:volumeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:localId] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:secret] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret23_FileLocation_fileLocation *_object = [[Secret23_FileLocation_fileLocation alloc] init];
    _object.dcId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:dcId] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.volumeId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:volumeId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:localId] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:secret] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret23_FileLocation_fileLocationUnavailable

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x7c596b46 serializeBlock:^bool (Secret23_FileLocation_fileLocationUnavailable *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.localId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(fileLocationUnavailable volume_id:%@ local_id:%@ secret:%@)", self.volumeId, self.localId, self.secret];
}

@end

@implementation Secret23_FileLocation_fileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x53d69076 serializeBlock:^bool (Secret23_FileLocation_fileLocation *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.dcId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.localId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(fileLocation dc_id:%@ volume_id:%@ local_id:%@ secret:%@)", self.dcId, self.volumeId, self.localId, self.secret];
}

@end




@interface Secret23_DecryptedMessageLayer ()

@property (nonatomic, strong) NSData * randomBytes;
@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) NSNumber * inSeqNo;
@property (nonatomic, strong) NSNumber * outSeqNo;
@property (nonatomic, strong) Secret23_DecryptedMessage * message;

@end

@interface Secret23_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret23_DecryptedMessageLayer

+ (Secret23_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret23_DecryptedMessage *)message
{
    Secret23_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret23_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.randomBytes = [Secret23__Serializer addSerializerToObject:[randomBytes copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.layer = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:layer] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.inSeqNo = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:inSeqNo] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.outSeqNo = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:outSeqNo] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret23_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x1be31789 serializeBlock:^bool (Secret23_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomBytes data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.inSeqNo data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.outSeqNo data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageLayer random_bytes:%d layer:%@ in_seq_no:%@ out_seq_no:%@ message:%@)", (int)[self.randomBytes length], self.layer, self.inSeqNo, self.outSeqNo, self.message];
}

@end




@interface Secret23_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * randomId;

@end

@interface Secret23_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSNumber * ttl;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret23_DecryptedMessageMedia * media;

@end

@interface Secret23_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret23_DecryptedMessageAction * action;

@end

@implementation Secret23_DecryptedMessage

+ (Secret23_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret23_DecryptedMessageMedia *)media
{
    Secret23_DecryptedMessage_decryptedMessage *_object = [[Secret23_DecryptedMessage_decryptedMessage alloc] init];
    _object.randomId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:randomId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.ttl = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:ttl] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.message = [Secret23__Serializer addSerializerToObject:[message copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (Secret23_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret23_DecryptedMessageAction *)action
{
    Secret23_DecryptedMessage_decryptedMessageService *_object = [[Secret23_DecryptedMessage_decryptedMessageService alloc] init];
    _object.randomId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:randomId] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation Secret23_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x204d3878 serializeBlock:^bool (Secret23_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.ttl data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage random_id:%@ ttl:%@ message:%d media:%@)", self.randomId, self.ttl, (int)[self.message length], self.media];
}

@end

@implementation Secret23_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x73164160 serializeBlock:^bool (Secret23_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageService random_id:%@ action:%@)", self.randomId, self.action];
}

@end




@interface Secret23_DocumentAttribute ()

@end

@interface Secret23_DocumentAttribute_documentAttributeImageSize ()

@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAnimated ()

@end

@interface Secret23_DocumentAttribute_documentAttributeSticker ()

@end

@interface Secret23_DocumentAttribute_documentAttributeVideo ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAudio ()

@property (nonatomic, strong) NSNumber * duration;

@end

@interface Secret23_DocumentAttribute_documentAttributeFilename ()

@property (nonatomic, strong) NSString * fileName;

@end

@implementation Secret23_DocumentAttribute

+ (Secret23_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h
{
    Secret23_DocumentAttribute_documentAttributeImageSize *_object = [[Secret23_DocumentAttribute_documentAttributeImageSize alloc] init];
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated
{
    Secret23_DocumentAttribute_documentAttributeAnimated *_object = [[Secret23_DocumentAttribute_documentAttributeAnimated alloc] init];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeSticker *)documentAttributeSticker
{
    Secret23_DocumentAttribute_documentAttributeSticker *_object = [[Secret23_DocumentAttribute_documentAttributeSticker alloc] init];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h
{
    Secret23_DocumentAttribute_documentAttributeVideo *_object = [[Secret23_DocumentAttribute_documentAttributeVideo alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:duration] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration
{
    Secret23_DocumentAttribute_documentAttributeAudio *_object = [[Secret23_DocumentAttribute_documentAttributeAudio alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:duration] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName
{
    Secret23_DocumentAttribute_documentAttributeFilename *_object = [[Secret23_DocumentAttribute_documentAttributeFilename alloc] init];
    _object.fileName = [Secret23__Serializer addSerializerToObject:[fileName copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret23_DocumentAttribute_documentAttributeImageSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6c37c15c serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeImageSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeImageSize w:%@ h:%@)", self.w, self.h];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeAnimated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x11b58939 serializeBlock:^bool (__unused Secret23_DocumentAttribute_documentAttributeAnimated *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAnimated)"];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeSticker

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfb0a5727 serializeBlock:^bool (__unused Secret23_DocumentAttribute_documentAttributeSticker *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeSticker)"];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x5910cccb serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeVideo *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeVideo duration:%@ w:%@ h:%@)", self.duration, self.w, self.h];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x51448e5 serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeAudio *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAudio duration:%@)", self.duration];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeFilename

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x15590068 serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeFilename *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.fileName data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeFilename file_name:%d)", (int)[self.fileName length]];
}

@end




@interface Secret23_DecryptedMessageMedia ()

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSNumber * userId;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * accessHash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) Secret23_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dcId;
@property (nonatomic, strong) NSArray * attributes;

@end

@implementation Secret23_DecryptedMessageMedia

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbW] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbH] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:lat] serializer:[[Secret23_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:plong] serializer:[[Secret23_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phoneNumber = [Secret23__Serializer addSerializerToObject:[phoneNumber copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.firstName = [Secret23__Serializer addSerializerToObject:[firstName copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.lastName = [Secret23__Serializer addSerializerToObject:[lastName copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.userId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:userId] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbW] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbH] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.fileName = [Secret23__Serializer addSerializerToObject:[fileName copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.mimeType = [Secret23__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbW] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:thumbH] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:duration] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret23__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:w] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:h] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:duration] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret23__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret23_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument alloc] init];
    _object.pid = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:pid] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.accessHash = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:accessHash] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.date = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:date] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret23__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:size] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dcId = [Secret23__Serializer addSerializerToObject:[[Secret23__Number alloc] initWithNumber:dcId] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret23__Serializer addSerializerToObject:attributes_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    return _object;
}


@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaEmpty)"];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%d thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaGeoPoint lat:%@ long:%@)", self.lat, self.plong];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.phoneNumber data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.firstName data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.lastName data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.userId data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaContact phone_number:%d first_name:%d last_name:%d user_id:%@)", (int)[self.phoneNumber length], (int)[self.firstName length], (int)[self.lastName length], self.userId];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xb095434b serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.fileName data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%d thumb_w:%@ thumb_h:%@ file_name:%d mime_type:%d size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, (int)[self.fileName length], (int)[self.mimeType length], self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x524a415d serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%d thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%d w:%@ h:%@ size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.duration, (int)[self.mimeType length], self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x57e0a9cb serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ mime_type:%d size:%@ key:%d iv:%d)", self.duration, (int)[self.mimeType length], self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfa95b0dd serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.accessHash data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.dcId data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.attributes data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaExternalDocument id:%@ access_hash:%@ date:%@ mime_type:%d size:%@ thumb:%@ dc_id:%@ attributes:%@)", self.pid, self.accessHash, self.date, (int)[self.mimeType length], self.size, self.thumb, self.dcId, self.attributes];
}

@end




@implementation Secret23: NSObject

@end
