#import "SecretLayer13.h"
#import <objc/runtime.h>

static const char *Secret13__Serializer_Key = "Secret13__Serializer";

@interface Secret13__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret13__Serializer

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
        objc_setAssociatedObject(object, Secret13__Serializer_Key, [[Secret13__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret13__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret13__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret13__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret13__UnboxedTypeMetaInfo

- (instancetype)initWithConstructorSignature:(int32_t)constructorSignature
{
    self = [super init];
    if (self != nil)
    {
        _constructorSignature = constructorSignature;
    }
    return nil;
}

@end

@interface Secret13__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret13__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret13__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret13__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret13__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret13__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret13__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret13__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret13__Environment

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
            uint8_t tmp = 0;
            [data getBytes:(void *)&tmp range:NSMakeRange(*offset, 1)];
            *offset += 1;

            int paddingBytes = 0;

            int32_t length = tmp;
            if (length == 254)
            {
                length = 0;
                [data getBytes:((uint8_t *)&length) + 1 range:NSMakeRange(*offset, 3)];
                *offset += 3;
                length >>= 8;

                paddingBytes = ((length % 4) == 0 ? length : (length + 4 - (length % 4)));
            }
            else
                paddingBytes = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);

            bool isData = [metaInfo isKindOfClass:[Secret13__PreferNSDataTypeMetaInfo class]];
            id object = nil;

            if (length > 0)
            {
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
            if ([metaInfo isKindOfClass:[Secret13__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret13__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret13__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
            else
                return nil;

            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
            for (int32_t i = 0; i < count; i++)
            {
                int32_t itemConstructorSignature = 0;
                if (isBoxed)
                {
                    [data getBytes:(void *)&itemConstructorSignature range:NSMakeRange(*offset, 4)];
                    *offset += 4;
                }
                else
                    itemConstructorSignature = unboxedConstructorSignature;
                id item = [Secret13__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0x99a438cf)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret13_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret13__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessageLayer decryptedMessageLayerWithLayer:layer message:message];
        } copy];
        parsers[@((int32_t)0x1f814f1f)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret13_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret13__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessage decryptedMessageWithRandom_id:random_id random_bytes:random_bytes message:message media:media];
        } copy];
        parsers[@((int32_t)0xaa48327d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            Secret13_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret13__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessage decryptedMessageServiceWithRandom_id:random_id random_bytes:random_bytes action:action];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phone_number = nil;
            if ((phone_number = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0xb095434b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h file_name:file_name mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x524a415d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h duration:duration mime_type:mime_type w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret13__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttl_seconds = nil;
            if ((ttl_seconds = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:ttl_seconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret13__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret13__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret13__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret13__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret13__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret13__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret13_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret13_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret13__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret13_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
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
     Secret13__Serializer *serializer = objc_getAssociatedObject(object, Secret13__Serializer_Key);
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

@interface Secret13_BuiltinSerializer_Int : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Int

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

@interface Secret13_BuiltinSerializer_Long : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Long

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

@interface Secret13_BuiltinSerializer_Double : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Double

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

@interface Secret13_BuiltinSerializer_String : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_String

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
            padding = ((length % 4) == 0 ? length : (length + 4 - (length % 4)));
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

@interface Secret13_BuiltinSerializer_Bytes : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Bytes

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        NSData *value = object;
        int32_t length = value.length;
        int32_t padding = 0;
        if (length >= 254)
        {
            uint8_t tmp = 254;
            [data appendBytes:&tmp length:1];
            [data appendBytes:(void *)&length length:3];
            padding = ((length % 4) == 0 ? length : (length + 4 - (length % 4)));
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

@interface Secret13_BuiltinSerializer_Int128 : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Int128

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

@interface Secret13_BuiltinSerializer_Int256 : Secret13__Serializer
@end

@implementation Secret13_BuiltinSerializer_Int256

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


@interface Secret13_DecryptedMessageLayer ()

@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) Secret13_DecryptedMessage * message;

@end

@interface Secret13_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret13_DecryptedMessageLayer

+ (Secret13_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithLayer:(NSNumber *)layer message:(Secret13_DecryptedMessage *)message
{
    Secret13_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret13_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.layer = [Secret13__Serializer addSerializerToObject:[layer copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret13_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x99a438cf serializeBlock:^bool (Secret13_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageLayer layer:%@ message:%@)", self.layer, self.message];
}

@end




@interface Secret13_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;
@property (nonatomic, strong) NSData * random_bytes;

@end

@interface Secret13_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret13_DecryptedMessageMedia * media;

@end

@interface Secret13_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret13_DecryptedMessageAction * action;

@end

@implementation Secret13_DecryptedMessage

+ (Secret13_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret13_DecryptedMessageMedia *)media
{
    Secret13_DecryptedMessage_decryptedMessage *_object = [[Secret13_DecryptedMessage_decryptedMessage alloc] init];
    _object.random_id = [Secret13__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret13_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [Secret13__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.message = [Secret13__Serializer addSerializerToObject:[message copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (Secret13_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret13_DecryptedMessageAction *)action
{
    Secret13_DecryptedMessage_decryptedMessageService *_object = [[Secret13_DecryptedMessage_decryptedMessageService alloc] init];
    _object.random_id = [Secret13__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret13_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [Secret13__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation Secret13_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x1f814f1f serializeBlock:^bool (Secret13_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage random_id:%@ random_bytes:%@ message:%@ media:%@)", self.random_id, self.random_bytes, self.message, self.media];
}

@end

@implementation Secret13_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0xaa48327d serializeBlock:^bool (Secret13_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageService random_id:%@ random_bytes:%@ action:%@)", self.random_id, self.random_bytes, self.action];
}

@end




@interface Secret13_DecryptedMessageMedia ()

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@implementation Secret13_DecryptedMessageMedia

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret13__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret13__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret13__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret13__Serializer addSerializerToObject:[w copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret13__Serializer addSerializerToObject:[h copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret13__Serializer addSerializerToObject:[size copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret13__Serializer addSerializerToObject:[key copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret13__Serializer addSerializerToObject:[iv copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret13__Serializer addSerializerToObject:[lat copy] serializer:[[Secret13_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret13__Serializer addSerializerToObject:[plong copy] serializer:[[Secret13_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phone_number = [Secret13__Serializer addSerializerToObject:[phone_number copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.first_name = [Secret13__Serializer addSerializerToObject:[first_name copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.last_name = [Secret13__Serializer addSerializerToObject:[last_name copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.user_id = [Secret13__Serializer addSerializerToObject:[user_id copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret13__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret13__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret13__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.file_name = [Secret13__Serializer addSerializerToObject:[file_name copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [Secret13__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret13__Serializer addSerializerToObject:[size copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret13__Serializer addSerializerToObject:[key copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret13__Serializer addSerializerToObject:[iv copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret13__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret13__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret13__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret13__Serializer addSerializerToObject:[duration copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret13__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret13__Serializer addSerializerToObject:[w copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret13__Serializer addSerializerToObject:[h copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret13__Serializer addSerializerToObject:[size copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret13__Serializer addSerializerToObject:[key copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret13__Serializer addSerializerToObject:[iv copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret13__Serializer addSerializerToObject:[duration copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret13__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret13_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret13__Serializer addSerializerToObject:[size copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret13__Serializer addSerializerToObject:[key copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret13__Serializer addSerializerToObject:[iv copy] serializer:[[Secret13_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
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

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%@ thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.w, self.h, self.size, self.key, self.iv];
}

@end

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.plong data:data addSignature:false])
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

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaContact phone_number:%@ first_name:%@ last_name:%@ user_id:%@)", self.phone_number, self.first_name, self.last_name, self.user_id];
}

@end

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0xb095434b serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%@ thumb_w:%@ thumb_h:%@ file_name:%@ mime_type:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.file_name, self.mime_type, self.size, self.key, self.iv];
}

@end

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x524a415d serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%@ thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%@ w:%@ h:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.duration, self.mime_type, self.w, self.h, self.size, self.key, self.iv];
}

@end

@implementation Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x57e0a9cb serializeBlock:^bool (Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret13__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ mime_type:%@ size:%@ key:%@ iv:%@)", self.duration, self.mime_type, self.size, self.key, self.iv];
}

@end




@interface Secret13_DecryptedMessageAction ()

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttl_seconds;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@implementation Secret13_DecryptedMessageAction

+ (Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds
{
    Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttl_seconds = [Secret13__Serializer addSerializerToObject:[ttl_seconds copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.random_ids = [Secret13__Serializer addSerializerToObject:[random_ids copy] serializer:[[Secret13__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret13__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.random_ids = [Secret13__Serializer addSerializerToObject:[random_ids copy] serializer:[[Secret13__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret13__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.random_ids = [Secret13__Serializer addSerializerToObject:[random_ids copy] serializer:[[Secret13__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret13__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret13__Serializer addSerializerToObject:[layer copy] serializer:[[Secret13_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.ttl_seconds data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionSetMessageTTL ttl_seconds:%@)", self.ttl_seconds];
}

@end

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionReadMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionDeleteMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionScreenshotMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
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

@implementation Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret13__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret13__Environment serializeObject:object.layer data:data addSignature:false])
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




