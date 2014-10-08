/*
 * Layer 17
 */

@class API17_InputGeoPlaceName;
@class API17_InputGeoPlaceName_inputGeoPlaceName;

@class API17_InputGeoPoint;
@class API17_InputGeoPoint_inputGeoPointEmpty;
@class API17_InputGeoPoint_inputGeoPoint;

@class API17_messages_Chat;
@class API17_messages_Chat_messages_chat;

@class API17_ChatFull;
@class API17_ChatFull_chatFull;

@class API17_ChatParticipant;
@class API17_ChatParticipant_chatParticipant;

@class API17_updates_Difference;
@class API17_updates_Difference_updates_differenceEmpty;
@class API17_updates_Difference_updates_difference;
@class API17_updates_Difference_updates_differenceSlice;

@class API17_SchemeMethod;
@class API17_SchemeMethod_schemeMethod;

@class API17_GeoChatMessage;
@class API17_GeoChatMessage_geoChatMessageEmpty;
@class API17_GeoChatMessage_geoChatMessage;
@class API17_GeoChatMessage_geoChatMessageService;

@class API17_ProtoMessage;
@class API17_ProtoMessage_protoMessage;

@class API17_InputPhotoCrop;
@class API17_InputPhotoCrop_inputPhotoCropAuto;
@class API17_InputPhotoCrop_inputPhotoCrop;

@class API17_DestroySessionRes;
@class API17_DestroySessionRes_destroy_session_ok;
@class API17_DestroySessionRes_destroy_session_none;

@class API17_Photo;
@class API17_Photo_photoEmpty;
@class API17_Photo_photo;
@class API17_Photo_wallPhoto;

@class API17_Chat;
@class API17_Chat_geoChat;
@class API17_Chat_chatEmpty;
@class API17_Chat_chat;
@class API17_Chat_chatForbidden;

@class API17_contacts_Requests;
@class API17_contacts_Requests_contacts_requests;
@class API17_contacts_Requests_contacts_requestsSlice;

@class API17_Server_DH_Params;
@class API17_Server_DH_Params_server_DH_params_fail;
@class API17_Server_DH_Params_server_DH_params_ok;

@class API17_DecryptedMessageAction;
@class API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class API17_DecryptedMessageAction_decryptedMessageActionViewMessage;
@class API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage;
@class API17_DecryptedMessageAction_decryptedMessageActionScreenshot;
@class API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class API17_DecryptedMessageAction_decryptedMessageActionFlushHistory;

@class API17_GeoPlaceName;
@class API17_GeoPlaceName_geoPlaceName;

@class API17_UserFull;
@class API17_UserFull_userFull;

@class API17_InputPeerNotifyEvents;
@class API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty;
@class API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll;

@class API17_DcOption;
@class API17_DcOption_dcOption;

@class API17_MsgsStateReq;
@class API17_MsgsStateReq_msgs_state_req;

@class API17_help_AppUpdate;
@class API17_help_AppUpdate_help_appUpdate;
@class API17_help_AppUpdate_help_noAppUpdate;

@class API17_contacts_SentLink;
@class API17_contacts_SentLink_contacts_sentLink;

@class API17_ResPQ;
@class API17_ResPQ_resPQ;

@class API17_storage_FileType;
@class API17_storage_FileType_storage_fileUnknown;
@class API17_storage_FileType_storage_fileJpeg;
@class API17_storage_FileType_storage_fileGif;
@class API17_storage_FileType_storage_filePng;
@class API17_storage_FileType_storage_filePdf;
@class API17_storage_FileType_storage_fileMp3;
@class API17_storage_FileType_storage_fileMov;
@class API17_storage_FileType_storage_filePartial;
@class API17_storage_FileType_storage_fileMp4;
@class API17_storage_FileType_storage_fileWebp;

@class API17_InputEncryptedFile;
@class API17_InputEncryptedFile_inputEncryptedFileEmpty;
@class API17_InputEncryptedFile_inputEncryptedFileUploaded;
@class API17_InputEncryptedFile_inputEncryptedFile;
@class API17_InputEncryptedFile_inputEncryptedFileBigUploaded;

@class API17_FutureSalts;
@class API17_FutureSalts_futureSalts;

@class API17_messages_SentEncryptedMessage;
@class API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage;
@class API17_messages_SentEncryptedMessage_messages_sentEncryptedFile;

@class API17_auth_Authorization;
@class API17_auth_Authorization_auth_authorization;

@class API17_InputFile;
@class API17_InputFile_inputFile;
@class API17_InputFile_inputFileBig;

@class API17_Peer;
@class API17_Peer_peerUser;
@class API17_Peer_peerChat;

@class API17_UserStatus;
@class API17_UserStatus_userStatusEmpty;
@class API17_UserStatus_userStatusOnline;
@class API17_UserStatus_userStatusOffline;

@class API17_Dialog;
@class API17_Dialog_dialog;

@class API17_MsgsAllInfo;
@class API17_MsgsAllInfo_msgs_all_info;

@class API17_SendMessageAction;
@class API17_SendMessageAction_sendMessageTypingAction;
@class API17_SendMessageAction_sendMessageCancelAction;
@class API17_SendMessageAction_sendMessageRecordVideoAction;
@class API17_SendMessageAction_sendMessageUploadVideoAction;
@class API17_SendMessageAction_sendMessageRecordAudioAction;
@class API17_SendMessageAction_sendMessageUploadAudioAction;
@class API17_SendMessageAction_sendMessageUploadPhotoAction;
@class API17_SendMessageAction_sendMessageUploadDocumentAction;
@class API17_SendMessageAction_sendMessageGeoLocationAction;
@class API17_SendMessageAction_sendMessageChooseContactAction;

@class API17_Update;
@class API17_Update_updateNewGeoChatMessage;
@class API17_Update_updateNewMessage;
@class API17_Update_updateMessageID;
@class API17_Update_updateReadMessages;
@class API17_Update_updateDeleteMessages;
@class API17_Update_updateRestoreMessages;
@class API17_Update_updateChatParticipants;
@class API17_Update_updateUserStatus;
@class API17_Update_updateUserName;
@class API17_Update_updateUserPhoto;
@class API17_Update_updateContactRegistered;
@class API17_Update_updateContactLink;
@class API17_Update_updateContactLocated;
@class API17_Update_updateActivation;
@class API17_Update_updateNewAuthorization;
@class API17_Update_updatePhoneCallRequested;
@class API17_Update_updatePhoneCallConfirmed;
@class API17_Update_updatePhoneCallDeclined;
@class API17_Update_updateNewEncryptedMessage;
@class API17_Update_updateEncryptedChatTyping;
@class API17_Update_updateEncryption;
@class API17_Update_updateEncryptedMessagesRead;
@class API17_Update_updateChatParticipantAdd;
@class API17_Update_updateChatParticipantDelete;
@class API17_Update_updateDcOptions;
@class API17_Update_updateUserBlocked;
@class API17_Update_updateNotifySettings;
@class API17_Update_updateUserTyping;
@class API17_Update_updateChatUserTyping;

@class API17_contacts_Blocked;
@class API17_contacts_Blocked_contacts_blocked;
@class API17_contacts_Blocked_contacts_blockedSlice;

@class API17_Error;
@class API17_Error_error;
@class API17_Error_richError;

@class API17_ContactLocated;
@class API17_ContactLocated_contactLocated;
@class API17_ContactLocated_contactLocatedPreview;

@class API17_ContactStatus;
@class API17_ContactStatus_contactStatus;

@class API17_geochats_Messages;
@class API17_geochats_Messages_geochats_messages;
@class API17_geochats_Messages_geochats_messagesSlice;

@class API17_MsgsStateInfo;
@class API17_MsgsStateInfo_msgs_state_info;

@class API17_PhotoSize;
@class API17_PhotoSize_photoSizeEmpty;
@class API17_PhotoSize_photoSize;
@class API17_PhotoSize_photoCachedSize;

@class API17_GlobalPrivacySettings;
@class API17_GlobalPrivacySettings_globalPrivacySettings;

@class API17_InputGeoChat;
@class API17_InputGeoChat_inputGeoChat;

@class API17_FileLocation;
@class API17_FileLocation_fileLocationUnavailable;
@class API17_FileLocation_fileLocation;

@class API17_InputNotifyPeer;
@class API17_InputNotifyPeer_inputNotifyGeoChatPeer;
@class API17_InputNotifyPeer_inputNotifyPeer;
@class API17_InputNotifyPeer_inputNotifyUsers;
@class API17_InputNotifyPeer_inputNotifyChats;
@class API17_InputNotifyPeer_inputNotifyAll;

@class API17_EncryptedMessage;
@class API17_EncryptedMessage_encryptedMessage;
@class API17_EncryptedMessage_encryptedMessageService;

@class API17_photos_Photo;
@class API17_photos_Photo_photos_photo;

@class API17_InputContact;
@class API17_InputContact_inputPhoneContact;

@class API17_contacts_Contacts;
@class API17_contacts_Contacts_contacts_contacts;
@class API17_contacts_Contacts_contacts_contactsNotModified;

@class API17_BadMsgNotification;
@class API17_BadMsgNotification_bad_msg_notification;
@class API17_BadMsgNotification_bad_server_salt;

@class API17_InputDocument;
@class API17_InputDocument_inputDocumentEmpty;
@class API17_InputDocument_inputDocument;

@class API17_InputMedia;
@class API17_InputMedia_inputMediaEmpty;
@class API17_InputMedia_inputMediaUploadedPhoto;
@class API17_InputMedia_inputMediaPhoto;
@class API17_InputMedia_inputMediaGeoPoint;
@class API17_InputMedia_inputMediaContact;
@class API17_InputMedia_inputMediaVideo;
@class API17_InputMedia_inputMediaAudio;
@class API17_InputMedia_inputMediaUploadedDocument;
@class API17_InputMedia_inputMediaUploadedThumbDocument;
@class API17_InputMedia_inputMediaDocument;
@class API17_InputMedia_inputMediaUploadedAudio;
@class API17_InputMedia_inputMediaUploadedVideo;
@class API17_InputMedia_inputMediaUploadedThumbVideo;

@class API17_InputPeer;
@class API17_InputPeer_inputPeerEmpty;
@class API17_InputPeer_inputPeerSelf;
@class API17_InputPeer_inputPeerContact;
@class API17_InputPeer_inputPeerForeign;
@class API17_InputPeer_inputPeerChat;

@class API17_Contact;
@class API17_Contact_contact;

@class API17_messages_Chats;
@class API17_messages_Chats_messages_chats;

@class API17_P_Q_inner_data;
@class API17_P_Q_inner_data_p_q_inner_data;

@class API17_contacts_MyLink;
@class API17_contacts_MyLink_contacts_myLinkEmpty;
@class API17_contacts_MyLink_contacts_myLinkRequested;
@class API17_contacts_MyLink_contacts_myLinkContact;

@class API17_messages_DhConfig;
@class API17_messages_DhConfig_messages_dhConfigNotModified;
@class API17_messages_DhConfig_messages_dhConfig;

@class API17_auth_ExportedAuthorization;
@class API17_auth_ExportedAuthorization_auth_exportedAuthorization;

@class API17_ContactRequest;
@class API17_ContactRequest_contactRequest;

@class API17_messages_AffectedHistory;
@class API17_messages_AffectedHistory_messages_affectedHistory;

@class API17_messages_SentMessage;
@class API17_messages_SentMessage_messages_sentMessageLink;
@class API17_messages_SentMessage_messages_sentMessage;

@class API17_messages_ChatFull;
@class API17_messages_ChatFull_messages_chatFull;

@class API17_contacts_ForeignLink;
@class API17_contacts_ForeignLink_contacts_foreignLinkUnknown;
@class API17_contacts_ForeignLink_contacts_foreignLinkRequested;
@class API17_contacts_ForeignLink_contacts_foreignLinkMutual;

@class API17_InputEncryptedChat;
@class API17_InputEncryptedChat_inputEncryptedChat;

@class API17_InvokeWithLayer17;
@class API17_InvokeWithLayer17_invokeWithLayer17;

@class API17_EncryptedFile;
@class API17_EncryptedFile_encryptedFileEmpty;
@class API17_EncryptedFile_encryptedFile;

@class API17_ContactFound;
@class API17_ContactFound_contactFound;

@class API17_NotifyPeer;
@class API17_NotifyPeer_notifyPeer;
@class API17_NotifyPeer_notifyUsers;
@class API17_NotifyPeer_notifyChats;
@class API17_NotifyPeer_notifyAll;

@class API17_Client_DH_Inner_Data;
@class API17_Client_DH_Inner_Data_client_DH_inner_data;

@class API17_contacts_Link;
@class API17_contacts_Link_contacts_link;

@class API17_ContactBlocked;
@class API17_ContactBlocked_contactBlocked;

@class API17_auth_CheckedPhone;
@class API17_auth_CheckedPhone_auth_checkedPhone;

@class API17_InputUser;
@class API17_InputUser_inputUserEmpty;
@class API17_InputUser_inputUserSelf;
@class API17_InputUser_inputUserContact;
@class API17_InputUser_inputUserForeign;

@class API17_SchemeType;
@class API17_SchemeType_schemeType;

@class API17_geochats_StatedMessage;
@class API17_geochats_StatedMessage_geochats_statedMessage;

@class API17_upload_File;
@class API17_upload_File_upload_file;

@class API17_InputVideo;
@class API17_InputVideo_inputVideoEmpty;
@class API17_InputVideo_inputVideo;

@class API17_FutureSalt;
@class API17_FutureSalt_futureSalt;

@class API17_Config;
@class API17_Config_config;

@class API17_ProtoMessageCopy;
@class API17_ProtoMessageCopy_msg_copy;

@class API17_Audio;
@class API17_Audio_audioEmpty;
@class API17_Audio_audio;

@class API17_contacts_Located;
@class API17_contacts_Located_contacts_located;

@class API17_InputAudio;
@class API17_InputAudio_inputAudioEmpty;
@class API17_InputAudio_inputAudio;

@class API17_MsgsAck;
@class API17_MsgsAck_msgs_ack;

@class API17_Pong;
@class API17_Pong_pong;

@class API17_ResponseIndirect;
@class API17_ResponseIndirect_responseIndirect;

@class API17_MsgResendReq;
@class API17_MsgResendReq_msg_resend_req;

@class API17_messages_StatedMessages;
@class API17_messages_StatedMessages_messages_statedMessagesLinks;
@class API17_messages_StatedMessages_messages_statedMessages;

@class API17_WallPaper;
@class API17_WallPaper_wallPaperSolid;
@class API17_WallPaper_wallPaper;

@class API17_DestroySessionsRes;
@class API17_DestroySessionsRes_destroy_sessions_res;

@class API17_messages_Messages;
@class API17_messages_Messages_messages_messages;
@class API17_messages_Messages_messages_messagesSlice;

@class API17_geochats_Located;
@class API17_geochats_Located_geochats_located;

@class API17_auth_SentCode;
@class API17_auth_SentCode_auth_sentCodePreview;
@class API17_auth_SentCode_auth_sentPassPhrase;
@class API17_auth_SentCode_auth_sentCode;
@class API17_auth_SentCode_auth_sentAppCode;

@class API17_phone_DhConfig;
@class API17_phone_DhConfig_phone_dhConfig;

@class API17_InputChatPhoto;
@class API17_InputChatPhoto_inputChatPhotoEmpty;
@class API17_InputChatPhoto_inputChatUploadedPhoto;
@class API17_InputChatPhoto_inputChatPhoto;

@class API17_Updates;
@class API17_Updates_updatesTooLong;
@class API17_Updates_updateShortMessage;
@class API17_Updates_updateShortChatMessage;
@class API17_Updates_updateShort;
@class API17_Updates_updatesCombined;
@class API17_Updates_updates;

@class API17_InitConnection;
@class API17_InitConnection_pinitConnection;

@class API17_DecryptedMessage;
@class API17_DecryptedMessage_decryptedMessage;
@class API17_DecryptedMessage_decryptedMessageService;

@class API17_MessageMedia;
@class API17_MessageMedia_messageMediaEmpty;
@class API17_MessageMedia_messageMediaPhoto;
@class API17_MessageMedia_messageMediaVideo;
@class API17_MessageMedia_messageMediaGeo;
@class API17_MessageMedia_messageMediaContact;
@class API17_MessageMedia_messageMediaUnsupported;
@class API17_MessageMedia_messageMediaDocument;
@class API17_MessageMedia_messageMediaAudio;

@class API17_Null;
@class API17_Null_null;

@class API17_ChatPhoto;
@class API17_ChatPhoto_chatPhotoEmpty;
@class API17_ChatPhoto_chatPhoto;

@class API17_InvokeAfterMsg;
@class API17_InvokeAfterMsg_invokeAfterMsg;

@class API17_contacts_Suggested;
@class API17_contacts_Suggested_contacts_suggested;

@class API17_updates_State;
@class API17_updates_State_updates_state;

@class API17_User;
@class API17_User_userEmpty;
@class API17_User_userSelf;
@class API17_User_userContact;
@class API17_User_userRequest;
@class API17_User_userForeign;
@class API17_User_userDeleted;

@class API17_Message;
@class API17_Message_messageEmpty;
@class API17_Message_message;
@class API17_Message_messageForwarded;
@class API17_Message_messageService;

@class API17_InputFileLocation;
@class API17_InputFileLocation_inputFileLocation;
@class API17_InputFileLocation_inputVideoFileLocation;
@class API17_InputFileLocation_inputEncryptedFileLocation;
@class API17_InputFileLocation_inputAudioFileLocation;
@class API17_InputFileLocation_inputDocumentFileLocation;

@class API17_GeoPoint;
@class API17_GeoPoint_geoPointEmpty;
@class API17_GeoPoint_geoPoint;
@class API17_GeoPoint_geoPlace;

@class API17_InputPhoneCall;
@class API17_InputPhoneCall_inputPhoneCall;

@class API17_ChatParticipants;
@class API17_ChatParticipants_chatParticipantsForbidden;
@class API17_ChatParticipants_chatParticipants;

@class API17_RpcError;
@class API17_RpcError_rpc_error;
@class API17_RpcError_rpc_req_error;

@class API17_NearestDc;
@class API17_NearestDc_nearestDc;

@class API17_Set_client_DH_params_answer;
@class API17_Set_client_DH_params_answer_dh_gen_ok;
@class API17_Set_client_DH_params_answer_dh_gen_retry;
@class API17_Set_client_DH_params_answer_dh_gen_fail;

@class API17_photos_Photos;
@class API17_photos_Photos_photos_photos;
@class API17_photos_Photos_photos_photosSlice;

@class API17_contacts_ImportedContacts;
@class API17_contacts_ImportedContacts_contacts_importedContacts;

@class API17_MsgDetailedInfo;
@class API17_MsgDetailedInfo_msg_detailed_info;
@class API17_MsgDetailedInfo_msg_new_detailed_info;

@class API17_Bool;
@class API17_Bool_boolFalse;
@class API17_Bool_boolTrue;

@class API17_help_Support;
@class API17_help_Support_help_support;

@class API17_ChatLocated;
@class API17_ChatLocated_chatLocated;

@class API17_MessagesFilter;
@class API17_MessagesFilter_inputMessagesFilterEmpty;
@class API17_MessagesFilter_inputMessagesFilterPhotos;
@class API17_MessagesFilter_inputMessagesFilterVideo;
@class API17_MessagesFilter_inputMessagesFilterPhotoVideo;

@class API17_messages_Dialogs;
@class API17_messages_Dialogs_messages_dialogs;
@class API17_messages_Dialogs_messages_dialogsSlice;

@class API17_help_InviteText;
@class API17_help_InviteText_help_inviteText;

@class API17_ContactSuggested;
@class API17_ContactSuggested_contactSuggested;

@class API17_InputPeerNotifySettings;
@class API17_InputPeerNotifySettings_inputPeerNotifySettings;

@class API17_DcNetworkStats;
@class API17_DcNetworkStats_dcPingStats;

@class API17_HttpWait;
@class API17_HttpWait_http_wait;

@class API17_PhoneConnection;
@class API17_PhoneConnection_phoneConnectionNotReady;
@class API17_PhoneConnection_phoneConnection;

@class API17_messages_StatedMessage;
@class API17_messages_StatedMessage_messages_statedMessageLink;
@class API17_messages_StatedMessage_messages_statedMessage;

@class API17_Scheme;
@class API17_Scheme_scheme;
@class API17_Scheme_schemeNotModified;

@class API17_RpcDropAnswer;
@class API17_RpcDropAnswer_rpc_answer_unknown;
@class API17_RpcDropAnswer_rpc_answer_dropped_running;
@class API17_RpcDropAnswer_rpc_answer_dropped;

@class API17_messages_Message;
@class API17_messages_Message_messages_messageEmpty;
@class API17_messages_Message_messages_message;

@class API17_MessageAction;
@class API17_MessageAction_messageActionGeoChatCreate;
@class API17_MessageAction_messageActionGeoChatCheckin;
@class API17_MessageAction_messageActionEmpty;
@class API17_MessageAction_messageActionChatCreate;
@class API17_MessageAction_messageActionChatEditTitle;
@class API17_MessageAction_messageActionChatEditPhoto;
@class API17_MessageAction_messageActionChatDeletePhoto;
@class API17_MessageAction_messageActionChatAddUser;
@class API17_MessageAction_messageActionChatDeleteUser;
@class API17_MessageAction_messageActionSentRequest;
@class API17_MessageAction_messageActionAcceptRequest;

@class API17_PhoneCall;
@class API17_PhoneCall_phoneCallEmpty;
@class API17_PhoneCall_phoneCall;

@class API17_PeerNotifyEvents;
@class API17_PeerNotifyEvents_peerNotifyEventsEmpty;
@class API17_PeerNotifyEvents_peerNotifyEventsAll;

@class API17_NewSession;
@class API17_NewSession_pnew_session_created;

@class API17_help_AppPrefs;
@class API17_help_AppPrefs_help_appPrefs;

@class API17_contacts_Found;
@class API17_contacts_Found_contacts_found;

@class API17_PeerNotifySettings;
@class API17_PeerNotifySettings_peerNotifySettingsEmpty;
@class API17_PeerNotifySettings_peerNotifySettings;

@class API17_SchemeParam;
@class API17_SchemeParam_schemeParam;

@class API17_UserProfilePhoto;
@class API17_UserProfilePhoto_userProfilePhotoEmpty;
@class API17_UserProfilePhoto_userProfilePhoto;

@class API17_Server_DH_inner_data;
@class API17_Server_DH_inner_data_server_DH_inner_data;

@class API17_InputPhoto;
@class API17_InputPhoto_inputPhotoEmpty;
@class API17_InputPhoto_inputPhoto;

@class API17_DecryptedMessageMedia;
@class API17_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class API17_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class API17_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class API17_DecryptedMessageMedia_decryptedMessageMediaContact;
@class API17_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class API17_DecryptedMessageMedia_decryptedMessageMediaAudio;

@class API17_Video;
@class API17_Video_videoEmpty;
@class API17_Video_video;

@class API17_EncryptedChat;
@class API17_EncryptedChat_encryptedChatEmpty;
@class API17_EncryptedChat_encryptedChatWaiting;
@class API17_EncryptedChat_encryptedChatDiscarded;
@class API17_EncryptedChat_encryptedChatRequested;
@class API17_EncryptedChat_encryptedChat;

@class API17_Document;
@class API17_Document_documentEmpty;
@class API17_Document_document;

@class API17_ImportedContact;
@class API17_ImportedContact_importedContact;


@interface API17__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 17
 */

@interface API17_InputGeoPlaceName : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSString * state;
@property (nonatomic, strong, readonly) NSString * city;
@property (nonatomic, strong, readonly) NSString * district;
@property (nonatomic, strong, readonly) NSString * street;

+ (API17_InputGeoPlaceName_inputGeoPlaceName *)inputGeoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street;

@end

@interface API17_InputGeoPlaceName_inputGeoPlaceName : API17_InputGeoPlaceName

@end


@interface API17_InputGeoPoint : NSObject

+ (API17_InputGeoPoint_inputGeoPointEmpty *)inputGeoPointEmpty;
+ (API17_InputGeoPoint_inputGeoPoint *)inputGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;

@end

@interface API17_InputGeoPoint_inputGeoPointEmpty : API17_InputGeoPoint

@end

@interface API17_InputGeoPoint_inputGeoPoint : API17_InputGeoPoint

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end


@interface API17_messages_Chat : NSObject

@property (nonatomic, strong, readonly) API17_Chat * chat;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_messages_Chat_messages_chat *)messages_chatWithChat:(API17_Chat *)chat users:(NSArray *)users;

@end

@interface API17_messages_Chat_messages_chat : API17_messages_Chat

@end


@interface API17_ChatFull : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) API17_ChatParticipants * participants;
@property (nonatomic, strong, readonly) API17_Photo * chat_photo;
@property (nonatomic, strong, readonly) API17_PeerNotifySettings * notify_settings;

+ (API17_ChatFull_chatFull *)chatFullWithPid:(NSNumber *)pid participants:(API17_ChatParticipants *)participants chat_photo:(API17_Photo *)chat_photo notify_settings:(API17_PeerNotifySettings *)notify_settings;

@end

@interface API17_ChatFull_chatFull : API17_ChatFull

@end


@interface API17_ChatParticipant : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * inviter_id;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (API17_ChatParticipant_chatParticipant *)chatParticipantWithUser_id:(NSNumber *)user_id inviter_id:(NSNumber *)inviter_id date:(NSNumber *)date;

@end

@interface API17_ChatParticipant_chatParticipant : API17_ChatParticipant

@end


@interface API17_updates_Difference : NSObject

+ (API17_updates_Difference_updates_differenceEmpty *)updates_differenceEmptyWithDate:(NSNumber *)date seq:(NSNumber *)seq;
+ (API17_updates_Difference_updates_difference *)updates_differenceWithPnew_messages:(NSArray *)pnew_messages pnew_encrypted_messages:(NSArray *)pnew_encrypted_messages other_updates:(NSArray *)other_updates chats:(NSArray *)chats users:(NSArray *)users state:(API17_updates_State *)state;
+ (API17_updates_Difference_updates_differenceSlice *)updates_differenceSliceWithPnew_messages:(NSArray *)pnew_messages pnew_encrypted_messages:(NSArray *)pnew_encrypted_messages other_updates:(NSArray *)other_updates chats:(NSArray *)chats users:(NSArray *)users intermediate_state:(API17_updates_State *)intermediate_state;

@end

@interface API17_updates_Difference_updates_differenceEmpty : API17_updates_Difference

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface API17_updates_Difference_updates_difference : API17_updates_Difference

@property (nonatomic, strong, readonly) NSArray * pnew_messages;
@property (nonatomic, strong, readonly) NSArray * pnew_encrypted_messages;
@property (nonatomic, strong, readonly) NSArray * other_updates;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) API17_updates_State * state;

@end

@interface API17_updates_Difference_updates_differenceSlice : API17_updates_Difference

@property (nonatomic, strong, readonly) NSArray * pnew_messages;
@property (nonatomic, strong, readonly) NSArray * pnew_encrypted_messages;
@property (nonatomic, strong, readonly) NSArray * other_updates;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) API17_updates_State * intermediate_state;

@end


@interface API17_SchemeMethod : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * method;
@property (nonatomic, strong, readonly) NSArray * params;
@property (nonatomic, strong, readonly) NSString * type;

+ (API17_SchemeMethod_schemeMethod *)schemeMethodWithPid:(NSNumber *)pid method:(NSString *)method params:(NSArray *)params type:(NSString *)type;

@end

@interface API17_SchemeMethod_schemeMethod : API17_SchemeMethod

@end


@interface API17_GeoChatMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_GeoChatMessage_geoChatMessageEmpty *)geoChatMessageEmptyWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid;
+ (API17_GeoChatMessage_geoChatMessage *)geoChatMessageWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid from_id:(NSNumber *)from_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media;
+ (API17_GeoChatMessage_geoChatMessageService *)geoChatMessageServiceWithChat_id:(NSNumber *)chat_id pid:(NSNumber *)pid from_id:(NSNumber *)from_id date:(NSNumber *)date action:(API17_MessageAction *)action;

@end

@interface API17_GeoChatMessage_geoChatMessageEmpty : API17_GeoChatMessage

@end

@interface API17_GeoChatMessage_geoChatMessage : API17_GeoChatMessage

@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) API17_MessageMedia * media;

@end

@interface API17_GeoChatMessage_geoChatMessageService : API17_GeoChatMessage

@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) API17_MessageAction * action;

@end


@interface API17_ProtoMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * msg_id;
@property (nonatomic, strong, readonly) NSNumber * seqno;
@property (nonatomic, strong, readonly) NSNumber * bytes;
@property (nonatomic, strong, readonly) NSObject * body;

+ (API17_ProtoMessage_protoMessage *)protoMessageWithMsg_id:(NSNumber *)msg_id seqno:(NSNumber *)seqno bytes:(NSNumber *)bytes body:(NSObject *)body;

@end

@interface API17_ProtoMessage_protoMessage : API17_ProtoMessage

@end


@interface API17_InputPhotoCrop : NSObject

+ (API17_InputPhotoCrop_inputPhotoCropAuto *)inputPhotoCropAuto;
+ (API17_InputPhotoCrop_inputPhotoCrop *)inputPhotoCropWithCrop_left:(NSNumber *)crop_left crop_top:(NSNumber *)crop_top crop_width:(NSNumber *)crop_width;

@end

@interface API17_InputPhotoCrop_inputPhotoCropAuto : API17_InputPhotoCrop

@end

@interface API17_InputPhotoCrop_inputPhotoCrop : API17_InputPhotoCrop

@property (nonatomic, strong, readonly) NSNumber * crop_left;
@property (nonatomic, strong, readonly) NSNumber * crop_top;
@property (nonatomic, strong, readonly) NSNumber * crop_width;

@end


@interface API17_DestroySessionRes : NSObject

@property (nonatomic, strong, readonly) NSNumber * session_id;

+ (API17_DestroySessionRes_destroy_session_ok *)destroy_session_okWithSession_id:(NSNumber *)session_id;
+ (API17_DestroySessionRes_destroy_session_none *)destroy_session_noneWithSession_id:(NSNumber *)session_id;

@end

@interface API17_DestroySessionRes_destroy_session_ok : API17_DestroySessionRes

@end

@interface API17_DestroySessionRes_destroy_session_none : API17_DestroySessionRes

@end


@interface API17_Photo : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Photo_photoEmpty *)photoEmptyWithPid:(NSNumber *)pid;
+ (API17_Photo_photo *)photoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption geo:(API17_GeoPoint *)geo sizes:(NSArray *)sizes;
+ (API17_Photo_wallPhoto *)wallPhotoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption geo:(API17_GeoPoint *)geo unread:(API17_Bool *)unread sizes:(NSArray *)sizes;

@end

@interface API17_Photo_photoEmpty : API17_Photo

@end

@interface API17_Photo_photo : API17_Photo

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * caption;
@property (nonatomic, strong, readonly) API17_GeoPoint * geo;
@property (nonatomic, strong, readonly) NSArray * sizes;

@end

@interface API17_Photo_wallPhoto : API17_Photo

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * caption;
@property (nonatomic, strong, readonly) API17_GeoPoint * geo;
@property (nonatomic, strong, readonly) API17_Bool * unread;
@property (nonatomic, strong, readonly) NSArray * sizes;

@end


@interface API17_Chat : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Chat_geoChat *)geoChatWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash title:(NSString *)title address:(NSString *)address venue:(NSString *)venue geo:(API17_GeoPoint *)geo photo:(API17_ChatPhoto *)photo participants_count:(NSNumber *)participants_count date:(NSNumber *)date checked_in:(API17_Bool *)checked_in version:(NSNumber *)version;
+ (API17_Chat_chatEmpty *)chatEmptyWithPid:(NSNumber *)pid;
+ (API17_Chat_chat *)chatWithPid:(NSNumber *)pid title:(NSString *)title photo:(API17_ChatPhoto *)photo participants_count:(NSNumber *)participants_count date:(NSNumber *)date left:(API17_Bool *)left version:(NSNumber *)version;
+ (API17_Chat_chatForbidden *)chatForbiddenWithPid:(NSNumber *)pid title:(NSString *)title date:(NSNumber *)date;

@end

@interface API17_Chat_geoChat : API17_Chat

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * venue;
@property (nonatomic, strong, readonly) API17_GeoPoint * geo;
@property (nonatomic, strong, readonly) API17_ChatPhoto * photo;
@property (nonatomic, strong, readonly) NSNumber * participants_count;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) API17_Bool * checked_in;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface API17_Chat_chatEmpty : API17_Chat

@end

@interface API17_Chat_chat : API17_Chat

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) API17_ChatPhoto * photo;
@property (nonatomic, strong, readonly) NSNumber * participants_count;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) API17_Bool * left;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface API17_Chat_chatForbidden : API17_Chat

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSNumber * date;

@end


@interface API17_contacts_Requests : NSObject

@property (nonatomic, strong, readonly) NSArray * requests;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_Requests_contacts_requests *)contacts_requestsWithRequests:(NSArray *)requests users:(NSArray *)users;
+ (API17_contacts_Requests_contacts_requestsSlice *)contacts_requestsSliceWithCount:(NSNumber *)count requests:(NSArray *)requests users:(NSArray *)users;

@end

@interface API17_contacts_Requests_contacts_requests : API17_contacts_Requests

@end

@interface API17_contacts_Requests_contacts_requestsSlice : API17_contacts_Requests

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_Server_DH_Params : NSObject

@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;

+ (API17_Server_DH_Params_server_DH_params_fail *)server_DH_params_failWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash:(NSData *)pnew_nonce_hash;
+ (API17_Server_DH_Params_server_DH_params_ok *)server_DH_params_okWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_answer:(NSData *)encrypted_answer;

@end

@interface API17_Server_DH_Params_server_DH_params_fail : API17_Server_DH_Params

@property (nonatomic, strong, readonly) NSData * pnew_nonce_hash;

@end

@interface API17_Server_DH_Params_server_DH_params_ok : API17_Server_DH_Params

@property (nonatomic, strong, readonly) NSData * encrypted_answer;

@end


@interface API17_DecryptedMessageAction : NSObject

+ (API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (API17_DecryptedMessageAction_decryptedMessageActionViewMessage *)decryptedMessageActionViewMessageWithRandom_id:(NSNumber *)random_id;
+ (API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage *)decryptedMessageActionScreenshotMessageWithRandom_id:(NSNumber *)random_id;
+ (API17_DecryptedMessageAction_decryptedMessageActionScreenshot *)decryptedMessageActionScreenshot;
+ (API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (API17_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : API17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionViewMessage : API17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * random_id;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionScreenshotMessage : API17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * random_id;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionScreenshot : API17_DecryptedMessageAction

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionDeleteMessages : API17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface API17_DecryptedMessageAction_decryptedMessageActionFlushHistory : API17_DecryptedMessageAction

@end


@interface API17_GeoPlaceName : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSString * state;
@property (nonatomic, strong, readonly) NSString * city;
@property (nonatomic, strong, readonly) NSString * district;
@property (nonatomic, strong, readonly) NSString * street;

+ (API17_GeoPlaceName_geoPlaceName *)geoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street;

@end

@interface API17_GeoPlaceName_geoPlaceName : API17_GeoPlaceName

@end


@interface API17_UserFull : NSObject

@property (nonatomic, strong, readonly) API17_User * user;
@property (nonatomic, strong, readonly) API17_contacts_Link * link;
@property (nonatomic, strong, readonly) API17_Photo * profile_photo;
@property (nonatomic, strong, readonly) API17_PeerNotifySettings * notify_settings;
@property (nonatomic, strong, readonly) API17_Bool * blocked;
@property (nonatomic, strong, readonly) NSString * real_first_name;
@property (nonatomic, strong, readonly) NSString * real_last_name;

+ (API17_UserFull_userFull *)userFullWithUser:(API17_User *)user link:(API17_contacts_Link *)link profile_photo:(API17_Photo *)profile_photo notify_settings:(API17_PeerNotifySettings *)notify_settings blocked:(API17_Bool *)blocked real_first_name:(NSString *)real_first_name real_last_name:(NSString *)real_last_name;

@end

@interface API17_UserFull_userFull : API17_UserFull

@end


@interface API17_InputPeerNotifyEvents : NSObject

+ (API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty *)inputPeerNotifyEventsEmpty;
+ (API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll *)inputPeerNotifyEventsAll;

@end

@interface API17_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty : API17_InputPeerNotifyEvents

@end

@interface API17_InputPeerNotifyEvents_inputPeerNotifyEventsAll : API17_InputPeerNotifyEvents

@end


@interface API17_DcOption : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * hostname;
@property (nonatomic, strong, readonly) NSString * ip_address;
@property (nonatomic, strong, readonly) NSNumber * port;

+ (API17_DcOption_dcOption *)dcOptionWithPid:(NSNumber *)pid hostname:(NSString *)hostname ip_address:(NSString *)ip_address port:(NSNumber *)port;

@end

@interface API17_DcOption_dcOption : API17_DcOption

@end


@interface API17_MsgsStateReq : NSObject

@property (nonatomic, strong, readonly) NSArray * msg_ids;

+ (API17_MsgsStateReq_msgs_state_req *)msgs_state_reqWithMsg_ids:(NSArray *)msg_ids;

@end

@interface API17_MsgsStateReq_msgs_state_req : API17_MsgsStateReq

@end


@interface API17_help_AppUpdate : NSObject

+ (API17_help_AppUpdate_help_appUpdate *)help_appUpdateWithPid:(NSNumber *)pid critical:(API17_Bool *)critical url:(NSString *)url text:(NSString *)text;
+ (API17_help_AppUpdate_help_noAppUpdate *)help_noAppUpdate;

@end

@interface API17_help_AppUpdate_help_appUpdate : API17_help_AppUpdate

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) API17_Bool * critical;
@property (nonatomic, strong, readonly) NSString * url;
@property (nonatomic, strong, readonly) NSString * text;

@end

@interface API17_help_AppUpdate_help_noAppUpdate : API17_help_AppUpdate

@end


@interface API17_contacts_SentLink : NSObject

@property (nonatomic, strong, readonly) API17_messages_Message * message;
@property (nonatomic, strong, readonly) API17_contacts_Link * link;

+ (API17_contacts_SentLink_contacts_sentLink *)contacts_sentLinkWithMessage:(API17_messages_Message *)message link:(API17_contacts_Link *)link;

@end

@interface API17_contacts_SentLink_contacts_sentLink : API17_contacts_SentLink

@end


@interface API17_ResPQ : NSObject

@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;
@property (nonatomic, strong, readonly) NSData * pq;
@property (nonatomic, strong, readonly) NSArray * server_public_key_fingerprints;

+ (API17_ResPQ_resPQ *)resPQWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pq:(NSData *)pq server_public_key_fingerprints:(NSArray *)server_public_key_fingerprints;

@end

@interface API17_ResPQ_resPQ : API17_ResPQ

@end


@interface API17_storage_FileType : NSObject

+ (API17_storage_FileType_storage_fileUnknown *)storage_fileUnknown;
+ (API17_storage_FileType_storage_fileJpeg *)storage_fileJpeg;
+ (API17_storage_FileType_storage_fileGif *)storage_fileGif;
+ (API17_storage_FileType_storage_filePng *)storage_filePng;
+ (API17_storage_FileType_storage_filePdf *)storage_filePdf;
+ (API17_storage_FileType_storage_fileMp3 *)storage_fileMp3;
+ (API17_storage_FileType_storage_fileMov *)storage_fileMov;
+ (API17_storage_FileType_storage_filePartial *)storage_filePartial;
+ (API17_storage_FileType_storage_fileMp4 *)storage_fileMp4;
+ (API17_storage_FileType_storage_fileWebp *)storage_fileWebp;

@end

@interface API17_storage_FileType_storage_fileUnknown : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileJpeg : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileGif : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_filePng : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_filePdf : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileMp3 : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileMov : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_filePartial : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileMp4 : API17_storage_FileType

@end

@interface API17_storage_FileType_storage_fileWebp : API17_storage_FileType

@end


@interface API17_InputEncryptedFile : NSObject

+ (API17_InputEncryptedFile_inputEncryptedFileEmpty *)inputEncryptedFileEmpty;
+ (API17_InputEncryptedFile_inputEncryptedFileUploaded *)inputEncryptedFileUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(NSNumber *)key_fingerprint;
+ (API17_InputEncryptedFile_inputEncryptedFile *)inputEncryptedFileWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;
+ (API17_InputEncryptedFile_inputEncryptedFileBigUploaded *)inputEncryptedFileBigUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts key_fingerprint:(NSNumber *)key_fingerprint;

@end

@interface API17_InputEncryptedFile_inputEncryptedFileEmpty : API17_InputEncryptedFile

@end

@interface API17_InputEncryptedFile_inputEncryptedFileUploaded : API17_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSString * md5_checksum;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end

@interface API17_InputEncryptedFile_inputEncryptedFile : API17_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end

@interface API17_InputEncryptedFile_inputEncryptedFileBigUploaded : API17_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end


@interface API17_FutureSalts : NSObject

+ (API17_FutureSalts_futureSalts *)futureSalts;

@end

@interface API17_FutureSalts_futureSalts : API17_FutureSalts

@end


@interface API17_messages_SentEncryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;

+ (API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage *)messages_sentEncryptedMessageWithDate:(NSNumber *)date;
+ (API17_messages_SentEncryptedMessage_messages_sentEncryptedFile *)messages_sentEncryptedFileWithDate:(NSNumber *)date file:(API17_EncryptedFile *)file;

@end

@interface API17_messages_SentEncryptedMessage_messages_sentEncryptedMessage : API17_messages_SentEncryptedMessage

@end

@interface API17_messages_SentEncryptedMessage_messages_sentEncryptedFile : API17_messages_SentEncryptedMessage

@property (nonatomic, strong, readonly) API17_EncryptedFile * file;

@end


@interface API17_auth_Authorization : NSObject

@property (nonatomic, strong, readonly) NSNumber * expires;
@property (nonatomic, strong, readonly) API17_User * user;

+ (API17_auth_Authorization_auth_authorization *)auth_authorizationWithExpires:(NSNumber *)expires user:(API17_User *)user;

@end

@interface API17_auth_Authorization_auth_authorization : API17_auth_Authorization

@end


@interface API17_InputFile : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSString * name;

+ (API17_InputFile_inputFile *)inputFileWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name md5_checksum:(NSString *)md5_checksum;
+ (API17_InputFile_inputFileBig *)inputFileBigWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name;

@end

@interface API17_InputFile_inputFile : API17_InputFile

@property (nonatomic, strong, readonly) NSString * md5_checksum;

@end

@interface API17_InputFile_inputFileBig : API17_InputFile

@end


@interface API17_Peer : NSObject

+ (API17_Peer_peerUser *)peerUserWithUser_id:(NSNumber *)user_id;
+ (API17_Peer_peerChat *)peerChatWithChat_id:(NSNumber *)chat_id;

@end

@interface API17_Peer_peerUser : API17_Peer

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_Peer_peerChat : API17_Peer

@property (nonatomic, strong, readonly) NSNumber * chat_id;

@end


@interface API17_UserStatus : NSObject

+ (API17_UserStatus_userStatusEmpty *)userStatusEmpty;
+ (API17_UserStatus_userStatusOnline *)userStatusOnlineWithExpires:(NSNumber *)expires;
+ (API17_UserStatus_userStatusOffline *)userStatusOfflineWithWas_online:(NSNumber *)was_online;

@end

@interface API17_UserStatus_userStatusEmpty : API17_UserStatus

@end

@interface API17_UserStatus_userStatusOnline : API17_UserStatus

@property (nonatomic, strong, readonly) NSNumber * expires;

@end

@interface API17_UserStatus_userStatusOffline : API17_UserStatus

@property (nonatomic, strong, readonly) NSNumber * was_online;

@end


@interface API17_Dialog : NSObject

@property (nonatomic, strong, readonly) API17_Peer * peer;
@property (nonatomic, strong, readonly) NSNumber * top_message;
@property (nonatomic, strong, readonly) NSNumber * unread_count;
@property (nonatomic, strong, readonly) API17_PeerNotifySettings * notify_settings;

+ (API17_Dialog_dialog *)dialogWithPeer:(API17_Peer *)peer top_message:(NSNumber *)top_message unread_count:(NSNumber *)unread_count notify_settings:(API17_PeerNotifySettings *)notify_settings;

@end

@interface API17_Dialog_dialog : API17_Dialog

@end


@interface API17_MsgsAllInfo : NSObject

@property (nonatomic, strong, readonly) NSArray * msg_ids;
@property (nonatomic, strong, readonly) NSString * info;

+ (API17_MsgsAllInfo_msgs_all_info *)msgs_all_infoWithMsg_ids:(NSArray *)msg_ids info:(NSString *)info;

@end

@interface API17_MsgsAllInfo_msgs_all_info : API17_MsgsAllInfo

@end


@interface API17_SendMessageAction : NSObject

+ (API17_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (API17_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (API17_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (API17_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (API17_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (API17_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (API17_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (API17_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (API17_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (API17_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface API17_SendMessageAction_sendMessageTypingAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageCancelAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageRecordVideoAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageUploadVideoAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageRecordAudioAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageUploadAudioAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageUploadPhotoAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageUploadDocumentAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageGeoLocationAction : API17_SendMessageAction

@end

@interface API17_SendMessageAction_sendMessageChooseContactAction : API17_SendMessageAction

@end


@interface API17_Update : NSObject

+ (API17_Update_updateNewGeoChatMessage *)updateNewGeoChatMessageWithMessage:(API17_GeoChatMessage *)message;
+ (API17_Update_updateNewMessage *)updateNewMessageWithMessage:(API17_Message *)message pts:(NSNumber *)pts;
+ (API17_Update_updateMessageID *)updateMessageIDWithPid:(NSNumber *)pid random_id:(NSNumber *)random_id;
+ (API17_Update_updateReadMessages *)updateReadMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts;
+ (API17_Update_updateDeleteMessages *)updateDeleteMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts;
+ (API17_Update_updateRestoreMessages *)updateRestoreMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts;
+ (API17_Update_updateChatParticipants *)updateChatParticipantsWithParticipants:(API17_ChatParticipants *)participants;
+ (API17_Update_updateUserStatus *)updateUserStatusWithUser_id:(NSNumber *)user_id status:(API17_UserStatus *)status;
+ (API17_Update_updateUserName *)updateUserNameWithUser_id:(NSNumber *)user_id first_name:(NSString *)first_name last_name:(NSString *)last_name;
+ (API17_Update_updateUserPhoto *)updateUserPhotoWithUser_id:(NSNumber *)user_id photo:(API17_UserProfilePhoto *)photo;
+ (API17_Update_updateContactRegistered *)updateContactRegisteredWithUser_id:(NSNumber *)user_id date:(NSNumber *)date;
+ (API17_Update_updateContactLink *)updateContactLinkWithUser_id:(NSNumber *)user_id my_link:(API17_contacts_MyLink *)my_link foreign_link:(API17_contacts_ForeignLink *)foreign_link;
+ (API17_Update_updateContactLocated *)updateContactLocatedWithContacts:(NSArray *)contacts;
+ (API17_Update_updateActivation *)updateActivationWithUser_id:(NSNumber *)user_id;
+ (API17_Update_updateNewAuthorization *)updateNewAuthorizationWithAuth_key_id:(NSNumber *)auth_key_id date:(NSNumber *)date device:(NSString *)device location:(NSString *)location;
+ (API17_Update_updatePhoneCallRequested *)updatePhoneCallRequestedWithPhone_call:(API17_PhoneCall *)phone_call;
+ (API17_Update_updatePhoneCallConfirmed *)updatePhoneCallConfirmedWithPid:(NSNumber *)pid a_or_b:(NSData *)a_or_b connection:(API17_PhoneConnection *)connection;
+ (API17_Update_updatePhoneCallDeclined *)updatePhoneCallDeclinedWithPid:(NSNumber *)pid;
+ (API17_Update_updateNewEncryptedMessage *)updateNewEncryptedMessageWithMessage:(API17_EncryptedMessage *)message qts:(NSNumber *)qts;
+ (API17_Update_updateEncryptedChatTyping *)updateEncryptedChatTypingWithChat_id:(NSNumber *)chat_id;
+ (API17_Update_updateEncryption *)updateEncryptionWithChat:(API17_EncryptedChat *)chat date:(NSNumber *)date;
+ (API17_Update_updateEncryptedMessagesRead *)updateEncryptedMessagesReadWithChat_id:(NSNumber *)chat_id max_date:(NSNumber *)max_date date:(NSNumber *)date;
+ (API17_Update_updateChatParticipantAdd *)updateChatParticipantAddWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id inviter_id:(NSNumber *)inviter_id version:(NSNumber *)version;
+ (API17_Update_updateChatParticipantDelete *)updateChatParticipantDeleteWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id version:(NSNumber *)version;
+ (API17_Update_updateDcOptions *)updateDcOptionsWithDc_options:(NSArray *)dc_options;
+ (API17_Update_updateUserBlocked *)updateUserBlockedWithUser_id:(NSNumber *)user_id blocked:(API17_Bool *)blocked;
+ (API17_Update_updateNotifySettings *)updateNotifySettingsWithPeer:(API17_NotifyPeer *)peer notify_settings:(API17_PeerNotifySettings *)notify_settings;
+ (API17_Update_updateUserTyping *)updateUserTypingWithUser_id:(NSNumber *)user_id action:(API17_SendMessageAction *)action;
+ (API17_Update_updateChatUserTyping *)updateChatUserTypingWithChat_id:(NSNumber *)chat_id user_id:(NSNumber *)user_id action:(API17_SendMessageAction *)action;

@end

@interface API17_Update_updateNewGeoChatMessage : API17_Update

@property (nonatomic, strong, readonly) API17_GeoChatMessage * message;

@end

@interface API17_Update_updateNewMessage : API17_Update

@property (nonatomic, strong, readonly) API17_Message * message;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end

@interface API17_Update_updateMessageID : API17_Update

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * random_id;

@end

@interface API17_Update_updateReadMessages : API17_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end

@interface API17_Update_updateDeleteMessages : API17_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end

@interface API17_Update_updateRestoreMessages : API17_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end

@interface API17_Update_updateChatParticipants : API17_Update

@property (nonatomic, strong, readonly) API17_ChatParticipants * participants;

@end

@interface API17_Update_updateUserStatus : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_UserStatus * status;

@end

@interface API17_Update_updateUserName : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;

@end

@interface API17_Update_updateUserPhoto : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_UserProfilePhoto * photo;

@end

@interface API17_Update_updateContactRegistered : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface API17_Update_updateContactLink : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_contacts_MyLink * my_link;
@property (nonatomic, strong, readonly) API17_contacts_ForeignLink * foreign_link;

@end

@interface API17_Update_updateContactLocated : API17_Update

@property (nonatomic, strong, readonly) NSArray * contacts;

@end

@interface API17_Update_updateActivation : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_Update_updateNewAuthorization : API17_Update

@property (nonatomic, strong, readonly) NSNumber * auth_key_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * device;
@property (nonatomic, strong, readonly) NSString * location;

@end

@interface API17_Update_updatePhoneCallRequested : API17_Update

@property (nonatomic, strong, readonly) API17_PhoneCall * phone_call;

@end

@interface API17_Update_updatePhoneCallConfirmed : API17_Update

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSData * a_or_b;
@property (nonatomic, strong, readonly) API17_PhoneConnection * connection;

@end

@interface API17_Update_updatePhoneCallDeclined : API17_Update

@property (nonatomic, strong, readonly) NSNumber * pid;

@end

@interface API17_Update_updateNewEncryptedMessage : API17_Update

@property (nonatomic, strong, readonly) API17_EncryptedMessage * message;
@property (nonatomic, strong, readonly) NSNumber * qts;

@end

@interface API17_Update_updateEncryptedChatTyping : API17_Update

@property (nonatomic, strong, readonly) NSNumber * chat_id;

@end

@interface API17_Update_updateEncryption : API17_Update

@property (nonatomic, strong, readonly) API17_EncryptedChat * chat;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface API17_Update_updateEncryptedMessagesRead : API17_Update

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * max_date;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface API17_Update_updateChatParticipantAdd : API17_Update

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * inviter_id;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface API17_Update_updateChatParticipantDelete : API17_Update

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface API17_Update_updateDcOptions : API17_Update

@property (nonatomic, strong, readonly) NSArray * dc_options;

@end

@interface API17_Update_updateUserBlocked : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_Bool * blocked;

@end

@interface API17_Update_updateNotifySettings : API17_Update

@property (nonatomic, strong, readonly) API17_NotifyPeer * peer;
@property (nonatomic, strong, readonly) API17_PeerNotifySettings * notify_settings;

@end

@interface API17_Update_updateUserTyping : API17_Update

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_SendMessageAction * action;

@end

@interface API17_Update_updateChatUserTyping : API17_Update

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_SendMessageAction * action;

@end


@interface API17_contacts_Blocked : NSObject

@property (nonatomic, strong, readonly) NSArray * blocked;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_Blocked_contacts_blocked *)contacts_blockedWithBlocked:(NSArray *)blocked users:(NSArray *)users;
+ (API17_contacts_Blocked_contacts_blockedSlice *)contacts_blockedSliceWithCount:(NSNumber *)count blocked:(NSArray *)blocked users:(NSArray *)users;

@end

@interface API17_contacts_Blocked_contacts_blocked : API17_contacts_Blocked

@end

@interface API17_contacts_Blocked_contacts_blockedSlice : API17_contacts_Blocked

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_Error : NSObject

@property (nonatomic, strong, readonly) NSNumber * code;

+ (API17_Error_error *)errorWithCode:(NSNumber *)code text:(NSString *)text;
+ (API17_Error_richError *)richErrorWithCode:(NSNumber *)code type:(NSString *)type n_description:(NSString *)n_description debug:(NSString *)debug request_params:(NSString *)request_params;

@end

@interface API17_Error_error : API17_Error

@property (nonatomic, strong, readonly) NSString * text;

@end

@interface API17_Error_richError : API17_Error

@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSString * n_description;
@property (nonatomic, strong, readonly) NSString * debug;
@property (nonatomic, strong, readonly) NSString * request_params;

@end


@interface API17_ContactLocated : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * distance;

+ (API17_ContactLocated_contactLocated *)contactLocatedWithUser_id:(NSNumber *)user_id location:(API17_GeoPoint *)location date:(NSNumber *)date distance:(NSNumber *)distance;
+ (API17_ContactLocated_contactLocatedPreview *)contactLocatedPreviewWithPhash:(NSString *)phash hidden:(API17_Bool *)hidden date:(NSNumber *)date distance:(NSNumber *)distance;

@end

@interface API17_ContactLocated_contactLocated : API17_ContactLocated

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_GeoPoint * location;

@end

@interface API17_ContactLocated_contactLocatedPreview : API17_ContactLocated

@property (nonatomic, strong, readonly) NSString * phash;
@property (nonatomic, strong, readonly) API17_Bool * hidden;

@end


@interface API17_ContactStatus : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * expires;

+ (API17_ContactStatus_contactStatus *)contactStatusWithUser_id:(NSNumber *)user_id expires:(NSNumber *)expires;

@end

@interface API17_ContactStatus_contactStatus : API17_ContactStatus

@end


@interface API17_geochats_Messages : NSObject

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_geochats_Messages_geochats_messages *)geochats_messagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (API17_geochats_Messages_geochats_messagesSlice *)geochats_messagesSliceWithCount:(NSNumber *)count messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_geochats_Messages_geochats_messages : API17_geochats_Messages

@end

@interface API17_geochats_Messages_geochats_messagesSlice : API17_geochats_Messages

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_MsgsStateInfo : NSObject

@property (nonatomic, strong, readonly) NSNumber * req_msg_id;
@property (nonatomic, strong, readonly) NSString * info;

+ (API17_MsgsStateInfo_msgs_state_info *)msgs_state_infoWithReq_msg_id:(NSNumber *)req_msg_id info:(NSString *)info;

@end

@interface API17_MsgsStateInfo_msgs_state_info : API17_MsgsStateInfo

@end


@interface API17_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (API17_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (API17_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(API17_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (API17_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(API17_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface API17_PhotoSize_photoSizeEmpty : API17_PhotoSize

@end

@interface API17_PhotoSize_photoSize : API17_PhotoSize

@property (nonatomic, strong, readonly) API17_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface API17_PhotoSize_photoCachedSize : API17_PhotoSize

@property (nonatomic, strong, readonly) API17_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface API17_GlobalPrivacySettings : NSObject

@property (nonatomic, strong, readonly) API17_Bool * no_suggestions;
@property (nonatomic, strong, readonly) API17_Bool * hide_contacts;
@property (nonatomic, strong, readonly) API17_Bool * hide_located;
@property (nonatomic, strong, readonly) API17_Bool * hide_last_visit;

+ (API17_GlobalPrivacySettings_globalPrivacySettings *)globalPrivacySettingsWithNo_suggestions:(API17_Bool *)no_suggestions hide_contacts:(API17_Bool *)hide_contacts hide_located:(API17_Bool *)hide_located hide_last_visit:(API17_Bool *)hide_last_visit;

@end

@interface API17_GlobalPrivacySettings_globalPrivacySettings : API17_GlobalPrivacySettings

@end


@interface API17_InputGeoChat : NSObject

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

+ (API17_InputGeoChat_inputGeoChat *)inputGeoChatWithChat_id:(NSNumber *)chat_id access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputGeoChat_inputGeoChat : API17_InputGeoChat

@end


@interface API17_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volume_id;
@property (nonatomic, strong, readonly) NSNumber * local_id;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (API17_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret;
+ (API17_FileLocation_fileLocation *)fileLocationWithDc_id:(NSNumber *)dc_id volume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret;

@end

@interface API17_FileLocation_fileLocationUnavailable : API17_FileLocation

@end

@interface API17_FileLocation_fileLocation : API17_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dc_id;

@end


@interface API17_InputNotifyPeer : NSObject

+ (API17_InputNotifyPeer_inputNotifyGeoChatPeer *)inputNotifyGeoChatPeerWithPeer:(API17_InputGeoChat *)peer;
+ (API17_InputNotifyPeer_inputNotifyPeer *)inputNotifyPeerWithPeer:(API17_InputPeer *)peer;
+ (API17_InputNotifyPeer_inputNotifyUsers *)inputNotifyUsers;
+ (API17_InputNotifyPeer_inputNotifyChats *)inputNotifyChats;
+ (API17_InputNotifyPeer_inputNotifyAll *)inputNotifyAll;

@end

@interface API17_InputNotifyPeer_inputNotifyGeoChatPeer : API17_InputNotifyPeer

@property (nonatomic, strong, readonly) API17_InputGeoChat * peer;

@end

@interface API17_InputNotifyPeer_inputNotifyPeer : API17_InputNotifyPeer

@property (nonatomic, strong, readonly) API17_InputPeer * peer;

@end

@interface API17_InputNotifyPeer_inputNotifyUsers : API17_InputNotifyPeer

@end

@interface API17_InputNotifyPeer_inputNotifyChats : API17_InputNotifyPeer

@end

@interface API17_InputNotifyPeer_inputNotifyAll : API17_InputNotifyPeer

@end


@interface API17_EncryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (API17_EncryptedMessage_encryptedMessage *)encryptedMessageWithRandom_id:(NSNumber *)random_id chat_id:(NSNumber *)chat_id date:(NSNumber *)date bytes:(NSData *)bytes file:(API17_EncryptedFile *)file;
+ (API17_EncryptedMessage_encryptedMessageService *)encryptedMessageServiceWithRandom_id:(NSNumber *)random_id chat_id:(NSNumber *)chat_id date:(NSNumber *)date bytes:(NSData *)bytes;

@end

@interface API17_EncryptedMessage_encryptedMessage : API17_EncryptedMessage

@property (nonatomic, strong, readonly) API17_EncryptedFile * file;

@end

@interface API17_EncryptedMessage_encryptedMessageService : API17_EncryptedMessage

@end


@interface API17_photos_Photo : NSObject

@property (nonatomic, strong, readonly) API17_Photo * photo;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_photos_Photo_photos_photo *)photos_photoWithPhoto:(API17_Photo *)photo users:(NSArray *)users;

@end

@interface API17_photos_Photo_photos_photo : API17_photos_Photo

@end


@interface API17_InputContact : NSObject

@property (nonatomic, strong, readonly) NSNumber * client_id;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;

+ (API17_InputContact_inputPhoneContact *)inputPhoneContactWithClient_id:(NSNumber *)client_id phone:(NSString *)phone first_name:(NSString *)first_name last_name:(NSString *)last_name;

@end

@interface API17_InputContact_inputPhoneContact : API17_InputContact

@end


@interface API17_contacts_Contacts : NSObject

+ (API17_contacts_Contacts_contacts_contacts *)contacts_contactsWithContacts:(NSArray *)contacts users:(NSArray *)users;
+ (API17_contacts_Contacts_contacts_contactsNotModified *)contacts_contactsNotModified;

@end

@interface API17_contacts_Contacts_contacts_contacts : API17_contacts_Contacts

@property (nonatomic, strong, readonly) NSArray * contacts;
@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface API17_contacts_Contacts_contacts_contactsNotModified : API17_contacts_Contacts

@end


@interface API17_BadMsgNotification : NSObject

@property (nonatomic, strong, readonly) NSNumber * bad_msg_id;
@property (nonatomic, strong, readonly) NSNumber * bad_msg_seqno;
@property (nonatomic, strong, readonly) NSNumber * error_code;

+ (API17_BadMsgNotification_bad_msg_notification *)bad_msg_notificationWithBad_msg_id:(NSNumber *)bad_msg_id bad_msg_seqno:(NSNumber *)bad_msg_seqno error_code:(NSNumber *)error_code;
+ (API17_BadMsgNotification_bad_server_salt *)bad_server_saltWithBad_msg_id:(NSNumber *)bad_msg_id bad_msg_seqno:(NSNumber *)bad_msg_seqno error_code:(NSNumber *)error_code pnew_server_salt:(NSNumber *)pnew_server_salt;

@end

@interface API17_BadMsgNotification_bad_msg_notification : API17_BadMsgNotification

@end

@interface API17_BadMsgNotification_bad_server_salt : API17_BadMsgNotification

@property (nonatomic, strong, readonly) NSNumber * pnew_server_salt;

@end


@interface API17_InputDocument : NSObject

+ (API17_InputDocument_inputDocumentEmpty *)inputDocumentEmpty;
+ (API17_InputDocument_inputDocument *)inputDocumentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputDocument_inputDocumentEmpty : API17_InputDocument

@end

@interface API17_InputDocument_inputDocument : API17_InputDocument

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_InputMedia : NSObject

+ (API17_InputMedia_inputMediaEmpty *)inputMediaEmpty;
+ (API17_InputMedia_inputMediaUploadedPhoto *)inputMediaUploadedPhotoWithFile:(API17_InputFile *)file;
+ (API17_InputMedia_inputMediaPhoto *)inputMediaPhotoWithPid:(API17_InputPhoto *)pid;
+ (API17_InputMedia_inputMediaGeoPoint *)inputMediaGeoPointWithGeo_point:(API17_InputGeoPoint *)geo_point;
+ (API17_InputMedia_inputMediaContact *)inputMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name;
+ (API17_InputMedia_inputMediaVideo *)inputMediaVideoWithPid:(API17_InputVideo *)pid;
+ (API17_InputMedia_inputMediaAudio *)inputMediaAudioWithPid:(API17_InputAudio *)pid;
+ (API17_InputMedia_inputMediaUploadedDocument *)inputMediaUploadedDocumentWithFile:(API17_InputFile *)file file_name:(NSString *)file_name mime_type:(NSString *)mime_type;
+ (API17_InputMedia_inputMediaUploadedThumbDocument *)inputMediaUploadedThumbDocumentWithFile:(API17_InputFile *)file thumb:(API17_InputFile *)thumb file_name:(NSString *)file_name mime_type:(NSString *)mime_type;
+ (API17_InputMedia_inputMediaDocument *)inputMediaDocumentWithPid:(API17_InputDocument *)pid;
+ (API17_InputMedia_inputMediaUploadedAudio *)inputMediaUploadedAudioWithFile:(API17_InputFile *)file duration:(NSNumber *)duration mime_type:(NSString *)mime_type;
+ (API17_InputMedia_inputMediaUploadedVideo *)inputMediaUploadedVideoWithFile:(API17_InputFile *)file duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mime_type:(NSString *)mime_type;
+ (API17_InputMedia_inputMediaUploadedThumbVideo *)inputMediaUploadedThumbVideoWithFile:(API17_InputFile *)file thumb:(API17_InputFile *)thumb duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mime_type:(NSString *)mime_type;

@end

@interface API17_InputMedia_inputMediaEmpty : API17_InputMedia

@end

@interface API17_InputMedia_inputMediaUploadedPhoto : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;

@end

@interface API17_InputMedia_inputMediaPhoto : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputPhoto * pid;

@end

@interface API17_InputMedia_inputMediaGeoPoint : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputGeoPoint * geo_point;

@end

@interface API17_InputMedia_inputMediaContact : API17_InputMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;

@end

@interface API17_InputMedia_inputMediaVideo : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputVideo * pid;

@end

@interface API17_InputMedia_inputMediaAudio : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputAudio * pid;

@end

@interface API17_InputMedia_inputMediaUploadedDocument : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedThumbDocument : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) API17_InputFile * thumb;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaDocument : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputDocument * pid;

@end

@interface API17_InputMedia_inputMediaUploadedAudio : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedVideo : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSString * mime_type;

@end

@interface API17_InputMedia_inputMediaUploadedThumbVideo : API17_InputMedia

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) API17_InputFile * thumb;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSString * mime_type;

@end


@interface API17_InputPeer : NSObject

+ (API17_InputPeer_inputPeerEmpty *)inputPeerEmpty;
+ (API17_InputPeer_inputPeerSelf *)inputPeerSelf;
+ (API17_InputPeer_inputPeerContact *)inputPeerContactWithUser_id:(NSNumber *)user_id;
+ (API17_InputPeer_inputPeerForeign *)inputPeerForeignWithUser_id:(NSNumber *)user_id access_hash:(NSNumber *)access_hash;
+ (API17_InputPeer_inputPeerChat *)inputPeerChatWithChat_id:(NSNumber *)chat_id;

@end

@interface API17_InputPeer_inputPeerEmpty : API17_InputPeer

@end

@interface API17_InputPeer_inputPeerSelf : API17_InputPeer

@end

@interface API17_InputPeer_inputPeerContact : API17_InputPeer

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_InputPeer_inputPeerForeign : API17_InputPeer

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end

@interface API17_InputPeer_inputPeerChat : API17_InputPeer

@property (nonatomic, strong, readonly) NSNumber * chat_id;

@end


@interface API17_Contact : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) API17_Bool * mutual;

+ (API17_Contact_contact *)contactWithUser_id:(NSNumber *)user_id mutual:(API17_Bool *)mutual;

@end

@interface API17_Contact_contact : API17_Contact

@end


@interface API17_messages_Chats : NSObject

@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_messages_Chats_messages_chats *)messages_chatsWithChats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_messages_Chats_messages_chats : API17_messages_Chats

@end


@interface API17_P_Q_inner_data : NSObject

@property (nonatomic, strong, readonly) NSData * pq;
@property (nonatomic, strong, readonly) NSData * p;
@property (nonatomic, strong, readonly) NSData * q;
@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;
@property (nonatomic, strong, readonly) NSData * pnew_nonce;

+ (API17_P_Q_inner_data_p_q_inner_data *)p_q_inner_dataWithPq:(NSData *)pq p:(NSData *)p q:(NSData *)q nonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce:(NSData *)pnew_nonce;

@end

@interface API17_P_Q_inner_data_p_q_inner_data : API17_P_Q_inner_data

@end


@interface API17_contacts_MyLink : NSObject

+ (API17_contacts_MyLink_contacts_myLinkEmpty *)contacts_myLinkEmpty;
+ (API17_contacts_MyLink_contacts_myLinkRequested *)contacts_myLinkRequestedWithContact:(API17_Bool *)contact;
+ (API17_contacts_MyLink_contacts_myLinkContact *)contacts_myLinkContact;

@end

@interface API17_contacts_MyLink_contacts_myLinkEmpty : API17_contacts_MyLink

@end

@interface API17_contacts_MyLink_contacts_myLinkRequested : API17_contacts_MyLink

@property (nonatomic, strong, readonly) API17_Bool * contact;

@end

@interface API17_contacts_MyLink_contacts_myLinkContact : API17_contacts_MyLink

@end


@interface API17_messages_DhConfig : NSObject

@property (nonatomic, strong, readonly) NSData * random;

+ (API17_messages_DhConfig_messages_dhConfigNotModified *)messages_dhConfigNotModifiedWithRandom:(NSData *)random;
+ (API17_messages_DhConfig_messages_dhConfig *)messages_dhConfigWithG:(NSNumber *)g p:(NSData *)p version:(NSNumber *)version random:(NSData *)random;

@end

@interface API17_messages_DhConfig_messages_dhConfigNotModified : API17_messages_DhConfig

@end

@interface API17_messages_DhConfig_messages_dhConfig : API17_messages_DhConfig

@property (nonatomic, strong, readonly) NSNumber * g;
@property (nonatomic, strong, readonly) NSData * p;
@property (nonatomic, strong, readonly) NSNumber * version;

@end


@interface API17_auth_ExportedAuthorization : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (API17_auth_ExportedAuthorization_auth_exportedAuthorization *)auth_exportedAuthorizationWithPid:(NSNumber *)pid bytes:(NSData *)bytes;

@end

@interface API17_auth_ExportedAuthorization_auth_exportedAuthorization : API17_auth_ExportedAuthorization

@end


@interface API17_ContactRequest : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (API17_ContactRequest_contactRequest *)contactRequestWithUser_id:(NSNumber *)user_id date:(NSNumber *)date;

@end

@interface API17_ContactRequest_contactRequest : API17_ContactRequest

@end


@interface API17_messages_AffectedHistory : NSObject

@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * seq;
@property (nonatomic, strong, readonly) NSNumber * offset;

+ (API17_messages_AffectedHistory_messages_affectedHistory *)messages_affectedHistoryWithPts:(NSNumber *)pts seq:(NSNumber *)seq offset:(NSNumber *)offset;

@end

@interface API17_messages_AffectedHistory_messages_affectedHistory : API17_messages_AffectedHistory

@end


@interface API17_messages_SentMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * seq;

+ (API17_messages_SentMessage_messages_sentMessageLink *)messages_sentMessageLinkWithPid:(NSNumber *)pid date:(NSNumber *)date pts:(NSNumber *)pts seq:(NSNumber *)seq links:(NSArray *)links;
+ (API17_messages_SentMessage_messages_sentMessage *)messages_sentMessageWithPid:(NSNumber *)pid date:(NSNumber *)date pts:(NSNumber *)pts seq:(NSNumber *)seq;

@end

@interface API17_messages_SentMessage_messages_sentMessageLink : API17_messages_SentMessage

@property (nonatomic, strong, readonly) NSArray * links;

@end

@interface API17_messages_SentMessage_messages_sentMessage : API17_messages_SentMessage

@end


@interface API17_messages_ChatFull : NSObject

@property (nonatomic, strong, readonly) API17_ChatFull * full_chat;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_messages_ChatFull_messages_chatFull *)messages_chatFullWithFull_chat:(API17_ChatFull *)full_chat chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_messages_ChatFull_messages_chatFull : API17_messages_ChatFull

@end


@interface API17_contacts_ForeignLink : NSObject

+ (API17_contacts_ForeignLink_contacts_foreignLinkUnknown *)contacts_foreignLinkUnknown;
+ (API17_contacts_ForeignLink_contacts_foreignLinkRequested *)contacts_foreignLinkRequestedWithHas_phone:(API17_Bool *)has_phone;
+ (API17_contacts_ForeignLink_contacts_foreignLinkMutual *)contacts_foreignLinkMutual;

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkUnknown : API17_contacts_ForeignLink

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkRequested : API17_contacts_ForeignLink

@property (nonatomic, strong, readonly) API17_Bool * has_phone;

@end

@interface API17_contacts_ForeignLink_contacts_foreignLinkMutual : API17_contacts_ForeignLink

@end


@interface API17_InputEncryptedChat : NSObject

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

+ (API17_InputEncryptedChat_inputEncryptedChat *)inputEncryptedChatWithChat_id:(NSNumber *)chat_id access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputEncryptedChat_inputEncryptedChat : API17_InputEncryptedChat

@end


@interface API17_InvokeWithLayer17 : NSObject

@property (nonatomic, strong, readonly) NSObject * query;

+ (API17_InvokeWithLayer17_invokeWithLayer17 *)invokeWithLayer17WithQuery:(NSObject *)query;

@end

@interface API17_InvokeWithLayer17_invokeWithLayer17 : API17_InvokeWithLayer17

@end


@interface API17_EncryptedFile : NSObject

+ (API17_EncryptedFile_encryptedFileEmpty *)encryptedFileEmpty;
+ (API17_EncryptedFile_encryptedFile *)encryptedFileWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash size:(NSNumber *)size dc_id:(NSNumber *)dc_id key_fingerprint:(NSNumber *)key_fingerprint;

@end

@interface API17_EncryptedFile_encryptedFileEmpty : API17_EncryptedFile

@end

@interface API17_EncryptedFile_encryptedFile : API17_EncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSNumber * dc_id;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end


@interface API17_ContactFound : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;

+ (API17_ContactFound_contactFound *)contactFoundWithUser_id:(NSNumber *)user_id;

@end

@interface API17_ContactFound_contactFound : API17_ContactFound

@end


@interface API17_NotifyPeer : NSObject

+ (API17_NotifyPeer_notifyPeer *)notifyPeerWithPeer:(API17_Peer *)peer;
+ (API17_NotifyPeer_notifyUsers *)notifyUsers;
+ (API17_NotifyPeer_notifyChats *)notifyChats;
+ (API17_NotifyPeer_notifyAll *)notifyAll;

@end

@interface API17_NotifyPeer_notifyPeer : API17_NotifyPeer

@property (nonatomic, strong, readonly) API17_Peer * peer;

@end

@interface API17_NotifyPeer_notifyUsers : API17_NotifyPeer

@end

@interface API17_NotifyPeer_notifyChats : API17_NotifyPeer

@end

@interface API17_NotifyPeer_notifyAll : API17_NotifyPeer

@end


@interface API17_Client_DH_Inner_Data : NSObject

@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;
@property (nonatomic, strong, readonly) NSNumber * retry_id;
@property (nonatomic, strong, readonly) NSData * g_b;

+ (API17_Client_DH_Inner_Data_client_DH_inner_data *)client_DH_inner_dataWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce retry_id:(NSNumber *)retry_id g_b:(NSData *)g_b;

@end

@interface API17_Client_DH_Inner_Data_client_DH_inner_data : API17_Client_DH_Inner_Data

@end


@interface API17_contacts_Link : NSObject

@property (nonatomic, strong, readonly) API17_contacts_MyLink * my_link;
@property (nonatomic, strong, readonly) API17_contacts_ForeignLink * foreign_link;
@property (nonatomic, strong, readonly) API17_User * user;

+ (API17_contacts_Link_contacts_link *)contacts_linkWithMy_link:(API17_contacts_MyLink *)my_link foreign_link:(API17_contacts_ForeignLink *)foreign_link user:(API17_User *)user;

@end

@interface API17_contacts_Link_contacts_link : API17_contacts_Link

@end


@interface API17_ContactBlocked : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (API17_ContactBlocked_contactBlocked *)contactBlockedWithUser_id:(NSNumber *)user_id date:(NSNumber *)date;

@end

@interface API17_ContactBlocked_contactBlocked : API17_ContactBlocked

@end


@interface API17_auth_CheckedPhone : NSObject

@property (nonatomic, strong, readonly) API17_Bool * phone_registered;
@property (nonatomic, strong, readonly) API17_Bool * phone_invited;

+ (API17_auth_CheckedPhone_auth_checkedPhone *)auth_checkedPhoneWithPhone_registered:(API17_Bool *)phone_registered phone_invited:(API17_Bool *)phone_invited;

@end

@interface API17_auth_CheckedPhone_auth_checkedPhone : API17_auth_CheckedPhone

@end


@interface API17_InputUser : NSObject

+ (API17_InputUser_inputUserEmpty *)inputUserEmpty;
+ (API17_InputUser_inputUserSelf *)inputUserSelf;
+ (API17_InputUser_inputUserContact *)inputUserContactWithUser_id:(NSNumber *)user_id;
+ (API17_InputUser_inputUserForeign *)inputUserForeignWithUser_id:(NSNumber *)user_id access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputUser_inputUserEmpty : API17_InputUser

@end

@interface API17_InputUser_inputUserSelf : API17_InputUser

@end

@interface API17_InputUser_inputUserContact : API17_InputUser

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_InputUser_inputUserForeign : API17_InputUser

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_SchemeType : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * predicate;
@property (nonatomic, strong, readonly) NSArray * params;
@property (nonatomic, strong, readonly) NSString * type;

+ (API17_SchemeType_schemeType *)schemeTypeWithPid:(NSNumber *)pid predicate:(NSString *)predicate params:(NSArray *)params type:(NSString *)type;

@end

@interface API17_SchemeType_schemeType : API17_SchemeType

@end


@interface API17_geochats_StatedMessage : NSObject

@property (nonatomic, strong, readonly) API17_GeoChatMessage * message;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSNumber * seq;

+ (API17_geochats_StatedMessage_geochats_statedMessage *)geochats_statedMessageWithMessage:(API17_GeoChatMessage *)message chats:(NSArray *)chats users:(NSArray *)users seq:(NSNumber *)seq;

@end

@interface API17_geochats_StatedMessage_geochats_statedMessage : API17_geochats_StatedMessage

@end


@interface API17_upload_File : NSObject

@property (nonatomic, strong, readonly) API17_storage_FileType * type;
@property (nonatomic, strong, readonly) NSNumber * mtime;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (API17_upload_File_upload_file *)upload_fileWithType:(API17_storage_FileType *)type mtime:(NSNumber *)mtime bytes:(NSData *)bytes;

@end

@interface API17_upload_File_upload_file : API17_upload_File

@end


@interface API17_InputVideo : NSObject

+ (API17_InputVideo_inputVideoEmpty *)inputVideoEmpty;
+ (API17_InputVideo_inputVideo *)inputVideoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputVideo_inputVideoEmpty : API17_InputVideo

@end

@interface API17_InputVideo_inputVideo : API17_InputVideo

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_FutureSalt : NSObject

@property (nonatomic, strong, readonly) NSNumber * valid_since;
@property (nonatomic, strong, readonly) NSNumber * valid_until;
@property (nonatomic, strong, readonly) NSNumber * salt;

+ (API17_FutureSalt_futureSalt *)futureSaltWithValid_since:(NSNumber *)valid_since valid_until:(NSNumber *)valid_until salt:(NSNumber *)salt;

@end

@interface API17_FutureSalt_futureSalt : API17_FutureSalt

@end


@interface API17_Config : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) API17_Bool * test_mode;
@property (nonatomic, strong, readonly) NSNumber * this_dc;
@property (nonatomic, strong, readonly) NSArray * dc_options;
@property (nonatomic, strong, readonly) NSNumber * chat_size_max;
@property (nonatomic, strong, readonly) NSNumber * broadcast_size_max;

+ (API17_Config_config *)configWithDate:(NSNumber *)date test_mode:(API17_Bool *)test_mode this_dc:(NSNumber *)this_dc dc_options:(NSArray *)dc_options chat_size_max:(NSNumber *)chat_size_max broadcast_size_max:(NSNumber *)broadcast_size_max;

@end

@interface API17_Config_config : API17_Config

@end


@interface API17_ProtoMessageCopy : NSObject

@property (nonatomic, strong, readonly) API17_ProtoMessage * orig_message;

+ (API17_ProtoMessageCopy_msg_copy *)msg_copyWithOrig_message:(API17_ProtoMessage *)orig_message;

@end

@interface API17_ProtoMessageCopy_msg_copy : API17_ProtoMessageCopy

@end


@interface API17_Audio : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Audio_audioEmpty *)audioEmptyWithPid:(NSNumber *)pid;
+ (API17_Audio_audio *)audioWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date duration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size dc_id:(NSNumber *)dc_id;

@end

@interface API17_Audio_audioEmpty : API17_Audio

@end

@interface API17_Audio_audio : API17_Audio

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSNumber * dc_id;

@end


@interface API17_contacts_Located : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_Located_contacts_located *)contacts_locatedWithResults:(NSArray *)results users:(NSArray *)users;

@end

@interface API17_contacts_Located_contacts_located : API17_contacts_Located

@end


@interface API17_InputAudio : NSObject

+ (API17_InputAudio_inputAudioEmpty *)inputAudioEmpty;
+ (API17_InputAudio_inputAudio *)inputAudioWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputAudio_inputAudioEmpty : API17_InputAudio

@end

@interface API17_InputAudio_inputAudio : API17_InputAudio

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_MsgsAck : NSObject

@property (nonatomic, strong, readonly) NSArray * msg_ids;

+ (API17_MsgsAck_msgs_ack *)msgs_ackWithMsg_ids:(NSArray *)msg_ids;

@end

@interface API17_MsgsAck_msgs_ack : API17_MsgsAck

@end


@interface API17_Pong : NSObject

@property (nonatomic, strong, readonly) NSNumber * msg_id;
@property (nonatomic, strong, readonly) NSNumber * ping_id;

+ (API17_Pong_pong *)pongWithMsg_id:(NSNumber *)msg_id ping_id:(NSNumber *)ping_id;

@end

@interface API17_Pong_pong : API17_Pong

@end


@interface API17_ResponseIndirect : NSObject

+ (API17_ResponseIndirect_responseIndirect *)responseIndirect;

@end

@interface API17_ResponseIndirect_responseIndirect : API17_ResponseIndirect

@end


@interface API17_MsgResendReq : NSObject

@property (nonatomic, strong, readonly) NSArray * msg_ids;

+ (API17_MsgResendReq_msg_resend_req *)msg_resend_reqWithMsg_ids:(NSArray *)msg_ids;

@end

@interface API17_MsgResendReq_msg_resend_req : API17_MsgResendReq

@end


@interface API17_messages_StatedMessages : NSObject

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * seq;

+ (API17_messages_StatedMessages_messages_statedMessagesLinks *)messages_statedMessagesLinksWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users links:(NSArray *)links pts:(NSNumber *)pts seq:(NSNumber *)seq;
+ (API17_messages_StatedMessages_messages_statedMessages *)messages_statedMessagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users pts:(NSNumber *)pts seq:(NSNumber *)seq;

@end

@interface API17_messages_StatedMessages_messages_statedMessagesLinks : API17_messages_StatedMessages

@property (nonatomic, strong, readonly) NSArray * links;

@end

@interface API17_messages_StatedMessages_messages_statedMessages : API17_messages_StatedMessages

@end


@interface API17_WallPaper : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSNumber * color;

+ (API17_WallPaper_wallPaperSolid *)wallPaperSolidWithPid:(NSNumber *)pid title:(NSString *)title bg_color:(NSNumber *)bg_color color:(NSNumber *)color;
+ (API17_WallPaper_wallPaper *)wallPaperWithPid:(NSNumber *)pid title:(NSString *)title sizes:(NSArray *)sizes color:(NSNumber *)color;

@end

@interface API17_WallPaper_wallPaperSolid : API17_WallPaper

@property (nonatomic, strong, readonly) NSNumber * bg_color;

@end

@interface API17_WallPaper_wallPaper : API17_WallPaper

@property (nonatomic, strong, readonly) NSArray * sizes;

@end


@interface API17_DestroySessionsRes : NSObject

@property (nonatomic, strong, readonly) NSArray * destroy_results;

+ (API17_DestroySessionsRes_destroy_sessions_res *)destroy_sessions_resWithDestroy_results:(NSArray *)destroy_results;

@end

@interface API17_DestroySessionsRes_destroy_sessions_res : API17_DestroySessionsRes

@end


@interface API17_messages_Messages : NSObject

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_messages_Messages_messages_messages *)messages_messagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (API17_messages_Messages_messages_messagesSlice *)messages_messagesSliceWithCount:(NSNumber *)count messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_messages_Messages_messages_messages : API17_messages_Messages

@end

@interface API17_messages_Messages_messages_messagesSlice : API17_messages_Messages

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_geochats_Located : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_geochats_Located_geochats_located *)geochats_locatedWithResults:(NSArray *)results messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_geochats_Located_geochats_located : API17_geochats_Located

@end


@interface API17_auth_SentCode : NSObject

@property (nonatomic, strong, readonly) API17_Bool * phone_registered;

+ (API17_auth_SentCode_auth_sentCodePreview *)auth_sentCodePreviewWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash phone_code_test:(NSString *)phone_code_test;
+ (API17_auth_SentCode_auth_sentPassPhrase *)auth_sentPassPhraseWithPhone_registered:(API17_Bool *)phone_registered;
+ (API17_auth_SentCode_auth_sentCode *)auth_sentCodeWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(NSNumber *)send_call_timeout is_password:(API17_Bool *)is_password;
+ (API17_auth_SentCode_auth_sentAppCode *)auth_sentAppCodeWithPhone_registered:(API17_Bool *)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(NSNumber *)send_call_timeout is_password:(API17_Bool *)is_password;

@end

@interface API17_auth_SentCode_auth_sentCodePreview : API17_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phone_code_hash;
@property (nonatomic, strong, readonly) NSString * phone_code_test;

@end

@interface API17_auth_SentCode_auth_sentPassPhrase : API17_auth_SentCode

@end

@interface API17_auth_SentCode_auth_sentCode : API17_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phone_code_hash;
@property (nonatomic, strong, readonly) NSNumber * send_call_timeout;
@property (nonatomic, strong, readonly) API17_Bool * is_password;

@end

@interface API17_auth_SentCode_auth_sentAppCode : API17_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phone_code_hash;
@property (nonatomic, strong, readonly) NSNumber * send_call_timeout;
@property (nonatomic, strong, readonly) API17_Bool * is_password;

@end


@interface API17_phone_DhConfig : NSObject

@property (nonatomic, strong, readonly) NSNumber * g;
@property (nonatomic, strong, readonly) NSString * p;
@property (nonatomic, strong, readonly) NSNumber * ring_timeout;
@property (nonatomic, strong, readonly) NSNumber * expires;

+ (API17_phone_DhConfig_phone_dhConfig *)phone_dhConfigWithG:(NSNumber *)g p:(NSString *)p ring_timeout:(NSNumber *)ring_timeout expires:(NSNumber *)expires;

@end

@interface API17_phone_DhConfig_phone_dhConfig : API17_phone_DhConfig

@end


@interface API17_InputChatPhoto : NSObject

+ (API17_InputChatPhoto_inputChatPhotoEmpty *)inputChatPhotoEmpty;
+ (API17_InputChatPhoto_inputChatUploadedPhoto *)inputChatUploadedPhotoWithFile:(API17_InputFile *)file crop:(API17_InputPhotoCrop *)crop;
+ (API17_InputChatPhoto_inputChatPhoto *)inputChatPhotoWithPid:(API17_InputPhoto *)pid crop:(API17_InputPhotoCrop *)crop;

@end

@interface API17_InputChatPhoto_inputChatPhotoEmpty : API17_InputChatPhoto

@end

@interface API17_InputChatPhoto_inputChatUploadedPhoto : API17_InputChatPhoto

@property (nonatomic, strong, readonly) API17_InputFile * file;
@property (nonatomic, strong, readonly) API17_InputPhotoCrop * crop;

@end

@interface API17_InputChatPhoto_inputChatPhoto : API17_InputChatPhoto

@property (nonatomic, strong, readonly) API17_InputPhoto * pid;
@property (nonatomic, strong, readonly) API17_InputPhotoCrop * crop;

@end


@interface API17_Updates : NSObject

+ (API17_Updates_updatesTooLong *)updatesTooLong;
+ (API17_Updates_updateShortMessage *)updateShortMessageWithPid:(NSNumber *)pid from_id:(NSNumber *)from_id message:(NSString *)message pts:(NSNumber *)pts date:(NSNumber *)date seq:(NSNumber *)seq;
+ (API17_Updates_updateShortChatMessage *)updateShortChatMessageWithPid:(NSNumber *)pid from_id:(NSNumber *)from_id chat_id:(NSNumber *)chat_id message:(NSString *)message pts:(NSNumber *)pts date:(NSNumber *)date seq:(NSNumber *)seq;
+ (API17_Updates_updateShort *)updateShortWithUpdate:(API17_Update *)update date:(NSNumber *)date;
+ (API17_Updates_updatesCombined *)updatesCombinedWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seq_start:(NSNumber *)seq_start seq:(NSNumber *)seq;
+ (API17_Updates_updates *)updatesWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seq:(NSNumber *)seq;

@end

@interface API17_Updates_updatesTooLong : API17_Updates

@end

@interface API17_Updates_updateShortMessage : API17_Updates

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface API17_Updates_updateShortChatMessage : API17_Updates

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface API17_Updates_updateShort : API17_Updates

@property (nonatomic, strong, readonly) API17_Update * update;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface API17_Updates_updatesCombined : API17_Updates

@property (nonatomic, strong, readonly) NSArray * updates;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq_start;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface API17_Updates_updates : API17_Updates

@property (nonatomic, strong, readonly) NSArray * updates;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end


@interface API17_InitConnection : NSObject

@property (nonatomic, strong, readonly) NSNumber * api_id;
@property (nonatomic, strong, readonly) NSString * device_model;
@property (nonatomic, strong, readonly) NSString * system_version;
@property (nonatomic, strong, readonly) NSString * app_version;
@property (nonatomic, strong, readonly) NSString * lang_code;
@property (nonatomic, strong, readonly) NSObject * query;

+ (API17_InitConnection_pinitConnection *)pinitConnectionWithApi_id:(NSNumber *)api_id device_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version lang_code:(NSString *)lang_code query:(NSObject *)query;

@end

@interface API17_InitConnection_pinitConnection : API17_InitConnection

@end


@interface API17_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSData * random_bytes;

+ (API17_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(API17_DecryptedMessageMedia *)media;
+ (API17_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(API17_DecryptedMessageAction *)action;

@end

@interface API17_DecryptedMessage_decryptedMessage : API17_DecryptedMessage

@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) API17_DecryptedMessageMedia * media;

@end

@interface API17_DecryptedMessage_decryptedMessageService : API17_DecryptedMessage

@property (nonatomic, strong, readonly) API17_DecryptedMessageAction * action;

@end


@interface API17_MessageMedia : NSObject

+ (API17_MessageMedia_messageMediaEmpty *)messageMediaEmpty;
+ (API17_MessageMedia_messageMediaPhoto *)messageMediaPhotoWithPhoto:(API17_Photo *)photo;
+ (API17_MessageMedia_messageMediaVideo *)messageMediaVideoWithVideo:(API17_Video *)video;
+ (API17_MessageMedia_messageMediaGeo *)messageMediaGeoWithGeo:(API17_GeoPoint *)geo;
+ (API17_MessageMedia_messageMediaContact *)messageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (API17_MessageMedia_messageMediaUnsupported *)messageMediaUnsupportedWithBytes:(NSData *)bytes;
+ (API17_MessageMedia_messageMediaDocument *)messageMediaDocumentWithDocument:(API17_Document *)document;
+ (API17_MessageMedia_messageMediaAudio *)messageMediaAudioWithAudio:(API17_Audio *)audio;

@end

@interface API17_MessageMedia_messageMediaEmpty : API17_MessageMedia

@end

@interface API17_MessageMedia_messageMediaPhoto : API17_MessageMedia

@property (nonatomic, strong, readonly) API17_Photo * photo;

@end

@interface API17_MessageMedia_messageMediaVideo : API17_MessageMedia

@property (nonatomic, strong, readonly) API17_Video * video;

@end

@interface API17_MessageMedia_messageMediaGeo : API17_MessageMedia

@property (nonatomic, strong, readonly) API17_GeoPoint * geo;

@end

@interface API17_MessageMedia_messageMediaContact : API17_MessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_MessageMedia_messageMediaUnsupported : API17_MessageMedia

@property (nonatomic, strong, readonly) NSData * bytes;

@end

@interface API17_MessageMedia_messageMediaDocument : API17_MessageMedia

@property (nonatomic, strong, readonly) API17_Document * document;

@end

@interface API17_MessageMedia_messageMediaAudio : API17_MessageMedia

@property (nonatomic, strong, readonly) API17_Audio * audio;

@end


@interface API17_Null : NSObject

+ (API17_Null_null *)null;

@end

@interface API17_Null_null : API17_Null

@end


@interface API17_ChatPhoto : NSObject

+ (API17_ChatPhoto_chatPhotoEmpty *)chatPhotoEmpty;
+ (API17_ChatPhoto_chatPhoto *)chatPhotoWithPhoto_small:(API17_FileLocation *)photo_small photo_big:(API17_FileLocation *)photo_big;

@end

@interface API17_ChatPhoto_chatPhotoEmpty : API17_ChatPhoto

@end

@interface API17_ChatPhoto_chatPhoto : API17_ChatPhoto

@property (nonatomic, strong, readonly) API17_FileLocation * photo_small;
@property (nonatomic, strong, readonly) API17_FileLocation * photo_big;

@end


@interface API17_InvokeAfterMsg : NSObject

@property (nonatomic, strong, readonly) NSNumber * msg_id;
@property (nonatomic, strong, readonly) NSObject * query;

+ (API17_InvokeAfterMsg_invokeAfterMsg *)invokeAfterMsgWithMsg_id:(NSNumber *)msg_id query:(NSObject *)query;

@end

@interface API17_InvokeAfterMsg_invokeAfterMsg : API17_InvokeAfterMsg

@end


@interface API17_contacts_Suggested : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_Suggested_contacts_suggested *)contacts_suggestedWithResults:(NSArray *)results users:(NSArray *)users;

@end

@interface API17_contacts_Suggested_contacts_suggested : API17_contacts_Suggested

@end


@interface API17_updates_State : NSObject

@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * qts;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;
@property (nonatomic, strong, readonly) NSNumber * unread_count;

+ (API17_updates_State_updates_state *)updates_stateWithPts:(NSNumber *)pts qts:(NSNumber *)qts date:(NSNumber *)date seq:(NSNumber *)seq unread_count:(NSNumber *)unread_count;

@end

@interface API17_updates_State_updates_state : API17_updates_State

@end


@interface API17_User : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_User_userEmpty *)userEmptyWithPid:(NSNumber *)pid;
+ (API17_User_userSelf *)userSelfWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status inactive:(API17_Bool *)inactive;
+ (API17_User_userContact *)userContactWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status;
+ (API17_User_userRequest *)userRequestWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash phone:(NSString *)phone photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status;
+ (API17_User_userForeign *)userForeignWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name access_hash:(NSNumber *)access_hash photo:(API17_UserProfilePhoto *)photo status:(API17_UserStatus *)status;
+ (API17_User_userDeleted *)userDeletedWithPid:(NSNumber *)pid first_name:(NSString *)first_name last_name:(NSString *)last_name;

@end

@interface API17_User_userEmpty : API17_User

@end

@interface API17_User_userSelf : API17_User

@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) API17_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) API17_UserStatus * status;
@property (nonatomic, strong, readonly) API17_Bool * inactive;

@end

@interface API17_User_userContact : API17_User

@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) API17_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) API17_UserStatus * status;

@end

@interface API17_User_userRequest : API17_User

@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) API17_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) API17_UserStatus * status;

@end

@interface API17_User_userForeign : API17_User

@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) API17_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) API17_UserStatus * status;

@end

@interface API17_User_userDeleted : API17_User

@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;

@end


@interface API17_Message : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Message_messageEmpty *)messageEmptyWithPid:(NSNumber *)pid;
+ (API17_Message_message *)messageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media;
+ (API17_Message_messageForwarded *)messageForwardedWithFlags:(NSNumber *)flags pid:(NSNumber *)pid fwd_from_id:(NSNumber *)fwd_from_id fwd_date:(NSNumber *)fwd_date from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date message:(NSString *)message media:(API17_MessageMedia *)media;
+ (API17_Message_messageService *)messageServiceWithFlags:(NSNumber *)flags pid:(NSNumber *)pid from_id:(NSNumber *)from_id to_id:(API17_Peer *)to_id date:(NSNumber *)date action:(API17_MessageAction *)action;

@end

@interface API17_Message_messageEmpty : API17_Message

@end

@interface API17_Message_message : API17_Message

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) API17_Peer * to_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) API17_MessageMedia * media;

@end

@interface API17_Message_messageForwarded : API17_Message

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * fwd_from_id;
@property (nonatomic, strong, readonly) NSNumber * fwd_date;
@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) API17_Peer * to_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) API17_MessageMedia * media;

@end

@interface API17_Message_messageService : API17_Message

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * from_id;
@property (nonatomic, strong, readonly) API17_Peer * to_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) API17_MessageAction * action;

@end


@interface API17_InputFileLocation : NSObject

+ (API17_InputFileLocation_inputFileLocation *)inputFileLocationWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret;
+ (API17_InputFileLocation_inputVideoFileLocation *)inputVideoFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;
+ (API17_InputFileLocation_inputEncryptedFileLocation *)inputEncryptedFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;
+ (API17_InputFileLocation_inputAudioFileLocation *)inputAudioFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;
+ (API17_InputFileLocation_inputDocumentFileLocation *)inputDocumentFileLocationWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputFileLocation_inputFileLocation : API17_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * volume_id;
@property (nonatomic, strong, readonly) NSNumber * local_id;
@property (nonatomic, strong, readonly) NSNumber * secret;

@end

@interface API17_InputFileLocation_inputVideoFileLocation : API17_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputEncryptedFileLocation : API17_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputAudioFileLocation : API17_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end

@interface API17_InputFileLocation_inputDocumentFileLocation : API17_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_GeoPoint : NSObject

+ (API17_GeoPoint_geoPointEmpty *)geoPointEmpty;
+ (API17_GeoPoint_geoPoint *)geoPointWithPlong:(NSNumber *)plong lat:(NSNumber *)lat;
+ (API17_GeoPoint_geoPlace *)geoPlaceWithPlong:(NSNumber *)plong lat:(NSNumber *)lat name:(API17_GeoPlaceName *)name;

@end

@interface API17_GeoPoint_geoPointEmpty : API17_GeoPoint

@end

@interface API17_GeoPoint_geoPoint : API17_GeoPoint

@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSNumber * lat;

@end

@interface API17_GeoPoint_geoPlace : API17_GeoPoint

@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) API17_GeoPlaceName * name;

@end


@interface API17_InputPhoneCall : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

+ (API17_InputPhoneCall_inputPhoneCall *)inputPhoneCallWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputPhoneCall_inputPhoneCall : API17_InputPhoneCall

@end


@interface API17_ChatParticipants : NSObject

@property (nonatomic, strong, readonly) NSNumber * chat_id;

+ (API17_ChatParticipants_chatParticipantsForbidden *)chatParticipantsForbiddenWithChat_id:(NSNumber *)chat_id;
+ (API17_ChatParticipants_chatParticipants *)chatParticipantsWithChat_id:(NSNumber *)chat_id admin_id:(NSNumber *)admin_id participants:(NSArray *)participants version:(NSNumber *)version;

@end

@interface API17_ChatParticipants_chatParticipantsForbidden : API17_ChatParticipants

@end

@interface API17_ChatParticipants_chatParticipants : API17_ChatParticipants

@property (nonatomic, strong, readonly) NSNumber * admin_id;
@property (nonatomic, strong, readonly) NSArray * participants;
@property (nonatomic, strong, readonly) NSNumber * version;

@end


@interface API17_RpcError : NSObject

@property (nonatomic, strong, readonly) NSNumber * error_code;
@property (nonatomic, strong, readonly) NSString * error_message;

+ (API17_RpcError_rpc_error *)rpc_errorWithError_code:(NSNumber *)error_code error_message:(NSString *)error_message;
+ (API17_RpcError_rpc_req_error *)rpc_req_errorWithQuery_id:(NSNumber *)query_id error_code:(NSNumber *)error_code error_message:(NSString *)error_message;

@end

@interface API17_RpcError_rpc_error : API17_RpcError

@end

@interface API17_RpcError_rpc_req_error : API17_RpcError

@property (nonatomic, strong, readonly) NSNumber * query_id;

@end


@interface API17_NearestDc : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSNumber * this_dc;
@property (nonatomic, strong, readonly) NSNumber * nearest_dc;

+ (API17_NearestDc_nearestDc *)nearestDcWithCountry:(NSString *)country this_dc:(NSNumber *)this_dc nearest_dc:(NSNumber *)nearest_dc;

@end

@interface API17_NearestDc_nearestDc : API17_NearestDc

@end


@interface API17_Set_client_DH_params_answer : NSObject

@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;

+ (API17_Set_client_DH_params_answer_dh_gen_ok *)dh_gen_okWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash1:(NSData *)pnew_nonce_hash1;
+ (API17_Set_client_DH_params_answer_dh_gen_retry *)dh_gen_retryWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash2:(NSData *)pnew_nonce_hash2;
+ (API17_Set_client_DH_params_answer_dh_gen_fail *)dh_gen_failWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pnew_nonce_hash3:(NSData *)pnew_nonce_hash3;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_ok : API17_Set_client_DH_params_answer

@property (nonatomic, strong, readonly) NSData * pnew_nonce_hash1;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_retry : API17_Set_client_DH_params_answer

@property (nonatomic, strong, readonly) NSData * pnew_nonce_hash2;

@end

@interface API17_Set_client_DH_params_answer_dh_gen_fail : API17_Set_client_DH_params_answer

@property (nonatomic, strong, readonly) NSData * pnew_nonce_hash3;

@end


@interface API17_photos_Photos : NSObject

@property (nonatomic, strong, readonly) NSArray * photos;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_photos_Photos_photos_photos *)photos_photosWithPhotos:(NSArray *)photos users:(NSArray *)users;
+ (API17_photos_Photos_photos_photosSlice *)photos_photosSliceWithCount:(NSNumber *)count photos:(NSArray *)photos users:(NSArray *)users;

@end

@interface API17_photos_Photos_photos_photos : API17_photos_Photos

@end

@interface API17_photos_Photos_photos_photosSlice : API17_photos_Photos

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_contacts_ImportedContacts : NSObject

@property (nonatomic, strong, readonly) NSArray * imported;
@property (nonatomic, strong, readonly) NSArray * retry_contacts;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_ImportedContacts_contacts_importedContacts *)contacts_importedContactsWithImported:(NSArray *)imported retry_contacts:(NSArray *)retry_contacts users:(NSArray *)users;

@end

@interface API17_contacts_ImportedContacts_contacts_importedContacts : API17_contacts_ImportedContacts

@end


@interface API17_MsgDetailedInfo : NSObject

@property (nonatomic, strong, readonly) NSNumber * answer_msg_id;
@property (nonatomic, strong, readonly) NSNumber * bytes;
@property (nonatomic, strong, readonly) NSNumber * status;

+ (API17_MsgDetailedInfo_msg_detailed_info *)msg_detailed_infoWithMsg_id:(NSNumber *)msg_id answer_msg_id:(NSNumber *)answer_msg_id bytes:(NSNumber *)bytes status:(NSNumber *)status;
+ (API17_MsgDetailedInfo_msg_new_detailed_info *)msg_new_detailed_infoWithAnswer_msg_id:(NSNumber *)answer_msg_id bytes:(NSNumber *)bytes status:(NSNumber *)status;

@end

@interface API17_MsgDetailedInfo_msg_detailed_info : API17_MsgDetailedInfo

@property (nonatomic, strong, readonly) NSNumber * msg_id;

@end

@interface API17_MsgDetailedInfo_msg_new_detailed_info : API17_MsgDetailedInfo

@end


@interface API17_Bool : NSObject

+ (API17_Bool_boolFalse *)boolFalse;
+ (API17_Bool_boolTrue *)boolTrue;

@end

@interface API17_Bool_boolFalse : API17_Bool

@end

@interface API17_Bool_boolTrue : API17_Bool

@end


@interface API17_help_Support : NSObject

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) API17_User * user;

+ (API17_help_Support_help_support *)help_supportWithPhone_number:(NSString *)phone_number user:(API17_User *)user;

@end

@interface API17_help_Support_help_support : API17_help_Support

@end


@interface API17_ChatLocated : NSObject

@property (nonatomic, strong, readonly) NSNumber * chat_id;
@property (nonatomic, strong, readonly) NSNumber * distance;

+ (API17_ChatLocated_chatLocated *)chatLocatedWithChat_id:(NSNumber *)chat_id distance:(NSNumber *)distance;

@end

@interface API17_ChatLocated_chatLocated : API17_ChatLocated

@end


@interface API17_MessagesFilter : NSObject

+ (API17_MessagesFilter_inputMessagesFilterEmpty *)inputMessagesFilterEmpty;
+ (API17_MessagesFilter_inputMessagesFilterPhotos *)inputMessagesFilterPhotos;
+ (API17_MessagesFilter_inputMessagesFilterVideo *)inputMessagesFilterVideo;
+ (API17_MessagesFilter_inputMessagesFilterPhotoVideo *)inputMessagesFilterPhotoVideo;

@end

@interface API17_MessagesFilter_inputMessagesFilterEmpty : API17_MessagesFilter

@end

@interface API17_MessagesFilter_inputMessagesFilterPhotos : API17_MessagesFilter

@end

@interface API17_MessagesFilter_inputMessagesFilterVideo : API17_MessagesFilter

@end

@interface API17_MessagesFilter_inputMessagesFilterPhotoVideo : API17_MessagesFilter

@end


@interface API17_messages_Dialogs : NSObject

@property (nonatomic, strong, readonly) NSArray * dialogs;
@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_messages_Dialogs_messages_dialogs *)messages_dialogsWithDialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (API17_messages_Dialogs_messages_dialogsSlice *)messages_dialogsSliceWithCount:(NSNumber *)count dialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_messages_Dialogs_messages_dialogs : API17_messages_Dialogs

@end

@interface API17_messages_Dialogs_messages_dialogsSlice : API17_messages_Dialogs

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface API17_help_InviteText : NSObject

@property (nonatomic, strong, readonly) NSString * message;

+ (API17_help_InviteText_help_inviteText *)help_inviteTextWithMessage:(NSString *)message;

@end

@interface API17_help_InviteText_help_inviteText : API17_help_InviteText

@end


@interface API17_ContactSuggested : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * mutual_contacts;

+ (API17_ContactSuggested_contactSuggested *)contactSuggestedWithUser_id:(NSNumber *)user_id mutual_contacts:(NSNumber *)mutual_contacts;

@end

@interface API17_ContactSuggested_contactSuggested : API17_ContactSuggested

@end


@interface API17_InputPeerNotifySettings : NSObject

@property (nonatomic, strong, readonly) NSNumber * mute_until;
@property (nonatomic, strong, readonly) NSString * sound;
@property (nonatomic, strong, readonly) API17_Bool * show_previews;
@property (nonatomic, strong, readonly) API17_InputPeerNotifyEvents * events;

+ (API17_InputPeerNotifySettings_inputPeerNotifySettings *)inputPeerNotifySettingsWithMute_until:(NSNumber *)mute_until sound:(NSString *)sound show_previews:(API17_Bool *)show_previews events:(API17_InputPeerNotifyEvents *)events;

@end

@interface API17_InputPeerNotifySettings_inputPeerNotifySettings : API17_InputPeerNotifySettings

@end


@interface API17_DcNetworkStats : NSObject

@property (nonatomic, strong, readonly) NSNumber * dc_id;
@property (nonatomic, strong, readonly) NSString * ip_address;
@property (nonatomic, strong, readonly) NSArray * pings;

+ (API17_DcNetworkStats_dcPingStats *)dcPingStatsWithDc_id:(NSNumber *)dc_id ip_address:(NSString *)ip_address pings:(NSArray *)pings;

@end

@interface API17_DcNetworkStats_dcPingStats : API17_DcNetworkStats

@end


@interface API17_HttpWait : NSObject

@property (nonatomic, strong, readonly) NSNumber * max_delay;
@property (nonatomic, strong, readonly) NSNumber * wait_after;
@property (nonatomic, strong, readonly) NSNumber * max_wait;

+ (API17_HttpWait_http_wait *)http_waitWithMax_delay:(NSNumber *)max_delay wait_after:(NSNumber *)wait_after max_wait:(NSNumber *)max_wait;

@end

@interface API17_HttpWait_http_wait : API17_HttpWait

@end


@interface API17_PhoneConnection : NSObject

+ (API17_PhoneConnection_phoneConnectionNotReady *)phoneConnectionNotReady;
+ (API17_PhoneConnection_phoneConnection *)phoneConnectionWithServer:(NSString *)server port:(NSNumber *)port stream_id:(NSNumber *)stream_id;

@end

@interface API17_PhoneConnection_phoneConnectionNotReady : API17_PhoneConnection

@end

@interface API17_PhoneConnection_phoneConnection : API17_PhoneConnection

@property (nonatomic, strong, readonly) NSString * server;
@property (nonatomic, strong, readonly) NSNumber * port;
@property (nonatomic, strong, readonly) NSNumber * stream_id;

@end


@interface API17_messages_StatedMessage : NSObject

@property (nonatomic, strong, readonly) API17_Message * message;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * seq;

+ (API17_messages_StatedMessage_messages_statedMessageLink *)messages_statedMessageLinkWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users links:(NSArray *)links pts:(NSNumber *)pts seq:(NSNumber *)seq;
+ (API17_messages_StatedMessage_messages_statedMessage *)messages_statedMessageWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users pts:(NSNumber *)pts seq:(NSNumber *)seq;

@end

@interface API17_messages_StatedMessage_messages_statedMessageLink : API17_messages_StatedMessage

@property (nonatomic, strong, readonly) NSArray * links;

@end

@interface API17_messages_StatedMessage_messages_statedMessage : API17_messages_StatedMessage

@end


@interface API17_Scheme : NSObject

+ (API17_Scheme_scheme *)schemeWithScheme_raw:(NSString *)scheme_raw types:(NSArray *)types methods:(NSArray *)methods version:(NSNumber *)version;
+ (API17_Scheme_schemeNotModified *)schemeNotModified;

@end

@interface API17_Scheme_scheme : API17_Scheme

@property (nonatomic, strong, readonly) NSString * scheme_raw;
@property (nonatomic, strong, readonly) NSArray * types;
@property (nonatomic, strong, readonly) NSArray * methods;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface API17_Scheme_schemeNotModified : API17_Scheme

@end


@interface API17_RpcDropAnswer : NSObject

+ (API17_RpcDropAnswer_rpc_answer_unknown *)rpc_answer_unknown;
+ (API17_RpcDropAnswer_rpc_answer_dropped_running *)rpc_answer_dropped_running;
+ (API17_RpcDropAnswer_rpc_answer_dropped *)rpc_answer_droppedWithMsg_id:(NSNumber *)msg_id seq_no:(NSNumber *)seq_no bytes:(NSNumber *)bytes;

@end

@interface API17_RpcDropAnswer_rpc_answer_unknown : API17_RpcDropAnswer

@end

@interface API17_RpcDropAnswer_rpc_answer_dropped_running : API17_RpcDropAnswer

@end

@interface API17_RpcDropAnswer_rpc_answer_dropped : API17_RpcDropAnswer

@property (nonatomic, strong, readonly) NSNumber * msg_id;
@property (nonatomic, strong, readonly) NSNumber * seq_no;
@property (nonatomic, strong, readonly) NSNumber * bytes;

@end


@interface API17_messages_Message : NSObject

+ (API17_messages_Message_messages_messageEmpty *)messages_messageEmpty;
+ (API17_messages_Message_messages_message *)messages_messageWithMessage:(API17_Message *)message chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface API17_messages_Message_messages_messageEmpty : API17_messages_Message

@end

@interface API17_messages_Message_messages_message : API17_messages_Message

@property (nonatomic, strong, readonly) API17_Message * message;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

@end


@interface API17_MessageAction : NSObject

+ (API17_MessageAction_messageActionGeoChatCreate *)messageActionGeoChatCreateWithTitle:(NSString *)title address:(NSString *)address;
+ (API17_MessageAction_messageActionGeoChatCheckin *)messageActionGeoChatCheckin;
+ (API17_MessageAction_messageActionEmpty *)messageActionEmpty;
+ (API17_MessageAction_messageActionChatCreate *)messageActionChatCreateWithTitle:(NSString *)title users:(NSArray *)users;
+ (API17_MessageAction_messageActionChatEditTitle *)messageActionChatEditTitleWithTitle:(NSString *)title;
+ (API17_MessageAction_messageActionChatEditPhoto *)messageActionChatEditPhotoWithPhoto:(API17_Photo *)photo;
+ (API17_MessageAction_messageActionChatDeletePhoto *)messageActionChatDeletePhoto;
+ (API17_MessageAction_messageActionChatAddUser *)messageActionChatAddUserWithUser_id:(NSNumber *)user_id;
+ (API17_MessageAction_messageActionChatDeleteUser *)messageActionChatDeleteUserWithUser_id:(NSNumber *)user_id;
+ (API17_MessageAction_messageActionSentRequest *)messageActionSentRequestWithHas_phone:(API17_Bool *)has_phone;
+ (API17_MessageAction_messageActionAcceptRequest *)messageActionAcceptRequest;

@end

@interface API17_MessageAction_messageActionGeoChatCreate : API17_MessageAction

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;

@end

@interface API17_MessageAction_messageActionGeoChatCheckin : API17_MessageAction

@end

@interface API17_MessageAction_messageActionEmpty : API17_MessageAction

@end

@interface API17_MessageAction_messageActionChatCreate : API17_MessageAction

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface API17_MessageAction_messageActionChatEditTitle : API17_MessageAction

@property (nonatomic, strong, readonly) NSString * title;

@end

@interface API17_MessageAction_messageActionChatEditPhoto : API17_MessageAction

@property (nonatomic, strong, readonly) API17_Photo * photo;

@end

@interface API17_MessageAction_messageActionChatDeletePhoto : API17_MessageAction

@end

@interface API17_MessageAction_messageActionChatAddUser : API17_MessageAction

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_MessageAction_messageActionChatDeleteUser : API17_MessageAction

@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_MessageAction_messageActionSentRequest : API17_MessageAction

@property (nonatomic, strong, readonly) API17_Bool * has_phone;

@end

@interface API17_MessageAction_messageActionAcceptRequest : API17_MessageAction

@end


@interface API17_PhoneCall : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_PhoneCall_phoneCallEmpty *)phoneCallEmptyWithPid:(NSNumber *)pid;
+ (API17_PhoneCall_phoneCall *)phoneCallWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date user_id:(NSNumber *)user_id callee_id:(NSNumber *)callee_id;

@end

@interface API17_PhoneCall_phoneCallEmpty : API17_PhoneCall

@end

@interface API17_PhoneCall_phoneCall : API17_PhoneCall

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * callee_id;

@end


@interface API17_PeerNotifyEvents : NSObject

+ (API17_PeerNotifyEvents_peerNotifyEventsEmpty *)peerNotifyEventsEmpty;
+ (API17_PeerNotifyEvents_peerNotifyEventsAll *)peerNotifyEventsAll;

@end

@interface API17_PeerNotifyEvents_peerNotifyEventsEmpty : API17_PeerNotifyEvents

@end

@interface API17_PeerNotifyEvents_peerNotifyEventsAll : API17_PeerNotifyEvents

@end


@interface API17_NewSession : NSObject

@property (nonatomic, strong, readonly) NSNumber * first_msg_id;
@property (nonatomic, strong, readonly) NSNumber * unique_id;
@property (nonatomic, strong, readonly) NSNumber * server_salt;

+ (API17_NewSession_pnew_session_created *)pnew_session_createdWithFirst_msg_id:(NSNumber *)first_msg_id unique_id:(NSNumber *)unique_id server_salt:(NSNumber *)server_salt;

@end

@interface API17_NewSession_pnew_session_created : API17_NewSession

@end


@interface API17_help_AppPrefs : NSObject

@property (nonatomic, strong, readonly) NSData * bytes;

+ (API17_help_AppPrefs_help_appPrefs *)help_appPrefsWithBytes:(NSData *)bytes;

@end

@interface API17_help_AppPrefs_help_appPrefs : API17_help_AppPrefs

@end


@interface API17_contacts_Found : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * users;

+ (API17_contacts_Found_contacts_found *)contacts_foundWithResults:(NSArray *)results users:(NSArray *)users;

@end

@interface API17_contacts_Found_contacts_found : API17_contacts_Found

@end


@interface API17_PeerNotifySettings : NSObject

+ (API17_PeerNotifySettings_peerNotifySettingsEmpty *)peerNotifySettingsEmpty;
+ (API17_PeerNotifySettings_peerNotifySettings *)peerNotifySettingsWithMute_until:(NSNumber *)mute_until sound:(NSString *)sound show_previews:(API17_Bool *)show_previews events:(API17_PeerNotifyEvents *)events;

@end

@interface API17_PeerNotifySettings_peerNotifySettingsEmpty : API17_PeerNotifySettings

@end

@interface API17_PeerNotifySettings_peerNotifySettings : API17_PeerNotifySettings

@property (nonatomic, strong, readonly) NSNumber * mute_until;
@property (nonatomic, strong, readonly) NSString * sound;
@property (nonatomic, strong, readonly) API17_Bool * show_previews;
@property (nonatomic, strong, readonly) API17_PeerNotifyEvents * events;

@end


@interface API17_SchemeParam : NSObject

@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSString * type;

+ (API17_SchemeParam_schemeParam *)schemeParamWithName:(NSString *)name type:(NSString *)type;

@end

@interface API17_SchemeParam_schemeParam : API17_SchemeParam

@end


@interface API17_UserProfilePhoto : NSObject

+ (API17_UserProfilePhoto_userProfilePhotoEmpty *)userProfilePhotoEmpty;
+ (API17_UserProfilePhoto_userProfilePhoto *)userProfilePhotoWithPhoto_small:(API17_FileLocation *)photo_small photo_big:(API17_FileLocation *)photo_big;

@end

@interface API17_UserProfilePhoto_userProfilePhotoEmpty : API17_UserProfilePhoto

@end

@interface API17_UserProfilePhoto_userProfilePhoto : API17_UserProfilePhoto

@property (nonatomic, strong, readonly) API17_FileLocation * photo_small;
@property (nonatomic, strong, readonly) API17_FileLocation * photo_big;

@end


@interface API17_Server_DH_inner_data : NSObject

@property (nonatomic, strong, readonly) NSData * nonce;
@property (nonatomic, strong, readonly) NSData * server_nonce;
@property (nonatomic, strong, readonly) NSNumber * g;
@property (nonatomic, strong, readonly) NSData * dh_prime;
@property (nonatomic, strong, readonly) NSData * g_a;
@property (nonatomic, strong, readonly) NSNumber * server_time;

+ (API17_Server_DH_inner_data_server_DH_inner_data *)server_DH_inner_dataWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce g:(NSNumber *)g dh_prime:(NSData *)dh_prime g_a:(NSData *)g_a server_time:(NSNumber *)server_time;

@end

@interface API17_Server_DH_inner_data_server_DH_inner_data : API17_Server_DH_inner_data

@end


@interface API17_InputPhoto : NSObject

+ (API17_InputPhoto_inputPhotoEmpty *)inputPhotoEmpty;
+ (API17_InputPhoto_inputPhoto *)inputPhotoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash;

@end

@interface API17_InputPhoto_inputPhotoEmpty : API17_InputPhoto

@end

@interface API17_InputPhoto_inputPhoto : API17_InputPhoto

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;

@end


@interface API17_DecryptedMessageMedia : NSObject

+ (API17_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (API17_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaEmpty : API17_DecryptedMessageMedia

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaPhoto : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaVideo : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaContact : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaDocument : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface API17_DecryptedMessageMedia_decryptedMessageMediaAudio : API17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


@interface API17_Video : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Video_videoEmpty *)videoEmptyWithPid:(NSNumber *)pid;
+ (API17_Video_video *)videoWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date caption:(NSString *)caption duration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(API17_PhotoSize *)thumb dc_id:(NSNumber *)dc_id w:(NSNumber *)w h:(NSNumber *)h;

@end

@interface API17_Video_videoEmpty : API17_Video

@end

@interface API17_Video_video : API17_Video

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * caption;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) API17_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dc_id;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end


@interface API17_EncryptedChat : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_EncryptedChat_encryptedChatEmpty *)encryptedChatEmptyWithPid:(NSNumber *)pid;
+ (API17_EncryptedChat_encryptedChatWaiting *)encryptedChatWaitingWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id;
+ (API17_EncryptedChat_encryptedChatDiscarded *)encryptedChatDiscardedWithPid:(NSNumber *)pid;
+ (API17_EncryptedChat_encryptedChatRequested *)encryptedChatRequestedWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id g_a:(NSData *)g_a;
+ (API17_EncryptedChat_encryptedChat *)encryptedChatWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date admin_id:(NSNumber *)admin_id participant_id:(NSNumber *)participant_id g_a_or_b:(NSData *)g_a_or_b key_fingerprint:(NSNumber *)key_fingerprint;

@end

@interface API17_EncryptedChat_encryptedChatEmpty : API17_EncryptedChat

@end

@interface API17_EncryptedChat_encryptedChatWaiting : API17_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * admin_id;
@property (nonatomic, strong, readonly) NSNumber * participant_id;

@end

@interface API17_EncryptedChat_encryptedChatDiscarded : API17_EncryptedChat

@end

@interface API17_EncryptedChat_encryptedChatRequested : API17_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * admin_id;
@property (nonatomic, strong, readonly) NSNumber * participant_id;
@property (nonatomic, strong, readonly) NSData * g_a;

@end

@interface API17_EncryptedChat_encryptedChat : API17_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * admin_id;
@property (nonatomic, strong, readonly) NSNumber * participant_id;
@property (nonatomic, strong, readonly) NSData * g_a_or_b;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end


@interface API17_Document : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (API17_Document_documentEmpty *)documentEmptyWithPid:(NSNumber *)pid;
+ (API17_Document_document *)documentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash user_id:(NSNumber *)user_id date:(NSNumber *)date file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(API17_PhotoSize *)thumb dc_id:(NSNumber *)dc_id;

@end

@interface API17_Document_documentEmpty : API17_Document

@end

@interface API17_Document_document : API17_Document

@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) API17_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dc_id;

@end


@interface API17_ImportedContact : NSObject

@property (nonatomic, strong, readonly) NSNumber * user_id;
@property (nonatomic, strong, readonly) NSNumber * client_id;

+ (API17_ImportedContact_importedContact *)importedContactWithUser_id:(NSNumber *)user_id client_id:(NSNumber *)client_id;

@end

@interface API17_ImportedContact_importedContact : API17_ImportedContact

@end


/*
 * Functions 17
 */

