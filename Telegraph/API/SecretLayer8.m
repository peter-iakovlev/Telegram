#import "SecretLayer8.h"
#import <objc/runtime.h>

static const char *Secret8__Serializer_Key = "Secret8__Serializer";

@interface Secret8__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret8__Serializer

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
        objc_setAssociatedObject(object, Secret8__Serializer_Key, [[Secret8__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret8__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret8__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret8__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret8__UnboxedTypeMetaInfo

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

@interface Secret8__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret8__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret8__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret8__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret8__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret8__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret8__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret8__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret8__Environment

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

            bool isData = [metaInfo isKindOfClass:[Secret8__PreferNSDataTypeMetaInfo class]];
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
            if ([metaInfo isKindOfClass:[Secret8__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret8__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret8__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
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
                id item = [Secret8__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0x99a438cf)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret8_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret8__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessageLayer decryptedMessageLayerWithLayer:layer message:message];
        } copy];
        parsers[@((int32_t)0x1f814f1f)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret8_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret8__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessage decryptedMessageWithRandom_id:random_id random_bytes:random_bytes message:message media:media];
        } copy];
        parsers[@((int32_t)0xaa48327d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            Secret8_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret8__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessage decryptedMessageServiceWithRandom_id:random_id random_bytes:random_bytes action:action];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret8_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret8_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x4cee6ef3)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret8__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret8_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h duration:duration w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phone_number = nil;
            if ((phone_number = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessageMedia decryptedMessageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttl_seconds = nil;
            if ((ttl_seconds = [Secret8__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret8_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:ttl_seconds];
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
     Secret8__Serializer *serializer = objc_getAssociatedObject(object, Secret8__Serializer_Key);
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

@interface Secret8_BuiltinSerializer_Int : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Int

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

@interface Secret8_BuiltinSerializer_Long : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Long

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

@interface Secret8_BuiltinSerializer_Double : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Double

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

@interface Secret8_BuiltinSerializer_String : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_String

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

@interface Secret8_BuiltinSerializer_Bytes : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Bytes

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

@interface Secret8_BuiltinSerializer_Int128 : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Int128

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

@interface Secret8_BuiltinSerializer_Int256 : Secret8__Serializer
@end

@implementation Secret8_BuiltinSerializer_Int256

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


@interface Secret8_DecryptedMessageLayer ()

@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) Secret8_DecryptedMessage * message;

@end

@interface Secret8_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret8_DecryptedMessageLayer

+ (Secret8_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithLayer:(NSNumber *)layer message:(Secret8_DecryptedMessage *)message
{
    Secret8_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret8_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.layer = [Secret8__Serializer addSerializerToObject:[layer copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret8_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x99a438cf serializeBlock:^bool (Secret8_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.message data:data addSignature:true])
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




@interface Secret8_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;
@property (nonatomic, strong) NSData * random_bytes;

@end

@interface Secret8_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret8_DecryptedMessageMedia * media;

@end

@interface Secret8_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret8_DecryptedMessageAction * action;

@end

@implementation Secret8_DecryptedMessage

+ (Secret8_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret8_DecryptedMessageMedia *)media
{
    Secret8_DecryptedMessage_decryptedMessage *_object = [[Secret8_DecryptedMessage_decryptedMessage alloc] init];
    _object.random_id = [Secret8__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret8_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [Secret8__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.message = [Secret8__Serializer addSerializerToObject:[message copy] serializer:[[Secret8_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (Secret8_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret8_DecryptedMessageAction *)action
{
    Secret8_DecryptedMessage_decryptedMessageService *_object = [[Secret8_DecryptedMessage_decryptedMessageService alloc] init];
    _object.random_id = [Secret8__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret8_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [Secret8__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation Secret8_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x1f814f1f serializeBlock:^bool (Secret8_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.media data:data addSignature:true])
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

@implementation Secret8_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0xaa48327d serializeBlock:^bool (Secret8_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.action data:data addSignature:true])
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




@interface Secret8_DecryptedMessageMedia ()

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@implementation Secret8_DecryptedMessageMedia

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret8__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret8__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret8__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret8__Serializer addSerializerToObject:[w copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret8__Serializer addSerializerToObject:[h copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret8__Serializer addSerializerToObject:[size copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret8__Serializer addSerializerToObject:[key copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret8__Serializer addSerializerToObject:[iv copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret8__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret8__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret8__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret8__Serializer addSerializerToObject:[duration copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret8__Serializer addSerializerToObject:[w copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret8__Serializer addSerializerToObject:[h copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret8__Serializer addSerializerToObject:[size copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret8__Serializer addSerializerToObject:[key copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret8__Serializer addSerializerToObject:[iv copy] serializer:[[Secret8_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret8__Serializer addSerializerToObject:[lat copy] serializer:[[Secret8_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret8__Serializer addSerializerToObject:[plong copy] serializer:[[Secret8_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    Secret8_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret8_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phone_number = [Secret8__Serializer addSerializerToObject:[phone_number copy] serializer:[[Secret8_BuiltinSerializer_String alloc] init]];
    _object.first_name = [Secret8__Serializer addSerializerToObject:[first_name copy] serializer:[[Secret8_BuiltinSerializer_String alloc] init]];
    _object.last_name = [Secret8__Serializer addSerializerToObject:[last_name copy] serializer:[[Secret8_BuiltinSerializer_String alloc] init]];
    _object.user_id = [Secret8__Serializer addSerializerToObject:[user_id copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
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

@implementation Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.iv data:data addSignature:false])
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

@implementation Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x4cee6ef3 serializeBlock:^bool (Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%@ thumb_w:%@ thumb_h:%@ duration:%@ w:%@ h:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.duration, self.w, self.h, self.size, self.key, self.iv];
}

@end

@implementation Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.plong data:data addSignature:false])
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

@implementation Secret8_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret8_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![Secret8__Environment serializeObject:object.user_id data:data addSignature:false])
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




@interface Secret8_DecryptedMessageAction ()

@property (nonatomic, strong) NSNumber * ttl_seconds;

@end

@interface Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@end

@implementation Secret8_DecryptedMessageAction

+ (Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds
{
    Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttl_seconds = [Secret8__Serializer addSerializerToObject:[ttl_seconds copy] serializer:[[Secret8_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret8__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret8__Environment serializeObject:object.ttl_seconds data:data addSignature:false])
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




