#import "SecretLayer1.h"
#import <objc/runtime.h>

static const char *Secret1__Serializer_Key = "Secret1__Serializer";

@interface Secret1__Number : NSNumber
{
    NSNumber *_value;
}

@end

@implementation Secret1__Number

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

@interface Secret1__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret1__Serializer

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
        objc_setAssociatedObject(object, Secret1__Serializer_Key, [[Secret1__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret1__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret1__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret1__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret1__UnboxedTypeMetaInfo

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

@interface Secret1__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret1__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret1__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret1__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret1__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret1__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret1__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret1__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret1__Environment

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

            bool isData = [metaInfo isKindOfClass:[Secret1__PreferNSDataTypeMetaInfo class]];
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
            if ([metaInfo isKindOfClass:[Secret1__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret1__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret1__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
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
                id item = [Secret1__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0x1f814f1f)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * randomBytes = nil;
            if ((randomBytes = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret1_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret1__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessage decryptedMessageWithRandomId:randomId randomBytes:randomBytes message:message media:media];
        } copy];
        parsers[@((int32_t)0xaa48327d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * randomBytes = nil;
            if ((randomBytes = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            Secret1_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret1__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessage decryptedMessageServiceWithRandomId:randomId randomBytes:randomBytes action:action];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumbW:thumbW thumbH:thumbH w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x4cee6ef3)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumbW:thumbW thumbH:thumbH duration:duration w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phoneNumber = nil;
            if ((phoneNumber = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * firstName = nil;
            if ((firstName = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * lastName = nil;
            if ((lastName = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * userId = nil;
            if ((userId = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaContactWithPhoneNumber:phoneNumber firstName:firstName lastName:lastName userId:userId];
        } copy];
        parsers[@((int32_t)0xb095434b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * fileName = nil;
            if ((fileName = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumbW:thumbW thumbH:thumbH fileName:fileName mimeType:mimeType size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x6080758f)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret1__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttlSeconds = nil;
            if ((ttlSeconds = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:ttlSeconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret1__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret1__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret1__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret1__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret1__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret1__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret1_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret1_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret1__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret1_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
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
     Secret1__Serializer *serializer = objc_getAssociatedObject(object, Secret1__Serializer_Key);
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

@interface Secret1_BuiltinSerializer_Int : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Int

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

@interface Secret1_BuiltinSerializer_Long : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Long

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

@interface Secret1_BuiltinSerializer_Double : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Double

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

@interface Secret1_BuiltinSerializer_String : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_String

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

@interface Secret1_BuiltinSerializer_Bytes : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Bytes

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

@interface Secret1_BuiltinSerializer_Int128 : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Int128

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

@interface Secret1_BuiltinSerializer_Int256 : Secret1__Serializer
@end

@implementation Secret1_BuiltinSerializer_Int256

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



@implementation Secret1_FunctionContext

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

@interface Secret1_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * randomId;
@property (nonatomic, strong) NSData * randomBytes;

@end

@interface Secret1_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret1_DecryptedMessageMedia * media;

@end

@interface Secret1_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret1_DecryptedMessageAction * action;

@end

@implementation Secret1_DecryptedMessage

+ (Secret1_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId randomBytes:(NSData *)randomBytes message:(NSString *)message media:(Secret1_DecryptedMessageMedia *)media
{
    Secret1_DecryptedMessage_decryptedMessage *_object = [[Secret1_DecryptedMessage_decryptedMessage alloc] init];
    _object.randomId = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:randomId] serializer:[[Secret1_BuiltinSerializer_Long alloc] init]];
    _object.randomBytes = [Secret1__Serializer addSerializerToObject:[randomBytes copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.message = [Secret1__Serializer addSerializerToObject:[message copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (Secret1_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId randomBytes:(NSData *)randomBytes action:(Secret1_DecryptedMessageAction *)action
{
    Secret1_DecryptedMessage_decryptedMessageService *_object = [[Secret1_DecryptedMessage_decryptedMessageService alloc] init];
    _object.randomId = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:randomId] serializer:[[Secret1_BuiltinSerializer_Long alloc] init]];
    _object.randomBytes = [Secret1__Serializer addSerializerToObject:[randomBytes copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation Secret1_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x1f814f1f serializeBlock:^bool (Secret1_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.randomBytes data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage random_id:%@ random_bytes:%d message:%d media:%@)", self.randomId, (int)[self.randomBytes length], (int)[self.message length], self.media];
}

@end

@implementation Secret1_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0xaa48327d serializeBlock:^bool (Secret1_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.randomId data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.randomBytes data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageService random_id:%@ random_bytes:%d action:%@)", self.randomId, (int)[self.randomBytes length], self.action];
}

@end




@interface Secret1_DecryptedMessageMedia ()

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSNumber * userId;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@implementation Secret1_DecryptedMessageMedia

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret1__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbW] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbH] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:w] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:h] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:size] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret1__Serializer addSerializerToObject:[key copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret1__Serializer addSerializerToObject:[iv copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret1__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbW] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbH] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:duration] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:w] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:h] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:size] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret1__Serializer addSerializerToObject:[key copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret1__Serializer addSerializerToObject:[iv copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:lat] serializer:[[Secret1_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:plong] serializer:[[Secret1_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phoneNumber = [Secret1__Serializer addSerializerToObject:[phoneNumber copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.firstName = [Secret1__Serializer addSerializerToObject:[firstName copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.lastName = [Secret1__Serializer addSerializerToObject:[lastName copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.userId = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:userId] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret1__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbW] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:thumbH] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.fileName = [Secret1__Serializer addSerializerToObject:[fileName copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.mimeType = [Secret1__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret1_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:size] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret1__Serializer addSerializerToObject:[key copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret1__Serializer addSerializerToObject:[iv copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:duration] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:size] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret1__Serializer addSerializerToObject:[key copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret1__Serializer addSerializerToObject:[iv copy] serializer:[[Secret1_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
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

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.iv data:data addSignature:false])
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

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x4cee6ef3 serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%d thumb_w:%@ thumb_h:%@ duration:%@ w:%@ h:%@ size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.duration, self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.plong data:data addSignature:false])
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

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.phoneNumber data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.firstName data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.lastName data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.userId data:data addSignature:false])
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

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0xb095434b serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.fileName data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.iv data:data addSignature:false])
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

@implementation Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x6080758f serializeBlock:^bool (Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret1__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ size:%@ key:%d iv:%d)", self.duration, self.size, (int)[self.key length], (int)[self.iv length]];
}

@end




@interface Secret1_DecryptedMessageAction ()

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttlSeconds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@implementation Secret1_DecryptedMessageAction

+ (Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds
{
    Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttlSeconds = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:ttlSeconds] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret1_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret1__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret1__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret1__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret1_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret1__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret1__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret1__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret1_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret1__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret1__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret1__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret1__Serializer addSerializerToObject:[[Secret1__Number alloc] initWithNumber:layer] serializer:[[Secret1_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.ttlSeconds data:data addSignature:false])
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

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.randomIds data:data addSignature:true])
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

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
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

@implementation Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret1__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret1__Environment serializeObject:object.layer data:data addSignature:false])
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




@implementation Secret1: NSObject

@end
