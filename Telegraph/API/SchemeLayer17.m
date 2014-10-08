#import "SchemeLayer17.h"
#import <objc/runtime.h>

static const char *API17__Serializer_Key = "API17__Serializer";

@interface API17__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation API17__Serializer

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
        objc_setAssociatedObject(object, API17__Serializer_Key, [[API17__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(API17__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, API17__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@implementation API17__Environment

+ (id (^)(NSData *data, NSUInteger *offset))parserByConstructorSignature:(int32_t)constructorSignature
{
    static NSMutableDictionary *parsers = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        parsers = [[NSMutableDictionary alloc] init];

        parsers[@((int32_t)0xA8509BDA)] = [^id (NSData *data, NSUInteger *offset)
        {
            if (*offset + 4 > data.length)
                return nil;
            int32_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 4)];
            *offset += 4;
            return @(value);
        } copy];

        parsers[@((int32_t)0x22076CBA)] = [^id (NSData *data, NSUInteger *offset)
        {
            if (*offset + 8 > data.length)
                return nil;
            int64_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0x2210C154)] = [^id (NSData *data, NSUInteger *offset)
        {
            if (*offset + 8 > data.length)
                return nil;
            double value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0xB5286E24)] = [^id (NSData *data, NSUInteger *offset)
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

            NSString *string = @"";

            if (length > 0)
            {
                string = [[NSString alloc] initWithBytes:((uint8_t *)data.bytes) + *offset length:length encoding:NSUTF8StringEncoding];
                *offset += length;
            }

            *offset += paddingBytes;

            return string;
        } copy];


        parsers[@((int32_t)0x68afa7d4)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * country = nil;
            if ((country = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * state = nil;
            if ((state = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * city = nil;
            if ((city = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * district = nil;
            if ((district = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * street = nil;
            if ((street = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputGeoPlaceName inputGeoPlaceNameWithCountry:country state:state city:city district:district street:street];
        } copy];
        parsers[@((int32_t)0xe4c123d6)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputGeoPoint inputGeoPointEmpty];
        } copy];
        parsers[@((int32_t)0xf3b7acc9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * lat = nil;
            if ((lat = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            return [API17_InputGeoPoint inputGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x40e9002a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Chat * chat = nil;
            int32_t chat_signature = 0; [data getBytes:(void *)&chat_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chat = [API17__Environment parseObject:data offset:_offset  implicitSignature:chat_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Chat messages_chatWithChat:chat users:users];
        } copy];
        parsers[@((int32_t)0x630e61be)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_ChatParticipants * participants = nil;
            int32_t participants_signature = 0; [data getBytes:(void *)&participants_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((participants = [API17__Environment parseObject:data offset:_offset  implicitSignature:participants_signature]) == nil)
               return nil;
            API17_Photo * chat_photo = nil;
            int32_t chat_photo_signature = 0; [data getBytes:(void *)&chat_photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chat_photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:chat_photo_signature]) == nil)
               return nil;
            API17_PeerNotifySettings * notify_settings = nil;
            int32_t notify_settings_signature = 0; [data getBytes:(void *)&notify_settings_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((notify_settings = [API17__Environment parseObject:data offset:_offset  implicitSignature:notify_settings_signature]) == nil)
               return nil;
            return [API17_ChatFull chatFullWithPid:pid participants:participants chat_photo:chat_photo notify_settings:notify_settings];
        } copy];
        parsers[@((int32_t)0xc8d7493e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * inviter_id = nil;
            if ((inviter_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ChatParticipant chatParticipantWithUser_id:user_id inviter_id:inviter_id date:date];
        } copy];
        parsers[@((int32_t)0x5d75a138)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_updates_Difference updates_differenceEmptyWithDate:date seq:seq];
        } copy];
        parsers[@((int32_t)0xf49ca0)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * pnew_messages = nil;
            int32_t pnew_messages_signature = 0; [data getBytes:(void *)&pnew_messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pnew_messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:pnew_messages_signature]) == nil)
               return nil;
            NSArray * pnew_encrypted_messages = nil;
            int32_t pnew_encrypted_messages_signature = 0; [data getBytes:(void *)&pnew_encrypted_messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pnew_encrypted_messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:pnew_encrypted_messages_signature]) == nil)
               return nil;
            NSArray * other_updates = nil;
            int32_t other_updates_signature = 0; [data getBytes:(void *)&other_updates_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((other_updates = [API17__Environment parseObject:data offset:_offset  implicitSignature:other_updates_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            API17_updates_State * state = nil;
            int32_t state_signature = 0; [data getBytes:(void *)&state_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((state = [API17__Environment parseObject:data offset:_offset  implicitSignature:state_signature]) == nil)
               return nil;
            return [API17_updates_Difference updates_differenceWithPnew_messages:pnew_messages pnew_encrypted_messages:pnew_encrypted_messages other_updates:other_updates chats:chats users:users state:state];
        } copy];
        parsers[@((int32_t)0xa8fb1981)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * pnew_messages = nil;
            int32_t pnew_messages_signature = 0; [data getBytes:(void *)&pnew_messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pnew_messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:pnew_messages_signature]) == nil)
               return nil;
            NSArray * pnew_encrypted_messages = nil;
            int32_t pnew_encrypted_messages_signature = 0; [data getBytes:(void *)&pnew_encrypted_messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pnew_encrypted_messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:pnew_encrypted_messages_signature]) == nil)
               return nil;
            NSArray * other_updates = nil;
            int32_t other_updates_signature = 0; [data getBytes:(void *)&other_updates_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((other_updates = [API17__Environment parseObject:data offset:_offset  implicitSignature:other_updates_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            API17_updates_State * intermediate_state = nil;
            int32_t intermediate_state_signature = 0; [data getBytes:(void *)&intermediate_state_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((intermediate_state = [API17__Environment parseObject:data offset:_offset  implicitSignature:intermediate_state_signature]) == nil)
               return nil;
            return [API17_updates_Difference updates_differenceSliceWithPnew_messages:pnew_messages pnew_encrypted_messages:pnew_encrypted_messages other_updates:other_updates chats:chats users:users intermediate_state:intermediate_state];
        } copy];
        parsers[@((int32_t)0x479357c0)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * method = nil;
            if ((method = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * params = nil;
            int32_t params_signature = 0; [data getBytes:(void *)&params_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((params = [API17__Environment parseObject:data offset:_offset  implicitSignature:params_signature]) == nil)
               return nil;
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_SchemeMethod schemeMethodWithPid:pid method:method params:params type:type];
        } copy];
        parsers[@((int32_t)0x60311a9b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_GeoChatMessage geoChatMessageEmptyWithChat_id:chat_id pid:pid];
        } copy];
        parsers[@((int32_t)0x4505f8e1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_MessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [API17__Environment parseObject:data offset:_offset  implicitSignature:media_signature]) == nil)
               return nil;
            return [API17_GeoChatMessage geoChatMessageWithChat_id:chat_id pid:pid from_id:from_id date:date message:message media:media];
        } copy];
        parsers[@((int32_t)0xd34fa24e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_MessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [API17__Environment parseObject:data offset:_offset  implicitSignature:action_signature]) == nil)
               return nil;
            return [API17_GeoChatMessage geoChatMessageServiceWithChat_id:chat_id pid:pid from_id:from_id date:date action:action];
        } copy];
        parsers[@((int32_t)0x5bb8e511)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * msg_id = nil;
            if ((msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * seqno = nil;
            if ((seqno = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSObject * body = nil;
            int32_t body_signature = 0; [data getBytes:(void *)&body_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((body = [API17__Environment parseObject:data offset:_offset  implicitSignature:body_signature]) == nil)
               return nil;
            return [API17_ProtoMessage protoMessageWithMsg_id:msg_id seqno:seqno bytes:bytes body:body];
        } copy];
        parsers[@((int32_t)0xade6b004)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPhotoCrop inputPhotoCropAuto];
        } copy];
        parsers[@((int32_t)0xd9915325)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * crop_left = nil;
            if ((crop_left = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * crop_top = nil;
            if ((crop_top = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * crop_width = nil;
            if ((crop_width = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            return [API17_InputPhotoCrop inputPhotoCropWithCrop_left:crop_left crop_top:crop_top crop_width:crop_width];
        } copy];
        parsers[@((int32_t)0xe22045fc)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * session_id = nil;
            if ((session_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_DestroySessionRes destroy_session_okWithSession_id:session_id];
        } copy];
        parsers[@((int32_t)0x62d350c9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * session_id = nil;
            if ((session_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_DestroySessionRes destroy_session_noneWithSession_id:session_id];
        } copy];
        parsers[@((int32_t)0x2331b22d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Photo photoEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x22b56751)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_GeoPoint * geo = nil;
            int32_t geo_signature = 0; [data getBytes:(void *)&geo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((geo = [API17__Environment parseObject:data offset:_offset  implicitSignature:geo_signature]) == nil)
               return nil;
            NSArray * sizes = nil;
            int32_t sizes_signature = 0; [data getBytes:(void *)&sizes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((sizes = [API17__Environment parseObject:data offset:_offset  implicitSignature:sizes_signature]) == nil)
               return nil;
            return [API17_Photo photoWithPid:pid access_hash:access_hash user_id:user_id date:date caption:caption geo:geo sizes:sizes];
        } copy];
        parsers[@((int32_t)0x559dc1e2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_GeoPoint * geo = nil;
            int32_t geo_signature = 0; [data getBytes:(void *)&geo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((geo = [API17__Environment parseObject:data offset:_offset  implicitSignature:geo_signature]) == nil)
               return nil;
            API17_Bool * unread = nil;
            int32_t unread_signature = 0; [data getBytes:(void *)&unread_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((unread = [API17__Environment parseObject:data offset:_offset  implicitSignature:unread_signature]) == nil)
               return nil;
            NSArray * sizes = nil;
            int32_t sizes_signature = 0; [data getBytes:(void *)&sizes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((sizes = [API17__Environment parseObject:data offset:_offset  implicitSignature:sizes_signature]) == nil)
               return nil;
            return [API17_Photo wallPhotoWithPid:pid access_hash:access_hash user_id:user_id date:date caption:caption geo:geo unread:unread sizes:sizes];
        } copy];
        parsers[@((int32_t)0x75eaea5a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * address = nil;
            if ((address = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * venue = nil;
            if ((venue = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_GeoPoint * geo = nil;
            int32_t geo_signature = 0; [data getBytes:(void *)&geo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((geo = [API17__Environment parseObject:data offset:_offset  implicitSignature:geo_signature]) == nil)
               return nil;
            API17_ChatPhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            NSNumber * participants_count = nil;
            if ((participants_count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * checked_in = nil;
            int32_t checked_in_signature = 0; [data getBytes:(void *)&checked_in_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((checked_in = [API17__Environment parseObject:data offset:_offset  implicitSignature:checked_in_signature]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Chat geoChatWithPid:pid access_hash:access_hash title:title address:address venue:venue geo:geo photo:photo participants_count:participants_count date:date checked_in:checked_in version:version];
        } copy];
        parsers[@((int32_t)0x9ba2d800)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Chat chatEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x6e9c9bc7)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_ChatPhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            NSNumber * participants_count = nil;
            if ((participants_count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * left = nil;
            int32_t left_signature = 0; [data getBytes:(void *)&left_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((left = [API17__Environment parseObject:data offset:_offset  implicitSignature:left_signature]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Chat chatWithPid:pid title:title photo:photo participants_count:participants_count date:date left:left version:version];
        } copy];
        parsers[@((int32_t)0xfb0ccc41)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Chat chatForbiddenWithPid:pid title:title date:date];
        } copy];
        parsers[@((int32_t)0x6262c36c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * requests = nil;
            int32_t requests_signature = 0; [data getBytes:(void *)&requests_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((requests = [API17__Environment parseObject:data offset:_offset  implicitSignature:requests_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Requests contacts_requestsWithRequests:requests users:users];
        } copy];
        parsers[@((int32_t)0x6f585b8c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * requests = nil;
            int32_t requests_signature = 0; [data getBytes:(void *)&requests_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((requests = [API17__Environment parseObject:data offset:_offset  implicitSignature:requests_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Requests contacts_requestsSliceWithCount:count requests:requests users:users];
        } copy];
        parsers[@((int32_t)0x79cb045d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pnew_nonce_hash = nil;
            if ((pnew_nonce_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            return [API17_Server_DH_Params server_DH_params_failWithNonce:nonce server_nonce:server_nonce pnew_nonce_hash:pnew_nonce_hash];
        } copy];
        parsers[@((int32_t)0xd0e8075c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * encrypted_answer = nil;
            if ((encrypted_answer = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_Server_DH_Params server_DH_params_okWithNonce:nonce server_nonce:server_nonce encrypted_answer:encrypted_answer];
        } copy];
        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * ttl_seconds = nil;
            if ((ttl_seconds = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:ttl_seconds];
        } copy];
        parsers[@((int32_t)0x1e1604f2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_DecryptedMessageAction decryptedMessageActionViewMessageWithRandom_id:random_id];
        } copy];
        parsers[@((int32_t)0xb56b1bc5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_DecryptedMessageAction decryptedMessageActionScreenshotMessageWithRandom_id:random_id];
        } copy];
        parsers[@((int32_t)0xd9f5c5d4)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_DecryptedMessageAction decryptedMessageActionScreenshot];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [API17__Environment parseObject:data offset:_offset  implicitSignature:random_ids_signature]) == nil)
               return nil;
            return [API17_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0x3819538f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * country = nil;
            if ((country = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * state = nil;
            if ((state = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * city = nil;
            if ((city = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * district = nil;
            if ((district = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * street = nil;
            if ((street = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_GeoPlaceName geoPlaceNameWithCountry:country state:state city:city district:district street:street];
        } copy];
        parsers[@((int32_t)0x771095da)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_User * user = nil;
            int32_t user_signature = 0; [data getBytes:(void *)&user_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((user = [API17__Environment parseObject:data offset:_offset  implicitSignature:user_signature]) == nil)
               return nil;
            API17_contacts_Link * link = nil;
            int32_t link_signature = 0; [data getBytes:(void *)&link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((link = [API17__Environment parseObject:data offset:_offset  implicitSignature:link_signature]) == nil)
               return nil;
            API17_Photo * profile_photo = nil;
            int32_t profile_photo_signature = 0; [data getBytes:(void *)&profile_photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((profile_photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:profile_photo_signature]) == nil)
               return nil;
            API17_PeerNotifySettings * notify_settings = nil;
            int32_t notify_settings_signature = 0; [data getBytes:(void *)&notify_settings_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((notify_settings = [API17__Environment parseObject:data offset:_offset  implicitSignature:notify_settings_signature]) == nil)
               return nil;
            API17_Bool * blocked = nil;
            int32_t blocked_signature = 0; [data getBytes:(void *)&blocked_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((blocked = [API17__Environment parseObject:data offset:_offset  implicitSignature:blocked_signature]) == nil)
               return nil;
            NSString * real_first_name = nil;
            if ((real_first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * real_last_name = nil;
            if ((real_last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_UserFull userFullWithUser:user link:link profile_photo:profile_photo notify_settings:notify_settings blocked:blocked real_first_name:real_first_name real_last_name:real_last_name];
        } copy];
        parsers[@((int32_t)0xf03064d8)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPeerNotifyEvents inputPeerNotifyEventsEmpty];
        } copy];
        parsers[@((int32_t)0xe86a2c74)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPeerNotifyEvents inputPeerNotifyEventsAll];
        } copy];
        parsers[@((int32_t)0x2ec2a43c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * hostname = nil;
            if ((hostname = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * ip_address = nil;
            if ((ip_address = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * port = nil;
            if ((port = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_DcOption dcOptionWithPid:pid hostname:hostname ip_address:ip_address port:port];
        } copy];
        parsers[@((int32_t)0xda69fb52)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * msg_ids = nil;
            int32_t msg_ids_signature = 0; [data getBytes:(void *)&msg_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((msg_ids = [API17__Environment parseObject:data offset:_offset  implicitSignature:msg_ids_signature]) == nil)
               return nil;
            return [API17_MsgsStateReq msgs_state_reqWithMsg_ids:msg_ids];
        } copy];
        parsers[@((int32_t)0x8987f311)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * critical = nil;
            int32_t critical_signature = 0; [data getBytes:(void *)&critical_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((critical = [API17__Environment parseObject:data offset:_offset  implicitSignature:critical_signature]) == nil)
               return nil;
            NSString * url = nil;
            if ((url = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * text = nil;
            if ((text = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_help_AppUpdate help_appUpdateWithPid:pid critical:critical url:url text:text];
        } copy];
        parsers[@((int32_t)0xc45a6536)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_help_AppUpdate help_noAppUpdate];
        } copy];
        parsers[@((int32_t)0x96a0c63e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_messages_Message * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            API17_contacts_Link * link = nil;
            int32_t link_signature = 0; [data getBytes:(void *)&link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((link = [API17__Environment parseObject:data offset:_offset  implicitSignature:link_signature]) == nil)
               return nil;
            return [API17_contacts_SentLink contacts_sentLinkWithMessage:message link:link];
        } copy];
        parsers[@((int32_t)0x5162463)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pq = nil;
            if ((pq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSArray * server_public_key_fingerprints = nil;
            int32_t server_public_key_fingerprints_signature = 0; [data getBytes:(void *)&server_public_key_fingerprints_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((server_public_key_fingerprints = [API17__Environment parseObject:data offset:_offset  implicitSignature:server_public_key_fingerprints_signature]) == nil)
               return nil;
            return [API17_ResPQ resPQWithNonce:nonce server_nonce:server_nonce pq:pq server_public_key_fingerprints:server_public_key_fingerprints];
        } copy];
        parsers[@((int32_t)0xaa963b05)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileUnknown];
        } copy];
        parsers[@((int32_t)0x7efe0e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileJpeg];
        } copy];
        parsers[@((int32_t)0xcae1aadf)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileGif];
        } copy];
        parsers[@((int32_t)0xa4f63c0)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_filePng];
        } copy];
        parsers[@((int32_t)0xae1e508d)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_filePdf];
        } copy];
        parsers[@((int32_t)0x528a0677)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileMp3];
        } copy];
        parsers[@((int32_t)0x4b09ebbc)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileMov];
        } copy];
        parsers[@((int32_t)0x40bc6f52)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_filePartial];
        } copy];
        parsers[@((int32_t)0xb3cea0e4)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileMp4];
        } copy];
        parsers[@((int32_t)0x1081464c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_storage_FileType storage_fileWebp];
        } copy];
        parsers[@((int32_t)0x1837c364)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputEncryptedFile inputEncryptedFileEmpty];
        } copy];
        parsers[@((int32_t)0x64bd0306)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * parts = nil;
            if ((parts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * md5_checksum = nil;
            if ((md5_checksum = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_InputEncryptedFile inputEncryptedFileUploadedWithPid:pid parts:parts md5_checksum:md5_checksum key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0x5a17b5e5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputEncryptedFile inputEncryptedFileWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x2dc173c8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * parts = nil;
            if ((parts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_InputEncryptedFile inputEncryptedFileBigUploadedWithPid:pid parts:parts key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0x4965676a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_FutureSalts futureSalts];
        } copy];
        parsers[@((int32_t)0x560f8935)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_SentEncryptedMessage messages_sentEncryptedMessageWithDate:date];
        } copy];
        parsers[@((int32_t)0x9493ff32)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_EncryptedFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            return [API17_messages_SentEncryptedMessage messages_sentEncryptedFileWithDate:date file:file];
        } copy];
        parsers[@((int32_t)0xf6b673a4)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * expires = nil;
            if ((expires = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_User * user = nil;
            int32_t user_signature = 0; [data getBytes:(void *)&user_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((user = [API17__Environment parseObject:data offset:_offset  implicitSignature:user_signature]) == nil)
               return nil;
            return [API17_auth_Authorization auth_authorizationWithExpires:expires user:user];
        } copy];
        parsers[@((int32_t)0xf52ff27f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * parts = nil;
            if ((parts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * name = nil;
            if ((name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * md5_checksum = nil;
            if ((md5_checksum = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputFile inputFileWithPid:pid parts:parts name:name md5_checksum:md5_checksum];
        } copy];
        parsers[@((int32_t)0xfa4f0bb5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * parts = nil;
            if ((parts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * name = nil;
            if ((name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputFile inputFileBigWithPid:pid parts:parts name:name];
        } copy];
        parsers[@((int32_t)0x9db1bc6d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Peer peerUserWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0xbad0e5bb)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Peer peerChatWithChat_id:chat_id];
        } copy];
        parsers[@((int32_t)0x9d05049)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_UserStatus userStatusEmpty];
        } copy];
        parsers[@((int32_t)0xedb93949)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * expires = nil;
            if ((expires = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_UserStatus userStatusOnlineWithExpires:expires];
        } copy];
        parsers[@((int32_t)0x8c703f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * was_online = nil;
            if ((was_online = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_UserStatus userStatusOfflineWithWas_online:was_online];
        } copy];
        parsers[@((int32_t)0xab3a99ac)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Peer * peer = nil;
            int32_t peer_signature = 0; [data getBytes:(void *)&peer_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((peer = [API17__Environment parseObject:data offset:_offset  implicitSignature:peer_signature]) == nil)
               return nil;
            NSNumber * top_message = nil;
            if ((top_message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * unread_count = nil;
            if ((unread_count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_PeerNotifySettings * notify_settings = nil;
            int32_t notify_settings_signature = 0; [data getBytes:(void *)&notify_settings_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((notify_settings = [API17__Environment parseObject:data offset:_offset  implicitSignature:notify_settings_signature]) == nil)
               return nil;
            return [API17_Dialog dialogWithPeer:peer top_message:top_message unread_count:unread_count notify_settings:notify_settings];
        } copy];
        parsers[@((int32_t)0x8cc0d131)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * msg_ids = nil;
            int32_t msg_ids_signature = 0; [data getBytes:(void *)&msg_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((msg_ids = [API17__Environment parseObject:data offset:_offset  implicitSignature:msg_ids_signature]) == nil)
               return nil;
            NSString * info = nil;
            if ((info = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_MsgsAllInfo msgs_all_infoWithMsg_ids:msg_ids info:info];
        } copy];
        parsers[@((int32_t)0x16bf744e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageTypingAction];
        } copy];
        parsers[@((int32_t)0xfd5ec8f5)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageCancelAction];
        } copy];
        parsers[@((int32_t)0xa187d66f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageRecordVideoAction];
        } copy];
        parsers[@((int32_t)0x92042ff7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageUploadVideoAction];
        } copy];
        parsers[@((int32_t)0xd52f73f7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageRecordAudioAction];
        } copy];
        parsers[@((int32_t)0xe6ac8a6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageUploadAudioAction];
        } copy];
        parsers[@((int32_t)0x990a3c1a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageUploadPhotoAction];
        } copy];
        parsers[@((int32_t)0x8faee98e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageUploadDocumentAction];
        } copy];
        parsers[@((int32_t)0x176f8ba1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageGeoLocationAction];
        } copy];
        parsers[@((int32_t)0x628cbc6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_SendMessageAction sendMessageChooseContactAction];
        } copy];
        parsers[@((int32_t)0x5a68e3f7)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_GeoChatMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            return [API17_Update updateNewGeoChatMessageWithMessage:message];
        } copy];
        parsers[@((int32_t)0x13abdb3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Message * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateNewMessageWithMessage:message pts:pts];
        } copy];
        parsers[@((int32_t)0x4e90bfd6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Update updateMessageIDWithPid:pid random_id:random_id];
        } copy];
        parsers[@((int32_t)0xc6649e31)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateReadMessagesWithMessages:messages pts:pts];
        } copy];
        parsers[@((int32_t)0xa92bfe26)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateDeleteMessagesWithMessages:messages pts:pts];
        } copy];
        parsers[@((int32_t)0xd15de04d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateRestoreMessagesWithMessages:messages pts:pts];
        } copy];
        parsers[@((int32_t)0x7761198)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_ChatParticipants * participants = nil;
            int32_t participants_signature = 0; [data getBytes:(void *)&participants_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((participants = [API17__Environment parseObject:data offset:_offset  implicitSignature:participants_signature]) == nil)
               return nil;
            return [API17_Update updateChatParticipantsWithParticipants:participants];
        } copy];
        parsers[@((int32_t)0x1bfbd823)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_UserStatus * status = nil;
            int32_t status_signature = 0; [data getBytes:(void *)&status_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:status_signature]) == nil)
               return nil;
            return [API17_Update updateUserStatusWithUser_id:user_id status:status];
        } copy];
        parsers[@((int32_t)0xda22d9ad)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_Update updateUserNameWithUser_id:user_id first_name:first_name last_name:last_name];
        } copy];
        parsers[@((int32_t)0xbb8ba607)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_UserProfilePhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            return [API17_Update updateUserPhotoWithUser_id:user_id photo:photo];
        } copy];
        parsers[@((int32_t)0x2575bbb9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateContactRegisteredWithUser_id:user_id date:date];
        } copy];
        parsers[@((int32_t)0x51a48a9a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_contacts_MyLink * my_link = nil;
            int32_t my_link_signature = 0; [data getBytes:(void *)&my_link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((my_link = [API17__Environment parseObject:data offset:_offset  implicitSignature:my_link_signature]) == nil)
               return nil;
            API17_contacts_ForeignLink * foreign_link = nil;
            int32_t foreign_link_signature = 0; [data getBytes:(void *)&foreign_link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((foreign_link = [API17__Environment parseObject:data offset:_offset  implicitSignature:foreign_link_signature]) == nil)
               return nil;
            return [API17_Update updateContactLinkWithUser_id:user_id my_link:my_link foreign_link:foreign_link];
        } copy];
        parsers[@((int32_t)0x5f83b963)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * contacts = nil;
            int32_t contacts_signature = 0; [data getBytes:(void *)&contacts_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((contacts = [API17__Environment parseObject:data offset:_offset  implicitSignature:contacts_signature]) == nil)
               return nil;
            return [API17_Update updateContactLocatedWithContacts:contacts];
        } copy];
        parsers[@((int32_t)0x6f690963)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateActivationWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0x8f06529a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * auth_key_id = nil;
            if ((auth_key_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * device = nil;
            if ((device = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * location = nil;
            if ((location = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_Update updateNewAuthorizationWithAuth_key_id:auth_key_id date:date device:device location:location];
        } copy];
        parsers[@((int32_t)0xdad7490e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_PhoneCall * phone_call = nil;
            int32_t phone_call_signature = 0; [data getBytes:(void *)&phone_call_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_call = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_call_signature]) == nil)
               return nil;
            return [API17_Update updatePhoneCallRequestedWithPhone_call:phone_call];
        } copy];
        parsers[@((int32_t)0x5609ff88)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSData * a_or_b = nil;
            if ((a_or_b = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            API17_PhoneConnection * connection = nil;
            int32_t connection_signature = 0; [data getBytes:(void *)&connection_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((connection = [API17__Environment parseObject:data offset:_offset  implicitSignature:connection_signature]) == nil)
               return nil;
            return [API17_Update updatePhoneCallConfirmedWithPid:pid a_or_b:a_or_b connection:connection];
        } copy];
        parsers[@((int32_t)0x31ae2cc2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Update updatePhoneCallDeclinedWithPid:pid];
        } copy];
        parsers[@((int32_t)0x12bcbd9a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_EncryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSNumber * qts = nil;
            if ((qts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateNewEncryptedMessageWithMessage:message qts:qts];
        } copy];
        parsers[@((int32_t)0x1710f156)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateEncryptedChatTypingWithChat_id:chat_id];
        } copy];
        parsers[@((int32_t)0xb4a2e88d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_EncryptedChat * chat = nil;
            int32_t chat_signature = 0; [data getBytes:(void *)&chat_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chat = [API17__Environment parseObject:data offset:_offset  implicitSignature:chat_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateEncryptionWithChat:chat date:date];
        } copy];
        parsers[@((int32_t)0x38fe25b7)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * max_date = nil;
            if ((max_date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateEncryptedMessagesReadWithChat_id:chat_id max_date:max_date date:date];
        } copy];
        parsers[@((int32_t)0x3a0eeb22)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * inviter_id = nil;
            if ((inviter_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateChatParticipantAddWithChat_id:chat_id user_id:user_id inviter_id:inviter_id version:version];
        } copy];
        parsers[@((int32_t)0x6e5f8c22)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Update updateChatParticipantDeleteWithChat_id:chat_id user_id:user_id version:version];
        } copy];
        parsers[@((int32_t)0x8e5e9873)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * dc_options = nil;
            int32_t dc_options_signature = 0; [data getBytes:(void *)&dc_options_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((dc_options = [API17__Environment parseObject:data offset:_offset  implicitSignature:dc_options_signature]) == nil)
               return nil;
            return [API17_Update updateDcOptionsWithDc_options:dc_options];
        } copy];
        parsers[@((int32_t)0x80ece81a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * blocked = nil;
            int32_t blocked_signature = 0; [data getBytes:(void *)&blocked_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((blocked = [API17__Environment parseObject:data offset:_offset  implicitSignature:blocked_signature]) == nil)
               return nil;
            return [API17_Update updateUserBlockedWithUser_id:user_id blocked:blocked];
        } copy];
        parsers[@((int32_t)0xbec268ef)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_NotifyPeer * peer = nil;
            int32_t peer_signature = 0; [data getBytes:(void *)&peer_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((peer = [API17__Environment parseObject:data offset:_offset  implicitSignature:peer_signature]) == nil)
               return nil;
            API17_PeerNotifySettings * notify_settings = nil;
            int32_t notify_settings_signature = 0; [data getBytes:(void *)&notify_settings_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((notify_settings = [API17__Environment parseObject:data offset:_offset  implicitSignature:notify_settings_signature]) == nil)
               return nil;
            return [API17_Update updateNotifySettingsWithPeer:peer notify_settings:notify_settings];
        } copy];
        parsers[@((int32_t)0x5c486927)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_SendMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [API17__Environment parseObject:data offset:_offset  implicitSignature:action_signature]) == nil)
               return nil;
            return [API17_Update updateUserTypingWithUser_id:user_id action:action];
        } copy];
        parsers[@((int32_t)0x9a65ea1f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_SendMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [API17__Environment parseObject:data offset:_offset  implicitSignature:action_signature]) == nil)
               return nil;
            return [API17_Update updateChatUserTypingWithChat_id:chat_id user_id:user_id action:action];
        } copy];
        parsers[@((int32_t)0x1c138d15)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * blocked = nil;
            int32_t blocked_signature = 0; [data getBytes:(void *)&blocked_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((blocked = [API17__Environment parseObject:data offset:_offset  implicitSignature:blocked_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Blocked contacts_blockedWithBlocked:blocked users:users];
        } copy];
        parsers[@((int32_t)0x900802a1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * blocked = nil;
            int32_t blocked_signature = 0; [data getBytes:(void *)&blocked_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((blocked = [API17__Environment parseObject:data offset:_offset  implicitSignature:blocked_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Blocked contacts_blockedSliceWithCount:count blocked:blocked users:users];
        } copy];
        parsers[@((int32_t)0xc4b9f9bb)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * code = nil;
            if ((code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * text = nil;
            if ((text = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_Error errorWithCode:code text:text];
        } copy];
        parsers[@((int32_t)0x59aefc57)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * code = nil;
            if ((code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * n_description = nil;
            if ((n_description = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * debug = nil;
            if ((debug = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * request_params = nil;
            if ((request_params = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_Error richErrorWithCode:code type:type n_description:n_description debug:debug request_params:request_params];
        } copy];
        parsers[@((int32_t)0xe144acaf)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_GeoPoint * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [API17__Environment parseObject:data offset:_offset  implicitSignature:location_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * distance = nil;
            if ((distance = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactLocated contactLocatedWithUser_id:user_id location:location date:date distance:distance];
        } copy];
        parsers[@((int32_t)0xc1257157)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * phash = nil;
            if ((phash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_Bool * hidden = nil;
            int32_t hidden_signature = 0; [data getBytes:(void *)&hidden_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((hidden = [API17__Environment parseObject:data offset:_offset  implicitSignature:hidden_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * distance = nil;
            if ((distance = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactLocated contactLocatedPreviewWithPhash:phash hidden:hidden date:date distance:distance];
        } copy];
        parsers[@((int32_t)0xaa77b873)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * expires = nil;
            if ((expires = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactStatus contactStatusWithUser_id:user_id expires:expires];
        } copy];
        parsers[@((int32_t)0xd1526db1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_geochats_Messages geochats_messagesWithMessages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0xbc5863e8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_geochats_Messages geochats_messagesSliceWithCount:count messages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x4deb57d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * req_msg_id = nil;
            if ((req_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSString * info = nil;
            if ((info = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_MsgsStateInfo msgs_state_infoWithReq_msg_id:req_msg_id info:info];
        } copy];
        parsers[@((int32_t)0xe17e23c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_PhotoSize photoSizeEmptyWithType:type];
        } copy];
        parsers[@((int32_t)0x77bfb61b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [API17__Environment parseObject:data offset:_offset  implicitSignature:location_signature]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_PhotoSize photoSizeWithType:type location:location w:w h:h size:size];
        } copy];
        parsers[@((int32_t)0xe9a734fa)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [API17__Environment parseObject:data offset:_offset  implicitSignature:location_signature]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_PhotoSize photoCachedSizeWithType:type location:location w:w h:h bytes:bytes];
        } copy];
        parsers[@((int32_t)0x40f5c53a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * no_suggestions = nil;
            int32_t no_suggestions_signature = 0; [data getBytes:(void *)&no_suggestions_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((no_suggestions = [API17__Environment parseObject:data offset:_offset  implicitSignature:no_suggestions_signature]) == nil)
               return nil;
            API17_Bool * hide_contacts = nil;
            int32_t hide_contacts_signature = 0; [data getBytes:(void *)&hide_contacts_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((hide_contacts = [API17__Environment parseObject:data offset:_offset  implicitSignature:hide_contacts_signature]) == nil)
               return nil;
            API17_Bool * hide_located = nil;
            int32_t hide_located_signature = 0; [data getBytes:(void *)&hide_located_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((hide_located = [API17__Environment parseObject:data offset:_offset  implicitSignature:hide_located_signature]) == nil)
               return nil;
            API17_Bool * hide_last_visit = nil;
            int32_t hide_last_visit_signature = 0; [data getBytes:(void *)&hide_last_visit_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((hide_last_visit = [API17__Environment parseObject:data offset:_offset  implicitSignature:hide_last_visit_signature]) == nil)
               return nil;
            return [API17_GlobalPrivacySettings globalPrivacySettingsWithNo_suggestions:no_suggestions hide_contacts:hide_contacts hide_located:hide_located hide_last_visit:hide_last_visit];
        } copy];
        parsers[@((int32_t)0x74d456fa)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputGeoChat inputGeoChatWithChat_id:chat_id access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x7c596b46)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * volume_id = nil;
            if ((volume_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_FileLocation fileLocationUnavailableWithVolume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * volume_id = nil;
            if ((volume_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_FileLocation fileLocationWithDc_id:dc_id volume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x4d8ddec8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputGeoChat * peer = nil;
            int32_t peer_signature = 0; [data getBytes:(void *)&peer_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((peer = [API17__Environment parseObject:data offset:_offset  implicitSignature:peer_signature]) == nil)
               return nil;
            return [API17_InputNotifyPeer inputNotifyGeoChatPeerWithPeer:peer];
        } copy];
        parsers[@((int32_t)0xb8bc5b0c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputPeer * peer = nil;
            int32_t peer_signature = 0; [data getBytes:(void *)&peer_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((peer = [API17__Environment parseObject:data offset:_offset  implicitSignature:peer_signature]) == nil)
               return nil;
            return [API17_InputNotifyPeer inputNotifyPeerWithPeer:peer];
        } copy];
        parsers[@((int32_t)0x193b4417)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputNotifyPeer inputNotifyUsers];
        } copy];
        parsers[@((int32_t)0x4a95e84e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputNotifyPeer inputNotifyChats];
        } copy];
        parsers[@((int32_t)0xa429b886)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputNotifyPeer inputNotifyAll];
        } copy];
        parsers[@((int32_t)0xed18c118)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            API17_EncryptedFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            return [API17_EncryptedMessage encryptedMessageWithRandom_id:random_id chat_id:chat_id date:date bytes:bytes file:file];
        } copy];
        parsers[@((int32_t)0x23734b06)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_EncryptedMessage encryptedMessageServiceWithRandom_id:random_id chat_id:chat_id date:date bytes:bytes];
        } copy];
        parsers[@((int32_t)0x20212ca8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Photo * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_photos_Photo photos_photoWithPhoto:photo users:users];
        } copy];
        parsers[@((int32_t)0xf392b7f4)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * client_id = nil;
            if ((client_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSString * phone = nil;
            if ((phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputContact inputPhoneContactWithClient_id:client_id phone:phone first_name:first_name last_name:last_name];
        } copy];
        parsers[@((int32_t)0x6f8b8cb2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * contacts = nil;
            int32_t contacts_signature = 0; [data getBytes:(void *)&contacts_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((contacts = [API17__Environment parseObject:data offset:_offset  implicitSignature:contacts_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Contacts contacts_contactsWithContacts:contacts users:users];
        } copy];
        parsers[@((int32_t)0xb74ba9d2)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_contacts_Contacts contacts_contactsNotModified];
        } copy];
        parsers[@((int32_t)0xa7eff811)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * bad_msg_id = nil;
            if ((bad_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * bad_msg_seqno = nil;
            if ((bad_msg_seqno = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * error_code = nil;
            if ((error_code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_BadMsgNotification bad_msg_notificationWithBad_msg_id:bad_msg_id bad_msg_seqno:bad_msg_seqno error_code:error_code];
        } copy];
        parsers[@((int32_t)0xedab447b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * bad_msg_id = nil;
            if ((bad_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * bad_msg_seqno = nil;
            if ((bad_msg_seqno = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * error_code = nil;
            if ((error_code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pnew_server_salt = nil;
            if ((pnew_server_salt = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_BadMsgNotification bad_server_saltWithBad_msg_id:bad_msg_id bad_msg_seqno:bad_msg_seqno error_code:error_code pnew_server_salt:pnew_server_salt];
        } copy];
        parsers[@((int32_t)0x72f0eaae)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputDocument inputDocumentEmpty];
        } copy];
        parsers[@((int32_t)0x18798952)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputDocument inputDocumentWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x9664f57f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputMedia inputMediaEmpty];
        } copy];
        parsers[@((int32_t)0x2dc53a7d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedPhotoWithFile:file];
        } copy];
        parsers[@((int32_t)0x8f2ab2ec)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputPhoto * pid = nil;
            int32_t pid_signature = 0; [data getBytes:(void *)&pid_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:pid_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaPhotoWithPid:pid];
        } copy];
        parsers[@((int32_t)0xf9c44144)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputGeoPoint * geo_point = nil;
            int32_t geo_point_signature = 0; [data getBytes:(void *)&geo_point_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((geo_point = [API17__Environment parseObject:data offset:_offset  implicitSignature:geo_point_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaGeoPointWithGeo_point:geo_point];
        } copy];
        parsers[@((int32_t)0xa6e45987)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * phone_number = nil;
            if ((phone_number = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name];
        } copy];
        parsers[@((int32_t)0x7f023ae6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputVideo * pid = nil;
            int32_t pid_signature = 0; [data getBytes:(void *)&pid_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:pid_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaVideoWithPid:pid];
        } copy];
        parsers[@((int32_t)0x89938781)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputAudio * pid = nil;
            int32_t pid_signature = 0; [data getBytes:(void *)&pid_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:pid_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaAudioWithPid:pid];
        } copy];
        parsers[@((int32_t)0x34e794bd)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedDocumentWithFile:file file_name:file_name mime_type:mime_type];
        } copy];
        parsers[@((int32_t)0x3e46de5d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            API17_InputFile * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:thumb_signature]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedThumbDocumentWithFile:file thumb:thumb file_name:file_name mime_type:mime_type];
        } copy];
        parsers[@((int32_t)0xd184e841)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputDocument * pid = nil;
            int32_t pid_signature = 0; [data getBytes:(void *)&pid_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:pid_signature]) == nil)
               return nil;
            return [API17_InputMedia inputMediaDocumentWithPid:pid];
        } copy];
        parsers[@((int32_t)0x4e498cab)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedAudioWithFile:file duration:duration mime_type:mime_type];
        } copy];
        parsers[@((int32_t)0x133ad6f6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedVideoWithFile:file duration:duration w:w h:h mime_type:mime_type];
        } copy];
        parsers[@((int32_t)0x9912dabf)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            API17_InputFile * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:thumb_signature]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_InputMedia inputMediaUploadedThumbVideoWithFile:file thumb:thumb duration:duration w:w h:h mime_type:mime_type];
        } copy];
        parsers[@((int32_t)0x7f3b18ea)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPeer inputPeerEmpty];
        } copy];
        parsers[@((int32_t)0x7da07ec9)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPeer inputPeerSelf];
        } copy];
        parsers[@((int32_t)0x1023dbe8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_InputPeer inputPeerContactWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0x9b447325)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputPeer inputPeerForeignWithUser_id:user_id access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x179be863)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_InputPeer inputPeerChatWithChat_id:chat_id];
        } copy];
        parsers[@((int32_t)0xf911c994)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * mutual = nil;
            int32_t mutual_signature = 0; [data getBytes:(void *)&mutual_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((mutual = [API17__Environment parseObject:data offset:_offset  implicitSignature:mutual_signature]) == nil)
               return nil;
            return [API17_Contact contactWithUser_id:user_id mutual:mutual];
        } copy];
        parsers[@((int32_t)0x8150cbd8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Chats messages_chatsWithChats:chats users:users];
        } copy];
        parsers[@((int32_t)0x83c95aec)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * pq = nil;
            if ((pq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * p = nil;
            if ((p = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * q = nil;
            if ((q = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pnew_nonce = nil;
            if ((pnew_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x929c32f]) == nil)
               return nil;
            return [API17_P_Q_inner_data p_q_inner_dataWithPq:pq p:p q:q nonce:nonce server_nonce:server_nonce pnew_nonce:pnew_nonce];
        } copy];
        parsers[@((int32_t)0xd22a1c60)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_contacts_MyLink contacts_myLinkEmpty];
        } copy];
        parsers[@((int32_t)0x6c69efee)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * contact = nil;
            int32_t contact_signature = 0; [data getBytes:(void *)&contact_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((contact = [API17__Environment parseObject:data offset:_offset  implicitSignature:contact_signature]) == nil)
               return nil;
            return [API17_contacts_MyLink contacts_myLinkRequestedWithContact:contact];
        } copy];
        parsers[@((int32_t)0xc240ebd9)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_contacts_MyLink contacts_myLinkContact];
        } copy];
        parsers[@((int32_t)0xc0e24635)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * random = nil;
            if ((random = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_messages_DhConfig messages_dhConfigNotModifiedWithRandom:random];
        } copy];
        parsers[@((int32_t)0x2c221edd)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * g = nil;
            if ((g = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * p = nil;
            if ((p = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * random = nil;
            if ((random = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_messages_DhConfig messages_dhConfigWithG:g p:p version:version random:random];
        } copy];
        parsers[@((int32_t)0xdf969c2d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_auth_ExportedAuthorization auth_exportedAuthorizationWithPid:pid bytes:bytes];
        } copy];
        parsers[@((int32_t)0x59f24214)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactRequest contactRequestWithUser_id:user_id date:date];
        } copy];
        parsers[@((int32_t)0xb7de36f2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * offset = nil;
            if ((offset = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_AffectedHistory messages_affectedHistoryWithPts:pts seq:seq offset:offset];
        } copy];
        parsers[@((int32_t)0xe9db4a3f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * links = nil;
            int32_t links_signature = 0; [data getBytes:(void *)&links_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((links = [API17__Environment parseObject:data offset:_offset  implicitSignature:links_signature]) == nil)
               return nil;
            return [API17_messages_SentMessage messages_sentMessageLinkWithPid:pid date:date pts:pts seq:seq links:links];
        } copy];
        parsers[@((int32_t)0xd1f4d35c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_SentMessage messages_sentMessageWithPid:pid date:date pts:pts seq:seq];
        } copy];
        parsers[@((int32_t)0xe5d7d19c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_ChatFull * full_chat = nil;
            int32_t full_chat_signature = 0; [data getBytes:(void *)&full_chat_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((full_chat = [API17__Environment parseObject:data offset:_offset  implicitSignature:full_chat_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_ChatFull messages_chatFullWithFull_chat:full_chat chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x133421f8)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_contacts_ForeignLink contacts_foreignLinkUnknown];
        } copy];
        parsers[@((int32_t)0xa7801f47)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * has_phone = nil;
            int32_t has_phone_signature = 0; [data getBytes:(void *)&has_phone_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((has_phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:has_phone_signature]) == nil)
               return nil;
            return [API17_contacts_ForeignLink contacts_foreignLinkRequestedWithHas_phone:has_phone];
        } copy];
        parsers[@((int32_t)0x1bea8ce1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_contacts_ForeignLink contacts_foreignLinkMutual];
        } copy];
        parsers[@((int32_t)0xf141b5e1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputEncryptedChat inputEncryptedChatWithChat_id:chat_id access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x50858a19)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSObject * query = nil;
            int32_t query_signature = 0; [data getBytes:(void *)&query_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((query = [API17__Environment parseObject:data offset:_offset  implicitSignature:query_signature]) == nil)
               return nil;
            return [API17_InvokeWithLayer17 invokeWithLayer17WithQuery:query];
        } copy];
        parsers[@((int32_t)0xc21f497e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_EncryptedFile encryptedFileEmpty];
        } copy];
        parsers[@((int32_t)0x4a70994c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_EncryptedFile encryptedFileWithPid:pid access_hash:access_hash size:size dc_id:dc_id key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0xea879f95)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactFound contactFoundWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0x9fd40bd8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Peer * peer = nil;
            int32_t peer_signature = 0; [data getBytes:(void *)&peer_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((peer = [API17__Environment parseObject:data offset:_offset  implicitSignature:peer_signature]) == nil)
               return nil;
            return [API17_NotifyPeer notifyPeerWithPeer:peer];
        } copy];
        parsers[@((int32_t)0xb4c83b4c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_NotifyPeer notifyUsers];
        } copy];
        parsers[@((int32_t)0xc007cec3)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_NotifyPeer notifyChats];
        } copy];
        parsers[@((int32_t)0x74d07c60)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_NotifyPeer notifyAll];
        } copy];
        parsers[@((int32_t)0x6643b654)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSNumber * retry_id = nil;
            if ((retry_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSData * g_b = nil;
            if ((g_b = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_Client_DH_Inner_Data client_DH_inner_dataWithNonce:nonce server_nonce:server_nonce retry_id:retry_id g_b:g_b];
        } copy];
        parsers[@((int32_t)0xeccea3f5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_contacts_MyLink * my_link = nil;
            int32_t my_link_signature = 0; [data getBytes:(void *)&my_link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((my_link = [API17__Environment parseObject:data offset:_offset  implicitSignature:my_link_signature]) == nil)
               return nil;
            API17_contacts_ForeignLink * foreign_link = nil;
            int32_t foreign_link_signature = 0; [data getBytes:(void *)&foreign_link_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((foreign_link = [API17__Environment parseObject:data offset:_offset  implicitSignature:foreign_link_signature]) == nil)
               return nil;
            API17_User * user = nil;
            int32_t user_signature = 0; [data getBytes:(void *)&user_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((user = [API17__Environment parseObject:data offset:_offset  implicitSignature:user_signature]) == nil)
               return nil;
            return [API17_contacts_Link contacts_linkWithMy_link:my_link foreign_link:foreign_link user:user];
        } copy];
        parsers[@((int32_t)0x561bc879)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactBlocked contactBlockedWithUser_id:user_id date:date];
        } copy];
        parsers[@((int32_t)0xe300cc3b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * phone_registered = nil;
            int32_t phone_registered_signature = 0; [data getBytes:(void *)&phone_registered_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_registered = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_registered_signature]) == nil)
               return nil;
            API17_Bool * phone_invited = nil;
            int32_t phone_invited_signature = 0; [data getBytes:(void *)&phone_invited_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_invited = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_invited_signature]) == nil)
               return nil;
            return [API17_auth_CheckedPhone auth_checkedPhoneWithPhone_registered:phone_registered phone_invited:phone_invited];
        } copy];
        parsers[@((int32_t)0xb98886cf)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputUser inputUserEmpty];
        } copy];
        parsers[@((int32_t)0xf7c1b13f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputUser inputUserSelf];
        } copy];
        parsers[@((int32_t)0x86e94f65)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_InputUser inputUserContactWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0x655e74ff)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputUser inputUserForeignWithUser_id:user_id access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0xa8e1e989)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * predicate = nil;
            if ((predicate = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * params = nil;
            int32_t params_signature = 0; [data getBytes:(void *)&params_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((params = [API17__Environment parseObject:data offset:_offset  implicitSignature:params_signature]) == nil)
               return nil;
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_SchemeType schemeTypeWithPid:pid predicate:predicate params:params type:type];
        } copy];
        parsers[@((int32_t)0x17b1578b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_GeoChatMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_geochats_StatedMessage geochats_statedMessageWithMessage:message chats:chats users:users seq:seq];
        } copy];
        parsers[@((int32_t)0x96a18d5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_storage_FileType * type = nil;
            int32_t type_signature = 0; [data getBytes:(void *)&type_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:type_signature]) == nil)
               return nil;
            NSNumber * mtime = nil;
            if ((mtime = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_upload_File upload_fileWithType:type mtime:mtime bytes:bytes];
        } copy];
        parsers[@((int32_t)0x5508ec75)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputVideo inputVideoEmpty];
        } copy];
        parsers[@((int32_t)0xee579652)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputVideo inputVideoWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x949d9dc)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * valid_since = nil;
            if ((valid_since = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * valid_until = nil;
            if ((valid_until = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * salt = nil;
            if ((salt = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_FutureSalt futureSaltWithValid_since:valid_since valid_until:valid_until salt:salt];
        } copy];
        parsers[@((int32_t)0x2e54dd74)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * test_mode = nil;
            int32_t test_mode_signature = 0; [data getBytes:(void *)&test_mode_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((test_mode = [API17__Environment parseObject:data offset:_offset  implicitSignature:test_mode_signature]) == nil)
               return nil;
            NSNumber * this_dc = nil;
            if ((this_dc = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * dc_options = nil;
            int32_t dc_options_signature = 0; [data getBytes:(void *)&dc_options_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((dc_options = [API17__Environment parseObject:data offset:_offset  implicitSignature:dc_options_signature]) == nil)
               return nil;
            NSNumber * chat_size_max = nil;
            if ((chat_size_max = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * broadcast_size_max = nil;
            if ((broadcast_size_max = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Config configWithDate:date test_mode:test_mode this_dc:this_dc dc_options:dc_options chat_size_max:chat_size_max broadcast_size_max:broadcast_size_max];
        } copy];
        parsers[@((int32_t)0xe06046b2)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_ProtoMessage * orig_message = nil;
            int32_t orig_message_signature = 0; [data getBytes:(void *)&orig_message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((orig_message = [API17__Environment parseObject:data offset:_offset  implicitSignature:orig_message_signature]) == nil)
               return nil;
            return [API17_ProtoMessageCopy msg_copyWithOrig_message:orig_message];
        } copy];
        parsers[@((int32_t)0x586988d8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Audio audioEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0xc7ac6496)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Audio audioWithPid:pid access_hash:access_hash user_id:user_id date:date duration:duration mime_type:mime_type size:size dc_id:dc_id];
        } copy];
        parsers[@((int32_t)0xaad7f4a7)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * results = nil;
            int32_t results_signature = 0; [data getBytes:(void *)&results_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((results = [API17__Environment parseObject:data offset:_offset  implicitSignature:results_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Located contacts_locatedWithResults:results users:users];
        } copy];
        parsers[@((int32_t)0xd95adc84)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputAudio inputAudioEmpty];
        } copy];
        parsers[@((int32_t)0x77d440ff)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputAudio inputAudioWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x62d6b459)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * msg_ids = nil;
            int32_t msg_ids_signature = 0; [data getBytes:(void *)&msg_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((msg_ids = [API17__Environment parseObject:data offset:_offset  implicitSignature:msg_ids_signature]) == nil)
               return nil;
            return [API17_MsgsAck msgs_ackWithMsg_ids:msg_ids];
        } copy];
        parsers[@((int32_t)0x347773c5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * msg_id = nil;
            if ((msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * ping_id = nil;
            if ((ping_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Pong pongWithMsg_id:msg_id ping_id:ping_id];
        } copy];
        parsers[@((int32_t)0x2194f56e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_ResponseIndirect responseIndirect];
        } copy];
        parsers[@((int32_t)0x7d861a08)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * msg_ids = nil;
            int32_t msg_ids_signature = 0; [data getBytes:(void *)&msg_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((msg_ids = [API17__Environment parseObject:data offset:_offset  implicitSignature:msg_ids_signature]) == nil)
               return nil;
            return [API17_MsgResendReq msg_resend_reqWithMsg_ids:msg_ids];
        } copy];
        parsers[@((int32_t)0x3e74f5c6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSArray * links = nil;
            int32_t links_signature = 0; [data getBytes:(void *)&links_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((links = [API17__Environment parseObject:data offset:_offset  implicitSignature:links_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_StatedMessages messages_statedMessagesLinksWithMessages:messages chats:chats users:users links:links pts:pts seq:seq];
        } copy];
        parsers[@((int32_t)0x969478bb)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_StatedMessages messages_statedMessagesWithMessages:messages chats:chats users:users pts:pts seq:seq];
        } copy];
        parsers[@((int32_t)0x63117f24)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * bg_color = nil;
            if ((bg_color = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * color = nil;
            if ((color = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_WallPaper wallPaperSolidWithPid:pid title:title bg_color:bg_color color:color];
        } copy];
        parsers[@((int32_t)0xccb03657)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * sizes = nil;
            int32_t sizes_signature = 0; [data getBytes:(void *)&sizes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((sizes = [API17__Environment parseObject:data offset:_offset  implicitSignature:sizes_signature]) == nil)
               return nil;
            NSNumber * color = nil;
            if ((color = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_WallPaper wallPaperWithPid:pid title:title sizes:sizes color:color];
        } copy];
        parsers[@((int32_t)0xfb95abcd)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * destroy_results = nil;
            int32_t destroy_results_count = 0; [data getBytes:&destroy_results_count range:NSMakeRange(*_offset , 4)]; *_offset += 4;
            NSMutableArray *destroy_results_array = [[NSMutableArray alloc] init];
            for (int32_t i = 0; i < destroy_results_count; i++)
            {
               API17_DestroySessionRes * _item = nil;
            int32_t _item_signature = 0; [data getBytes:(void *)&_item_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((_item = [API17__Environment parseObject:data offset:_offset  implicitSignature:_item_signature]) == nil)
               return nil;
            }
            destroy_results = destroy_results_array;
            return [API17_DestroySessionsRes destroy_sessions_resWithDestroy_results:destroy_results];
        } copy];
        parsers[@((int32_t)0x8c718e87)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Messages messages_messagesWithMessages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0xb446ae3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Messages messages_messagesSliceWithCount:count messages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x48feb267)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * results = nil;
            int32_t results_signature = 0; [data getBytes:(void *)&results_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((results = [API17__Environment parseObject:data offset:_offset  implicitSignature:results_signature]) == nil)
               return nil;
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_geochats_Located geochats_locatedWithResults:results messages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x3cf5727a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * phone_registered = nil;
            int32_t phone_registered_signature = 0; [data getBytes:(void *)&phone_registered_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_registered = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_registered_signature]) == nil)
               return nil;
            NSString * phone_code_hash = nil;
            if ((phone_code_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * phone_code_test = nil;
            if ((phone_code_test = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_auth_SentCode auth_sentCodePreviewWithPhone_registered:phone_registered phone_code_hash:phone_code_hash phone_code_test:phone_code_test];
        } copy];
        parsers[@((int32_t)0x1a1e1fae)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * phone_registered = nil;
            int32_t phone_registered_signature = 0; [data getBytes:(void *)&phone_registered_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_registered = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_registered_signature]) == nil)
               return nil;
            return [API17_auth_SentCode auth_sentPassPhraseWithPhone_registered:phone_registered];
        } copy];
        parsers[@((int32_t)0xefed51d9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * phone_registered = nil;
            int32_t phone_registered_signature = 0; [data getBytes:(void *)&phone_registered_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_registered = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_registered_signature]) == nil)
               return nil;
            NSString * phone_code_hash = nil;
            if ((phone_code_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * send_call_timeout = nil;
            if ((send_call_timeout = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * is_password = nil;
            int32_t is_password_signature = 0; [data getBytes:(void *)&is_password_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((is_password = [API17__Environment parseObject:data offset:_offset  implicitSignature:is_password_signature]) == nil)
               return nil;
            return [API17_auth_SentCode auth_sentCodeWithPhone_registered:phone_registered phone_code_hash:phone_code_hash send_call_timeout:send_call_timeout is_password:is_password];
        } copy];
        parsers[@((int32_t)0xe325edcf)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * phone_registered = nil;
            int32_t phone_registered_signature = 0; [data getBytes:(void *)&phone_registered_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((phone_registered = [API17__Environment parseObject:data offset:_offset  implicitSignature:phone_registered_signature]) == nil)
               return nil;
            NSString * phone_code_hash = nil;
            if ((phone_code_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * send_call_timeout = nil;
            if ((send_call_timeout = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Bool * is_password = nil;
            int32_t is_password_signature = 0; [data getBytes:(void *)&is_password_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((is_password = [API17__Environment parseObject:data offset:_offset  implicitSignature:is_password_signature]) == nil)
               return nil;
            return [API17_auth_SentCode auth_sentAppCodeWithPhone_registered:phone_registered phone_code_hash:phone_code_hash send_call_timeout:send_call_timeout is_password:is_password];
        } copy];
        parsers[@((int32_t)0x8a5d855e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * g = nil;
            if ((g = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * p = nil;
            if ((p = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * ring_timeout = nil;
            if ((ring_timeout = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * expires = nil;
            if ((expires = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_phone_DhConfig phone_dhConfigWithG:g p:p ring_timeout:ring_timeout expires:expires];
        } copy];
        parsers[@((int32_t)0x1ca48f57)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputChatPhoto inputChatPhotoEmpty];
        } copy];
        parsers[@((int32_t)0x94254732)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputFile * file = nil;
            int32_t file_signature = 0; [data getBytes:(void *)&file_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((file = [API17__Environment parseObject:data offset:_offset  implicitSignature:file_signature]) == nil)
               return nil;
            API17_InputPhotoCrop * crop = nil;
            int32_t crop_signature = 0; [data getBytes:(void *)&crop_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((crop = [API17__Environment parseObject:data offset:_offset  implicitSignature:crop_signature]) == nil)
               return nil;
            return [API17_InputChatPhoto inputChatUploadedPhotoWithFile:file crop:crop];
        } copy];
        parsers[@((int32_t)0xb2e1bf08)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_InputPhoto * pid = nil;
            int32_t pid_signature = 0; [data getBytes:(void *)&pid_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:pid_signature]) == nil)
               return nil;
            API17_InputPhotoCrop * crop = nil;
            int32_t crop_signature = 0; [data getBytes:(void *)&crop_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((crop = [API17__Environment parseObject:data offset:_offset  implicitSignature:crop_signature]) == nil)
               return nil;
            return [API17_InputChatPhoto inputChatPhotoWithPid:pid crop:crop];
        } copy];
        parsers[@((int32_t)0xe317af7e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_Updates updatesTooLong];
        } copy];
        parsers[@((int32_t)0xd3f45784)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Updates updateShortMessageWithPid:pid from_id:from_id message:message pts:pts date:date seq:seq];
        } copy];
        parsers[@((int32_t)0x2b2fbd4e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Updates updateShortChatMessageWithPid:pid from_id:from_id chat_id:chat_id message:message pts:pts date:date seq:seq];
        } copy];
        parsers[@((int32_t)0x78d4dec1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Update * update = nil;
            int32_t update_signature = 0; [data getBytes:(void *)&update_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((update = [API17__Environment parseObject:data offset:_offset  implicitSignature:update_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Updates updateShortWithUpdate:update date:date];
        } copy];
        parsers[@((int32_t)0x725b04c3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * updates = nil;
            int32_t updates_signature = 0; [data getBytes:(void *)&updates_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((updates = [API17__Environment parseObject:data offset:_offset  implicitSignature:updates_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq_start = nil;
            if ((seq_start = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Updates updatesCombinedWithUpdates:updates users:users chats:chats date:date seq_start:seq_start seq:seq];
        } copy];
        parsers[@((int32_t)0x74ae4240)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * updates = nil;
            int32_t updates_signature = 0; [data getBytes:(void *)&updates_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((updates = [API17__Environment parseObject:data offset:_offset  implicitSignature:updates_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Updates updatesWithUpdates:updates users:users chats:chats date:date seq:seq];
        } copy];
        parsers[@((int32_t)0x69796de9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * api_id = nil;
            if ((api_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * device_model = nil;
            if ((device_model = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * system_version = nil;
            if ((system_version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * app_version = nil;
            if ((app_version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * lang_code = nil;
            if ((lang_code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSObject * query = nil;
            int32_t query_signature = 0; [data getBytes:(void *)&query_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((query = [API17__Environment parseObject:data offset:_offset  implicitSignature:query_signature]) == nil)
               return nil;
            return [API17_InitConnection pinitConnectionWithApi_id:api_id device_model:device_model system_version:system_version app_version:app_version lang_code:lang_code query:query];
        } copy];
        parsers[@((int32_t)0x1f814f1f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [API17__Environment parseObject:data offset:_offset  implicitSignature:media_signature]) == nil)
               return nil;
            return [API17_DecryptedMessage decryptedMessageWithRandom_id:random_id random_bytes:random_bytes message:message media:media];
        } copy];
        parsers[@((int32_t)0xaa48327d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * random_id = nil;
            if ((random_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSData * random_bytes = nil;
            if ((random_bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            API17_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [API17__Environment parseObject:data offset:_offset  implicitSignature:action_signature]) == nil)
               return nil;
            return [API17_DecryptedMessage decryptedMessageServiceWithRandom_id:random_id random_bytes:random_bytes action:action];
        } copy];
        parsers[@((int32_t)0x3ded6320)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessageMedia messageMediaEmpty];
        } copy];
        parsers[@((int32_t)0xc8c45a2a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Photo * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaPhotoWithPhoto:photo];
        } copy];
        parsers[@((int32_t)0xa2d24290)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Video * video = nil;
            int32_t video_signature = 0; [data getBytes:(void *)&video_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((video = [API17__Environment parseObject:data offset:_offset  implicitSignature:video_signature]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaVideoWithVideo:video];
        } copy];
        parsers[@((int32_t)0x56e0d474)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_GeoPoint * geo = nil;
            int32_t geo_signature = 0; [data getBytes:(void *)&geo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((geo = [API17__Environment parseObject:data offset:_offset  implicitSignature:geo_signature]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaGeoWithGeo:geo];
        } copy];
        parsers[@((int32_t)0x5e7d2f39)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * phone_number = nil;
            if ((phone_number = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0x29632a36)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaUnsupportedWithBytes:bytes];
        } copy];
        parsers[@((int32_t)0x2fda2204)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Document * document = nil;
            int32_t document_signature = 0; [data getBytes:(void *)&document_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((document = [API17__Environment parseObject:data offset:_offset  implicitSignature:document_signature]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaDocumentWithDocument:document];
        } copy];
        parsers[@((int32_t)0xc6b68300)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Audio * audio = nil;
            int32_t audio_signature = 0; [data getBytes:(void *)&audio_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((audio = [API17__Environment parseObject:data offset:_offset  implicitSignature:audio_signature]) == nil)
               return nil;
            return [API17_MessageMedia messageMediaAudioWithAudio:audio];
        } copy];
        parsers[@((int32_t)0x56730bcc)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_Null null];
        } copy];
        parsers[@((int32_t)0x37c1011c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_ChatPhoto chatPhotoEmpty];
        } copy];
        parsers[@((int32_t)0x6153276a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_FileLocation * photo_small = nil;
            int32_t photo_small_signature = 0; [data getBytes:(void *)&photo_small_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo_small = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_small_signature]) == nil)
               return nil;
            API17_FileLocation * photo_big = nil;
            int32_t photo_big_signature = 0; [data getBytes:(void *)&photo_big_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo_big = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_big_signature]) == nil)
               return nil;
            return [API17_ChatPhoto chatPhotoWithPhoto_small:photo_small photo_big:photo_big];
        } copy];
        parsers[@((int32_t)0xcb9f372d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * msg_id = nil;
            if ((msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSObject * query = nil;
            int32_t query_signature = 0; [data getBytes:(void *)&query_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((query = [API17__Environment parseObject:data offset:_offset  implicitSignature:query_signature]) == nil)
               return nil;
            return [API17_InvokeAfterMsg invokeAfterMsgWithMsg_id:msg_id query:query];
        } copy];
        parsers[@((int32_t)0x5649dcc5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * results = nil;
            int32_t results_signature = 0; [data getBytes:(void *)&results_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((results = [API17__Environment parseObject:data offset:_offset  implicitSignature:results_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Suggested contacts_suggestedWithResults:results users:users];
        } copy];
        parsers[@((int32_t)0xa56c2a3e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * qts = nil;
            if ((qts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * unread_count = nil;
            if ((unread_count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_updates_State updates_stateWithPts:pts qts:qts date:date seq:seq unread_count:unread_count];
        } copy];
        parsers[@((int32_t)0x200250ba)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_User userEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x720535ec)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * phone = nil;
            if ((phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_UserProfilePhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            API17_UserStatus * status = nil;
            int32_t status_signature = 0; [data getBytes:(void *)&status_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:status_signature]) == nil)
               return nil;
            API17_Bool * inactive = nil;
            int32_t inactive_signature = 0; [data getBytes:(void *)&inactive_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((inactive = [API17__Environment parseObject:data offset:_offset  implicitSignature:inactive_signature]) == nil)
               return nil;
            return [API17_User userSelfWithPid:pid first_name:first_name last_name:last_name phone:phone photo:photo status:status inactive:inactive];
        } copy];
        parsers[@((int32_t)0xf2fb8319)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSString * phone = nil;
            if ((phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_UserProfilePhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            API17_UserStatus * status = nil;
            int32_t status_signature = 0; [data getBytes:(void *)&status_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:status_signature]) == nil)
               return nil;
            return [API17_User userContactWithPid:pid first_name:first_name last_name:last_name access_hash:access_hash phone:phone photo:photo status:status];
        } copy];
        parsers[@((int32_t)0x22e8ceb0)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSString * phone = nil;
            if ((phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_UserProfilePhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            API17_UserStatus * status = nil;
            int32_t status_signature = 0; [data getBytes:(void *)&status_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:status_signature]) == nil)
               return nil;
            return [API17_User userRequestWithPid:pid first_name:first_name last_name:last_name access_hash:access_hash phone:phone photo:photo status:status];
        } copy];
        parsers[@((int32_t)0x5214c89d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            API17_UserProfilePhoto * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            API17_UserStatus * status = nil;
            int32_t status_signature = 0; [data getBytes:(void *)&status_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:status_signature]) == nil)
               return nil;
            return [API17_User userForeignWithPid:pid first_name:first_name last_name:last_name access_hash:access_hash photo:photo status:status];
        } copy];
        parsers[@((int32_t)0xb29ad7cc)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_User userDeletedWithPid:pid first_name:first_name last_name:last_name];
        } copy];
        parsers[@((int32_t)0x83e5de54)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Message messageEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x567699b3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * flags = nil;
            if ((flags = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Peer * to_id = nil;
            int32_t to_id_signature = 0; [data getBytes:(void *)&to_id_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((to_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:to_id_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_MessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [API17__Environment parseObject:data offset:_offset  implicitSignature:media_signature]) == nil)
               return nil;
            return [API17_Message messageWithFlags:flags pid:pid from_id:from_id to_id:to_id date:date message:message media:media];
        } copy];
        parsers[@((int32_t)0xa367e716)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * flags = nil;
            if ((flags = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * fwd_from_id = nil;
            if ((fwd_from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * fwd_date = nil;
            if ((fwd_date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Peer * to_id = nil;
            int32_t to_id_signature = 0; [data getBytes:(void *)&to_id_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((to_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:to_id_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_MessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [API17__Environment parseObject:data offset:_offset  implicitSignature:media_signature]) == nil)
               return nil;
            return [API17_Message messageForwardedWithFlags:flags pid:pid fwd_from_id:fwd_from_id fwd_date:fwd_date from_id:from_id to_id:to_id date:date message:message media:media];
        } copy];
        parsers[@((int32_t)0x1d86f70e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * flags = nil;
            if ((flags = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * from_id = nil;
            if ((from_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_Peer * to_id = nil;
            int32_t to_id_signature = 0; [data getBytes:(void *)&to_id_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((to_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:to_id_signature]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_MessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [API17__Environment parseObject:data offset:_offset  implicitSignature:action_signature]) == nil)
               return nil;
            return [API17_Message messageServiceWithFlags:flags pid:pid from_id:from_id to_id:to_id date:date action:action];
        } copy];
        parsers[@((int32_t)0x14637196)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * volume_id = nil;
            if ((volume_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputFileLocation inputFileLocationWithVolume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x3d0364ec)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputFileLocation inputVideoFileLocationWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0xf5235d55)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputFileLocation inputEncryptedFileLocationWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x74dc404d)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputFileLocation inputAudioFileLocationWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x4e45abe9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputFileLocation inputDocumentFileLocationWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x1117dd5f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_GeoPoint geoPointEmpty];
        } copy];
        parsers[@((int32_t)0x2049d70c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * plong = nil;
            if ((plong = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * lat = nil;
            if ((lat = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            return [API17_GeoPoint geoPointWithPlong:plong lat:lat];
        } copy];
        parsers[@((int32_t)0x6e9e21ca)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * plong = nil;
            if ((plong = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * lat = nil;
            if ((lat = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            API17_GeoPlaceName * name = nil;
            int32_t name_signature = 0; [data getBytes:(void *)&name_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((name = [API17__Environment parseObject:data offset:_offset  implicitSignature:name_signature]) == nil)
               return nil;
            return [API17_GeoPoint geoPlaceWithPlong:plong lat:lat name:name];
        } copy];
        parsers[@((int32_t)0x1e36fded)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputPhoneCall inputPhoneCallWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0xfd2bb8a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ChatParticipants chatParticipantsForbiddenWithChat_id:chat_id];
        } copy];
        parsers[@((int32_t)0x7841b415)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * admin_id = nil;
            if ((admin_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * participants = nil;
            int32_t participants_signature = 0; [data getBytes:(void *)&participants_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((participants = [API17__Environment parseObject:data offset:_offset  implicitSignature:participants_signature]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ChatParticipants chatParticipantsWithChat_id:chat_id admin_id:admin_id participants:participants version:version];
        } copy];
        parsers[@((int32_t)0x2144ca19)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * error_code = nil;
            if ((error_code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * error_message = nil;
            if ((error_message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_RpcError rpc_errorWithError_code:error_code error_message:error_message];
        } copy];
        parsers[@((int32_t)0x7ae432f5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * query_id = nil;
            if ((query_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * error_code = nil;
            if ((error_code = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * error_message = nil;
            if ((error_message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_RpcError rpc_req_errorWithQuery_id:query_id error_code:error_code error_message:error_message];
        } copy];
        parsers[@((int32_t)0x8e1a1775)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * country = nil;
            if ((country = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * this_dc = nil;
            if ((this_dc = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * nearest_dc = nil;
            if ((nearest_dc = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_NearestDc nearestDcWithCountry:country this_dc:this_dc nearest_dc:nearest_dc];
        } copy];
        parsers[@((int32_t)0x3bcbf734)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pnew_nonce_hash1 = nil;
            if ((pnew_nonce_hash1 = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            return [API17_Set_client_DH_params_answer dh_gen_okWithNonce:nonce server_nonce:server_nonce pnew_nonce_hash1:pnew_nonce_hash1];
        } copy];
        parsers[@((int32_t)0x46dc1fb9)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pnew_nonce_hash2 = nil;
            if ((pnew_nonce_hash2 = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            return [API17_Set_client_DH_params_answer dh_gen_retryWithNonce:nonce server_nonce:server_nonce pnew_nonce_hash2:pnew_nonce_hash2];
        } copy];
        parsers[@((int32_t)0xa69dae02)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * pnew_nonce_hash3 = nil;
            if ((pnew_nonce_hash3 = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            return [API17_Set_client_DH_params_answer dh_gen_failWithNonce:nonce server_nonce:server_nonce pnew_nonce_hash3:pnew_nonce_hash3];
        } copy];
        parsers[@((int32_t)0x8dca6aa5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * photos = nil;
            int32_t photos_signature = 0; [data getBytes:(void *)&photos_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photos = [API17__Environment parseObject:data offset:_offset  implicitSignature:photos_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_photos_Photos photos_photosWithPhotos:photos users:users];
        } copy];
        parsers[@((int32_t)0x15051f54)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * photos = nil;
            int32_t photos_signature = 0; [data getBytes:(void *)&photos_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photos = [API17__Environment parseObject:data offset:_offset  implicitSignature:photos_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_photos_Photos photos_photosSliceWithCount:count photos:photos users:users];
        } copy];
        parsers[@((int32_t)0xad524315)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * imported = nil;
            int32_t imported_signature = 0; [data getBytes:(void *)&imported_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((imported = [API17__Environment parseObject:data offset:_offset  implicitSignature:imported_signature]) == nil)
               return nil;
            NSArray * retry_contacts = nil;
            int32_t retry_contacts_signature = 0; [data getBytes:(void *)&retry_contacts_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((retry_contacts = [API17__Environment parseObject:data offset:_offset  implicitSignature:retry_contacts_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_ImportedContacts contacts_importedContactsWithImported:imported retry_contacts:retry_contacts users:users];
        } copy];
        parsers[@((int32_t)0x276d3ec6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * msg_id = nil;
            if ((msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * answer_msg_id = nil;
            if ((answer_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * status = nil;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_MsgDetailedInfo msg_detailed_infoWithMsg_id:msg_id answer_msg_id:answer_msg_id bytes:bytes status:status];
        } copy];
        parsers[@((int32_t)0x809db6df)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * answer_msg_id = nil;
            if ((answer_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * status = nil;
            if ((status = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_MsgDetailedInfo msg_new_detailed_infoWithAnswer_msg_id:answer_msg_id bytes:bytes status:status];
        } copy];
        parsers[@((int32_t)0xbc799737)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_Bool boolFalse];
        } copy];
        parsers[@((int32_t)0x997275b5)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_Bool boolTrue];
        } copy];
        parsers[@((int32_t)0x17c6b5f6)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * phone_number = nil;
            if ((phone_number = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_User * user = nil;
            int32_t user_signature = 0; [data getBytes:(void *)&user_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((user = [API17__Environment parseObject:data offset:_offset  implicitSignature:user_signature]) == nil)
               return nil;
            return [API17_help_Support help_supportWithPhone_number:phone_number user:user];
        } copy];
        parsers[@((int32_t)0x3631cf4c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * chat_id = nil;
            if ((chat_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * distance = nil;
            if ((distance = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ChatLocated chatLocatedWithChat_id:chat_id distance:distance];
        } copy];
        parsers[@((int32_t)0x57e2f66c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessagesFilter inputMessagesFilterEmpty];
        } copy];
        parsers[@((int32_t)0x9609a51c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessagesFilter inputMessagesFilterPhotos];
        } copy];
        parsers[@((int32_t)0x9fc00e65)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessagesFilter inputMessagesFilterVideo];
        } copy];
        parsers[@((int32_t)0x56e9f0e4)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessagesFilter inputMessagesFilterPhotoVideo];
        } copy];
        parsers[@((int32_t)0x15ba6c40)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * dialogs = nil;
            int32_t dialogs_signature = 0; [data getBytes:(void *)&dialogs_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((dialogs = [API17__Environment parseObject:data offset:_offset  implicitSignature:dialogs_signature]) == nil)
               return nil;
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Dialogs messages_dialogsWithDialogs:dialogs messages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x71e094f3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * count = nil;
            if ((count = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSArray * dialogs = nil;
            int32_t dialogs_signature = 0; [data getBytes:(void *)&dialogs_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((dialogs = [API17__Environment parseObject:data offset:_offset  implicitSignature:dialogs_signature]) == nil)
               return nil;
            NSArray * messages = nil;
            int32_t messages_signature = 0; [data getBytes:(void *)&messages_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((messages = [API17__Environment parseObject:data offset:_offset  implicitSignature:messages_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Dialogs messages_dialogsSliceWithCount:count dialogs:dialogs messages:messages chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x18cb9f78)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * message = nil;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_help_InviteText help_inviteTextWithMessage:message];
        } copy];
        parsers[@((int32_t)0x3de191a1)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * mutual_contacts = nil;
            if ((mutual_contacts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_ContactSuggested contactSuggestedWithUser_id:user_id mutual_contacts:mutual_contacts];
        } copy];
        parsers[@((int32_t)0x3cf4b1be)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * mute_until = nil;
            if ((mute_until = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * sound = nil;
            if ((sound = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_Bool * show_previews = nil;
            int32_t show_previews_signature = 0; [data getBytes:(void *)&show_previews_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((show_previews = [API17__Environment parseObject:data offset:_offset  implicitSignature:show_previews_signature]) == nil)
               return nil;
            API17_InputPeerNotifyEvents * events = nil;
            int32_t events_signature = 0; [data getBytes:(void *)&events_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((events = [API17__Environment parseObject:data offset:_offset  implicitSignature:events_signature]) == nil)
               return nil;
            return [API17_InputPeerNotifySettings inputPeerNotifySettingsWithMute_until:mute_until sound:sound show_previews:show_previews events:events];
        } copy];
        parsers[@((int32_t)0x3203df8c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * ip_address = nil;
            if ((ip_address = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * pings = nil;
            int32_t pings_signature = 0; [data getBytes:(void *)&pings_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((pings = [API17__Environment parseObject:data offset:_offset  implicitSignature:pings_signature]) == nil)
               return nil;
            return [API17_DcNetworkStats dcPingStatsWithDc_id:dc_id ip_address:ip_address pings:pings];
        } copy];
        parsers[@((int32_t)0x9299359f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * max_delay = nil;
            if ((max_delay = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * wait_after = nil;
            if ((wait_after = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * max_wait = nil;
            if ((max_wait = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_HttpWait http_waitWithMax_delay:max_delay wait_after:wait_after max_wait:max_wait];
        } copy];
        parsers[@((int32_t)0x26bc3c3)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_PhoneConnection phoneConnectionNotReady];
        } copy];
        parsers[@((int32_t)0x3a84026a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * server = nil;
            if ((server = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * port = nil;
            if ((port = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * stream_id = nil;
            if ((stream_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_PhoneConnection phoneConnectionWithServer:server port:port stream_id:stream_id];
        } copy];
        parsers[@((int32_t)0xa9af2881)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Message * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSArray * links = nil;
            int32_t links_signature = 0; [data getBytes:(void *)&links_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((links = [API17__Environment parseObject:data offset:_offset  implicitSignature:links_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_StatedMessage messages_statedMessageLinkWithMessage:message chats:chats users:users links:links pts:pts seq:seq];
        } copy];
        parsers[@((int32_t)0xd07ae726)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Message * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            NSNumber * pts = nil;
            if ((pts = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * seq = nil;
            if ((seq = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_messages_StatedMessage messages_statedMessageWithMessage:message chats:chats users:users pts:pts seq:seq];
        } copy];
        parsers[@((int32_t)0x4e6ef65e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * scheme_raw = nil;
            if ((scheme_raw = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * types = nil;
            int32_t types_signature = 0; [data getBytes:(void *)&types_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((types = [API17__Environment parseObject:data offset:_offset  implicitSignature:types_signature]) == nil)
               return nil;
            NSArray * methods = nil;
            int32_t methods_signature = 0; [data getBytes:(void *)&methods_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((methods = [API17__Environment parseObject:data offset:_offset  implicitSignature:methods_signature]) == nil)
               return nil;
            NSNumber * version = nil;
            if ((version = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Scheme schemeWithScheme_raw:scheme_raw types:types methods:methods version:version];
        } copy];
        parsers[@((int32_t)0x263c9c58)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_Scheme schemeNotModified];
        } copy];
        parsers[@((int32_t)0x5e2ad36e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_RpcDropAnswer rpc_answer_unknown];
        } copy];
        parsers[@((int32_t)0xcd78e586)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_RpcDropAnswer rpc_answer_dropped_running];
        } copy];
        parsers[@((int32_t)0xa43ad8b7)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * msg_id = nil;
            if ((msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * seq_no = nil;
            if ((seq_no = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_RpcDropAnswer rpc_answer_droppedWithMsg_id:msg_id seq_no:seq_no bytes:bytes];
        } copy];
        parsers[@((int32_t)0x3f4e0648)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_messages_Message messages_messageEmpty];
        } copy];
        parsers[@((int32_t)0xff90c417)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Message * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [API17__Environment parseObject:data offset:_offset  implicitSignature:message_signature]) == nil)
               return nil;
            NSArray * chats = nil;
            int32_t chats_signature = 0; [data getBytes:(void *)&chats_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((chats = [API17__Environment parseObject:data offset:_offset  implicitSignature:chats_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_messages_Message messages_messageWithMessage:message chats:chats users:users];
        } copy];
        parsers[@((int32_t)0x6f038ebc)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * address = nil;
            if ((address = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_MessageAction messageActionGeoChatCreateWithTitle:title address:address];
        } copy];
        parsers[@((int32_t)0xc7d53de)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessageAction messageActionGeoChatCheckin];
        } copy];
        parsers[@((int32_t)0xb6aef7b0)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessageAction messageActionEmpty];
        } copy];
        parsers[@((int32_t)0xa6638b9a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_MessageAction messageActionChatCreateWithTitle:title users:users];
        } copy];
        parsers[@((int32_t)0xb5a1ce5a)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * title = nil;
            if ((title = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_MessageAction messageActionChatEditTitleWithTitle:title];
        } copy];
        parsers[@((int32_t)0x7fcb13a8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Photo * photo = nil;
            int32_t photo_signature = 0; [data getBytes:(void *)&photo_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_signature]) == nil)
               return nil;
            return [API17_MessageAction messageActionChatEditPhotoWithPhoto:photo];
        } copy];
        parsers[@((int32_t)0x95e3fbef)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessageAction messageActionChatDeletePhoto];
        } copy];
        parsers[@((int32_t)0x5e3cfc4b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_MessageAction messageActionChatAddUserWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0xb2ae9b0c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_MessageAction messageActionChatDeleteUserWithUser_id:user_id];
        } copy];
        parsers[@((int32_t)0xfc479b0f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_Bool * has_phone = nil;
            int32_t has_phone_signature = 0; [data getBytes:(void *)&has_phone_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((has_phone = [API17__Environment parseObject:data offset:_offset  implicitSignature:has_phone_signature]) == nil)
               return nil;
            return [API17_MessageAction messageActionSentRequestWithHas_phone:has_phone];
        } copy];
        parsers[@((int32_t)0x7f07d76c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_MessageAction messageActionAcceptRequest];
        } copy];
        parsers[@((int32_t)0x5366c915)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_PhoneCall phoneCallEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0xec7bbe3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * callee_id = nil;
            if ((callee_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_PhoneCall phoneCallWithPid:pid access_hash:access_hash date:date user_id:user_id callee_id:callee_id];
        } copy];
        parsers[@((int32_t)0xadd53cb3)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_PeerNotifyEvents peerNotifyEventsEmpty];
        } copy];
        parsers[@((int32_t)0x6d1ded88)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_PeerNotifyEvents peerNotifyEventsAll];
        } copy];
        parsers[@((int32_t)0x9ec20908)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * first_msg_id = nil;
            if ((first_msg_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * unique_id = nil;
            if ((unique_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * server_salt = nil;
            if ((server_salt = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_NewSession pnew_session_createdWithFirst_msg_id:first_msg_id unique_id:unique_id server_salt:server_salt];
        } copy];
        parsers[@((int32_t)0x424f8614)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * bytes = nil;
            if ((bytes = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_help_AppPrefs help_appPrefsWithBytes:bytes];
        } copy];
        parsers[@((int32_t)0x566000e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSArray * results = nil;
            int32_t results_signature = 0; [data getBytes:(void *)&results_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((results = [API17__Environment parseObject:data offset:_offset  implicitSignature:results_signature]) == nil)
               return nil;
            NSArray * users = nil;
            int32_t users_signature = 0; [data getBytes:(void *)&users_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((users = [API17__Environment parseObject:data offset:_offset  implicitSignature:users_signature]) == nil)
               return nil;
            return [API17_contacts_Found contacts_foundWithResults:results users:users];
        } copy];
        parsers[@((int32_t)0x70a68512)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_PeerNotifySettings peerNotifySettingsEmpty];
        } copy];
        parsers[@((int32_t)0xddbcd4a5)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * mute_until = nil;
            if ((mute_until = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * sound = nil;
            if ((sound = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            API17_Bool * show_previews = nil;
            int32_t show_previews_signature = 0; [data getBytes:(void *)&show_previews_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((show_previews = [API17__Environment parseObject:data offset:_offset  implicitSignature:show_previews_signature]) == nil)
               return nil;
            API17_PeerNotifyEvents * events = nil;
            int32_t events_signature = 0; [data getBytes:(void *)&events_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((events = [API17__Environment parseObject:data offset:_offset  implicitSignature:events_signature]) == nil)
               return nil;
            return [API17_PeerNotifySettings peerNotifySettingsWithMute_until:mute_until sound:sound show_previews:show_previews events:events];
        } copy];
        parsers[@((int32_t)0x21b59bef)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * name = nil;
            if ((name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * type = nil;
            if ((type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            return [API17_SchemeParam schemeParamWithName:name type:type];
        } copy];
        parsers[@((int32_t)0x4f11bae1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_UserProfilePhoto userProfilePhotoEmpty];
        } copy];
        parsers[@((int32_t)0x990d1493)] = [^id (NSData *data, NSUInteger* _offset)
        {
            API17_FileLocation * photo_small = nil;
            int32_t photo_small_signature = 0; [data getBytes:(void *)&photo_small_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo_small = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_small_signature]) == nil)
               return nil;
            API17_FileLocation * photo_big = nil;
            int32_t photo_big_signature = 0; [data getBytes:(void *)&photo_big_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((photo_big = [API17__Environment parseObject:data offset:_offset  implicitSignature:photo_big_signature]) == nil)
               return nil;
            return [API17_UserProfilePhoto userProfilePhotoWithPhoto_small:photo_small photo_big:photo_big];
        } copy];
        parsers[@((int32_t)0xb5890dba)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * nonce = nil;
            if ((nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSData * server_nonce = nil;
            if ((server_nonce = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x4bb5362b]) == nil)
               return nil;
            NSNumber * g = nil;
            if ((g = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * dh_prime = nil;
            if ((dh_prime = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * g_a = nil;
            if ((g_a = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * server_time = nil;
            if ((server_time = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Server_DH_inner_data server_DH_inner_dataWithNonce:nonce server_nonce:server_nonce g:g dh_prime:dh_prime g_a:g_a server_time:server_time];
        } copy];
        parsers[@((int32_t)0x1cd7bf0d)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_InputPhoto inputPhotoEmpty];
        } copy];
        parsers[@((int32_t)0xfb95c6c4)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_InputPhoto inputPhotoWithPid:pid access_hash:access_hash];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset)
        {
            return [API17_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * thumb = nil;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x4cee6ef3)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * thumb = nil;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h duration:duration w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * lat = nil;
            if ((lat = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x2210c154]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSString * phone_number = nil;
            if ((phone_number = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0xb095434b)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSData * thumb = nil;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h file_name:file_name mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x6080758f)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xc10658a8)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Video videoEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x388fa391)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:thumb_signature]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Video videoWithPid:pid access_hash:access_hash user_id:user_id date:date caption:caption duration:duration mime_type:mime_type size:size thumb:thumb dc_id:dc_id w:w h:h];
        } copy];
        parsers[@((int32_t)0xab7ec0a0)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_EncryptedChat encryptedChatEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x3bf703dc)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * admin_id = nil;
            if ((admin_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * participant_id = nil;
            if ((participant_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_EncryptedChat encryptedChatWaitingWithPid:pid access_hash:access_hash date:date admin_id:admin_id participant_id:participant_id];
        } copy];
        parsers[@((int32_t)0x13d6dd27)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_EncryptedChat encryptedChatDiscardedWithPid:pid];
        } copy];
        parsers[@((int32_t)0xc878527e)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * admin_id = nil;
            if ((admin_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * participant_id = nil;
            if ((participant_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * g_a = nil;
            if ((g_a = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            return [API17_EncryptedChat encryptedChatRequestedWithPid:pid access_hash:access_hash date:date admin_id:admin_id participant_id:participant_id g_a:g_a];
        } copy];
        parsers[@((int32_t)0xfa56ce36)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * admin_id = nil;
            if ((admin_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * participant_id = nil;
            if ((participant_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSData * g_a_or_b = nil;
            if ((g_a_or_b = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xebefb69e]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_EncryptedChat encryptedChatWithPid:pid access_hash:access_hash date:date admin_id:admin_id participant_id:participant_id g_a_or_b:g_a_or_b key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0x36f8c871)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_Document documentEmptyWithPid:pid];
        } copy];
        parsers[@((int32_t)0x9efc6326)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * pid = nil;
            if ((pid = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xb5286e24]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            API17_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [API17__Environment parseObject:data offset:_offset  implicitSignature:thumb_signature]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            return [API17_Document documentWithPid:pid access_hash:access_hash user_id:user_id date:date file_name:file_name mime_type:mime_type size:size thumb:thumb dc_id:dc_id];
        } copy];
        parsers[@((int32_t)0xd0028438)] = [^id (NSData *data, NSUInteger* _offset)
        {
            NSNumber * user_id = nil;
            if ((user_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0xa8509bda]) == nil)
               return nil;
            NSNumber * client_id = nil;
            if ((client_id = [API17__Environment parseObject:data offset:_offset  implicitSignature:(int32_t)0x22076cba]) == nil)
               return nil;
            return [API17_ImportedContact importedContactWithUser_id:user_id client_id:client_id];
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
     API17__Serializer *serializer = objc_getAssociatedObject(object, API17__Serializer_Key);
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
    return [self parseObject:data offset:&offset implicitSignature:constructorSignature];
}

+ (id)parseObject:(NSData *)data offset:(NSUInteger *)offset implicitSignature:(int32_t)implicitSignature
{
    id (^parser)(NSData *data, NSUInteger *offset) = [self parserByConstructorSignature:implicitSignature];
    if (parser)
        return parser(data, offset);
    return nil;
}

@end

@interface API17_BuiltinSerializer_Int : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Int

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

@interface API17_BuiltinSerializer_Long : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Long

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

@interface API17_BuiltinSerializer_Double : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Double

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

@interface API17_BuiltinSerializer_String : API17__Serializer
@end

@implementation API17_BuiltinSerializer_String

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

@interface API17_BuiltinSerializer_Bytes : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Bytes

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

@interface API17_BuiltinSerializer_Int128 : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Int128

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

@interface API17_BuiltinSerializer_Int256 : API17__Serializer
@end

@implementation API17_BuiltinSerializer_Int256

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


@interface API17_InputGeoPlaceName ()

@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * district;
@property (nonatomic, strong) NSString * street;

@end

@interface API17_InputGeoPlaceName_inputGeoPlaceName ()

@end

@implementation API17_InputGeoPlaceName

+ (API17_InputGeoPlaceName_inputGeoPlaceName *)inputGeoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street
{
    API17_InputGeoPlaceName_inputGeoPlaceName *_object = [[API17_InputGeoPlaceName_inputGeoPlaceName alloc] init];
    _object.country = [API17__Serializer addSerializerToObject:[country copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.state = [API17__Serializer addSerializerToObject:[state copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.city = [API17__Serializer addSerializerToObject:[city copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.district = [API17__Serializer addSerializerToObject:[district copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.street = [API17__Serializer addSerializerToObject:[street copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_InputGeoPlaceName_inputGeoPlaceName

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x68afa7d4 serializeBlock:^bool (API17_InputGeoPlaceName_inputGeoPlaceName *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.country data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.state data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.city data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.district data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.street data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputGeoPoint ()

@end

@interface API17_InputGeoPoint_inputGeoPointEmpty ()

@end

@interface API17_InputGeoPoint_inputGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@implementation API17_InputGeoPoint

+ (API17_InputGeoPoint_inputGeoPointEmpty *)inputGeoPointEmpty
{
    API17_InputGeoPoint_inputGeoPointEmpty *_object = [[API17_InputGeoPoint_inputGeoPointEmpty alloc] init];
    return _object;
}

+ (API17_InputGeoPoint_inputGeoPoint *)inputGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    API17_InputGeoPoint_inputGeoPoint *_object = [[API17_InputGeoPoint_inputGeoPoint alloc] init];
    _object.lat = [API17__Serializer addSerializerToObject:[lat copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.plong = [API17__Serializer addSerializerToObject:[plong copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    return _object;
}


@end

@implementation API17_InputGeoPoint_inputGeoPointEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe4c123d6 serializeBlock:^bool (__unused API17_InputGeoPoint_inputGeoPointEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputGeoPoint_inputGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf3b7acc9 serializeBlock:^bool (API17_InputGeoPoint_inputGeoPoint *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_Chat ()

@property (nonatomic, strong) API17_Chat * chat;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_messages_Chat_messages_chat ()

@end

@implementation API17_messages_Chat

+ (API17_messages_Chat_messages_chat *)messages_chatWithChat:(API17_Chat *)chat users:(NSArray *)users
{
    API17_messages_Chat_messages_chat *_object = [[API17_messages_Chat_messages_chat alloc] init];
    _object.chat = chat;
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_Chat_messages_chat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x40e9002a serializeBlock:^bool (API17_messages_Chat_messages_chat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ChatFull ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) API17_ChatParticipants * participants;
@property (nonatomic, strong) API17_Photo * chat_photo;
@property (nonatomic, strong) API17_PeerNotifySettings * notify_settings;

@end

@interface API17_ChatFull_chatFull ()

@end

@implementation API17_ChatFull

+ (API17_ChatFull_chatFull *)chatFullWithPid:(NSNumber *)pid participants:(API17_ChatParticipants *)participants chat_photo:(API17_Photo *)chat_photo notify_settings:(API17_PeerNotifySettings *)notify_settings
{
    API17_ChatFull_chatFull *_object = [[API17_ChatFull_chatFull alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.participants = participants;
    _object.chat_photo = chat_photo;
    _object.notify_settings = notify_settings;
    return _object;
}


@end

@implementation API17_ChatFull_chatFull

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x630e61be serializeBlock:^bool (API17_ChatFull_chatFull *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.participants data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chat_photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.notify_settings data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ChatParticipant ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * inviter_id;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_ChatParticipant_chatParticipant ()

@end

@implementation API17_ChatParticipant

+ (API17_ChatParticipant_chatParticipant *)chatParticipantWithUser_id:(NSNumber *)user_id inviter_id:(NSNumber *)inviter_id date:(NSNumber *)date
{
    API17_ChatParticipant_chatParticipant *_object = [[API17_ChatParticipant_chatParticipant alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.inviter_id = [API17__Serializer addSerializerToObject:[inviter_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ChatParticipant_chatParticipant

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc8d7493e serializeBlock:^bool (API17_ChatParticipant_chatParticipant *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.inviter_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_updates_Difference ()

@end

@interface API17_updates_Difference_updates_differenceEmpty ()

@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_updates_Difference_updates_difference ()

@property (nonatomic, strong) NSArray * pnew_messages;
@property (nonatomic, strong) NSArray * pnew_encrypted_messages;
@property (nonatomic, strong) NSArray * other_updates;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) API17_updates_State * state;

@end

@interface API17_updates_Difference_updates_differenceSlice ()

@property (nonatomic, strong) NSArray * pnew_messages;
@property (nonatomic, strong) NSArray * pnew_encrypted_messages;
@property (nonatomic, strong) NSArray * other_updates;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) API17_updates_State * intermediate_state;

@end

@implementation API17_updates_Difference

+ (API17_updates_Difference_updates_differenceEmpty *)updates_differenceEmptyWithDate:(NSNumber *)date seq:(NSNumber *)seq
{
    API17_updates_Difference_updates_differenceEmpty *_object = [[API17_updates_Difference_updates_differenceEmpty alloc] init];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_updates_Difference_updates_difference *)updates_differenceWithPnew_messages:(NSArray *)pnew_messages pnew_encrypted_messages:(NSArray *)pnew_encrypted_messages other_updates:(NSArray *)other_updates chats:(NSArray *)chats users:(NSArray *)users state:(API17_updates_State *)state
{
    API17_updates_Difference_updates_difference *_object = [[API17_updates_Difference_updates_difference alloc] init];
    _object.pnew_messages = [API17__Serializer addSerializerToObject:[pnew_messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pnew_encrypted_messages = [API17__Serializer addSerializerToObject:[pnew_encrypted_messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.other_updates = [API17__Serializer addSerializerToObject:[other_updates copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.state = state;
    return _object;
}

+ (API17_updates_Difference_updates_differenceSlice *)updates_differenceSliceWithPnew_messages:(NSArray *)pnew_messages pnew_encrypted_messages:(NSArray *)pnew_encrypted_messages other_updates:(NSArray *)other_updates chats:(NSArray *)chats users:(NSArray *)users intermediate_state:(API17_updates_State *)intermediate_state
{
    API17_updates_Difference_updates_differenceSlice *_object = [[API17_updates_Difference_updates_differenceSlice alloc] init];
    _object.pnew_messages = [API17__Serializer addSerializerToObject:[pnew_messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pnew_encrypted_messages = [API17__Serializer addSerializerToObject:[pnew_encrypted_messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.other_updates = [API17__Serializer addSerializerToObject:[other_updates copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.intermediate_state = intermediate_state;
    return _object;
}


@end

@implementation API17_updates_Difference_updates_differenceEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5d75a138 serializeBlock:^bool (API17_updates_Difference_updates_differenceEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_updates_Difference_updates_difference

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf49ca0 serializeBlock:^bool (API17_updates_Difference_updates_difference *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pnew_messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pnew_encrypted_messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.other_updates data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.state data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_updates_Difference_updates_differenceSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa8fb1981 serializeBlock:^bool (API17_updates_Difference_updates_differenceSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pnew_messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pnew_encrypted_messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.other_updates data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.intermediate_state data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_SchemeMethod ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSString * method;
@property (nonatomic, strong) NSArray * params;
@property (nonatomic, strong) NSString * type;

@end

@interface API17_SchemeMethod_schemeMethod ()

@end

@implementation API17_SchemeMethod

+ (API17_SchemeMethod_schemeMethod *)schemeMethodWithPid:(NSNumber *)pid method:(NSString *)method params:(NSArray *)params type:(NSString *)type
{
    API17_SchemeMethod_schemeMethod *_object = [[API17_SchemeMethod_schemeMethod alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.method = [API17__Serializer addSerializerToObject:[method copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.params = [API17__Serializer addSerializerToObject:[params copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_SchemeMethod_schemeMethod

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x479357c0 serializeBlock:^bool (API17_SchemeMethod_schemeMethod *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.method data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.params data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_GeoChatMessage ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_GeoChatMessage_geoChatMessageEmpty ()

@end

@interface API17_GeoChatMessage_geoChatMessage ()

@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) API17_MessageMedia * media;

@end

@interface API17_GeoChatMessage_geoChatMessageService ()

@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) API17_MessageAction * action;

@end

@implementation API17_GeoChatMessage

+ (API17_GeoChatMessage_geoChatMessageEmpty *)geoChatMessageEmptyWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid
{
    API17_GeoChatMessage_geoChatMessageEmpty *_object = [[API17_GeoChatMessage_geoChatMessageEmpty alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_GeoChatMessage_geoChatMessage *)geoChatMessageWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid from_id:(NSNumber *)from_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media
{
    API17_GeoChatMessage_geoChatMessage *_object = [[API17_GeoChatMessage_geoChatMessage alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (API17_GeoChatMessage_geoChatMessageService *)geoChatMessageServiceWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid from_id:(NSNumber *)from_id date:(NSNumber *)date action:(API17_MessageAction *)action
{
    API17_GeoChatMessage_geoChatMessageService *_object = [[API17_GeoChatMessage_geoChatMessageService alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation API17_GeoChatMessage_geoChatMessageEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x60311a9b serializeBlock:^bool (API17_GeoChatMessage_geoChatMessageEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_GeoChatMessage_geoChatMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4505f8e1 serializeBlock:^bool (API17_GeoChatMessage_geoChatMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_GeoChatMessage_geoChatMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd34fa24e serializeBlock:^bool (API17_GeoChatMessage_geoChatMessageService *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ProtoMessage ()

@property (nonatomic, strong) NSNumber * msg_id;
@property (nonatomic, strong) NSNumber * seqno;
@property (nonatomic, strong) NSNumber * bytes;
@property (nonatomic, strong) NSObject * body;

@end

@interface API17_ProtoMessage_protoMessage ()

@end

@implementation API17_ProtoMessage

+ (API17_ProtoMessage_protoMessage *)protoMessageWithMsg_id:(NSNumber *)msg_id seqno:(NSNumber *)seqno bytes:(NSNumber *)bytes body:(NSObject *)body
{
    API17_ProtoMessage_protoMessage *_object = [[API17_ProtoMessage_protoMessage alloc] init];
    _object.msg_id = [API17__Serializer addSerializerToObject:[msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.seqno = [API17__Serializer addSerializerToObject:[seqno copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.body = body;
    return _object;
}


@end

@implementation API17_ProtoMessage_protoMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5bb8e511 serializeBlock:^bool (API17_ProtoMessage_protoMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seqno data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.body data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPhotoCrop ()

@end

@interface API17_InputPhotoCrop_inputPhotoCropAuto ()

@end

@interface API17_InputPhotoCrop_inputPhotoCrop ()

@property (nonatomic, strong) NSNumber * crop_left;
@property (nonatomic, strong) NSNumber * crop_top;
@property (nonatomic, strong) NSNumber * crop_width;

@end

@implementation API17_InputPhotoCrop

+ (API17_InputPhotoCrop_inputPhotoCropAuto *)inputPhotoCropAuto
{
    API17_InputPhotoCrop_inputPhotoCropAuto *_object = [[API17_InputPhotoCrop_inputPhotoCropAuto alloc] init];
    return _object;
}

+ (API17_InputPhotoCrop_inputPhotoCrop *)inputPhotoCropWithCrop_left:(NSNumber *)crop_left crop_top:(NSNumber *)crop_top crop_width:(NSNumber *)crop_width
{
    API17_InputPhotoCrop_inputPhotoCrop *_object = [[API17_InputPhotoCrop_inputPhotoCrop alloc] init];
    _object.crop_left = [API17__Serializer addSerializerToObject:[crop_left copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.crop_top = [API17__Serializer addSerializerToObject:[crop_top copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.crop_width = [API17__Serializer addSerializerToObject:[crop_width copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    return _object;
}


@end

@implementation API17_InputPhotoCrop_inputPhotoCropAuto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xade6b004 serializeBlock:^bool (__unused API17_InputPhotoCrop_inputPhotoCropAuto *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPhotoCrop_inputPhotoCrop

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd9915325 serializeBlock:^bool (API17_InputPhotoCrop_inputPhotoCrop *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.crop_left data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.crop_top data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.crop_width data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DestroySessionRes ()

@property (nonatomic, strong) NSNumber * session_id;

@end

@interface API17_DestroySessionRes_destroy_session_ok ()

@end

@interface API17_DestroySessionRes_destroy_session_none ()

@end

@implementation API17_DestroySessionRes

+ (API17_DestroySessionRes_destroy_session_ok *)destroy_session_okWithSession_id:(NSNumber *)session_id
{
    API17_DestroySessionRes_destroy_session_ok *_object = [[API17_DestroySessionRes_destroy_session_ok alloc] init];
    _object.session_id = [API17__Serializer addSerializerToObject:[session_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_DestroySessionRes_destroy_session_none *)destroy_session_noneWithSession_id:(NSNumber *)session_id
{
    API17_DestroySessionRes_destroy_session_none *_object = [[API17_DestroySessionRes_destroy_session_none alloc] init];
    _object.session_id = [API17__Serializer addSerializerToObject:[session_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_DestroySessionRes_destroy_session_ok

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe22045fc serializeBlock:^bool (API17_DestroySessionRes_destroy_session_ok *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.session_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DestroySessionRes_destroy_session_none

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x62d350c9 serializeBlock:^bool (API17_DestroySessionRes_destroy_session_none *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.session_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Photo ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Photo_photoEmpty ()

@end

@interface API17_Photo_photo ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) API17_GeoPoint * geo;
@property (nonatomic, strong) NSArray * sizes;

@end

@interface API17_Photo_wallPhoto ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) API17_GeoPoint * geo;
@property (nonatomic, strong) API17_Bool * unread;
@property (nonatomic, strong) NSArray * sizes;

@end

@implementation API17_Photo

+ (API17_Photo_photoEmpty *)photoEmptyWithPid:(NSNumber *)pid
{
    API17_Photo_photoEmpty *_object = [[API17_Photo_photoEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Photo_photo *)photoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption geo:(API17_GeoPoint *)geo sizes:(NSArray *)sizes
{
    API17_Photo_photo *_object = [[API17_Photo_photo alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.caption = [API17__Serializer addSerializerToObject:[caption copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.geo = geo;
    _object.sizes = [API17__Serializer addSerializerToObject:[sizes copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_Photo_wallPhoto *)wallPhotoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption geo:(API17_GeoPoint *)geo unread:(API17_Bool *)unread sizes:(NSArray *)sizes
{
    API17_Photo_wallPhoto *_object = [[API17_Photo_wallPhoto alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.caption = [API17__Serializer addSerializerToObject:[caption copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.geo = geo;
    _object.unread = unread;
    _object.sizes = [API17__Serializer addSerializerToObject:[sizes copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_Photo_photoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2331b22d serializeBlock:^bool (API17_Photo_photoEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Photo_photo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x22b56751 serializeBlock:^bool (API17_Photo_photo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.geo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.sizes data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Photo_wallPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x559dc1e2 serializeBlock:^bool (API17_Photo_wallPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.geo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.unread data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.sizes data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Chat ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Chat_geoChat ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * venue;
@property (nonatomic, strong) API17_GeoPoint * geo;
@property (nonatomic, strong) API17_ChatPhoto * photo;
@property (nonatomic, strong) NSNumber * participants_count;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) API17_Bool * checked_in;
@property (nonatomic, strong) NSNumber * version;

@end

@interface API17_Chat_chatEmpty ()

@end

@interface API17_Chat_chat ()

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) API17_ChatPhoto * photo;
@property (nonatomic, strong) NSNumber * participants_count;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) API17_Bool * left;
@property (nonatomic, strong) NSNumber * version;

@end

@interface API17_Chat_chatForbidden ()

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * date;

@end

@implementation API17_Chat

+ (API17_Chat_geoChat *)geoChatWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash title:(NSString *)title address:(NSString *)address venue:(NSString *)venue geo:(API17_GeoPoint *)geo photo:(API17_ChatPhoto *)photo participants_count:(NSNumber *)participants_count date:(NSNumber *)date checked_in:(API17_Bool *)checked_in version:(NSNumber *)version
{
    API17_Chat_geoChat *_object = [[API17_Chat_geoChat alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.address = [API17__Serializer addSerializerToObject:[address copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.venue = [API17__Serializer addSerializerToObject:[venue copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.geo = geo;
    _object.photo = photo;
    _object.participants_count = [API17__Serializer addSerializerToObject:[participants_count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.checked_in = checked_in;
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Chat_chatEmpty *)chatEmptyWithPid:(NSNumber *)pid
{
    API17_Chat_chatEmpty *_object = [[API17_Chat_chatEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Chat_chat *)chatWithPid:(NSNumber *)pid title:(NSString *)title photo:(API17_ChatPhoto *)photo participants_count:(NSNumber *)participants_count date:(NSNumber *)date left:(API17_Bool *)left version:(NSNumber *)version
{
    API17_Chat_chat *_object = [[API17_Chat_chat alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.photo = photo;
    _object.participants_count = [API17__Serializer addSerializerToObject:[participants_count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.left = left;
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Chat_chatForbidden *)chatForbiddenWithPid:(NSNumber *)pid title:(NSString *)title date:(NSNumber *)date
{
    API17_Chat_chatForbidden *_object = [[API17_Chat_chatForbidden alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Chat_geoChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x75eaea5a serializeBlock:^bool (API17_Chat_geoChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.address data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.venue data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.geo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.participants_count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.checked_in data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Chat_chatEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9ba2d800 serializeBlock:^bool (API17_Chat_chatEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Chat_chat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6e9c9bc7 serializeBlock:^bool (API17_Chat_chat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.participants_count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.left data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Chat_chatForbidden

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfb0ccc41 serializeBlock:^bool (API17_Chat_chatForbidden *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Requests ()

@property (nonatomic, strong) NSArray * requests;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Requests_contacts_requests ()

@end

@interface API17_contacts_Requests_contacts_requestsSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_contacts_Requests

+ (API17_contacts_Requests_contacts_requests *)contacts_requestsWithRequests:(NSArray *)requests users:(NSArray *)users
{
    API17_contacts_Requests_contacts_requests *_object = [[API17_contacts_Requests_contacts_requests alloc] init];
    _object.requests = [API17__Serializer addSerializerToObject:[requests copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_contacts_Requests_contacts_requestsSlice *)contacts_requestsSliceWithCount:(NSNumber *)count requests:(NSArray *)requests users:(NSArray *)users
{
    API17_contacts_Requests_contacts_requestsSlice *_object = [[API17_contacts_Requests_contacts_requestsSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.requests = [API17__Serializer addSerializerToObject:[requests copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_Requests_contacts_requests

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6262c36c serializeBlock:^bool (API17_contacts_Requests_contacts_requests *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.requests data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_Requests_contacts_requestsSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6f585b8c serializeBlock:^bool (API17_contacts_Requests_contacts_requestsSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.requests data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Server_DH_Params ()

@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;

@end

@interface API17_Server_DH_Params_server_DH_params_fail ()

@property (nonatomic, strong) NSData * pnew_nonce_hash;

@end

@interface API17_Server_DH_Params_server_DH_params_ok ()

@property (nonatomic, strong) NSData * encrypted_answer;

@end

@implementation API17_Server_DH_Params

+ (API17_Server_DH_Params_server_DH_params_fail *)server_DH_params_failWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash:(NSData *)pnew_nonce_hash
{
    API17_Server_DH_Params_server_DH_params_fail *_object = [[API17_Server_DH_Params_server_DH_params_fail alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pnew_nonce_hash = [API17__Serializer addSerializerToObject:[pnew_nonce_hash copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    return _object;
}

+ (API17_Server_DH_Params_server_DH_params_ok *)server_DH_params_okWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_answer:(NSData *)encrypted_answer
{
    API17_Server_DH_Params_server_DH_params_ok *_object = [[API17_Server_DH_Params_server_DH_params_ok alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.encrypted_answer = [API17__Serializer addSerializerToObject:[encrypted_answer copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_Server_DH_Params_server_DH_params_fail

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x79cb045d serializeBlock:^bool (API17_Server_DH_Params_server_DH_params_fail *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_nonce_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Server_DH_Params_server_DH_params_ok

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd0e8075c serializeBlock:^bool (API17_Server_DH_Params_server_DH_params_ok *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.encrypted_answer data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DecryptedMessageAction ()

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttl_seconds;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionViewMessage ()

@property (nonatomic, strong) NSNumber * random_id;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage ()

@property (nonatomic, strong) NSNumber * random_id;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionScreenshot ()

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@implementation API17_DecryptedMessageAction

+ (API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds
{
    API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttl_seconds = [API17__Serializer addSerializerToObject:[ttl_seconds copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageAction_decryptedMessageActionViewMessage *)decryptedMessageActionViewMessageWithRandom_id:(NSNumber *)random_id
{
    API17_DecryptedMessageAction_decryptedMessageActionViewMessage *_object = [[API17_DecryptedMessageAction_decryptedMessageActionViewMessage alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage *)decryptedMessageActionScreenshotMessageWithRandom_id:(NSNumber *)random_id
{
    API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage *_object = [[API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageAction_decryptedMessageActionScreenshot *)decryptedMessageActionScreenshot
{
    API17_DecryptedMessageAction_decryptedMessageActionScreenshot *_object = [[API17_DecryptedMessageAction_decryptedMessageActionScreenshot alloc] init];
    return _object;
}

+ (API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids
{
    API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.random_ids = [API17__Serializer addSerializerToObject:[random_ids copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    API17_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[API17_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}


@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.ttl_seconds data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionViewMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1e1604f2 serializeBlock:^bool (API17_DecryptedMessageAction_decryptedMessageActionViewMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb56b1bc5 serializeBlock:^bool (API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionScreenshot

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd9f5c5d4 serializeBlock:^bool (__unused API17_DecryptedMessageAction_decryptedMessageActionScreenshot *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused API17_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_GeoPlaceName ()

@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * district;
@property (nonatomic, strong) NSString * street;

@end

@interface API17_GeoPlaceName_geoPlaceName ()

@end

@implementation API17_GeoPlaceName

+ (API17_GeoPlaceName_geoPlaceName *)geoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street
{
    API17_GeoPlaceName_geoPlaceName *_object = [[API17_GeoPlaceName_geoPlaceName alloc] init];
    _object.country = [API17__Serializer addSerializerToObject:[country copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.state = [API17__Serializer addSerializerToObject:[state copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.city = [API17__Serializer addSerializerToObject:[city copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.district = [API17__Serializer addSerializerToObject:[district copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.street = [API17__Serializer addSerializerToObject:[street copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_GeoPlaceName_geoPlaceName

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3819538f serializeBlock:^bool (API17_GeoPlaceName_geoPlaceName *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.country data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.state data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.city data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.district data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.street data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_UserFull ()

@property (nonatomic, strong) API17_User * user;
@property (nonatomic, strong) API17_contacts_Link * link;
@property (nonatomic, strong) API17_Photo * profile_photo;
@property (nonatomic, strong) API17_PeerNotifySettings * notify_settings;
@property (nonatomic, strong) API17_Bool * blocked;
@property (nonatomic, strong) NSString * real_first_name;
@property (nonatomic, strong) NSString * real_last_name;

@end

@interface API17_UserFull_userFull ()

@end

@implementation API17_UserFull

+ (API17_UserFull_userFull *)userFullWithUser:(API17_User *)user link:(API17_contacts_Link *)link profile_photo:(API17_Photo *)profile_photo notify_settings:(API17_PeerNotifySettings *)notify_settings blocked:(API17_Bool *)blocked real_first_name:(NSString *)real_first_name real_last_name:(NSString *)real_last_name
{
    API17_UserFull_userFull *_object = [[API17_UserFull_userFull alloc] init];
    _object.user = user;
    _object.link = link;
    _object.profile_photo = profile_photo;
    _object.notify_settings = notify_settings;
    _object.blocked = blocked;
    _object.real_first_name = [API17__Serializer addSerializerToObject:[real_first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.real_last_name = [API17__Serializer addSerializerToObject:[real_last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_UserFull_userFull

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x771095da serializeBlock:^bool (API17_UserFull_userFull *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.link data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.profile_photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.notify_settings data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.blocked data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.real_first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.real_last_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPeerNotifyEvents ()

@end

@interface API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty ()

@end

@interface API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll ()

@end

@implementation API17_InputPeerNotifyEvents

+ (API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty *)inputPeerNotifyEventsEmpty
{
    API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty *_object = [[API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty alloc] init];
    return _object;
}

+ (API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll *)inputPeerNotifyEventsAll
{
    API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll *_object = [[API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll alloc] init];
    return _object;
}


@end

@implementation API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf03064d8 serializeBlock:^bool (__unused API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe86a2c74 serializeBlock:^bool (__unused API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DcOption ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSString * hostname;
@property (nonatomic, strong) NSString * ip_address;
@property (nonatomic, strong) NSNumber * port;

@end

@interface API17_DcOption_dcOption ()

@end

@implementation API17_DcOption

+ (API17_DcOption_dcOption *)dcOptionWithPid:(NSNumber *)pid hostname:(NSString *)hostname ip_address:(NSString *)ip_address port:(NSNumber *)port
{
    API17_DcOption_dcOption *_object = [[API17_DcOption_dcOption alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.hostname = [API17__Serializer addSerializerToObject:[hostname copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.ip_address = [API17__Serializer addSerializerToObject:[ip_address copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.port = [API17__Serializer addSerializerToObject:[port copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_DcOption_dcOption

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2ec2a43c serializeBlock:^bool (API17_DcOption_dcOption *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.hostname data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.ip_address data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.port data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgsStateReq ()

@property (nonatomic, strong) NSArray * msg_ids;

@end

@interface API17_MsgsStateReq_msgs_state_req ()

@end

@implementation API17_MsgsStateReq

+ (API17_MsgsStateReq_msgs_state_req *)msgs_state_reqWithMsg_ids:(NSArray *)msg_ids
{
    API17_MsgsStateReq_msgs_state_req *_object = [[API17_MsgsStateReq_msgs_state_req alloc] init];
    _object.msg_ids = [API17__Serializer addSerializerToObject:[msg_ids copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_MsgsStateReq_msgs_state_req

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xda69fb52 serializeBlock:^bool (API17_MsgsStateReq_msgs_state_req *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_help_AppUpdate ()

@end

@interface API17_help_AppUpdate_help_appUpdate ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) API17_Bool * critical;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * text;

@end

@interface API17_help_AppUpdate_help_noAppUpdate ()

@end

@implementation API17_help_AppUpdate

+ (API17_help_AppUpdate_help_appUpdate *)help_appUpdateWithPid:(NSNumber *)pid critical:(API17_Bool *)critical url:(NSString *)url text:(NSString *)text
{
    API17_help_AppUpdate_help_appUpdate *_object = [[API17_help_AppUpdate_help_appUpdate alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.critical = critical;
    _object.url = [API17__Serializer addSerializerToObject:[url copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.text = [API17__Serializer addSerializerToObject:[text copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_help_AppUpdate_help_noAppUpdate *)help_noAppUpdate
{
    API17_help_AppUpdate_help_noAppUpdate *_object = [[API17_help_AppUpdate_help_noAppUpdate alloc] init];
    return _object;
}


@end

@implementation API17_help_AppUpdate_help_appUpdate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8987f311 serializeBlock:^bool (API17_help_AppUpdate_help_appUpdate *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.critical data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.url data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.text data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_help_AppUpdate_help_noAppUpdate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc45a6536 serializeBlock:^bool (__unused API17_help_AppUpdate_help_noAppUpdate *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_SentLink ()

@property (nonatomic, strong) API17_messages_Message * message;
@property (nonatomic, strong) API17_contacts_Link * link;

@end

@interface API17_contacts_SentLink_contacts_sentLink ()

@end

@implementation API17_contacts_SentLink

+ (API17_contacts_SentLink_contacts_sentLink *)contacts_sentLinkWithMessage:(API17_messages_Message *)message link:(API17_contacts_Link *)link
{
    API17_contacts_SentLink_contacts_sentLink *_object = [[API17_contacts_SentLink_contacts_sentLink alloc] init];
    _object.message = message;
    _object.link = link;
    return _object;
}


@end

@implementation API17_contacts_SentLink_contacts_sentLink

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x96a0c63e serializeBlock:^bool (API17_contacts_SentLink_contacts_sentLink *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.link data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ResPQ ()

@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;
@property (nonatomic, strong) NSData * pq;
@property (nonatomic, strong) NSArray * server_public_key_fingerprints;

@end

@interface API17_ResPQ_resPQ ()

@end

@implementation API17_ResPQ

+ (API17_ResPQ_resPQ *)resPQWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pq:(NSData *)pq server_public_key_fingerprints:(NSArray *)server_public_key_fingerprints
{
    API17_ResPQ_resPQ *_object = [[API17_ResPQ_resPQ alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pq = [API17__Serializer addSerializerToObject:[pq copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.server_public_key_fingerprints = [API17__Serializer addSerializerToObject:[server_public_key_fingerprints copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_ResPQ_resPQ

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5162463 serializeBlock:^bool (API17_ResPQ_resPQ *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pq data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_public_key_fingerprints data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_storage_FileType ()

@end

@interface API17_storage_FileType_storage_fileUnknown ()

@end

@interface API17_storage_FileType_storage_fileJpeg ()

@end

@interface API17_storage_FileType_storage_fileGif ()

@end

@interface API17_storage_FileType_storage_filePng ()

@end

@interface API17_storage_FileType_storage_filePdf ()

@end

@interface API17_storage_FileType_storage_fileMp3 ()

@end

@interface API17_storage_FileType_storage_fileMov ()

@end

@interface API17_storage_FileType_storage_filePartial ()

@end

@interface API17_storage_FileType_storage_fileMp4 ()

@end

@interface API17_storage_FileType_storage_fileWebp ()

@end

@implementation API17_storage_FileType

+ (API17_storage_FileType_storage_fileUnknown *)storage_fileUnknown
{
    API17_storage_FileType_storage_fileUnknown *_object = [[API17_storage_FileType_storage_fileUnknown alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileJpeg *)storage_fileJpeg
{
    API17_storage_FileType_storage_fileJpeg *_object = [[API17_storage_FileType_storage_fileJpeg alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileGif *)storage_fileGif
{
    API17_storage_FileType_storage_fileGif *_object = [[API17_storage_FileType_storage_fileGif alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_filePng *)storage_filePng
{
    API17_storage_FileType_storage_filePng *_object = [[API17_storage_FileType_storage_filePng alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_filePdf *)storage_filePdf
{
    API17_storage_FileType_storage_filePdf *_object = [[API17_storage_FileType_storage_filePdf alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileMp3 *)storage_fileMp3
{
    API17_storage_FileType_storage_fileMp3 *_object = [[API17_storage_FileType_storage_fileMp3 alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileMov *)storage_fileMov
{
    API17_storage_FileType_storage_fileMov *_object = [[API17_storage_FileType_storage_fileMov alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_filePartial *)storage_filePartial
{
    API17_storage_FileType_storage_filePartial *_object = [[API17_storage_FileType_storage_filePartial alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileMp4 *)storage_fileMp4
{
    API17_storage_FileType_storage_fileMp4 *_object = [[API17_storage_FileType_storage_fileMp4 alloc] init];
    return _object;
}

+ (API17_storage_FileType_storage_fileWebp *)storage_fileWebp
{
    API17_storage_FileType_storage_fileWebp *_object = [[API17_storage_FileType_storage_fileWebp alloc] init];
    return _object;
}


@end

@implementation API17_storage_FileType_storage_fileUnknown

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xaa963b05 serializeBlock:^bool (__unused API17_storage_FileType_storage_fileUnknown *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileJpeg

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7efe0e serializeBlock:^bool (__unused API17_storage_FileType_storage_fileJpeg *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileGif

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xcae1aadf serializeBlock:^bool (__unused API17_storage_FileType_storage_fileGif *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_filePng

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa4f63c0 serializeBlock:^bool (__unused API17_storage_FileType_storage_filePng *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_filePdf

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xae1e508d serializeBlock:^bool (__unused API17_storage_FileType_storage_filePdf *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileMp3

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x528a0677 serializeBlock:^bool (__unused API17_storage_FileType_storage_fileMp3 *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileMov

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4b09ebbc serializeBlock:^bool (__unused API17_storage_FileType_storage_fileMov *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_filePartial

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x40bc6f52 serializeBlock:^bool (__unused API17_storage_FileType_storage_filePartial *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileMp4

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb3cea0e4 serializeBlock:^bool (__unused API17_storage_FileType_storage_fileMp4 *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_storage_FileType_storage_fileWebp

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1081464c serializeBlock:^bool (__unused API17_storage_FileType_storage_fileWebp *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputEncryptedFile ()

@end

@interface API17_InputEncryptedFile_inputEncryptedFileEmpty ()

@end

@interface API17_InputEncryptedFile_inputEncryptedFileUploaded ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * parts;
@property (nonatomic, strong) NSString * md5_checksum;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@interface API17_InputEncryptedFile_inputEncryptedFile ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputEncryptedFile_inputEncryptedFileBigUploaded ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * parts;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@implementation API17_InputEncryptedFile

+ (API17_InputEncryptedFile_inputEncryptedFileEmpty *)inputEncryptedFileEmpty
{
    API17_InputEncryptedFile_inputEncryptedFileEmpty *_object = [[API17_InputEncryptedFile_inputEncryptedFileEmpty alloc] init];
    return _object;
}

+ (API17_InputEncryptedFile_inputEncryptedFileUploaded *)inputEncryptedFileUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(NSNumber *)key_fingerprint
{
    API17_InputEncryptedFile_inputEncryptedFileUploaded *_object = [[API17_InputEncryptedFile_inputEncryptedFileUploaded alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.parts = [API17__Serializer addSerializerToObject:[parts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.md5_checksum = [API17__Serializer addSerializerToObject:[md5_checksum copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.key_fingerprint = [API17__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_InputEncryptedFile_inputEncryptedFile *)inputEncryptedFileWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputEncryptedFile_inputEncryptedFile *_object = [[API17_InputEncryptedFile_inputEncryptedFile alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputEncryptedFile_inputEncryptedFileBigUploaded *)inputEncryptedFileBigUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts key_fingerprint:(NSNumber *)key_fingerprint
{
    API17_InputEncryptedFile_inputEncryptedFileBigUploaded *_object = [[API17_InputEncryptedFile_inputEncryptedFileBigUploaded alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.parts = [API17__Serializer addSerializerToObject:[parts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key_fingerprint = [API17__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_InputEncryptedFile_inputEncryptedFileEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1837c364 serializeBlock:^bool (__unused API17_InputEncryptedFile_inputEncryptedFileEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputEncryptedFile_inputEncryptedFileUploaded

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x64bd0306 serializeBlock:^bool (API17_InputEncryptedFile_inputEncryptedFileUploaded *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.parts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.md5_checksum data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputEncryptedFile_inputEncryptedFile

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5a17b5e5 serializeBlock:^bool (API17_InputEncryptedFile_inputEncryptedFile *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputEncryptedFile_inputEncryptedFileBigUploaded

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2dc173c8 serializeBlock:^bool (API17_InputEncryptedFile_inputEncryptedFileBigUploaded *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.parts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_FutureSalts ()

@end

@interface API17_FutureSalts_futureSalts ()

@end

@implementation API17_FutureSalts

+ (API17_FutureSalts_futureSalts *)futureSalts
{
    API17_FutureSalts_futureSalts *_object = [[API17_FutureSalts_futureSalts alloc] init];
    return _object;
}


@end

@implementation API17_FutureSalts_futureSalts

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4965676a serializeBlock:^bool (__unused API17_FutureSalts_futureSalts *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_SentEncryptedMessage ()

@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage ()

@end

@interface API17_messages_SentEncryptedMessage_messages_sentEncryptedFile ()

@property (nonatomic, strong) API17_EncryptedFile * file;

@end

@implementation API17_messages_SentEncryptedMessage

+ (API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage *)messages_sentEncryptedMessageWithDate:(NSNumber *)date
{
    API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage *_object = [[API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage alloc] init];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_messages_SentEncryptedMessage_messages_sentEncryptedFile *)messages_sentEncryptedFileWithDate:(NSNumber *)date file:(API17_EncryptedFile *)file
{
    API17_messages_SentEncryptedMessage_messages_sentEncryptedFile *_object = [[API17_messages_SentEncryptedMessage_messages_sentEncryptedFile alloc] init];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.file = file;
    return _object;
}


@end

@implementation API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x560f8935 serializeBlock:^bool (API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_SentEncryptedMessage_messages_sentEncryptedFile

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9493ff32 serializeBlock:^bool (API17_messages_SentEncryptedMessage_messages_sentEncryptedFile *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_auth_Authorization ()

@property (nonatomic, strong) NSNumber * expires;
@property (nonatomic, strong) API17_User * user;

@end

@interface API17_auth_Authorization_auth_authorization ()

@end

@implementation API17_auth_Authorization

+ (API17_auth_Authorization_auth_authorization *)auth_authorizationWithExpires:(NSNumber *)expires user:(API17_User *)user
{
    API17_auth_Authorization_auth_authorization *_object = [[API17_auth_Authorization_auth_authorization alloc] init];
    _object.expires = [API17__Serializer addSerializerToObject:[expires copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.user = user;
    return _object;
}


@end

@implementation API17_auth_Authorization_auth_authorization

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf6b673a4 serializeBlock:^bool (API17_auth_Authorization_auth_authorization *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.expires data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputFile ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * parts;
@property (nonatomic, strong) NSString * name;

@end

@interface API17_InputFile_inputFile ()

@property (nonatomic, strong) NSString * md5_checksum;

@end

@interface API17_InputFile_inputFileBig ()

@end

@implementation API17_InputFile

+ (API17_InputFile_inputFile *)inputFileWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name md5_checksum:(NSString *)md5_checksum
{
    API17_InputFile_inputFile *_object = [[API17_InputFile_inputFile alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.parts = [API17__Serializer addSerializerToObject:[parts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.name = [API17__Serializer addSerializerToObject:[name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.md5_checksum = [API17__Serializer addSerializerToObject:[md5_checksum copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputFile_inputFileBig *)inputFileBigWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name
{
    API17_InputFile_inputFileBig *_object = [[API17_InputFile_inputFileBig alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.parts = [API17__Serializer addSerializerToObject:[parts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.name = [API17__Serializer addSerializerToObject:[name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_InputFile_inputFile

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf52ff27f serializeBlock:^bool (API17_InputFile_inputFile *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.parts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.md5_checksum data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputFile_inputFileBig

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfa4f0bb5 serializeBlock:^bool (API17_InputFile_inputFileBig *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.parts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Peer ()

@end

@interface API17_Peer_peerUser ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_Peer_peerChat ()

@property (nonatomic, strong) NSNumber * chat_id;

@end

@implementation API17_Peer

+ (API17_Peer_peerUser *)peerUserWithUser_id:(NSNumber *)user_id
{
    API17_Peer_peerUser *_object = [[API17_Peer_peerUser alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Peer_peerChat *)peerChatWithChat_id:(NSNumber *)chat_id
{
    API17_Peer_peerChat *_object = [[API17_Peer_peerChat alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Peer_peerUser

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9db1bc6d serializeBlock:^bool (API17_Peer_peerUser *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Peer_peerChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xbad0e5bb serializeBlock:^bool (API17_Peer_peerChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_UserStatus ()

@end

@interface API17_UserStatus_userStatusEmpty ()

@end

@interface API17_UserStatus_userStatusOnline ()

@property (nonatomic, strong) NSNumber * expires;

@end

@interface API17_UserStatus_userStatusOffline ()

@property (nonatomic, strong) NSNumber * was_online;

@end

@implementation API17_UserStatus

+ (API17_UserStatus_userStatusEmpty *)userStatusEmpty
{
    API17_UserStatus_userStatusEmpty *_object = [[API17_UserStatus_userStatusEmpty alloc] init];
    return _object;
}

+ (API17_UserStatus_userStatusOnline *)userStatusOnlineWithExpires:(NSNumber *)expires
{
    API17_UserStatus_userStatusOnline *_object = [[API17_UserStatus_userStatusOnline alloc] init];
    _object.expires = [API17__Serializer addSerializerToObject:[expires copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_UserStatus_userStatusOffline *)userStatusOfflineWithWas_online:(NSNumber *)was_online
{
    API17_UserStatus_userStatusOffline *_object = [[API17_UserStatus_userStatusOffline alloc] init];
    _object.was_online = [API17__Serializer addSerializerToObject:[was_online copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_UserStatus_userStatusEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9d05049 serializeBlock:^bool (__unused API17_UserStatus_userStatusEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_UserStatus_userStatusOnline

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xedb93949 serializeBlock:^bool (API17_UserStatus_userStatusOnline *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.expires data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_UserStatus_userStatusOffline

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8c703f serializeBlock:^bool (API17_UserStatus_userStatusOffline *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.was_online data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Dialog ()

@property (nonatomic, strong) API17_Peer * peer;
@property (nonatomic, strong) NSNumber * top_message;
@property (nonatomic, strong) NSNumber * unread_count;
@property (nonatomic, strong) API17_PeerNotifySettings * notify_settings;

@end

@interface API17_Dialog_dialog ()

@end

@implementation API17_Dialog

+ (API17_Dialog_dialog *)dialogWithPeer:(API17_Peer *)peer top_message:(NSNumber *)top_message unread_count:(NSNumber *)unread_count notify_settings:(API17_PeerNotifySettings *)notify_settings
{
    API17_Dialog_dialog *_object = [[API17_Dialog_dialog alloc] init];
    _object.peer = peer;
    _object.top_message = [API17__Serializer addSerializerToObject:[top_message copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.unread_count = [API17__Serializer addSerializerToObject:[unread_count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.notify_settings = notify_settings;
    return _object;
}


@end

@implementation API17_Dialog_dialog

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xab3a99ac serializeBlock:^bool (API17_Dialog_dialog *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.peer data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.top_message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.unread_count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.notify_settings data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgsAllInfo ()

@property (nonatomic, strong) NSArray * msg_ids;
@property (nonatomic, strong) NSString * info;

@end

@interface API17_MsgsAllInfo_msgs_all_info ()

@end

@implementation API17_MsgsAllInfo

+ (API17_MsgsAllInfo_msgs_all_info *)msgs_all_infoWithMsg_ids:(NSArray *)msg_ids info:(NSString *)info
{
    API17_MsgsAllInfo_msgs_all_info *_object = [[API17_MsgsAllInfo_msgs_all_info alloc] init];
    _object.msg_ids = [API17__Serializer addSerializerToObject:[msg_ids copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    _object.info = [API17__Serializer addSerializerToObject:[info copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_MsgsAllInfo_msgs_all_info

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8cc0d131 serializeBlock:^bool (API17_MsgsAllInfo_msgs_all_info *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_ids data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.info data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_SendMessageAction ()

@end

@interface API17_SendMessageAction_sendMessageTypingAction ()

@end

@interface API17_SendMessageAction_sendMessageCancelAction ()

@end

@interface API17_SendMessageAction_sendMessageRecordVideoAction ()

@end

@interface API17_SendMessageAction_sendMessageUploadVideoAction ()

@end

@interface API17_SendMessageAction_sendMessageRecordAudioAction ()

@end

@interface API17_SendMessageAction_sendMessageUploadAudioAction ()

@end

@interface API17_SendMessageAction_sendMessageUploadPhotoAction ()

@end

@interface API17_SendMessageAction_sendMessageUploadDocumentAction ()

@end

@interface API17_SendMessageAction_sendMessageGeoLocationAction ()

@end

@interface API17_SendMessageAction_sendMessageChooseContactAction ()

@end

@implementation API17_SendMessageAction

+ (API17_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction
{
    API17_SendMessageAction_sendMessageTypingAction *_object = [[API17_SendMessageAction_sendMessageTypingAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction
{
    API17_SendMessageAction_sendMessageCancelAction *_object = [[API17_SendMessageAction_sendMessageCancelAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction
{
    API17_SendMessageAction_sendMessageRecordVideoAction *_object = [[API17_SendMessageAction_sendMessageRecordVideoAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction
{
    API17_SendMessageAction_sendMessageUploadVideoAction *_object = [[API17_SendMessageAction_sendMessageUploadVideoAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction
{
    API17_SendMessageAction_sendMessageRecordAudioAction *_object = [[API17_SendMessageAction_sendMessageRecordAudioAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction
{
    API17_SendMessageAction_sendMessageUploadAudioAction *_object = [[API17_SendMessageAction_sendMessageUploadAudioAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction
{
    API17_SendMessageAction_sendMessageUploadPhotoAction *_object = [[API17_SendMessageAction_sendMessageUploadPhotoAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction
{
    API17_SendMessageAction_sendMessageUploadDocumentAction *_object = [[API17_SendMessageAction_sendMessageUploadDocumentAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction
{
    API17_SendMessageAction_sendMessageGeoLocationAction *_object = [[API17_SendMessageAction_sendMessageGeoLocationAction alloc] init];
    return _object;
}

+ (API17_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction
{
    API17_SendMessageAction_sendMessageChooseContactAction *_object = [[API17_SendMessageAction_sendMessageChooseContactAction alloc] init];
    return _object;
}


@end

@implementation API17_SendMessageAction_sendMessageTypingAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x16bf744e serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageTypingAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageCancelAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfd5ec8f5 serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageCancelAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageRecordVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa187d66f serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageRecordVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageUploadVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x92042ff7 serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageUploadVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageRecordAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd52f73f7 serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageRecordAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageUploadAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe6ac8a6f serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageUploadAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageUploadPhotoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x990a3c1a serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageUploadPhotoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageUploadDocumentAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8faee98e serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageUploadDocumentAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageGeoLocationAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x176f8ba1 serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageGeoLocationAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_SendMessageAction_sendMessageChooseContactAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x628cbc6f serializeBlock:^bool (__unused API17_SendMessageAction_sendMessageChooseContactAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Update ()

@end

@interface API17_Update_updateNewGeoChatMessage ()

@property (nonatomic, strong) API17_GeoChatMessage * message;

@end

@interface API17_Update_updateNewMessage ()

@property (nonatomic, strong) API17_Message * message;
@property (nonatomic, strong) NSNumber * pts;

@end

@interface API17_Update_updateMessageID ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * random_id;

@end

@interface API17_Update_updateReadMessages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSNumber * pts;

@end

@interface API17_Update_updateDeleteMessages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSNumber * pts;

@end

@interface API17_Update_updateRestoreMessages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSNumber * pts;

@end

@interface API17_Update_updateChatParticipants ()

@property (nonatomic, strong) API17_ChatParticipants * participants;

@end

@interface API17_Update_updateUserStatus ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_UserStatus * status;

@end

@interface API17_Update_updateUserName ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;

@end

@interface API17_Update_updateUserPhoto ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_UserProfilePhoto * photo;

@end

@interface API17_Update_updateContactRegistered ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_Update_updateContactLink ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_contacts_MyLink * my_link;
@property (nonatomic, strong) API17_contacts_ForeignLink * foreign_link;

@end

@interface API17_Update_updateContactLocated ()

@property (nonatomic, strong) NSArray * contacts;

@end

@interface API17_Update_updateActivation ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_Update_updateNewAuthorization ()

@property (nonatomic, strong) NSNumber * auth_key_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * device;
@property (nonatomic, strong) NSString * location;

@end

@interface API17_Update_updatePhoneCallRequested ()

@property (nonatomic, strong) API17_PhoneCall * phone_call;

@end

@interface API17_Update_updatePhoneCallConfirmed ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSData * a_or_b;
@property (nonatomic, strong) API17_PhoneConnection * connection;

@end

@interface API17_Update_updatePhoneCallDeclined ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Update_updateNewEncryptedMessage ()

@property (nonatomic, strong) API17_EncryptedMessage * message;
@property (nonatomic, strong) NSNumber * qts;

@end

@interface API17_Update_updateEncryptedChatTyping ()

@property (nonatomic, strong) NSNumber * chat_id;

@end

@interface API17_Update_updateEncryption ()

@property (nonatomic, strong) API17_EncryptedChat * chat;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_Update_updateEncryptedMessagesRead ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * max_date;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_Update_updateChatParticipantAdd ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * inviter_id;
@property (nonatomic, strong) NSNumber * version;

@end

@interface API17_Update_updateChatParticipantDelete ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * version;

@end

@interface API17_Update_updateDcOptions ()

@property (nonatomic, strong) NSArray * dc_options;

@end

@interface API17_Update_updateUserBlocked ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_Bool * blocked;

@end

@interface API17_Update_updateNotifySettings ()

@property (nonatomic, strong) API17_NotifyPeer * peer;
@property (nonatomic, strong) API17_PeerNotifySettings * notify_settings;

@end

@interface API17_Update_updateUserTyping ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_SendMessageAction * action;

@end

@interface API17_Update_updateChatUserTyping ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_SendMessageAction * action;

@end

@implementation API17_Update

+ (API17_Update_updateNewGeoChatMessage *)updateNewGeoChatMessageWithMessage:(API17_GeoChatMessage *)message
{
    API17_Update_updateNewGeoChatMessage *_object = [[API17_Update_updateNewGeoChatMessage alloc] init];
    _object.message = message;
    return _object;
}

+ (API17_Update_updateNewMessage *)updateNewMessageWithMessage:(API17_Message *)message pts:(NSNumber *)pts
{
    API17_Update_updateNewMessage *_object = [[API17_Update_updateNewMessage alloc] init];
    _object.message = message;
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateMessageID *)updateMessageIDWithPid:(NSNumber *)pid random_id:(NSNumber *)random_id
{
    API17_Update_updateMessageID *_object = [[API17_Update_updateMessageID alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Update_updateReadMessages *)updateReadMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts
{
    API17_Update_updateReadMessages *_object = [[API17_Update_updateReadMessages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateDeleteMessages *)updateDeleteMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts
{
    API17_Update_updateDeleteMessages *_object = [[API17_Update_updateDeleteMessages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateRestoreMessages *)updateRestoreMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts
{
    API17_Update_updateRestoreMessages *_object = [[API17_Update_updateRestoreMessages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateChatParticipants *)updateChatParticipantsWithParticipants:(API17_ChatParticipants *)participants
{
    API17_Update_updateChatParticipants *_object = [[API17_Update_updateChatParticipants alloc] init];
    _object.participants = participants;
    return _object;
}

+ (API17_Update_updateUserStatus *)updateUserStatusWithUser_id:(NSNumber *)user_id status:(API17_UserStatus *)status
{
    API17_Update_updateUserStatus *_object = [[API17_Update_updateUserStatus alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.status = status;
    return _object;
}

+ (API17_Update_updateUserName *)updateUserNameWithUser_id:(NSNumber *)user_id first_name:(NSString *)first_name last_name:(NSString *)last_name
{
    API17_Update_updateUserName *_object = [[API17_Update_updateUserName alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_Update_updateUserPhoto *)updateUserPhotoWithUser_id:(NSNumber *)user_id photo:(API17_UserProfilePhoto *)photo
{
    API17_Update_updateUserPhoto *_object = [[API17_Update_updateUserPhoto alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.photo = photo;
    return _object;
}

+ (API17_Update_updateContactRegistered *)updateContactRegisteredWithUser_id:(NSNumber *)user_id date:(NSNumber *)date
{
    API17_Update_updateContactRegistered *_object = [[API17_Update_updateContactRegistered alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateContactLink *)updateContactLinkWithUser_id:(NSNumber *)user_id my_link:(API17_contacts_MyLink *)my_link foreign_link:(API17_contacts_ForeignLink *)foreign_link
{
    API17_Update_updateContactLink *_object = [[API17_Update_updateContactLink alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.my_link = my_link;
    _object.foreign_link = foreign_link;
    return _object;
}

+ (API17_Update_updateContactLocated *)updateContactLocatedWithContacts:(NSArray *)contacts
{
    API17_Update_updateContactLocated *_object = [[API17_Update_updateContactLocated alloc] init];
    _object.contacts = [API17__Serializer addSerializerToObject:[contacts copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_Update_updateActivation *)updateActivationWithUser_id:(NSNumber *)user_id
{
    API17_Update_updateActivation *_object = [[API17_Update_updateActivation alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateNewAuthorization *)updateNewAuthorizationWithAuth_key_id:(NSNumber *)auth_key_id date:(NSNumber *)date device:(NSString *)device location:(NSString *)location
{
    API17_Update_updateNewAuthorization *_object = [[API17_Update_updateNewAuthorization alloc] init];
    _object.auth_key_id = [API17__Serializer addSerializerToObject:[auth_key_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.device = [API17__Serializer addSerializerToObject:[device copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.location = [API17__Serializer addSerializerToObject:[location copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_Update_updatePhoneCallRequested *)updatePhoneCallRequestedWithPhone_call:(API17_PhoneCall *)phone_call
{
    API17_Update_updatePhoneCallRequested *_object = [[API17_Update_updatePhoneCallRequested alloc] init];
    _object.phone_call = phone_call;
    return _object;
}

+ (API17_Update_updatePhoneCallConfirmed *)updatePhoneCallConfirmedWithPid:(NSNumber *)pid a_or_b:(NSData *)a_or_b connection:(API17_PhoneConnection *)connection
{
    API17_Update_updatePhoneCallConfirmed *_object = [[API17_Update_updatePhoneCallConfirmed alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.a_or_b = [API17__Serializer addSerializerToObject:[a_or_b copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.connection = connection;
    return _object;
}

+ (API17_Update_updatePhoneCallDeclined *)updatePhoneCallDeclinedWithPid:(NSNumber *)pid
{
    API17_Update_updatePhoneCallDeclined *_object = [[API17_Update_updatePhoneCallDeclined alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Update_updateNewEncryptedMessage *)updateNewEncryptedMessageWithMessage:(API17_EncryptedMessage *)message qts:(NSNumber *)qts
{
    API17_Update_updateNewEncryptedMessage *_object = [[API17_Update_updateNewEncryptedMessage alloc] init];
    _object.message = message;
    _object.qts = [API17__Serializer addSerializerToObject:[qts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateEncryptedChatTyping *)updateEncryptedChatTypingWithChat_id:(NSNumber *)chat_id
{
    API17_Update_updateEncryptedChatTyping *_object = [[API17_Update_updateEncryptedChatTyping alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateEncryption *)updateEncryptionWithChat:(API17_EncryptedChat *)chat date:(NSNumber *)date
{
    API17_Update_updateEncryption *_object = [[API17_Update_updateEncryption alloc] init];
    _object.chat = chat;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateEncryptedMessagesRead *)updateEncryptedMessagesReadWithChat_id:(NSNumber *)chat_id max_date:(NSNumber *)max_date date:(NSNumber *)date
{
    API17_Update_updateEncryptedMessagesRead *_object = [[API17_Update_updateEncryptedMessagesRead alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.max_date = [API17__Serializer addSerializerToObject:[max_date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateChatParticipantAdd *)updateChatParticipantAddWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id inviter_id:(NSNumber *)inviter_id version:(NSNumber *)version
{
    API17_Update_updateChatParticipantAdd *_object = [[API17_Update_updateChatParticipantAdd alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.inviter_id = [API17__Serializer addSerializerToObject:[inviter_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateChatParticipantDelete *)updateChatParticipantDeleteWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id version:(NSNumber *)version
{
    API17_Update_updateChatParticipantDelete *_object = [[API17_Update_updateChatParticipantDelete alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Update_updateDcOptions *)updateDcOptionsWithDc_options:(NSArray *)dc_options
{
    API17_Update_updateDcOptions *_object = [[API17_Update_updateDcOptions alloc] init];
    _object.dc_options = [API17__Serializer addSerializerToObject:[dc_options copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_Update_updateUserBlocked *)updateUserBlockedWithUser_id:(NSNumber *)user_id blocked:(API17_Bool *)blocked
{
    API17_Update_updateUserBlocked *_object = [[API17_Update_updateUserBlocked alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.blocked = blocked;
    return _object;
}

+ (API17_Update_updateNotifySettings *)updateNotifySettingsWithPeer:(API17_NotifyPeer *)peer notify_settings:(API17_PeerNotifySettings *)notify_settings
{
    API17_Update_updateNotifySettings *_object = [[API17_Update_updateNotifySettings alloc] init];
    _object.peer = peer;
    _object.notify_settings = notify_settings;
    return _object;
}

+ (API17_Update_updateUserTyping *)updateUserTypingWithUser_id:(NSNumber *)user_id action:(API17_SendMessageAction *)action
{
    API17_Update_updateUserTyping *_object = [[API17_Update_updateUserTyping alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.action = action;
    return _object;
}

+ (API17_Update_updateChatUserTyping *)updateChatUserTypingWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id action:(API17_SendMessageAction *)action
{
    API17_Update_updateChatUserTyping *_object = [[API17_Update_updateChatUserTyping alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation API17_Update_updateNewGeoChatMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5a68e3f7 serializeBlock:^bool (API17_Update_updateNewGeoChatMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateNewMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x13abdb3 serializeBlock:^bool (API17_Update_updateNewMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateMessageID

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4e90bfd6 serializeBlock:^bool (API17_Update_updateMessageID *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc6649e31 serializeBlock:^bool (API17_Update_updateReadMessages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa92bfe26 serializeBlock:^bool (API17_Update_updateDeleteMessages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateRestoreMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd15de04d serializeBlock:^bool (API17_Update_updateRestoreMessages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateChatParticipants

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7761198 serializeBlock:^bool (API17_Update_updateChatParticipants *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.participants data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateUserStatus

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1bfbd823 serializeBlock:^bool (API17_Update_updateUserStatus *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateUserName

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xda22d9ad serializeBlock:^bool (API17_Update_updateUserName *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateUserPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xbb8ba607 serializeBlock:^bool (API17_Update_updateUserPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateContactRegistered

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2575bbb9 serializeBlock:^bool (API17_Update_updateContactRegistered *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateContactLink

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x51a48a9a serializeBlock:^bool (API17_Update_updateContactLink *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.my_link data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.foreign_link data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateContactLocated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5f83b963 serializeBlock:^bool (API17_Update_updateContactLocated *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.contacts data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateActivation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6f690963 serializeBlock:^bool (API17_Update_updateActivation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateNewAuthorization

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8f06529a serializeBlock:^bool (API17_Update_updateNewAuthorization *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.auth_key_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.device data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.location data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updatePhoneCallRequested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xdad7490e serializeBlock:^bool (API17_Update_updatePhoneCallRequested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_call data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updatePhoneCallConfirmed

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5609ff88 serializeBlock:^bool (API17_Update_updatePhoneCallConfirmed *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.a_or_b data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.connection data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updatePhoneCallDeclined

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x31ae2cc2 serializeBlock:^bool (API17_Update_updatePhoneCallDeclined *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateNewEncryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x12bcbd9a serializeBlock:^bool (API17_Update_updateNewEncryptedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.qts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateEncryptedChatTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1710f156 serializeBlock:^bool (API17_Update_updateEncryptedChatTyping *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateEncryption

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb4a2e88d serializeBlock:^bool (API17_Update_updateEncryption *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateEncryptedMessagesRead

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x38fe25b7 serializeBlock:^bool (API17_Update_updateEncryptedMessagesRead *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.max_date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateChatParticipantAdd

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3a0eeb22 serializeBlock:^bool (API17_Update_updateChatParticipantAdd *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.inviter_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateChatParticipantDelete

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6e5f8c22 serializeBlock:^bool (API17_Update_updateChatParticipantDelete *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateDcOptions

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8e5e9873 serializeBlock:^bool (API17_Update_updateDcOptions *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.dc_options data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateUserBlocked

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x80ece81a serializeBlock:^bool (API17_Update_updateUserBlocked *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.blocked data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateNotifySettings

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xbec268ef serializeBlock:^bool (API17_Update_updateNotifySettings *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.peer data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.notify_settings data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateUserTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5c486927 serializeBlock:^bool (API17_Update_updateUserTyping *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Update_updateChatUserTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9a65ea1f serializeBlock:^bool (API17_Update_updateChatUserTyping *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Blocked ()

@property (nonatomic, strong) NSArray * blocked;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Blocked_contacts_blocked ()

@end

@interface API17_contacts_Blocked_contacts_blockedSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_contacts_Blocked

+ (API17_contacts_Blocked_contacts_blocked *)contacts_blockedWithBlocked:(NSArray *)blocked users:(NSArray *)users
{
    API17_contacts_Blocked_contacts_blocked *_object = [[API17_contacts_Blocked_contacts_blocked alloc] init];
    _object.blocked = [API17__Serializer addSerializerToObject:[blocked copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_contacts_Blocked_contacts_blockedSlice *)contacts_blockedSliceWithCount:(NSNumber *)count blocked:(NSArray *)blocked users:(NSArray *)users
{
    API17_contacts_Blocked_contacts_blockedSlice *_object = [[API17_contacts_Blocked_contacts_blockedSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.blocked = [API17__Serializer addSerializerToObject:[blocked copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_Blocked_contacts_blocked

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1c138d15 serializeBlock:^bool (API17_contacts_Blocked_contacts_blocked *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.blocked data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_Blocked_contacts_blockedSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x900802a1 serializeBlock:^bool (API17_contacts_Blocked_contacts_blockedSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.blocked data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Error ()

@property (nonatomic, strong) NSNumber * code;

@end

@interface API17_Error_error ()

@property (nonatomic, strong) NSString * text;

@end

@interface API17_Error_richError ()

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * n_description;
@property (nonatomic, strong) NSString * debug;
@property (nonatomic, strong) NSString * request_params;

@end

@implementation API17_Error

+ (API17_Error_error *)errorWithCode:(NSNumber *)code text:(NSString *)text
{
    API17_Error_error *_object = [[API17_Error_error alloc] init];
    _object.code = [API17__Serializer addSerializerToObject:[code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.text = [API17__Serializer addSerializerToObject:[text copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_Error_richError *)richErrorWithCode:(NSNumber *)code type:(NSString *)type n_description:(NSString *)n_description debug:(NSString *)debug request_params:(NSString *)request_params
{
    API17_Error_richError *_object = [[API17_Error_richError alloc] init];
    _object.code = [API17__Serializer addSerializerToObject:[code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.n_description = [API17__Serializer addSerializerToObject:[n_description copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.debug = [API17__Serializer addSerializerToObject:[debug copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.request_params = [API17__Serializer addSerializerToObject:[request_params copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_Error_error

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc4b9f9bb serializeBlock:^bool (API17_Error_error *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.text data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Error_richError

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x59aefc57 serializeBlock:^bool (API17_Error_richError *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.n_description data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.debug data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.request_params data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactLocated ()

@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * distance;

@end

@interface API17_ContactLocated_contactLocated ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_GeoPoint * location;

@end

@interface API17_ContactLocated_contactLocatedPreview ()

@property (nonatomic, strong) NSString * phash;
@property (nonatomic, strong) API17_Bool * hidden;

@end

@implementation API17_ContactLocated

+ (API17_ContactLocated_contactLocated *)contactLocatedWithUser_id:(NSNumber *)user_id location:(API17_GeoPoint *)location date:(NSNumber *)date distance:(NSNumber *)distance
{
    API17_ContactLocated_contactLocated *_object = [[API17_ContactLocated_contactLocated alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.location = location;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.distance = [API17__Serializer addSerializerToObject:[distance copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_ContactLocated_contactLocatedPreview *)contactLocatedPreviewWithPhash:(NSString *)phash hidden:(API17_Bool *)hidden date:(NSNumber *)date distance:(NSNumber *)distance
{
    API17_ContactLocated_contactLocatedPreview *_object = [[API17_ContactLocated_contactLocatedPreview alloc] init];
    _object.phash = [API17__Serializer addSerializerToObject:[phash copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.hidden = hidden;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.distance = [API17__Serializer addSerializerToObject:[distance copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactLocated_contactLocated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe144acaf serializeBlock:^bool (API17_ContactLocated_contactLocated *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.distance data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_ContactLocated_contactLocatedPreview

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc1257157 serializeBlock:^bool (API17_ContactLocated_contactLocatedPreview *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.hidden data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.distance data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactStatus ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * expires;

@end

@interface API17_ContactStatus_contactStatus ()

@end

@implementation API17_ContactStatus

+ (API17_ContactStatus_contactStatus *)contactStatusWithUser_id:(NSNumber *)user_id expires:(NSNumber *)expires
{
    API17_ContactStatus_contactStatus *_object = [[API17_ContactStatus_contactStatus alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.expires = [API17__Serializer addSerializerToObject:[expires copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactStatus_contactStatus

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xaa77b873 serializeBlock:^bool (API17_ContactStatus_contactStatus *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.expires data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_geochats_Messages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_geochats_Messages_geochats_messages ()

@end

@interface API17_geochats_Messages_geochats_messagesSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_geochats_Messages

+ (API17_geochats_Messages_geochats_messages *)geochats_messagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_geochats_Messages_geochats_messages *_object = [[API17_geochats_Messages_geochats_messages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_geochats_Messages_geochats_messagesSlice *)geochats_messagesSliceWithCount:(NSNumber *)count messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_geochats_Messages_geochats_messagesSlice *_object = [[API17_geochats_Messages_geochats_messagesSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_geochats_Messages_geochats_messages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd1526db1 serializeBlock:^bool (API17_geochats_Messages_geochats_messages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_geochats_Messages_geochats_messagesSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xbc5863e8 serializeBlock:^bool (API17_geochats_Messages_geochats_messagesSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgsStateInfo ()

@property (nonatomic, strong) NSNumber * req_msg_id;
@property (nonatomic, strong) NSString * info;

@end

@interface API17_MsgsStateInfo_msgs_state_info ()

@end

@implementation API17_MsgsStateInfo

+ (API17_MsgsStateInfo_msgs_state_info *)msgs_state_infoWithReq_msg_id:(NSNumber *)req_msg_id info:(NSString *)info
{
    API17_MsgsStateInfo_msgs_state_info *_object = [[API17_MsgsStateInfo_msgs_state_info alloc] init];
    _object.req_msg_id = [API17__Serializer addSerializerToObject:[req_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.info = [API17__Serializer addSerializerToObject:[info copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_MsgsStateInfo_msgs_state_info

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4deb57d serializeBlock:^bool (API17_MsgsStateInfo_msgs_state_info *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.req_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.info data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_PhotoSize ()

@property (nonatomic, strong) NSString * type;

@end

@interface API17_PhotoSize_photoSizeEmpty ()

@end

@interface API17_PhotoSize_photoSize ()

@property (nonatomic, strong) API17_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;

@end

@interface API17_PhotoSize_photoCachedSize ()

@property (nonatomic, strong) API17_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSData * bytes;

@end

@implementation API17_PhotoSize

+ (API17_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type
{
    API17_PhotoSize_photoSizeEmpty *_object = [[API17_PhotoSize_photoSizeEmpty alloc] init];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(API17_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size
{
    API17_PhotoSize_photoSize *_object = [[API17_PhotoSize_photoSize alloc] init];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(API17_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes
{
    API17_PhotoSize_photoCachedSize *_object = [[API17_PhotoSize_photoCachedSize alloc] init];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_PhotoSize_photoSizeEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe17e23c serializeBlock:^bool (API17_PhotoSize_photoSizeEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PhotoSize_photoSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x77bfb61b serializeBlock:^bool (API17_PhotoSize_photoSize *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PhotoSize_photoCachedSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe9a734fa serializeBlock:^bool (API17_PhotoSize_photoCachedSize *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_GlobalPrivacySettings ()

@property (nonatomic, strong) API17_Bool * no_suggestions;
@property (nonatomic, strong) API17_Bool * hide_contacts;
@property (nonatomic, strong) API17_Bool * hide_located;
@property (nonatomic, strong) API17_Bool * hide_last_visit;

@end

@interface API17_GlobalPrivacySettings_globalPrivacySettings ()

@end

@implementation API17_GlobalPrivacySettings

+ (API17_GlobalPrivacySettings_globalPrivacySettings *)globalPrivacySettingsWithNo_suggestions:(API17_Bool *)no_suggestions hide_contacts:(API17_Bool *)hide_contacts hide_located:(API17_Bool *)hide_located hide_last_visit:(API17_Bool *)hide_last_visit
{
    API17_GlobalPrivacySettings_globalPrivacySettings *_object = [[API17_GlobalPrivacySettings_globalPrivacySettings alloc] init];
    _object.no_suggestions = no_suggestions;
    _object.hide_contacts = hide_contacts;
    _object.hide_located = hide_located;
    _object.hide_last_visit = hide_last_visit;
    return _object;
}


@end

@implementation API17_GlobalPrivacySettings_globalPrivacySettings

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x40f5c53a serializeBlock:^bool (API17_GlobalPrivacySettings_globalPrivacySettings *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.no_suggestions data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.hide_contacts data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.hide_located data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.hide_last_visit data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputGeoChat ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputGeoChat_inputGeoChat ()

@end

@implementation API17_InputGeoChat

+ (API17_InputGeoChat_inputGeoChat *)inputGeoChatWithChat_id:(NSNumber *)chat_id access_hash:(NSNumber *)access_hash
{
    API17_InputGeoChat_inputGeoChat *_object = [[API17_InputGeoChat_inputGeoChat alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputGeoChat_inputGeoChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x74d456fa serializeBlock:^bool (API17_InputGeoChat_inputGeoChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_FileLocation ()

@property (nonatomic, strong) NSNumber * volume_id;
@property (nonatomic, strong) NSNumber * local_id;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface API17_FileLocation_fileLocationUnavailable ()

@end

@interface API17_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dc_id;

@end

@implementation API17_FileLocation

+ (API17_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    API17_FileLocation_fileLocationUnavailable *_object = [[API17_FileLocation_fileLocationUnavailable alloc] init];
    _object.volume_id = [API17__Serializer addSerializerToObject:[volume_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [API17__Serializer addSerializerToObject:[local_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.secret = [API17__Serializer addSerializerToObject:[secret copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_FileLocation_fileLocation *)fileLocationWithDc_id:(NSNumber *)dc_id volume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    API17_FileLocation_fileLocation *_object = [[API17_FileLocation_fileLocation alloc] init];
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.volume_id = [API17__Serializer addSerializerToObject:[volume_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [API17__Serializer addSerializerToObject:[local_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.secret = [API17__Serializer addSerializerToObject:[secret copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_FileLocation_fileLocationUnavailable

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7c596b46 serializeBlock:^bool (API17_FileLocation_fileLocationUnavailable *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_FileLocation_fileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x53d69076 serializeBlock:^bool (API17_FileLocation_fileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputNotifyPeer ()

@end

@interface API17_InputNotifyPeer_inputNotifyGeoChatPeer ()

@property (nonatomic, strong) API17_InputGeoChat * peer;

@end

@interface API17_InputNotifyPeer_inputNotifyPeer ()

@property (nonatomic, strong) API17_InputPeer * peer;

@end

@interface API17_InputNotifyPeer_inputNotifyUsers ()

@end

@interface API17_InputNotifyPeer_inputNotifyChats ()

@end

@interface API17_InputNotifyPeer_inputNotifyAll ()

@end

@implementation API17_InputNotifyPeer

+ (API17_InputNotifyPeer_inputNotifyGeoChatPeer *)inputNotifyGeoChatPeerWithPeer:(API17_InputGeoChat *)peer
{
    API17_InputNotifyPeer_inputNotifyGeoChatPeer *_object = [[API17_InputNotifyPeer_inputNotifyGeoChatPeer alloc] init];
    _object.peer = peer;
    return _object;
}

+ (API17_InputNotifyPeer_inputNotifyPeer *)inputNotifyPeerWithPeer:(API17_InputPeer *)peer
{
    API17_InputNotifyPeer_inputNotifyPeer *_object = [[API17_InputNotifyPeer_inputNotifyPeer alloc] init];
    _object.peer = peer;
    return _object;
}

+ (API17_InputNotifyPeer_inputNotifyUsers *)inputNotifyUsers
{
    API17_InputNotifyPeer_inputNotifyUsers *_object = [[API17_InputNotifyPeer_inputNotifyUsers alloc] init];
    return _object;
}

+ (API17_InputNotifyPeer_inputNotifyChats *)inputNotifyChats
{
    API17_InputNotifyPeer_inputNotifyChats *_object = [[API17_InputNotifyPeer_inputNotifyChats alloc] init];
    return _object;
}

+ (API17_InputNotifyPeer_inputNotifyAll *)inputNotifyAll
{
    API17_InputNotifyPeer_inputNotifyAll *_object = [[API17_InputNotifyPeer_inputNotifyAll alloc] init];
    return _object;
}


@end

@implementation API17_InputNotifyPeer_inputNotifyGeoChatPeer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4d8ddec8 serializeBlock:^bool (API17_InputNotifyPeer_inputNotifyGeoChatPeer *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.peer data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputNotifyPeer_inputNotifyPeer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb8bc5b0c serializeBlock:^bool (API17_InputNotifyPeer_inputNotifyPeer *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.peer data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputNotifyPeer_inputNotifyUsers

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x193b4417 serializeBlock:^bool (__unused API17_InputNotifyPeer_inputNotifyUsers *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputNotifyPeer_inputNotifyChats

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4a95e84e serializeBlock:^bool (__unused API17_InputNotifyPeer_inputNotifyChats *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputNotifyPeer_inputNotifyAll

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa429b886 serializeBlock:^bool (__unused API17_InputNotifyPeer_inputNotifyAll *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_EncryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;
@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSData * bytes;

@end

@interface API17_EncryptedMessage_encryptedMessage ()

@property (nonatomic, strong) API17_EncryptedFile * file;

@end

@interface API17_EncryptedMessage_encryptedMessageService ()

@end

@implementation API17_EncryptedMessage

+ (API17_EncryptedMessage_encryptedMessage *)encryptedMessageWithRandom_id:(NSNumber *)random_id chat_id:(NSNumber *)chat_id date:(NSNumber *)date bytes:(NSData *)bytes file:(API17_EncryptedFile *)file
{
    API17_EncryptedMessage_encryptedMessage *_object = [[API17_EncryptedMessage_encryptedMessage alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.file = file;
    return _object;
}

+ (API17_EncryptedMessage_encryptedMessageService *)encryptedMessageServiceWithRandom_id:(NSNumber *)random_id chat_id:(NSNumber *)chat_id date:(NSNumber *)date bytes:(NSData *)bytes
{
    API17_EncryptedMessage_encryptedMessageService *_object = [[API17_EncryptedMessage_encryptedMessageService alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_EncryptedMessage_encryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xed18c118 serializeBlock:^bool (API17_EncryptedMessage_encryptedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedMessage_encryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x23734b06 serializeBlock:^bool (API17_EncryptedMessage_encryptedMessageService *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_photos_Photo ()

@property (nonatomic, strong) API17_Photo * photo;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_photos_Photo_photos_photo ()

@end

@implementation API17_photos_Photo

+ (API17_photos_Photo_photos_photo *)photos_photoWithPhoto:(API17_Photo *)photo users:(NSArray *)users
{
    API17_photos_Photo_photos_photo *_object = [[API17_photos_Photo_photos_photo alloc] init];
    _object.photo = photo;
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_photos_Photo_photos_photo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x20212ca8 serializeBlock:^bool (API17_photos_Photo_photos_photo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputContact ()

@property (nonatomic, strong) NSNumber * client_id;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;

@end

@interface API17_InputContact_inputPhoneContact ()

@end

@implementation API17_InputContact

+ (API17_InputContact_inputPhoneContact *)inputPhoneContactWithClient_id:(NSNumber *)client_id phone:(NSString *)phone first_name:(NSString *)first_name last_name:(NSString *)last_name
{
    API17_InputContact_inputPhoneContact *_object = [[API17_InputContact_inputPhoneContact alloc] init];
    _object.client_id = [API17__Serializer addSerializerToObject:[client_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.phone = [API17__Serializer addSerializerToObject:[phone copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_InputContact_inputPhoneContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf392b7f4 serializeBlock:^bool (API17_InputContact_inputPhoneContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.client_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.phone data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Contacts ()

@end

@interface API17_contacts_Contacts_contacts_contacts ()

@property (nonatomic, strong) NSArray * contacts;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Contacts_contacts_contactsNotModified ()

@end

@implementation API17_contacts_Contacts

+ (API17_contacts_Contacts_contacts_contacts *)contacts_contactsWithContacts:(NSArray *)contacts users:(NSArray *)users
{
    API17_contacts_Contacts_contacts_contacts *_object = [[API17_contacts_Contacts_contacts_contacts alloc] init];
    _object.contacts = [API17__Serializer addSerializerToObject:[contacts copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_contacts_Contacts_contacts_contactsNotModified *)contacts_contactsNotModified
{
    API17_contacts_Contacts_contacts_contactsNotModified *_object = [[API17_contacts_Contacts_contacts_contactsNotModified alloc] init];
    return _object;
}


@end

@implementation API17_contacts_Contacts_contacts_contacts

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6f8b8cb2 serializeBlock:^bool (API17_contacts_Contacts_contacts_contacts *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.contacts data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_Contacts_contacts_contactsNotModified

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb74ba9d2 serializeBlock:^bool (__unused API17_contacts_Contacts_contacts_contactsNotModified *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_BadMsgNotification ()

@property (nonatomic, strong) NSNumber * bad_msg_id;
@property (nonatomic, strong) NSNumber * bad_msg_seqno;
@property (nonatomic, strong) NSNumber * error_code;

@end

@interface API17_BadMsgNotification_bad_msg_notification ()

@end

@interface API17_BadMsgNotification_bad_server_salt ()

@property (nonatomic, strong) NSNumber * pnew_server_salt;

@end

@implementation API17_BadMsgNotification

+ (API17_BadMsgNotification_bad_msg_notification *)bad_msg_notificationWithBad_msg_id:(NSNumber *)bad_msg_id bad_msg_seqno:(NSNumber *)bad_msg_seqno error_code:(NSNumber *)error_code
{
    API17_BadMsgNotification_bad_msg_notification *_object = [[API17_BadMsgNotification_bad_msg_notification alloc] init];
    _object.bad_msg_id = [API17__Serializer addSerializerToObject:[bad_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.bad_msg_seqno = [API17__Serializer addSerializerToObject:[bad_msg_seqno copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.error_code = [API17__Serializer addSerializerToObject:[error_code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_BadMsgNotification_bad_server_salt *)bad_server_saltWithBad_msg_id:(NSNumber *)bad_msg_id bad_msg_seqno:(NSNumber *)bad_msg_seqno error_code:(NSNumber *)error_code pnew_server_salt:(NSNumber *)pnew_server_salt
{
    API17_BadMsgNotification_bad_server_salt *_object = [[API17_BadMsgNotification_bad_server_salt alloc] init];
    _object.bad_msg_id = [API17__Serializer addSerializerToObject:[bad_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.bad_msg_seqno = [API17__Serializer addSerializerToObject:[bad_msg_seqno copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.error_code = [API17__Serializer addSerializerToObject:[error_code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pnew_server_salt = [API17__Serializer addSerializerToObject:[pnew_server_salt copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_BadMsgNotification_bad_msg_notification

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa7eff811 serializeBlock:^bool (API17_BadMsgNotification_bad_msg_notification *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.bad_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bad_msg_seqno data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.error_code data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_BadMsgNotification_bad_server_salt

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xedab447b serializeBlock:^bool (API17_BadMsgNotification_bad_server_salt *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.bad_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bad_msg_seqno data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.error_code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_server_salt data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputDocument ()

@end

@interface API17_InputDocument_inputDocumentEmpty ()

@end

@interface API17_InputDocument_inputDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputDocument

+ (API17_InputDocument_inputDocumentEmpty *)inputDocumentEmpty
{
    API17_InputDocument_inputDocumentEmpty *_object = [[API17_InputDocument_inputDocumentEmpty alloc] init];
    return _object;
}

+ (API17_InputDocument_inputDocument *)inputDocumentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputDocument_inputDocument *_object = [[API17_InputDocument_inputDocument alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputDocument_inputDocumentEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x72f0eaae serializeBlock:^bool (__unused API17_InputDocument_inputDocumentEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputDocument_inputDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x18798952 serializeBlock:^bool (API17_InputDocument_inputDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputMedia ()

@end

@interface API17_InputMedia_inputMediaEmpty ()

@end

@interface API17_InputMedia_inputMediaUploadedPhoto ()

@property (nonatomic, strong) API17_InputFile * file;

@end

@interface API17_InputMedia_inputMediaPhoto ()

@property (nonatomic, strong) API17_InputPhoto * pid;

@end

@interface API17_InputMedia_inputMediaGeoPoint ()

@property (nonatomic, strong) API17_InputGeoPoint * geo_point;

@end

@interface API17_InputMedia_inputMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;

@end

@interface API17_InputMedia_inputMediaVideo ()

@property (nonatomic, strong) API17_InputVideo * pid;

@end

@interface API17_InputMedia_inputMediaAudio ()

@property (nonatomic, strong) API17_InputAudio * pid;

@end

@interface API17_InputMedia_inputMediaUploadedDocument ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedThumbDocument ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) API17_InputFile * thumb;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaDocument ()

@property (nonatomic, strong) API17_InputDocument * pid;

@end

@interface API17_InputMedia_inputMediaUploadedAudio ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedVideo ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedThumbVideo ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) API17_InputFile * thumb;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSString * mime_type;

@end

@implementation API17_InputMedia

+ (API17_InputMedia_inputMediaEmpty *)inputMediaEmpty
{
    API17_InputMedia_inputMediaEmpty *_object = [[API17_InputMedia_inputMediaEmpty alloc] init];
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedPhoto *)inputMediaUploadedPhotoWithFile:(API17_InputFile *)file
{
    API17_InputMedia_inputMediaUploadedPhoto *_object = [[API17_InputMedia_inputMediaUploadedPhoto alloc] init];
    _object.file = file;
    return _object;
}

+ (API17_InputMedia_inputMediaPhoto *)inputMediaPhotoWithPid:(API17_InputPhoto *)pid
{
    API17_InputMedia_inputMediaPhoto *_object = [[API17_InputMedia_inputMediaPhoto alloc] init];
    _object.pid = pid;
    return _object;
}

+ (API17_InputMedia_inputMediaGeoPoint *)inputMediaGeoPointWithGeo_point:(API17_InputGeoPoint *)geo_point
{
    API17_InputMedia_inputMediaGeoPoint *_object = [[API17_InputMedia_inputMediaGeoPoint alloc] init];
    _object.geo_point = geo_point;
    return _object;
}

+ (API17_InputMedia_inputMediaContact *)inputMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name
{
    API17_InputMedia_inputMediaContact *_object = [[API17_InputMedia_inputMediaContact alloc] init];
    _object.phone_number = [API17__Serializer addSerializerToObject:[phone_number copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputMedia_inputMediaVideo *)inputMediaVideoWithPid:(API17_InputVideo *)pid
{
    API17_InputMedia_inputMediaVideo *_object = [[API17_InputMedia_inputMediaVideo alloc] init];
    _object.pid = pid;
    return _object;
}

+ (API17_InputMedia_inputMediaAudio *)inputMediaAudioWithPid:(API17_InputAudio *)pid
{
    API17_InputMedia_inputMediaAudio *_object = [[API17_InputMedia_inputMediaAudio alloc] init];
    _object.pid = pid;
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedDocument *)inputMediaUploadedDocumentWithFile:(API17_InputFile *)file file_name:(NSString *)file_name mime_type:(NSString *)mime_type
{
    API17_InputMedia_inputMediaUploadedDocument *_object = [[API17_InputMedia_inputMediaUploadedDocument alloc] init];
    _object.file = file;
    _object.file_name = [API17__Serializer addSerializerToObject:[file_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedThumbDocument *)inputMediaUploadedThumbDocumentWithFile:(API17_InputFile *)file thumb:(API17_InputFile *)thumb file_name:(NSString *)file_name mime_type:(NSString *)mime_type
{
    API17_InputMedia_inputMediaUploadedThumbDocument *_object = [[API17_InputMedia_inputMediaUploadedThumbDocument alloc] init];
    _object.file = file;
    _object.thumb = thumb;
    _object.file_name = [API17__Serializer addSerializerToObject:[file_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputMedia_inputMediaDocument *)inputMediaDocumentWithPid:(API17_InputDocument *)pid
{
    API17_InputMedia_inputMediaDocument *_object = [[API17_InputMedia_inputMediaDocument alloc] init];
    _object.pid = pid;
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedAudio *)inputMediaUploadedAudioWithFile:(API17_InputFile *)file duration:(NSNumber *)duration mime_type:(NSString *)mime_type
{
    API17_InputMedia_inputMediaUploadedAudio *_object = [[API17_InputMedia_inputMediaUploadedAudio alloc] init];
    _object.file = file;
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedVideo *)inputMediaUploadedVideoWithFile:(API17_InputFile *)file duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mime_type:(NSString *)mime_type
{
    API17_InputMedia_inputMediaUploadedVideo *_object = [[API17_InputMedia_inputMediaUploadedVideo alloc] init];
    _object.file = file;
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_InputMedia_inputMediaUploadedThumbVideo *)inputMediaUploadedThumbVideoWithFile:(API17_InputFile *)file thumb:(API17_InputFile *)thumb duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mime_type:(NSString *)mime_type
{
    API17_InputMedia_inputMediaUploadedThumbVideo *_object = [[API17_InputMedia_inputMediaUploadedThumbVideo alloc] init];
    _object.file = file;
    _object.thumb = thumb;
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_InputMedia_inputMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9664f57f serializeBlock:^bool (__unused API17_InputMedia_inputMediaEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2dc53a7d serializeBlock:^bool (API17_InputMedia_inputMediaUploadedPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8f2ab2ec serializeBlock:^bool (API17_InputMedia_inputMediaPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf9c44144 serializeBlock:^bool (API17_InputMedia_inputMediaGeoPoint *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.geo_point data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa6e45987 serializeBlock:^bool (API17_InputMedia_inputMediaContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7f023ae6 serializeBlock:^bool (API17_InputMedia_inputMediaVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x89938781 serializeBlock:^bool (API17_InputMedia_inputMediaAudio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x34e794bd serializeBlock:^bool (API17_InputMedia_inputMediaUploadedDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedThumbDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3e46de5d serializeBlock:^bool (API17_InputMedia_inputMediaUploadedThumbDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd184e841 serializeBlock:^bool (API17_InputMedia_inputMediaDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4e498cab serializeBlock:^bool (API17_InputMedia_inputMediaUploadedAudio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x133ad6f6 serializeBlock:^bool (API17_InputMedia_inputMediaUploadedVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputMedia_inputMediaUploadedThumbVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9912dabf serializeBlock:^bool (API17_InputMedia_inputMediaUploadedThumbVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPeer ()

@end

@interface API17_InputPeer_inputPeerEmpty ()

@end

@interface API17_InputPeer_inputPeerSelf ()

@end

@interface API17_InputPeer_inputPeerContact ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_InputPeer_inputPeerForeign ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputPeer_inputPeerChat ()

@property (nonatomic, strong) NSNumber * chat_id;

@end

@implementation API17_InputPeer

+ (API17_InputPeer_inputPeerEmpty *)inputPeerEmpty
{
    API17_InputPeer_inputPeerEmpty *_object = [[API17_InputPeer_inputPeerEmpty alloc] init];
    return _object;
}

+ (API17_InputPeer_inputPeerSelf *)inputPeerSelf
{
    API17_InputPeer_inputPeerSelf *_object = [[API17_InputPeer_inputPeerSelf alloc] init];
    return _object;
}

+ (API17_InputPeer_inputPeerContact *)inputPeerContactWithUser_id:(NSNumber *)user_id
{
    API17_InputPeer_inputPeerContact *_object = [[API17_InputPeer_inputPeerContact alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_InputPeer_inputPeerForeign *)inputPeerForeignWithUser_id:(NSNumber *)user_id access_hash:(NSNumber *)access_hash
{
    API17_InputPeer_inputPeerForeign *_object = [[API17_InputPeer_inputPeerForeign alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputPeer_inputPeerChat *)inputPeerChatWithChat_id:(NSNumber *)chat_id
{
    API17_InputPeer_inputPeerChat *_object = [[API17_InputPeer_inputPeerChat alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_InputPeer_inputPeerEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7f3b18ea serializeBlock:^bool (__unused API17_InputPeer_inputPeerEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPeer_inputPeerSelf

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7da07ec9 serializeBlock:^bool (__unused API17_InputPeer_inputPeerSelf *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPeer_inputPeerContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1023dbe8 serializeBlock:^bool (API17_InputPeer_inputPeerContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPeer_inputPeerForeign

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9b447325 serializeBlock:^bool (API17_InputPeer_inputPeerForeign *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPeer_inputPeerChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x179be863 serializeBlock:^bool (API17_InputPeer_inputPeerChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Contact ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) API17_Bool * mutual;

@end

@interface API17_Contact_contact ()

@end

@implementation API17_Contact

+ (API17_Contact_contact *)contactWithUser_id:(NSNumber *)user_id mutual:(API17_Bool *)mutual
{
    API17_Contact_contact *_object = [[API17_Contact_contact alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mutual = mutual;
    return _object;
}


@end

@implementation API17_Contact_contact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf911c994 serializeBlock:^bool (API17_Contact_contact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mutual data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_Chats ()

@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_messages_Chats_messages_chats ()

@end

@implementation API17_messages_Chats

+ (API17_messages_Chats_messages_chats *)messages_chatsWithChats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Chats_messages_chats *_object = [[API17_messages_Chats_messages_chats alloc] init];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_Chats_messages_chats

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8150cbd8 serializeBlock:^bool (API17_messages_Chats_messages_chats *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_P_Q_inner_data ()

@property (nonatomic, strong) NSData * pq;
@property (nonatomic, strong) NSData * p;
@property (nonatomic, strong) NSData * q;
@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;
@property (nonatomic, strong) NSData * pnew_nonce;

@end

@interface API17_P_Q_inner_data_p_q_inner_data ()

@end

@implementation API17_P_Q_inner_data

+ (API17_P_Q_inner_data_p_q_inner_data *)p_q_inner_dataWithPq:(NSData *)pq p:(NSData *)p q:(NSData *)q nonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce:(NSData *)pnew_nonce
{
    API17_P_Q_inner_data_p_q_inner_data *_object = [[API17_P_Q_inner_data_p_q_inner_data alloc] init];
    _object.pq = [API17__Serializer addSerializerToObject:[pq copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.p = [API17__Serializer addSerializerToObject:[p copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.q = [API17__Serializer addSerializerToObject:[q copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pnew_nonce = [API17__Serializer addSerializerToObject:[pnew_nonce copy] serializer:[[API17_BuiltinSerializer_Int256 alloc] init]];
    return _object;
}


@end

@implementation API17_P_Q_inner_data_p_q_inner_data

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x83c95aec serializeBlock:^bool (API17_P_Q_inner_data_p_q_inner_data *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pq data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.p data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.q data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_nonce data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_MyLink ()

@end

@interface API17_contacts_MyLink_contacts_myLinkEmpty ()

@end

@interface API17_contacts_MyLink_contacts_myLinkRequested ()

@property (nonatomic, strong) API17_Bool * contact;

@end

@interface API17_contacts_MyLink_contacts_myLinkContact ()

@end

@implementation API17_contacts_MyLink

+ (API17_contacts_MyLink_contacts_myLinkEmpty *)contacts_myLinkEmpty
{
    API17_contacts_MyLink_contacts_myLinkEmpty *_object = [[API17_contacts_MyLink_contacts_myLinkEmpty alloc] init];
    return _object;
}

+ (API17_contacts_MyLink_contacts_myLinkRequested *)contacts_myLinkRequestedWithContact:(API17_Bool *)contact
{
    API17_contacts_MyLink_contacts_myLinkRequested *_object = [[API17_contacts_MyLink_contacts_myLinkRequested alloc] init];
    _object.contact = contact;
    return _object;
}

+ (API17_contacts_MyLink_contacts_myLinkContact *)contacts_myLinkContact
{
    API17_contacts_MyLink_contacts_myLinkContact *_object = [[API17_contacts_MyLink_contacts_myLinkContact alloc] init];
    return _object;
}


@end

@implementation API17_contacts_MyLink_contacts_myLinkEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd22a1c60 serializeBlock:^bool (__unused API17_contacts_MyLink_contacts_myLinkEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_MyLink_contacts_myLinkRequested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6c69efee serializeBlock:^bool (API17_contacts_MyLink_contacts_myLinkRequested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.contact data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_MyLink_contacts_myLinkContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc240ebd9 serializeBlock:^bool (__unused API17_contacts_MyLink_contacts_myLinkContact *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_DhConfig ()

@property (nonatomic, strong) NSData * random;

@end

@interface API17_messages_DhConfig_messages_dhConfigNotModified ()

@end

@interface API17_messages_DhConfig_messages_dhConfig ()

@property (nonatomic, strong) NSNumber * g;
@property (nonatomic, strong) NSData * p;
@property (nonatomic, strong) NSNumber * version;

@end

@implementation API17_messages_DhConfig

+ (API17_messages_DhConfig_messages_dhConfigNotModified *)messages_dhConfigNotModifiedWithRandom:(NSData *)random
{
    API17_messages_DhConfig_messages_dhConfigNotModified *_object = [[API17_messages_DhConfig_messages_dhConfigNotModified alloc] init];
    _object.random = [API17__Serializer addSerializerToObject:[random copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_messages_DhConfig_messages_dhConfig *)messages_dhConfigWithG:(NSNumber *)g p:(NSData *)p version:(NSNumber *)version random:(NSData *)random
{
    API17_messages_DhConfig_messages_dhConfig *_object = [[API17_messages_DhConfig_messages_dhConfig alloc] init];
    _object.g = [API17__Serializer addSerializerToObject:[g copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.p = [API17__Serializer addSerializerToObject:[p copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.random = [API17__Serializer addSerializerToObject:[random copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_messages_DhConfig_messages_dhConfigNotModified

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc0e24635 serializeBlock:^bool (API17_messages_DhConfig_messages_dhConfigNotModified *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_DhConfig_messages_dhConfig

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2c221edd serializeBlock:^bool (API17_messages_DhConfig_messages_dhConfig *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.g data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.p data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.random data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_auth_ExportedAuthorization ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSData * bytes;

@end

@interface API17_auth_ExportedAuthorization_auth_exportedAuthorization ()

@end

@implementation API17_auth_ExportedAuthorization

+ (API17_auth_ExportedAuthorization_auth_exportedAuthorization *)auth_exportedAuthorizationWithPid:(NSNumber *)pid bytes:(NSData *)bytes
{
    API17_auth_ExportedAuthorization_auth_exportedAuthorization *_object = [[API17_auth_ExportedAuthorization_auth_exportedAuthorization alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_auth_ExportedAuthorization_auth_exportedAuthorization

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xdf969c2d serializeBlock:^bool (API17_auth_ExportedAuthorization_auth_exportedAuthorization *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactRequest ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_ContactRequest_contactRequest ()

@end

@implementation API17_ContactRequest

+ (API17_ContactRequest_contactRequest *)contactRequestWithUser_id:(NSNumber *)user_id date:(NSNumber *)date
{
    API17_ContactRequest_contactRequest *_object = [[API17_ContactRequest_contactRequest alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactRequest_contactRequest

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x59f24214 serializeBlock:^bool (API17_ContactRequest_contactRequest *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_AffectedHistory ()

@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * seq;
@property (nonatomic, strong) NSNumber * offset;

@end

@interface API17_messages_AffectedHistory_messages_affectedHistory ()

@end

@implementation API17_messages_AffectedHistory

+ (API17_messages_AffectedHistory_messages_affectedHistory *)messages_affectedHistoryWithPts:(NSNumber *)pts seq:(NSNumber *)seq offset:(NSNumber *)offset
{
    API17_messages_AffectedHistory_messages_affectedHistory *_object = [[API17_messages_AffectedHistory_messages_affectedHistory alloc] init];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.offset = [API17__Serializer addSerializerToObject:[offset copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_messages_AffectedHistory_messages_affectedHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb7de36f2 serializeBlock:^bool (API17_messages_AffectedHistory_messages_affectedHistory *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_SentMessage ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_messages_SentMessage_messages_sentMessageLink ()

@property (nonatomic, strong) NSArray * links;

@end

@interface API17_messages_SentMessage_messages_sentMessage ()

@end

@implementation API17_messages_SentMessage

+ (API17_messages_SentMessage_messages_sentMessageLink *)messages_sentMessageLinkWithPid:(NSNumber *)pid date:(NSNumber *)date pts:(NSNumber *)pts seq:(NSNumber *)seq links:(NSArray *)links
{
    API17_messages_SentMessage_messages_sentMessageLink *_object = [[API17_messages_SentMessage_messages_sentMessageLink alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.links = [API17__Serializer addSerializerToObject:[links copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_messages_SentMessage_messages_sentMessage *)messages_sentMessageWithPid:(NSNumber *)pid date:(NSNumber *)date pts:(NSNumber *)pts seq:(NSNumber *)seq
{
    API17_messages_SentMessage_messages_sentMessage *_object = [[API17_messages_SentMessage_messages_sentMessage alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_messages_SentMessage_messages_sentMessageLink

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe9db4a3f serializeBlock:^bool (API17_messages_SentMessage_messages_sentMessageLink *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.links data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_SentMessage_messages_sentMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd1f4d35c serializeBlock:^bool (API17_messages_SentMessage_messages_sentMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_ChatFull ()

@property (nonatomic, strong) API17_ChatFull * full_chat;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_messages_ChatFull_messages_chatFull ()

@end

@implementation API17_messages_ChatFull

+ (API17_messages_ChatFull_messages_chatFull *)messages_chatFullWithFull_chat:(API17_ChatFull *)full_chat chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_ChatFull_messages_chatFull *_object = [[API17_messages_ChatFull_messages_chatFull alloc] init];
    _object.full_chat = full_chat;
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_ChatFull_messages_chatFull

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe5d7d19c serializeBlock:^bool (API17_messages_ChatFull_messages_chatFull *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.full_chat data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_ForeignLink ()

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkUnknown ()

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkRequested ()

@property (nonatomic, strong) API17_Bool * has_phone;

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkMutual ()

@end

@implementation API17_contacts_ForeignLink

+ (API17_contacts_ForeignLink_contacts_foreignLinkUnknown *)contacts_foreignLinkUnknown
{
    API17_contacts_ForeignLink_contacts_foreignLinkUnknown *_object = [[API17_contacts_ForeignLink_contacts_foreignLinkUnknown alloc] init];
    return _object;
}

+ (API17_contacts_ForeignLink_contacts_foreignLinkRequested *)contacts_foreignLinkRequestedWithHas_phone:(API17_Bool *)has_phone
{
    API17_contacts_ForeignLink_contacts_foreignLinkRequested *_object = [[API17_contacts_ForeignLink_contacts_foreignLinkRequested alloc] init];
    _object.has_phone = has_phone;
    return _object;
}

+ (API17_contacts_ForeignLink_contacts_foreignLinkMutual *)contacts_foreignLinkMutual
{
    API17_contacts_ForeignLink_contacts_foreignLinkMutual *_object = [[API17_contacts_ForeignLink_contacts_foreignLinkMutual alloc] init];
    return _object;
}


@end

@implementation API17_contacts_ForeignLink_contacts_foreignLinkUnknown

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x133421f8 serializeBlock:^bool (__unused API17_contacts_ForeignLink_contacts_foreignLinkUnknown *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_ForeignLink_contacts_foreignLinkRequested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa7801f47 serializeBlock:^bool (API17_contacts_ForeignLink_contacts_foreignLinkRequested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.has_phone data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_contacts_ForeignLink_contacts_foreignLinkMutual

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1bea8ce1 serializeBlock:^bool (__unused API17_contacts_ForeignLink_contacts_foreignLinkMutual *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputEncryptedChat ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputEncryptedChat_inputEncryptedChat ()

@end

@implementation API17_InputEncryptedChat

+ (API17_InputEncryptedChat_inputEncryptedChat *)inputEncryptedChatWithChat_id:(NSNumber *)chat_id access_hash:(NSNumber *)access_hash
{
    API17_InputEncryptedChat_inputEncryptedChat *_object = [[API17_InputEncryptedChat_inputEncryptedChat alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputEncryptedChat_inputEncryptedChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf141b5e1 serializeBlock:^bool (API17_InputEncryptedChat_inputEncryptedChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InvokeWithLayer17 ()

@property (nonatomic, strong) NSObject * query;

@end

@interface API17_InvokeWithLayer17_invokeWithLayer17 ()

@end

@implementation API17_InvokeWithLayer17

+ (API17_InvokeWithLayer17_invokeWithLayer17 *)invokeWithLayer17WithQuery:(NSObject *)query
{
    API17_InvokeWithLayer17_invokeWithLayer17 *_object = [[API17_InvokeWithLayer17_invokeWithLayer17 alloc] init];
    _object.query = query;
    return _object;
}


@end

@implementation API17_InvokeWithLayer17_invokeWithLayer17

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x50858a19 serializeBlock:^bool (API17_InvokeWithLayer17_invokeWithLayer17 *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.query data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_EncryptedFile ()

@end

@interface API17_EncryptedFile_encryptedFileEmpty ()

@end

@interface API17_EncryptedFile_encryptedFile ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSNumber * dc_id;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@implementation API17_EncryptedFile

+ (API17_EncryptedFile_encryptedFileEmpty *)encryptedFileEmpty
{
    API17_EncryptedFile_encryptedFileEmpty *_object = [[API17_EncryptedFile_encryptedFileEmpty alloc] init];
    return _object;
}

+ (API17_EncryptedFile_encryptedFile *)encryptedFileWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash size:(NSNumber *)size dc_id:(NSNumber *)dc_id key_fingerprint:(NSNumber *)key_fingerprint
{
    API17_EncryptedFile_encryptedFile *_object = [[API17_EncryptedFile_encryptedFile alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key_fingerprint = [API17__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_EncryptedFile_encryptedFileEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc21f497e serializeBlock:^bool (__unused API17_EncryptedFile_encryptedFileEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedFile_encryptedFile

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4a70994c serializeBlock:^bool (API17_EncryptedFile_encryptedFile *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactFound ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_ContactFound_contactFound ()

@end

@implementation API17_ContactFound

+ (API17_ContactFound_contactFound *)contactFoundWithUser_id:(NSNumber *)user_id
{
    API17_ContactFound_contactFound *_object = [[API17_ContactFound_contactFound alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactFound_contactFound

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xea879f95 serializeBlock:^bool (API17_ContactFound_contactFound *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_NotifyPeer ()

@end

@interface API17_NotifyPeer_notifyPeer ()

@property (nonatomic, strong) API17_Peer * peer;

@end

@interface API17_NotifyPeer_notifyUsers ()

@end

@interface API17_NotifyPeer_notifyChats ()

@end

@interface API17_NotifyPeer_notifyAll ()

@end

@implementation API17_NotifyPeer

+ (API17_NotifyPeer_notifyPeer *)notifyPeerWithPeer:(API17_Peer *)peer
{
    API17_NotifyPeer_notifyPeer *_object = [[API17_NotifyPeer_notifyPeer alloc] init];
    _object.peer = peer;
    return _object;
}

+ (API17_NotifyPeer_notifyUsers *)notifyUsers
{
    API17_NotifyPeer_notifyUsers *_object = [[API17_NotifyPeer_notifyUsers alloc] init];
    return _object;
}

+ (API17_NotifyPeer_notifyChats *)notifyChats
{
    API17_NotifyPeer_notifyChats *_object = [[API17_NotifyPeer_notifyChats alloc] init];
    return _object;
}

+ (API17_NotifyPeer_notifyAll *)notifyAll
{
    API17_NotifyPeer_notifyAll *_object = [[API17_NotifyPeer_notifyAll alloc] init];
    return _object;
}


@end

@implementation API17_NotifyPeer_notifyPeer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9fd40bd8 serializeBlock:^bool (API17_NotifyPeer_notifyPeer *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.peer data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_NotifyPeer_notifyUsers

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb4c83b4c serializeBlock:^bool (__unused API17_NotifyPeer_notifyUsers *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_NotifyPeer_notifyChats

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc007cec3 serializeBlock:^bool (__unused API17_NotifyPeer_notifyChats *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_NotifyPeer_notifyAll

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x74d07c60 serializeBlock:^bool (__unused API17_NotifyPeer_notifyAll *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Client_DH_Inner_Data ()

@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;
@property (nonatomic, strong) NSNumber * retry_id;
@property (nonatomic, strong) NSData * g_b;

@end

@interface API17_Client_DH_Inner_Data_client_DH_inner_data ()

@end

@implementation API17_Client_DH_Inner_Data

+ (API17_Client_DH_Inner_Data_client_DH_inner_data *)client_DH_inner_dataWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce retry_id:(NSNumber *)retry_id g_b:(NSData *)g_b
{
    API17_Client_DH_Inner_Data_client_DH_inner_data *_object = [[API17_Client_DH_Inner_Data_client_DH_inner_data alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.retry_id = [API17__Serializer addSerializerToObject:[retry_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.g_b = [API17__Serializer addSerializerToObject:[g_b copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_Client_DH_Inner_Data_client_DH_inner_data

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6643b654 serializeBlock:^bool (API17_Client_DH_Inner_Data_client_DH_inner_data *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.retry_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.g_b data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Link ()

@property (nonatomic, strong) API17_contacts_MyLink * my_link;
@property (nonatomic, strong) API17_contacts_ForeignLink * foreign_link;
@property (nonatomic, strong) API17_User * user;

@end

@interface API17_contacts_Link_contacts_link ()

@end

@implementation API17_contacts_Link

+ (API17_contacts_Link_contacts_link *)contacts_linkWithMy_link:(API17_contacts_MyLink *)my_link foreign_link:(API17_contacts_ForeignLink *)foreign_link user:(API17_User *)user
{
    API17_contacts_Link_contacts_link *_object = [[API17_contacts_Link_contacts_link alloc] init];
    _object.my_link = my_link;
    _object.foreign_link = foreign_link;
    _object.user = user;
    return _object;
}


@end

@implementation API17_contacts_Link_contacts_link

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xeccea3f5 serializeBlock:^bool (API17_contacts_Link_contacts_link *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.my_link data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.foreign_link data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.user data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactBlocked ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_ContactBlocked_contactBlocked ()

@end

@implementation API17_ContactBlocked

+ (API17_ContactBlocked_contactBlocked *)contactBlockedWithUser_id:(NSNumber *)user_id date:(NSNumber *)date
{
    API17_ContactBlocked_contactBlocked *_object = [[API17_ContactBlocked_contactBlocked alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactBlocked_contactBlocked

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x561bc879 serializeBlock:^bool (API17_ContactBlocked_contactBlocked *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_auth_CheckedPhone ()

@property (nonatomic, strong) API17_Bool * phone_registered;
@property (nonatomic, strong) API17_Bool * phone_invited;

@end

@interface API17_auth_CheckedPhone_auth_checkedPhone ()

@end

@implementation API17_auth_CheckedPhone

+ (API17_auth_CheckedPhone_auth_checkedPhone *)auth_checkedPhoneWithPhone_registered:(API17_Bool *)phone_registered phone_invited:(API17_Bool *)phone_invited
{
    API17_auth_CheckedPhone_auth_checkedPhone *_object = [[API17_auth_CheckedPhone_auth_checkedPhone alloc] init];
    _object.phone_registered = phone_registered;
    _object.phone_invited = phone_invited;
    return _object;
}


@end

@implementation API17_auth_CheckedPhone_auth_checkedPhone

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe300cc3b serializeBlock:^bool (API17_auth_CheckedPhone_auth_checkedPhone *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_registered data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.phone_invited data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputUser ()

@end

@interface API17_InputUser_inputUserEmpty ()

@end

@interface API17_InputUser_inputUserSelf ()

@end

@interface API17_InputUser_inputUserContact ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_InputUser_inputUserForeign ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputUser

+ (API17_InputUser_inputUserEmpty *)inputUserEmpty
{
    API17_InputUser_inputUserEmpty *_object = [[API17_InputUser_inputUserEmpty alloc] init];
    return _object;
}

+ (API17_InputUser_inputUserSelf *)inputUserSelf
{
    API17_InputUser_inputUserSelf *_object = [[API17_InputUser_inputUserSelf alloc] init];
    return _object;
}

+ (API17_InputUser_inputUserContact *)inputUserContactWithUser_id:(NSNumber *)user_id
{
    API17_InputUser_inputUserContact *_object = [[API17_InputUser_inputUserContact alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_InputUser_inputUserForeign *)inputUserForeignWithUser_id:(NSNumber *)user_id access_hash:(NSNumber *)access_hash
{
    API17_InputUser_inputUserForeign *_object = [[API17_InputUser_inputUserForeign alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputUser_inputUserEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb98886cf serializeBlock:^bool (__unused API17_InputUser_inputUserEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputUser_inputUserSelf

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf7c1b13f serializeBlock:^bool (__unused API17_InputUser_inputUserSelf *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputUser_inputUserContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x86e94f65 serializeBlock:^bool (API17_InputUser_inputUserContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputUser_inputUserForeign

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x655e74ff serializeBlock:^bool (API17_InputUser_inputUserForeign *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_SchemeType ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSString * predicate;
@property (nonatomic, strong) NSArray * params;
@property (nonatomic, strong) NSString * type;

@end

@interface API17_SchemeType_schemeType ()

@end

@implementation API17_SchemeType

+ (API17_SchemeType_schemeType *)schemeTypeWithPid:(NSNumber *)pid predicate:(NSString *)predicate params:(NSArray *)params type:(NSString *)type
{
    API17_SchemeType_schemeType *_object = [[API17_SchemeType_schemeType alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.predicate = [API17__Serializer addSerializerToObject:[predicate copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.params = [API17__Serializer addSerializerToObject:[params copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_SchemeType_schemeType

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa8e1e989 serializeBlock:^bool (API17_SchemeType_schemeType *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.predicate data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.params data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_geochats_StatedMessage ()

@property (nonatomic, strong) API17_GeoChatMessage * message;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_geochats_StatedMessage_geochats_statedMessage ()

@end

@implementation API17_geochats_StatedMessage

+ (API17_geochats_StatedMessage_geochats_statedMessage *)geochats_statedMessageWithMessage:(API17_GeoChatMessage *)message chats:(NSArray *)chats users:(NSArray *)users seq:(NSNumber *)seq
{
    API17_geochats_StatedMessage_geochats_statedMessage *_object = [[API17_geochats_StatedMessage_geochats_statedMessage alloc] init];
    _object.message = message;
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_geochats_StatedMessage_geochats_statedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x17b1578b serializeBlock:^bool (API17_geochats_StatedMessage_geochats_statedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_upload_File ()

@property (nonatomic, strong) API17_storage_FileType * type;
@property (nonatomic, strong) NSNumber * mtime;
@property (nonatomic, strong) NSData * bytes;

@end

@interface API17_upload_File_upload_file ()

@end

@implementation API17_upload_File

+ (API17_upload_File_upload_file *)upload_fileWithType:(API17_storage_FileType *)type mtime:(NSNumber *)mtime bytes:(NSData *)bytes
{
    API17_upload_File_upload_file *_object = [[API17_upload_File_upload_file alloc] init];
    _object.type = type;
    _object.mtime = [API17__Serializer addSerializerToObject:[mtime copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_upload_File_upload_file

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x96a18d5 serializeBlock:^bool (API17_upload_File_upload_file *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.type data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.mtime data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputVideo ()

@end

@interface API17_InputVideo_inputVideoEmpty ()

@end

@interface API17_InputVideo_inputVideo ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputVideo

+ (API17_InputVideo_inputVideoEmpty *)inputVideoEmpty
{
    API17_InputVideo_inputVideoEmpty *_object = [[API17_InputVideo_inputVideoEmpty alloc] init];
    return _object;
}

+ (API17_InputVideo_inputVideo *)inputVideoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputVideo_inputVideo *_object = [[API17_InputVideo_inputVideo alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputVideo_inputVideoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5508ec75 serializeBlock:^bool (__unused API17_InputVideo_inputVideoEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputVideo_inputVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xee579652 serializeBlock:^bool (API17_InputVideo_inputVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_FutureSalt ()

@property (nonatomic, strong) NSNumber * valid_since;
@property (nonatomic, strong) NSNumber * valid_until;
@property (nonatomic, strong) NSNumber * salt;

@end

@interface API17_FutureSalt_futureSalt ()

@end

@implementation API17_FutureSalt

+ (API17_FutureSalt_futureSalt *)futureSaltWithValid_since:(NSNumber *)valid_since valid_until:(NSNumber *)valid_until salt:(NSNumber *)salt
{
    API17_FutureSalt_futureSalt *_object = [[API17_FutureSalt_futureSalt alloc] init];
    _object.valid_since = [API17__Serializer addSerializerToObject:[valid_since copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.valid_until = [API17__Serializer addSerializerToObject:[valid_until copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.salt = [API17__Serializer addSerializerToObject:[salt copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_FutureSalt_futureSalt

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x949d9dc serializeBlock:^bool (API17_FutureSalt_futureSalt *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.valid_since data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.valid_until data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.salt data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Config ()

@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) API17_Bool * test_mode;
@property (nonatomic, strong) NSNumber * this_dc;
@property (nonatomic, strong) NSArray * dc_options;
@property (nonatomic, strong) NSNumber * chat_size_max;
@property (nonatomic, strong) NSNumber * broadcast_size_max;

@end

@interface API17_Config_config ()

@end

@implementation API17_Config

+ (API17_Config_config *)configWithDate:(NSNumber *)date test_mode:(API17_Bool *)test_mode this_dc:(NSNumber *)this_dc dc_options:(NSArray *)dc_options chat_size_max:(NSNumber *)chat_size_max broadcast_size_max:(NSNumber *)broadcast_size_max
{
    API17_Config_config *_object = [[API17_Config_config alloc] init];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.test_mode = test_mode;
    _object.this_dc = [API17__Serializer addSerializerToObject:[this_dc copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.dc_options = [API17__Serializer addSerializerToObject:[dc_options copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chat_size_max = [API17__Serializer addSerializerToObject:[chat_size_max copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.broadcast_size_max = [API17__Serializer addSerializerToObject:[broadcast_size_max copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Config_config

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2e54dd74 serializeBlock:^bool (API17_Config_config *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.test_mode data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.this_dc data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.dc_options data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chat_size_max data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.broadcast_size_max data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ProtoMessageCopy ()

@property (nonatomic, strong) API17_ProtoMessage * orig_message;

@end

@interface API17_ProtoMessageCopy_msg_copy ()

@end

@implementation API17_ProtoMessageCopy

+ (API17_ProtoMessageCopy_msg_copy *)msg_copyWithOrig_message:(API17_ProtoMessage *)orig_message
{
    API17_ProtoMessageCopy_msg_copy *_object = [[API17_ProtoMessageCopy_msg_copy alloc] init];
    _object.orig_message = orig_message;
    return _object;
}


@end

@implementation API17_ProtoMessageCopy_msg_copy

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe06046b2 serializeBlock:^bool (API17_ProtoMessageCopy_msg_copy *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.orig_message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Audio ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Audio_audioEmpty ()

@end

@interface API17_Audio_audio ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSNumber * dc_id;

@end

@implementation API17_Audio

+ (API17_Audio_audioEmpty *)audioEmptyWithPid:(NSNumber *)pid
{
    API17_Audio_audioEmpty *_object = [[API17_Audio_audioEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Audio_audio *)audioWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date duration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size dc_id:(NSNumber *)dc_id
{
    API17_Audio_audio *_object = [[API17_Audio_audio alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Audio_audioEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x586988d8 serializeBlock:^bool (API17_Audio_audioEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Audio_audio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc7ac6496 serializeBlock:^bool (API17_Audio_audio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Located ()

@property (nonatomic, strong) NSArray * results;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Located_contacts_located ()

@end

@implementation API17_contacts_Located

+ (API17_contacts_Located_contacts_located *)contacts_locatedWithResults:(NSArray *)results users:(NSArray *)users
{
    API17_contacts_Located_contacts_located *_object = [[API17_contacts_Located_contacts_located alloc] init];
    _object.results = [API17__Serializer addSerializerToObject:[results copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_Located_contacts_located

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xaad7f4a7 serializeBlock:^bool (API17_contacts_Located_contacts_located *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.results data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputAudio ()

@end

@interface API17_InputAudio_inputAudioEmpty ()

@end

@interface API17_InputAudio_inputAudio ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputAudio

+ (API17_InputAudio_inputAudioEmpty *)inputAudioEmpty
{
    API17_InputAudio_inputAudioEmpty *_object = [[API17_InputAudio_inputAudioEmpty alloc] init];
    return _object;
}

+ (API17_InputAudio_inputAudio *)inputAudioWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputAudio_inputAudio *_object = [[API17_InputAudio_inputAudio alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputAudio_inputAudioEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd95adc84 serializeBlock:^bool (__unused API17_InputAudio_inputAudioEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputAudio_inputAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x77d440ff serializeBlock:^bool (API17_InputAudio_inputAudio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgsAck ()

@property (nonatomic, strong) NSArray * msg_ids;

@end

@interface API17_MsgsAck_msgs_ack ()

@end

@implementation API17_MsgsAck

+ (API17_MsgsAck_msgs_ack *)msgs_ackWithMsg_ids:(NSArray *)msg_ids
{
    API17_MsgsAck_msgs_ack *_object = [[API17_MsgsAck_msgs_ack alloc] init];
    _object.msg_ids = [API17__Serializer addSerializerToObject:[msg_ids copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_MsgsAck_msgs_ack

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x62d6b459 serializeBlock:^bool (API17_MsgsAck_msgs_ack *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Pong ()

@property (nonatomic, strong) NSNumber * msg_id;
@property (nonatomic, strong) NSNumber * ping_id;

@end

@interface API17_Pong_pong ()

@end

@implementation API17_Pong

+ (API17_Pong_pong *)pongWithMsg_id:(NSNumber *)msg_id ping_id:(NSNumber *)ping_id
{
    API17_Pong_pong *_object = [[API17_Pong_pong alloc] init];
    _object.msg_id = [API17__Serializer addSerializerToObject:[msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.ping_id = [API17__Serializer addSerializerToObject:[ping_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_Pong_pong

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x347773c5 serializeBlock:^bool (API17_Pong_pong *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.ping_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ResponseIndirect ()

@end

@interface API17_ResponseIndirect_responseIndirect ()

@end

@implementation API17_ResponseIndirect

+ (API17_ResponseIndirect_responseIndirect *)responseIndirect
{
    API17_ResponseIndirect_responseIndirect *_object = [[API17_ResponseIndirect_responseIndirect alloc] init];
    return _object;
}


@end

@implementation API17_ResponseIndirect_responseIndirect

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2194f56e serializeBlock:^bool (__unused API17_ResponseIndirect_responseIndirect *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgResendReq ()

@property (nonatomic, strong) NSArray * msg_ids;

@end

@interface API17_MsgResendReq_msg_resend_req ()

@end

@implementation API17_MsgResendReq

+ (API17_MsgResendReq_msg_resend_req *)msg_resend_reqWithMsg_ids:(NSArray *)msg_ids
{
    API17_MsgResendReq_msg_resend_req *_object = [[API17_MsgResendReq_msg_resend_req alloc] init];
    _object.msg_ids = [API17__Serializer addSerializerToObject:[msg_ids copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_MsgResendReq_msg_resend_req

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7d861a08 serializeBlock:^bool (API17_MsgResendReq_msg_resend_req *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_StatedMessages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_messages_StatedMessages_messages_statedMessagesLinks ()

@property (nonatomic, strong) NSArray * links;

@end

@interface API17_messages_StatedMessages_messages_statedMessages ()

@end

@implementation API17_messages_StatedMessages

+ (API17_messages_StatedMessages_messages_statedMessagesLinks *)messages_statedMessagesLinksWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users links:(NSArray *)links pts:(NSNumber *)pts seq:(NSNumber *)seq
{
    API17_messages_StatedMessages_messages_statedMessagesLinks *_object = [[API17_messages_StatedMessages_messages_statedMessagesLinks alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.links = [API17__Serializer addSerializerToObject:[links copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_messages_StatedMessages_messages_statedMessages *)messages_statedMessagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users pts:(NSNumber *)pts seq:(NSNumber *)seq
{
    API17_messages_StatedMessages_messages_statedMessages *_object = [[API17_messages_StatedMessages_messages_statedMessages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_messages_StatedMessages_messages_statedMessagesLinks

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3e74f5c6 serializeBlock:^bool (API17_messages_StatedMessages_messages_statedMessagesLinks *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.links data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_StatedMessages_messages_statedMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x969478bb serializeBlock:^bool (API17_messages_StatedMessages_messages_statedMessages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_WallPaper ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * color;

@end

@interface API17_WallPaper_wallPaperSolid ()

@property (nonatomic, strong) NSNumber * bg_color;

@end

@interface API17_WallPaper_wallPaper ()

@property (nonatomic, strong) NSArray * sizes;

@end

@implementation API17_WallPaper

+ (API17_WallPaper_wallPaperSolid *)wallPaperSolidWithPid:(NSNumber *)pid title:(NSString *)title bg_color:(NSNumber *)bg_color color:(NSNumber *)color
{
    API17_WallPaper_wallPaperSolid *_object = [[API17_WallPaper_wallPaperSolid alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.bg_color = [API17__Serializer addSerializerToObject:[bg_color copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.color = [API17__Serializer addSerializerToObject:[color copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_WallPaper_wallPaper *)wallPaperWithPid:(NSNumber *)pid title:(NSString *)title sizes:(NSArray *)sizes color:(NSNumber *)color
{
    API17_WallPaper_wallPaper *_object = [[API17_WallPaper_wallPaper alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.sizes = [API17__Serializer addSerializerToObject:[sizes copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.color = [API17__Serializer addSerializerToObject:[color copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_WallPaper_wallPaperSolid

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x63117f24 serializeBlock:^bool (API17_WallPaper_wallPaperSolid *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bg_color data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.color data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_WallPaper_wallPaper

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xccb03657 serializeBlock:^bool (API17_WallPaper_wallPaper *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.sizes data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.color data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DestroySessionsRes ()

@property (nonatomic, strong) NSArray * destroy_results;

@end

@interface API17_DestroySessionsRes_destroy_sessions_res ()

@end

@implementation API17_DestroySessionsRes

+ (API17_DestroySessionsRes_destroy_sessions_res *)destroy_sessions_resWithDestroy_results:(NSArray *)destroy_results
{
    API17_DestroySessionsRes_destroy_sessions_res *_object = [[API17_DestroySessionsRes_destroy_sessions_res alloc] init];
    _object.destroy_results = [API17__Serializer addSerializerToObject:[destroy_results copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_DestroySessionsRes_destroy_sessions_res

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfb95abcd serializeBlock:^bool (API17_DestroySessionsRes_destroy_sessions_res *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.destroy_results data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_Messages ()

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_messages_Messages_messages_messages ()

@end

@interface API17_messages_Messages_messages_messagesSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_messages_Messages

+ (API17_messages_Messages_messages_messages *)messages_messagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Messages_messages_messages *_object = [[API17_messages_Messages_messages_messages alloc] init];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_messages_Messages_messages_messagesSlice *)messages_messagesSliceWithCount:(NSNumber *)count messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Messages_messages_messagesSlice *_object = [[API17_messages_Messages_messages_messagesSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_Messages_messages_messages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8c718e87 serializeBlock:^bool (API17_messages_Messages_messages_messages *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_Messages_messages_messagesSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb446ae3 serializeBlock:^bool (API17_messages_Messages_messages_messagesSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_geochats_Located ()

@property (nonatomic, strong) NSArray * results;
@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_geochats_Located_geochats_located ()

@end

@implementation API17_geochats_Located

+ (API17_geochats_Located_geochats_located *)geochats_locatedWithResults:(NSArray *)results messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_geochats_Located_geochats_located *_object = [[API17_geochats_Located_geochats_located alloc] init];
    _object.results = [API17__Serializer addSerializerToObject:[results copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_geochats_Located_geochats_located

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x48feb267 serializeBlock:^bool (API17_geochats_Located_geochats_located *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.results data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_auth_SentCode ()

@property (nonatomic, strong) API17_Bool * phone_registered;

@end

@interface API17_auth_SentCode_auth_sentCodePreview ()

@property (nonatomic, strong) NSString * phone_code_hash;
@property (nonatomic, strong) NSString * phone_code_test;

@end

@interface API17_auth_SentCode_auth_sentPassPhrase ()

@end

@interface API17_auth_SentCode_auth_sentCode ()

@property (nonatomic, strong) NSString * phone_code_hash;
@property (nonatomic, strong) NSNumber * send_call_timeout;
@property (nonatomic, strong) API17_Bool * is_password;

@end

@interface API17_auth_SentCode_auth_sentAppCode ()

@property (nonatomic, strong) NSString * phone_code_hash;
@property (nonatomic, strong) NSNumber * send_call_timeout;
@property (nonatomic, strong) API17_Bool * is_password;

@end

@implementation API17_auth_SentCode

+ (API17_auth_SentCode_auth_sentCodePreview *)auth_sentCodePreviewWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash phone_code_test:(NSString *)phone_code_test
{
    API17_auth_SentCode_auth_sentCodePreview *_object = [[API17_auth_SentCode_auth_sentCodePreview alloc] init];
    _object.phone_registered = phone_registered;
    _object.phone_code_hash = [API17__Serializer addSerializerToObject:[phone_code_hash copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.phone_code_test = [API17__Serializer addSerializerToObject:[phone_code_test copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_auth_SentCode_auth_sentPassPhrase *)auth_sentPassPhraseWithPhone_registered:(API17_Bool *)phone_registered
{
    API17_auth_SentCode_auth_sentPassPhrase *_object = [[API17_auth_SentCode_auth_sentPassPhrase alloc] init];
    _object.phone_registered = phone_registered;
    return _object;
}

+ (API17_auth_SentCode_auth_sentCode *)auth_sentCodeWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(NSNumber *)send_call_timeout is_password:(API17_Bool *)is_password
{
    API17_auth_SentCode_auth_sentCode *_object = [[API17_auth_SentCode_auth_sentCode alloc] init];
    _object.phone_registered = phone_registered;
    _object.phone_code_hash = [API17__Serializer addSerializerToObject:[phone_code_hash copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.send_call_timeout = [API17__Serializer addSerializerToObject:[send_call_timeout copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.is_password = is_password;
    return _object;
}

+ (API17_auth_SentCode_auth_sentAppCode *)auth_sentAppCodeWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(NSNumber *)send_call_timeout is_password:(API17_Bool *)is_password
{
    API17_auth_SentCode_auth_sentAppCode *_object = [[API17_auth_SentCode_auth_sentAppCode alloc] init];
    _object.phone_registered = phone_registered;
    _object.phone_code_hash = [API17__Serializer addSerializerToObject:[phone_code_hash copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.send_call_timeout = [API17__Serializer addSerializerToObject:[send_call_timeout copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.is_password = is_password;
    return _object;
}


@end

@implementation API17_auth_SentCode_auth_sentCodePreview

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3cf5727a serializeBlock:^bool (API17_auth_SentCode_auth_sentCodePreview *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_registered data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.phone_code_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.phone_code_test data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_auth_SentCode_auth_sentPassPhrase

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1a1e1fae serializeBlock:^bool (API17_auth_SentCode_auth_sentPassPhrase *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_registered data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_auth_SentCode_auth_sentCode

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xefed51d9 serializeBlock:^bool (API17_auth_SentCode_auth_sentCode *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_registered data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.phone_code_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.send_call_timeout data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.is_password data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_auth_SentCode_auth_sentAppCode

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe325edcf serializeBlock:^bool (API17_auth_SentCode_auth_sentAppCode *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_registered data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.phone_code_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.send_call_timeout data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.is_password data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_phone_DhConfig ()

@property (nonatomic, strong) NSNumber * g;
@property (nonatomic, strong) NSString * p;
@property (nonatomic, strong) NSNumber * ring_timeout;
@property (nonatomic, strong) NSNumber * expires;

@end

@interface API17_phone_DhConfig_phone_dhConfig ()

@end

@implementation API17_phone_DhConfig

+ (API17_phone_DhConfig_phone_dhConfig *)phone_dhConfigWithG:(NSNumber *)g p:(NSString *)p ring_timeout:(NSNumber *)ring_timeout expires:(NSNumber *)expires
{
    API17_phone_DhConfig_phone_dhConfig *_object = [[API17_phone_DhConfig_phone_dhConfig alloc] init];
    _object.g = [API17__Serializer addSerializerToObject:[g copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.p = [API17__Serializer addSerializerToObject:[p copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.ring_timeout = [API17__Serializer addSerializerToObject:[ring_timeout copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.expires = [API17__Serializer addSerializerToObject:[expires copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_phone_DhConfig_phone_dhConfig

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8a5d855e serializeBlock:^bool (API17_phone_DhConfig_phone_dhConfig *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.g data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.p data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.ring_timeout data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.expires data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputChatPhoto ()

@end

@interface API17_InputChatPhoto_inputChatPhotoEmpty ()

@end

@interface API17_InputChatPhoto_inputChatUploadedPhoto ()

@property (nonatomic, strong) API17_InputFile * file;
@property (nonatomic, strong) API17_InputPhotoCrop * crop;

@end

@interface API17_InputChatPhoto_inputChatPhoto ()

@property (nonatomic, strong) API17_InputPhoto * pid;
@property (nonatomic, strong) API17_InputPhotoCrop * crop;

@end

@implementation API17_InputChatPhoto

+ (API17_InputChatPhoto_inputChatPhotoEmpty *)inputChatPhotoEmpty
{
    API17_InputChatPhoto_inputChatPhotoEmpty *_object = [[API17_InputChatPhoto_inputChatPhotoEmpty alloc] init];
    return _object;
}

+ (API17_InputChatPhoto_inputChatUploadedPhoto *)inputChatUploadedPhotoWithFile:(API17_InputFile *)file crop:(API17_InputPhotoCrop *)crop
{
    API17_InputChatPhoto_inputChatUploadedPhoto *_object = [[API17_InputChatPhoto_inputChatUploadedPhoto alloc] init];
    _object.file = file;
    _object.crop = crop;
    return _object;
}

+ (API17_InputChatPhoto_inputChatPhoto *)inputChatPhotoWithPid:(API17_InputPhoto *)pid crop:(API17_InputPhotoCrop *)crop
{
    API17_InputChatPhoto_inputChatPhoto *_object = [[API17_InputChatPhoto_inputChatPhoto alloc] init];
    _object.pid = pid;
    _object.crop = crop;
    return _object;
}


@end

@implementation API17_InputChatPhoto_inputChatPhotoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1ca48f57 serializeBlock:^bool (__unused API17_InputChatPhoto_inputChatPhotoEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputChatPhoto_inputChatUploadedPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x94254732 serializeBlock:^bool (API17_InputChatPhoto_inputChatUploadedPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.file data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.crop data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputChatPhoto_inputChatPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb2e1bf08 serializeBlock:^bool (API17_InputChatPhoto_inputChatPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.crop data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Updates ()

@end

@interface API17_Updates_updatesTooLong ()

@end

@interface API17_Updates_updateShortMessage ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_Updates_updateShortChatMessage ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_Updates_updateShort ()

@property (nonatomic, strong) API17_Update * update;
@property (nonatomic, strong) NSNumber * date;

@end

@interface API17_Updates_updatesCombined ()

@property (nonatomic, strong) NSArray * updates;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq_start;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_Updates_updates ()

@property (nonatomic, strong) NSArray * updates;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq;

@end

@implementation API17_Updates

+ (API17_Updates_updatesTooLong *)updatesTooLong
{
    API17_Updates_updatesTooLong *_object = [[API17_Updates_updatesTooLong alloc] init];
    return _object;
}

+ (API17_Updates_updateShortMessage *)updateShortMessageWithPid:(NSNumber *)pid from_id:(NSNumber *)from_id message:(NSString *)message pts:(NSNumber *)pts date:(NSNumber *)date seq:(NSNumber *)seq
{
    API17_Updates_updateShortMessage *_object = [[API17_Updates_updateShortMessage alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Updates_updateShortChatMessage *)updateShortChatMessageWithPid:(NSNumber *)pid from_id:(NSNumber *)from_id chat_id:(NSNumber *)chat_id message:(NSString *)message pts:(NSNumber *)pts date:(NSNumber *)date seq:(NSNumber *)seq
{
    API17_Updates_updateShortChatMessage *_object = [[API17_Updates_updateShortChatMessage alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Updates_updateShort *)updateShortWithUpdate:(API17_Update *)update date:(NSNumber *)date
{
    API17_Updates_updateShort *_object = [[API17_Updates_updateShort alloc] init];
    _object.update = update;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Updates_updatesCombined *)updatesCombinedWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seq_start:(NSNumber *)seq_start seq:(NSNumber *)seq
{
    API17_Updates_updatesCombined *_object = [[API17_Updates_updatesCombined alloc] init];
    _object.updates = [API17__Serializer addSerializerToObject:[updates copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq_start = [API17__Serializer addSerializerToObject:[seq_start copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Updates_updates *)updatesWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seq:(NSNumber *)seq
{
    API17_Updates_updates *_object = [[API17_Updates_updates alloc] init];
    _object.updates = [API17__Serializer addSerializerToObject:[updates copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Updates_updatesTooLong

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xe317af7e serializeBlock:^bool (__unused API17_Updates_updatesTooLong *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Updates_updateShortMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd3f45784 serializeBlock:^bool (API17_Updates_updateShortMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Updates_updateShortChatMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2b2fbd4e serializeBlock:^bool (API17_Updates_updateShortChatMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Updates_updateShort

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x78d4dec1 serializeBlock:^bool (API17_Updates_updateShort *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.update data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Updates_updatesCombined

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x725b04c3 serializeBlock:^bool (API17_Updates_updatesCombined *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.updates data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq_start data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Updates_updates

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x74ae4240 serializeBlock:^bool (API17_Updates_updates *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.updates data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InitConnection ()

@property (nonatomic, strong) NSNumber * api_id;
@property (nonatomic, strong) NSString * device_model;
@property (nonatomic, strong) NSString * system_version;
@property (nonatomic, strong) NSString * app_version;
@property (nonatomic, strong) NSString * lang_code;
@property (nonatomic, strong) NSObject * query;

@end

@interface API17_InitConnection_pinitConnection ()

@end

@implementation API17_InitConnection

+ (API17_InitConnection_pinitConnection *)pinitConnectionWithApi_id:(NSNumber *)api_id device_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version lang_code:(NSString *)lang_code query:(NSObject *)query
{
    API17_InitConnection_pinitConnection *_object = [[API17_InitConnection_pinitConnection alloc] init];
    _object.api_id = [API17__Serializer addSerializerToObject:[api_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.device_model = [API17__Serializer addSerializerToObject:[device_model copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.system_version = [API17__Serializer addSerializerToObject:[system_version copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.app_version = [API17__Serializer addSerializerToObject:[app_version copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.lang_code = [API17__Serializer addSerializerToObject:[lang_code copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.query = query;
    return _object;
}


@end

@implementation API17_InitConnection_pinitConnection

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x69796de9 serializeBlock:^bool (API17_InitConnection_pinitConnection *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.api_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.device_model data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.system_version data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.app_version data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.lang_code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.query data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;
@property (nonatomic, strong) NSData * random_bytes;

@end

@interface API17_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) API17_DecryptedMessageMedia * media;

@end

@interface API17_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) API17_DecryptedMessageAction * action;

@end

@implementation API17_DecryptedMessage

+ (API17_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(API17_DecryptedMessageMedia *)media
{
    API17_DecryptedMessage_decryptedMessage *_object = [[API17_DecryptedMessage_decryptedMessage alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [API17__Serializer addSerializerToObject:[random_bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (API17_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(API17_DecryptedMessageAction *)action
{
    API17_DecryptedMessage_decryptedMessageService *_object = [[API17_DecryptedMessage_decryptedMessageService alloc] init];
    _object.random_id = [API17__Serializer addSerializerToObject:[random_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.random_bytes = [API17__Serializer addSerializerToObject:[random_bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation API17_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1f814f1f serializeBlock:^bool (API17_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xaa48327d serializeBlock:^bool (API17_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MessageMedia ()

@end

@interface API17_MessageMedia_messageMediaEmpty ()

@end

@interface API17_MessageMedia_messageMediaPhoto ()

@property (nonatomic, strong) API17_Photo * photo;

@end

@interface API17_MessageMedia_messageMediaVideo ()

@property (nonatomic, strong) API17_Video * video;

@end

@interface API17_MessageMedia_messageMediaGeo ()

@property (nonatomic, strong) API17_GeoPoint * geo;

@end

@interface API17_MessageMedia_messageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_MessageMedia_messageMediaUnsupported ()

@property (nonatomic, strong) NSData * bytes;

@end

@interface API17_MessageMedia_messageMediaDocument ()

@property (nonatomic, strong) API17_Document * document;

@end

@interface API17_MessageMedia_messageMediaAudio ()

@property (nonatomic, strong) API17_Audio * audio;

@end

@implementation API17_MessageMedia

+ (API17_MessageMedia_messageMediaEmpty *)messageMediaEmpty
{
    API17_MessageMedia_messageMediaEmpty *_object = [[API17_MessageMedia_messageMediaEmpty alloc] init];
    return _object;
}

+ (API17_MessageMedia_messageMediaPhoto *)messageMediaPhotoWithPhoto:(API17_Photo *)photo
{
    API17_MessageMedia_messageMediaPhoto *_object = [[API17_MessageMedia_messageMediaPhoto alloc] init];
    _object.photo = photo;
    return _object;
}

+ (API17_MessageMedia_messageMediaVideo *)messageMediaVideoWithVideo:(API17_Video *)video
{
    API17_MessageMedia_messageMediaVideo *_object = [[API17_MessageMedia_messageMediaVideo alloc] init];
    _object.video = video;
    return _object;
}

+ (API17_MessageMedia_messageMediaGeo *)messageMediaGeoWithGeo:(API17_GeoPoint *)geo
{
    API17_MessageMedia_messageMediaGeo *_object = [[API17_MessageMedia_messageMediaGeo alloc] init];
    _object.geo = geo;
    return _object;
}

+ (API17_MessageMedia_messageMediaContact *)messageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    API17_MessageMedia_messageMediaContact *_object = [[API17_MessageMedia_messageMediaContact alloc] init];
    _object.phone_number = [API17__Serializer addSerializerToObject:[phone_number copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_MessageMedia_messageMediaUnsupported *)messageMediaUnsupportedWithBytes:(NSData *)bytes
{
    API17_MessageMedia_messageMediaUnsupported *_object = [[API17_MessageMedia_messageMediaUnsupported alloc] init];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_MessageMedia_messageMediaDocument *)messageMediaDocumentWithDocument:(API17_Document *)document
{
    API17_MessageMedia_messageMediaDocument *_object = [[API17_MessageMedia_messageMediaDocument alloc] init];
    _object.document = document;
    return _object;
}

+ (API17_MessageMedia_messageMediaAudio *)messageMediaAudioWithAudio:(API17_Audio *)audio
{
    API17_MessageMedia_messageMediaAudio *_object = [[API17_MessageMedia_messageMediaAudio alloc] init];
    _object.audio = audio;
    return _object;
}


@end

@implementation API17_MessageMedia_messageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3ded6320 serializeBlock:^bool (__unused API17_MessageMedia_messageMediaEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc8c45a2a serializeBlock:^bool (API17_MessageMedia_messageMediaPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa2d24290 serializeBlock:^bool (API17_MessageMedia_messageMediaVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.video data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaGeo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x56e0d474 serializeBlock:^bool (API17_MessageMedia_messageMediaGeo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.geo data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5e7d2f39 serializeBlock:^bool (API17_MessageMedia_messageMediaContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaUnsupported

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x29632a36 serializeBlock:^bool (API17_MessageMedia_messageMediaUnsupported *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2fda2204 serializeBlock:^bool (API17_MessageMedia_messageMediaDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.document data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageMedia_messageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc6b68300 serializeBlock:^bool (API17_MessageMedia_messageMediaAudio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.audio data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Null ()

@end

@interface API17_Null_null ()

@end

@implementation API17_Null

+ (API17_Null_null *)null
{
    API17_Null_null *_object = [[API17_Null_null alloc] init];
    return _object;
}


@end

@implementation API17_Null_null

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x56730bcc serializeBlock:^bool (__unused API17_Null_null *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ChatPhoto ()

@end

@interface API17_ChatPhoto_chatPhotoEmpty ()

@end

@interface API17_ChatPhoto_chatPhoto ()

@property (nonatomic, strong) API17_FileLocation * photo_small;
@property (nonatomic, strong) API17_FileLocation * photo_big;

@end

@implementation API17_ChatPhoto

+ (API17_ChatPhoto_chatPhotoEmpty *)chatPhotoEmpty
{
    API17_ChatPhoto_chatPhotoEmpty *_object = [[API17_ChatPhoto_chatPhotoEmpty alloc] init];
    return _object;
}

+ (API17_ChatPhoto_chatPhoto *)chatPhotoWithPhoto_small:(API17_FileLocation *)photo_small photo_big:(API17_FileLocation *)photo_big
{
    API17_ChatPhoto_chatPhoto *_object = [[API17_ChatPhoto_chatPhoto alloc] init];
    _object.photo_small = photo_small;
    _object.photo_big = photo_big;
    return _object;
}


@end

@implementation API17_ChatPhoto_chatPhotoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x37c1011c serializeBlock:^bool (__unused API17_ChatPhoto_chatPhotoEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_ChatPhoto_chatPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6153276a serializeBlock:^bool (API17_ChatPhoto_chatPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photo_small data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.photo_big data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InvokeAfterMsg ()

@property (nonatomic, strong) NSNumber * msg_id;
@property (nonatomic, strong) NSObject * query;

@end

@interface API17_InvokeAfterMsg_invokeAfterMsg ()

@end

@implementation API17_InvokeAfterMsg

+ (API17_InvokeAfterMsg_invokeAfterMsg *)invokeAfterMsgWithMsg_id:(NSNumber *)msg_id query:(NSObject *)query
{
    API17_InvokeAfterMsg_invokeAfterMsg *_object = [[API17_InvokeAfterMsg_invokeAfterMsg alloc] init];
    _object.msg_id = [API17__Serializer addSerializerToObject:[msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.query = query;
    return _object;
}


@end

@implementation API17_InvokeAfterMsg_invokeAfterMsg

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xcb9f372d serializeBlock:^bool (API17_InvokeAfterMsg_invokeAfterMsg *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.query data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Suggested ()

@property (nonatomic, strong) NSArray * results;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Suggested_contacts_suggested ()

@end

@implementation API17_contacts_Suggested

+ (API17_contacts_Suggested_contacts_suggested *)contacts_suggestedWithResults:(NSArray *)results users:(NSArray *)users
{
    API17_contacts_Suggested_contacts_suggested *_object = [[API17_contacts_Suggested_contacts_suggested alloc] init];
    _object.results = [API17__Serializer addSerializerToObject:[results copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_Suggested_contacts_suggested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5649dcc5 serializeBlock:^bool (API17_contacts_Suggested_contacts_suggested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.results data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_updates_State ()

@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * qts;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * seq;
@property (nonatomic, strong) NSNumber * unread_count;

@end

@interface API17_updates_State_updates_state ()

@end

@implementation API17_updates_State

+ (API17_updates_State_updates_state *)updates_stateWithPts:(NSNumber *)pts qts:(NSNumber *)qts date:(NSNumber *)date seq:(NSNumber *)seq unread_count:(NSNumber *)unread_count
{
    API17_updates_State_updates_state *_object = [[API17_updates_State_updates_state alloc] init];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.qts = [API17__Serializer addSerializerToObject:[qts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.unread_count = [API17__Serializer addSerializerToObject:[unread_count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_updates_State_updates_state

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa56c2a3e serializeBlock:^bool (API17_updates_State_updates_state *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.qts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.unread_count data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_User ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_User_userEmpty ()

@end

@interface API17_User_userSelf ()

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) API17_UserProfilePhoto * photo;
@property (nonatomic, strong) API17_UserStatus * status;
@property (nonatomic, strong) API17_Bool * inactive;

@end

@interface API17_User_userContact ()

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) API17_UserProfilePhoto * photo;
@property (nonatomic, strong) API17_UserStatus * status;

@end

@interface API17_User_userRequest ()

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) API17_UserProfilePhoto * photo;
@property (nonatomic, strong) API17_UserStatus * status;

@end

@interface API17_User_userForeign ()

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) API17_UserProfilePhoto * photo;
@property (nonatomic, strong) API17_UserStatus * status;

@end

@interface API17_User_userDeleted ()

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;

@end

@implementation API17_User

+ (API17_User_userEmpty *)userEmptyWithPid:(NSNumber *)pid
{
    API17_User_userEmpty *_object = [[API17_User_userEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_User_userSelf *)userSelfWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status inactive:(API17_Bool *)inactive
{
    API17_User_userSelf *_object = [[API17_User_userSelf alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.phone = [API17__Serializer addSerializerToObject:[phone copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.photo = photo;
    _object.status = status;
    _object.inactive = inactive;
    return _object;
}

+ (API17_User_userContact *)userContactWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status
{
    API17_User_userContact *_object = [[API17_User_userContact alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.phone = [API17__Serializer addSerializerToObject:[phone copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.photo = photo;
    _object.status = status;
    return _object;
}

+ (API17_User_userRequest *)userRequestWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status
{
    API17_User_userRequest *_object = [[API17_User_userRequest alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.phone = [API17__Serializer addSerializerToObject:[phone copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.photo = photo;
    _object.status = status;
    return _object;
}

+ (API17_User_userForeign *)userForeignWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status
{
    API17_User_userForeign *_object = [[API17_User_userForeign alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.photo = photo;
    _object.status = status;
    return _object;
}

+ (API17_User_userDeleted *)userDeletedWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name
{
    API17_User_userDeleted *_object = [[API17_User_userDeleted alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_User_userEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x200250ba serializeBlock:^bool (API17_User_userEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_User_userSelf

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x720535ec serializeBlock:^bool (API17_User_userSelf *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.phone data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.inactive data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_User_userContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf2fb8319 serializeBlock:^bool (API17_User_userContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.phone data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_User_userRequest

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x22e8ceb0 serializeBlock:^bool (API17_User_userRequest *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.phone data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_User_userForeign

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5214c89d serializeBlock:^bool (API17_User_userForeign *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_User_userDeleted

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb29ad7cc serializeBlock:^bool (API17_User_userDeleted *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Message ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Message_messageEmpty ()

@end

@interface API17_Message_message ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) API17_Peer * to_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) API17_MessageMedia * media;

@end

@interface API17_Message_messageForwarded ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * fwd_from_id;
@property (nonatomic, strong) NSNumber * fwd_date;
@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) API17_Peer * to_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) API17_MessageMedia * media;

@end

@interface API17_Message_messageService ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * from_id;
@property (nonatomic, strong) API17_Peer * to_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) API17_MessageAction * action;

@end

@implementation API17_Message

+ (API17_Message_messageEmpty *)messageEmptyWithPid:(NSNumber *)pid
{
    API17_Message_messageEmpty *_object = [[API17_Message_messageEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Message_message *)messageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media
{
    API17_Message_message *_object = [[API17_Message_message alloc] init];
    _object.flags = [API17__Serializer addSerializerToObject:[flags copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.to_id = to_id;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (API17_Message_messageForwarded *)messageForwardedWithFlags:(NSNumber *)flags pid:(NSNumber *)pid fwd_from_id:(NSNumber *)fwd_from_id fwd_date:(NSNumber *)fwd_date from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media
{
    API17_Message_messageForwarded *_object = [[API17_Message_messageForwarded alloc] init];
    _object.flags = [API17__Serializer addSerializerToObject:[flags copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.fwd_from_id = [API17__Serializer addSerializerToObject:[fwd_from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.fwd_date = [API17__Serializer addSerializerToObject:[fwd_date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.to_id = to_id;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (API17_Message_messageService *)messageServiceWithFlags:(NSNumber *)flags pid:(NSNumber *)pid from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date action:(API17_MessageAction *)action
{
    API17_Message_messageService *_object = [[API17_Message_messageService alloc] init];
    _object.flags = [API17__Serializer addSerializerToObject:[flags copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.from_id = [API17__Serializer addSerializerToObject:[from_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.to_id = to_id;
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation API17_Message_messageEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x83e5de54 serializeBlock:^bool (API17_Message_messageEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Message_message

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x567699b3 serializeBlock:^bool (API17_Message_message *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.to_id data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Message_messageForwarded

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa367e716 serializeBlock:^bool (API17_Message_messageForwarded *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.fwd_from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.fwd_date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.to_id data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Message_messageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1d86f70e serializeBlock:^bool (API17_Message_messageService *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.from_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.to_id data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputFileLocation ()

@end

@interface API17_InputFileLocation_inputFileLocation ()

@property (nonatomic, strong) NSNumber * volume_id;
@property (nonatomic, strong) NSNumber * local_id;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface API17_InputFileLocation_inputVideoFileLocation ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputEncryptedFileLocation ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputAudioFileLocation ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputDocumentFileLocation ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputFileLocation

+ (API17_InputFileLocation_inputFileLocation *)inputFileLocationWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    API17_InputFileLocation_inputFileLocation *_object = [[API17_InputFileLocation_inputFileLocation alloc] init];
    _object.volume_id = [API17__Serializer addSerializerToObject:[volume_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [API17__Serializer addSerializerToObject:[local_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.secret = [API17__Serializer addSerializerToObject:[secret copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputFileLocation_inputVideoFileLocation *)inputVideoFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputFileLocation_inputVideoFileLocation *_object = [[API17_InputFileLocation_inputVideoFileLocation alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputFileLocation_inputEncryptedFileLocation *)inputEncryptedFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputFileLocation_inputEncryptedFileLocation *_object = [[API17_InputFileLocation_inputEncryptedFileLocation alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputFileLocation_inputAudioFileLocation *)inputAudioFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputFileLocation_inputAudioFileLocation *_object = [[API17_InputFileLocation_inputAudioFileLocation alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_InputFileLocation_inputDocumentFileLocation *)inputDocumentFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputFileLocation_inputDocumentFileLocation *_object = [[API17_InputFileLocation_inputDocumentFileLocation alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputFileLocation_inputFileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x14637196 serializeBlock:^bool (API17_InputFileLocation_inputFileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputFileLocation_inputVideoFileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3d0364ec serializeBlock:^bool (API17_InputFileLocation_inputVideoFileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputFileLocation_inputEncryptedFileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xf5235d55 serializeBlock:^bool (API17_InputFileLocation_inputEncryptedFileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputFileLocation_inputAudioFileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x74dc404d serializeBlock:^bool (API17_InputFileLocation_inputAudioFileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputFileLocation_inputDocumentFileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4e45abe9 serializeBlock:^bool (API17_InputFileLocation_inputDocumentFileLocation *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_GeoPoint ()

@end

@interface API17_GeoPoint_geoPointEmpty ()

@end

@interface API17_GeoPoint_geoPoint ()

@property (nonatomic, strong) NSNumber * plong;
@property (nonatomic, strong) NSNumber * lat;

@end

@interface API17_GeoPoint_geoPlace ()

@property (nonatomic, strong) NSNumber * plong;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) API17_GeoPlaceName * name;

@end

@implementation API17_GeoPoint

+ (API17_GeoPoint_geoPointEmpty *)geoPointEmpty
{
    API17_GeoPoint_geoPointEmpty *_object = [[API17_GeoPoint_geoPointEmpty alloc] init];
    return _object;
}

+ (API17_GeoPoint_geoPoint *)geoPointWithPlong:(NSNumber *)plong lat:(NSNumber *)lat
{
    API17_GeoPoint_geoPoint *_object = [[API17_GeoPoint_geoPoint alloc] init];
    _object.plong = [API17__Serializer addSerializerToObject:[plong copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.lat = [API17__Serializer addSerializerToObject:[lat copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (API17_GeoPoint_geoPlace *)geoPlaceWithPlong:(NSNumber *)plong lat:(NSNumber *)lat name:(API17_GeoPlaceName *)name
{
    API17_GeoPoint_geoPlace *_object = [[API17_GeoPoint_geoPlace alloc] init];
    _object.plong = [API17__Serializer addSerializerToObject:[plong copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.lat = [API17__Serializer addSerializerToObject:[lat copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.name = name;
    return _object;
}


@end

@implementation API17_GeoPoint_geoPointEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1117dd5f serializeBlock:^bool (__unused API17_GeoPoint_geoPointEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_GeoPoint_geoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2049d70c serializeBlock:^bool (API17_GeoPoint_geoPoint *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_GeoPoint_geoPlace

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6e9e21ca serializeBlock:^bool (API17_GeoPoint_geoPlace *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.name data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPhoneCall ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@interface API17_InputPhoneCall_inputPhoneCall ()

@end

@implementation API17_InputPhoneCall

+ (API17_InputPhoneCall_inputPhoneCall *)inputPhoneCallWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputPhoneCall_inputPhoneCall *_object = [[API17_InputPhoneCall_inputPhoneCall alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputPhoneCall_inputPhoneCall

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1e36fded serializeBlock:^bool (API17_InputPhoneCall_inputPhoneCall *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ChatParticipants ()

@property (nonatomic, strong) NSNumber * chat_id;

@end

@interface API17_ChatParticipants_chatParticipantsForbidden ()

@end

@interface API17_ChatParticipants_chatParticipants ()

@property (nonatomic, strong) NSNumber * admin_id;
@property (nonatomic, strong) NSArray * participants;
@property (nonatomic, strong) NSNumber * version;

@end

@implementation API17_ChatParticipants

+ (API17_ChatParticipants_chatParticipantsForbidden *)chatParticipantsForbiddenWithChat_id:(NSNumber *)chat_id
{
    API17_ChatParticipants_chatParticipantsForbidden *_object = [[API17_ChatParticipants_chatParticipantsForbidden alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_ChatParticipants_chatParticipants *)chatParticipantsWithChat_id:(NSNumber *)chat_id admin_id:(NSNumber *)admin_id participants:(NSArray *)participants version:(NSNumber *)version
{
    API17_ChatParticipants_chatParticipants *_object = [[API17_ChatParticipants_chatParticipants alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.admin_id = [API17__Serializer addSerializerToObject:[admin_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.participants = [API17__Serializer addSerializerToObject:[participants copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ChatParticipants_chatParticipantsForbidden

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfd2bb8a serializeBlock:^bool (API17_ChatParticipants_chatParticipantsForbidden *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_ChatParticipants_chatParticipants

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7841b415 serializeBlock:^bool (API17_ChatParticipants_chatParticipants *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.admin_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.participants data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_RpcError ()

@property (nonatomic, strong) NSNumber * error_code;
@property (nonatomic, strong) NSString * error_message;

@end

@interface API17_RpcError_rpc_error ()

@end

@interface API17_RpcError_rpc_req_error ()

@property (nonatomic, strong) NSNumber * query_id;

@end

@implementation API17_RpcError

+ (API17_RpcError_rpc_error *)rpc_errorWithError_code:(NSNumber *)error_code error_message:(NSString *)error_message
{
    API17_RpcError_rpc_error *_object = [[API17_RpcError_rpc_error alloc] init];
    _object.error_code = [API17__Serializer addSerializerToObject:[error_code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.error_message = [API17__Serializer addSerializerToObject:[error_message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_RpcError_rpc_req_error *)rpc_req_errorWithQuery_id:(NSNumber *)query_id error_code:(NSNumber *)error_code error_message:(NSString *)error_message
{
    API17_RpcError_rpc_req_error *_object = [[API17_RpcError_rpc_req_error alloc] init];
    _object.query_id = [API17__Serializer addSerializerToObject:[query_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.error_code = [API17__Serializer addSerializerToObject:[error_code copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.error_message = [API17__Serializer addSerializerToObject:[error_message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_RpcError_rpc_error

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x2144ca19 serializeBlock:^bool (API17_RpcError_rpc_error *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.error_code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.error_message data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_RpcError_rpc_req_error

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7ae432f5 serializeBlock:^bool (API17_RpcError_rpc_req_error *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.query_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.error_code data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.error_message data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_NearestDc ()

@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSNumber * this_dc;
@property (nonatomic, strong) NSNumber * nearest_dc;

@end

@interface API17_NearestDc_nearestDc ()

@end

@implementation API17_NearestDc

+ (API17_NearestDc_nearestDc *)nearestDcWithCountry:(NSString *)country this_dc:(NSNumber *)this_dc nearest_dc:(NSNumber *)nearest_dc
{
    API17_NearestDc_nearestDc *_object = [[API17_NearestDc_nearestDc alloc] init];
    _object.country = [API17__Serializer addSerializerToObject:[country copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.this_dc = [API17__Serializer addSerializerToObject:[this_dc copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.nearest_dc = [API17__Serializer addSerializerToObject:[nearest_dc copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_NearestDc_nearestDc

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8e1a1775 serializeBlock:^bool (API17_NearestDc_nearestDc *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.country data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.this_dc data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.nearest_dc data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Set_client_DH_params_answer ()

@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_ok ()

@property (nonatomic, strong) NSData * pnew_nonce_hash1;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_retry ()

@property (nonatomic, strong) NSData * pnew_nonce_hash2;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_fail ()

@property (nonatomic, strong) NSData * pnew_nonce_hash3;

@end

@implementation API17_Set_client_DH_params_answer

+ (API17_Set_client_DH_params_answer_dh_gen_ok *)dh_gen_okWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash1:(NSData *)pnew_nonce_hash1
{
    API17_Set_client_DH_params_answer_dh_gen_ok *_object = [[API17_Set_client_DH_params_answer_dh_gen_ok alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pnew_nonce_hash1 = [API17__Serializer addSerializerToObject:[pnew_nonce_hash1 copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    return _object;
}

+ (API17_Set_client_DH_params_answer_dh_gen_retry *)dh_gen_retryWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash2:(NSData *)pnew_nonce_hash2
{
    API17_Set_client_DH_params_answer_dh_gen_retry *_object = [[API17_Set_client_DH_params_answer_dh_gen_retry alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pnew_nonce_hash2 = [API17__Serializer addSerializerToObject:[pnew_nonce_hash2 copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    return _object;
}

+ (API17_Set_client_DH_params_answer_dh_gen_fail *)dh_gen_failWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash3:(NSData *)pnew_nonce_hash3
{
    API17_Set_client_DH_params_answer_dh_gen_fail *_object = [[API17_Set_client_DH_params_answer_dh_gen_fail alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.pnew_nonce_hash3 = [API17__Serializer addSerializerToObject:[pnew_nonce_hash3 copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    return _object;
}


@end

@implementation API17_Set_client_DH_params_answer_dh_gen_ok

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3bcbf734 serializeBlock:^bool (API17_Set_client_DH_params_answer_dh_gen_ok *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_nonce_hash1 data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Set_client_DH_params_answer_dh_gen_retry

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x46dc1fb9 serializeBlock:^bool (API17_Set_client_DH_params_answer_dh_gen_retry *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_nonce_hash2 data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Set_client_DH_params_answer_dh_gen_fail

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa69dae02 serializeBlock:^bool (API17_Set_client_DH_params_answer_dh_gen_fail *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pnew_nonce_hash3 data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_photos_Photos ()

@property (nonatomic, strong) NSArray * photos;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_photos_Photos_photos_photos ()

@end

@interface API17_photos_Photos_photos_photosSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_photos_Photos

+ (API17_photos_Photos_photos_photos *)photos_photosWithPhotos:(NSArray *)photos users:(NSArray *)users
{
    API17_photos_Photos_photos_photos *_object = [[API17_photos_Photos_photos_photos alloc] init];
    _object.photos = [API17__Serializer addSerializerToObject:[photos copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_photos_Photos_photos_photosSlice *)photos_photosSliceWithCount:(NSNumber *)count photos:(NSArray *)photos users:(NSArray *)users
{
    API17_photos_Photos_photos_photosSlice *_object = [[API17_photos_Photos_photos_photosSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.photos = [API17__Serializer addSerializerToObject:[photos copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_photos_Photos_photos_photos

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x8dca6aa5 serializeBlock:^bool (API17_photos_Photos_photos_photos *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photos data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_photos_Photos_photos_photosSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x15051f54 serializeBlock:^bool (API17_photos_Photos_photos_photosSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.photos data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_ImportedContacts ()

@property (nonatomic, strong) NSArray * imported;
@property (nonatomic, strong) NSArray * retry_contacts;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_ImportedContacts_contacts_importedContacts ()

@end

@implementation API17_contacts_ImportedContacts

+ (API17_contacts_ImportedContacts_contacts_importedContacts *)contacts_importedContactsWithImported:(NSArray *)imported retry_contacts:(NSArray *)retry_contacts users:(NSArray *)users
{
    API17_contacts_ImportedContacts_contacts_importedContacts *_object = [[API17_contacts_ImportedContacts_contacts_importedContacts alloc] init];
    _object.imported = [API17__Serializer addSerializerToObject:[imported copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.retry_contacts = [API17__Serializer addSerializerToObject:[retry_contacts copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_ImportedContacts_contacts_importedContacts

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xad524315 serializeBlock:^bool (API17_contacts_ImportedContacts_contacts_importedContacts *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.imported data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.retry_contacts data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MsgDetailedInfo ()

@property (nonatomic, strong) NSNumber * answer_msg_id;
@property (nonatomic, strong) NSNumber * bytes;
@property (nonatomic, strong) NSNumber * status;

@end

@interface API17_MsgDetailedInfo_msg_detailed_info ()

@property (nonatomic, strong) NSNumber * msg_id;

@end

@interface API17_MsgDetailedInfo_msg_new_detailed_info ()

@end

@implementation API17_MsgDetailedInfo

+ (API17_MsgDetailedInfo_msg_detailed_info *)msg_detailed_infoWithMsg_id:(NSNumber *)msg_id answer_msg_id:(NSNumber *)answer_msg_id bytes:(NSNumber *)bytes status:(NSNumber *)status
{
    API17_MsgDetailedInfo_msg_detailed_info *_object = [[API17_MsgDetailedInfo_msg_detailed_info alloc] init];
    _object.msg_id = [API17__Serializer addSerializerToObject:[msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.answer_msg_id = [API17__Serializer addSerializerToObject:[answer_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.status = [API17__Serializer addSerializerToObject:[status copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_MsgDetailedInfo_msg_new_detailed_info *)msg_new_detailed_infoWithAnswer_msg_id:(NSNumber *)answer_msg_id bytes:(NSNumber *)bytes status:(NSNumber *)status
{
    API17_MsgDetailedInfo_msg_new_detailed_info *_object = [[API17_MsgDetailedInfo_msg_new_detailed_info alloc] init];
    _object.answer_msg_id = [API17__Serializer addSerializerToObject:[answer_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.status = [API17__Serializer addSerializerToObject:[status copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_MsgDetailedInfo_msg_detailed_info

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x276d3ec6 serializeBlock:^bool (API17_MsgDetailedInfo_msg_detailed_info *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.answer_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MsgDetailedInfo_msg_new_detailed_info

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x809db6df serializeBlock:^bool (API17_MsgDetailedInfo_msg_new_detailed_info *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.answer_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.status data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Bool ()

@end

@interface API17_Bool_boolFalse ()

@end

@interface API17_Bool_boolTrue ()

@end

@implementation API17_Bool

+ (API17_Bool_boolFalse *)boolFalse
{
    API17_Bool_boolFalse *_object = [[API17_Bool_boolFalse alloc] init];
    return _object;
}

+ (API17_Bool_boolTrue *)boolTrue
{
    API17_Bool_boolTrue *_object = [[API17_Bool_boolTrue alloc] init];
    return _object;
}


@end

@implementation API17_Bool_boolFalse

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xbc799737 serializeBlock:^bool (__unused API17_Bool_boolFalse *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Bool_boolTrue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x997275b5 serializeBlock:^bool (__unused API17_Bool_boolTrue *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_help_Support ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) API17_User * user;

@end

@interface API17_help_Support_help_support ()

@end

@implementation API17_help_Support

+ (API17_help_Support_help_support *)help_supportWithPhone_number:(NSString *)phone_number user:(API17_User *)user
{
    API17_help_Support_help_support *_object = [[API17_help_Support_help_support alloc] init];
    _object.phone_number = [API17__Serializer addSerializerToObject:[phone_number copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.user = user;
    return _object;
}


@end

@implementation API17_help_Support_help_support

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x17c6b5f6 serializeBlock:^bool (API17_help_Support_help_support *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ChatLocated ()

@property (nonatomic, strong) NSNumber * chat_id;
@property (nonatomic, strong) NSNumber * distance;

@end

@interface API17_ChatLocated_chatLocated ()

@end

@implementation API17_ChatLocated

+ (API17_ChatLocated_chatLocated *)chatLocatedWithChat_id:(NSNumber *)chat_id distance:(NSNumber *)distance
{
    API17_ChatLocated_chatLocated *_object = [[API17_ChatLocated_chatLocated alloc] init];
    _object.chat_id = [API17__Serializer addSerializerToObject:[chat_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.distance = [API17__Serializer addSerializerToObject:[distance copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ChatLocated_chatLocated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3631cf4c serializeBlock:^bool (API17_ChatLocated_chatLocated *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.chat_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.distance data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MessagesFilter ()

@end

@interface API17_MessagesFilter_inputMessagesFilterEmpty ()

@end

@interface API17_MessagesFilter_inputMessagesFilterPhotos ()

@end

@interface API17_MessagesFilter_inputMessagesFilterVideo ()

@end

@interface API17_MessagesFilter_inputMessagesFilterPhotoVideo ()

@end

@implementation API17_MessagesFilter

+ (API17_MessagesFilter_inputMessagesFilterEmpty *)inputMessagesFilterEmpty
{
    API17_MessagesFilter_inputMessagesFilterEmpty *_object = [[API17_MessagesFilter_inputMessagesFilterEmpty alloc] init];
    return _object;
}

+ (API17_MessagesFilter_inputMessagesFilterPhotos *)inputMessagesFilterPhotos
{
    API17_MessagesFilter_inputMessagesFilterPhotos *_object = [[API17_MessagesFilter_inputMessagesFilterPhotos alloc] init];
    return _object;
}

+ (API17_MessagesFilter_inputMessagesFilterVideo *)inputMessagesFilterVideo
{
    API17_MessagesFilter_inputMessagesFilterVideo *_object = [[API17_MessagesFilter_inputMessagesFilterVideo alloc] init];
    return _object;
}

+ (API17_MessagesFilter_inputMessagesFilterPhotoVideo *)inputMessagesFilterPhotoVideo
{
    API17_MessagesFilter_inputMessagesFilterPhotoVideo *_object = [[API17_MessagesFilter_inputMessagesFilterPhotoVideo alloc] init];
    return _object;
}


@end

@implementation API17_MessagesFilter_inputMessagesFilterEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x57e2f66c serializeBlock:^bool (__unused API17_MessagesFilter_inputMessagesFilterEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessagesFilter_inputMessagesFilterPhotos

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9609a51c serializeBlock:^bool (__unused API17_MessagesFilter_inputMessagesFilterPhotos *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessagesFilter_inputMessagesFilterVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9fc00e65 serializeBlock:^bool (__unused API17_MessagesFilter_inputMessagesFilterVideo *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessagesFilter_inputMessagesFilterPhotoVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x56e9f0e4 serializeBlock:^bool (__unused API17_MessagesFilter_inputMessagesFilterPhotoVideo *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_Dialogs ()

@property (nonatomic, strong) NSArray * dialogs;
@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_messages_Dialogs_messages_dialogs ()

@end

@interface API17_messages_Dialogs_messages_dialogsSlice ()

@property (nonatomic, strong) NSNumber * count;

@end

@implementation API17_messages_Dialogs

+ (API17_messages_Dialogs_messages_dialogs *)messages_dialogsWithDialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Dialogs_messages_dialogs *_object = [[API17_messages_Dialogs_messages_dialogs alloc] init];
    _object.dialogs = [API17__Serializer addSerializerToObject:[dialogs copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_messages_Dialogs_messages_dialogsSlice *)messages_dialogsSliceWithCount:(NSNumber *)count dialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Dialogs_messages_dialogsSlice *_object = [[API17_messages_Dialogs_messages_dialogsSlice alloc] init];
    _object.count = [API17__Serializer addSerializerToObject:[count copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.dialogs = [API17__Serializer addSerializerToObject:[dialogs copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.messages = [API17__Serializer addSerializerToObject:[messages copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_Dialogs_messages_dialogs

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x15ba6c40 serializeBlock:^bool (API17_messages_Dialogs_messages_dialogs *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.dialogs data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_Dialogs_messages_dialogsSlice

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x71e094f3 serializeBlock:^bool (API17_messages_Dialogs_messages_dialogsSlice *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.count data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.dialogs data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.messages data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_help_InviteText ()

@property (nonatomic, strong) NSString * message;

@end

@interface API17_help_InviteText_help_inviteText ()

@end

@implementation API17_help_InviteText

+ (API17_help_InviteText_help_inviteText *)help_inviteTextWithMessage:(NSString *)message
{
    API17_help_InviteText_help_inviteText *_object = [[API17_help_InviteText_help_inviteText alloc] init];
    _object.message = [API17__Serializer addSerializerToObject:[message copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_help_InviteText_help_inviteText

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x18cb9f78 serializeBlock:^bool (API17_help_InviteText_help_inviteText *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ContactSuggested ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * mutual_contacts;

@end

@interface API17_ContactSuggested_contactSuggested ()

@end

@implementation API17_ContactSuggested

+ (API17_ContactSuggested_contactSuggested *)contactSuggestedWithUser_id:(NSNumber *)user_id mutual_contacts:(NSNumber *)mutual_contacts
{
    API17_ContactSuggested_contactSuggested *_object = [[API17_ContactSuggested_contactSuggested alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mutual_contacts = [API17__Serializer addSerializerToObject:[mutual_contacts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_ContactSuggested_contactSuggested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3de191a1 serializeBlock:^bool (API17_ContactSuggested_contactSuggested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mutual_contacts data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPeerNotifySettings ()

@property (nonatomic, strong) NSNumber * mute_until;
@property (nonatomic, strong) NSString * sound;
@property (nonatomic, strong) API17_Bool * show_previews;
@property (nonatomic, strong) API17_InputPeerNotifyEvents * events;

@end

@interface API17_InputPeerNotifySettings_inputPeerNotifySettings ()

@end

@implementation API17_InputPeerNotifySettings

+ (API17_InputPeerNotifySettings_inputPeerNotifySettings *)inputPeerNotifySettingsWithMute_until:(NSNumber *)mute_until sound:(NSString *)sound show_previews:(API17_Bool *)show_previews events:(API17_InputPeerNotifyEvents *)events
{
    API17_InputPeerNotifySettings_inputPeerNotifySettings *_object = [[API17_InputPeerNotifySettings_inputPeerNotifySettings alloc] init];
    _object.mute_until = [API17__Serializer addSerializerToObject:[mute_until copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.sound = [API17__Serializer addSerializerToObject:[sound copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.show_previews = show_previews;
    _object.events = events;
    return _object;
}


@end

@implementation API17_InputPeerNotifySettings_inputPeerNotifySettings

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3cf4b1be serializeBlock:^bool (API17_InputPeerNotifySettings_inputPeerNotifySettings *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.mute_until data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.sound data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.show_previews data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.events data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DcNetworkStats ()

@property (nonatomic, strong) NSNumber * dc_id;
@property (nonatomic, strong) NSString * ip_address;
@property (nonatomic, strong) NSArray * pings;

@end

@interface API17_DcNetworkStats_dcPingStats ()

@end

@implementation API17_DcNetworkStats

+ (API17_DcNetworkStats_dcPingStats *)dcPingStatsWithDc_id:(NSNumber *)dc_id ip_address:(NSString *)ip_address pings:(NSArray *)pings
{
    API17_DcNetworkStats_dcPingStats *_object = [[API17_DcNetworkStats_dcPingStats alloc] init];
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.ip_address = [API17__Serializer addSerializerToObject:[ip_address copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.pings = [API17__Serializer addSerializerToObject:[pings copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_DcNetworkStats_dcPingStats

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3203df8c serializeBlock:^bool (API17_DcNetworkStats_dcPingStats *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.ip_address data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.pings data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_HttpWait ()

@property (nonatomic, strong) NSNumber * max_delay;
@property (nonatomic, strong) NSNumber * wait_after;
@property (nonatomic, strong) NSNumber * max_wait;

@end

@interface API17_HttpWait_http_wait ()

@end

@implementation API17_HttpWait

+ (API17_HttpWait_http_wait *)http_waitWithMax_delay:(NSNumber *)max_delay wait_after:(NSNumber *)wait_after max_wait:(NSNumber *)max_wait
{
    API17_HttpWait_http_wait *_object = [[API17_HttpWait_http_wait alloc] init];
    _object.max_delay = [API17__Serializer addSerializerToObject:[max_delay copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.wait_after = [API17__Serializer addSerializerToObject:[wait_after copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.max_wait = [API17__Serializer addSerializerToObject:[max_wait copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_HttpWait_http_wait

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9299359f serializeBlock:^bool (API17_HttpWait_http_wait *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.max_delay data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.wait_after data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.max_wait data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_PhoneConnection ()

@end

@interface API17_PhoneConnection_phoneConnectionNotReady ()

@end

@interface API17_PhoneConnection_phoneConnection ()

@property (nonatomic, strong) NSString * server;
@property (nonatomic, strong) NSNumber * port;
@property (nonatomic, strong) NSNumber * stream_id;

@end

@implementation API17_PhoneConnection

+ (API17_PhoneConnection_phoneConnectionNotReady *)phoneConnectionNotReady
{
    API17_PhoneConnection_phoneConnectionNotReady *_object = [[API17_PhoneConnection_phoneConnectionNotReady alloc] init];
    return _object;
}

+ (API17_PhoneConnection_phoneConnection *)phoneConnectionWithServer:(NSString *)server port:(NSNumber *)port stream_id:(NSNumber *)stream_id
{
    API17_PhoneConnection_phoneConnection *_object = [[API17_PhoneConnection_phoneConnection alloc] init];
    _object.server = [API17__Serializer addSerializerToObject:[server copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.port = [API17__Serializer addSerializerToObject:[port copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.stream_id = [API17__Serializer addSerializerToObject:[stream_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_PhoneConnection_phoneConnectionNotReady

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x26bc3c3 serializeBlock:^bool (__unused API17_PhoneConnection_phoneConnectionNotReady *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PhoneConnection_phoneConnection

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3a84026a serializeBlock:^bool (API17_PhoneConnection_phoneConnection *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.server data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.port data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.stream_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_StatedMessage ()

@property (nonatomic, strong) API17_Message * message;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSNumber * pts;
@property (nonatomic, strong) NSNumber * seq;

@end

@interface API17_messages_StatedMessage_messages_statedMessageLink ()

@property (nonatomic, strong) NSArray * links;

@end

@interface API17_messages_StatedMessage_messages_statedMessage ()

@end

@implementation API17_messages_StatedMessage

+ (API17_messages_StatedMessage_messages_statedMessageLink *)messages_statedMessageLinkWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users links:(NSArray *)links pts:(NSNumber *)pts seq:(NSNumber *)seq
{
    API17_messages_StatedMessage_messages_statedMessageLink *_object = [[API17_messages_StatedMessage_messages_statedMessageLink alloc] init];
    _object.message = message;
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.links = [API17__Serializer addSerializerToObject:[links copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_messages_StatedMessage_messages_statedMessage *)messages_statedMessageWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users pts:(NSNumber *)pts seq:(NSNumber *)seq
{
    API17_messages_StatedMessage_messages_statedMessage *_object = [[API17_messages_StatedMessage_messages_statedMessage alloc] init];
    _object.message = message;
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.pts = [API17__Serializer addSerializerToObject:[pts copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.seq = [API17__Serializer addSerializerToObject:[seq copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_messages_StatedMessage_messages_statedMessageLink

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa9af2881 serializeBlock:^bool (API17_messages_StatedMessage_messages_statedMessageLink *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.links data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_StatedMessage_messages_statedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd07ae726 serializeBlock:^bool (API17_messages_StatedMessage_messages_statedMessage *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.pts data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Scheme ()

@end

@interface API17_Scheme_scheme ()

@property (nonatomic, strong) NSString * scheme_raw;
@property (nonatomic, strong) NSArray * types;
@property (nonatomic, strong) NSArray * methods;
@property (nonatomic, strong) NSNumber * version;

@end

@interface API17_Scheme_schemeNotModified ()

@end

@implementation API17_Scheme

+ (API17_Scheme_scheme *)schemeWithScheme_raw:(NSString *)scheme_raw types:(NSArray *)types methods:(NSArray *)methods version:(NSNumber *)version
{
    API17_Scheme_scheme *_object = [[API17_Scheme_scheme alloc] init];
    _object.scheme_raw = [API17__Serializer addSerializerToObject:[scheme_raw copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.types = [API17__Serializer addSerializerToObject:[types copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.methods = [API17__Serializer addSerializerToObject:[methods copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.version = [API17__Serializer addSerializerToObject:[version copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_Scheme_schemeNotModified *)schemeNotModified
{
    API17_Scheme_schemeNotModified *_object = [[API17_Scheme_schemeNotModified alloc] init];
    return _object;
}


@end

@implementation API17_Scheme_scheme

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4e6ef65e serializeBlock:^bool (API17_Scheme_scheme *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.scheme_raw data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.types data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.methods data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.version data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Scheme_schemeNotModified

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x263c9c58 serializeBlock:^bool (__unused API17_Scheme_schemeNotModified *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_RpcDropAnswer ()

@end

@interface API17_RpcDropAnswer_rpc_answer_unknown ()

@end

@interface API17_RpcDropAnswer_rpc_answer_dropped_running ()

@end

@interface API17_RpcDropAnswer_rpc_answer_dropped ()

@property (nonatomic, strong) NSNumber * msg_id;
@property (nonatomic, strong) NSNumber * seq_no;
@property (nonatomic, strong) NSNumber * bytes;

@end

@implementation API17_RpcDropAnswer

+ (API17_RpcDropAnswer_rpc_answer_unknown *)rpc_answer_unknown
{
    API17_RpcDropAnswer_rpc_answer_unknown *_object = [[API17_RpcDropAnswer_rpc_answer_unknown alloc] init];
    return _object;
}

+ (API17_RpcDropAnswer_rpc_answer_dropped_running *)rpc_answer_dropped_running
{
    API17_RpcDropAnswer_rpc_answer_dropped_running *_object = [[API17_RpcDropAnswer_rpc_answer_dropped_running alloc] init];
    return _object;
}

+ (API17_RpcDropAnswer_rpc_answer_dropped *)rpc_answer_droppedWithMsg_id:(NSNumber *)msg_id seq_no:(NSNumber *)seq_no bytes:(NSNumber *)bytes
{
    API17_RpcDropAnswer_rpc_answer_dropped *_object = [[API17_RpcDropAnswer_rpc_answer_dropped alloc] init];
    _object.msg_id = [API17__Serializer addSerializerToObject:[msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.seq_no = [API17__Serializer addSerializerToObject:[seq_no copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_RpcDropAnswer_rpc_answer_unknown

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5e2ad36e serializeBlock:^bool (__unused API17_RpcDropAnswer_rpc_answer_unknown *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_RpcDropAnswer_rpc_answer_dropped_running

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xcd78e586 serializeBlock:^bool (__unused API17_RpcDropAnswer_rpc_answer_dropped_running *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_RpcDropAnswer_rpc_answer_dropped

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa43ad8b7 serializeBlock:^bool (API17_RpcDropAnswer_rpc_answer_dropped *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.seq_no data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_messages_Message ()

@end

@interface API17_messages_Message_messages_messageEmpty ()

@end

@interface API17_messages_Message_messages_message ()

@property (nonatomic, strong) API17_Message * message;
@property (nonatomic, strong) NSArray * chats;
@property (nonatomic, strong) NSArray * users;

@end

@implementation API17_messages_Message

+ (API17_messages_Message_messages_messageEmpty *)messages_messageEmpty
{
    API17_messages_Message_messages_messageEmpty *_object = [[API17_messages_Message_messages_messageEmpty alloc] init];
    return _object;
}

+ (API17_messages_Message_messages_message *)messages_messageWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users
{
    API17_messages_Message_messages_message *_object = [[API17_messages_Message_messages_message alloc] init];
    _object.message = message;
    _object.chats = [API17__Serializer addSerializerToObject:[chats copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_messages_Message_messages_messageEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3f4e0648 serializeBlock:^bool (__unused API17_messages_Message_messages_messageEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_messages_Message_messages_message

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xff90c417 serializeBlock:^bool (API17_messages_Message_messages_message *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.chats data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_MessageAction ()

@end

@interface API17_MessageAction_messageActionGeoChatCreate ()

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * address;

@end

@interface API17_MessageAction_messageActionGeoChatCheckin ()

@end

@interface API17_MessageAction_messageActionEmpty ()

@end

@interface API17_MessageAction_messageActionChatCreate ()

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_MessageAction_messageActionChatEditTitle ()

@property (nonatomic, strong) NSString * title;

@end

@interface API17_MessageAction_messageActionChatEditPhoto ()

@property (nonatomic, strong) API17_Photo * photo;

@end

@interface API17_MessageAction_messageActionChatDeletePhoto ()

@end

@interface API17_MessageAction_messageActionChatAddUser ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_MessageAction_messageActionChatDeleteUser ()

@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_MessageAction_messageActionSentRequest ()

@property (nonatomic, strong) API17_Bool * has_phone;

@end

@interface API17_MessageAction_messageActionAcceptRequest ()

@end

@implementation API17_MessageAction

+ (API17_MessageAction_messageActionGeoChatCreate *)messageActionGeoChatCreateWithTitle:(NSString *)title address:(NSString *)address
{
    API17_MessageAction_messageActionGeoChatCreate *_object = [[API17_MessageAction_messageActionGeoChatCreate alloc] init];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.address = [API17__Serializer addSerializerToObject:[address copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_MessageAction_messageActionGeoChatCheckin *)messageActionGeoChatCheckin
{
    API17_MessageAction_messageActionGeoChatCheckin *_object = [[API17_MessageAction_messageActionGeoChatCheckin alloc] init];
    return _object;
}

+ (API17_MessageAction_messageActionEmpty *)messageActionEmpty
{
    API17_MessageAction_messageActionEmpty *_object = [[API17_MessageAction_messageActionEmpty alloc] init];
    return _object;
}

+ (API17_MessageAction_messageActionChatCreate *)messageActionChatCreateWithTitle:(NSString *)title users:(NSArray *)users
{
    API17_MessageAction_messageActionChatCreate *_object = [[API17_MessageAction_messageActionChatCreate alloc] init];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]];
    return _object;
}

+ (API17_MessageAction_messageActionChatEditTitle *)messageActionChatEditTitleWithTitle:(NSString *)title
{
    API17_MessageAction_messageActionChatEditTitle *_object = [[API17_MessageAction_messageActionChatEditTitle alloc] init];
    _object.title = [API17__Serializer addSerializerToObject:[title copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (API17_MessageAction_messageActionChatEditPhoto *)messageActionChatEditPhotoWithPhoto:(API17_Photo *)photo
{
    API17_MessageAction_messageActionChatEditPhoto *_object = [[API17_MessageAction_messageActionChatEditPhoto alloc] init];
    _object.photo = photo;
    return _object;
}

+ (API17_MessageAction_messageActionChatDeletePhoto *)messageActionChatDeletePhoto
{
    API17_MessageAction_messageActionChatDeletePhoto *_object = [[API17_MessageAction_messageActionChatDeletePhoto alloc] init];
    return _object;
}

+ (API17_MessageAction_messageActionChatAddUser *)messageActionChatAddUserWithUser_id:(NSNumber *)user_id
{
    API17_MessageAction_messageActionChatAddUser *_object = [[API17_MessageAction_messageActionChatAddUser alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_MessageAction_messageActionChatDeleteUser *)messageActionChatDeleteUserWithUser_id:(NSNumber *)user_id
{
    API17_MessageAction_messageActionChatDeleteUser *_object = [[API17_MessageAction_messageActionChatDeleteUser alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_MessageAction_messageActionSentRequest *)messageActionSentRequestWithHas_phone:(API17_Bool *)has_phone
{
    API17_MessageAction_messageActionSentRequest *_object = [[API17_MessageAction_messageActionSentRequest alloc] init];
    _object.has_phone = has_phone;
    return _object;
}

+ (API17_MessageAction_messageActionAcceptRequest *)messageActionAcceptRequest
{
    API17_MessageAction_messageActionAcceptRequest *_object = [[API17_MessageAction_messageActionAcceptRequest alloc] init];
    return _object;
}


@end

@implementation API17_MessageAction_messageActionGeoChatCreate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6f038ebc serializeBlock:^bool (API17_MessageAction_messageActionGeoChatCreate *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.address data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionGeoChatCheckin

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc7d53de serializeBlock:^bool (__unused API17_MessageAction_messageActionGeoChatCheckin *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb6aef7b0 serializeBlock:^bool (__unused API17_MessageAction_messageActionEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatCreate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xa6638b9a serializeBlock:^bool (API17_MessageAction_messageActionChatCreate *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatEditTitle

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb5a1ce5a serializeBlock:^bool (API17_MessageAction_messageActionChatEditTitle *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatEditPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7fcb13a8 serializeBlock:^bool (API17_MessageAction_messageActionChatEditPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photo data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatDeletePhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x95e3fbef serializeBlock:^bool (__unused API17_MessageAction_messageActionChatDeletePhoto *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatAddUser

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5e3cfc4b serializeBlock:^bool (API17_MessageAction_messageActionChatAddUser *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionChatDeleteUser

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb2ae9b0c serializeBlock:^bool (API17_MessageAction_messageActionChatDeleteUser *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionSentRequest

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfc479b0f serializeBlock:^bool (API17_MessageAction_messageActionSentRequest *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.has_phone data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_MessageAction_messageActionAcceptRequest

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x7f07d76c serializeBlock:^bool (__unused API17_MessageAction_messageActionAcceptRequest *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_PhoneCall ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_PhoneCall_phoneCallEmpty ()

@end

@interface API17_PhoneCall_phoneCall ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * callee_id;

@end

@implementation API17_PhoneCall

+ (API17_PhoneCall_phoneCallEmpty *)phoneCallEmptyWithPid:(NSNumber *)pid
{
    API17_PhoneCall_phoneCallEmpty *_object = [[API17_PhoneCall_phoneCallEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_PhoneCall_phoneCall *)phoneCallWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date user_id:(NSNumber *)user_id callee_id:(NSNumber *)callee_id
{
    API17_PhoneCall_phoneCall *_object = [[API17_PhoneCall_phoneCall alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.callee_id = [API17__Serializer addSerializerToObject:[callee_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_PhoneCall_phoneCallEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x5366c915 serializeBlock:^bool (API17_PhoneCall_phoneCallEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PhoneCall_phoneCall

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xec7bbe3 serializeBlock:^bool (API17_PhoneCall_phoneCall *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.callee_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_PeerNotifyEvents ()

@end

@interface API17_PeerNotifyEvents_peerNotifyEventsEmpty ()

@end

@interface API17_PeerNotifyEvents_peerNotifyEventsAll ()

@end

@implementation API17_PeerNotifyEvents

+ (API17_PeerNotifyEvents_peerNotifyEventsEmpty *)peerNotifyEventsEmpty
{
    API17_PeerNotifyEvents_peerNotifyEventsEmpty *_object = [[API17_PeerNotifyEvents_peerNotifyEventsEmpty alloc] init];
    return _object;
}

+ (API17_PeerNotifyEvents_peerNotifyEventsAll *)peerNotifyEventsAll
{
    API17_PeerNotifyEvents_peerNotifyEventsAll *_object = [[API17_PeerNotifyEvents_peerNotifyEventsAll alloc] init];
    return _object;
}


@end

@implementation API17_PeerNotifyEvents_peerNotifyEventsEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xadd53cb3 serializeBlock:^bool (__unused API17_PeerNotifyEvents_peerNotifyEventsEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PeerNotifyEvents_peerNotifyEventsAll

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6d1ded88 serializeBlock:^bool (__unused API17_PeerNotifyEvents_peerNotifyEventsAll *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end




@interface API17_NewSession ()

@property (nonatomic, strong) NSNumber * first_msg_id;
@property (nonatomic, strong) NSNumber * unique_id;
@property (nonatomic, strong) NSNumber * server_salt;

@end

@interface API17_NewSession_pnew_session_created ()

@end

@implementation API17_NewSession

+ (API17_NewSession_pnew_session_created *)pnew_session_createdWithFirst_msg_id:(NSNumber *)first_msg_id unique_id:(NSNumber *)unique_id server_salt:(NSNumber *)server_salt
{
    API17_NewSession_pnew_session_created *_object = [[API17_NewSession_pnew_session_created alloc] init];
    _object.first_msg_id = [API17__Serializer addSerializerToObject:[first_msg_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.unique_id = [API17__Serializer addSerializerToObject:[unique_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.server_salt = [API17__Serializer addSerializerToObject:[server_salt copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_NewSession_pnew_session_created

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9ec20908 serializeBlock:^bool (API17_NewSession_pnew_session_created *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.first_msg_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.unique_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_salt data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_help_AppPrefs ()

@property (nonatomic, strong) NSData * bytes;

@end

@interface API17_help_AppPrefs_help_appPrefs ()

@end

@implementation API17_help_AppPrefs

+ (API17_help_AppPrefs_help_appPrefs *)help_appPrefsWithBytes:(NSData *)bytes
{
    API17_help_AppPrefs_help_appPrefs *_object = [[API17_help_AppPrefs_help_appPrefs alloc] init];
    _object.bytes = [API17__Serializer addSerializerToObject:[bytes copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_help_AppPrefs_help_appPrefs

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x424f8614 serializeBlock:^bool (API17_help_AppPrefs_help_appPrefs *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_contacts_Found ()

@property (nonatomic, strong) NSArray * results;
@property (nonatomic, strong) NSArray * users;

@end

@interface API17_contacts_Found_contacts_found ()

@end

@implementation API17_contacts_Found

+ (API17_contacts_Found_contacts_found *)contacts_foundWithResults:(NSArray *)results users:(NSArray *)users
{
    API17_contacts_Found_contacts_found *_object = [[API17_contacts_Found_contacts_found alloc] init];
    _object.results = [API17__Serializer addSerializerToObject:[results copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    _object.users = [API17__Serializer addSerializerToObject:[users copy] serializer:[[API17__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![API17__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]];
    return _object;
}


@end

@implementation API17_contacts_Found_contacts_found

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x566000e serializeBlock:^bool (API17_contacts_Found_contacts_found *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.results data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.users data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_PeerNotifySettings ()

@end

@interface API17_PeerNotifySettings_peerNotifySettingsEmpty ()

@end

@interface API17_PeerNotifySettings_peerNotifySettings ()

@property (nonatomic, strong) NSNumber * mute_until;
@property (nonatomic, strong) NSString * sound;
@property (nonatomic, strong) API17_Bool * show_previews;
@property (nonatomic, strong) API17_PeerNotifyEvents * events;

@end

@implementation API17_PeerNotifySettings

+ (API17_PeerNotifySettings_peerNotifySettingsEmpty *)peerNotifySettingsEmpty
{
    API17_PeerNotifySettings_peerNotifySettingsEmpty *_object = [[API17_PeerNotifySettings_peerNotifySettingsEmpty alloc] init];
    return _object;
}

+ (API17_PeerNotifySettings_peerNotifySettings *)peerNotifySettingsWithMute_until:(NSNumber *)mute_until sound:(NSString *)sound show_previews:(API17_Bool *)show_previews events:(API17_PeerNotifyEvents *)events
{
    API17_PeerNotifySettings_peerNotifySettings *_object = [[API17_PeerNotifySettings_peerNotifySettings alloc] init];
    _object.mute_until = [API17__Serializer addSerializerToObject:[mute_until copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.sound = [API17__Serializer addSerializerToObject:[sound copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.show_previews = show_previews;
    _object.events = events;
    return _object;
}


@end

@implementation API17_PeerNotifySettings_peerNotifySettingsEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x70a68512 serializeBlock:^bool (__unused API17_PeerNotifySettings_peerNotifySettingsEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_PeerNotifySettings_peerNotifySettings

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xddbcd4a5 serializeBlock:^bool (API17_PeerNotifySettings_peerNotifySettings *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.mute_until data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.sound data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.show_previews data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.events data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_SchemeParam ()

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;

@end

@interface API17_SchemeParam_schemeParam ()

@end

@implementation API17_SchemeParam

+ (API17_SchemeParam_schemeParam *)schemeParamWithName:(NSString *)name type:(NSString *)type
{
    API17_SchemeParam_schemeParam *_object = [[API17_SchemeParam_schemeParam alloc] init];
    _object.name = [API17__Serializer addSerializerToObject:[name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.type = [API17__Serializer addSerializerToObject:[type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation API17_SchemeParam_schemeParam

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x21b59bef serializeBlock:^bool (API17_SchemeParam_schemeParam *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_UserProfilePhoto ()

@end

@interface API17_UserProfilePhoto_userProfilePhotoEmpty ()

@end

@interface API17_UserProfilePhoto_userProfilePhoto ()

@property (nonatomic, strong) API17_FileLocation * photo_small;
@property (nonatomic, strong) API17_FileLocation * photo_big;

@end

@implementation API17_UserProfilePhoto

+ (API17_UserProfilePhoto_userProfilePhotoEmpty *)userProfilePhotoEmpty
{
    API17_UserProfilePhoto_userProfilePhotoEmpty *_object = [[API17_UserProfilePhoto_userProfilePhotoEmpty alloc] init];
    return _object;
}

+ (API17_UserProfilePhoto_userProfilePhoto *)userProfilePhotoWithPhoto_small:(API17_FileLocation *)photo_small photo_big:(API17_FileLocation *)photo_big
{
    API17_UserProfilePhoto_userProfilePhoto *_object = [[API17_UserProfilePhoto_userProfilePhoto alloc] init];
    _object.photo_small = photo_small;
    _object.photo_big = photo_big;
    return _object;
}


@end

@implementation API17_UserProfilePhoto_userProfilePhotoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4f11bae1 serializeBlock:^bool (__unused API17_UserProfilePhoto_userProfilePhotoEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_UserProfilePhoto_userProfilePhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x990d1493 serializeBlock:^bool (API17_UserProfilePhoto_userProfilePhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.photo_small data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.photo_big data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Server_DH_inner_data ()

@property (nonatomic, strong) NSData * nonce;
@property (nonatomic, strong) NSData * server_nonce;
@property (nonatomic, strong) NSNumber * g;
@property (nonatomic, strong) NSData * dh_prime;
@property (nonatomic, strong) NSData * g_a;
@property (nonatomic, strong) NSNumber * server_time;

@end

@interface API17_Server_DH_inner_data_server_DH_inner_data ()

@end

@implementation API17_Server_DH_inner_data

+ (API17_Server_DH_inner_data_server_DH_inner_data *)server_DH_inner_dataWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce g:(NSNumber *)g dh_prime:(NSData *)dh_prime g_a:(NSData *)g_a server_time:(NSNumber *)server_time
{
    API17_Server_DH_inner_data_server_DH_inner_data *_object = [[API17_Server_DH_inner_data_server_DH_inner_data alloc] init];
    _object.nonce = [API17__Serializer addSerializerToObject:[nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.server_nonce = [API17__Serializer addSerializerToObject:[server_nonce copy] serializer:[[API17_BuiltinSerializer_Int128 alloc] init]];
    _object.g = [API17__Serializer addSerializerToObject:[g copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.dh_prime = [API17__Serializer addSerializerToObject:[dh_prime copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.g_a = [API17__Serializer addSerializerToObject:[g_a copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.server_time = [API17__Serializer addSerializerToObject:[server_time copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Server_DH_inner_data_server_DH_inner_data

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb5890dba serializeBlock:^bool (API17_Server_DH_inner_data_server_DH_inner_data *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_nonce data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.g data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.dh_prime data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.g_a data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.server_time data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_InputPhoto ()

@end

@interface API17_InputPhoto_inputPhotoEmpty ()

@end

@interface API17_InputPhoto_inputPhoto ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;

@end

@implementation API17_InputPhoto

+ (API17_InputPhoto_inputPhotoEmpty *)inputPhotoEmpty
{
    API17_InputPhoto_inputPhotoEmpty *_object = [[API17_InputPhoto_inputPhotoEmpty alloc] init];
    return _object;
}

+ (API17_InputPhoto_inputPhoto *)inputPhotoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash
{
    API17_InputPhoto_inputPhoto *_object = [[API17_InputPhoto_inputPhoto alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_InputPhoto_inputPhotoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x1cd7bf0d serializeBlock:^bool (__unused API17_InputPhoto_inputPhotoEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_InputPhoto_inputPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfb95c6c4 serializeBlock:^bool (API17_InputPhoto_inputPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_DecryptedMessageMedia ()

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaVideo ()

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

@interface API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@implementation API17_DecryptedMessageMedia

+ (API17_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    API17_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    API17_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [API17__Serializer addSerializerToObject:[thumb copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [API17__Serializer addSerializerToObject:[thumb_w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [API17__Serializer addSerializerToObject:[thumb_h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key = [API17__Serializer addSerializerToObject:[key copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [API17__Serializer addSerializerToObject:[iv copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    API17_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [API17__Serializer addSerializerToObject:[thumb copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [API17__Serializer addSerializerToObject:[thumb_w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [API17__Serializer addSerializerToObject:[thumb_h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key = [API17__Serializer addSerializerToObject:[key copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [API17__Serializer addSerializerToObject:[iv copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [API17__Serializer addSerializerToObject:[lat copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    _object.plong = [API17__Serializer addSerializerToObject:[plong copy] serializer:[[API17_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    API17_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phone_number = [API17__Serializer addSerializerToObject:[phone_number copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.first_name = [API17__Serializer addSerializerToObject:[first_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.last_name = [API17__Serializer addSerializerToObject:[last_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    API17_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [API17__Serializer addSerializerToObject:[thumb copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [API17__Serializer addSerializerToObject:[thumb_w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [API17__Serializer addSerializerToObject:[thumb_h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.file_name = [API17__Serializer addSerializerToObject:[file_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key = [API17__Serializer addSerializerToObject:[key copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [API17__Serializer addSerializerToObject:[iv copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    API17_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[API17_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.key = [API17__Serializer addSerializerToObject:[key copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [API17__Serializer addSerializerToObject:[iv copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused API17_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x4cee6ef3 serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xb095434b serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x6080758f serializeBlock:^bool (API17_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Video ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Video_videoEmpty ()

@end

@interface API17_Video_video ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) API17_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dc_id;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@implementation API17_Video

+ (API17_Video_videoEmpty *)videoEmptyWithPid:(NSNumber *)pid
{
    API17_Video_videoEmpty *_object = [[API17_Video_videoEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Video_video *)videoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption duration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(API17_PhotoSize *)thumb dc_id:(NSNumber *)dc_id w:(NSNumber *)w h:(NSNumber *)h
{
    API17_Video_video *_object = [[API17_Video_video alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.caption = [API17__Serializer addSerializerToObject:[caption copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.duration = [API17__Serializer addSerializerToObject:[duration copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.w = [API17__Serializer addSerializerToObject:[w copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.h = [API17__Serializer addSerializerToObject:[h copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Video_videoEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc10658a8 serializeBlock:^bool (API17_Video_videoEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Video_video

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x388fa391 serializeBlock:^bool (API17_Video_video *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_EncryptedChat ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_EncryptedChat_encryptedChatEmpty ()

@end

@interface API17_EncryptedChat_encryptedChatWaiting ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * admin_id;
@property (nonatomic, strong) NSNumber * participant_id;

@end

@interface API17_EncryptedChat_encryptedChatDiscarded ()

@end

@interface API17_EncryptedChat_encryptedChatRequested ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * admin_id;
@property (nonatomic, strong) NSNumber * participant_id;
@property (nonatomic, strong) NSData * g_a;

@end

@interface API17_EncryptedChat_encryptedChat ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * admin_id;
@property (nonatomic, strong) NSNumber * participant_id;
@property (nonatomic, strong) NSData * g_a_or_b;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@implementation API17_EncryptedChat

+ (API17_EncryptedChat_encryptedChatEmpty *)encryptedChatEmptyWithPid:(NSNumber *)pid
{
    API17_EncryptedChat_encryptedChatEmpty *_object = [[API17_EncryptedChat_encryptedChatEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_EncryptedChat_encryptedChatWaiting *)encryptedChatWaitingWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id
{
    API17_EncryptedChat_encryptedChatWaiting *_object = [[API17_EncryptedChat_encryptedChatWaiting alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.admin_id = [API17__Serializer addSerializerToObject:[admin_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.participant_id = [API17__Serializer addSerializerToObject:[participant_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_EncryptedChat_encryptedChatDiscarded *)encryptedChatDiscardedWithPid:(NSNumber *)pid
{
    API17_EncryptedChat_encryptedChatDiscarded *_object = [[API17_EncryptedChat_encryptedChatDiscarded alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (API17_EncryptedChat_encryptedChatRequested *)encryptedChatRequestedWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id g_a:(NSData *)g_a
{
    API17_EncryptedChat_encryptedChatRequested *_object = [[API17_EncryptedChat_encryptedChatRequested alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.admin_id = [API17__Serializer addSerializerToObject:[admin_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.participant_id = [API17__Serializer addSerializerToObject:[participant_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.g_a = [API17__Serializer addSerializerToObject:[g_a copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (API17_EncryptedChat_encryptedChat *)encryptedChatWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id g_a_or_b:(NSData *)g_a_or_b key_fingerprint:(NSNumber *)key_fingerprint
{
    API17_EncryptedChat_encryptedChat *_object = [[API17_EncryptedChat_encryptedChat alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.admin_id = [API17__Serializer addSerializerToObject:[admin_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.participant_id = [API17__Serializer addSerializerToObject:[participant_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.g_a_or_b = [API17__Serializer addSerializerToObject:[g_a_or_b copy] serializer:[[API17_BuiltinSerializer_Bytes alloc] init]];
    _object.key_fingerprint = [API17__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_EncryptedChat_encryptedChatEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xab7ec0a0 serializeBlock:^bool (API17_EncryptedChat_encryptedChatEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedChat_encryptedChatWaiting

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x3bf703dc serializeBlock:^bool (API17_EncryptedChat_encryptedChatWaiting *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.admin_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.participant_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedChat_encryptedChatDiscarded

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x13d6dd27 serializeBlock:^bool (API17_EncryptedChat_encryptedChatDiscarded *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedChat_encryptedChatRequested

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xc878527e serializeBlock:^bool (API17_EncryptedChat_encryptedChatRequested *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.admin_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.participant_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.g_a data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_EncryptedChat_encryptedChat

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xfa56ce36 serializeBlock:^bool (API17_EncryptedChat_encryptedChat *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.admin_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.participant_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.g_a_or_b data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_Document ()

@property (nonatomic, strong) NSNumber * pid;

@end

@interface API17_Document_documentEmpty ()

@end

@interface API17_Document_document ()

@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) API17_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dc_id;

@end

@implementation API17_Document

+ (API17_Document_documentEmpty *)documentEmptyWithPid:(NSNumber *)pid
{
    API17_Document_documentEmpty *_object = [[API17_Document_documentEmpty alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (API17_Document_document *)documentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(API17_PhotoSize *)thumb dc_id:(NSNumber *)dc_id
{
    API17_Document_document *_object = [[API17_Document_document alloc] init];
    _object.pid = [API17__Serializer addSerializerToObject:[pid copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [API17__Serializer addSerializerToObject:[access_hash copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.date = [API17__Serializer addSerializerToObject:[date copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.file_name = [API17__Serializer addSerializerToObject:[file_name copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [API17__Serializer addSerializerToObject:[mime_type copy] serializer:[[API17_BuiltinSerializer_String alloc] init]];
    _object.size = [API17__Serializer addSerializerToObject:[size copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dc_id = [API17__Serializer addSerializerToObject:[dc_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    return _object;
}


@end

@implementation API17_Document_documentEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x36f8c871 serializeBlock:^bool (API17_Document_documentEmpty *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end

@implementation API17_Document_document

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0x9efc6326 serializeBlock:^bool (API17_Document_document *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![API17__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




@interface API17_ImportedContact ()

@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * client_id;

@end

@interface API17_ImportedContact_importedContact ()

@end

@implementation API17_ImportedContact

+ (API17_ImportedContact_importedContact *)importedContactWithUser_id:(NSNumber *)user_id client_id:(NSNumber *)client_id
{
    API17_ImportedContact_importedContact *_object = [[API17_ImportedContact_importedContact alloc] init];
    _object.user_id = [API17__Serializer addSerializerToObject:[user_id copy] serializer:[[API17_BuiltinSerializer_Int alloc] init]];
    _object.client_id = [API17__Serializer addSerializerToObject:[client_id copy] serializer:[[API17_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation API17_ImportedContact_importedContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [API17__Serializer addSerializerToObject:self withConstructorSignature:0xd0028438 serializeBlock:^bool (API17_ImportedContact_importedContact *object, NSMutableData *data)
        {
            if (![API17__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            if (![API17__Environment serializeObject:object.client_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

@end




