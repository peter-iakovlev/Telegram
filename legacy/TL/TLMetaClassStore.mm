#include "TLMetaClassStore.h"

#import "NSData+GZip.h"
#import "NSInputStream+TL.h"

#import "TLCompressedObject.h"
#import "TLMessageContainer.h"
#import "TLRpcResult.h"

#import "TLResPQ$resPQ_manual.h"
#import "TLMsgsAck$msgs_ack_manual.h"
#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"
#import "TLWebPage_manual.h"
#import "TLUser$modernUser.h"
#import "TLDcOption$modernDcOption.h"
#import "TLUpdates$modernUpdateShortMessage.h"
#import "TLUpdates$modernUpdateShortChatMessage.h"
#import "TLaccount_PasswordInputSettings_manual.h"
#import "TLmessages_Messages$modernChannelMessages.h"
#import "TLUpdates$updateShortSentMessage.h"
#import "TLUpdates_ChannelDifference_manual.h"
#import "TLChat$channel.h"
#import "TLChatFull$channelFull.h"
#import "TLChat$chat.h"
#import "TLChatParticipants$chatParticipantsForbidden.h"
#import "TLWebPage$webPageExternal.h"
#import "TLMessages_BotResults$botResults.h"
#import "TLBotInlineMessage$botInlineMessageMediaAuto.h"
#import "TLBotInlineMessage$botInlineMessageText.h"
#import "TLBotInlineResult$botInlineResult.h"
#import "TLDocumentAttribute$documentAttributeAudio.h"
#import "TLMessageFwdHeader$messageFwdHeader.h"
#import "TLUserFull$userFull.h"
#import "TLUpdate$updateChannelTooLong.h"
#import "TLauth_SentCode$auth_sentCode.h"
#import "TLmessages_BotCallbackAnswer$botCallbackAnswer.h"
#import "TLBotInlineResult$botInlineMediaResult.h"
#import "TLBotInlineMessage$botInlineMessageMediaGeo.h"
#import "TLBotInlineMessage$botInlineMessageMediaVenue.h"
#import "TLBotInlineMessage$botInlineMessageMediaContact.h"
#import "TLDialog$dialog.h"
#import "TLDraftMessage$draftMessage.h"
#import "TLChatInvite$chatInvite.h"
#import "TLConfig$config.h"
#import "TLGame$game.h"
#import "TLPageBlock$pageBlockEmbed.h"
#import "TLPhoneCall$phoneCallWaiting.h"
#import "TLUpdate$updateServiceNotification.h"
#import "TLPhoneCall$phoneCallDiscarded.h"
#import "TLUpdate$updatePinnedDialogs.h"
#import "TLMessageAction$messageActionPhoneCall.h"
#import "TLInvoice$invoice.h"
#import "TLMessageMedia$messageMediaInvoice.h"
#import "TLpayments_PaymentForm$payments_paymentForm.h"
#import "TLpayments_SavedInfo$payments_savedInfo.h"
#import "TLPaymentRequestedInfo$paymentRequestedInfo.h"
#import "TLPayments_PaymentCeceipt$payments_paymentReceipt.h"
#import "TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo.h"
#import "TLLangPackStringPluralized.h"
#import "TLChat$channelForbidden.h"
#import "TLMessageMedia$messageMediaPhoto.h"
#import "TLMessageMedia$messageMediaDocument.h"

#import "TLDocumentAttributeSticker.h"

#import "TLBool.h"

#import "TGStringUtils.h"

#import "TLauth_Authorization$auth_authorization.h"

#include <map>
#include <set>

#include <zlib.h>

struct TLMetaTypeArgumentWithName : public TLMetaTypeArgument
{
    std::vector<char> name;
};

static std::unordered_map<int32_t, NSString *> hashToStringMap;

std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> > TLMetaClassStore::constructorsBySignature;
std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> > TLMetaClassStore::constructorsByName;
std::unordered_map<int32_t, std::shared_ptr<TLMetaType> > TLMetaClassStore::typesByName;
std::unordered_map<int32_t, TLMetaTypeArgument> TLMetaClassStore::vectorElementTypesByConstructor;

std::unordered_map<int32_t, id<TLObject> > TLMetaClassStore::objectClassesByConstructorNames;
std::unordered_map<int32_t, id<TLVector> > TLMetaClassStore::vectorClassesBySignature;

std::unordered_map<int32_t, id<TLObject> > TLMetaClassStore::manualObjectParsers;
std::unordered_map<int32_t, id<TLObject> > TLMetaClassStore::manualObjectSerializers;

static void addHashToString(int32_t hash, NSString *string)
{
    hashToStringMap.insert(std::pair<int32_t, NSString *>(hash, string));
}

static NSString *stringForHash(int32_t hash)
{
    std::unordered_map<int32_t, NSString *>::iterator it = hashToStringMap.find(hash);
    if (it == hashToStringMap.end())
        return [NSString stringWithFormat:@"#%.8x", hash];
    return it->second;
}

void TLMetaClassStore::registerObjectClass(id<TLObject> objectClass)
{
    objectClassesByConstructorNames.insert(std::pair<int32_t, id<TLObject> >([objectClass TLconstructorName], objectClass));
}

void TLMetaClassStore::registerVectorClass(id<TLVector> vectorClass)
{
#if TARGET_IPHONE_SIMULATOR
    std::unordered_map<int32_t, id<TLVector> >::iterator it = vectorClassesBySignature.find([vectorClass TLconstructorSignature]);
    if (it != vectorClassesBySignature.end())
        TGLog(@"***** Overriding constructor 0x%x with %@ (was %@)", [vectorClass TLconstructorSignature], [vectorClass class], [it->second class]);
    
#endif
    vectorClassesBySignature.insert(std::pair<int32_t, id<TLVector> >([vectorClass TLconstructorSignature], vectorClass));
}

id<TLObject> TLMetaClassStore::getObjectClass(int32_t name)
{
    std::unordered_map<int32_t, id<TLObject> >::iterator it = objectClassesByConstructorNames.find(name);
    if (it == objectClassesByConstructorNames.end())
    {
        TGLog(@"%.8x -> %@", name, stringForHash(name));
        return nil;
    }
    return it->second;
}

void TLMetaClassStore::clearScheme()
{
    constructorsBySignature.clear();
    constructorsByName.clear();
    typesByName.clear();
    vectorElementTypesByConstructor.clear();
}

TLMetaTypeArgument createTypeArgumentFromString(NSString *desc, std::set<int32_t> &typesToResolve, std::map<int32_t, TLMetaTypeArgumentWithName> &vectorTypeMap, bool &hasUnresolvedTypes)
{
    TLMetaTypeArgument type;
    
    type.unboxedConstructorName = 0;
    type.unboxedConstructorSignature = 0;
    
    TLMetaTypeCategory category;
    int32_t typeName = 0;
    
    std::vector<TLMetaTypeArgument> typeArguments;
    
    if ([desc isEqualToString:@"int"])
    {
        typeName = murMurHash32(@"Int");
        addHashToString(typeName, @"Int");
        
        category = TLMetaTypeCategoryBuiltinInt32;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_INT32_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"Int"])
    {
        typeName = murMurHash32(@"Int");
        addHashToString(typeName, @"Int");
        
        category = TLMetaTypeCategoryBuiltinInt32;
        type.boxed = true;
    }
    else if ([desc isEqualToString:@"long"])
    {
        typeName = murMurHash32(@"Long");
        addHashToString(typeName, @"Long");
        
        category = TLMetaTypeCategoryBuiltinInt64;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_INT64_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"Long"])
    {
        typeName = murMurHash32(@"Long");
        addHashToString(typeName, @"Long");
        
        category = TLMetaTypeCategoryBuiltinInt64;
        type.boxed = true;
    }
    else if ([desc isEqualToString:@"int128"])
    {
        typeName = murMurHash32(@"Int128");
        addHashToString(typeName, @"Int128");
        
        category = TLMetaTypeCategoryBuiltinInt128;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_INT128_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"int256"])
    {
        typeName = murMurHash32(@"Int256");
        addHashToString(typeName, @"Int256");
        
        category = TLMetaTypeCategoryBuiltinInt256;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_INT256_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"double"])
    {
        typeName = murMurHash32(@"Double");
        addHashToString(typeName, @"Double");
        
        category = TLMetaTypeCategoryBuiltinDouble;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_DOUBLE_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"Double"])
    {
        typeName = murMurHash32(@"Double");
        addHashToString(typeName, @"Double");
        
        category = TLMetaTypeCategoryBuiltinDouble;
        type.boxed = true;
    }
    else if ([desc isEqualToString:@"string"])
    {
        typeName = murMurHash32(@"String");
        addHashToString(typeName, @"String");
        
        category = TLMetaTypeCategoryBuiltinString;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_STRING_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"String"])
    {
        typeName = murMurHash32(@"String");
        addHashToString(typeName, @"String");
        
        category = TLMetaTypeCategoryBuiltinString;
        type.boxed = true;
    }
    else if ([desc isEqualToString:@"bytes"])
    {
        typeName = murMurHash32(@"Bytes");
        addHashToString(typeName, @"Bytes");
        
        category = TLMetaTypeCategoryBuiltinBytes;
        type.boxed = false;
        type.unboxedConstructorSignature = TL_BYTES_CONSTRUCTOR;
    }
    else if ([desc isEqualToString:@"Bytes"])
    {
        typeName = murMurHash32(@"Bytes");
        addHashToString(typeName, @"Bytes");
        
        category = TLMetaTypeCategoryBuiltinBytes;
        type.boxed = true;
    }
    else if ([desc isEqualToString:@"Bool"])
    {
        typeName = murMurHash32(@"Bool");
        addHashToString(typeName, @"Bool");
        
        category = TLMetaTypeCategoryBuiltinBool;
        type.boxed = true;
    }
    else if ([desc hasPrefix:@"Vector<"])
    {
        typeName = murMurHash32(desc);
        addHashToString(typeName, desc);
        
        NSString *typeArgumentDesc = [desc substringWithRange:NSMakeRange(7, desc.length - 7 - 1)];
        TLMetaTypeArgument typeArgument = createTypeArgumentFromString(typeArgumentDesc, typesToResolve, vectorTypeMap, hasUnresolvedTypes);
        typeArguments.push_back(typeArgument);
        
        TLMetaTypeArgumentWithName typeArgumentWithName;
        typeArgumentWithName.boxed = typeArgument.boxed;
        typeArgumentWithName.unboxedConstructorSignature = typeArgument.unboxedConstructorSignature;
        typeArgumentWithName.type = typeArgument.type;
        
        const char *utf8String = [typeArgumentDesc UTF8String];
        typeArgumentWithName.name.insert(typeArgumentWithName.name.end(), utf8String, utf8String + strlen(utf8String));
        
        vectorTypeMap[typeArgument.type->getName()] = typeArgumentWithName;
        
        category = TLMetaTypeCategoryBuiltinVector;
        type.boxed = true;
        
        type.unboxedConstructorName = murMurHash32(desc);

        const char *vectorPrefix = "vector # [ ";
        const char *vectorSuffix = " ] = Vector ";
        
        const char *utf8string = [typeArgumentDesc UTF8String];
        
        std::vector<char> signatureString;
        signatureString.insert(signatureString.end(), vectorPrefix, vectorPrefix + 11);
        signatureString.insert(signatureString.end(), utf8string, utf8string + strlen(utf8string));
        signatureString.insert(signatureString.end(), vectorSuffix, vectorSuffix + 12);
        signatureString.insert(signatureString.end(), utf8string, utf8string + strlen(utf8string));
        
        type.unboxedConstructorSignature = (int32_t)crc32(0, (const Bytef *)signatureString.data(), (int32_t)signatureString.size());
    }
    else if ([desc hasPrefix:@"vector<"])
    {
        typeName = murMurHash32(desc);
        addHashToString(typeName, desc);
        
        NSString *typeArgumentDesc = [desc substringWithRange:NSMakeRange(7, desc.length - 7 - 1)];
        TLMetaTypeArgument typeArgument = createTypeArgumentFromString(typeArgumentDesc, typesToResolve, vectorTypeMap, hasUnresolvedTypes);
        typeArguments.push_back(typeArgument);
        
        TLMetaTypeArgumentWithName typeArgumentWithName;
        typeArgumentWithName.boxed = typeArgument.boxed;
        typeArgumentWithName.unboxedConstructorSignature = typeArgument.unboxedConstructorSignature;
        typeArgumentWithName.unboxedConstructorName = typeArgument.unboxedConstructorName;
        typeArgumentWithName.type = typeArgument.type;
        
        const char *utf8String = [typeArgumentDesc UTF8String];
        typeArgumentWithName.name.insert(typeArgumentWithName.name.end(), utf8String, utf8String + strlen(utf8String));
        
        vectorTypeMap[typeArgument.type->getName()] = typeArgumentWithName;
        
        category = TLMetaTypeCategoryBuiltinVector;
        type.boxed = false;
        
        const char *vectorPrefix = "vector # [ ";
        const char *vectorSuffix = " ] = Vector ";
        
        const char *utf8string = [typeArgumentDesc UTF8String];

        std::vector<char> signatureString;
        signatureString.insert(signatureString.end(), vectorPrefix, vectorPrefix + 11);
        signatureString.insert(signatureString.end(), utf8string, utf8string + strlen(utf8string));
        signatureString.insert(signatureString.end(), vectorSuffix, vectorSuffix + 12);
        signatureString.insert(signatureString.end(), utf8string, utf8string + strlen(utf8string));
        
        type.unboxedConstructorSignature = (int32_t)crc32(0, (const Bytef *)signatureString.data(), (int32_t)signatureString.size());
    }
    else if ([desc isEqualToString:@"Object"])
    {
        typeName = murMurHash32(@"Object");
        addHashToString(typeName, @"Object");
        
        category = TLMetaTypeCategoryObject;
        type.boxed = true;
    }
    else
    {
        NSString *boxedDesc = desc;
        
        NSRange range = [desc rangeOfString:@"."];
        if (range.location == NSNotFound)
        {
            unichar c = [desc characterAtIndex:0];
            type.boxed = isupper(c);
            
            if (!type.boxed)
            {
                c = (unichar)toupper(c);
                boxedDesc = [desc stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithCharacters:&c length:1]];
            }
        }
        else
        {
            unichar c = [desc characterAtIndex:range.location + 1];
            type.boxed = isupper(c);
            
            if (!type.boxed)
            {
                c = (unichar)toupper(c);
                boxedDesc = [desc stringByReplacingCharactersInRange:NSMakeRange(range.location + 1, 1) withString:[NSString stringWithCharacters:&c length:1]];
            }
        }
        
        typeName = murMurHash32(boxedDesc);
        addHashToString(typeName, boxedDesc);
        
        category = TLMetaTypeCategoryObject;
        
        type.unboxedConstructorSignature = 0;
        type.unboxedConstructorName = 0;
        if (!type.boxed)
        {
            type.unboxedConstructorName = murMurHash32(desc);
            addHashToString(type.unboxedConstructorName, desc);
            hasUnresolvedTypes = true;
        }
        
        typesToResolve.insert(typeName);
    }
    
    std::shared_ptr<TLMetaType> metaType(new TLMetaType(typeName, category, typeArguments));
    
    type.type = metaType;
    
    return type;
}

bool resolveUnboxedTypes(TLMetaTypeArgument *type, std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> > const &constructorsByName, std::unordered_map<int32_t, TLMetaTypeArgument> const &vectorElementTypes)
{
    for (std::vector<TLMetaTypeArgument>::iterator it = type->type->getArguments().begin(); it != type->type->getArguments().end(); it++)
    {
        if (!resolveUnboxedTypes(&(*it), constructorsByName, vectorElementTypes))
            return false;
    }
    
    if (!type->boxed && type->unboxedConstructorSignature == 0)
    {
        std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> >::const_iterator foundIt = constructorsByName.find(type->unboxedConstructorName);
        if (foundIt != constructorsByName.end())
        {
            type->unboxedConstructorSignature = foundIt->second->getSignature();
        }
        else
        {
            TGLog(@"***** Failed to resolve unboxed type %@", stringForHash(type->unboxedConstructorName));
            return false;
        }
    }
    
    return true;
}

std::shared_ptr<TLMetaType> createTypeFromString(NSString *desc, std::set<int32_t> &typesToResolve, std::map<int32_t, TLMetaTypeArgumentWithName> &vectorTypeMap)
{
    bool hasUnresolvedTypes = false;
    TLMetaTypeArgument type = createTypeArgumentFromString(desc, typesToResolve, vectorTypeMap, hasUnresolvedTypes);
    return type.type;
}

void TLMetaClassStore::mergeScheme(TLScheme *scheme)
{
    if ([scheme isKindOfClass:[TLScheme$scheme class]])
    {   
        std::unordered_map<int32_t, std::pair<TLMetaTypeArgument, bool> > cachedFieldTypes;
        std::map<int32_t, TLMetaTypeArgumentWithName> vectorTypeMap;
        std::set<int32_t> typesToResolve;
        std::vector<std::shared_ptr<TLMetaConstructor> > constructorsWithUnresolvedTypes;
        
        NSMutableArray *types = [[NSMutableArray alloc] initWithArray:((TLScheme$scheme *)scheme).types];
        NSArray *methods = ((TLScheme$scheme *)scheme).methods;
        
        {
            id<TLObject> object = [[TLDestroySessionsRes$destroy_sessions_res alloc] init];
            manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >([object TLconstructorSignature], object));
        }
        
        {
            TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
            constructor.n_id = (int32_t)0x73f1f8dc;
            constructor.predicate = @"msg_container";
            constructor.type = @"MessageContainer";
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"messages";
                arg.type = @"vector<protoMessage>";
                [fields addObject:arg];
            }
            constructor.params = fields;
            [types addObject:constructor];
            
            manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(constructor.n_id, [[TLMessageContainer$msg_container alloc] init]));
        }
        
        {
            TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
            constructor.n_id = (int32_t)0xf35c6d01;
            constructor.predicate = @"rpc_result";
            constructor.type = @"RpcResult";
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"req_msg_id";
                arg.type = @"long";
                [fields addObject:arg];
            }
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"result";
                arg.type = @"Object";
                [fields addObject:arg];
            }
            constructor.params = fields;
            [types addObject:constructor];
            
            manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(constructor.n_id, [[TLRpcResult$rpc_result alloc] init]));
        }
        
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x5162463, [[TLResPQ$resPQ_manual alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x62d6b459, [[TLMsgsAck$msgs_ack_manual alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x90dddc11, [[TLMessage$modernMessage alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x9e19a1f6, [[TLMessage$modernMessageService alloc] init]));
        
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >((int32_t)0x5f07b4bc, [[TLWebPage_manual alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >((int32_t)0x2e13f4c3, [[TLUser$modernUser alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >((int32_t)0x05D8C6CC, [[TLDcOption$modernDcOption alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x914FBF11, [[TLUpdates$modernUpdateShortMessage alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x16812688, [[TLUpdates$modernUpdateShortChatMessage alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xBC0F17BC, [[TLmessages_Messages$modernChannelMessages alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x11f1331c, [[TLUpdates$updateShortSentMessage alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x2064674E, [[TLUpdates_ChannelDifference$channelDifference alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x3E11AFFB, [[TLUpdates_ChannelDifference$empty alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x410dee07, [[TLUpdates_ChannelDifference$tooLong alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x0cb44b1c, [[TLChat$channel alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x95cb5f57, [[TLChatFull$channelFull alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xFC900C2B, [[TLChatParticipants$chatParticipantsForbidden alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xD91CDD54, [[TLChat$chat alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xB08FBB93, [[TLWebPage$webPageExternal alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xccd3563d, [[TLMessages_BotResults$botResults alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xa74b15b, [[TLBotInlineMessage$botInlineMessageMediaAuto alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x8c7f65e2, [[TLBotInlineMessage$botInlineMessageText alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x3a8fd8b8, [[TLBotInlineMessage$botInlineMessageMediaGeo alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x4366232e, [[TLBotInlineMessage$botInlineMessageMediaVenue alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x35edb4d4, [[TLBotInlineMessage$botInlineMessageMediaContact alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x9BEBAEB9, [[TLBotInlineResult$botInlineResult alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x9852F9C6, [[TLDocumentAttribute$documentAttributeAudio alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xfadff4ac, [[TLMessageFwdHeader$messageFwdHeader alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xf220f3f, [[TLUserFull$userFull alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xeb0467fb, [[TLUpdate$updateChannelTooLong alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x5e002502, [[TLauth_SentCode$auth_sentCode alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x36585ea4, [[TLmessages_BotCallbackAnswer$botCallbackAnswer alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x17db940b, [[TLBotInlineResult$botInlineMediaResult alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x66ffba14, [[TLDialog$dialog alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xfd8e711f, [[TLDraftMessage$draftMessage alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xdb74f558, [[TLChatInvite$chatInvite alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x7feec888, [[TLConfig$config alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xcd050916, [[TLauth_Authorization$auth_authorization alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x6319d612, [[TLDocumentAttributeSticker alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xbdf9653b, [[TLGame$game alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xcde200d1, [[TLPageBlock$pageBlockEmbed alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x1b8f4ad1, [[TLPhoneCall$phoneCallWaiting alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xebe46819, [[TLUpdate$updateServiceNotification alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x50ca4de1, [[TLPhoneCall$phoneCallDiscarded alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xd8caf68d, [[TLUpdate$updatePinnedDialogs alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x80e11a7f, [[TLMessageAction$messageActionPhoneCall alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xc30aa358, [[TLInvoice$invoice alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x84551347, [[TLMessageMedia$messageMediaInvoice alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x3f56aea3, [[TLpayments_PaymentForm$payments_paymentForm alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xfb8fe43c, [[TLpayments_SavedInfo$payments_savedInfo alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x909c3f94, [[TLPaymentRequestedInfo$paymentRequestedInfo alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x500911e1, [[TLPayments_PaymentCeceipt$payments_paymentReceipt alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xd1451883, [[TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x6c47ac9f, [[TLLangPackStringPluralized alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x289da732, [[TLChat$channelForbidden alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0xb5223b0f, [[TLMessageMedia$messageMediaPhoto alloc] init]));
        manualObjectParsers.insert(std::pair<int32_t, id<TLObject> >(0x7c4414d3, [[TLMessageMedia$messageMediaDocument alloc] init]));
        
        {
            TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
            constructor.n_id = (int32_t)0xae500895;
            constructor.predicate = @"futuresalts";
            constructor.type = @"FutureSalts";
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"req_msg_id";
                arg.type = @"long";
                [fields addObject:arg];
            }
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"now";
                arg.type = @"int";
                [fields addObject:arg];
            }
            {
                TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
                arg.name = @"salts";
                arg.type = @"vector<futureSalt>";
                [fields addObject:arg];
            }
            constructor.params = fields;
            [types addObject:constructor];
        }
        
        for (TLSchemeType *typeDesc in types)
        {
            NSString *name = typeDesc.type;
            if ([name isEqualToString:@"Bool"] || [name isEqualToString:@"Null"] || [name hasPrefix:@"Vector<"])
            {
                continue;
            }
            
            std::shared_ptr<std::vector<TLMetaField> > fields(new std::vector<TLMetaField>());
            
            bool hasUnresolvedTypes = false;
            
            for (TLSchemeParam *argDesc in typeDesc.params)
            {
                TLMetaField field;
                field.name = murMurHash32(argDesc.name);
                
                NSString *typeName = argDesc.type;
                
                int32_t fieldTypeName = murMurHash32(typeName);
                std::unordered_map<int32_t, std::pair<TLMetaTypeArgument, bool> >::iterator it = cachedFieldTypes.find(fieldTypeName);
                if (it == cachedFieldTypes.end())
                {
                    bool fieldUnresolvedTypes = false;
                    field.type = createTypeArgumentFromString(typeName, typesToResolve, vectorTypeMap, fieldUnresolvedTypes);
                    cachedFieldTypes.insert(std::pair<int32_t, std::pair<TLMetaTypeArgument, bool> >(fieldTypeName, std::make_pair(field.type, fieldUnresolvedTypes)));
                    if (fieldUnresolvedTypes)
                        hasUnresolvedTypes = true;
                }
                else
                {
                    field.type = it->second.first;
                    if (it->second.second)
                        hasUnresolvedTypes = true;
                }
                
                fields->push_back(field);
            }
            
            std::shared_ptr<TLMetaType> resultType = createTypeFromString(name, typesToResolve, vectorTypeMap);
            typesByName[resultType->getName()] = resultType;
            
            std::shared_ptr<TLMetaConstructor> constructor(new TLMetaConstructor(murMurHash32(typeDesc.predicate), typeDesc.n_id, fields, resultType));
            constructorsBySignature[constructor->getSignature()] = constructor;
            constructorsByName[constructor->getName()] = constructor;
            
            if (hasUnresolvedTypes)
            {
                constructorsWithUnresolvedTypes.push_back(constructor);
            }
        }
        
        for (TLSchemeMethod *method in methods)
        {
            if ([method.type hasPrefix:@"Vector<"])
            {
                bool hasUnresolvedTypes = false;
                createTypeArgumentFromString(method.type, typesToResolve, vectorTypeMap, hasUnresolvedTypes);
            }
        }
        
        const char *vectorPrefix = "vector # [ ";
        const char *vectorSuffix = " ] = Vector ";
        for (std::map<int32_t, TLMetaTypeArgumentWithName>::iterator it = vectorTypeMap.begin(); it != vectorTypeMap.end(); it++)
        {
            std::vector<char> signatureString;
            signatureString.insert(signatureString.end(), vectorPrefix, vectorPrefix + 11);
            signatureString.insert(signatureString.end(), it->second.name.begin(), it->second.name.end());
            signatureString.insert(signatureString.end(), vectorSuffix, vectorSuffix + 12);
            signatureString.insert(signatureString.end(), it->second.name.begin(), it->second.name.end());
            
            int32_t signature = (int32_t)crc32(0, (const Bytef *)signatureString.data(), (int32_t)signatureString.size());
            
            TLMetaTypeArgument typeArgument;
            typeArgument.boxed = it->second.boxed;
            typeArgument.unboxedConstructorName = it->second.unboxedConstructorName;
            typeArgument.unboxedConstructorSignature = it->second.unboxedConstructorSignature;
            typeArgument.type = it->second.type;
            
            vectorElementTypesByConstructor.insert(std::pair<int32_t, TLMetaTypeArgument>(signature, typeArgument));
        }
        
        for (TLSchemeMethod *methodDesc in ((TLScheme$scheme *)scheme).methods)
        {
            NSString *resultTypeName = methodDesc.type;
            NSString *method = methodDesc.method;
            
            std::shared_ptr<std::vector<TLMetaField> > fields(new std::vector<TLMetaField>());
            
            bool hasUnresolvedTypes = false;
            
            for (TLSchemeParam *argDesc in methodDesc.params)
            {
                TLMetaField field;
                field.name = murMurHash32(argDesc.name);
                
                NSString *typeName = argDesc.type;
                
                int32_t fieldTypeName = murMurHash32(typeName);
                std::unordered_map<int32_t, std::pair<TLMetaTypeArgument, bool> >::iterator it = cachedFieldTypes.find(fieldTypeName);
                if (it == cachedFieldTypes.end())
                {
                    bool fieldUnresolvedTypes = false;
                    field.type = createTypeArgumentFromString(typeName, typesToResolve, vectorTypeMap, fieldUnresolvedTypes);
                    cachedFieldTypes.insert(std::pair<int32_t, std::pair<TLMetaTypeArgument, bool> >(fieldTypeName, std::make_pair(field.type, fieldUnresolvedTypes)));
                    if (fieldUnresolvedTypes)
                        hasUnresolvedTypes = true;
                }
                else
                {
                    field.type = it->second.first;
                    if (it->second.second)
                        hasUnresolvedTypes = true;
                }
                
                fields->push_back(field);
            }
            
            std::shared_ptr<TLMetaType> resultType = createTypeFromString(resultTypeName, typesToResolve, vectorTypeMap);
            
            if (!([resultTypeName isEqualToString:@"Bool"] || [resultTypeName hasPrefix:@"Vector<"]))
            {
                if (typesByName.find(resultType->getName()) == typesByName.end())
                {
                    TGLog(@"***** Type %@ not registered", resultTypeName);
                }
            }
            
            std::shared_ptr<TLMetaConstructor> constructor(new TLMetaConstructor(murMurHash32(method), methodDesc.n_id, fields, resultType));
            constructorsBySignature[constructor->getSignature()] = constructor;
            constructorsByName[constructor->getName()] = constructor;
            
            if (hasUnresolvedTypes)
            {
                constructorsWithUnresolvedTypes.push_back(constructor);
            }
        }
        
        for (std::set<int32_t>::iterator it = typesToResolve.begin(); it != typesToResolve.end(); it++)
        {
            if (typesByName.find(*it) == typesByName.end())
            {
                TGLog(@"***** Failed to resolve type %@", stringForHash(*it));
            }
        }
        
        for (std::vector<std::shared_ptr<TLMetaConstructor> >::iterator it = constructorsWithUnresolvedTypes.begin(); it != constructorsWithUnresolvedTypes.end(); it++)
        {
            std::shared_ptr<std::vector<TLMetaField> > fields = (*it)->getFields();
            for (std::vector<TLMetaField>::iterator fieldIt = fields->begin(); fieldIt != fields->end(); fieldIt++)
            {
                resolveUnboxedTypes(&fieldIt->type, constructorsByName, vectorElementTypesByConstructor);
            }
        }
        
        for (std::unordered_map<int32_t, TLMetaTypeArgument>::iterator it = vectorElementTypesByConstructor.begin(); it != vectorElementTypesByConstructor.end(); it++)
        {
            resolveUnboxedTypes(&it->second, constructorsByName, vectorElementTypesByConstructor);
        }
    }
}

id TLMetaClassStore::constructObject(NSInputStream *is, int32_t signature, id<TLSerializationEnvironment> environment, TLSerializationContext *context, __autoreleasing NSError **error)
{
    TLConstructedValue value = constructValue(is, signature, environment, context, error);
    if (error != nil && *error != nil)
    {
        return nil;
    }
    
    switch (value.type)
    {
        case TLConstructedValueTypeEmpty:
            return nil;
        case TLConstructedValueTypeObject:
            return value.nativeObject;
        case TLConstructedValueTypePrimitiveInt32:
            return [NSNumber numberWithInt:value.primitive.int32Value];
        case TLConstructedValueTypePrimitiveInt64:
            return [NSNumber numberWithLongLong:value.primitive.int64Value];
        case TLConstructedValueTypePrimitiveDouble:
            return [NSNumber numberWithDouble:value.primitive.doubleValue];
        case TLConstructedValueTypePrimitiveBool:
            return [NSNumber numberWithBool:value.primitive.boolValue];
        case TLConstructedValueTypeString:
            return value.nativeObject;
        case TLConstructedValueTypeBytes:
            return value.nativeObject;
        case TLConstructedValueTypeVector:
            return value.nativeObject;
        default:
            break;
    }
    
    return nil;
}

TLConstructedValue TLMetaClassStore::constructValue(NSInputStream *is, int32_t signature, id<TLSerializationEnvironment> environment, TLSerializationContext *context, __autoreleasing NSError **error)
{
    if (signature == 0x3072cfa1) //gzip_packed
    {
        NSData *packedData = [is readBytes];
        NSData *unpackedData = [packedData decompressGZip];
        if (unpackedData == nil)
        {
            if (error != NULL)
            {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setValue:@"Couldn't unpack gzipped data" forKey:NSLocalizedDescriptionKey];
                *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
            }
            return TLConstructedValue();
        }
        
        //TGLog(@"===== Packed / Unpacked: %d / %d kb", packedData.length / 1024, unpackedData.length / 1024);
        
        NSInputStream *unpackedIs = [NSInputStream inputStreamWithData:unpackedData];
        [unpackedIs open];
        int32_t unpackedSignature = [unpackedIs readInt32];
        TLConstructedValue result = constructValue(unpackedIs, unpackedSignature, environment, context, error);
        [unpackedIs close];
        
        return result;
    }
    
    switch (signature)
    {
        case TL_INT32_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypePrimitiveInt32;
            result.primitive.int32Value = [is readInt32];
            return result;
        }
        case TL_INT64_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypePrimitiveInt64;
            result.primitive.int64Value = [is readInt64];
            return result;
        }
        case TL_INT128_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypeBytes;
            NSData *data = [is readData:16];
            result.nativeObject = data;
            return result;
        }
        case TL_INT256_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypeBytes;
            NSData *data = [is readData:32];
            result.nativeObject = data;
            return result;
        }
        case TL_STRING_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypeString;
            NSString *data = [is readString];
            result.nativeObject = data;
            return result;
        }
        case TL_BYTES_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypeBytes;
            NSData *data = [is readBytes];
            result.nativeObject = data;
            return result;
        }
        case TL_DOUBLE_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypePrimitiveDouble;
            result.primitive.doubleValue = [is readDouble];
            return result;
        }
        case TL_BOOL_TRUE_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypePrimitiveBool;
            result.primitive.boolValue = true;
            return result;
        }
        case TL_BOOL_FALSE_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypePrimitiveBool;
            result.primitive.boolValue = false;
            return result;
        }
        case TL_NULL_CONSTRUCTOR:
        {
            TLConstructedValue result;
            result.type = TLConstructedValueTypeObject;
            result.nativeObject = nil;
            return result;
        }
        default:
            break;
    }
    
    if (signature == TL_UNIVERSAL_VECTOR_CONSTRUCTOR)
    {
        if (context != nil)
        {
            if (context.impliedSignature != 0)
                signature = context.impliedSignature;
        }
    }
    
    auto manualIt = manualObjectParsers.find(signature);
    if (manualIt != manualObjectParsers.end())
    {
        id<TLObject> parser = manualIt->second;
        
        id<TLObject> result = [parser TLdeserialize:is signature:signature environment:environment context:nil error:error];
        if (error && *error != nil)
            return TLConstructedValue();
        
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = result;
        
        return value;
    }
    
    std::shared_ptr<TLMetaConstructor> constructor = getConstructorBySignature(signature);
    
    if (constructor == NULL)
    {
        std::unordered_map<int32_t, TLMetaTypeArgument>::iterator it = vectorElementTypesByConstructor.find(signature);
        if (it != vectorElementTypesByConstructor.end())
        {
            int32_t count = [is readInt32];
            
            std::unordered_map<int32_t, id<TLVector> >::iterator classIt = vectorClassesBySignature.find(signature);
            
            NSMutableArray *array = nil;
            if (classIt != vectorClassesBySignature.end())
                array = [classIt->second TLvectorConstruct];
            else
                array = [[NSMutableArray alloc] init];
            
            TLConstructedValue result;
            result.type = TLConstructedValueTypeVector;
            
            for (int32_t i = 0; i < count; i++)
            {
                int itemSignature = 0;
                if (it->second.boxed)
                    itemSignature = [is readInt32];
                else
                    itemSignature = it->second.unboxedConstructorSignature;
                
                TLConstructedValue itemValue = constructValue(is, itemSignature, environment, nil, error);
                if (error != nil && *error != nil)
                {
                    return TLConstructedValue();
                }
                
                id nativeValue = nil;
                
                switch (itemValue.type)
                {
                    case TLConstructedValueTypePrimitiveInt32:
                        nativeValue = [[NSNumber alloc] initWithInt:itemValue.primitive.int32Value];
                        break;
                    case TLConstructedValueTypePrimitiveInt64:
                        nativeValue = [[NSNumber alloc] initWithLongLong:itemValue.primitive.int64Value];
                        break;
                    case TLConstructedValueTypePrimitiveBool:
                        nativeValue = [[NSNumber alloc] initWithBool:itemValue.primitive.boolValue];
                        break;
                    case TLConstructedValueTypePrimitiveDouble:
                        nativeValue = [[NSNumber alloc] initWithDouble:itemValue.primitive.doubleValue];
                        break;
                    case TLConstructedValueTypeObject:
                        nativeValue = itemValue.nativeObject;
                        break;
                    case TLConstructedValueTypeString:
                        nativeValue = itemValue.nativeObject;
                        break;
                    case TLConstructedValueTypeBytes:
                        nativeValue = itemValue.nativeObject;
                        break;
                    case TLConstructedValueTypeVector:
                        nativeValue = itemValue.nativeObject;
                        break;
                    default:
                        break;
                }
                
                if (nativeValue != nil)
                    [array addObject:nativeValue];
            }
            
            result.nativeObject = array;
            
            return result;
        }
        else
        {
            if (error != NULL)
            {
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
      //@throw [[NSException alloc] initWithName:@"tlmetaclassstore" reason:[NSString stringWithFormat:@"Constructor with signature %.8x not found", signature] userInfo:@{}];
#endif
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setValue:[NSString stringWithFormat:@"Constructor with signature %.8x not found", signature] forKey:NSLocalizedDescriptionKey];
                *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
            }
            return TLConstructedValue();
        }
    }
    
    return constructor->construct(is, environment, nil, error);
}

void TLMetaClassStore::serializeObject(NSOutputStream *os, id<TLObject> object, bool boxed)
{
    //TGLog(@"serialize object %@", object);

    if ([object isKindOfClass:[TLBool class]])
    {
        [os writeInt32:[((TLBool *)object) boolValue] ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
    }
    else if ([object TLconstructorSignature] == 0x3072cfa1)
    {
        if (boxed)
            [os writeInt32:[object TLconstructorSignature]];
        [os writeBytes:((TLCompressedObject *)object).compressedData];
    }
    else if ([object isKindOfClass:[TLMsgsAck class]])
    {
        if (boxed)
            [os writeInt32:[object TLconstructorSignature]];
        
        std::shared_ptr<TLMetaConstructor> constructor = getConstructorByName([object TLconstructorName]);
        
        std::map<int32_t, TLConstructedValue> fieldValues;
        [object TLfillFieldsWithValues:&fieldValues];
        
        std::vector<TLMetaField>::iterator fieldsEnd = constructor->fields->end();
        for (std::vector<TLMetaField>::iterator it = constructor->fields->begin(); it != fieldsEnd; it++)
        {
            std::map<int32_t, TLConstructedValue>::iterator fieldIt = fieldValues.find(it->name);
            
            if (it->type.boxed)
            {
                [os writeInt32:it->type.unboxedConstructorSignature];
            }
            
            NSArray *array = fieldIt->second.nativeObject;
            [os writeInt32:(int32_t)array.count];
            
            for (id item in array)
            {
                [os writeInt64:[item longLongValue]];
            }
        }
    }
    else
    {
        if ([object TLconstructorName] == -1)
        {
            if (boxed)
                [os writeInt32:[object TLconstructorSignature]];
            [object TLserialize:os];
        }
        else
        {
            std::shared_ptr<TLMetaConstructor> constructor = getConstructorByName([object TLconstructorName]);
            if (constructor != NULL)
            {
                if (boxed)
                    [os writeInt32:constructor->getSignature()];
                constructor->serialize(os, object);
            }
            else
            {
                TGLog(@"***** Constructor with name %.8x not found", [object TLconstructorName]);
                if (boxed)
                    [os writeInt32:TL_NULL_CONSTRUCTOR];
            }
        }
    }
}
