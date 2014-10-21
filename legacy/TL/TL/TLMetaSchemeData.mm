#import "TLMetaSchemeData.h"

TLScheme *TLgetMetaScheme()
{
    NSMutableArray *TLmetaSchemeTypes = [[NSMutableArray alloc] init];
    NSMutableArray *TLmetaSchemeMethods = [[NSMutableArray alloc] init];
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
        //TLmessages_StatedMessages$messages_statedMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x969478bb;
        constructor.predicate = @"messages.statedMessages";
        constructor.type = @"messages.StatedMessages";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
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
        //TLmessages_StatedMessages$messages_statedMessagesLinks
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3e74f5c6;
        constructor.predicate = @"messages.statedMessagesLinks";
        constructor.type = @"messages.StatedMessages";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"links";
            arg.type = @"Vector<contacts.Link>";
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
            arg.name = @"seq";
            arg.type = @"int";
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
        //TLInputUser$inputUserContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x86e94f65;
        constructor.predicate = @"inputUserContact";
        constructor.type = @"InputUser";
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
        //TLInputUser$inputUserForeign
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x655e74ff;
        constructor.predicate = @"inputUserForeign";
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
        //TLSendMessageAction$sendMessageUploadVideoAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x92042ff7;
        constructor.predicate = @"sendMessageUploadVideoAction";
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
        //TLSendMessageAction$sendMessageUploadAudioAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe6ac8a6f;
        constructor.predicate = @"sendMessageUploadAudioAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadPhotoAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x990a3c1a;
        constructor.predicate = @"sendMessageUploadPhotoAction";
        constructor.type = @"SendMessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLSendMessageAction$sendMessageUploadDocumentAction
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8faee98e;
        constructor.predicate = @"sendMessageUploadDocumentAction";
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
        //TLGeoChatMessage$geoChatMessageEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x60311a9b;
        constructor.predicate = @"geoChatMessageEmpty";
        constructor.type = @"GeoChatMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
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
        //TLGeoChatMessage$geoChatMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4505f8e1;
        constructor.predicate = @"geoChatMessage";
        constructor.type = @"GeoChatMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
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
        //TLGeoChatMessage$geoChatMessageService
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd34fa24e;
        constructor.predicate = @"geoChatMessageService";
        constructor.type = @"GeoChatMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"chat_id";
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
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"action";
            arg.type = @"MessageAction";
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
        //TLInputFileLocation$inputVideoFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3d0364ec;
        constructor.predicate = @"inputVideoFileLocation";
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
        //TLInputFileLocation$inputAudioFileLocation
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x74dc404d;
        constructor.predicate = @"inputAudioFileLocation";
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
        constructor.n_id = (int32_t)0x4e45abe9;
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
        //TLPhoto$photo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x22b56751;
        constructor.predicate = @"photo";
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
            arg.name = @"sizes";
            arg.type = @"Vector<PhotoSize>";
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
        //TLmessages_AffectedHistory$messages_affectedHistory
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb7de36f2;
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
            arg.name = @"seq";
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
        //TLInvokeWithLayer18$invokeWithLayer18
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1c900537;
        constructor.predicate = @"invokeWithLayer18";
        constructor.type = @"InvokeWithLayer18";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLcontacts_Link$contacts_link
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xeccea3f5;
        constructor.predicate = @"contacts.link";
        constructor.type = @"contacts.Link";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"my_link";
            arg.type = @"contacts.MyLink";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"foreign_link";
            arg.type = @"contacts.ForeignLink";
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
        constructor.n_id = (int32_t)0x94254732;
        constructor.predicate = @"inputChatUploadedPhoto";
        constructor.type = @"InputChatPhoto";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"crop";
            arg.type = @"InputPhotoCrop";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputChatPhoto$inputChatPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xb2e1bf08;
        constructor.predicate = @"inputChatPhoto";
        constructor.type = @"InputChatPhoto";
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
        //TLUpdate$updateNewMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x13abdb3;
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
        //TLUpdate$updateReadMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc6649e31;
        constructor.predicate = @"updateReadMessages";
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
        //TLUpdate$updateDeleteMessages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa92bfe26;
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
        //TLUpdate$updateContactLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x51a48a9a;
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
            arg.type = @"contacts.MyLink";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"foreign_link";
            arg.type = @"contacts.ForeignLink";
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
        //TLUpdate$updateNewAuthorization
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8f06529a;
        constructor.predicate = @"updateNewAuthorization";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"auth_key_id";
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
            arg.name = @"device";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"location";
            arg.type = @"string";
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
        //TLUpdate$updateNewGeoChatMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5a68e3f7;
        constructor.predicate = @"updateNewGeoChatMessage";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"GeoChatMessage";
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
        //TLUpdate$updateChatParticipantAdd
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3a0eeb22;
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
            arg.name = @"version";
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
        //TLUpdate$updateServiceNotification
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x382dd3e4;
        constructor.predicate = @"updateServiceNotification";
        constructor.type = @"Update";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
            arg.name = @"popup";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
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
        //TLAudio$audioEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x586988d8;
        constructor.predicate = @"audioEmpty";
        constructor.type = @"Audio";
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
        //TLAudio$audio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc7ac6496;
        constructor.predicate = @"audio";
        constructor.type = @"Audio";
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
            arg.name = @"duration";
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
            arg.name = @"dc_id";
            arg.type = @"int";
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
        //TLRpcError$rpc_req_error
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7ae432f5;
        constructor.predicate = @"rpc_req_error";
        constructor.type = @"RpcError";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"query_id";
            arg.type = @"long";
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
        //TLMessage$messageForwarded
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa367e716;
        constructor.predicate = @"messageForwarded";
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
            arg.name = @"fwd_from_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"fwd_date";
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
        //TLMessage$messageService
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1d86f70e;
        constructor.predicate = @"messageService";
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
            arg.name = @"action";
            arg.type = @"MessageAction";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLChatParticipants$chatParticipantsForbidden
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfd2bb8a;
        constructor.predicate = @"chatParticipantsForbidden";
        constructor.type = @"ChatParticipants";
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
        //TLChatParticipants$chatParticipants
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7841b415;
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
            arg.name = @"admin_id";
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
        //TLInputNotifyPeer$inputNotifyGeoChatPeer
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4d8ddec8;
        constructor.predicate = @"inputNotifyGeoChatPeer";
        constructor.type = @"InputNotifyPeer";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputAudio$inputAudioEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd95adc84;
        constructor.predicate = @"inputAudioEmpty";
        constructor.type = @"InputAudio";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputAudio$inputAudio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x77d440ff;
        constructor.predicate = @"inputAudio";
        constructor.type = @"InputAudio";
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
        //TLgeochats_StatedMessage$geochats_statedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x17b1578b;
        constructor.predicate = @"geochats.statedMessage";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"message";
            arg.type = @"GeoChatMessage";
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
            arg.name = @"seq";
            arg.type = @"int";
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
        constructor.n_id = (int32_t)0x9efc6326;
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
            arg.name = @"file_name";
            arg.type = @"string";
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
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputVideo$inputVideoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5508ec75;
        constructor.predicate = @"inputVideoEmpty";
        constructor.type = @"InputVideo";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputVideo$inputVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xee579652;
        constructor.predicate = @"inputVideo";
        constructor.type = @"InputVideo";
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
        //TLConfig$config
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2e54dd74;
        constructor.predicate = @"config";
        constructor.type = @"Config";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"date";
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
            arg.name = @"broadcast_size_max";
            arg.type = @"int";
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
        //TLcontacts_Found$contacts_found
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x566000e;
        constructor.predicate = @"contacts.found";
        constructor.type = @"contacts.Found";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<ContactFound>";
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
        //TLauth_Authorization$auth_authorization
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xf6b673a4;
        constructor.predicate = @"auth.authorization";
        constructor.type = @"auth.Authorization";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"expires";
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
        //TLContactStatus$contactStatus
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xaa77b873;
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
            arg.name = @"expires";
            arg.type = @"int";
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
        //TLInputMedia$inputMediaUploadedPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2dc53a7d;
        constructor.predicate = @"inputMediaUploadedPhoto";
        constructor.type = @"InputMedia";
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
        //TLInputMedia$inputMediaPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8f2ab2ec;
        constructor.predicate = @"inputMediaPhoto";
        constructor.type = @"InputMedia";
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
        //TLInputMedia$inputMediaVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7f023ae6;
        constructor.predicate = @"inputMediaVideo";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputVideo";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaAudio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x89938781;
        constructor.predicate = @"inputMediaAudio";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputAudio";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x34e794bd;
        constructor.predicate = @"inputMediaUploadedDocument";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedThumbDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3e46de5d;
        constructor.predicate = @"inputMediaUploadedThumbDocument";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
            arg.name = @"file_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd184e841;
        constructor.predicate = @"inputMediaDocument";
        constructor.type = @"InputMedia";
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
        //TLInputMedia$inputMediaUploadedAudio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x4e498cab;
        constructor.predicate = @"inputMediaUploadedAudio";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
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
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x133ad6f6;
        constructor.predicate = @"inputMediaUploadedVideo";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"file";
            arg.type = @"InputFile";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLInputMedia$inputMediaUploadedThumbVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9912dabf;
        constructor.predicate = @"inputMediaUploadedThumbVideo";
        constructor.type = @"InputMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"mime_type";
            arg.type = @"string";
            [fields addObject:arg];
        }
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
        //TLUserFull$userFull
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x771095da;
        constructor.predicate = @"userFull";
        constructor.type = @"UserFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"user";
            arg.type = @"User";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"link";
            arg.type = @"contacts.Link";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"profile_photo";
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
            arg.name = @"blocked";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"real_first_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"real_last_name";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLDialog$dialog
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xab3a99ac;
        constructor.predicate = @"dialog";
        constructor.type = @"Dialog";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLChat$chat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6e9c9bc7;
        constructor.predicate = @"chat";
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
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"left";
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
        //TLChat$chatForbidden
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xfb0ccc41;
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
        //TLChat$geoChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x75eaea5a;
        constructor.predicate = @"geoChat";
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
            arg.name = @"address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"venue";
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
            arg.name = @"date";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"checked_in";
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
        //TLInputGeoChat$inputGeoChat
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x74d456fa;
        constructor.predicate = @"inputGeoChat";
        constructor.type = @"InputGeoChat";
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
        //TLauth_SentCode$auth_sentCodePreview
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x3cf5727a;
        constructor.predicate = @"auth.sentCodePreview";
        constructor.type = @"auth.SentCode";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_registered";
            arg.type = @"Bool";
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
            arg.name = @"phone_code_test";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCode$auth_sentPassPhrase
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1a1e1fae;
        constructor.predicate = @"auth.sentPassPhrase";
        constructor.type = @"auth.SentCode";
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
        //TLauth_SentCode$auth_sentCode
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xefed51d9;
        constructor.predicate = @"auth.sentCode";
        constructor.type = @"auth.SentCode";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_registered";
            arg.type = @"Bool";
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
            arg.name = @"send_call_timeout";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"is_password";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLauth_SentCode$auth_sentAppCode
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe325edcf;
        constructor.predicate = @"auth.sentAppCode";
        constructor.type = @"auth.SentCode";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_registered";
            arg.type = @"Bool";
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
            arg.name = @"send_call_timeout";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"is_password";
            arg.type = @"Bool";
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
        //TLgeochats_Messages$geochats_messages
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd1526db1;
        constructor.predicate = @"geochats.messages";
        constructor.type = @"geochats.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<GeoChatMessage>";
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
        //TLgeochats_Messages$geochats_messagesSlice
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xbc5863e8;
        constructor.predicate = @"geochats.messagesSlice";
        constructor.type = @"geochats.Messages";
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
            arg.type = @"Vector<GeoChatMessage>";
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
        //TLVideo$videoEmpty
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc10658a8;
        constructor.predicate = @"videoEmpty";
        constructor.type = @"Video";
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
        //TLVideo$video
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x388fa391;
        constructor.predicate = @"video";
        constructor.type = @"Video";
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
            arg.name = @"duration";
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
        //TLContactFound$contactFound
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xea879f95;
        constructor.predicate = @"contactFound";
        constructor.type = @"ContactFound";
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
        //TLDcOption$dcOption
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2ec2a43c;
        constructor.predicate = @"dcOption";
        constructor.type = @"DcOption";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"hostname";
            arg.type = @"string";
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
            arg.name = @"port";
            arg.type = @"int";
            [fields addObject:arg];
        }
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
        //TLInputPeer$inputPeerContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x1023dbe8;
        constructor.predicate = @"inputPeerContact";
        constructor.type = @"InputPeer";
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
        //TLInputPeer$inputPeerForeign
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x9b447325;
        constructor.predicate = @"inputPeerForeign";
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
        //TLInputPeerNotifySettings$inputPeerNotifySettings
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x46a2ce98;
        constructor.predicate = @"inputPeerNotifySettings";
        constructor.type = @"InputPeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"show_previews";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"events_mask";
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
        //TLauth_CheckedPhone$auth_checkedPhone
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe300cc3b;
        constructor.predicate = @"auth.checkedPhone";
        constructor.type = @"auth.CheckedPhone";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_registered";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone_invited";
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
        constructor.n_id = (int32_t)0x8d5e11ee;
        constructor.predicate = @"peerNotifySettings";
        constructor.type = @"PeerNotifySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"show_previews";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"events_mask";
            arg.type = @"int";
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
        //TLmessages_StatedMessage$messages_statedMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd07ae726;
        constructor.predicate = @"messages.statedMessage";
        constructor.type = @"messages.StatedMessage";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"pts";
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
        //TLmessages_StatedMessage$messages_statedMessageLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa9af2881;
        constructor.predicate = @"messages.statedMessageLink";
        constructor.type = @"messages.StatedMessage";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"links";
            arg.type = @"Vector<contacts.Link>";
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
            arg.name = @"seq";
            arg.type = @"int";
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
        //TLcontacts_ImportedContacts$contacts_importedContacts
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xad524315;
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
        //TLUpdates$updateShortMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd3f45784;
        constructor.predicate = @"updateShortMessage";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
            arg.name = @"message";
            arg.type = @"string";
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
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUpdates$updateShortChatMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2b2fbd4e;
        constructor.predicate = @"updateShortChatMessage";
        constructor.type = @"Updates";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
            arg.name = @"chat_id";
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
            arg.name = @"seq";
            arg.type = @"int";
            [fields addObject:arg];
        }
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
        //TLChatFull$chatFull
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x630e61be;
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
        //TLMessageAction$messageActionChatAddUser
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x5e3cfc4b;
        constructor.predicate = @"messageActionChatAddUser";
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
        //TLMessageAction$messageActionGeoChatCreate
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x6f038ebc;
        constructor.predicate = @"messageActionGeoChatCreate";
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
            arg.name = @"address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLMessageAction$messageActionGeoChatCheckin
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc7d53de;
        constructor.predicate = @"messageActionGeoChatCheckin";
        constructor.type = @"MessageAction";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLUser$userSelf
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x7007b451;
        constructor.predicate = @"userSelf";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"phone";
            arg.type = @"string";
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
            arg.name = @"status";
            arg.type = @"UserStatus";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"inactive";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUser$userContact
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xcab35e18;
        constructor.predicate = @"userContact";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
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
            arg.name = @"photo";
            arg.type = @"UserProfilePhoto";
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
        //TLUser$userRequest
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd9ccc4ef;
        constructor.predicate = @"userRequest";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
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
            arg.name = @"photo";
            arg.type = @"UserProfilePhoto";
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
        //TLUser$userForeign
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x75cf7a8;
        constructor.predicate = @"userForeign";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"access_hash";
            arg.type = @"long";
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
            arg.name = @"status";
            arg.type = @"UserStatus";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeTypes addObject:constructor];
    }
    {
        //TLUser$userDeleted
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd6016d7a;
        constructor.predicate = @"userDeleted";
        constructor.type = @"User";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
        //TLgeochats_Located$geochats_located
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x48feb267;
        constructor.predicate = @"geochats.located";
        constructor.type = @"geochats.Located";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"results";
            arg.type = @"Vector<ChatLocated>";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"messages";
            arg.type = @"Vector<GeoChatMessage>";
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
        //TLPhoneCall$phoneCall
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xec7bbe3;
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
            arg.name = @"user_id";
            arg.type = @"int";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"callee_id";
            arg.type = @"int";
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
        constructor.n_id = (int32_t)0x3a84026a;
        constructor.predicate = @"phoneConnection";
        constructor.type = @"PhoneConnection";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"server";
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
            arg.name = @"stream_id";
            arg.type = @"long";
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
        //TLMessageMedia$messageMediaPhoto
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc8c45a2a;
        constructor.predicate = @"messageMediaPhoto";
        constructor.type = @"MessageMedia";
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
        //TLMessageMedia$messageMediaVideo
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xa2d24290;
        constructor.predicate = @"messageMediaVideo";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"video";
            arg.type = @"Video";
            [fields addObject:arg];
        }
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
        constructor.n_id = (int32_t)0x29632a36;
        constructor.predicate = @"messageMediaUnsupported";
        constructor.type = @"MessageMedia";
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
        //TLMessageMedia$messageMediaDocument
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x2fda2204;
        constructor.predicate = @"messageMediaDocument";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLMessageMedia$messageMediaAudio
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xc6b68300;
        constructor.predicate = @"messageMediaAudio";
        constructor.type = @"MessageMedia";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"audio";
            arg.type = @"Audio";
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
        //TLmessages_Chats$messages_chats
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0x8150cbd8;
        constructor.predicate = @"messages.chats";
        constructor.type = @"messages.Chats";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLmessages_SentMessage$messages_sentMessage
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xd1f4d35c;
        constructor.predicate = @"messages.sentMessage";
        constructor.type = @"messages.SentMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
            arg.name = @"pts";
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
        //TLmessages_SentMessage$messages_sentMessageLink
        TLSchemeType$schemeType *constructor = [[TLSchemeType$schemeType alloc] init];
        constructor.n_id = (int32_t)0xe9db4a3f;
        constructor.predicate = @"messages.sentMessageLink";
        constructor.type = @"messages.SentMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
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
            arg.name = @"pts";
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
            arg.name = @"links";
            arg.type = @"Vector<contacts.Link>";
            [fields addObject:arg];
        }
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
        //TLRPCauth_sendCall$auth_sendCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3c51564;
        constructor.method = @"auth.sendCall";
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
        //TLRPCaccount_updateGlobalPrivacySettings$account_updateGlobalPrivacySettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6d73d48f;
        constructor.method = @"account.updateGlobalPrivacySettings";
        constructor.type = @"Bool";
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
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_getGlobalPrivacySettings$account_getGlobalPrivacySettings
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xeb2b4cf6;
        constructor.method = @"account.getGlobalPrivacySettings";
        constructor.type = @"GlobalPrivacySettings";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCaccount_updateProfile$account_updateProfile
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf0888d68;
        constructor.method = @"account.updateProfile";
        constructor.type = @"User";
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
        //TLRPCmessages_getDialogs$messages_getDialogs
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xeccf1df6;
        constructor.method = @"messages.getDialogs";
        constructor.type = @"messages.Dialogs";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLRPCmessages_getHistory$messages_getHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x92a1df2f;
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
        //TLRPCmessages_search$messages_search
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x7e9f2ab;
        constructor.method = @"messages.search";
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
        //TLRPCmessages_deleteHistory$messages_deleteHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xf4f8fb61;
        constructor.method = @"messages.deleteHistory";
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
            arg.name = @"offset";
            arg.type = @"int";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_deleteMessages$messages_deleteMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x14f2dd0a;
        constructor.method = @"messages.deleteMessages";
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
        //TLRPCmessages_receivedMessages$messages_receivedMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x28abcb68;
        constructor.method = @"messages.receivedMessages";
        constructor.type = @"Vector<int>";
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
        //TLRPCmessages_sendMessage$messages_sendMessage
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4cde0aab;
        constructor.method = @"messages.sendMessage";
        constructor.type = @"messages.SentMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
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
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendMedia$messages_sendMedia
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa3c85d76;
        constructor.method = @"messages.sendMedia";
        constructor.type = @"messages.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputPeer";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"InputMedia";
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
    {
        //TLRPCmessages_forwardMessages$messages_forwardMessages
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x514cd10f;
        constructor.method = @"messages.forwardMessages";
        constructor.type = @"messages.StatedMessages";
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
        //TLRPCmessages_editChatTitle$messages_editChatTitle
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb4bc68b5;
        constructor.method = @"messages.editChatTitle";
        constructor.type = @"messages.StatedMessage";
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
        constructor.n_id = (int32_t)0xd881821d;
        constructor.method = @"messages.editChatPhoto";
        constructor.type = @"messages.StatedMessage";
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
        constructor.n_id = (int32_t)0x2ee9ee9e;
        constructor.method = @"messages.addChatUser";
        constructor.type = @"messages.StatedMessage";
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
        constructor.n_id = (int32_t)0xc3c5cd23;
        constructor.method = @"messages.deleteChatUser";
        constructor.type = @"messages.StatedMessage";
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
        constructor.n_id = (int32_t)0x419d9aee;
        constructor.method = @"messages.createChat";
        constructor.type = @"messages.StatedMessage";
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
        //TLRPCphone_requestCall$phone_requestCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x101981ed;
        constructor.method = @"phone.requestCall";
        constructor.type = @"PhoneCall";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLRPCphone_confirmCall$phone_confirmCall
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3e383969;
        constructor.method = @"phone.confirmCall";
        constructor.type = @"PhoneConnection";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"id";
            arg.type = @"InputPhoneCall";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"a_or_b";
            arg.type = @"bytes";
            [fields addObject:arg];
        }
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
        //TLRPCphotos_getUserPhotos$photos_getUserPhotos
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb7ee553c;
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
        //TLRPCmessages_forwardMessage$messages_forwardMessage
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x3f3f4f2;
        constructor.method = @"messages.forwardMessage";
        constructor.type = @"messages.StatedMessage";
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_sendBroadcast$messages_sendBroadcast
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x41bb0972;
        constructor.method = @"messages.sendBroadcast";
        constructor.type = @"messages.StatedMessages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"contacts";
            arg.type = @"Vector<InputUser>";
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
        //TLRPCgeochats_getLocated$geochats_getLocated
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x7f192d8f;
        constructor.method = @"geochats.getLocated";
        constructor.type = @"geochats.Located";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"geo_point";
            arg.type = @"InputGeoPoint";
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
        //TLRPCgeochats_getRecents$geochats_getRecents
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe1427e6f;
        constructor.method = @"geochats.getRecents";
        constructor.type = @"geochats.Messages";
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
        //TLRPCgeochats_checkin$geochats_checkin
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x55b3e8fb;
        constructor.method = @"geochats.checkin";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCgeochats_getFullChat$geochats_getFullChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x6722dd6f;
        constructor.method = @"geochats.getFullChat";
        constructor.type = @"messages.ChatFull";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCgeochats_editChatTitle$geochats_editChatTitle
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x4c8e2273;
        constructor.method = @"geochats.editChatTitle";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCgeochats_editChatPhoto$geochats_editChatPhoto
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x35d81a95;
        constructor.method = @"geochats.editChatPhoto";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
        //TLRPCgeochats_search$geochats_search
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xcfcdc44d;
        constructor.method = @"geochats.search";
        constructor.type = @"geochats.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
        //TLRPCgeochats_getHistory$geochats_getHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb53f7a68;
        constructor.method = @"geochats.getHistory";
        constructor.type = @"geochats.Messages";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
        //TLRPCgeochats_setTyping$geochats_setTyping
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x8b8a729;
        constructor.method = @"geochats.setTyping";
        constructor.type = @"Bool";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
        //TLRPCgeochats_sendMessage$geochats_sendMessage
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x61b0044;
        constructor.method = @"geochats.sendMessage";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
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
            arg.name = @"random_id";
            arg.type = @"long";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCgeochats_sendMedia$geochats_sendMedia
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xb8f0deff;
        constructor.method = @"geochats.sendMedia";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"peer";
            arg.type = @"InputGeoChat";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"media";
            arg.type = @"InputMedia";
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
    {
        //TLRPCauth_sendCode$auth_sendCode
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x768d5f4d;
        constructor.method = @"auth.sendCode";
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
            arg.name = @"sms_type";
            arg.type = @"int";
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
            arg.name = @"api_hash";
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
        //TLRPCgeochats_createGeoChat$geochats_createGeoChat
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xe092e16;
        constructor.method = @"geochats.createGeoChat";
        constructor.type = @"geochats.StatedMessage";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"title";
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
            arg.name = @"address";
            arg.type = @"string";
            [fields addObject:arg];
        }
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"venue";
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
        //TLRPCupdates_getDifference$updates_getDifference
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xa041495;
        constructor.method = @"updates.getDifference";
        constructor.type = @"updates.Difference";
        NSMutableArray *fields = [[NSMutableArray alloc] init];
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
        //TLRPCauth_sendSms$auth_sendSms
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xda9f3e8;
        constructor.method = @"auth.sendSms";
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
        //TLRPCmessages_readHistory$messages_readHistory
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0xeed884c6;
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
        {
            TLSchemeParam$schemeParam *arg = [[TLSchemeParam$schemeParam alloc] init];
            arg.name = @"read_contents";
            arg.type = @"Bool";
            [fields addObject:arg];
        }
        constructor.params = fields;
        [TLmetaSchemeMethods addObject:constructor];
    }
    {
        //TLRPCmessages_readMessageContents$messages_readMessageContents
        TLSchemeMethod$schemeMethod *constructor = [[TLSchemeMethod$schemeMethod alloc] init];
        constructor.n_id = (int32_t)0x354b5bc2;
        constructor.method = @"messages.readMessageContents";
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

    TLScheme$scheme *TLmetaScheme = [[TLScheme$scheme alloc] init];
    TLmetaScheme.types = TLmetaSchemeTypes;
    TLmetaScheme.methods = TLmetaSchemeMethods;
    return TLmetaScheme;
}

