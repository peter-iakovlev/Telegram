#import "SecretLayer73.h"
#import <objc/runtime.h>

static const char *Secret73__Serializer_Key = "Secret73__Serializer";

@interface Secret73__Number : NSNumber
{
    NSNumber *_value;
}

@end

@implementation Secret73__Number

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

@interface Secret73__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret73__Serializer

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
        objc_setAssociatedObject(object, Secret73__Serializer_Key, [[Secret73__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret73__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret73__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret73__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret73__UnboxedTypeMetaInfo

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

@interface Secret73__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret73__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret73__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret73__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret73__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret73__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret73__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret73__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret73__Environment

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

            bool isData = [metaInfo isKindOfClass:[Secret73__PreferNSDataTypeMetaInfo class]];
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
            if ([metaInfo isKindOfClass:[Secret73__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret73__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret73__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
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
                id item = [Secret73__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttlSeconds = nil;
            if ((ttlSeconds = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:ttlSeconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [_data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret73__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [_data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret73__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [_data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret73__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *_data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret73_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
        } copy];
        parsers[@((int32_t)0x511110b0)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * startSeqNo = nil;
            if ((startSeqNo = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * endSeqNo = nil;
            if ((endSeqNo = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:startSeqNo endSeqNo:endSeqNo];
        } copy];
        parsers[@((int32_t)0xf3c9611b)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gA = nil;
            if ((gA = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:exchangeId gA:gA];
        } copy];
        parsers[@((int32_t)0x6fe1735b)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gB = nil;
            if ((gB = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:exchangeId gB:gB keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xdd05ec6b)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:exchangeId];
        } copy];
        parsers[@((int32_t)0xec2e0b9b)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:exchangeId keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xa82fdd63)] = [^id (__unused NSData *_data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret73_DecryptedMessageAction decryptedMessageActionNoop];
        } copy];
        parsers[@((int32_t)0xe17e23c)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_PhotoSize photoSizeEmptyWithType:type];
        } copy];
        parsers[@((int32_t)0x77bfb61b)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret73_FileLocation * location = nil;
            int32_t location_signature = 0; [_data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_PhotoSize photoSizeWithType:type location:location w:w h:h size:size];
        } copy];
        parsers[@((int32_t)0xe9a734fa)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret73_FileLocation * location = nil;
            int32_t location_signature = 0; [_data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret73_PhotoSize photoCachedSizeWithType:type location:location w:w h:h bytes:bytes];
        } copy];
        parsers[@((int32_t)0x7c596b46)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret73_FileLocation fileLocationUnavailableWithVolumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * dcId = nil;
            if ((dcId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret73_FileLocation fileLocationWithDcId:dcId volumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x1be31789)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * randomBytes = nil;
            if ((randomBytes = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * layer = nil;
            if ((layer = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * inSeqNo = nil;
            if ((inSeqNo = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * outSeqNo = nil;
            if ((outSeqNo = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret73_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [_data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageLayer decryptedMessageLayerWithRandomBytes:randomBytes layer:layer inSeqNo:inSeqNo outSeqNo:outSeqNo message:message];
        } copy];
        parsers[@((int32_t)0x73164160)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            Secret73_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [_data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessage decryptedMessageServiceWithRandomId:randomId action:action];
        } copy];
        parsers[@((int32_t)0x91cc4674)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * flags = nil;
            if ((flags = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * randomId = nil;
            if ((randomId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * ttl = nil;
            if ((ttl = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret73_DecryptedMessageMedia * media = nil;
            if (flags != nil && ([flags intValue] & (1 << 9))) {
            int32_t media_signature = 0; [_data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            }
            NSArray * entities = nil;
            if (flags != nil && ([flags intValue] & (1 << 7))) {
            int32_t entities_signature = 0; [_data getBytes:(void *)&entities_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((entities = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:entities_signature metaInfo:[Secret73__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            }
            NSString * viaBotName = nil;
            if (flags != nil && ([flags intValue] & (1 << 11))) {
            if ((viaBotName = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            }
            NSNumber * replyToRandomId = nil;
            if (flags != nil && ([flags intValue] & (1 << 3))) {
            if ((replyToRandomId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            }
            NSNumber * groupedId = nil;
            if (flags != nil && ([flags intValue] & (1 << 17))) {
            if ((groupedId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            }
            return [Secret73_DecryptedMessage decryptedMessageWithFlags:flags randomId:randomId ttl:ttl message:message media:media entities:entities viaBotName:viaBotName replyToRandomId:replyToRandomId groupedId:groupedId];
        } copy];
        parsers[@((int32_t)0x6c37c15c)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DocumentAttribute documentAttributeImageSizeWithW:w h:h];
        } copy];
        parsers[@((int32_t)0x11b58939)] = [^id (__unused NSData *_data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret73_DocumentAttribute documentAttributeAnimated];
        } copy];
        parsers[@((int32_t)0x15590068)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * fileName = nil;
            if ((fileName = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DocumentAttribute documentAttributeFilenameWithFileName:fileName];
        } copy];
        parsers[@((int32_t)0x3a556302)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * alt = nil;
            if ((alt = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret73_InputStickerSet * stickerset = nil;
            int32_t stickerset_signature = 0; [_data getBytes:(void *)&stickerset_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((stickerset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:stickerset_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DocumentAttribute documentAttributeStickerWithAlt:alt stickerset:stickerset];
        } copy];
        parsers[@((int32_t)0x9852f9c6)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * flags = nil;
            if ((flags = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * title = nil;
            if (flags != nil && ([flags intValue] & (1 << 0))) {
            if ((title = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            }
            NSString * performer = nil;
            if (flags != nil && ([flags intValue] & (1 << 1))) {
            if ((performer = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            }
            NSData * waveform = nil;
            if (flags != nil && ([flags intValue] & (1 << 2))) {
            if ((waveform = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            }
            return [Secret73_DocumentAttribute documentAttributeAudioWithFlags:flags duration:duration title:title performer:performer waveform:waveform];
        } copy];
        parsers[@((int32_t)0xef02ce6)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * flags = nil;
            if ((flags = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DocumentAttribute documentAttributeVideoWithFlags:flags duration:duration w:w h:h];
        } copy];
        parsers[@((int32_t)0x861cc8a0)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * shortName = nil;
            if ((shortName = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
        } copy];
        parsers[@((int32_t)0xffb62b95)] = [^id (__unused NSData *_data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret73_InputStickerSet inputStickerSetEmpty];
        } copy];
        parsers[@((int32_t)0xbb92ba95)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityUnknownWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0xfa04579d)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityMentionWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6f635b0d)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityHashtagWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6cef8ac7)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityBotCommandWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6ed02538)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityUrlWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x64e475c2)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityEmailWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0xbd610bc9)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityBoldWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x826f8b60)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityItalicWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x28a20571)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityCodeWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x73924be0)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * language = nil;
            if ((language = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityPreWithOffset:offset length:length language:language];
        } copy];
        parsers[@((int32_t)0x76a6d327)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * url = nil;
            if ((url = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_MessageEntity messageEntityTextUrlWithOffset:offset length:length url:url];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *_data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phoneNumber = nil;
            if ((phoneNumber = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * firstName = nil;
            if ((firstName = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * lastName = nil;
            if ((lastName = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * userId = nil;
            if ((userId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaContactWithPhoneNumber:phoneNumber firstName:firstName lastName:lastName userId:userId];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mimeType:mimeType size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xfa95b0dd)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * pid = nil;
            if ((pid = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * accessHash = nil;
            if ((accessHash = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret73_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [_data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:thumb_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * dcId = nil;
            if ((dcId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [_data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret73__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:pid accessHash:accessHash date:date mimeType:mimeType size:size thumb:thumb dcId:dcId attributes:attributes];
        } copy];
        parsers[@((int32_t)0xf1fa8d78)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumbW:thumbW thumbH:thumbH w:w h:h size:size key:key iv:iv caption:caption];
        } copy];
        parsers[@((int32_t)0x7afe8ae2)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [_data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret73__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumbW:thumbW thumbH:thumbH mimeType:mimeType size:size key:key iv:iv attributes:attributes caption:caption];
        } copy];
        parsers[@((int32_t)0x970c8c0e)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret73__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumbW:thumbW thumbH:thumbH duration:duration mimeType:mimeType w:w h:h size:size key:key iv:iv caption:caption];
        } copy];
        parsers[@((int32_t)0x8a0df56f)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * address = nil;
            if ((address = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * provider = nil;
            if ((provider = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * venueId = nil;
            if ((venueId = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaVenueWithLat:lat plong:plong title:title address:address provider:provider venueId:venueId];
        } copy];
        parsers[@((int32_t)0xe50511d8)] = [^id (NSData *_data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * url = nil;
            if ((url = [Secret73__Environment parseObject:_data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret73_DecryptedMessageMedia decryptedMessageMediaWebPageWithUrl:url];
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
     Secret73__Serializer *serializer = objc_getAssociatedObject(object, Secret73__Serializer_Key);
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

@interface Secret73_BuiltinSerializer_Int : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Int

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

@interface Secret73_BuiltinSerializer_Long : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Long

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

@interface Secret73_BuiltinSerializer_Double : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Double

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

@interface Secret73_BuiltinSerializer_String : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_String

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSString *object, NSMutableData *data)
    {
        NSData *value = [object dataUsingEncoding:NSUTF8StringEncoding];
        int32_t length = value.length;
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

@interface Secret73_BuiltinSerializer_Bytes : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Bytes

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

@interface Secret73_BuiltinSerializer_Int128 : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Int128

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

@interface Secret73_BuiltinSerializer_Int256 : Secret73__Serializer
@end

@implementation Secret73_BuiltinSerializer_Int256

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



@implementation Secret73_FunctionContext

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

@interface Secret73_DecryptedMessageAction ()

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttlSeconds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionResend ()

@property (nonatomic, strong) NSNumber * startSeqNo;
@property (nonatomic, strong) NSNumber * endSeqNo;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gA;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gB;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey ()

@property (nonatomic, strong) NSNumber * exchangeId;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionNoop ()

@end

@implementation Secret73_DecryptedMessageAction

+ (Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds
{
    Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttlSeconds = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:ttlSeconds] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret73__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret73__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret73__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:layer] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo
{
    Secret73_DecryptedMessageAction_decryptedMessageActionResend *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionResend alloc] init];
    _object.startSeqNo = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:startSeqNo] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.endSeqNo = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:endSeqNo] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA
{
    Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey alloc] init];
    _object.exchangeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:exchangeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.gA = [Secret73__Serializer addSerializerToObject:[gA copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey alloc] init];
    _object.exchangeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:exchangeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.gB = [Secret73__Serializer addSerializerToObject:[gB copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.keyFingerprint = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId
{
    Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey alloc] init];
    _object.exchangeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:exchangeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey alloc] init];
    _object.exchangeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:exchangeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.keyFingerprint = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop
{
    Secret73_DecryptedMessageAction_decryptedMessageActionNoop *_object = [[Secret73_DecryptedMessageAction_decryptedMessageActionNoop alloc] init];
    return _object;
}


@end

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.ttlSeconds data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.layer data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionResend

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x511110b0 serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionResend *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.startSeqNo data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.endSeqNo data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xf3c9611b serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.gA data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6fe1735b serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.gB data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xdd05ec6b serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.exchangeId data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xec2e0b9b serializeBlock:^bool (Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageAction_decryptedMessageActionNoop

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xa82fdd63 serializeBlock:^bool (__unused Secret73_DecryptedMessageAction_decryptedMessageActionNoop *object, __unused NSMutableData *data)
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




@interface Secret73_PhotoSize ()

@property (nonatomic, strong) NSString * type;

@end

@interface Secret73_PhotoSize_photoSizeEmpty ()

@end

@interface Secret73_PhotoSize_photoSize ()

@property (nonatomic, strong) Secret73_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;

@end

@interface Secret73_PhotoSize_photoCachedSize ()

@property (nonatomic, strong) Secret73_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSData * bytes;

@end

@implementation Secret73_PhotoSize

+ (Secret73_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type
{
    Secret73_PhotoSize_photoSizeEmpty *_object = [[Secret73_PhotoSize_photoSizeEmpty alloc] init];
    _object.type = [Secret73__Serializer addSerializerToObject:[type copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret73_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size
{
    Secret73_PhotoSize_photoSize *_object = [[Secret73_PhotoSize_photoSize alloc] init];
    _object.type = [Secret73__Serializer addSerializerToObject:[type copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret73_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes
{
    Secret73_PhotoSize_photoCachedSize *_object = [[Secret73_PhotoSize_photoCachedSize alloc] init];
    _object.type = [Secret73__Serializer addSerializerToObject:[type copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [Secret73__Serializer addSerializerToObject:[bytes copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret73_PhotoSize_photoSizeEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xe17e23c serializeBlock:^bool (Secret73_PhotoSize_photoSizeEmpty *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.type data:data addSignature:false])
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

@implementation Secret73_PhotoSize_photoSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x77bfb61b serializeBlock:^bool (Secret73_PhotoSize_photoSize *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
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

@implementation Secret73_PhotoSize_photoCachedSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xe9a734fa serializeBlock:^bool (Secret73_PhotoSize_photoCachedSize *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.bytes data:data addSignature:false])
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




@interface Secret73_FileLocation ()

@property (nonatomic, strong) NSNumber * volumeId;
@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface Secret73_FileLocation_fileLocationUnavailable ()

@end

@interface Secret73_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dcId;

@end

@implementation Secret73_FileLocation

+ (Secret73_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret73_FileLocation_fileLocationUnavailable *_object = [[Secret73_FileLocation_fileLocationUnavailable alloc] init];
    _object.volumeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:volumeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:localId] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:secret] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret73_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret73_FileLocation_fileLocation *_object = [[Secret73_FileLocation_fileLocation alloc] init];
    _object.dcId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:dcId] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.volumeId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:volumeId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:localId] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:secret] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret73_FileLocation_fileLocationUnavailable

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x7c596b46 serializeBlock:^bool (Secret73_FileLocation_fileLocationUnavailable *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.localId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.secret data:data addSignature:false])
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

@implementation Secret73_FileLocation_fileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x53d69076 serializeBlock:^bool (Secret73_FileLocation_fileLocation *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.dcId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.localId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.secret data:data addSignature:false])
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




@interface Secret73_DecryptedMessageLayer ()

@property (nonatomic, strong) NSData * randomBytes;
@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) NSNumber * inSeqNo;
@property (nonatomic, strong) NSNumber * outSeqNo;
@property (nonatomic, strong) Secret73_DecryptedMessage * message;

@end

@interface Secret73_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret73_DecryptedMessageLayer

+ (Secret73_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret73_DecryptedMessage *)message
{
    Secret73_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret73_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.randomBytes = [Secret73__Serializer addSerializerToObject:[randomBytes copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.layer = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:layer] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.inSeqNo = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:inSeqNo] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.outSeqNo = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:outSeqNo] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret73_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x1be31789 serializeBlock:^bool (Secret73_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.randomBytes data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.inSeqNo data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.outSeqNo data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.message data:data addSignature:true])
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




@interface Secret73_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * randomId;

@end

@interface Secret73_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret73_DecryptedMessageAction * action;

@end

@interface Secret73_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * ttl;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret73_DecryptedMessageMedia * media;
@property (nonatomic, strong) NSArray * entities;
@property (nonatomic, strong) NSString * viaBotName;
@property (nonatomic, strong) NSNumber * replyToRandomId;
@property (nonatomic, strong) NSNumber * groupedId;

@end

@implementation Secret73_DecryptedMessage

+ (Secret73_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret73_DecryptedMessageAction *)action
{
    Secret73_DecryptedMessage_decryptedMessageService *_object = [[Secret73_DecryptedMessage_decryptedMessageService alloc] init];
    _object.randomId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:randomId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.action = action;
    return _object;
}

+ (Secret73_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret73_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId groupedId:(NSNumber *)groupedId
{
    Secret73_DecryptedMessage_decryptedMessage *_object = [[Secret73_DecryptedMessage_decryptedMessage alloc] init];
    _object.flags = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:flags] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.randomId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:randomId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.ttl = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:ttl] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.message = [Secret73__Serializer addSerializerToObject:[message copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    _object.entities = 
({
NSMutableArray *entities_copy = [[NSMutableArray alloc] initWithCapacity:entities.count];
for (id entities_item in entities)
{
    [entities_copy addObject:entities_item];
}
id entities_result = [Secret73__Serializer addSerializerToObject:entities_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; entities_result;});
    _object.viaBotName = [Secret73__Serializer addSerializerToObject:[viaBotName copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.replyToRandomId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:replyToRandomId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.groupedId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:groupedId] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret73_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x73164160 serializeBlock:^bool (Secret73_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.action data:data addSignature:true])
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

@implementation Secret73_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x91cc4674 serializeBlock:^bool (Secret73_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.ttl data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if ([object.flags intValue] & (1 << 9)) {
            if (![Secret73__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            }
            if ([object.flags intValue] & (1 << 7)) {
            if (![Secret73__Environment serializeObject:object.entities data:data addSignature:true])
                return false;
            }
            if ([object.flags intValue] & (1 << 11)) {
            if (![Secret73__Environment serializeObject:object.viaBotName data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 3)) {
            if (![Secret73__Environment serializeObject:object.replyToRandomId data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 17)) {
            if (![Secret73__Environment serializeObject:object.groupedId data:data addSignature:false])
                return false;
            }
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage flags:%@ random_id:%@ ttl:%@ message:%d media:%@ entities:%@ via_bot_name:%d reply_to_random_id:%@ grouped_id:%@)", self.flags, self.randomId, self.ttl, (int)[self.message length], self.media, self.entities, (int)[self.viaBotName length], self.replyToRandomId, self.groupedId];
}

@end




@interface Secret73_DocumentAttribute ()

@end

@interface Secret73_DocumentAttribute_documentAttributeImageSize ()

@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret73_DocumentAttribute_documentAttributeAnimated ()

@end

@interface Secret73_DocumentAttribute_documentAttributeFilename ()

@property (nonatomic, strong) NSString * fileName;

@end

@interface Secret73_DocumentAttribute_documentAttributeSticker ()

@property (nonatomic, strong) NSString * alt;
@property (nonatomic, strong) Secret73_InputStickerSet * stickerset;

@end

@interface Secret73_DocumentAttribute_documentAttributeAudio ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * performer;
@property (nonatomic, strong) NSData * waveform;

@end

@interface Secret73_DocumentAttribute_documentAttributeVideo ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@implementation Secret73_DocumentAttribute

+ (Secret73_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h
{
    Secret73_DocumentAttribute_documentAttributeImageSize *_object = [[Secret73_DocumentAttribute_documentAttributeImageSize alloc] init];
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated
{
    Secret73_DocumentAttribute_documentAttributeAnimated *_object = [[Secret73_DocumentAttribute_documentAttributeAnimated alloc] init];
    return _object;
}

+ (Secret73_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName
{
    Secret73_DocumentAttribute_documentAttributeFilename *_object = [[Secret73_DocumentAttribute_documentAttributeFilename alloc] init];
    _object.fileName = [Secret73__Serializer addSerializerToObject:[fileName copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret73_InputStickerSet *)stickerset
{
    Secret73_DocumentAttribute_documentAttributeSticker *_object = [[Secret73_DocumentAttribute_documentAttributeSticker alloc] init];
    _object.alt = [Secret73__Serializer addSerializerToObject:[alt copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.stickerset = stickerset;
    return _object;
}

+ (Secret73_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithFlags:(NSNumber *)flags duration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer waveform:(NSData *)waveform
{
    Secret73_DocumentAttribute_documentAttributeAudio *_object = [[Secret73_DocumentAttribute_documentAttributeAudio alloc] init];
    _object.flags = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:flags] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:duration] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.title = [Secret73__Serializer addSerializerToObject:[title copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.performer = [Secret73__Serializer addSerializerToObject:[performer copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.waveform = [Secret73__Serializer addSerializerToObject:[waveform copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret73_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithFlags:(NSNumber *)flags duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h
{
    Secret73_DocumentAttribute_documentAttributeVideo *_object = [[Secret73_DocumentAttribute_documentAttributeVideo alloc] init];
    _object.flags = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:flags] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:duration] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation Secret73_DocumentAttribute_documentAttributeImageSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6c37c15c serializeBlock:^bool (Secret73_DocumentAttribute_documentAttributeImageSize *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
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

@implementation Secret73_DocumentAttribute_documentAttributeAnimated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x11b58939 serializeBlock:^bool (__unused Secret73_DocumentAttribute_documentAttributeAnimated *object, __unused NSMutableData *data)
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

@implementation Secret73_DocumentAttribute_documentAttributeFilename

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x15590068 serializeBlock:^bool (Secret73_DocumentAttribute_documentAttributeFilename *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.fileName data:data addSignature:false])
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

@implementation Secret73_DocumentAttribute_documentAttributeSticker

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x3a556302 serializeBlock:^bool (Secret73_DocumentAttribute_documentAttributeSticker *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.alt data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.stickerset data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeSticker alt:%d stickerset:%@)", (int)[self.alt length], self.stickerset];
}

@end

@implementation Secret73_DocumentAttribute_documentAttributeAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x9852f9c6 serializeBlock:^bool (Secret73_DocumentAttribute_documentAttributeAudio *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if ([object.flags intValue] & (1 << 0)) {
            if (![Secret73__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 1)) {
            if (![Secret73__Environment serializeObject:object.performer data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 2)) {
            if (![Secret73__Environment serializeObject:object.waveform data:data addSignature:false])
                return false;
            }
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAudio flags:%@ duration:%@ title:%d performer:%d waveform:%d)", self.flags, self.duration, (int)[self.title length], (int)[self.performer length], (int)[self.waveform length]];
}

@end

@implementation Secret73_DocumentAttribute_documentAttributeVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xef02ce6 serializeBlock:^bool (Secret73_DocumentAttribute_documentAttributeVideo *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeVideo flags:%@ duration:%@ w:%@ h:%@)", self.flags, self.duration, self.w, self.h];
}

@end




@interface Secret73_InputStickerSet ()

@end

@interface Secret73_InputStickerSet_inputStickerSetShortName ()

@property (nonatomic, strong) NSString * shortName;

@end

@interface Secret73_InputStickerSet_inputStickerSetEmpty ()

@end

@implementation Secret73_InputStickerSet

+ (Secret73_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName
{
    Secret73_InputStickerSet_inputStickerSetShortName *_object = [[Secret73_InputStickerSet_inputStickerSetShortName alloc] init];
    _object.shortName = [Secret73__Serializer addSerializerToObject:[shortName copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty
{
    Secret73_InputStickerSet_inputStickerSetEmpty *_object = [[Secret73_InputStickerSet_inputStickerSetEmpty alloc] init];
    return _object;
}


@end

@implementation Secret73_InputStickerSet_inputStickerSetShortName

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x861cc8a0 serializeBlock:^bool (Secret73_InputStickerSet_inputStickerSetShortName *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.shortName data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(inputStickerSetShortName short_name:%d)", (int)[self.shortName length]];
}

@end

@implementation Secret73_InputStickerSet_inputStickerSetEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xffb62b95 serializeBlock:^bool (__unused Secret73_InputStickerSet_inputStickerSetEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(inputStickerSetEmpty)"];
}

@end




@interface Secret73_MessageEntity ()

@property (nonatomic, strong) NSNumber * offset;
@property (nonatomic, strong) NSNumber * length;

@end

@interface Secret73_MessageEntity_messageEntityUnknown ()

@end

@interface Secret73_MessageEntity_messageEntityMention ()

@end

@interface Secret73_MessageEntity_messageEntityHashtag ()

@end

@interface Secret73_MessageEntity_messageEntityBotCommand ()

@end

@interface Secret73_MessageEntity_messageEntityUrl ()

@end

@interface Secret73_MessageEntity_messageEntityEmail ()

@end

@interface Secret73_MessageEntity_messageEntityBold ()

@end

@interface Secret73_MessageEntity_messageEntityItalic ()

@end

@interface Secret73_MessageEntity_messageEntityCode ()

@end

@interface Secret73_MessageEntity_messageEntityPre ()

@property (nonatomic, strong) NSString * language;

@end

@interface Secret73_MessageEntity_messageEntityTextUrl ()

@property (nonatomic, strong) NSString * url;

@end

@implementation Secret73_MessageEntity

+ (Secret73_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityUnknown *_object = [[Secret73_MessageEntity_messageEntityUnknown alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityMention *_object = [[Secret73_MessageEntity_messageEntityMention alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityHashtag *_object = [[Secret73_MessageEntity_messageEntityHashtag alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityBotCommand *_object = [[Secret73_MessageEntity_messageEntityBotCommand alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityUrl *_object = [[Secret73_MessageEntity_messageEntityUrl alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityEmail *_object = [[Secret73_MessageEntity_messageEntityEmail alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityBold *_object = [[Secret73_MessageEntity_messageEntityBold alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityItalic *_object = [[Secret73_MessageEntity_messageEntityItalic alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret73_MessageEntity_messageEntityCode *_object = [[Secret73_MessageEntity_messageEntityCode alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language
{
    Secret73_MessageEntity_messageEntityPre *_object = [[Secret73_MessageEntity_messageEntityPre alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.language = [Secret73__Serializer addSerializerToObject:[language copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url
{
    Secret73_MessageEntity_messageEntityTextUrl *_object = [[Secret73_MessageEntity_messageEntityTextUrl alloc] init];
    _object.offset = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:offset] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:length] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.url = [Secret73__Serializer addSerializerToObject:[url copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret73_MessageEntity_messageEntityUnknown

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xbb92ba95 serializeBlock:^bool (Secret73_MessageEntity_messageEntityUnknown *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityUnknown offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityMention

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xfa04579d serializeBlock:^bool (Secret73_MessageEntity_messageEntityMention *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityMention offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityHashtag

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6f635b0d serializeBlock:^bool (Secret73_MessageEntity_messageEntityHashtag *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityHashtag offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityBotCommand

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6cef8ac7 serializeBlock:^bool (Secret73_MessageEntity_messageEntityBotCommand *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityBotCommand offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityUrl

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x6ed02538 serializeBlock:^bool (Secret73_MessageEntity_messageEntityUrl *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityUrl offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityEmail

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x64e475c2 serializeBlock:^bool (Secret73_MessageEntity_messageEntityEmail *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityEmail offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityBold

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xbd610bc9 serializeBlock:^bool (Secret73_MessageEntity_messageEntityBold *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityBold offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityItalic

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x826f8b60 serializeBlock:^bool (Secret73_MessageEntity_messageEntityItalic *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityItalic offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityCode

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x28a20571 serializeBlock:^bool (Secret73_MessageEntity_messageEntityCode *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityCode offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret73_MessageEntity_messageEntityPre

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x73924be0 serializeBlock:^bool (Secret73_MessageEntity_messageEntityPre *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.language data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityPre offset:%@ length:%@ language:%d)", self.offset, self.length, (int)[self.language length]];
}

@end

@implementation Secret73_MessageEntity_messageEntityTextUrl

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x76a6d327 serializeBlock:^bool (Secret73_MessageEntity_messageEntityTextUrl *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.url data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityTextUrl offset:%@ length:%@ url:%d)", self.offset, self.length, (int)[self.url length]];
}

@end




@interface Secret73_DecryptedMessageMedia ()

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSNumber * userId;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * accessHash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) Secret73_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dcId;
@property (nonatomic, strong) NSArray * attributes;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;
@property (nonatomic, strong) NSArray * attributes;
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo ()

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
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * provider;
@property (nonatomic, strong) NSString * venueId;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage ()

@property (nonatomic, strong) NSString * url;

@end

@implementation Secret73_DecryptedMessageMedia

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:lat] serializer:[[Secret73_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:plong] serializer:[[Secret73_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phoneNumber = [Secret73__Serializer addSerializerToObject:[phoneNumber copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.firstName = [Secret73__Serializer addSerializerToObject:[firstName copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.lastName = [Secret73__Serializer addSerializerToObject:[lastName copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.userId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:userId] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:duration] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret73__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret73__Serializer addSerializerToObject:[key copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret73__Serializer addSerializerToObject:[iv copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret73_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument alloc] init];
    _object.pid = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:pid] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.accessHash = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:accessHash] serializer:[[Secret73_BuiltinSerializer_Long alloc] init]];
    _object.date = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:date] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret73__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dcId = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:dcId] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret73__Serializer addSerializerToObject:attributes_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret73__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbW] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbH] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret73__Serializer addSerializerToObject:[key copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret73__Serializer addSerializerToObject:[iv copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.caption = [Secret73__Serializer addSerializerToObject:[caption copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes caption:(NSString *)caption
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret73__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbW] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbH] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret73__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret73__Serializer addSerializerToObject:[key copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret73__Serializer addSerializerToObject:[iv copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret73__Serializer addSerializerToObject:attributes_copy serializer:[[Secret73__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret73__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    _object.caption = [Secret73__Serializer addSerializerToObject:[caption copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret73__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbW] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:thumbH] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:duration] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret73__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:w] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:h] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:size] serializer:[[Secret73_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret73__Serializer addSerializerToObject:[key copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret73__Serializer addSerializerToObject:[iv copy] serializer:[[Secret73_BuiltinSerializer_Bytes alloc] init]];
    _object.caption = [Secret73__Serializer addSerializerToObject:[caption copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue *)decryptedMessageMediaVenueWithLat:(NSNumber *)lat plong:(NSNumber *)plong title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue alloc] init];
    _object.lat = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:lat] serializer:[[Secret73_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret73__Serializer addSerializerToObject:[[Secret73__Number alloc] initWithNumber:plong] serializer:[[Secret73_BuiltinSerializer_Double alloc] init]];
    _object.title = [Secret73__Serializer addSerializerToObject:[title copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.address = [Secret73__Serializer addSerializerToObject:[address copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.provider = [Secret73__Serializer addSerializerToObject:[provider copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    _object.venueId = [Secret73__Serializer addSerializerToObject:[venueId copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage *)decryptedMessageMediaWebPageWithUrl:(NSString *)url
{
    Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage *_object = [[Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage alloc] init];
    _object.url = [Secret73__Serializer addSerializerToObject:[url copy] serializer:[[Secret73_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
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

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.plong data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.phoneNumber data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.firstName data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.lastName data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.userId data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x57e0a9cb serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.iv data:data addSignature:false])
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

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xfa95b0dd serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.accessHash data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![Secret73__Environment serializeObject:object.dcId data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.attributes data:data addSignature:true])
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

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xf1fa8d78 serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%d thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%d iv:%d caption:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length], (int)[self.caption length]];
}

@end

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x7afe8ae2 serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.attributes data:data addSignature:true])
                return false;
            if (![Secret73__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%d thumb_w:%@ thumb_h:%@ mime_type:%d size:%@ key:%d iv:%d attributes:%@ caption:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, (int)[self.mimeType length], self.size, (int)[self.key length], (int)[self.iv length], self.attributes, (int)[self.caption length]];
}

@end

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x970c8c0e serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%d thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%d w:%@ h:%@ size:%@ key:%d iv:%d caption:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.duration, (int)[self.mimeType length], self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length], (int)[self.caption length]];
}

@end

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0x8a0df56f serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.address data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.provider data:data addSignature:false])
                return false;
            if (![Secret73__Environment serializeObject:object.venueId data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVenue lat:%@ long:%@ title:%d address:%d provider:%d venue_id:%d)", self.lat, self.plong, (int)[self.title length], (int)[self.address length], (int)[self.provider length], (int)[self.venueId length]];
}

@end

@implementation Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret73__Serializer addSerializerToObject:self withConstructorSignature:0xe50511d8 serializeBlock:^bool (Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage *object, NSMutableData *data)
        {
            if (![Secret73__Environment serializeObject:object.url data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaWebPage url:%d)", (int)[self.url length]];
}

@end




@implementation Secret73: NSObject

@end
