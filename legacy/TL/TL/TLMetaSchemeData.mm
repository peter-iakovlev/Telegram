#import "TLMetaSchemeData.h"

TLScheme *TLgetMetaScheme()
{
    NSMutableArray *TLmetaSchemeTypes = [[NSMutableArray alloc] init];
    NSMutableArray *TLmetaSchemeMethods = [[NSMutableArray alloc] init];
    {
        //TLPage$pagePart
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8e3f9ebe;
        constructor.predicate = @"pagePart";
        constructor.type = @"Page";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocks";
            arg.type = @"Vector<PageBlock>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photos";
            arg.type = @"Vector<Photo>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"documents";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPage$pageFull
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x556ec7aa;
        constructor.predicate = @"pageFull";
        constructor.type = @"Page";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocks";
            arg.type = @"Vector<PageBlock>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photos";
            arg.type = @"Vector<Photo>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"documents";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNewSession$new_session_created
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9ec20908;
        constructor.predicate = @"new_session_created";
        constructor.type = @"NewSession";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unique_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_salt";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_Difference$updates_differenceEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5d75a138;
        constructor.predicate = @"updates.differenceEmpty";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_Difference$updates_difference
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf49ca0;
        constructor.predicate = @"updates.difference";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_encrypted_messages";
            arg.type = @"Vector<EncryptedMessage>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"other_updates";
            arg.type = @"Vector<Update>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"state";
            arg.type = @"updates.State";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_Difference$updates_differenceSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa8fb1981;
        constructor.predicate = @"updates.differenceSlice";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_encrypted_messages";
            arg.type = @"Vector<EncryptedMessage>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"other_updates";
            arg.type = @"Vector<Update>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"intermediate_state";
            arg.type = @"updates.State";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_Difference$updates_differenceTooLong
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4afe8f6d;
        constructor.predicate = @"updates.differenceTooLong";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPhoto$inputPhotoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1cd7bf0d;
        constructor.predicate = @"inputPhotoEmpty";
        constructor.type = @"InputPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPhoto$inputPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfb95c6c4;
        constructor.predicate = @"inputPhoto";
        constructor.type = @"InputPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeer$peerUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9db1bc6d;
        constructor.predicate = @"peerUser";
        constructor.type = @"Peer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeer$peerChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbad0e5bb;
        constructor.predicate = @"peerChat";
        constructor.type = @"Peer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeer$peerChannel
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbddde532;
        constructor.predicate = @"peerChannel";
        constructor.type = @"Peer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDataJSON$dataJSON
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7d748d04;
        constructor.predicate = @"dataJSON";
        constructor.type = @"DataJSON";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputUser$inputUserEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb98886cf;
        constructor.predicate = @"inputUserEmpty";
        constructor.type = @"InputUser";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputUser$inputUserSelf
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf7c1b13f;
        constructor.predicate = @"inputUserSelf";
        constructor.type = @"InputUser";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputUser$inputUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd8292816;
        constructor.predicate = @"inputUser";
        constructor.type = @"InputUser";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLHighScore$highScore
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x58fffcd0;
        constructor.predicate = @"highScore";
        constructor.type = @"HighScore";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pos";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"score";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfoMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3cfc7e35;
        constructor.predicate = @"payments.validatedRequestedInfoMeta";
        constructor.type = @"payments.ValidatedRequestedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"shipping_options";
            arg.type = @"Vector<ShippingOption>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageTypingAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x16bf744e;
        constructor.predicate = @"sendMessageTypingAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageCancelAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfd5ec8f5;
        constructor.predicate = @"sendMessageCancelAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageRecordVideoAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa187d66f;
        constructor.predicate = @"sendMessageRecordVideoAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageRecordAudioAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd52f73f7;
        constructor.predicate = @"sendMessageRecordAudioAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageGeoLocationAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x176f8ba1;
        constructor.predicate = @"sendMessageGeoLocationAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageChooseContactAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x628cbc6f;
        constructor.predicate = @"sendMessageChooseContactAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadVideoAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9763aec;
        constructor.predicate = @"sendMessageUploadVideoAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"progress";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadAudioAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf351d7ab;
        constructor.predicate = @"sendMessageUploadAudioAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"progress";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadDocumentAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaa0cd9e4;
        constructor.predicate = @"sendMessageUploadDocumentAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"progress";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadPhotoAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd1d34a26;
        constructor.predicate = @"sendMessageUploadPhotoAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"progress";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageGamePlayAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdd6a8f48;
        constructor.predicate = @"sendMessageGamePlayAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageGameStopAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15c2c99a;
        constructor.predicate = @"sendMessageGameStopAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageRecordRoundAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x88f27fbc;
        constructor.predicate = @"sendMessageRecordRoundAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadRoundAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x243e1c66;
        constructor.predicate = @"sendMessageUploadRoundAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"progress";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_FeaturedStickers$messages_featuredStickersNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4ede3cf;
        constructor.predicate = @"messages.featuredStickersNotModified";
        constructor.type = @"messages.FeaturedStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_FeaturedStickers$messages_featuredStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf89d88e5;
        constructor.predicate = @"messages.featuredStickers";
        constructor.type = @"messages.FeaturedStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sets";
            arg.type = @"Vector<StickerSetCovered>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unread";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPong$pong
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x347773c5;
        constructor.predicate = @"pong";
        constructor.type = @"Pong";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ping_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputFileLocation$inputFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x14637196;
        constructor.predicate = @"inputFileLocation";
        constructor.type = @"InputFileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"volume_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"local_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"secret";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputFileLocation$inputEncryptedFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf5235d55;
        constructor.predicate = @"inputEncryptedFileLocation";
        constructor.type = @"InputFileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputFileLocation$inputDocumentFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x430f0724;
        constructor.predicate = @"inputDocumentFileLocation";
        constructor.type = @"InputFileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLImportedContact$importedContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd0028438;
        constructor.predicate = @"importedContact";
        constructor.type = @"ImportedContact";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"client_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoto$photoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2331b22d;
        constructor.predicate = @"photoEmpty";
        constructor.type = @"Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoto$wallPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x559dc1e2;
        constructor.predicate = @"wallPhoto";
        constructor.type = @"Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo";
            arg.type = @"GeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unread";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sizes";
            arg.type = @"Vector<PhotoSize>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoto$photo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9288dd29;
        constructor.predicate = @"photo";
        constructor.type = @"Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sizes";
            arg.type = @"Vector<PhotoSize>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDestroySessionsRes$destroy_sessions_res
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfb95abcd;
        constructor.predicate = @"destroy_sessions_res";
        constructor.type = @"DestroySessionsRes";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"destroy_results";
            arg.type = @"vector<DestroySessionRes>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBadMsgNotification$bad_msg_notification
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa7eff811;
        constructor.predicate = @"bad_msg_notification";
        constructor.type = @"BadMsgNotification";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bad_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bad_msg_seqno";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"error_code";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBadMsgNotification$bad_server_salt
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xedab447b;
        constructor.predicate = @"bad_server_salt";
        constructor.type = @"BadMsgNotification";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bad_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bad_msg_seqno";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"error_code";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_server_salt";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_AffectedHistory$messages_affectedHistory
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb45c69d1;
        constructor.predicate = @"messages.affectedHistory";
        constructor.type = @"messages.AffectedHistory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputEncryptedChat$inputEncryptedChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf141b5e1;
        constructor.predicate = @"inputEncryptedChat";
        constructor.type = @"InputEncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPhoneCall$inputPhoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1e36fded;
        constructor.predicate = @"inputPhoneCall";
        constructor.type = @"InputPhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgResendReq$msg_resend_req
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7d861a08;
        constructor.predicate = @"msg_resend_req";
        constructor.type = @"MsgResendReq";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_ids";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputWebFileLocation$inputWebFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc239d686;
        constructor.predicate = @"inputWebFileLocation";
        constructor.type = @"InputWebFileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputWebDocument$inputWebDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9bed434d;
        constructor.predicate = @"inputWebDocument";
        constructor.type = @"InputWebDocument";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"attributes";
            arg.type = @"Vector<DocumentAttribute>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Link$contacts_link
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3ace484c;
        constructor.predicate = @"contacts.link";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"my_link";
            arg.type = @"ContactLink";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"foreign_link";
            arg.type = @"ContactLink";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user";
            arg.type = @"User";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputEncryptedFile$inputEncryptedFileEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1837c364;
        constructor.predicate = @"inputEncryptedFileEmpty";
        constructor.type = @"InputEncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputEncryptedFile$inputEncryptedFileUploaded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x64bd0306;
        constructor.predicate = @"inputEncryptedFileUploaded";
        constructor.type = @"InputEncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"parts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"md5_checksum";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputEncryptedFile$inputEncryptedFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5a17b5e5;
        constructor.predicate = @"inputEncryptedFile";
        constructor.type = @"InputEncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputEncryptedFile$inputEncryptedFileBigUploaded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2dc173c8;
        constructor.predicate = @"inputEncryptedFileBigUploaded";
        constructor.type = @"InputEncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"parts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_PaymentForm$payments_paymentFormMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf82b6dc0;
        constructor.predicate = @"payments.paymentFormMeta";
        constructor.type = @"payments.PaymentForm";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bot_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"invoice";
            arg.type = @"Invoice";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"provider_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"native_provider";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"native_params";
            arg.type = @"DataJSON";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"saved_info";
            arg.type = @"PaymentRequestedInfo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"saved_credentials";
            arg.type = @"PaymentSavedCredentials";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgsStateInfo$msgs_state_info
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4deb57d;
        constructor.predicate = @"msgs_state_info";
        constructor.type = @"MsgsStateInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"req_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"info";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWallPaper$wallPaper
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xccb03657;
        constructor.predicate = @"wallPaper";
        constructor.type = @"WallPaper";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sizes";
            arg.type = @"Vector<PhotoSize>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"color";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWallPaper$wallPaperSolid
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x63117f24;
        constructor.predicate = @"wallPaperSolid";
        constructor.type = @"WallPaper";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bg_color";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"color";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLServer_DH_inner_data$server_DH_inner_data
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb5890dba;
        constructor.predicate = @"server_DH_inner_data";
        constructor.type = @"Server_DH_inner_data";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dh_prime";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_time";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLProtoMessage$protoMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5bb8e511;
        constructor.predicate = @"protoMessage";
        constructor.type = @"ProtoMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seqno";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"body";
            arg.type = @"Object";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChatPhoto$inputChatPhotoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1ca48f57;
        constructor.predicate = @"inputChatPhotoEmpty";
        constructor.type = @"InputChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChatPhoto$inputChatUploadedPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x927c55b4;
        constructor.predicate = @"inputChatUploadedPhoto";
        constructor.type = @"InputChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChatPhoto$inputChatPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8953ad37;
        constructor.predicate = @"inputChatPhoto";
        constructor.type = @"InputChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoto";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateMessageID
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4e90bfd6;
        constructor.predicate = @"updateMessageID";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateRestoreMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd15de04d;
        constructor.predicate = @"updateRestoreMessages";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatParticipants
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7761198;
        constructor.predicate = @"updateChatParticipants";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants";
            arg.type = @"ChatParticipants";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserStatus
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1bfbd823;
        constructor.predicate = @"updateUserStatus";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"status";
            arg.type = @"UserStatus";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateContactRegistered
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2575bbb9;
        constructor.predicate = @"updateContactRegistered";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateContactLocated
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5f83b963;
        constructor.predicate = @"updateContactLocated";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contacts";
            arg.type = @"Vector<ContactLocated>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateActivation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6f690963;
        constructor.predicate = @"updateActivation";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePhoneCallRequested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdad7490e;
        constructor.predicate = @"updatePhoneCallRequested";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_call";
            arg.type = @"PhoneCall";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePhoneCallConfirmed
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5609ff88;
        constructor.predicate = @"updatePhoneCallConfirmed";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"a_or_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"connection";
            arg.type = @"PhoneConnection";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePhoneCallDeclined
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x31ae2cc2;
        constructor.predicate = @"updatePhoneCallDeclined";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x95313b0c;
        constructor.predicate = @"updateUserPhoto";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"UserProfilePhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"previous";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateNewEncryptedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x12bcbd9a;
        constructor.predicate = @"updateNewEncryptedMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"EncryptedMessage";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"qts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateEncryptedChatTyping
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1710f156;
        constructor.predicate = @"updateEncryptedChatTyping";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateEncryption
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb4a2e88d;
        constructor.predicate = @"updateEncryption";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat";
            arg.type = @"EncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateEncryptedMessagesRead
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x38fe25b7;
        constructor.predicate = @"updateEncryptedMessagesRead";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatParticipantDelete
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6e5f8c22;
        constructor.predicate = @"updateChatParticipantDelete";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateDcOptions
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8e5e9873;
        constructor.predicate = @"updateDcOptions";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_options";
            arg.type = @"Vector<DcOption>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserBlocked
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x80ece81a;
        constructor.predicate = @"updateUserBlocked";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocked";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateNotifySettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbec268ef;
        constructor.predicate = @"updateNotifySettings";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"NotifyPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"notify_settings";
            arg.type = @"PeerNotifySettings";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserTyping
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5c486927;
        constructor.predicate = @"updateUserTyping";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"action";
            arg.type = @"SendMessageAction";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatUserTyping
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9a65ea1f;
        constructor.predicate = @"updateChatUserTyping";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"action";
            arg.type = @"SendMessageAction";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa7332b73;
        constructor.predicate = @"updateUserName";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePrivacy
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xee3b272a;
        constructor.predicate = @"updatePrivacy";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"PrivacyKey";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rules";
            arg.type = @"Vector<PrivacyRule>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateUserPhone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x12b9417b;
        constructor.predicate = @"updateUserPhone";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateNewMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1f2b0afd;
        constructor.predicate = @"updateNewMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateDeleteMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa20db0e5;
        constructor.predicate = @"updateDeleteMessages";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadHistoryInbox
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9961fd5c;
        constructor.predicate = @"updateReadHistoryInbox";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadHistoryOutbox
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2f2f21bf;
        constructor.predicate = @"updateReadHistoryOutbox";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateContactLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9d2e67c5;
        constructor.predicate = @"updateContactLink";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"my_link";
            arg.type = @"ContactLink";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"foreign_link";
            arg.type = @"ContactLink";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadMessagesContents
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x68c13933;
        constructor.predicate = @"updateReadMessagesContents";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatParticipantAdd
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xea4b0e5c;
        constructor.predicate = @"updateChatParticipantAdd";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateWebPage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7f891213;
        constructor.predicate = @"updateWebPage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"webpage";
            arg.type = @"WebPage";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannel
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb6d45656;
        constructor.predicate = @"updateChannel";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannelGroup
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc36c1e3c;
        constructor.predicate = @"updateChannelGroup";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"group";
            arg.type = @"MessageGroup";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateNewChannelMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x62ba04d9;
        constructor.predicate = @"updateNewChannelMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadChannelInbox
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4214f37f;
        constructor.predicate = @"updateReadChannelInbox";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateDeleteChannelMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc37521c9;
        constructor.predicate = @"updateDeleteChannelMessages";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannelMessageViews
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x98a12b4b;
        constructor.predicate = @"updateChannelMessageViews";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"views";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatAdmins
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6e947941;
        constructor.predicate = @"updateChatAdmins";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChatParticipantAdmin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb6901959;
        constructor.predicate = @"updateChatParticipantAdmin";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"is_admin";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateNewStickerSet
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x688a30aa;
        constructor.predicate = @"updateNewStickerSet";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickerset";
            arg.type = @"messages.StickerSet";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateStickerSets
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x43ae3dec;
        constructor.predicate = @"updateStickerSets";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateSavedGifs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9375341e;
        constructor.predicate = @"updateSavedGifs";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateEditChannelMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1b3f4df7;
        constructor.predicate = @"updateEditChannelMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannelPinnedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x98592475;
        constructor.predicate = @"updateChannelPinnedMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannelTooLongMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe17a8fe;
        constructor.predicate = @"updateChannelTooLongMeta";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateEditMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe40370a3;
        constructor.predicate = @"updateEditMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadChannelOutbox
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x25d6c9c7;
        constructor.predicate = @"updateReadChannelOutbox";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateDraftMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xee2bb969;
        constructor.predicate = @"updateDraftMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"draft";
            arg.type = @"DraftMessage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateReadFeaturedStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x571d2742;
        constructor.predicate = @"updateReadFeaturedStickers";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateRecentStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9a422c20;
        constructor.predicate = @"updateRecentStickers";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateConfig
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa229dd06;
        constructor.predicate = @"updateConfig";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePtsChanged
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3354678f;
        constructor.predicate = @"updatePtsChanged";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateStickerSetsOrder
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbb2d201;
        constructor.predicate = @"updateStickerSetsOrder";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"order";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateChannelWebPage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40771900;
        constructor.predicate = @"updateChannelWebPage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"webpage";
            arg.type = @"WebPage";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateServiceNotificationMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15b5ccd3;
        constructor.predicate = @"updateServiceNotificationMeta";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inbox_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"MessageMedia";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"entities";
            arg.type = @"Vector<MessageEntity>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePhoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xab0f6b1e;
        constructor.predicate = @"updatePhoneCall";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_call";
            arg.type = @"PhoneCall";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateDialogPinned
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd711a2cc;
        constructor.predicate = @"updateDialogPinned";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updatePinnedDialogsMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8a78e15b;
        constructor.predicate = @"updatePinnedDialogsMeta";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"order";
            arg.type = @"Vector<Peer>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateLangPackTooLong
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x10c2404b;
        constructor.predicate = @"updateLangPackTooLong";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateLangPack
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x56022f4d;
        constructor.predicate = @"updateLangPack";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"difference";
            arg.type = @"LangPackDifference";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdate$updateLangPackLanguageSuggested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe99a0a35;
        constructor.predicate = @"updateLangPackLanguageSuggested";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"language";
            arg.type = @"LangPackLanguage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBotInlineMessage$botInlineMessageMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7303dd9c;
        constructor.predicate = @"botInlineMessageMeta";
        constructor.type = @"BotInlineMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLFileLocation$fileLocationUnavailable
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7c596b46;
        constructor.predicate = @"fileLocationUnavailable";
        constructor.type = @"FileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"volume_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"local_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"secret";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLFileLocation$fileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x53d69076;
        constructor.predicate = @"fileLocation";
        constructor.type = @"FileLocation";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"volume_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"local_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"secret";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLExportedChatInvite$chatInviteEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x69df3769;
        constructor.predicate = @"chatInviteEmpty";
        constructor.type = @"ExportedChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLExportedChatInvite$chatInviteExported
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfc2e05bc;
        constructor.predicate = @"chatInviteExported";
        constructor.type = @"ExportedChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"link";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDcNetworkStats$dcPingStats
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3203df8c;
        constructor.predicate = @"dcPingStats";
        constructor.type = @"DcNetworkStats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ip_address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pings";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRpcError$rpc_error
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2144ca19;
        constructor.predicate = @"rpc_error";
        constructor.type = @"RpcError";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"error_code";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"error_message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessage$messageEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x83e5de54;
        constructor.predicate = @"messageEmpty";
        constructor.type = @"Message";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessage$message
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x567699b3;
        constructor.predicate = @"message";
        constructor.type = @"Message";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"to_id";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"MessageMedia";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessage$messageMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6c07448;
        constructor.predicate = @"messageMeta";
        constructor.type = @"Message";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"to_id";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"fwd_from";
            arg.type = @"MessageFwdHeader";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"via_bot_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reply_to_msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"MessageMedia";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reply_markup";
            arg.type = @"ReplyMarkup";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"entities";
            arg.type = @"Vector<MessageEntity>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"views";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"edit_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"post_author";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_PaymentReceipt$payments_paymentReceiptMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5f1794be;
        constructor.predicate = @"payments.paymentReceiptMeta";
        constructor.type = @"payments.PaymentReceipt";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bot_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"invoice";
            arg.type = @"Invoice";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"provider_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"info";
            arg.type = @"PaymentRequestedInfo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"shipping";
            arg.type = @"ShippingOption";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"currency";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"total_amount";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"credentials_title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatParticipants$chatParticipants
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3f460fed;
        constructor.predicate = @"chatParticipants";
        constructor.type = @"ChatParticipants";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants";
            arg.type = @"Vector<ChatParticipant>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputNotifyPeer$inputNotifyPeer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb8bc5b0c;
        constructor.predicate = @"inputNotifyPeer";
        constructor.type = @"InputNotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputNotifyPeer$inputNotifyUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x193b4417;
        constructor.predicate = @"inputNotifyUsers";
        constructor.type = @"InputNotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputNotifyPeer$inputNotifyChats
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4a95e84e;
        constructor.predicate = @"inputNotifyChats";
        constructor.type = @"InputNotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputNotifyPeer$inputNotifyAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa429b886;
        constructor.predicate = @"inputNotifyAll";
        constructor.type = @"InputNotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLClient_DH_Inner_Data$client_DH_inner_data
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6643b654;
        constructor.predicate = @"client_DH_inner_data";
        constructor.type = @"Client_DH_Inner_Data";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"retry_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Blocked$contacts_blocked
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1c138d15;
        constructor.predicate = @"contacts.blocked";
        constructor.type = @"contacts.Blocked";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocked";
            arg.type = @"Vector<ContactBlocked>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Blocked$contacts_blockedSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x900802a1;
        constructor.predicate = @"contacts.blockedSlice";
        constructor.type = @"contacts.Blocked";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocked";
            arg.type = @"Vector<ContactBlocked>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLProtoMessageCopy$msg_copy
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe06046b2;
        constructor.predicate = @"msg_copy";
        constructor.type = @"ProtoMessageCopy";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"orig_message";
            arg.type = @"ProtoMessage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGlobalPrivacySettings$globalPrivacySettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40f5c53a;
        constructor.predicate = @"globalPrivacySettings";
        constructor.type = @"GlobalPrivacySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"no_suggestions";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hide_contacts";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hide_located";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hide_last_visit";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_DhConfig$messages_dhConfigNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc0e24635;
        constructor.predicate = @"messages.dhConfigNotModified";
        constructor.type = @"messages.DhConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_DhConfig$messages_dhConfig
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2c221edd;
        constructor.predicate = @"messages.dhConfig";
        constructor.type = @"messages.DhConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"p";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatInvite$chatInviteAlready
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5a686d7c;
        constructor.predicate = @"chatInviteAlready";
        constructor.type = @"ChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat";
            arg.type = @"Chat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatInvite$chatInviteMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7b4b5b37;
        constructor.predicate = @"chatInviteMeta";
        constructor.type = @"ChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"ChatPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageRange$messageRange
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xae30253;
        constructor.predicate = @"messageRange";
        constructor.type = @"MessageRange";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputBotInlineResult$inputBotInlineResultGame
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4fa417f2;
        constructor.predicate = @"inputBotInlineResultGame";
        constructor.type = @"InputBotInlineResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"short_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"send_message";
            arg.type = @"InputBotInlineMessage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_AllStickers$messages_allStickersNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe86602c3;
        constructor.predicate = @"messages.allStickersNotModified";
        constructor.type = @"messages.AllStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_AllStickers$messages_allStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xedfd405f;
        constructor.predicate = @"messages.allStickers";
        constructor.type = @"messages.AllStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sets";
            arg.type = @"Vector<StickerSet>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocument$documentEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x36f8c871;
        constructor.predicate = @"documentEmpty";
        constructor.type = @"Document";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocument$document
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x87232bc7;
        constructor.predicate = @"document";
        constructor.type = @"Document";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"thumb";
            arg.type = @"PhotoSize";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"attributes";
            arg.type = @"Vector<DocumentAttribute>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLConfig$configMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5f688205;
        constructor.predicate = @"configMeta";
        constructor.type = @"Config";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"expires";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"test_mode";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"this_dc";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_options";
            arg.type = @"Vector<DcOption>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_size_max";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"megagroup_size_max";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"forwarded_count_max";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"online_update_period_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offline_blur_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offline_idle_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"online_cloud_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"notify_cloud_delay_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"notify_default_delay_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_big_size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"push_chat_period_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"push_chat_limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"saved_gifs_limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"edit_time_limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rating_e_decay";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickers_recent_limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"tmp_sessions";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pinned_dialogs_count_max";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"call_receive_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"call_ring_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"call_connect_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"call_packet_timeout_ms";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"me_url_prefix";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"suggested_lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_pack_version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"disabled_features";
            arg.type = @"Vector<DisabledFeature>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x57e2f66c;
        constructor.predicate = @"inputMessagesFilterEmpty";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterPhotos
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9609a51c;
        constructor.predicate = @"inputMessagesFilterPhotos";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9fc00e65;
        constructor.predicate = @"inputMessagesFilterVideo";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterPhotoVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x56e9f0e4;
        constructor.predicate = @"inputMessagesFilterPhotoVideo";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9eddf188;
        constructor.predicate = @"inputMessagesFilterDocument";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterPhotoVideoDocuments
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd95e73bb;
        constructor.predicate = @"inputMessagesFilterPhotoVideoDocuments";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterUrl
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7ef0dd87;
        constructor.predicate = @"inputMessagesFilterUrl";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterVoice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x50f5c392;
        constructor.predicate = @"inputMessagesFilterVoice";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterMusic
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3751b49e;
        constructor.predicate = @"inputMessagesFilterMusic";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterChatPhotos
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3a20ecb8;
        constructor.predicate = @"inputMessagesFilterChatPhotos";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterPhoneCalls
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x80c99768;
        constructor.predicate = @"inputMessagesFilterPhoneCalls";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterRoundVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb549da53;
        constructor.predicate = @"inputMessagesFilterRoundVideo";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessagesFilter$inputMessagesFilterRoundVoice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7a7c17a4;
        constructor.predicate = @"inputMessagesFilterRoundVoice";
        constructor.type = @"MessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Found$contacts_found
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1aa1f784;
        constructor.predicate = @"contacts.found";
        constructor.type = @"contacts.Found";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<Peer>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_HighScores$messages_highScores
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9a3bfd99;
        constructor.predicate = @"messages.highScores";
        constructor.type = @"messages.HighScores";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"scores";
            arg.type = @"Vector<HighScore>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_Authorization$auth_authorizationMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb1937d19;
        constructor.predicate = @"auth.authorizationMeta";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"tmp_sessions";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user";
            arg.type = @"User";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReportReason$inputReportReasonSpam
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x58dbcab8;
        constructor.predicate = @"inputReportReasonSpam";
        constructor.type = @"ReportReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReportReason$inputReportReasonViolence
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1e22c78d;
        constructor.predicate = @"inputReportReasonViolence";
        constructor.type = @"ReportReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReportReason$inputReportReasonPornography
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2e59d922;
        constructor.predicate = @"inputReportReasonPornography";
        constructor.type = @"ReportReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReportReason$inputReportReasonOther
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe1746d0a;
        constructor.predicate = @"inputReportReasonOther";
        constructor.type = @"ReportReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_StickerSet$messages_stickerSet
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb60a24a6;
        constructor.predicate = @"messages.stickerSet";
        constructor.type = @"messages.StickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"set";
            arg.type = @"StickerSet";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"packs";
            arg.type = @"Vector<StickerPack>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"documents";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactStatus$contactStatus
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd3680c61;
        constructor.predicate = @"contactStatus";
        constructor.type = @"ContactStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"status";
            arg.type = @"UserStatus";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9664f57f;
        constructor.predicate = @"inputMediaEmpty";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaGeoPoint
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf9c44144;
        constructor.predicate = @"inputMediaGeoPoint";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa6e45987;
        constructor.predicate = @"inputMediaContact";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9bfb4f3;
        constructor.predicate = @"inputMediaPhoto";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaVenue
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2827a81a;
        constructor.predicate = @"inputMediaVenue";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"provider";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"venue_id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaGifExternal
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4843b0fd;
        constructor.predicate = @"inputMediaGifExternal";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1a77f29c;
        constructor.predicate = @"inputMediaDocument";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputDocument";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaPhotoExternal
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3b7c62be;
        constructor.predicate = @"inputMediaPhotoExternal";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaDocumentExternal
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7477f92c;
        constructor.predicate = @"inputMediaDocumentExternal";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaGame
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd33f43f3;
        constructor.predicate = @"inputMediaGame";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputGame";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedPhotoMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xafdcd7e0;
        constructor.predicate = @"inputMediaUploadedPhotoMeta";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickers";
            arg.type = @"Vector<InputDocument>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ttl_seconds";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedDocumentMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf285c726;
        constructor.predicate = @"inputMediaUploadedDocumentMeta";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"thumb";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"attributes";
            arg.type = @"Vector<DocumentAttribute>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickers";
            arg.type = @"Vector<InputDocument>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ttl_seconds";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdc3d824f;
        constructor.predicate = @"textEmpty";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textPlain
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x744694e0;
        constructor.predicate = @"textPlain";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textBold
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6724abc4;
        constructor.predicate = @"textBold";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textItalic
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd912a59c;
        constructor.predicate = @"textItalic";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textUnderline
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc12622c4;
        constructor.predicate = @"textUnderline";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textStrike
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9bf8bb95;
        constructor.predicate = @"textStrike";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textFixed
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6c3f19b9;
        constructor.predicate = @"textFixed";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textUrl
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3c2884c1;
        constructor.predicate = @"textUrl";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"webpage_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textEmail
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xde5a0dd6;
        constructor.predicate = @"textEmail";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRichText$textConcat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7e6260d7;
        constructor.predicate = @"textConcat";
        constructor.type = @"RichText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"texts";
            arg.type = @"Vector<RichText>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelBannedRights$channelBannedRights
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x58cf4249;
        constructor.predicate = @"channelBannedRights";
        constructor.type = @"ChannelBannedRights";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"until_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLShippingOption$shippingOption
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb6213cdf;
        constructor.predicate = @"shippingOption";
        constructor.type = @"ShippingOption";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prices";
            arg.type = @"Vector<LabeledPrice>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReceivedNotifyMessage$receivedNotifyMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa384b779;
        constructor.predicate = @"receivedNotifyMessage";
        constructor.type = @"ReceivedNotifyMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGame$gameMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6c3a219d;
        constructor.predicate = @"gameMeta";
        constructor.type = @"Game";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"short_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"document";
            arg.type = @"Document";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserFull$userFullMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x47677fb2;
        constructor.predicate = @"userFullMeta";
        constructor.type = @"UserFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x560f8935;
        constructor.predicate = @"messages.sentEncryptedMessage";
        constructor.type = @"messages.SentEncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_SentEncryptedMessage$messages_sentEncryptedFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9493ff32;
        constructor.predicate = @"messages.sentEncryptedFile";
        constructor.type = @"messages.SentEncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"EncryptedFile";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDialog$dialogMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x96518a23;
        constructor.predicate = @"dialogMeta";
        constructor.type = @"Dialog";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"top_message";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"read_inbox_max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"read_outbox_max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unread_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"notify_settings";
            arg.type = @"PeerNotifySettings";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"draft";
            arg.type = @"DraftMessage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCodeType$auth_sentCodeTypeApp
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3dbb5986;
        constructor.predicate = @"auth.sentCodeTypeApp";
        constructor.type = @"auth.SentCodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCodeType$auth_sentCodeTypeSms
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc000bba2;
        constructor.predicate = @"auth.sentCodeTypeSms";
        constructor.type = @"auth.SentCodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCodeType$auth_sentCodeTypeCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5353e5a7;
        constructor.predicate = @"auth.sentCodeTypeCall";
        constructor.type = @"auth.SentCodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCodeType$auth_sentCodeTypeFlashCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xab03c6d9;
        constructor.predicate = @"auth.sentCodeTypeFlashCall";
        constructor.type = @"auth.SentCodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pattern";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChat$chatEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9ba2d800;
        constructor.predicate = @"chatEmpty";
        constructor.type = @"Chat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChat$chatForbidden
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7328bdb;
        constructor.predicate = @"chatForbidden";
        constructor.type = @"Chat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChat$channelMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb3d78daf;
        constructor.predicate = @"channelMeta";
        constructor.type = @"Chat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"ChatPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"restriction_reason";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_rights";
            arg.type = @"ChannelAdminRights";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChat$channelForbiddenMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5f7c81c5;
        constructor.predicate = @"channelForbiddenMeta";
        constructor.type = @"Chat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"until_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactRequest$contactRequest
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x59f24214;
        constructor.predicate = @"contactRequest";
        constructor.type = @"ContactRequest";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLCdnFileHash$cdnFileHash
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77eec38f;
        constructor.predicate = @"cdnFileHash";
        constructor.type = @"CdnFileHash";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLangPackDifference$langPackDifference
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf385c1f6;
        constructor.predicate = @"langPackDifference";
        constructor.type = @"LangPackDifference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"strings";
            arg.type = @"Vector<LangPackString>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_PrivacyRules$account_privacyRules
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x554abb6f;
        constructor.predicate = @"account.privacyRules";
        constructor.type = @"account.PrivacyRules";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rules";
            arg.type = @"Vector<PrivacyRule>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_TermsOfService$help_termsOfService
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf1ee3e90;
        constructor.predicate = @"help.termsOfService";
        constructor.type = @"help.TermsOfService";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSet_client_DH_params_answer$dh_gen_ok
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3bcbf734;
        constructor.predicate = @"dh_gen_ok";
        constructor.type = @"Set_client_DH_params_answer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_nonce_hash1";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSet_client_DH_params_answer$dh_gen_retry
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x46dc1fb9;
        constructor.predicate = @"dh_gen_retry";
        constructor.type = @"Set_client_DH_params_answer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_nonce_hash2";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSet_client_DH_params_answer$dh_gen_fail
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa69dae02;
        constructor.predicate = @"dh_gen_fail";
        constructor.type = @"Set_client_DH_params_answer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_nonce_hash3";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReplyMarkup$replyKeyboardHide
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa03e5b85;
        constructor.predicate = @"replyKeyboardHide";
        constructor.type = @"ReplyMarkup";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReplyMarkup$replyKeyboardForceReply
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf4108aa0;
        constructor.predicate = @"replyKeyboardForceReply";
        constructor.type = @"ReplyMarkup";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReplyMarkup$replyKeyboardMarkup
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3502758c;
        constructor.predicate = @"replyKeyboardMarkup";
        constructor.type = @"ReplyMarkup";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rows";
            arg.type = @"Vector<KeyboardButtonRow>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLReplyMarkup$replyInlineMarkup
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x48a30254;
        constructor.predicate = @"replyInlineMarkup";
        constructor.type = @"ReplyMarkup";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rows";
            arg.type = @"Vector<KeyboardButtonRow>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLangPackLanguage$langPackLanguage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x117698f1;
        constructor.predicate = @"langPackLanguage";
        constructor.type = @"LangPackLanguage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"native_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMaskCoords$maskCoords
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaed6dbb2;
        constructor.predicate = @"maskCoords";
        constructor.type = @"MaskCoords";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"x";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"y";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"zoom";
            arg.type = @"double";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_MessageEditData$messages_messageEditData
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x26b5dde6;
        constructor.predicate = @"messages.messageEditData";
        constructor.type = @"messages.MessageEditData";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCode$auth_sentCodeMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9e7cd5b6;
        constructor.predicate = @"auth.sentCodeMeta";
        constructor.type = @"auth.SentCode";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLCdnPublicKey$cdnPublicKey
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc982eaba;
        constructor.predicate = @"cdnPublicKey";
        constructor.type = @"CdnPublicKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"public_key";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactBlocked$contactBlocked
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x561bc879;
        constructor.predicate = @"contactBlocked";
        constructor.type = @"ContactBlocked";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageFwdHeader$messageFwdHeaderMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xba3903bf;
        constructor.predicate = @"messageFwdHeaderMeta";
        constructor.type = @"MessageFwdHeader";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_post";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"post_author";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_MyLink$contacts_myLinkEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd22a1c60;
        constructor.predicate = @"contacts.myLinkEmpty";
        constructor.type = @"contacts.MyLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_MyLink$contacts_myLinkRequested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6c69efee;
        constructor.predicate = @"contacts.myLinkRequested";
        constructor.type = @"contacts.MyLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contact";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_MyLink$contacts_myLinkContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc240ebd9;
        constructor.predicate = @"contacts.myLinkContact";
        constructor.type = @"contacts.MyLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_ChannelDifference$updates_channelDifferenceMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x47ddefe6;
        constructor.predicate = @"updates.channelDifferenceMeta";
        constructor.type = @"updates.ChannelDifference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphone_DhConfig$phone_dhConfig
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8a5d855e;
        constructor.predicate = @"phone.dhConfig";
        constructor.type = @"phone.DhConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"p";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ring_timeout";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"expires";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputStickeredMedia$inputStickeredMediaPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4a992157;
        constructor.predicate = @"inputStickeredMediaPhoto";
        constructor.type = @"InputStickeredMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoto";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputStickeredMedia$inputStickeredMediaDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x438865b;
        constructor.predicate = @"inputStickeredMediaDocument";
        constructor.type = @"InputStickeredMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputDocument";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_TmpPassword$account_tmpPassword
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdb64fd34;
        constructor.predicate = @"account.tmpPassword";
        constructor.type = @"account.TmpPassword";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"tmp_password";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"valid_until";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEvent$channelAdminLogEvent
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3b5a3e40;
        constructor.predicate = @"channelAdminLogEvent";
        constructor.type = @"ChannelAdminLogEvent";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"action";
            arg.type = @"ChannelAdminLogEventAction";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphone_DiscardedCall$phone_discardedCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd834f14e;
        constructor.predicate = @"phone.discardedCall";
        constructor.type = @"phone.DiscardedCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"updates";
            arg.type = @"Updates";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphone_PhoneCall$phone_phoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xec82e140;
        constructor.predicate = @"phone.phoneCall";
        constructor.type = @"phone.PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_call";
            arg.type = @"PhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4f96cb18;
        constructor.predicate = @"inputPrivacyKeyStatusTimestamp";
        constructor.type = @"InputPrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyKey$inputPrivacyKeyChatInvite
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbdfb0426;
        constructor.predicate = @"inputPrivacyKeyChatInvite";
        constructor.type = @"InputPrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyKey$inputPrivacyKeyPhoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfabadc5f;
        constructor.predicate = @"inputPrivacyKeyPhoneCall";
        constructor.type = @"InputPrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputGeoPlaceName$inputGeoPlaceName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x68afa7d4;
        constructor.predicate = @"inputGeoPlaceName";
        constructor.type = @"InputGeoPlaceName";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"country";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"state";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"city";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"district";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"street";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9d05049;
        constructor.predicate = @"userStatusEmpty";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusOnline
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xedb93949;
        constructor.predicate = @"userStatusOnline";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"expires";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusOffline
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8c703f;
        constructor.predicate = @"userStatusOffline";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"was_online";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusRecently
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe26f42f1;
        constructor.predicate = @"userStatusRecently";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusLastWeek
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7bf09fc;
        constructor.predicate = @"userStatusLastWeek";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserStatus$userStatusLastMonth
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77ebc742;
        constructor.predicate = @"userStatusLastMonth";
        constructor.type = @"UserStatus";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatLocated$chatLocated
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3631cf4c;
        constructor.predicate = @"chatLocated";
        constructor.type = @"ChatLocated";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"distance";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCallProtocol$phoneCallProtocol
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa2bb35cb;
        constructor.predicate = @"phoneCallProtocol";
        constructor.type = @"PhoneCallProtocol";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_layer";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_layer";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedChat$encryptedChatEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xab7ec0a0;
        constructor.predicate = @"encryptedChatEmpty";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedChat$encryptedChatWaiting
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3bf703dc;
        constructor.predicate = @"encryptedChatWaiting";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedChat$encryptedChatDiscarded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x13d6dd27;
        constructor.predicate = @"encryptedChatDiscarded";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedChat$encryptedChatRequested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc878527e;
        constructor.predicate = @"encryptedChatRequested";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedChat$encryptedChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfa56ce36;
        constructor.predicate = @"encryptedChat";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a_or_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInvokeWithLayer$invokeWithLayer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xda9b0d0d;
        constructor.predicate = @"invokeWithLayer";
        constructor.type = @"InvokeWithLayer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"layer";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"query";
            arg.type = @"Object";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategoryPeers$topPeerCategoryPeers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfb834291;
        constructor.predicate = @"topPeerCategoryPeers";
        constructor.type = @"TopPeerCategoryPeers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"category";
            arg.type = @"TopPeerCategory";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peers";
            arg.type = @"Vector<TopPeer>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDisabledFeature$disabledFeature
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xae636f24;
        constructor.predicate = @"disabledFeature";
        constructor.type = @"DisabledFeature";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"feature";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPaymentSavedCredentials$paymentSavedCredentialsCard
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcdc27a1f;
        constructor.predicate = @"paymentSavedCredentialsCard";
        constructor.type = @"PaymentSavedCredentials";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButtonRow$keyboardButtonRow
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77608b83;
        constructor.predicate = @"keyboardButtonRow";
        constructor.type = @"KeyboardButtonRow";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"buttons";
            arg.type = @"Vector<KeyboardButton>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_BotCallbackAnswer$messages_botCallbackAnswerMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x13041387;
        constructor.predicate = @"messages.botCallbackAnswerMeta";
        constructor.type = @"messages.BotCallbackAnswer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"cache_time";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLink$contactLinkUnknown
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5f4f9247;
        constructor.predicate = @"contactLinkUnknown";
        constructor.type = @"ContactLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLink$contactLinkNone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfeedd3ad;
        constructor.predicate = @"contactLinkNone";
        constructor.type = @"ContactLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLink$contactLinkHasPhone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x268f3f59;
        constructor.predicate = @"contactLinkHasPhone";
        constructor.type = @"ContactLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLink$contactLinkContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd502c2d0;
        constructor.predicate = @"contactLinkContact";
        constructor.type = @"ContactLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeer$inputPeerEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7f3b18ea;
        constructor.predicate = @"inputPeerEmpty";
        constructor.type = @"InputPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeer$inputPeerSelf
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7da07ec9;
        constructor.predicate = @"inputPeerSelf";
        constructor.type = @"InputPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeer$inputPeerChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x179be863;
        constructor.predicate = @"inputPeerChat";
        constructor.type = @"InputPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeer$inputPeerUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7b8e7de6;
        constructor.predicate = @"inputPeerUser";
        constructor.type = @"InputPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeer$inputPeerChannel
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x20adaef8;
        constructor.predicate = @"inputPeerChannel";
        constructor.type = @"InputPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDcOption$dcOption
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3549ebd6;
        constructor.predicate = @"dcOption";
        constructor.type = @"DcOption";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Dialogs$messages_dialogs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15ba6c40;
        constructor.predicate = @"messages.dialogs";
        constructor.type = @"messages.Dialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dialogs";
            arg.type = @"Vector<Dialog>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Dialogs$messages_dialogsSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x71e094f3;
        constructor.predicate = @"messages.dialogsSlice";
        constructor.type = @"messages.Dialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dialogs";
            arg.type = @"Vector<Dialog>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSchemeMethod$schemeMethod
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x479357c0;
        constructor.predicate = @"schemeMethod";
        constructor.type = @"SchemeMethod";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"method";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"params";
            arg.type = @"Vector<SchemeParam>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeImageSize
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6c37c15c;
        constructor.predicate = @"documentAttributeImageSize";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeAnimated
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x11b58939;
        constructor.predicate = @"documentAttributeAnimated";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeFilename
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15590068;
        constructor.predicate = @"documentAttributeFilename";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeStickerMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x21122b4c;
        constructor.predicate = @"documentAttributeStickerMeta";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"alt";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickerset";
            arg.type = @"InputStickerSet";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mask_coords";
            arg.type = @"MaskCoords";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeHasStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9801d2f7;
        constructor.predicate = @"documentAttributeHasStickers";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDocumentAttribute$documentAttributeVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xef02ce6;
        constructor.predicate = @"documentAttributeVideo";
        constructor.type = @"DocumentAttribute";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"duration";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLchannels_ChannelParticipant$channels_channelParticipant
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd0d9b163;
        constructor.predicate = @"channels.channelParticipant";
        constructor.type = @"channels.ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWebPage$webPageEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xeb1477e8;
        constructor.predicate = @"webPageEmpty";
        constructor.type = @"WebPage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWebPage$webPagePending
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc586da1c;
        constructor.predicate = @"webPagePending";
        constructor.type = @"WebPage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWebPage$webPage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcde7d21;
        constructor.predicate = @"webPage";
        constructor.type = @"WebPage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWebPage$webPageNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x85849473;
        constructor.predicate = @"webPageNotModified";
        constructor.type = @"WebPage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeerNotifySettings$inputPeerNotifySettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x38935eb2;
        constructor.predicate = @"inputPeerNotifySettings";
        constructor.type = @"InputPeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mute_until";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sound";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLStickerSet$stickerSet
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcd303b41;
        constructor.predicate = @"stickerSet";
        constructor.type = @"StickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"short_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGeoPlaceName$geoPlaceName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3819538f;
        constructor.predicate = @"geoPlaceName";
        constructor.type = @"GeoPlaceName";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"country";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"state";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"city";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"district";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"street";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeerSettings$peerSettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x818426cd;
        constructor.predicate = @"peerSettings";
        constructor.type = @"PeerSettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_CheckedPhone$auth_checkedPhone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x811ea28e;
        constructor.predicate = @"auth.checkedPhone";
        constructor.type = @"auth.CheckedPhone";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_registered";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputDocument$inputDocumentEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x72f0eaae;
        constructor.predicate = @"inputDocumentEmpty";
        constructor.type = @"InputDocument";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputDocument$inputDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x18798952;
        constructor.predicate = @"inputDocument";
        constructor.type = @"InputDocument";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLFoundGif$foundGif
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x162ecc1f;
        constructor.predicate = @"foundGif";
        constructor.type = @"FoundGif";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"thumb_url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"content_url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"content_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLFoundGif$foundGifCached
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9c750409;
        constructor.predicate = @"foundGifCached";
        constructor.type = @"FoundGif";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"document";
            arg.type = @"Document";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgsStateReq$msgs_state_req
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xda69fb52;
        constructor.predicate = @"msgs_state_req";
        constructor.type = @"MsgsStateReq";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_ids";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLabeledPrice$labeledPrice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcb296bf8;
        constructor.predicate = @"labeledPrice";
        constructor.type = @"LabeledPrice";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"label";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"amount";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSchemeParam$schemeParam
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x21b59bef;
        constructor.predicate = @"schemeParam";
        constructor.type = @"SchemeParam";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategory$topPeerCategoryBotsPM
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xab661b5b;
        constructor.predicate = @"topPeerCategoryBotsPM";
        constructor.type = @"TopPeerCategory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategory$topPeerCategoryBotsInline
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x148677e2;
        constructor.predicate = @"topPeerCategoryBotsInline";
        constructor.type = @"TopPeerCategory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategory$topPeerCategoryCorrespondents
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x637b7ed;
        constructor.predicate = @"topPeerCategoryCorrespondents";
        constructor.type = @"TopPeerCategory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategory$topPeerCategoryGroups
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbd17a14a;
        constructor.predicate = @"topPeerCategoryGroups";
        constructor.type = @"TopPeerCategory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeerCategory$topPeerCategoryChannels
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x161d9628;
        constructor.predicate = @"topPeerCategoryChannels";
        constructor.type = @"TopPeerCategory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeerNotifySettings$peerNotifySettingsEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x70a68512;
        constructor.predicate = @"peerNotifySettingsEmpty";
        constructor.type = @"PeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeerNotifySettings$peerNotifySettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9acda4c0;
        constructor.predicate = @"peerNotifySettings";
        constructor.type = @"PeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mute_until";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sound";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphotos_Photos$photos_photos
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8dca6aa5;
        constructor.predicate = @"photos.photos";
        constructor.type = @"photos.Photos";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photos";
            arg.type = @"Vector<Photo>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphotos_Photos$photos_photosSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15051f54;
        constructor.predicate = @"photos.photosSlice";
        constructor.type = @"photos.Photos";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photos";
            arg.type = @"Vector<Photo>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGeoPoint$geoPointEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1117dd5f;
        constructor.predicate = @"geoPointEmpty";
        constructor.type = @"GeoPoint";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGeoPoint$geoPoint
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2049d70c;
        constructor.predicate = @"geoPoint";
        constructor.type = @"GeoPoint";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"long";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lat";
            arg.type = @"double";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLGeoPoint$geoPlace
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6e9e21ca;
        constructor.predicate = @"geoPlace";
        constructor.type = @"GeoPoint";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"long";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lat";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"GeoPlaceName";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatParticipant$chatParticipant
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc8d7493e;
        constructor.predicate = @"chatParticipant";
        constructor.type = @"ChatParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatParticipant$chatParticipantCreator
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xda13538a;
        constructor.predicate = @"chatParticipantCreator";
        constructor.type = @"ChatParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatParticipant$chatParticipantAdmin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe2d6e436;
        constructor.predicate = @"chatParticipantAdmin";
        constructor.type = @"ChatParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueAllowContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfffe1bac;
        constructor.predicate = @"privacyValueAllowContacts";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueAllowAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x65427b82;
        constructor.predicate = @"privacyValueAllowAll";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueAllowUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4d5bbe0c;
        constructor.predicate = @"privacyValueAllowUsers";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueDisallowContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf888fa1a;
        constructor.predicate = @"privacyValueDisallowContacts";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueDisallowAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8b73e763;
        constructor.predicate = @"privacyValueDisallowAll";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyRule$privacyValueDisallowUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc7f49b7;
        constructor.predicate = @"privacyValueDisallowUsers";
        constructor.type = @"PrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_BotResults$messages_botResultsMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9f7e87b2;
        constructor.predicate = @"messages.botResultsMeta";
        constructor.type = @"messages.BotResults";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_PasswordSettings$account_passwordSettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb7b72ab3;
        constructor.predicate = @"account.passwordSettings";
        constructor.type = @"account.PasswordSettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLScheme$scheme
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4e6ef65e;
        constructor.predicate = @"scheme";
        constructor.type = @"Scheme";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"scheme_raw";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"types";
            arg.type = @"Vector<SchemeType>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"methods";
            arg.type = @"Vector<SchemeMethod>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLScheme$schemeNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x263c9c58;
        constructor.predicate = @"schemeNotModified";
        constructor.type = @"Scheme";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_RecentStickers$messages_recentStickersNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb17f890;
        constructor.predicate = @"messages.recentStickersNotModified";
        constructor.type = @"messages.RecentStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_RecentStickers$messages_recentStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5ce20970;
        constructor.predicate = @"messages.recentStickers";
        constructor.type = @"messages.RecentStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickers";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_ExportedAuthorization$auth_exportedAuthorization
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdf969c2d;
        constructor.predicate = @"auth.exportedAuthorization";
        constructor.type = @"auth.ExportedAuthorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContact$contact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf911c994;
        constructor.predicate = @"contact";
        constructor.type = @"Contact";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mutual";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_SavedInfo$payments_savedInfoMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa2ffb0da;
        constructor.predicate = @"payments.savedInfoMeta";
        constructor.type = @"payments.SavedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"saved_info";
            arg.type = @"PaymentRequestedInfo";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBotInfo$botInfo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x98e81d3a;
        constructor.predicate = @"botInfo";
        constructor.type = @"BotInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"commands";
            arg.type = @"Vector<BotCommand>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_AppChangelog$help_appChangelogEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaf7e0394;
        constructor.predicate = @"help.appChangelogEmpty";
        constructor.type = @"help.AppChangelog";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_AppChangelog$help_appChangelog
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2a137e7c;
        constructor.predicate = @"help.appChangelog";
        constructor.type = @"help.AppChangelog";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"MessageMedia";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"entities";
            arg.type = @"Vector<MessageEntity>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileUnknown
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaa963b05;
        constructor.predicate = @"storage.fileUnknown";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileJpeg
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7efe0e;
        constructor.predicate = @"storage.fileJpeg";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileGif
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcae1aadf;
        constructor.predicate = @"storage.fileGif";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_filePng
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa4f63c0;
        constructor.predicate = @"storage.filePng";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_filePdf
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xae1e508d;
        constructor.predicate = @"storage.filePdf";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileMp3
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x528a0677;
        constructor.predicate = @"storage.fileMp3";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileMov
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4b09ebbc;
        constructor.predicate = @"storage.fileMov";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_filePartial
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40bc6f52;
        constructor.predicate = @"storage.filePartial";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileMp4
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb3cea0e4;
        constructor.predicate = @"storage.fileMp4";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLstorage_FileType$storage_fileWebp
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1081464c;
        constructor.predicate = @"storage.fileWebp";
        constructor.type = @"storage.FileType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInvoice$invoiceMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x187882c1;
        constructor.predicate = @"invoiceMeta";
        constructor.type = @"Invoice";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"currency";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prices";
            arg.type = @"Vector<LabeledPrice>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBotCommand$botCommand
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc27ac8c7;
        constructor.predicate = @"botCommand";
        constructor.type = @"BotCommand";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"command";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupdates_State$updates_state
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa56c2a3e;
        constructor.predicate = @"updates.state";
        constructor.type = @"updates.State";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"qts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unread_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInitConnection$initConnection
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x69796de9;
        constructor.predicate = @"initConnection";
        constructor.type = @"InitConnection";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"api_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"device_model";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"system_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"query";
            arg.type = @"Object";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLBotInlineResult$botInlineMediaResultMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x13e11ac5;
        constructor.predicate = @"botInlineMediaResultMeta";
        constructor.type = @"BotInlineResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactSuggested$contactSuggested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3de191a1;
        constructor.predicate = @"contactSuggested";
        constructor.type = @"ContactSuggested";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mutual_contacts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeerNotifyEvents$inputPeerNotifyEventsEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf03064d8;
        constructor.predicate = @"inputPeerNotifyEventsEmpty";
        constructor.type = @"InputPeerNotifyEvents";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPeerNotifyEvents$inputPeerNotifyEventsAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe86a2c74;
        constructor.predicate = @"inputPeerNotifyEventsAll";
        constructor.type = @"InputPeerNotifyEvents";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_SavedGifs$messages_savedGifsNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe8025ca2;
        constructor.predicate = @"messages.savedGifsNotModified";
        constructor.type = @"messages.SavedGifs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_SavedGifs$messages_savedGifs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2e0709a5;
        constructor.predicate = @"messages.savedGifs";
        constructor.type = @"messages.SavedGifs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"gifs";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupload_File$upload_file
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x96a18d5;
        constructor.predicate = @"upload.file";
        constructor.type = @"upload.File";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"storage.FileType";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mtime";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupload_File$upload_fileCdnRedirect
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xea52fe5a;
        constructor.predicate = @"upload.fileCdnRedirect";
        constructor.type = @"upload.File";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"encryption_key";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"encryption_iv";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"cdn_file_hashes";
            arg.type = @"Vector<CdnFileHash>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Messages$messages_messages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8c718e87;
        constructor.predicate = @"messages.messages";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Messages$messages_messagesSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb446ae3;
        constructor.predicate = @"messages.messagesSlice";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Messages$messages_channelMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x99262e37;
        constructor.predicate = @"messages.channelMessages";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_ImportedContacts$contacts_importedContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77d01c3b;
        constructor.predicate = @"contacts.importedContacts";
        constructor.type = @"contacts.ImportedContacts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"imported";
            arg.type = @"Vector<ImportedContact>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"popular_invites";
            arg.type = @"Vector<PopularContact>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"retry_contacts";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Located$contacts_located
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaad7f4a7;
        constructor.predicate = @"contacts.located";
        constructor.type = @"contacts.Located";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<ContactLocated>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLchannels_AdminLogResults$channels_adminLogResults
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xed8af74d;
        constructor.predicate = @"channels.adminLogResults";
        constructor.type = @"channels.AdminLogResults";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"events";
            arg.type = @"Vector<ChannelAdminLogEvent>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipantsFilter$channelParticipantsRecent
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xde3f3c79;
        constructor.predicate = @"channelParticipantsRecent";
        constructor.type = @"ChannelParticipantsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipantsFilter$channelParticipantsAdmins
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb4608969;
        constructor.predicate = @"channelParticipantsAdmins";
        constructor.type = @"ChannelParticipantsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipantsFilter$channelParticipantsBanned
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1427a5e1;
        constructor.predicate = @"channelParticipantsBanned";
        constructor.type = @"ChannelParticipantsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipantsFilter$channelParticipantsSearch
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x656ac4b;
        constructor.predicate = @"channelParticipantsSearch";
        constructor.type = @"ChannelParticipantsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipantsFilter$channelParticipantsKicked
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa3b54985;
        constructor.predicate = @"channelParticipantsKicked";
        constructor.type = @"ChannelParticipantsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLServer_DH_Params$server_DH_params_fail
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x79cb045d;
        constructor.predicate = @"server_DH_params_fail";
        constructor.type = @"Server_DH_Params";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_nonce_hash";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLServer_DH_Params$server_DH_params_ok
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd0e8075c;
        constructor.predicate = @"server_DH_params_ok";
        constructor.type = @"Server_DH_Params";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"encrypted_answer";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_ForeignLink$contacts_foreignLinkUnknown
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x133421f8;
        constructor.predicate = @"contacts.foreignLinkUnknown";
        constructor.type = @"contacts.ForeignLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_ForeignLink$contacts_foreignLinkRequested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa7801f47;
        constructor.predicate = @"contacts.foreignLinkRequested";
        constructor.type = @"contacts.ForeignLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"has_phone";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_ForeignLink$contacts_foreignLinkMutual
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1bea8ce1;
        constructor.predicate = @"contacts.foreignLinkMutual";
        constructor.type = @"contacts.ForeignLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_Password$account_noPassword
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x96dabc18;
        constructor.predicate = @"account.noPassword";
        constructor.type = @"account.Password";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_salt";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email_unconfirmed_pattern";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_Password$account_password
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7c18141c;
        constructor.predicate = @"account.password";
        constructor.type = @"account.Password";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"current_salt";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_salt";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hint";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"has_recovery";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email_unconfirmed_pattern";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPaymentCredentials$inputPaymentCredentialsSaved
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc10eb2cf;
        constructor.predicate = @"inputPaymentCredentialsSaved";
        constructor.type = @"InputPaymentCredentials";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"tmp_password";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPaymentCredentials$inputPaymentCredentials
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3417d728;
        constructor.predicate = @"inputPaymentCredentials";
        constructor.type = @"InputPaymentCredentials";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"DataJSON";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLP_Q_inner_data$p_q_inner_data
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x83c95aec;
        constructor.predicate = @"p_q_inner_data";
        constructor.type = @"P_Q_inner_data";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pq";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"p";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_nonce";
            arg.type = @"int256";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedFile$encryptedFileEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc21f497e;
        constructor.predicate = @"encryptedFileEmpty";
        constructor.type = @"EncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedFile$encryptedFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4a70994c;
        constructor.predicate = @"encryptedFile";
        constructor.type = @"EncryptedFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe6dfb825;
        constructor.predicate = @"channelAdminLogEventActionChangeTitle";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x55188a2e;
        constructor.predicate = @"channelAdminLogEventActionChangeAbout";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6a4afc38;
        constructor.predicate = @"channelAdminLogEventActionChangeUsername";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb82f55c3;
        constructor.predicate = @"channelAdminLogEventActionChangePhoto";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_photo";
            arg.type = @"ChatPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_photo";
            arg.type = @"ChatPhoto";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1b7907ae;
        constructor.predicate = @"channelAdminLogEventActionToggleInvites";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_value";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x26ae0971;
        constructor.predicate = @"channelAdminLogEventActionToggleSignatures";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_value";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9e82c18;
        constructor.predicate = @"channelAdminLogEventActionUpdatePinned";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x709b2405;
        constructor.predicate = @"channelAdminLogEventActionEditMessage";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x42e047bb;
        constructor.predicate = @"channelAdminLogEventActionDeleteMessage";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x183040d3;
        constructor.predicate = @"channelAdminLogEventActionParticipantJoin";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf89777f2;
        constructor.predicate = @"channelAdminLogEventActionParticipantLeave";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe31c34d8;
        constructor.predicate = @"channelAdminLogEventActionParticipantInvite";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe6d83d7e;
        constructor.predicate = @"channelAdminLogEventActionParticipantToggleBan";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd5676710;
        constructor.predicate = @"channelAdminLogEventActionParticipantToggleAdmin";
        constructor.type = @"ChannelAdminLogEventAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_participant";
            arg.type = @"ChannelParticipant";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdates$updatesTooLong
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe317af7e;
        constructor.predicate = @"updatesTooLong";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdates$updateShort
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x78d4dec1;
        constructor.predicate = @"updateShort";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"update";
            arg.type = @"Update";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdates$updatesCombined
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x725b04c3;
        constructor.predicate = @"updatesCombined";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"updates";
            arg.type = @"Vector<Update>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq_start";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdates$updates
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x74ae4240;
        constructor.predicate = @"updates";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"updates";
            arg.type = @"Vector<Update>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Stickers$messages_stickersNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf1749a22;
        constructor.predicate = @"messages.stickersNotModified";
        constructor.type = @"messages.Stickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Stickers$messages_stickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8a8ecd32;
        constructor.predicate = @"messages.stickers";
        constructor.type = @"messages.Stickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickers";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_ResolvedPeer$contacts_resolvedPeer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7f077ad9;
        constructor.predicate = @"contacts.resolvedPeer";
        constructor.type = @"contacts.ResolvedPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageGroup$messageGroup
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe8346f53;
        constructor.predicate = @"messageGroup";
        constructor.type = @"MessageGroup";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_PasswordRecovery$auth_passwordRecovery
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x137948a5;
        constructor.predicate = @"auth.passwordRecovery";
        constructor.type = @"auth.PasswordRecovery";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email_pattern";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInvokeAfterMsg$invokeAfterMsg
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcb9f372d;
        constructor.predicate = @"invokeAfterMsg";
        constructor.type = @"InvokeAfterMsg";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"query";
            arg.type = @"Object";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatPhoto$chatPhotoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x37c1011c;
        constructor.predicate = @"chatPhotoEmpty";
        constructor.type = @"ChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatPhoto$chatPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6153276a;
        constructor.predicate = @"chatPhoto";
        constructor.type = @"ChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_small";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_big";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatFull$chatFull
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2e02a614;
        constructor.predicate = @"chatFull";
        constructor.type = @"ChatFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants";
            arg.type = @"ChatParticipants";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"notify_settings";
            arg.type = @"PeerNotifySettings";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"exported_invite";
            arg.type = @"ExportedChatInvite";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bot_info";
            arg.type = @"Vector<BotInfo>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLchannels_ChannelParticipants$channels_channelParticipants
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf56ee2a8;
        constructor.predicate = @"channels.channelParticipants";
        constructor.type = @"channels.ChannelParticipants";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participants";
            arg.type = @"Vector<ChannelParticipant>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputStickerSet$inputStickerSetEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xffb62b95;
        constructor.predicate = @"inputStickerSetEmpty";
        constructor.type = @"InputStickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputStickerSet$inputStickerSetID
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9de7a269;
        constructor.predicate = @"inputStickerSetID";
        constructor.type = @"InputStickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputStickerSet$inputStickerSetShortName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x861cc8a0;
        constructor.predicate = @"inputStickerSetShortName";
        constructor.type = @"InputStickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"short_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb6aef7b0;
        constructor.predicate = @"messageActionEmpty";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatCreate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa6638b9a;
        constructor.predicate = @"messageActionChatCreate";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatEditTitle
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb5a1ce5a;
        constructor.predicate = @"messageActionChatEditTitle";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatEditPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7fcb13a8;
        constructor.predicate = @"messageActionChatEditPhoto";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatDeletePhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x95e3fbef;
        constructor.predicate = @"messageActionChatDeletePhoto";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatDeleteUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb2ae9b0c;
        constructor.predicate = @"messageActionChatDeleteUser";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionSentRequest
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfc479b0f;
        constructor.predicate = @"messageActionSentRequest";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"has_phone";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionAcceptRequest
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7f07d76c;
        constructor.predicate = @"messageActionAcceptRequest";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatJoinedByLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf89cf5e8;
        constructor.predicate = @"messageActionChatJoinedByLink";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChannelCreate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x95d2ac92;
        constructor.predicate = @"messageActionChannelCreate";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChannelToggleComments
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf2863903;
        constructor.predicate = @"messageActionChannelToggleComments";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatMigrateTo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x51bdb021;
        constructor.predicate = @"messageActionChatMigrateTo";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatDeactivate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x64ad20a8;
        constructor.predicate = @"messageActionChatDeactivate";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatActivate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40ad8cb2;
        constructor.predicate = @"messageActionChatActivate";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChannelMigrateFrom
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb055eaee;
        constructor.predicate = @"messageActionChannelMigrateFrom";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatAddUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x488a7337;
        constructor.predicate = @"messageActionChatAddUser";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionChatAddUserLegacy
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5e3cfc4b;
        constructor.predicate = @"messageActionChatAddUserLegacy";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionPinMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x94bd38ed;
        constructor.predicate = @"messageActionPinMessage";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionHistoryClear
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9fbab604;
        constructor.predicate = @"messageActionHistoryClear";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionGameScore
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x92a72876;
        constructor.predicate = @"messageActionGameScore";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"game_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"score";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionPaymentSent
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40699cd0;
        constructor.predicate = @"messageActionPaymentSent";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"currency";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"total_amount";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionScreenshotTaken
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4792929b;
        constructor.predicate = @"messageActionScreenshotTaken";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEmbedPostMedia$embedPostPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe31ee77;
        constructor.predicate = @"embedPostPhoto";
        constructor.type = @"EmbedPostMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEmbedPostMedia$embedPostVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa07f2d66;
        constructor.predicate = @"embedPostVideo";
        constructor.type = @"EmbedPostMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"video_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLCdnConfig$cdnConfig
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5725e40a;
        constructor.predicate = @"cdnConfig";
        constructor.type = @"CdnConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"public_keys";
            arg.type = @"Vector<CdnPublicKey>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Message$messages_messageEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3f4e0648;
        constructor.predicate = @"messages.messageEmpty";
        constructor.type = @"messages.Message";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Message$messages_message
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xff90c417;
        constructor.predicate = @"messages.message";
        constructor.type = @"messages.Message";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRpcDropAnswer$rpc_answer_unknown
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5e2ad36e;
        constructor.predicate = @"rpc_answer_unknown";
        constructor.type = @"RpcDropAnswer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRpcDropAnswer$rpc_answer_dropped_running
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcd78e586;
        constructor.predicate = @"rpc_answer_dropped_running";
        constructor.type = @"RpcDropAnswer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRpcDropAnswer$rpc_answer_dropped
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa43ad8b7;
        constructor.predicate = @"rpc_answer_dropped";
        constructor.type = @"RpcDropAnswer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"seq_no";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputGame$inputGameID
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x32c3e77;
        constructor.predicate = @"inputGameID";
        constructor.type = @"InputGame";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputGame$inputGameShortName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc331e80a;
        constructor.predicate = @"inputGameShortName";
        constructor.type = @"InputGame";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bot_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"short_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButton
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa2fa4880;
        constructor.predicate = @"keyboardButton";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonUrl
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x258aff05;
        constructor.predicate = @"keyboardButtonUrl";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonCallback
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x683a5e46;
        constructor.predicate = @"keyboardButtonCallback";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonRequestPhone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb16a6c29;
        constructor.predicate = @"keyboardButtonRequestPhone";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonRequestGeoLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfc796b3f;
        constructor.predicate = @"keyboardButtonRequestGeoLocation";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonSwitchInline
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x568a748;
        constructor.predicate = @"keyboardButtonSwitchInline";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"query";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonGame
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x50f41ccf;
        constructor.predicate = @"keyboardButtonGame";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLKeyboardButton$keyboardButtonBuy
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xafd93fbb;
        constructor.predicate = @"keyboardButtonBuy";
        constructor.type = @"KeyboardButton";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUser$userEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x200250ba;
        constructor.predicate = @"userEmpty";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUser$user
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbb708740;
        constructor.predicate = @"user";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminRights$channelAdminRights
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5d7ceba5;
        constructor.predicate = @"channelAdminRights";
        constructor.type = @"ChannelAdminRights";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLangPackString$langPackString
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcad181f6;
        constructor.predicate = @"langPackString";
        constructor.type = @"LangPackString";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLangPackString$langPackStringPluralized
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa2fe21da;
        constructor.predicate = @"langPackStringPluralized";
        constructor.type = @"LangPackString";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"zero_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"one_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"two_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"few_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"many_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"other_value";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLLangPackString$langPackStringDeleted
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2979eeb2;
        constructor.predicate = @"langPackStringDeleted";
        constructor.type = @"LangPackString";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x85e42301;
        constructor.predicate = @"phoneCallDiscardReasonMissed";
        constructor.type = @"PhoneCallDiscardReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe095c1a0;
        constructor.predicate = @"phoneCallDiscardReasonDisconnect";
        constructor.type = @"PhoneCallDiscardReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x57adc690;
        constructor.predicate = @"phoneCallDiscardReasonHangup";
        constructor.type = @"PhoneCallDiscardReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfaf7e8c9;
        constructor.predicate = @"phoneCallDiscardReasonBusy";
        constructor.type = @"PhoneCallDiscardReason";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_AppUpdate$help_appUpdate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8987f311;
        constructor.predicate = @"help.appUpdate";
        constructor.type = @"help.AppUpdate";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"critical";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_AppUpdate$help_noAppUpdate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc45a6536;
        constructor.predicate = @"help.noAppUpdate";
        constructor.type = @"help.AppUpdate";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_ChatFull$messages_chatFull
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe5d7d19c;
        constructor.predicate = @"messages.chatFull";
        constructor.type = @"messages.ChatFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"full_chat";
            arg.type = @"ChatFull";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPhotoCrop$inputPhotoCropAuto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xade6b004;
        constructor.predicate = @"inputPhotoCropAuto";
        constructor.type = @"InputPhotoCrop";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPhotoCrop$inputPhotoCrop
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd9915325;
        constructor.predicate = @"inputPhotoCrop";
        constructor.type = @"InputPhotoCrop";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop_left";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop_top";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop_width";
            arg.type = @"double";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupload_CdnFile$upload_cdnFileReuploadNeeded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xeea8e46e;
        constructor.predicate = @"upload.cdnFileReuploadNeeded";
        constructor.type = @"upload.CdnFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"request_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupload_CdnFile$upload_cdnFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa99fca4f;
        constructor.predicate = @"upload.cdnFile";
        constructor.type = @"upload.CdnFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_SentLink$contacts_sentLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x96a0c63e;
        constructor.predicate = @"contacts.sentLink";
        constructor.type = @"contacts.SentLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"messages.Message";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"link";
            arg.type = @"contacts.Link";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_PasswordInputSettings$account_passwordInputSettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf19c121e;
        constructor.predicate = @"account.passwordInputSettings";
        constructor.type = @"account.PasswordInputSettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLaccount_Authorizations$account_authorizations
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1250abde;
        constructor.predicate = @"account.authorizations";
        constructor.type = @"account.Authorizations";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"authorizations";
            arg.type = @"Vector<Authorization>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedMessage$encryptedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xed18c118;
        constructor.predicate = @"encryptedMessage";
        constructor.type = @"EncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"EncryptedFile";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLEncryptedMessage$encryptedMessageService
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x23734b06;
        constructor.predicate = @"encryptedMessageService";
        constructor.type = @"EncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgsAllInfo$msgs_all_info
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8cc0d131;
        constructor.predicate = @"msgs_all_info";
        constructor.type = @"MsgsAllInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_ids";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"info";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgDetailedInfo$msg_detailed_info
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x276d3ec6;
        constructor.predicate = @"msg_detailed_info";
        constructor.type = @"MsgDetailedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"answer_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"status";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgDetailedInfo$msg_new_detailed_info
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x809db6df;
        constructor.predicate = @"msg_new_detailed_info";
        constructor.type = @"MsgDetailedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"answer_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"status";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLupload_WebFile$upload_webFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x21e753bc;
        constructor.predicate = @"upload.webFile";
        constructor.type = @"upload.WebFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_type";
            arg.type = @"storage.FileType";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mtime";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLocated$contactLocated
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe144acaf;
        constructor.predicate = @"contactLocated";
        constructor.type = @"ContactLocated";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"GeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"distance";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLContactLocated$contactLocatedPreview
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc1257157;
        constructor.predicate = @"contactLocatedPreview";
        constructor.type = @"ContactLocated";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hidden";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"distance";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueAllowContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd09e07b;
        constructor.predicate = @"inputPrivacyValueAllowContacts";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueAllowAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x184b35ce;
        constructor.predicate = @"inputPrivacyValueAllowAll";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueAllowUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x131cc67f;
        constructor.predicate = @"inputPrivacyValueAllowUsers";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueDisallowContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xba52007;
        constructor.predicate = @"inputPrivacyValueDisallowContacts";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueDisallowAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd66b66c9;
        constructor.predicate = @"inputPrivacyValueDisallowAll";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputPrivacyRule$inputPrivacyValueDisallowUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x90110467;
        constructor.predicate = @"inputPrivacyValueDisallowUsers";
        constructor.type = @"InputPrivacyRule";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_AffectedMessages$messages_affectedMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x84d19185;
        constructor.predicate = @"messages.affectedMessages";
        constructor.type = @"messages.AffectedMessages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts_count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNotifyPeer$notifyPeer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9fd40bd8;
        constructor.predicate = @"notifyPeer";
        constructor.type = @"NotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNotifyPeer$notifyUsers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb4c83b4c;
        constructor.predicate = @"notifyUsers";
        constructor.type = @"NotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNotifyPeer$notifyChats
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc007cec3;
        constructor.predicate = @"notifyChats";
        constructor.type = @"NotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNotifyPeer$notifyAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x74d07c60;
        constructor.predicate = @"notifyAll";
        constructor.type = @"NotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipant$channelParticipant
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x15ebac1d;
        constructor.predicate = @"channelParticipant";
        constructor.type = @"ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipant$channelParticipantSelf
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa3289a6d;
        constructor.predicate = @"channelParticipantSelf";
        constructor.type = @"ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipant$channelParticipantCreator
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe3e2e1f9;
        constructor.predicate = @"channelParticipantCreator";
        constructor.type = @"ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipant$channelParticipantAdmin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa82fa898;
        constructor.predicate = @"channelParticipantAdmin";
        constructor.type = @"ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inviter_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"promoted_by";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_rights";
            arg.type = @"ChannelAdminRights";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelParticipant$channelParticipantBanned
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x222c1886;
        constructor.predicate = @"channelParticipantBanned";
        constructor.type = @"ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"kicked_by";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"banned_rights";
            arg.type = @"ChannelBannedRights";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCallEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5366c915;
        constructor.predicate = @"phoneCallEmpty";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCallWaitingMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x44461b43;
        constructor.predicate = @"phoneCallWaitingMeta";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"receive_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCallRequested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x83761ce4;
        constructor.predicate = @"phoneCallRequested";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCallDiscardedMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc9d59add;
        constructor.predicate = @"phoneCallDiscardedMeta";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reason";
            arg.type = @"PhoneCallDiscardReason";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"duration";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCallAccepted
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6d003d3f;
        constructor.predicate = @"phoneCallAccepted";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneCall$phoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xffe6ab67;
        constructor.predicate = @"phoneCall";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"participant_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a_or_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"connection";
            arg.type = @"PhoneConnection";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"alternative_connections";
            arg.type = @"Vector<PhoneConnection>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"start_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityUnknown
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbb92ba95;
        constructor.predicate = @"messageEntityUnknown";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityMention
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfa04579d;
        constructor.predicate = @"messageEntityMention";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityHashtag
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6f635b0d;
        constructor.predicate = @"messageEntityHashtag";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityBotCommand
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6cef8ac7;
        constructor.predicate = @"messageEntityBotCommand";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityUrl
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6ed02538;
        constructor.predicate = @"messageEntityUrl";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityEmail
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x64e475c2;
        constructor.predicate = @"messageEntityEmail";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityBold
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbd610bc9;
        constructor.predicate = @"messageEntityBold";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityItalic
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x826f8b60;
        constructor.predicate = @"messageEntityItalic";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityCode
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x28a20571;
        constructor.predicate = @"messageEntityCode";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityPre
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x73924be0;
        constructor.predicate = @"messageEntityPre";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"language";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityTextUrl
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x76a6d327;
        constructor.predicate = @"messageEntityTextUrl";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$messageEntityMentionName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x352dca58;
        constructor.predicate = @"messageEntityMentionName";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageEntity$inputMessageEntityMentionName
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x208e68c9;
        constructor.predicate = @"inputMessageEntityMentionName";
        constructor.type = @"MessageEntity";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChannel$inputChannelEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xee8c1e86;
        constructor.predicate = @"inputChannelEmpty";
        constructor.type = @"InputChannel";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChannel$inputChannel
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xafeb712e;
        constructor.predicate = @"inputChannel";
        constructor.type = @"InputChannel";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputGeoPoint$inputGeoPointEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe4c123d6;
        constructor.predicate = @"inputGeoPointEmpty";
        constructor.type = @"InputGeoPoint";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputGeoPoint$inputGeoPoint
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf3b7acc9;
        constructor.predicate = @"inputGeoPoint";
        constructor.type = @"InputGeoPoint";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lat";
            arg.type = @"double";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"long";
            arg.type = @"double";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Chat$messages_chat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x40e9002a;
        constructor.predicate = @"messages.chat";
        constructor.type = @"messages.Chat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat";
            arg.type = @"Chat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhotoSize$photoSizeEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe17e23c;
        constructor.predicate = @"photoSizeEmpty";
        constructor.type = @"PhotoSize";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhotoSize$photoSize
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77bfb61b;
        constructor.predicate = @"photoSize";
        constructor.type = @"PhotoSize";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhotoSize$photoCachedSize
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9a734fa;
        constructor.predicate = @"photoCachedSize";
        constructor.type = @"PhotoSize";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_ArchivedStickers$messages_archivedStickers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4fcba9c8;
        constructor.predicate = @"messages.archivedStickers";
        constructor.type = @"messages.ArchivedStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sets";
            arg.type = @"Vector<StickerSetCovered>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPopularContact$popularContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5ce14175;
        constructor.predicate = @"popularContact";
        constructor.type = @"PopularContact";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"client_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"importers";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLAccountDaysTTL$accountDaysTTL
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb8d0afdf;
        constructor.predicate = @"accountDaysTTL";
        constructor.type = @"AccountDaysTTL";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"days";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLHttpWait$http_wait
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9299359f;
        constructor.predicate = @"http_wait";
        constructor.type = @"HttpWait";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_delay";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"wait_after";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_wait";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputFile$inputFile
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf52ff27f;
        constructor.predicate = @"inputFile";
        constructor.type = @"InputFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"parts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"md5_checksum";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputFile$inputFileBig
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfa4f0bb5;
        constructor.predicate = @"inputFileBig";
        constructor.type = @"InputFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"parts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSchemeType$schemeType
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa8e1e989;
        constructor.predicate = @"schemeType";
        constructor.type = @"SchemeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"predicate";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"params";
            arg.type = @"Vector<SchemeParam>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPaymentRequestedInfo$paymentRequestedInfoMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xeb45a08f;
        constructor.predicate = @"paymentRequestedInfoMeta";
        constructor.type = @"PaymentRequestedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"email";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"shipping_address";
            arg.type = @"PostAddress";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDestroySessionRes$destroy_session_ok
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe22045fc;
        constructor.predicate = @"destroy_session_ok";
        constructor.type = @"DestroySessionRes";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"session_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDestroySessionRes$destroy_session_none
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x62d350c9;
        constructor.predicate = @"destroy_session_none";
        constructor.type = @"DestroySessionRes";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"session_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Requests$contacts_requests
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6262c36c;
        constructor.predicate = @"contacts.requests";
        constructor.type = @"contacts.Requests";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"requests";
            arg.type = @"Vector<ContactRequest>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Requests$contacts_requestsSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6f585b8c;
        constructor.predicate = @"contacts.requestsSlice";
        constructor.type = @"contacts.Requests";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"requests";
            arg.type = @"Vector<ContactRequest>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xea107ae4;
        constructor.predicate = @"channelAdminLogEventsFilter";
        constructor.type = @"ChannelAdminLogEventsFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInlineBotSwitchPM$inlineBotSwitchPM
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3c20629f;
        constructor.predicate = @"inlineBotSwitchPM";
        constructor.type = @"InlineBotSwitchPM";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"start_param";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputBotInlineMessage$inputBotInlineMessageGame
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3c00f8aa;
        constructor.predicate = @"inputBotInlineMessageGame";
        constructor.type = @"InputBotInlineMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reply_markup";
            arg.type = @"ReplyMarkup";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserProfilePhoto$userProfilePhotoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4f11bae1;
        constructor.predicate = @"userProfilePhotoEmpty";
        constructor.type = @"UserProfilePhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUserProfilePhoto$userProfilePhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd559d8c8;
        constructor.predicate = @"userProfilePhoto";
        constructor.type = @"UserProfilePhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_small";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_big";
            arg.type = @"FileLocation";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_InviteText$help_inviteText
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x18cb9f78;
        constructor.predicate = @"help.inviteText";
        constructor.type = @"help.InviteText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultSuccess
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x38641628;
        constructor.predicate = @"messages.stickerSetInstallResultSuccess";
        constructor.type = @"messages.StickerSetInstallResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultArchive
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x35e410a8;
        constructor.predicate = @"messages.stickerSetInstallResultArchive";
        constructor.type = @"messages.StickerSetInstallResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sets";
            arg.type = @"Vector<StickerSetCovered>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLError$error
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc4b9f9bb;
        constructor.predicate = @"error";
        constructor.type = @"Error";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"code";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLError$richError
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x59aefc57;
        constructor.predicate = @"richError";
        constructor.type = @"Error";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"code";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"debug";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"request_params";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLExportedMessageLink$exportedMessageLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1f486803;
        constructor.predicate = @"exportedMessageLink";
        constructor.type = @"ExportedMessageLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"link";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneConnection$phoneConnectionNotReady
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x26bc3c3;
        constructor.predicate = @"phoneConnectionNotReady";
        constructor.type = @"PhoneConnection";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPhoneConnection$phoneConnection
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9d4c17c0;
        constructor.predicate = @"phoneConnection";
        constructor.type = @"PhoneConnection";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ip";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ipv6";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"port";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer_tag";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLNearestDc$nearestDc
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8e1a1775;
        constructor.predicate = @"nearestDc";
        constructor.type = @"NearestDc";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"country";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"this_dc";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nearest_dc";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLphotos_Photo$photos_photo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x20212ca8;
        constructor.predicate = @"photos.photo";
        constructor.type = @"photos.Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMsgsAck$msgs_ack
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x62d6b459;
        constructor.predicate = @"msgs_ack";
        constructor.type = @"MsgsAck";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_ids";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_AppPrefs$help_appPrefs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x424f8614;
        constructor.predicate = @"help.appPrefs";
        constructor.type = @"help.AppPrefs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLStickerPack$stickerPack
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x12b299d4;
        constructor.predicate = @"stickerPack";
        constructor.type = @"StickerPack";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"emoticon";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"documents";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeerNotifyEvents$peerNotifyEventsEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xadd53cb3;
        constructor.predicate = @"peerNotifyEventsEmpty";
        constructor.type = @"PeerNotifyEvents";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPeerNotifyEvents$peerNotifyEventsAll
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6d1ded88;
        constructor.predicate = @"peerNotifyEventsAll";
        constructor.type = @"PeerNotifyEvents";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLResPQ$resPQ
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5162463;
        constructor.predicate = @"resPQ";
        constructor.type = @"ResPQ";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pq";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_public_key_fingerprints";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDraftMessage$draftMessageEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xba4baec5;
        constructor.predicate = @"draftMessageEmpty";
        constructor.type = @"DraftMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDraftMessage$draftMessageMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd20ec09c;
        constructor.predicate = @"draftMessageMeta";
        constructor.type = @"DraftMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reply_to_msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"entities";
            arg.type = @"Vector<MessageEntity>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLStickerSetCovered$stickerSetCovered
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6410a5d2;
        constructor.predicate = @"stickerSetCovered";
        constructor.type = @"StickerSetCovered";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"set";
            arg.type = @"StickerSet";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"cover";
            arg.type = @"Document";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLStickerSetCovered$stickerSetMultiCovered
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3407e51b;
        constructor.predicate = @"stickerSetMultiCovered";
        constructor.type = @"StickerSetCovered";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"set";
            arg.type = @"StickerSet";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"covers";
            arg.type = @"Vector<Document>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelMessagesFilter$channelMessagesFilterEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x94d42ee7;
        constructor.predicate = @"channelMessagesFilterEmpty";
        constructor.type = @"ChannelMessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelMessagesFilter$channelMessagesFilter
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcd77d957;
        constructor.predicate = @"channelMessagesFilter";
        constructor.type = @"ChannelMessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ranges";
            arg.type = @"Vector<MessageRange>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChannelMessagesFilter$channelMessagesFilterCollapsed
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfa01232e;
        constructor.predicate = @"channelMessagesFilterCollapsed";
        constructor.type = @"ChannelMessagesFilter";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_FoundGifs$messages_foundGifs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x450a1c0a;
        constructor.predicate = @"messages.foundGifs";
        constructor.type = @"messages.FoundGifs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"next_offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<FoundGif>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLAuthorization$authorization
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7bf2e6f6;
        constructor.predicate = @"authorization";
        constructor.type = @"Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"device_model";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"platform";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"system_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"api_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date_created";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date_active";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ip";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"country";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"region";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3ded6320;
        constructor.predicate = @"messageMediaEmpty";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaGeo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x56e0d474;
        constructor.predicate = @"messageMediaGeo";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo";
            arg.type = @"GeoPoint";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5e7d2f39;
        constructor.predicate = @"messageMediaContact";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaUnsupported
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9f84f49e;
        constructor.predicate = @"messageMediaUnsupported";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaWebPage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa32dd600;
        constructor.predicate = @"messageMediaWebPage";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"webpage";
            arg.type = @"WebPage";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaVenue
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7912b71f;
        constructor.predicate = @"messageMediaVenue";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo";
            arg.type = @"GeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"provider";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"venue_id";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaGame
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfdb19008;
        constructor.predicate = @"messageMediaGame";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"game";
            arg.type = @"Game";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaInvoiceMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb0e774bd;
        constructor.predicate = @"messageMediaInvoiceMeta";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_description";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"WebDocument";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"receipt_msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"currency";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"total_amount";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"start_param";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaPhotoMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x17dace6c;
        constructor.predicate = @"messageMediaPhotoMeta";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"Photo";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ttl_seconds";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageMedia$messageMediaDocumentMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfac83deb;
        constructor.predicate = @"messageMediaDocumentMeta";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"document";
            arg.type = @"Document";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ttl_seconds";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLWebDocument$webDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc61acbd8;
        constructor.predicate = @"webDocument";
        constructor.type = @"WebDocument";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"attributes";
            arg.type = @"Vector<DocumentAttribute>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLhelp_Support$help_support
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x17c6b5f6;
        constructor.predicate = @"help.support";
        constructor.type = @"help.Support";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user";
            arg.type = @"User";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLTopPeer$topPeer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xedcdc05b;
        constructor.predicate = @"topPeer";
        constructor.type = @"TopPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"Peer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rating";
            arg.type = @"double";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_TopPeers$contacts_topPeersNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xde266ef5;
        constructor.predicate = @"contacts.topPeersNotModified";
        constructor.type = @"contacts.TopPeers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_TopPeers$contacts_topPeers
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x70b772a8;
        constructor.predicate = @"contacts.topPeers";
        constructor.type = @"contacts.TopPeers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"categories";
            arg.type = @"Vector<TopPeerCategoryPeers>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPostAddress$postAddress
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1e8caaeb;
        constructor.predicate = @"postAddress";
        constructor.type = @"PostAddress";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"street_line1";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"street_line2";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"city";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"state";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"country_iso2";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"post_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Suggested$contacts_suggested
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5649dcc5;
        constructor.predicate = @"contacts.suggested";
        constructor.type = @"contacts.Suggested";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<ContactSuggested>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputContact$inputPhoneContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf392b7f4;
        constructor.predicate = @"inputPhoneContact";
        constructor.type = @"InputContact";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"client_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_CodeType$auth_codeTypeSms
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x72a3158c;
        constructor.predicate = @"auth.codeTypeSms";
        constructor.type = @"auth.CodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_CodeType$auth_codeTypeCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x741cd3e3;
        constructor.predicate = @"auth.codeTypeCall";
        constructor.type = @"auth.CodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_CodeType$auth_codeTypeFlashCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x226ccefb;
        constructor.predicate = @"auth.codeTypeFlashCall";
        constructor.type = @"auth.CodeType";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Chats$messages_chats
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x64ff9fd5;
        constructor.predicate = @"messages.chats";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_Chats$messages_chatsSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9cd81144;
        constructor.predicate = @"messages.chatsSlice";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"count";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLFutureSalt$futureSalt
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x949d9dc;
        constructor.predicate = @"futureSalt";
        constructor.type = @"FutureSalt";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"valid_since";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"valid_until";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"salt";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLmessages_PeerDialogs$messages_peerDialogs
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3371c354;
        constructor.predicate = @"messages.peerDialogs";
        constructor.type = @"messages.PeerDialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dialogs";
            arg.type = @"Vector<Dialog>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<Message>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chats";
            arg.type = @"Vector<Chat>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"state";
            arg.type = @"updates.State";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_PaymentResult$payments_paymentResult
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4e5f810d;
        constructor.predicate = @"payments.paymentResult";
        constructor.type = @"payments.PaymentResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"updates";
            arg.type = @"Updates";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLpayments_PaymentResult$payments_paymentVerficationNeeded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6b56b921;
        constructor.predicate = @"payments.paymentVerficationNeeded";
        constructor.type = @"payments.PaymentResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockTitle
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x70abc3fd;
        constructor.predicate = @"pageBlockTitle";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockSubtitle
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8ffa9a1f;
        constructor.predicate = @"pageBlockSubtitle";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockHeader
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbfd064ec;
        constructor.predicate = @"pageBlockHeader";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockSubheader
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf12bb6e1;
        constructor.predicate = @"pageBlockSubheader";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockParagraph
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x467a0766;
        constructor.predicate = @"pageBlockParagraph";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockPreformatted
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc070d93e;
        constructor.predicate = @"pageBlockPreformatted";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"language";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockFooter
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x48870999;
        constructor.predicate = @"pageBlockFooter";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockDivider
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xdb20b188;
        constructor.predicate = @"pageBlockDivider";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockList
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3a58c7f4;
        constructor.predicate = @"pageBlockList";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ordered";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"items";
            arg.type = @"Vector<RichText>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockBlockquote
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x263d7c26;
        constructor.predicate = @"pageBlockBlockquote";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockPullquote
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4f4456d3;
        constructor.predicate = @"pageBlockPullquote";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"text";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9c69982;
        constructor.predicate = @"pageBlockPhoto";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd9d71866;
        constructor.predicate = @"pageBlockVideo";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"video_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockCover
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x39f23300;
        constructor.predicate = @"pageBlockCover";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"cover";
            arg.type = @"PageBlock";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockEmbedPost
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x292c7be9;
        constructor.predicate = @"pageBlockEmbedPost";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"webpage_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"author_photo_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"author";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"blocks";
            arg.type = @"Vector<PageBlock>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockCollage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8b31c4f;
        constructor.predicate = @"pageBlockCollage";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"items";
            arg.type = @"Vector<PageBlock>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockSlideshow
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x130c8963;
        constructor.predicate = @"pageBlockSlideshow";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"items";
            arg.type = @"Vector<PageBlock>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockUnsupported
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x13567e8a;
        constructor.predicate = @"pageBlockUnsupported";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockAnchor
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xce0d37b0;
        constructor.predicate = @"pageBlockAnchor";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockEmbedMeta
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe78f3d36;
        constructor.predicate = @"pageBlockEmbedMeta";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"html";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"poster_photo_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"w";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"h";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockAuthorDate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbaafe5e0;
        constructor.predicate = @"pageBlockAuthorDate";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"author";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"published_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockChannel
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xef1751b5;
        constructor.predicate = @"pageBlockChannel";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"Chat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPageBlock$pageBlockAudio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x31b81a7f;
        constructor.predicate = @"pageBlockAudio";
        constructor.type = @"PageBlock";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"audio_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"RichText";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLResponseIndirect$responseIndirect
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2194f56e;
        constructor.predicate = @"responseIndirect";
        constructor.type = @"ResponseIndirect";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyKey$privacyKeyStatusTimestamp
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbc2eab30;
        constructor.predicate = @"privacyKeyStatusTimestamp";
        constructor.type = @"PrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyKey$privacyKeyChatInvite
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x500e6dfa;
        constructor.predicate = @"privacyKeyChatInvite";
        constructor.type = @"PrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLPrivacyKey$privacyKeyPhoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3d662b7b;
        constructor.predicate = @"privacyKeyPhoneCall";
        constructor.type = @"PrivacyKey";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Contacts$contacts_contacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6f8b8cb2;
        constructor.predicate = @"contacts.contacts";
        constructor.type = @"contacts.Contacts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contacts";
            arg.type = @"Vector<Contact>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<User>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLcontacts_Contacts$contacts_contactsNotModified
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb74ba9d2;
        constructor.predicate = @"contacts.contactsNotModified";
        constructor.type = @"contacts.Contacts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLRPCreq_pq$req_pq
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x60469778;
        constructor.method = @"req_pq";
        constructor.type = @"ResPQ";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCreq_DH_params$req_DH_params
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd712e4be;
        constructor.method = @"req_DH_params";
        constructor.type = @"Server_DH_Params";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"p";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"public_key_fingerprint";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"encrypted_data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCset_client_DH_params$set_client_DH_params
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf5045f1f;
        constructor.method = @"set_client_DH_params";
        constructor.type = @"Set_client_DH_params_answer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server_nonce";
            arg.type = @"int128";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"encrypted_data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCping$ping
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x7abe77ec;
        constructor.method = @"ping";
        constructor.type = @"Pong";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ping_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCping_delay_disconnect$ping_delay_disconnect
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf3427b8c;
        constructor.method = @"ping_delay_disconnect";
        constructor.type = @"Pong";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ping_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"disconnect_delay";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCdestroy_session$destroy_session
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe7512126;
        constructor.method = @"destroy_session";
        constructor.type = @"DestroySessionRes";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"session_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCdestroy_sessions$destroy_sessions
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa13dc52f;
        constructor.method = @"destroy_sessions";
        constructor.type = @"DestroySessionsRes";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"session_ids";
            arg.type = @"vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCget_future_salts$get_future_salts
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb921bd04;
        constructor.method = @"get_future_salts";
        constructor.type = @"FutureSalts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"num";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCrpc_drop_answer$rpc_drop_answer
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x58e4a740;
        constructor.method = @"rpc_drop_answer";
        constructor.type = @"RpcDropAnswer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"req_msg_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_checkPhone$auth_checkPhone
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6fe51dfb;
        constructor.method = @"auth.checkPhone";
        constructor.type = @"auth.CheckedPhone";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_signUp$auth_signUp
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1b067634;
        constructor.method = @"auth.signUp";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_signIn$auth_signIn
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbcd51581;
        constructor.method = @"auth.signIn";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_logOut$auth_logOut
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5717da40;
        constructor.method = @"auth.logOut";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_resetAuthorizations$auth_resetAuthorizations
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9fab0d1a;
        constructor.method = @"auth.resetAuthorizations";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_sendInvites$auth_sendInvites
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x771c1d97;
        constructor.method = @"auth.sendInvites";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_numbers";
            arg.type = @"Vector<string>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_exportAuthorization$auth_exportAuthorization
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe5bfffcd;
        constructor.method = @"auth.exportAuthorization";
        constructor.type = @"auth.ExportedAuthorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"dc_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_importAuthorization$auth_importAuthorization
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe3ef9613;
        constructor.method = @"auth.importAuthorization";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_unregisterDevice$account_unregisterDevice
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x65c55b40;
        constructor.method = @"account.unregisterDevice";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"token_type";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"token";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updateNotifySettings$account_updateNotifySettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x84be5b93;
        constructor.method = @"account.updateNotifySettings";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputNotifyPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"settings";
            arg.type = @"InputPeerNotifySettings";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getNotifySettings$account_getNotifySettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x12b3ad31;
        constructor.method = @"account.getNotifySettings";
        constructor.type = @"PeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputNotifyPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_resetNotifySettings$account_resetNotifySettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdb7e1747;
        constructor.method = @"account.resetNotifySettings";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updateStatus$account_updateStatus
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6628562c;
        constructor.method = @"account.updateStatus";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offline";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getWallPapers$account_getWallPapers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc04cfac2;
        constructor.method = @"account.getWallPapers";
        constructor.type = @"Vector<WallPaper>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCusers_getUsers$users_getUsers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd91a548;
        constructor.method = @"users.getUsers";
        constructor.type = @"Vector<User>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCusers_getFullUser$users_getFullUser
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xca30a5b1;
        constructor.method = @"users.getFullUser";
        constructor.type = @"UserFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getContactIDs$contacts_getContactIDs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x13dc911d;
        constructor.method = @"contacts.getContactIDs";
        constructor.type = @"Vector<int>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getStatuses$contacts_getStatuses
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc4a353ee;
        constructor.method = @"contacts.getStatuses";
        constructor.type = @"Vector<ContactStatus>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getContacts$contacts_getContacts
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x22c6aa08;
        constructor.method = @"contacts.getContacts";
        constructor.type = @"contacts.Contacts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"n_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getRequests$contacts_getRequests
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf10a772e;
        constructor.method = @"contacts.getRequests";
        constructor.type = @"contacts.Requests";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getLink$contacts_getLink
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe51d3c51;
        constructor.method = @"contacts.getLink";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_importContacts$contacts_importContacts
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xda30b32d;
        constructor.method = @"contacts.importContacts";
        constructor.type = @"contacts.ImportedContacts";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contacts";
            arg.type = @"Vector<InputContact>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"replace";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getLocated$contacts_getLocated
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x61b5827c;
        constructor.method = @"contacts.getLocated";
        constructor.type = @"contacts.Located";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hidden";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"radius";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getSuggested$contacts_getSuggested
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xcd773428;
        constructor.method = @"contacts.getSuggested";
        constructor.type = @"contacts.Suggested";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_sendRequest$contacts_sendRequest
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x72ab4b2e;
        constructor.method = @"contacts.sendRequest";
        constructor.type = @"contacts.SentLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_acceptRequest$contacts_acceptRequest
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x946c1f91;
        constructor.method = @"contacts.acceptRequest";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_declineRequest$contacts_declineRequest
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x126a4378;
        constructor.method = @"contacts.declineRequest";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_deleteContact$contacts_deleteContact
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8e953744;
        constructor.method = @"contacts.deleteContact";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_clearContact$contacts_clearContact
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdc6cb6b3;
        constructor.method = @"contacts.clearContact";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_deleteContacts$contacts_deleteContacts
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x59ab389e;
        constructor.method = @"contacts.deleteContacts";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_block$contacts_block
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x332b49fc;
        constructor.method = @"contacts.block";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_unblock$contacts_unblock
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe54100bd;
        constructor.method = @"contacts.unblock";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getBlocked$contacts_getBlocked
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf57c350f;
        constructor.method = @"contacts.getBlocked";
        constructor.type = @"contacts.Blocked";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getMessages$messages_getMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4222fa74;
        constructor.method = @"messages.getMessages";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_restoreMessages$messages_restoreMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x395f9d7e;
        constructor.method = @"messages.restoreMessages";
        constructor.type = @"Vector<int>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getChats$messages_getChats
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3c6aa187;
        constructor.method = @"messages.getChats";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getFullChat$messages_getFullChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3b831c66;
        constructor.method = @"messages.getFullChat";
        constructor.type = @"messages.ChatFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_getDhConfig$phone_getDhConfig
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc4721a8e;
        constructor.method = @"phone.getDhConfig";
        constructor.type = @"phone.DhConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_declineCall$phone_declineCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3a999b28;
        constructor.method = @"phone.declineCall";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupdates_getState$updates_getState
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xedd4882a;
        constructor.method = @"updates.getState";
        constructor.type = @"updates.State";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupdates_subscribe$updates_subscribe
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xfbb329a8;
        constructor.method = @"updates.subscribe";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupdates_unsubscribe$updates_unsubscribe
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8452f78;
        constructor.method = @"updates.unsubscribe";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_getPhotos$photos_getPhotos
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x13258ee;
        constructor.method = @"photos.getPhotos";
        constructor.type = @"photos.Photos";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputPhoto>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_getWall$photos_getWall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x207512c;
        constructor.method = @"photos.getWall";
        constructor.type = @"photos.Photos";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_readWall$photos_readWall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x45c19e6b;
        constructor.method = @"photos.readWall";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_editPhoto$photos_editPhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5159e8c2;
        constructor.method = @"photos.editPhoto";
        constructor.type = @"photos.Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xeef579a0;
        constructor.method = @"photos.updateProfilePhoto";
        constructor.type = @"UserProfilePhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoto";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop";
            arg.type = @"InputPhotoCrop";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_uploadPhoto$photos_uploadPhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9b5965ae;
        constructor.method = @"photos.uploadPhoto";
        constructor.type = @"photos.Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_uploadProfilePhoto$photos_uploadProfilePhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd50f9c88;
        constructor.method = @"photos.uploadProfilePhoto";
        constructor.type = @"photos.Photo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"caption";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop";
            arg.type = @"InputPhotoCrop";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_deletePhotos$photos_deletePhotos
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x87cf7f2f;
        constructor.method = @"photos.deletePhotos";
        constructor.type = @"Vector<long>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputPhoto>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_restorePhotos$photos_restorePhotos
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x23e3d76c;
        constructor.method = @"photos.restorePhotos";
        constructor.type = @"Vector<long>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputPhoto>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_saveFilePart$upload_saveFilePart
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb304a621;
        constructor.method = @"upload.saveFilePart";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_part";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_getFile$upload_getFile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe3a6cfb5;
        constructor.method = @"upload.getFile";
        constructor.type = @"upload.File";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"InputFileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCgeo_saveGeoPlace$geo_saveGeoPlace
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8efd01cc;
        constructor.method = @"geo.saveGeoPlace";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"place_name";
            arg.type = @"InputGeoPlaceName";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getConfig$help_getConfig
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc4f9186b;
        constructor.method = @"help.getConfig";
        constructor.type = @"Config";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getNearestDc$help_getNearestDc
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1fb33026;
        constructor.method = @"help.getNearestDc";
        constructor.type = @"NearestDc";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getScheme$help_getScheme
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdbb69a9e;
        constructor.method = @"help.getScheme";
        constructor.type = @"Scheme";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getAppUpdate$help_getAppUpdate
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc812ac7e;
        constructor.method = @"help.getAppUpdate";
        constructor.type = @"help.AppUpdate";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"device_model";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"system_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getInviteText$help_getInviteText
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa4a95186;
        constructor.method = @"help.getInviteText";
        constructor.type = @"help.InviteText";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getAppPrefs$help_getAppPrefs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x704120a3;
        constructor.method = @"help.getAppPrefs";
        constructor.type = @"help.AppPrefs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"api_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"api_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_saveNetworkStats$help_saveNetworkStats
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbda22fad;
        constructor.method = @"help.saveNetworkStats";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stats";
            arg.type = @"Vector<DcNetworkStats>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_test$help_test
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc0e202f7;
        constructor.method = @"help.test";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontest_saveDeveloperInfo$contest_saveDeveloperInfo
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9a5f6e95;
        constructor.method = @"contest.saveDeveloperInfo";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"vk_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"age";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"city";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_registerDevice$account_registerDevice
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x446c712c;
        constructor.method = @"account.registerDevice";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"token_type";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"token";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"device_model";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"system_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"app_sandbox";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getDhConfig$messages_getDhConfig
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x26cf8950;
        constructor.method = @"messages.getDhConfig";
        constructor.type = @"messages.DhConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_length";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_requestEncryption$messages_requestEncryption
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf64daf43;
        constructor.method = @"messages.requestEncryption";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_acceptEncryption$messages_acceptEncryption
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3dbc0415;
        constructor.method = @"messages.acceptEncryption";
        constructor.type = @"EncryptedChat";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_discardEncryption$messages_discardEncryption
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xedd923c5;
        constructor.method = @"messages.discardEncryption";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x791451ed;
        constructor.method = @"messages.setEncryptedTyping";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"typing";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x7f4b690a;
        constructor.method = @"messages.readEncryptedHistory";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendEncrypted$messages_sendEncrypted
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa9776773;
        constructor.method = @"messages.sendEncrypted";
        constructor.type = @"messages.SentEncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9a901b66;
        constructor.method = @"messages.sendEncryptedFile";
        constructor.type = @"messages.SentEncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputEncryptedFile";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendEncryptedService$messages_sendEncryptedService
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x32d439a4;
        constructor.method = @"messages.sendEncryptedService";
        constructor.type = @"messages.SentEncryptedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"data";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_receivedQueue$messages_receivedQueue
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x55a5bb66;
        constructor.method = @"messages.receivedQueue";
        constructor.type = @"Vector<long>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_qts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_saveBigFilePart$upload_saveBigFilePart
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xde7b673d;
        constructor.method = @"upload.saveBigFilePart";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_part";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_total_parts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bytes";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getSupport$help_getSupport
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9cdf08cd;
        constructor.method = @"help.getSupport";
        constructor.type = @"help.Support";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_setTyping$messages_setTyping
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa3825e50;
        constructor.method = @"messages.setTyping";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"action";
            arg.type = @"SendMessageAction";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_checkUsername$account_checkUsername
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2714d86c;
        constructor.method = @"account.checkUsername";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updateUsername$account_updateUsername
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3e0bdd7c;
        constructor.method = @"account.updateUsername";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_search$contacts_search
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x11f812d8;
        constructor.method = @"contacts.search";
        constructor.type = @"contacts.Found";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getPrivacy$account_getPrivacy
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdadbc950;
        constructor.method = @"account.getPrivacy";
        constructor.type = @"account.PrivacyRules";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"InputPrivacyKey";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_setPrivacy$account_setPrivacy
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc9f81ce8;
        constructor.method = @"account.setPrivacy";
        constructor.type = @"account.PrivacyRules";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key";
            arg.type = @"InputPrivacyKey";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rules";
            arg.type = @"Vector<InputPrivacyRule>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_deleteAccount$account_deleteAccount
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x418d4e0b;
        constructor.method = @"account.deleteAccount";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reason";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getAccountTTL$account_getAccountTTL
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8fc711d;
        constructor.method = @"account.getAccountTTL";
        constructor.type = @"AccountDaysTTL";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_setAccountTTL$account_setAccountTTL
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2442485e;
        constructor.method = @"account.setAccountTTL";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"ttl";
            arg.type = @"AccountDaysTTL";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_changePhone$account_changePhone
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x70c32edb;
        constructor.method = @"account.changePhone";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_setPassword$account_setPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdd2a4d8f;
        constructor.method = @"account.setPassword";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"current_password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_salt";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hint";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_resetAccountPassword$auth_resetAccountPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb68929bf;
        constructor.method = @"auth.resetAccountPassword";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getStickers$messages_getStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xae22e045;
        constructor.method = @"messages.getStickers";
        constructor.type = @"messages.Stickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"emoticon";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x38df3532;
        constructor.method = @"account.updateDeviceLocked";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"period";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_readHistory$messages_readHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb04f2510;
        constructor.method = @"messages.readHistory";
        constructor.type = @"messages.AffectedHistory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_readMessageContents$messages_readMessageContents
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x36a73f77;
        constructor.method = @"messages.readMessageContents";
        constructor.type = @"messages.AffectedMessages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_editChatTitle$messages_editChatTitle
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdc452855;
        constructor.method = @"messages.editChatTitle";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_editChatPhoto$messages_editChatPhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xca4c79d8;
        constructor.method = @"messages.editChatPhoto";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"InputChatPhoto";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_addChatUser$messages_addChatUser
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf9a0aa09;
        constructor.method = @"messages.addChatUser";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"fwd_limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_deleteChatUser$messages_deleteChatUser
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe0611f16;
        constructor.method = @"messages.deleteChatUser";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_createChat$messages_createChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9cb126e;
        constructor.method = @"messages.createChat";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendBroadcast$messages_sendBroadcast
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbf73f4da;
        constructor.method = @"messages.sendBroadcast";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contacts";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"InputMedia";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getWebPagePreview$messages_getWebPagePreview
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x25223e24;
        constructor.method = @"messages.getWebPagePreview";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getAuthorizations$account_getAuthorizations
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe320c158;
        constructor.method = @"account.getAuthorizations";
        constructor.type = @"account.Authorizations";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_resetAuthorization$account_resetAuthorization
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xdf77f3bc;
        constructor.method = @"account.resetAuthorization";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getPassword$account_getPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x548a30f5;
        constructor.method = @"account.getPassword";
        constructor.type = @"account.Password";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getPasswordSettings$account_getPasswordSettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbc8d11bb;
        constructor.method = @"account.getPasswordSettings";
        constructor.type = @"account.PasswordSettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"current_password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xfa7c4b86;
        constructor.method = @"account.updatePasswordSettings";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"current_password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"new_settings";
            arg.type = @"account.PasswordInputSettings";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_checkPassword$auth_checkPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa63011e;
        constructor.method = @"auth.checkPassword";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd897bc66;
        constructor.method = @"auth.requestPasswordRecovery";
        constructor.type = @"auth.PasswordRecovery";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_recoverPassword$auth_recoverPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4ea56e92;
        constructor.method = @"auth.recoverPassword";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_receivedMessages$messages_receivedMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5a954c0;
        constructor.method = @"messages.receivedMessages";
        constructor.type = @"Vector<ReceivedNotifyMessage>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_exportChatInvite$messages_exportChatInvite
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x7d885289;
        constructor.method = @"messages.exportChatInvite";
        constructor.type = @"ExportedChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_checkChatInvite$messages_checkChatInvite
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3eadb1bb;
        constructor.method = @"messages.checkChatInvite";
        constructor.type = @"ChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_importChatInvite$messages_importChatInvite
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6c50051c;
        constructor.method = @"messages.importChatInvite";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getStickerSet$messages_getStickerSet
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2619a90e;
        constructor.method = @"messages.getStickerSet";
        constructor.type = @"messages.StickerSet";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickerset";
            arg.type = @"InputStickerSet";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf96e55de;
        constructor.method = @"messages.uninstallStickerSet";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickerset";
            arg.type = @"InputStickerSet";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphotos_getUserPhotos$photos_getUserPhotos
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x91cd32a8;
        constructor.method = @"photos.getUserPhotos";
        constructor.type = @"photos.Photos";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_search$messages_search
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd4569248;
        constructor.method = @"messages.search";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"filter";
            arg.type = @"MessagesFilter";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_forwardMessages$messages_forwardMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x708e0195;
        constructor.method = @"messages.forwardMessages";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"to_peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getMessagesViews$messages_getMessagesViews
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc4c8a55d;
        constructor.method = @"messages.getMessagesViews";
        constructor.type = @"Vector<int>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"increment";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_reportSpam$messages_reportSpam
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xcf1592db;
        constructor.method = @"messages.reportSpam";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_resolveUsername$contacts_resolveUsername
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf93ccba3;
        constructor.method = @"contacts.resolveUsername";
        constructor.type = @"contacts.ResolvedPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_readHistory$channels_readHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xcc104937;
        constructor.method = @"channels.readHistory";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_deleteMessages$channels_deleteMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x84c1fd4e;
        constructor.method = @"channels.deleteMessages";
        constructor.type = @"messages.AffectedMessages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getMessages$channels_getMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x93d7b347;
        constructor.method = @"channels.getMessages";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getParticipants$channels_getParticipants
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x24d98f92;
        constructor.method = @"channels.getParticipants";
        constructor.type = @"channels.ChannelParticipants";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"filter";
            arg.type = @"ChannelParticipantsFilter";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getParticipant$channels_getParticipant
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x546dd7a6;
        constructor.method = @"channels.getParticipant";
        constructor.type = @"channels.ChannelParticipant";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getChannels$channels_getChannels
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa7f6bbb;
        constructor.method = @"channels.getChannels";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<InputChannel>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getFullChannel$channels_getFullChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8736a09;
        constructor.method = @"channels.getFullChannel";
        constructor.type = @"messages.ChatFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_editAbout$channels_editAbout
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x13e27f1e;
        constructor.method = @"channels.editAbout";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"about";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_editTitle$channels_editTitle
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x566decd0;
        constructor.method = @"channels.editTitle";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_editPhoto$channels_editPhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf12e57c9;
        constructor.method = @"channels.editPhoto";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"photo";
            arg.type = @"InputChatPhoto";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_checkUsername$channels_checkUsername
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x10e6bd2c;
        constructor.method = @"channels.checkUsername";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_updateUsername$channels_updateUsername
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3514b3de;
        constructor.method = @"channels.updateUsername";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"username";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_joinChannel$channels_joinChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x24b524c5;
        constructor.method = @"channels.joinChannel";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_leaveChannel$channels_leaveChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf836aa95;
        constructor.method = @"channels.leaveChannel";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_inviteToChannel$channels_inviteToChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x199f3a6c;
        constructor.method = @"channels.inviteToChannel";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"users";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_exportInvite$channels_exportInvite
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc7560885;
        constructor.method = @"channels.exportInvite";
        constructor.type = @"ExportedChatInvite";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_deleteChannel$channels_deleteChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc0111fe3;
        constructor.method = @"channels.deleteChannel";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupdates_getChannelDifference$updates_getChannelDifference
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbb32d7c0;
        constructor.method = @"updates.getChannelDifference";
        constructor.type = @"updates.ChannelDifference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"filter";
            arg.type = @"ChannelMessagesFilter";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xec8bd9e1;
        constructor.method = @"messages.toggleChatAdmins";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_editChatAdmin$messages_editChatAdmin
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa9e69f2e;
        constructor.method = @"messages.editChatAdmin";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"is_admin";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_createChannel$channels_createChannel
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf4893d7f;
        constructor.method = @"channels.createChannel";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"about";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_deactivateChat$messages_deactivateChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x626f0b41;
        constructor.method = @"messages.deactivateChat";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_migrateChat$messages_migrateChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x15a3b8e3;
        constructor.method = @"messages.migrateChat";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_searchGlobal$messages_searchGlobal
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9e3cacb0;
        constructor.method = @"messages.searchGlobal";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_startBot$messages_startBot
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe6df7378;
        constructor.method = @"messages.startBot";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"bot";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"start_param";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_reportPeer$account_reportPeer
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xae189d5f;
        constructor.method = @"account.reportPeer";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reason";
            arg.type = @"ReportReason";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getTermsOfService$help_getTermsOfService
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x37d78f83;
        constructor.method = @"help.getTermsOfService";
        constructor.type = @"help.TermsOfService";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getAllStickers$messages_getAllStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1c9618b1;
        constructor.method = @"messages.getAllStickers";
        constructor.type = @"messages.AllStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_searchGifs$messages_searchGifs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbf9a776b;
        constructor.method = @"messages.searchGifs";
        constructor.type = @"messages.FoundGifs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getSavedGifs$messages_getSavedGifs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x83bf3d52;
        constructor.method = @"messages.getSavedGifs";
        constructor.type = @"messages.SavedGifs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_saveGif$messages_saveGif
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x327a30cb;
        constructor.method = @"messages.saveGif";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputDocument";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unsave";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getDocumentByHash$messages_getDocumentByHash
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x338e2464;
        constructor.method = @"messages.getDocumentByHash";
        constructor.type = @"Document";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"sha256";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"size";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_toggleInvites$channels_toggleInvites
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x49609307;
        constructor.method = @"channels.toggleInvites";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_exportMessageLink$channels_exportMessageLink
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc846d22d;
        constructor.method = @"channels.exportMessageLink";
        constructor.type = @"ExportedMessageLink";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_toggleSignatures$channels_toggleSignatures
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1f69b606;
        constructor.method = @"channels.toggleSignatures";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"enabled";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_updatePinnedMessage$channels_updatePinnedMessage
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa72ded52;
        constructor.method = @"channels.updatePinnedMessage";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_deleteUserHistory$channels_deleteUserHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd10dd71b;
        constructor.method = @"channels.deleteUserHistory";
        constructor.type = @"messages.AffectedHistory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_reportSpam$channels_reportSpam
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xfe087810;
        constructor.method = @"channels.reportSpam";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_hideReportSpam$messages_hideReportSpam
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa8f1709b;
        constructor.method = @"messages.hideReportSpam";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getPeerSettings$messages_getPeerSettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3672e09c;
        constructor.method = @"messages.getPeerSettings";
        constructor.type = @"PeerSettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_resendCode$auth_resendCode
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3ef1a9bf;
        constructor.method = @"auth.resendCode";
        constructor.type = @"auth.SentCode";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCauth_cancelCode$auth_cancelCode
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1f040578;
        constructor.method = @"auth.cancelCode";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_number";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getMessageEditData$messages_getMessageEditData
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xfda68d36;
        constructor.method = @"messages.getMessageEditData";
        constructor.type = @"messages.MessageEditData";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_getTopPeers$contacts_getTopPeers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd4982db5;
        constructor.method = @"contacts.getTopPeers";
        constructor.type = @"contacts.TopPeers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1ae373ac;
        constructor.method = @"contacts.resetTopPeerRating";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"category";
            arg.type = @"TopPeerCategory";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getPeerDialogs$messages_getPeerDialogs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2d9776b9;
        constructor.method = @"messages.getPeerDialogs";
        constructor.type = @"messages.PeerDialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peers";
            arg.type = @"Vector<InputPeer>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getAllDrafts$messages_getAllDrafts
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6a3f8d65;
        constructor.method = @"messages.getAllDrafts";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_deleteHistory$messages_deleteHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1c015b09;
        constructor.method = @"messages.deleteHistory";
        constructor.type = @"messages.AffectedHistory";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getFeaturedStickers$messages_getFeaturedStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2dacca4f;
        constructor.method = @"messages.getFeaturedStickers";
        constructor.type = @"messages.FeaturedStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getUnusedStickers$messages_getUnusedStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa978d356;
        constructor.method = @"messages.getUnusedStickers";
        constructor.type = @"Vector<StickerSet>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_saveRecentSticker$messages_saveRecentSticker
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x348e39bf;
        constructor.method = @"messages.saveRecentSticker";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputDocument";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"unsave";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_installStickerSet$messages_installStickerSet
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc78fe460;
        constructor.method = @"messages.installStickerSet";
        constructor.type = @"messages.StickerSetInstallResult";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"stickerset";
            arg.type = @"InputStickerSet";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"archived";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_confirmPhone$account_confirmPhone
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5f2178c3;
        constructor.method = @"account.confirmPhone";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code_hash";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getAdminedPublicChannels$channels_getAdminedPublicChannels
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8d8d82d7;
        constructor.method = @"channels.getAdminedPublicChannels";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getMaskStickers$messages_getMaskStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x65b8c79f;
        constructor.method = @"messages.getMaskStickers";
        constructor.type = @"messages.AllStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_readFeaturedStickers$messages_readFeaturedStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5b118126;
        constructor.method = @"messages.readFeaturedStickers";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_reorderStickerSets$messages_reorderStickerSets
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x78337739;
        constructor.method = @"messages.reorderStickerSets";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"order";
            arg.type = @"Vector<long>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getAttachedStickers$messages_getAttachedStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xcc5b67cc;
        constructor.method = @"messages.getAttachedStickers";
        constructor.type = @"Vector<StickerSetCovered>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"InputStickeredMedia";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getRecentStickers$messages_getRecentStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5ea192c9;
        constructor.method = @"messages.getRecentStickers";
        constructor.type = @"messages.RecentStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_clearRecentStickers$messages_clearRecentStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8999602d;
        constructor.method = @"messages.clearRecentStickers";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getArchivedStickers$messages_getArchivedStickers
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x57f17692;
        constructor.method = @"messages.getArchivedStickers";
        constructor.type = @"messages.ArchivedStickers";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupdates_getDifference$updates_getDifference
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x25939651;
        constructor.method = @"updates.getDifference";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"qts";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getCommonChats$messages_getCommonChats
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd0a48c4;
        constructor.method = @"messages.getCommonChats";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getAllChats$messages_getAllChats
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xeba80ff0;
        constructor.method = @"messages.getAllChats";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"except_ids";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getWebPage$messages_getWebPage
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x32ca8f91;
        constructor.method = @"messages.getWebPage";
        constructor.type = @"WebPage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"url";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hash";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getHistory$messages_getHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xafa92846;
        constructor.method = @"messages.getHistory";
        constructor.type = @"messages.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"add_offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_toggleDialogPin$messages_toggleDialogPin
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3289be6a;
        constructor.method = @"messages.toggleDialogPin";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x959ff644;
        constructor.method = @"messages.reorderPinnedDialogs";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"order";
            arg.type = @"Vector<InputPeer>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe254d64e;
        constructor.method = @"messages.getPinnedDialogs";
        constructor.type = @"messages.PeerDialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_getDialogs$messages_getDialogs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x191ba9c5;
        constructor.method = @"messages.getDialogs";
        constructor.type = @"messages.Dialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset_peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_deleteMessages$messages_deleteMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe58e95d2;
        constructor.method = @"messages.deleteMessages";
        constructor.type = @"messages.AffectedMessages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"Vector<int>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4b0c8c0f;
        constructor.method = @"messages.reportEncryptedSpam";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputEncryptedChat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_requestCall$phone_requestCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x5b95b3d4;
        constructor.method = @"phone.requestCall";
        constructor.type = @"phone.PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_acceptCall$phone_acceptCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3bd2b4a0;
        constructor.method = @"phone.acceptCall";
        constructor.type = @"phone.PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_receivedCall$phone_receivedCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x17d54f61;
        constructor.method = @"phone.receivedCall";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_discardCall$phone_discardCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x78d413a6;
        constructor.method = @"phone.discardCall";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"duration";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reason";
            arg.type = @"PhoneCallDiscardReason";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"connection_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_setCallRating$phone_setCallRating
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1c536a34;
        constructor.method = @"phone.setCallRating";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"rating";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"comment";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_getWebFile$upload_getWebFile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x24e6818d;
        constructor.method = @"upload.getWebFile";
        constructor.type = @"upload.WebFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"InputWebFileLocation";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCpayments_getPaymentForm$payments_getPaymentForm
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x99f09745;
        constructor.method = @"payments.getPaymentForm";
        constructor.type = @"payments.PaymentForm";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa092a980;
        constructor.method = @"payments.getPaymentReceipt";
        constructor.type = @"payments.PaymentReceipt";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x770a8e74;
        constructor.method = @"payments.validateRequestedInfo";
        constructor.type = @"payments.ValidatedRequestedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"info";
            arg.type = @"PaymentRequestedInfo";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getTmpPassword$account_getTmpPassword
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4a82327e;
        constructor.method = @"account.getTmpPassword";
        constructor.type = @"account.TmpPassword";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"password_hash";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"period";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCpayments_getSavedInfo$payments_getSavedInfo
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x227d824b;
        constructor.method = @"payments.getSavedInfo";
        constructor.type = @"payments.SavedInfo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCpayments_clearSavedInfo$payments_clearSavedInfo
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xd83d70c1;
        constructor.method = @"payments.clearSavedInfo";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getAppChangelog$help_getAppChangelog
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9010ef6f;
        constructor.method = @"help.getAppChangelog";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"prev_app_version";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_getCallConfig$phone_getCallConfig
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x55451fa9;
        constructor.method = @"phone.getCallConfig";
        constructor.type = @"DataJSON";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_saveCallDebug$phone_saveCallDebug
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x277add7e;
        constructor.method = @"phone.saveCallDebug";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"debug";
            arg.type = @"DataJSON";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCphone_confirmCall$phone_confirmCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2efe1722;
        constructor.method = @"phone.confirmCall";
        constructor.type = @"phone.PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"g_a";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"key_fingerprint";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"protocol";
            arg.type = @"PhoneCallProtocol";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_getCdnFile$upload_getCdnFile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2000bcc3;
        constructor.method = @"upload.getCdnFile";
        constructor.type = @"upload.CdnFile";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPChelp_getCdnConfig$help_getCdnConfig
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x52029342;
        constructor.method = @"help.getCdnConfig";
        constructor.type = @"CdnConfig";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPClangpack_getLangPack$langpack_getLangPack
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x9ab5c58e;
        constructor.method = @"langpack.getLangPack";
        constructor.type = @"LangPackDifference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPClangpack_getStrings$langpack_getStrings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x2e1ee318;
        constructor.method = @"langpack.getStrings";
        constructor.type = @"Vector<LangPackString>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"lang_code";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"keys";
            arg.type = @"Vector<string>";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPClangpack_getDifference$langpack_getDifference
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb2e4d7d;
        constructor.method = @"langpack.getDifference";
        constructor.type = @"LangPackDifference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"from_version";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPClangpack_getLanguages$langpack_getLanguages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x800fd57d;
        constructor.method = @"langpack.getLanguages";
        constructor.type = @"Vector<LangPackLanguage>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_editAdmin$channels_editAdmin
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x20b88214;
        constructor.method = @"channels.editAdmin";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admin_rights";
            arg.type = @"ChannelAdminRights";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_editBanned$channels_editBanned
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xbfd915cd;
        constructor.method = @"channels.editBanned";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user_id";
            arg.type = @"InputUser";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"banned_rights";
            arg.type = @"ChannelBannedRights";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCchannels_getAdminLogMeta$channels_getAdminLogMeta
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3e9a6fbd;
        constructor.method = @"channels.getAdminLogMeta";
        constructor.type = @"channels.AdminLogResults";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"flags";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"channel";
            arg.type = @"InputChannel";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"q";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"events_filter";
            arg.type = @"ChannelAdminLogEventsFilter";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"admins";
            arg.type = @"Vector<InputUser>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"max_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"min_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"limit";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x1af91c09;
        constructor.method = @"upload.reuploadCdnFile";
        constructor.type = @"Vector<CdnFileHash>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"request_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf715c87b;
        constructor.method = @"upload.getCdnFileHashes";
        constructor.type = @"Vector<CdnFileHash>";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_token";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendScreenshotNotification$messages_sendScreenshotNotification
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xc97df020;
        constructor.method = @"messages.sendScreenshotNotification";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"reply_to_msg_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }

    TLScheme$scheme *TLmetaScheme = [[TLScheme$scheme alloc] init];
    TLmetaScheme.types = TLmetaSchemeTypes;
    TLmetaScheme.methods = TLmetaSchemeMethods;
    return TLmetaScheme;
}

