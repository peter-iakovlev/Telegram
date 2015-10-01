#import <Foundation/Foundation.h>

/*
 * Layer 38
 */

@class Api38_messages_StickerSet;
@class Api38_messages_StickerSet_messages_stickerSet;

@class Api38_InputGeoPlaceName;
@class Api38_InputGeoPlaceName_inputGeoPlaceName;

@class Api38_InputGeoPoint;
@class Api38_InputGeoPoint_inputGeoPointEmpty;
@class Api38_InputGeoPoint_inputGeoPoint;

@class Api38_messages_Chat;
@class Api38_messages_Chat_messages_chat;

@class Api38_ChatFull;
@class Api38_ChatFull_chatFull;
@class Api38_ChatFull_channelFull;

@class Api38_ChatParticipant;
@class Api38_ChatParticipant_chatParticipant;

@class Api38_updates_Difference;
@class Api38_updates_Difference_updates_differenceEmpty;
@class Api38_updates_Difference_updates_difference;
@class Api38_updates_Difference_updates_differenceSlice;

@class Api38_SchemeMethod;
@class Api38_SchemeMethod_schemeMethod;

@class Api38_InputPhotoCrop;
@class Api38_InputPhotoCrop_inputPhotoCropAuto;
@class Api38_InputPhotoCrop_inputPhotoCrop;

@class Api38_Photo;
@class Api38_Photo_photoEmpty;
@class Api38_Photo_wallPhoto;
@class Api38_Photo_photo;

@class Api38_Chat;
@class Api38_Chat_chatEmpty;
@class Api38_Chat_channel;
@class Api38_Chat_channelForbidden;
@class Api38_Chat_chat;
@class Api38_Chat_chatForbidden;

@class Api38_ChatInvite;
@class Api38_ChatInvite_chatInviteAlready;
@class Api38_ChatInvite_chatInvite;

@class Api38_contacts_Requests;
@class Api38_contacts_Requests_contacts_requests;
@class Api38_contacts_Requests_contacts_requestsSlice;

@class Api38_channels_ChannelParticipants;
@class Api38_channels_ChannelParticipants_channels_channelParticipants;

@class Api38_GeoPlaceName;
@class Api38_GeoPlaceName_geoPlaceName;

@class Api38_UserFull;
@class Api38_UserFull_userFull;

@class Api38_InputPeerNotifyEvents;
@class Api38_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty;
@class Api38_InputPeerNotifyEvents_inputPeerNotifyEventsAll;

@class Api38_InputChannel;
@class Api38_InputChannel_inputChannelEmpty;
@class Api38_InputChannel_inputChannel;

@class Api38_DcOption;
@class Api38_DcOption_dcOption;

@class Api38_MessageGroup;
@class Api38_MessageGroup_messageGroup;

@class Api38_account_PasswordSettings;
@class Api38_account_PasswordSettings_account_passwordSettings;

@class Api38_help_AppUpdate;
@class Api38_help_AppUpdate_help_appUpdate;
@class Api38_help_AppUpdate_help_noAppUpdate;

@class Api38_channels_ChannelParticipant;
@class Api38_channels_ChannelParticipant_channels_channelParticipant;

@class Api38_contacts_SentLink;
@class Api38_contacts_SentLink_contacts_sentLink;

@class Api38_ChannelParticipantRole;
@class Api38_ChannelParticipantRole_channelRoleEmpty;
@class Api38_ChannelParticipantRole_channelRoleModerator;
@class Api38_ChannelParticipantRole_channelRoleEditor;

@class Api38_storage_FileType;
@class Api38_storage_FileType_storage_fileUnknown;
@class Api38_storage_FileType_storage_fileJpeg;
@class Api38_storage_FileType_storage_fileGif;
@class Api38_storage_FileType_storage_filePng;
@class Api38_storage_FileType_storage_filePdf;
@class Api38_storage_FileType_storage_fileMp3;
@class Api38_storage_FileType_storage_fileMov;
@class Api38_storage_FileType_storage_filePartial;
@class Api38_storage_FileType_storage_fileMp4;
@class Api38_storage_FileType_storage_fileWebp;

@class Api38_InputEncryptedFile;
@class Api38_InputEncryptedFile_inputEncryptedFileEmpty;
@class Api38_InputEncryptedFile_inputEncryptedFileUploaded;
@class Api38_InputEncryptedFile_inputEncryptedFile;
@class Api38_InputEncryptedFile_inputEncryptedFileBigUploaded;

@class Api38_messages_SentEncryptedMessage;
@class Api38_messages_SentEncryptedMessage_messages_sentEncryptedMessage;
@class Api38_messages_SentEncryptedMessage_messages_sentEncryptedFile;

@class Api38_auth_Authorization;
@class Api38_auth_Authorization_auth_authorization;

@class Api38_InputFile;
@class Api38_InputFile_inputFile;
@class Api38_InputFile_inputFileBig;

@class Api38_Peer;
@class Api38_Peer_peerUser;
@class Api38_Peer_peerChat;
@class Api38_Peer_peerChannel;

@class Api38_UserStatus;
@class Api38_UserStatus_userStatusEmpty;
@class Api38_UserStatus_userStatusOnline;
@class Api38_UserStatus_userStatusOffline;
@class Api38_UserStatus_userStatusRecently;
@class Api38_UserStatus_userStatusLastWeek;
@class Api38_UserStatus_userStatusLastMonth;

@class Api38_Dialog;
@class Api38_Dialog_dialog;
@class Api38_Dialog_dialogChannel;

@class Api38_help_AppChangelog;
@class Api38_help_AppChangelog_help_appChangelogEmpty;
@class Api38_help_AppChangelog_help_appChangelog;

@class Api38_SendMessageAction;
@class Api38_SendMessageAction_sendMessageTypingAction;
@class Api38_SendMessageAction_sendMessageCancelAction;
@class Api38_SendMessageAction_sendMessageRecordVideoAction;
@class Api38_SendMessageAction_sendMessageRecordAudioAction;
@class Api38_SendMessageAction_sendMessageGeoLocationAction;
@class Api38_SendMessageAction_sendMessageChooseContactAction;
@class Api38_SendMessageAction_sendMessageUploadVideoAction;
@class Api38_SendMessageAction_sendMessageUploadAudioAction;
@class Api38_SendMessageAction_sendMessageUploadDocumentAction;
@class Api38_SendMessageAction_sendMessageUploadPhotoAction;

@class Api38_PrivacyKey;
@class Api38_PrivacyKey_privacyKeyStatusTimestamp;

@class Api38_Update;
@class Api38_Update_updateMessageID;
@class Api38_Update_updateRestoreMessages;
@class Api38_Update_updateChatParticipants;
@class Api38_Update_updateUserStatus;
@class Api38_Update_updateContactRegistered;
@class Api38_Update_updateContactLocated;
@class Api38_Update_updateActivation;
@class Api38_Update_updateNewAuthorization;
@class Api38_Update_updatePhoneCallRequested;
@class Api38_Update_updatePhoneCallConfirmed;
@class Api38_Update_updatePhoneCallDeclined;
@class Api38_Update_updateUserPhoto;
@class Api38_Update_updateNewEncryptedMessage;
@class Api38_Update_updateEncryptedChatTyping;
@class Api38_Update_updateEncryption;
@class Api38_Update_updateEncryptedMessagesRead;
@class Api38_Update_updateChatParticipantDelete;
@class Api38_Update_updateDcOptions;
@class Api38_Update_updateUserBlocked;
@class Api38_Update_updateNotifySettings;
@class Api38_Update_updateUserTyping;
@class Api38_Update_updateChatUserTyping;
@class Api38_Update_updateUserName;
@class Api38_Update_updateServiceNotification;
@class Api38_Update_updatePrivacy;
@class Api38_Update_updateUserPhone;
@class Api38_Update_updateNewMessage;
@class Api38_Update_updateReadMessages;
@class Api38_Update_updateDeleteMessages;
@class Api38_Update_updateReadHistoryInbox;
@class Api38_Update_updateReadHistoryOutbox;
@class Api38_Update_updateContactLink;
@class Api38_Update_updateReadMessagesContents;
@class Api38_Update_updateChatParticipantAdd;
@class Api38_Update_updateWebPage;
@class Api38_Update_updateChannelTooLong;
@class Api38_Update_updateChannel;
@class Api38_Update_updateChannelGroup;
@class Api38_Update_updateNewChannelMessage;
@class Api38_Update_updateReadChannelInbox;
@class Api38_Update_updateDeleteChannelMessages;
@class Api38_Update_updateChannelMessageViews;

@class Api38_ChannelParticipant;
@class Api38_ChannelParticipant_channelParticipant;
@class Api38_ChannelParticipant_channelParticipantSelf;
@class Api38_ChannelParticipant_channelParticipantModerator;
@class Api38_ChannelParticipant_channelParticipantEditor;
@class Api38_ChannelParticipant_channelParticipantKicked;
@class Api38_ChannelParticipant_channelParticipantCreator;

@class Api38_contacts_Blocked;
@class Api38_contacts_Blocked_contacts_blocked;
@class Api38_contacts_Blocked_contacts_blockedSlice;

@class Api38_Error;
@class Api38_Error_error;
@class Api38_Error_richError;

@class Api38_ContactLocated;
@class Api38_ContactLocated_contactLocated;
@class Api38_ContactLocated_contactLocatedPreview;

@class Api38_KeyboardButton;
@class Api38_KeyboardButton_keyboardButton;

@class Api38_ContactStatus;
@class Api38_ContactStatus_contactStatus;

@class Api38_PhotoSize;
@class Api38_PhotoSize_photoSizeEmpty;
@class Api38_PhotoSize_photoSize;
@class Api38_PhotoSize_photoCachedSize;

@class Api38_messages_Stickers;
@class Api38_messages_Stickers_messages_stickersNotModified;
@class Api38_messages_Stickers_messages_stickers;

@class Api38_GlobalPrivacySettings;
@class Api38_GlobalPrivacySettings_globalPrivacySettings;

@class Api38_FileLocation;
@class Api38_FileLocation_fileLocationUnavailable;
@class Api38_FileLocation_fileLocation;

@class Api38_InputNotifyPeer;
@class Api38_InputNotifyPeer_inputNotifyPeer;
@class Api38_InputNotifyPeer_inputNotifyUsers;
@class Api38_InputNotifyPeer_inputNotifyChats;
@class Api38_InputNotifyPeer_inputNotifyAll;

@class Api38_EncryptedMessage;
@class Api38_EncryptedMessage_encryptedMessage;
@class Api38_EncryptedMessage_encryptedMessageService;

@class Api38_ChannelParticipantsFilter;
@class Api38_ChannelParticipantsFilter_channelParticipantsRecent;
@class Api38_ChannelParticipantsFilter_channelParticipantsAdmins;
@class Api38_ChannelParticipantsFilter_channelParticipantsKicked;

@class Api38_WebPage;
@class Api38_WebPage_webPageEmpty;
@class Api38_WebPage_webPagePending;
@class Api38_WebPage_webPage;

@class Api38_KeyboardButtonRow;
@class Api38_KeyboardButtonRow_keyboardButtonRow;

@class Api38_StickerSet;
@class Api38_StickerSet_stickerSet;

@class Api38_photos_Photo;
@class Api38_photos_Photo_photos_photo;

@class Api38_InputContact;
@class Api38_InputContact_inputPhoneContact;

@class Api38_contacts_Contacts;
@class Api38_contacts_Contacts_contacts_contacts;
@class Api38_contacts_Contacts_contacts_contactsNotModified;

@class Api38_ChannelMessagesFilter;
@class Api38_ChannelMessagesFilter_channelMessagesFilterEmpty;
@class Api38_ChannelMessagesFilter_channelMessagesFilter;
@class Api38_ChannelMessagesFilter_channelMessagesFilterCollapsed;

@class Api38_auth_PasswordRecovery;
@class Api38_auth_PasswordRecovery_auth_passwordRecovery;

@class Api38_InputDocument;
@class Api38_InputDocument_inputDocumentEmpty;
@class Api38_InputDocument_inputDocument;

@class Api38_contacts_ResolvedPeer;
@class Api38_contacts_ResolvedPeer_contacts_resolvedPeer;

@class Api38_InputMedia;
@class Api38_InputMedia_inputMediaEmpty;
@class Api38_InputMedia_inputMediaGeoPoint;
@class Api38_InputMedia_inputMediaContact;
@class Api38_InputMedia_inputMediaAudio;
@class Api38_InputMedia_inputMediaDocument;
@class Api38_InputMedia_inputMediaUploadedAudio;
@class Api38_InputMedia_inputMediaUploadedDocument;
@class Api38_InputMedia_inputMediaUploadedThumbDocument;
@class Api38_InputMedia_inputMediaUploadedPhoto;
@class Api38_InputMedia_inputMediaPhoto;
@class Api38_InputMedia_inputMediaVideo;
@class Api38_InputMedia_inputMediaVenue;
@class Api38_InputMedia_inputMediaUploadedVideo;
@class Api38_InputMedia_inputMediaUploadedThumbVideo;

@class Api38_InputPeer;
@class Api38_InputPeer_inputPeerEmpty;
@class Api38_InputPeer_inputPeerSelf;
@class Api38_InputPeer_inputPeerChat;
@class Api38_InputPeer_inputPeerUser;
@class Api38_InputPeer_inputPeerChannel;

@class Api38_Contact;
@class Api38_Contact_contact;

@class Api38_messages_Chats;
@class Api38_messages_Chats_messages_chats;

@class Api38_contacts_MyLink;
@class Api38_contacts_MyLink_contacts_myLinkEmpty;
@class Api38_contacts_MyLink_contacts_myLinkRequested;
@class Api38_contacts_MyLink_contacts_myLinkContact;

@class Api38_InputPrivacyRule;
@class Api38_InputPrivacyRule_inputPrivacyValueAllowContacts;
@class Api38_InputPrivacyRule_inputPrivacyValueAllowAll;
@class Api38_InputPrivacyRule_inputPrivacyValueAllowUsers;
@class Api38_InputPrivacyRule_inputPrivacyValueDisallowContacts;
@class Api38_InputPrivacyRule_inputPrivacyValueDisallowAll;
@class Api38_InputPrivacyRule_inputPrivacyValueDisallowUsers;

@class Api38_messages_DhConfig;
@class Api38_messages_DhConfig_messages_dhConfigNotModified;
@class Api38_messages_DhConfig_messages_dhConfig;

@class Api38_auth_ExportedAuthorization;
@class Api38_auth_ExportedAuthorization_auth_exportedAuthorization;

@class Api38_ContactRequest;
@class Api38_ContactRequest_contactRequest;

@class Api38_messages_AffectedHistory;
@class Api38_messages_AffectedHistory_messages_affectedHistory;

@class Api38_account_PasswordInputSettings;
@class Api38_account_PasswordInputSettings_account_passwordInputSettings;

@class Api38_messages_ChatFull;
@class Api38_messages_ChatFull_messages_chatFull;

@class Api38_contacts_ForeignLink;
@class Api38_contacts_ForeignLink_contacts_foreignLinkUnknown;
@class Api38_contacts_ForeignLink_contacts_foreignLinkRequested;
@class Api38_contacts_ForeignLink_contacts_foreignLinkMutual;

@class Api38_InputEncryptedChat;
@class Api38_InputEncryptedChat_inputEncryptedChat;

@class Api38_DisabledFeature;
@class Api38_DisabledFeature_disabledFeature;

@class Api38_EncryptedFile;
@class Api38_EncryptedFile_encryptedFileEmpty;
@class Api38_EncryptedFile_encryptedFile;

@class Api38_NotifyPeer;
@class Api38_NotifyPeer_notifyPeer;
@class Api38_NotifyPeer_notifyUsers;
@class Api38_NotifyPeer_notifyChats;
@class Api38_NotifyPeer_notifyAll;

@class Api38_InputPrivacyKey;
@class Api38_InputPrivacyKey_inputPrivacyKeyStatusTimestamp;

@class Api38_ReplyMarkup;
@class Api38_ReplyMarkup_replyKeyboardHide;
@class Api38_ReplyMarkup_replyKeyboardForceReply;
@class Api38_ReplyMarkup_replyKeyboardMarkup;

@class Api38_contacts_Link;
@class Api38_contacts_Link_contacts_link;

@class Api38_ContactBlocked;
@class Api38_ContactBlocked_contactBlocked;

@class Api38_auth_CheckedPhone;
@class Api38_auth_CheckedPhone_auth_checkedPhone;

@class Api38_InputUser;
@class Api38_InputUser_inputUserEmpty;
@class Api38_InputUser_inputUserSelf;
@class Api38_InputUser_inputUser;

@class Api38_SchemeType;
@class Api38_SchemeType_schemeType;

@class Api38_upload_File;
@class Api38_upload_File_upload_file;

@class Api38_InputVideo;
@class Api38_InputVideo_inputVideoEmpty;
@class Api38_InputVideo_inputVideo;

@class Api38_MessageRange;
@class Api38_MessageRange_messageRange;

@class Api38_Config;
@class Api38_Config_config;

@class Api38_BotCommand;
@class Api38_BotCommand_botCommand;

@class Api38_Audio;
@class Api38_Audio_audioEmpty;
@class Api38_Audio_audio;

@class Api38_contacts_Located;
@class Api38_contacts_Located_contacts_located;

@class Api38_messages_AffectedMessages;
@class Api38_messages_AffectedMessages_messages_affectedMessages;

@class Api38_InputAudio;
@class Api38_InputAudio_inputAudioEmpty;
@class Api38_InputAudio_inputAudio;

@class Api38_ResponseIndirect;
@class Api38_ResponseIndirect_responseIndirect;

@class Api38_WallPaper;
@class Api38_WallPaper_wallPaper;
@class Api38_WallPaper_wallPaperSolid;

@class Api38_messages_Messages;
@class Api38_messages_Messages_messages_messages;
@class Api38_messages_Messages_messages_messagesSlice;
@class Api38_messages_Messages_messages_channelMessages;

@class Api38_auth_SentCode;
@class Api38_auth_SentCode_auth_sentCodePreview;
@class Api38_auth_SentCode_auth_sentPassPhrase;
@class Api38_auth_SentCode_auth_sentCode;
@class Api38_auth_SentCode_auth_sentAppCode;

@class Api38_phone_DhConfig;
@class Api38_phone_DhConfig_phone_dhConfig;

@class Api38_InputChatPhoto;
@class Api38_InputChatPhoto_inputChatPhotoEmpty;
@class Api38_InputChatPhoto_inputChatUploadedPhoto;
@class Api38_InputChatPhoto_inputChatPhoto;

@class Api38_Updates;
@class Api38_Updates_updatesTooLong;
@class Api38_Updates_updateShort;
@class Api38_Updates_updatesCombined;
@class Api38_Updates_updates;
@class Api38_Updates_updateShortSentMessage;
@class Api38_Updates_updateShortMessage;
@class Api38_Updates_updateShortChatMessage;

@class Api38_InitConnection;
@class Api38_InitConnection_pinitConnection;

@class Api38_MessageMedia;
@class Api38_MessageMedia_messageMediaEmpty;
@class Api38_MessageMedia_messageMediaGeo;
@class Api38_MessageMedia_messageMediaContact;
@class Api38_MessageMedia_messageMediaDocument;
@class Api38_MessageMedia_messageMediaAudio;
@class Api38_MessageMedia_messageMediaUnsupported;
@class Api38_MessageMedia_messageMediaWebPage;
@class Api38_MessageMedia_messageMediaPhoto;
@class Api38_MessageMedia_messageMediaVideo;
@class Api38_MessageMedia_messageMediaVenue;

@class Api38_Null;
@class Api38_Null_null;

@class Api38_DocumentAttribute;
@class Api38_DocumentAttribute_documentAttributeImageSize;
@class Api38_DocumentAttribute_documentAttributeAnimated;
@class Api38_DocumentAttribute_documentAttributeVideo;
@class Api38_DocumentAttribute_documentAttributeFilename;
@class Api38_DocumentAttribute_documentAttributeSticker;
@class Api38_DocumentAttribute_documentAttributeAudio;

@class Api38_account_Authorizations;
@class Api38_account_Authorizations_account_authorizations;

@class Api38_ChatPhoto;
@class Api38_ChatPhoto_chatPhotoEmpty;
@class Api38_ChatPhoto_chatPhoto;

@class Api38_InputStickerSet;
@class Api38_InputStickerSet_inputStickerSetEmpty;
@class Api38_InputStickerSet_inputStickerSetID;
@class Api38_InputStickerSet_inputStickerSetShortName;

@class Api38_BotInfo;
@class Api38_BotInfo_botInfoEmpty;
@class Api38_BotInfo_botInfo;

@class Api38_contacts_Suggested;
@class Api38_contacts_Suggested_contacts_suggested;

@class Api38_updates_State;
@class Api38_updates_State_updates_state;

@class Api38_User;
@class Api38_User_userEmpty;
@class Api38_User_user;

@class Api38_Message;
@class Api38_Message_messageEmpty;
@class Api38_Message_message;
@class Api38_Message_messageService;

@class Api38_InputFileLocation;
@class Api38_InputFileLocation_inputFileLocation;
@class Api38_InputFileLocation_inputVideoFileLocation;
@class Api38_InputFileLocation_inputEncryptedFileLocation;
@class Api38_InputFileLocation_inputAudioFileLocation;
@class Api38_InputFileLocation_inputDocumentFileLocation;

@class Api38_GeoPoint;
@class Api38_GeoPoint_geoPointEmpty;
@class Api38_GeoPoint_geoPoint;
@class Api38_GeoPoint_geoPlace;

@class Api38_InputPhoneCall;
@class Api38_InputPhoneCall_inputPhoneCall;

@class Api38_ReceivedNotifyMessage;
@class Api38_ReceivedNotifyMessage_receivedNotifyMessage;

@class Api38_ChatParticipants;
@class Api38_ChatParticipants_chatParticipants;
@class Api38_ChatParticipants_chatParticipantsForbidden;

@class Api38_NearestDc;
@class Api38_NearestDc_nearestDc;

@class Api38_photos_Photos;
@class Api38_photos_Photos_photos_photos;
@class Api38_photos_Photos_photos_photosSlice;

@class Api38_contacts_ImportedContacts;
@class Api38_contacts_ImportedContacts_contacts_importedContacts;

@class Api38_Bool;
@class Api38_Bool_boolFalse;
@class Api38_Bool_boolTrue;

@class Api38_help_Support;
@class Api38_help_Support_help_support;

@class Api38_ChatLocated;
@class Api38_ChatLocated_chatLocated;

@class Api38_MessagesFilter;
@class Api38_MessagesFilter_inputMessagesFilterEmpty;
@class Api38_MessagesFilter_inputMessagesFilterPhotos;
@class Api38_MessagesFilter_inputMessagesFilterVideo;
@class Api38_MessagesFilter_inputMessagesFilterPhotoVideo;
@class Api38_MessagesFilter_inputMessagesFilterDocument;
@class Api38_MessagesFilter_inputMessagesFilterAudio;
@class Api38_MessagesFilter_inputMessagesFilterPhotoVideoDocuments;

@class Api38_messages_Dialogs;
@class Api38_messages_Dialogs_messages_dialogs;
@class Api38_messages_Dialogs_messages_dialogsSlice;

@class Api38_help_InviteText;
@class Api38_help_InviteText_help_inviteText;

@class Api38_ContactSuggested;
@class Api38_ContactSuggested_contactSuggested;

@class Api38_InputPeerNotifySettings;
@class Api38_InputPeerNotifySettings_inputPeerNotifySettings;

@class Api38_ExportedChatInvite;
@class Api38_ExportedChatInvite_chatInviteEmpty;
@class Api38_ExportedChatInvite_chatInviteExported;

@class Api38_DcNetworkStats;
@class Api38_DcNetworkStats_dcPingStats;

@class Api38_Authorization;
@class Api38_Authorization_authorization;

@class Api38_messages_AllStickers;
@class Api38_messages_AllStickers_messages_allStickersNotModified;
@class Api38_messages_AllStickers_messages_allStickers;

@class Api38_PhoneConnection;
@class Api38_PhoneConnection_phoneConnectionNotReady;
@class Api38_PhoneConnection_phoneConnection;

@class Api38_AccountDaysTTL;
@class Api38_AccountDaysTTL_accountDaysTTL;

@class Api38_Scheme;
@class Api38_Scheme_scheme;
@class Api38_Scheme_schemeNotModified;

@class Api38_account_Password;
@class Api38_account_Password_account_noPassword;
@class Api38_account_Password_account_password;

@class Api38_account_PrivacyRules;
@class Api38_account_PrivacyRules_account_privacyRules;

@class Api38_messages_Message;
@class Api38_messages_Message_messages_messageEmpty;
@class Api38_messages_Message_messages_message;

@class Api38_PrivacyRule;
@class Api38_PrivacyRule_privacyValueAllowContacts;
@class Api38_PrivacyRule_privacyValueAllowAll;
@class Api38_PrivacyRule_privacyValueAllowUsers;
@class Api38_PrivacyRule_privacyValueDisallowContacts;
@class Api38_PrivacyRule_privacyValueDisallowAll;
@class Api38_PrivacyRule_privacyValueDisallowUsers;

@class Api38_account_SentChangePhoneCode;
@class Api38_account_SentChangePhoneCode_account_sentChangePhoneCode;

@class Api38_MessageAction;
@class Api38_MessageAction_messageActionEmpty;
@class Api38_MessageAction_messageActionChatCreate;
@class Api38_MessageAction_messageActionChatEditTitle;
@class Api38_MessageAction_messageActionChatEditPhoto;
@class Api38_MessageAction_messageActionChatDeletePhoto;
@class Api38_MessageAction_messageActionChatAddUser;
@class Api38_MessageAction_messageActionChatDeleteUser;
@class Api38_MessageAction_messageActionSentRequest;
@class Api38_MessageAction_messageActionAcceptRequest;
@class Api38_MessageAction_messageActionChatJoinedByLink;
@class Api38_MessageAction_messageActionChannelCreate;

@class Api38_PhoneCall;
@class Api38_PhoneCall_phoneCallEmpty;
@class Api38_PhoneCall_phoneCall;

@class Api38_PeerNotifyEvents;
@class Api38_PeerNotifyEvents_peerNotifyEventsEmpty;
@class Api38_PeerNotifyEvents_peerNotifyEventsAll;

@class Api38_ContactLink;
@class Api38_ContactLink_contactLinkUnknown;
@class Api38_ContactLink_contactLinkNone;
@class Api38_ContactLink_contactLinkHasPhone;
@class Api38_ContactLink_contactLinkContact;

@class Api38_help_AppPrefs;
@class Api38_help_AppPrefs_help_appPrefs;

@class Api38_contacts_Found;
@class Api38_contacts_Found_contacts_found;

@class Api38_PeerNotifySettings;
@class Api38_PeerNotifySettings_peerNotifySettingsEmpty;
@class Api38_PeerNotifySettings_peerNotifySettings;

@class Api38_SchemeParam;
@class Api38_SchemeParam_schemeParam;

@class Api38_StickerPack;
@class Api38_StickerPack_stickerPack;

@class Api38_UserProfilePhoto;
@class Api38_UserProfilePhoto_userProfilePhotoEmpty;
@class Api38_UserProfilePhoto_userProfilePhoto;

@class Api38_updates_ChannelDifference;
@class Api38_updates_ChannelDifference_updates_channelDifferenceEmpty;
@class Api38_updates_ChannelDifference_updates_channelDifferenceTooLong;
@class Api38_updates_ChannelDifference_updates_channelDifference;

@class Api38_MessageEntity;
@class Api38_MessageEntity_messageEntityUnknown;
@class Api38_MessageEntity_messageEntityMention;
@class Api38_MessageEntity_messageEntityHashtag;
@class Api38_MessageEntity_messageEntityBotCommand;
@class Api38_MessageEntity_messageEntityUrl;
@class Api38_MessageEntity_messageEntityEmail;
@class Api38_MessageEntity_messageEntityBold;
@class Api38_MessageEntity_messageEntityItalic;
@class Api38_MessageEntity_messageEntityCode;
@class Api38_MessageEntity_messageEntityPre;
@class Api38_MessageEntity_messageEntityTextUrl;

@class Api38_InputPhoto;
@class Api38_InputPhoto_inputPhotoEmpty;
@class Api38_InputPhoto_inputPhoto;

@class Api38_Video;
@class Api38_Video_videoEmpty;
@class Api38_Video_video;

@class Api38_EncryptedChat;
@class Api38_EncryptedChat_encryptedChatEmpty;
@class Api38_EncryptedChat_encryptedChatWaiting;
@class Api38_EncryptedChat_encryptedChatDiscarded;
@class Api38_EncryptedChat_encryptedChatRequested;
@class Api38_EncryptedChat_encryptedChat;

@class Api38_Document;
@class Api38_Document_documentEmpty;
@class Api38_Document_document;

@class Api38_ImportedContact;
@class Api38_ImportedContact_importedContact;


@interface Api38__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Api38_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 38
 */

@interface Api38_messages_StickerSet : NSObject

@property (nonatomic, strong, readonly) Api38_StickerSet * set;
@property (nonatomic, strong, readonly) NSArray * packs;
@property (nonatomic, strong, readonly) NSArray * documents;

+ (Api38_messages_StickerSet_messages_stickerSet *)messages_stickerSetWithSet:(Api38_StickerSet *)set packs:(NSArray *)packs documents:(NSArray *)documents;

@end

@interface Api38_messages_StickerSet_messages_stickerSet : Api38_messages_StickerSet

@end


@interface Api38_InputGeoPlaceName : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSString * state;
@property (nonatomic, strong, readonly) NSString * city;
@property (nonatomic, strong, readonly) NSString * district;
@property (nonatomic, strong, readonly) NSString * street;

+ (Api38_InputGeoPlaceName_inputGeoPlaceName *)inputGeoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street;

@end

@interface Api38_InputGeoPlaceName_inputGeoPlaceName : Api38_InputGeoPlaceName

@end


@interface Api38_InputGeoPoint : NSObject

+ (Api38_InputGeoPoint_inputGeoPointEmpty *)inputGeoPointEmpty;
+ (Api38_InputGeoPoint_inputGeoPoint *)inputGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;

@end

@interface Api38_InputGeoPoint_inputGeoPointEmpty : Api38_InputGeoPoint

@end

@interface Api38_InputGeoPoint_inputGeoPoint : Api38_InputGeoPoint

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end


@interface Api38_messages_Chat : NSObject

@property (nonatomic, strong, readonly) Api38_Chat * chat;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_messages_Chat_messages_chat *)messages_chatWithChat:(Api38_Chat *)chat users:(NSArray *)users;

@end

@interface Api38_messages_Chat_messages_chat : Api38_messages_Chat

@end


@interface Api38_ChatFull : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) Api38_Photo * chatPhoto;
@property (nonatomic, strong, readonly) Api38_PeerNotifySettings * notifySettings;
@property (nonatomic, strong, readonly) Api38_ExportedChatInvite * exportedInvite;

+ (Api38_ChatFull_chatFull *)chatFullWithPid:(NSNumber *)pid participants:(Api38_ChatParticipants *)participants chatPhoto:(Api38_Photo *)chatPhoto notifySettings:(Api38_PeerNotifySettings *)notifySettings exportedInvite:(Api38_ExportedChatInvite *)exportedInvite botInfo:(NSArray *)botInfo;
+ (Api38_ChatFull_channelFull *)channelFullWithFlags:(NSNumber *)flags pid:(NSNumber *)pid about:(NSString *)about participantsCount:(NSNumber *)participantsCount adminsCount:(NSNumber *)adminsCount kickedCount:(NSNumber *)kickedCount readInboxMaxId:(NSNumber *)readInboxMaxId unreadCount:(NSNumber *)unreadCount unreadImportantCount:(NSNumber *)unreadImportantCount chatPhoto:(Api38_Photo *)chatPhoto notifySettings:(Api38_PeerNotifySettings *)notifySettings exportedInvite:(Api38_ExportedChatInvite *)exportedInvite;

@end

@interface Api38_ChatFull_chatFull : Api38_ChatFull

@property (nonatomic, strong, readonly) Api38_ChatParticipants * participants;
@property (nonatomic, strong, readonly) NSArray * botInfo;

@end

@interface Api38_ChatFull_channelFull : Api38_ChatFull

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSString * about;
@property (nonatomic, strong, readonly) NSNumber * participantsCount;
@property (nonatomic, strong, readonly) NSNumber * adminsCount;
@property (nonatomic, strong, readonly) NSNumber * kickedCount;
@property (nonatomic, strong, readonly) NSNumber * readInboxMaxId;
@property (nonatomic, strong, readonly) NSNumber * unreadCount;
@property (nonatomic, strong, readonly) NSNumber * unreadImportantCount;

@end


@interface Api38_ChatParticipant : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * inviterId;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (Api38_ChatParticipant_chatParticipant *)chatParticipantWithUserId:(NSNumber *)userId inviterId:(NSNumber *)inviterId date:(NSNumber *)date;

@end

@interface Api38_ChatParticipant_chatParticipant : Api38_ChatParticipant

@end


@interface Api38_updates_Difference : NSObject

+ (Api38_updates_Difference_updates_differenceEmpty *)updates_differenceEmptyWithDate:(NSNumber *)date seq:(NSNumber *)seq;
+ (Api38_updates_Difference_updates_difference *)updates_differenceWithPnewMessages:(NSArray *)pnewMessages pnewEncryptedMessages:(NSArray *)pnewEncryptedMessages otherUpdates:(NSArray *)otherUpdates chats:(NSArray *)chats users:(NSArray *)users state:(Api38_updates_State *)state;
+ (Api38_updates_Difference_updates_differenceSlice *)updates_differenceSliceWithPnewMessages:(NSArray *)pnewMessages pnewEncryptedMessages:(NSArray *)pnewEncryptedMessages otherUpdates:(NSArray *)otherUpdates chats:(NSArray *)chats users:(NSArray *)users intermediateState:(Api38_updates_State *)intermediateState;

@end

@interface Api38_updates_Difference_updates_differenceEmpty : Api38_updates_Difference

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface Api38_updates_Difference_updates_difference : Api38_updates_Difference

@property (nonatomic, strong, readonly) NSArray * pnewMessages;
@property (nonatomic, strong, readonly) NSArray * pnewEncryptedMessages;
@property (nonatomic, strong, readonly) NSArray * otherUpdates;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) Api38_updates_State * state;

@end

@interface Api38_updates_Difference_updates_differenceSlice : Api38_updates_Difference

@property (nonatomic, strong, readonly) NSArray * pnewMessages;
@property (nonatomic, strong, readonly) NSArray * pnewEncryptedMessages;
@property (nonatomic, strong, readonly) NSArray * otherUpdates;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) Api38_updates_State * intermediateState;

@end


@interface Api38_SchemeMethod : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * method;
@property (nonatomic, strong, readonly) NSArray * params;
@property (nonatomic, strong, readonly) NSString * type;

+ (Api38_SchemeMethod_schemeMethod *)schemeMethodWithPid:(NSNumber *)pid method:(NSString *)method params:(NSArray *)params type:(NSString *)type;

@end

@interface Api38_SchemeMethod_schemeMethod : Api38_SchemeMethod

@end


@interface Api38_InputPhotoCrop : NSObject

+ (Api38_InputPhotoCrop_inputPhotoCropAuto *)inputPhotoCropAuto;
+ (Api38_InputPhotoCrop_inputPhotoCrop *)inputPhotoCropWithCropLeft:(NSNumber *)cropLeft cropTop:(NSNumber *)cropTop cropWidth:(NSNumber *)cropWidth;

@end

@interface Api38_InputPhotoCrop_inputPhotoCropAuto : Api38_InputPhotoCrop

@end

@interface Api38_InputPhotoCrop_inputPhotoCrop : Api38_InputPhotoCrop

@property (nonatomic, strong, readonly) NSNumber * cropLeft;
@property (nonatomic, strong, readonly) NSNumber * cropTop;
@property (nonatomic, strong, readonly) NSNumber * cropWidth;

@end


@interface Api38_Photo : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Photo_photoEmpty *)photoEmptyWithPid:(NSNumber *)pid;
+ (Api38_Photo_wallPhoto *)wallPhotoWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash userId:(NSNumber *)userId date:(NSNumber *)date caption:(NSString *)caption geo:(Api38_GeoPoint *)geo unread:(Api38_Bool *)unread sizes:(NSArray *)sizes;
+ (Api38_Photo_photo *)photoWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date sizes:(NSArray *)sizes;

@end

@interface Api38_Photo_photoEmpty : Api38_Photo

@end

@interface Api38_Photo_wallPhoto : Api38_Photo

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * caption;
@property (nonatomic, strong, readonly) Api38_GeoPoint * geo;
@property (nonatomic, strong, readonly) Api38_Bool * unread;
@property (nonatomic, strong, readonly) NSArray * sizes;

@end

@interface Api38_Photo_photo : Api38_Photo

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSArray * sizes;

@end


@interface Api38_Chat : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Chat_chatEmpty *)chatEmptyWithPid:(NSNumber *)pid;
+ (Api38_Chat_channel *)channelWithFlags:(NSNumber *)flags pid:(NSNumber *)pid accessHash:(NSNumber *)accessHash title:(NSString *)title username:(NSString *)username photo:(Api38_ChatPhoto *)photo date:(NSNumber *)date version:(NSNumber *)version;
+ (Api38_Chat_channelForbidden *)channelForbiddenWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash title:(NSString *)title;
+ (Api38_Chat_chat *)chatWithFlags:(NSNumber *)flags pid:(NSNumber *)pid title:(NSString *)title photo:(Api38_ChatPhoto *)photo participantsCount:(NSNumber *)participantsCount date:(NSNumber *)date version:(NSNumber *)version;
+ (Api38_Chat_chatForbidden *)chatForbiddenWithPid:(NSNumber *)pid title:(NSString *)title;

@end

@interface Api38_Chat_chatEmpty : Api38_Chat

@end

@interface Api38_Chat_channel : Api38_Chat

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * username;
@property (nonatomic, strong, readonly) Api38_ChatPhoto * photo;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_Chat_channelForbidden : Api38_Chat

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSString * title;

@end

@interface Api38_Chat_chat : Api38_Chat

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) Api38_ChatPhoto * photo;
@property (nonatomic, strong, readonly) NSNumber * participantsCount;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_Chat_chatForbidden : Api38_Chat

@property (nonatomic, strong, readonly) NSString * title;

@end


@interface Api38_ChatInvite : NSObject

+ (Api38_ChatInvite_chatInviteAlready *)chatInviteAlreadyWithChat:(Api38_Chat *)chat;
+ (Api38_ChatInvite_chatInvite *)chatInviteWithFlags:(NSNumber *)flags title:(NSString *)title;

@end

@interface Api38_ChatInvite_chatInviteAlready : Api38_ChatInvite

@property (nonatomic, strong, readonly) Api38_Chat * chat;

@end

@interface Api38_ChatInvite_chatInvite : Api38_ChatInvite

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSString * title;

@end


@interface Api38_contacts_Requests : NSObject

@property (nonatomic, strong, readonly) NSArray * requests;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_Requests_contacts_requests *)contacts_requestsWithRequests:(NSArray *)requests users:(NSArray *)users;
+ (Api38_contacts_Requests_contacts_requestsSlice *)contacts_requestsSliceWithCount:(NSNumber *)count requests:(NSArray *)requests users:(NSArray *)users;

@end

@interface Api38_contacts_Requests_contacts_requests : Api38_contacts_Requests

@end

@interface Api38_contacts_Requests_contacts_requestsSlice : Api38_contacts_Requests

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface Api38_channels_ChannelParticipants : NSObject

@property (nonatomic, strong, readonly) NSNumber * count;
@property (nonatomic, strong, readonly) NSArray * participants;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_channels_ChannelParticipants_channels_channelParticipants *)channels_channelParticipantsWithCount:(NSNumber *)count participants:(NSArray *)participants users:(NSArray *)users;

@end

@interface Api38_channels_ChannelParticipants_channels_channelParticipants : Api38_channels_ChannelParticipants

@end


@interface Api38_GeoPlaceName : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSString * state;
@property (nonatomic, strong, readonly) NSString * city;
@property (nonatomic, strong, readonly) NSString * district;
@property (nonatomic, strong, readonly) NSString * street;

+ (Api38_GeoPlaceName_geoPlaceName *)geoPlaceNameWithCountry:(NSString *)country state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street;

@end

@interface Api38_GeoPlaceName_geoPlaceName : Api38_GeoPlaceName

@end


@interface Api38_UserFull : NSObject

@property (nonatomic, strong, readonly) Api38_User * user;
@property (nonatomic, strong, readonly) Api38_contacts_Link * link;
@property (nonatomic, strong, readonly) Api38_Photo * profilePhoto;
@property (nonatomic, strong, readonly) Api38_PeerNotifySettings * notifySettings;
@property (nonatomic, strong, readonly) Api38_Bool * blocked;
@property (nonatomic, strong, readonly) Api38_BotInfo * botInfo;

+ (Api38_UserFull_userFull *)userFullWithUser:(Api38_User *)user link:(Api38_contacts_Link *)link profilePhoto:(Api38_Photo *)profilePhoto notifySettings:(Api38_PeerNotifySettings *)notifySettings blocked:(Api38_Bool *)blocked botInfo:(Api38_BotInfo *)botInfo;

@end

@interface Api38_UserFull_userFull : Api38_UserFull

@end


@interface Api38_InputPeerNotifyEvents : NSObject

+ (Api38_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty *)inputPeerNotifyEventsEmpty;
+ (Api38_InputPeerNotifyEvents_inputPeerNotifyEventsAll *)inputPeerNotifyEventsAll;

@end

@interface Api38_InputPeerNotifyEvents_inputPeerNotifyEventsEmpty : Api38_InputPeerNotifyEvents

@end

@interface Api38_InputPeerNotifyEvents_inputPeerNotifyEventsAll : Api38_InputPeerNotifyEvents

@end


@interface Api38_InputChannel : NSObject

+ (Api38_InputChannel_inputChannelEmpty *)inputChannelEmpty;
+ (Api38_InputChannel_inputChannel *)inputChannelWithChannelId:(NSNumber *)channelId accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputChannel_inputChannelEmpty : Api38_InputChannel

@end

@interface Api38_InputChannel_inputChannel : Api38_InputChannel

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_DcOption : NSObject

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * ipAddress;
@property (nonatomic, strong, readonly) NSNumber * port;

+ (Api38_DcOption_dcOption *)dcOptionWithFlags:(NSNumber *)flags pid:(NSNumber *)pid ipAddress:(NSString *)ipAddress port:(NSNumber *)port;

@end

@interface Api38_DcOption_dcOption : Api38_DcOption

@end


@interface Api38_MessageGroup : NSObject

@property (nonatomic, strong, readonly) NSNumber * minId;
@property (nonatomic, strong, readonly) NSNumber * maxId;
@property (nonatomic, strong, readonly) NSNumber * count;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (Api38_MessageGroup_messageGroup *)messageGroupWithMinId:(NSNumber *)minId maxId:(NSNumber *)maxId count:(NSNumber *)count date:(NSNumber *)date;

@end

@interface Api38_MessageGroup_messageGroup : Api38_MessageGroup

@end


@interface Api38_account_PasswordSettings : NSObject

@property (nonatomic, strong, readonly) NSString * email;

+ (Api38_account_PasswordSettings_account_passwordSettings *)account_passwordSettingsWithEmail:(NSString *)email;

@end

@interface Api38_account_PasswordSettings_account_passwordSettings : Api38_account_PasswordSettings

@end


@interface Api38_help_AppUpdate : NSObject

+ (Api38_help_AppUpdate_help_appUpdate *)help_appUpdateWithPid:(NSNumber *)pid critical:(Api38_Bool *)critical url:(NSString *)url text:(NSString *)text;
+ (Api38_help_AppUpdate_help_noAppUpdate *)help_noAppUpdate;

@end

@interface Api38_help_AppUpdate_help_appUpdate : Api38_help_AppUpdate

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) Api38_Bool * critical;
@property (nonatomic, strong, readonly) NSString * url;
@property (nonatomic, strong, readonly) NSString * text;

@end

@interface Api38_help_AppUpdate_help_noAppUpdate : Api38_help_AppUpdate

@end


@interface Api38_channels_ChannelParticipant : NSObject

@property (nonatomic, strong, readonly) Api38_ChannelParticipant * participant;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_channels_ChannelParticipant_channels_channelParticipant *)channels_channelParticipantWithParticipant:(Api38_ChannelParticipant *)participant users:(NSArray *)users;

@end

@interface Api38_channels_ChannelParticipant_channels_channelParticipant : Api38_channels_ChannelParticipant

@end


@interface Api38_contacts_SentLink : NSObject

@property (nonatomic, strong, readonly) Api38_messages_Message * message;
@property (nonatomic, strong, readonly) Api38_contacts_Link * link;

+ (Api38_contacts_SentLink_contacts_sentLink *)contacts_sentLinkWithMessage:(Api38_messages_Message *)message link:(Api38_contacts_Link *)link;

@end

@interface Api38_contacts_SentLink_contacts_sentLink : Api38_contacts_SentLink

@end


@interface Api38_ChannelParticipantRole : NSObject

+ (Api38_ChannelParticipantRole_channelRoleEmpty *)channelRoleEmpty;
+ (Api38_ChannelParticipantRole_channelRoleModerator *)channelRoleModerator;
+ (Api38_ChannelParticipantRole_channelRoleEditor *)channelRoleEditor;

@end

@interface Api38_ChannelParticipantRole_channelRoleEmpty : Api38_ChannelParticipantRole

@end

@interface Api38_ChannelParticipantRole_channelRoleModerator : Api38_ChannelParticipantRole

@end

@interface Api38_ChannelParticipantRole_channelRoleEditor : Api38_ChannelParticipantRole

@end


@interface Api38_storage_FileType : NSObject

+ (Api38_storage_FileType_storage_fileUnknown *)storage_fileUnknown;
+ (Api38_storage_FileType_storage_fileJpeg *)storage_fileJpeg;
+ (Api38_storage_FileType_storage_fileGif *)storage_fileGif;
+ (Api38_storage_FileType_storage_filePng *)storage_filePng;
+ (Api38_storage_FileType_storage_filePdf *)storage_filePdf;
+ (Api38_storage_FileType_storage_fileMp3 *)storage_fileMp3;
+ (Api38_storage_FileType_storage_fileMov *)storage_fileMov;
+ (Api38_storage_FileType_storage_filePartial *)storage_filePartial;
+ (Api38_storage_FileType_storage_fileMp4 *)storage_fileMp4;
+ (Api38_storage_FileType_storage_fileWebp *)storage_fileWebp;

@end

@interface Api38_storage_FileType_storage_fileUnknown : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileJpeg : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileGif : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_filePng : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_filePdf : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileMp3 : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileMov : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_filePartial : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileMp4 : Api38_storage_FileType

@end

@interface Api38_storage_FileType_storage_fileWebp : Api38_storage_FileType

@end


@interface Api38_InputEncryptedFile : NSObject

+ (Api38_InputEncryptedFile_inputEncryptedFileEmpty *)inputEncryptedFileEmpty;
+ (Api38_InputEncryptedFile_inputEncryptedFileUploaded *)inputEncryptedFileUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts md5Checksum:(NSString *)md5Checksum keyFingerprint:(NSNumber *)keyFingerprint;
+ (Api38_InputEncryptedFile_inputEncryptedFile *)inputEncryptedFileWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;
+ (Api38_InputEncryptedFile_inputEncryptedFileBigUploaded *)inputEncryptedFileBigUploadedWithPid:(NSNumber *)pid parts:(NSNumber *)parts keyFingerprint:(NSNumber *)keyFingerprint;

@end

@interface Api38_InputEncryptedFile_inputEncryptedFileEmpty : Api38_InputEncryptedFile

@end

@interface Api38_InputEncryptedFile_inputEncryptedFileUploaded : Api38_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSString * md5Checksum;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Api38_InputEncryptedFile_inputEncryptedFile : Api38_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputEncryptedFile_inputEncryptedFileBigUploaded : Api38_InputEncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end


@interface Api38_messages_SentEncryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;

+ (Api38_messages_SentEncryptedMessage_messages_sentEncryptedMessage *)messages_sentEncryptedMessageWithDate:(NSNumber *)date;
+ (Api38_messages_SentEncryptedMessage_messages_sentEncryptedFile *)messages_sentEncryptedFileWithDate:(NSNumber *)date file:(Api38_EncryptedFile *)file;

@end

@interface Api38_messages_SentEncryptedMessage_messages_sentEncryptedMessage : Api38_messages_SentEncryptedMessage

@end

@interface Api38_messages_SentEncryptedMessage_messages_sentEncryptedFile : Api38_messages_SentEncryptedMessage

@property (nonatomic, strong, readonly) Api38_EncryptedFile * file;

@end


@interface Api38_auth_Authorization : NSObject

@property (nonatomic, strong, readonly) Api38_User * user;

+ (Api38_auth_Authorization_auth_authorization *)auth_authorizationWithUser:(Api38_User *)user;

@end

@interface Api38_auth_Authorization_auth_authorization : Api38_auth_Authorization

@end


@interface Api38_InputFile : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * parts;
@property (nonatomic, strong, readonly) NSString * name;

+ (Api38_InputFile_inputFile *)inputFileWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name md5Checksum:(NSString *)md5Checksum;
+ (Api38_InputFile_inputFileBig *)inputFileBigWithPid:(NSNumber *)pid parts:(NSNumber *)parts name:(NSString *)name;

@end

@interface Api38_InputFile_inputFile : Api38_InputFile

@property (nonatomic, strong, readonly) NSString * md5Checksum;

@end

@interface Api38_InputFile_inputFileBig : Api38_InputFile

@end


@interface Api38_Peer : NSObject

+ (Api38_Peer_peerUser *)peerUserWithUserId:(NSNumber *)userId;
+ (Api38_Peer_peerChat *)peerChatWithChatId:(NSNumber *)chatId;
+ (Api38_Peer_peerChannel *)peerChannelWithChannelId:(NSNumber *)channelId;

@end

@interface Api38_Peer_peerUser : Api38_Peer

@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Api38_Peer_peerChat : Api38_Peer

@property (nonatomic, strong, readonly) NSNumber * chatId;

@end

@interface Api38_Peer_peerChannel : Api38_Peer

@property (nonatomic, strong, readonly) NSNumber * channelId;

@end


@interface Api38_UserStatus : NSObject

+ (Api38_UserStatus_userStatusEmpty *)userStatusEmpty;
+ (Api38_UserStatus_userStatusOnline *)userStatusOnlineWithExpires:(NSNumber *)expires;
+ (Api38_UserStatus_userStatusOffline *)userStatusOfflineWithWasOnline:(NSNumber *)wasOnline;
+ (Api38_UserStatus_userStatusRecently *)userStatusRecently;
+ (Api38_UserStatus_userStatusLastWeek *)userStatusLastWeek;
+ (Api38_UserStatus_userStatusLastMonth *)userStatusLastMonth;

@end

@interface Api38_UserStatus_userStatusEmpty : Api38_UserStatus

@end

@interface Api38_UserStatus_userStatusOnline : Api38_UserStatus

@property (nonatomic, strong, readonly) NSNumber * expires;

@end

@interface Api38_UserStatus_userStatusOffline : Api38_UserStatus

@property (nonatomic, strong, readonly) NSNumber * wasOnline;

@end

@interface Api38_UserStatus_userStatusRecently : Api38_UserStatus

@end

@interface Api38_UserStatus_userStatusLastWeek : Api38_UserStatus

@end

@interface Api38_UserStatus_userStatusLastMonth : Api38_UserStatus

@end


@interface Api38_Dialog : NSObject

@property (nonatomic, strong, readonly) Api38_Peer * peer;
@property (nonatomic, strong, readonly) NSNumber * topMessage;
@property (nonatomic, strong, readonly) NSNumber * readInboxMaxId;
@property (nonatomic, strong, readonly) NSNumber * unreadCount;
@property (nonatomic, strong, readonly) Api38_PeerNotifySettings * notifySettings;

+ (Api38_Dialog_dialog *)dialogWithPeer:(Api38_Peer *)peer topMessage:(NSNumber *)topMessage readInboxMaxId:(NSNumber *)readInboxMaxId unreadCount:(NSNumber *)unreadCount notifySettings:(Api38_PeerNotifySettings *)notifySettings;
+ (Api38_Dialog_dialogChannel *)dialogChannelWithPeer:(Api38_Peer *)peer topMessage:(NSNumber *)topMessage topImportantMessage:(NSNumber *)topImportantMessage readInboxMaxId:(NSNumber *)readInboxMaxId unreadCount:(NSNumber *)unreadCount unreadImportantCount:(NSNumber *)unreadImportantCount notifySettings:(Api38_PeerNotifySettings *)notifySettings pts:(NSNumber *)pts;

@end

@interface Api38_Dialog_dialog : Api38_Dialog

@end

@interface Api38_Dialog_dialogChannel : Api38_Dialog

@property (nonatomic, strong, readonly) NSNumber * topImportantMessage;
@property (nonatomic, strong, readonly) NSNumber * unreadImportantCount;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end


@interface Api38_help_AppChangelog : NSObject

+ (Api38_help_AppChangelog_help_appChangelogEmpty *)help_appChangelogEmpty;
+ (Api38_help_AppChangelog_help_appChangelog *)help_appChangelogWithText:(NSString *)text;

@end

@interface Api38_help_AppChangelog_help_appChangelogEmpty : Api38_help_AppChangelog

@end

@interface Api38_help_AppChangelog_help_appChangelog : Api38_help_AppChangelog

@property (nonatomic, strong, readonly) NSString * text;

@end


@interface Api38_SendMessageAction : NSObject

+ (Api38_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Api38_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Api38_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Api38_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Api38_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Api38_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;
+ (Api38_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoActionWithProgress:(NSNumber *)progress;
+ (Api38_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioActionWithProgress:(NSNumber *)progress;
+ (Api38_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentActionWithProgress:(NSNumber *)progress;
+ (Api38_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoActionWithProgress:(NSNumber *)progress;

@end

@interface Api38_SendMessageAction_sendMessageTypingAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageCancelAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageRecordVideoAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageRecordAudioAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageGeoLocationAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageChooseContactAction : Api38_SendMessageAction

@end

@interface Api38_SendMessageAction_sendMessageUploadVideoAction : Api38_SendMessageAction

@property (nonatomic, strong, readonly) NSNumber * progress;

@end

@interface Api38_SendMessageAction_sendMessageUploadAudioAction : Api38_SendMessageAction

@property (nonatomic, strong, readonly) NSNumber * progress;

@end

@interface Api38_SendMessageAction_sendMessageUploadDocumentAction : Api38_SendMessageAction

@property (nonatomic, strong, readonly) NSNumber * progress;

@end

@interface Api38_SendMessageAction_sendMessageUploadPhotoAction : Api38_SendMessageAction

@property (nonatomic, strong, readonly) NSNumber * progress;

@end


@interface Api38_PrivacyKey : NSObject

+ (Api38_PrivacyKey_privacyKeyStatusTimestamp *)privacyKeyStatusTimestamp;

@end

@interface Api38_PrivacyKey_privacyKeyStatusTimestamp : Api38_PrivacyKey

@end


@interface Api38_Update : NSObject

+ (Api38_Update_updateMessageID *)updateMessageIDWithPid:(NSNumber *)pid randomId:(NSNumber *)randomId;
+ (Api38_Update_updateRestoreMessages *)updateRestoreMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts;
+ (Api38_Update_updateChatParticipants *)updateChatParticipantsWithParticipants:(Api38_ChatParticipants *)participants;
+ (Api38_Update_updateUserStatus *)updateUserStatusWithUserId:(NSNumber *)userId status:(Api38_UserStatus *)status;
+ (Api38_Update_updateContactRegistered *)updateContactRegisteredWithUserId:(NSNumber *)userId date:(NSNumber *)date;
+ (Api38_Update_updateContactLocated *)updateContactLocatedWithContacts:(NSArray *)contacts;
+ (Api38_Update_updateActivation *)updateActivationWithUserId:(NSNumber *)userId;
+ (Api38_Update_updateNewAuthorization *)updateNewAuthorizationWithAuthKeyId:(NSNumber *)authKeyId date:(NSNumber *)date device:(NSString *)device location:(NSString *)location;
+ (Api38_Update_updatePhoneCallRequested *)updatePhoneCallRequestedWithPhoneCall:(Api38_PhoneCall *)phoneCall;
+ (Api38_Update_updatePhoneCallConfirmed *)updatePhoneCallConfirmedWithPid:(NSNumber *)pid aOrB:(NSData *)aOrB connection:(Api38_PhoneConnection *)connection;
+ (Api38_Update_updatePhoneCallDeclined *)updatePhoneCallDeclinedWithPid:(NSNumber *)pid;
+ (Api38_Update_updateUserPhoto *)updateUserPhotoWithUserId:(NSNumber *)userId date:(NSNumber *)date photo:(Api38_UserProfilePhoto *)photo previous:(Api38_Bool *)previous;
+ (Api38_Update_updateNewEncryptedMessage *)updateNewEncryptedMessageWithMessage:(Api38_EncryptedMessage *)message qts:(NSNumber *)qts;
+ (Api38_Update_updateEncryptedChatTyping *)updateEncryptedChatTypingWithChatId:(NSNumber *)chatId;
+ (Api38_Update_updateEncryption *)updateEncryptionWithChat:(Api38_EncryptedChat *)chat date:(NSNumber *)date;
+ (Api38_Update_updateEncryptedMessagesRead *)updateEncryptedMessagesReadWithChatId:(NSNumber *)chatId maxDate:(NSNumber *)maxDate date:(NSNumber *)date;
+ (Api38_Update_updateChatParticipantDelete *)updateChatParticipantDeleteWithChatId:(NSNumber *)chatId userId:(NSNumber *)userId version:(NSNumber *)version;
+ (Api38_Update_updateDcOptions *)updateDcOptionsWithDcOptions:(NSArray *)dcOptions;
+ (Api38_Update_updateUserBlocked *)updateUserBlockedWithUserId:(NSNumber *)userId blocked:(Api38_Bool *)blocked;
+ (Api38_Update_updateNotifySettings *)updateNotifySettingsWithPeer:(Api38_NotifyPeer *)peer notifySettings:(Api38_PeerNotifySettings *)notifySettings;
+ (Api38_Update_updateUserTyping *)updateUserTypingWithUserId:(NSNumber *)userId action:(Api38_SendMessageAction *)action;
+ (Api38_Update_updateChatUserTyping *)updateChatUserTypingWithChatId:(NSNumber *)chatId userId:(NSNumber *)userId action:(Api38_SendMessageAction *)action;
+ (Api38_Update_updateUserName *)updateUserNameWithUserId:(NSNumber *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username;
+ (Api38_Update_updateServiceNotification *)updateServiceNotificationWithType:(NSString *)type message:(NSString *)message media:(Api38_MessageMedia *)media popup:(Api38_Bool *)popup;
+ (Api38_Update_updatePrivacy *)updatePrivacyWithKey:(Api38_PrivacyKey *)key rules:(NSArray *)rules;
+ (Api38_Update_updateUserPhone *)updateUserPhoneWithUserId:(NSNumber *)userId phone:(NSString *)phone;
+ (Api38_Update_updateNewMessage *)updateNewMessageWithMessage:(Api38_Message *)message pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateReadMessages *)updateReadMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateDeleteMessages *)updateDeleteMessagesWithMessages:(NSArray *)messages pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateReadHistoryInbox *)updateReadHistoryInboxWithPeer:(Api38_Peer *)peer maxId:(NSNumber *)maxId pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateReadHistoryOutbox *)updateReadHistoryOutboxWithPeer:(Api38_Peer *)peer maxId:(NSNumber *)maxId pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateContactLink *)updateContactLinkWithUserId:(NSNumber *)userId myLink:(Api38_ContactLink *)myLink foreignLink:(Api38_ContactLink *)foreignLink;
+ (Api38_Update_updateReadMessagesContents *)updateReadMessagesContentsWithMessages:(NSArray *)messages pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateChatParticipantAdd *)updateChatParticipantAddWithChatId:(NSNumber *)chatId userId:(NSNumber *)userId inviterId:(NSNumber *)inviterId date:(NSNumber *)date version:(NSNumber *)version;
+ (Api38_Update_updateWebPage *)updateWebPageWithWebpage:(Api38_WebPage *)webpage pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateChannelTooLong *)updateChannelTooLongWithChannelId:(NSNumber *)channelId;
+ (Api38_Update_updateChannel *)updateChannelWithChannelId:(NSNumber *)channelId;
+ (Api38_Update_updateChannelGroup *)updateChannelGroupWithChannelId:(NSNumber *)channelId group:(Api38_MessageGroup *)group;
+ (Api38_Update_updateNewChannelMessage *)updateNewChannelMessageWithMessage:(Api38_Message *)message pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateReadChannelInbox *)updateReadChannelInboxWithChannelId:(NSNumber *)channelId maxId:(NSNumber *)maxId;
+ (Api38_Update_updateDeleteChannelMessages *)updateDeleteChannelMessagesWithChannelId:(NSNumber *)channelId messages:(NSArray *)messages pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;
+ (Api38_Update_updateChannelMessageViews *)updateChannelMessageViewsWithChannelId:(NSNumber *)channelId pid:(NSNumber *)pid views:(NSNumber *)views;

@end

@interface Api38_Update_updateMessageID : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * randomId;

@end

@interface Api38_Update_updateRestoreMessages : Api38_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;

@end

@interface Api38_Update_updateChatParticipants : Api38_Update

@property (nonatomic, strong, readonly) Api38_ChatParticipants * participants;

@end

@interface Api38_Update_updateUserStatus : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_UserStatus * status;

@end

@interface Api38_Update_updateContactRegistered : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_Update_updateContactLocated : Api38_Update

@property (nonatomic, strong, readonly) NSArray * contacts;

@end

@interface Api38_Update_updateActivation : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Api38_Update_updateNewAuthorization : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * authKeyId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * device;
@property (nonatomic, strong, readonly) NSString * location;

@end

@interface Api38_Update_updatePhoneCallRequested : Api38_Update

@property (nonatomic, strong, readonly) Api38_PhoneCall * phoneCall;

@end

@interface Api38_Update_updatePhoneCallConfirmed : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSData * aOrB;
@property (nonatomic, strong, readonly) Api38_PhoneConnection * connection;

@end

@interface Api38_Update_updatePhoneCallDeclined : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * pid;

@end

@interface Api38_Update_updateUserPhoto : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) Api38_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) Api38_Bool * previous;

@end

@interface Api38_Update_updateNewEncryptedMessage : Api38_Update

@property (nonatomic, strong, readonly) Api38_EncryptedMessage * message;
@property (nonatomic, strong, readonly) NSNumber * qts;

@end

@interface Api38_Update_updateEncryptedChatTyping : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * chatId;

@end

@interface Api38_Update_updateEncryption : Api38_Update

@property (nonatomic, strong, readonly) Api38_EncryptedChat * chat;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_Update_updateEncryptedMessagesRead : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * maxDate;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_Update_updateChatParticipantDelete : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_Update_updateDcOptions : Api38_Update

@property (nonatomic, strong, readonly) NSArray * dcOptions;

@end

@interface Api38_Update_updateUserBlocked : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_Bool * blocked;

@end

@interface Api38_Update_updateNotifySettings : Api38_Update

@property (nonatomic, strong, readonly) Api38_NotifyPeer * peer;
@property (nonatomic, strong, readonly) Api38_PeerNotifySettings * notifySettings;

@end

@interface Api38_Update_updateUserTyping : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_SendMessageAction * action;

@end

@interface Api38_Update_updateChatUserTyping : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_SendMessageAction * action;

@end

@interface Api38_Update_updateUserName : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSString * username;

@end

@interface Api38_Update_updateServiceNotification : Api38_Update

@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Api38_MessageMedia * media;
@property (nonatomic, strong, readonly) Api38_Bool * popup;

@end

@interface Api38_Update_updatePrivacy : Api38_Update

@property (nonatomic, strong, readonly) Api38_PrivacyKey * key;
@property (nonatomic, strong, readonly) NSArray * rules;

@end

@interface Api38_Update_updateUserPhone : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSString * phone;

@end

@interface Api38_Update_updateNewMessage : Api38_Update

@property (nonatomic, strong, readonly) Api38_Message * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateReadMessages : Api38_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateDeleteMessages : Api38_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateReadHistoryInbox : Api38_Update

@property (nonatomic, strong, readonly) Api38_Peer * peer;
@property (nonatomic, strong, readonly) NSNumber * maxId;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateReadHistoryOutbox : Api38_Update

@property (nonatomic, strong, readonly) Api38_Peer * peer;
@property (nonatomic, strong, readonly) NSNumber * maxId;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateContactLink : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_ContactLink * myLink;
@property (nonatomic, strong, readonly) Api38_ContactLink * foreignLink;

@end

@interface Api38_Update_updateReadMessagesContents : Api38_Update

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateChatParticipantAdd : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * inviterId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_Update_updateWebPage : Api38_Update

@property (nonatomic, strong, readonly) Api38_WebPage * webpage;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateChannelTooLong : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;

@end

@interface Api38_Update_updateChannel : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;

@end

@interface Api38_Update_updateChannelGroup : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) Api38_MessageGroup * group;

@end

@interface Api38_Update_updateNewChannelMessage : Api38_Update

@property (nonatomic, strong, readonly) Api38_Message * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateReadChannelInbox : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) NSNumber * maxId;

@end

@interface Api38_Update_updateDeleteChannelMessages : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

@end

@interface Api38_Update_updateChannelMessageViews : Api38_Update

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * views;

@end


@interface Api38_ChannelParticipant : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;

+ (Api38_ChannelParticipant_channelParticipant *)channelParticipantWithUserId:(NSNumber *)userId date:(NSNumber *)date;
+ (Api38_ChannelParticipant_channelParticipantSelf *)channelParticipantSelfWithUserId:(NSNumber *)userId inviterId:(NSNumber *)inviterId date:(NSNumber *)date;
+ (Api38_ChannelParticipant_channelParticipantModerator *)channelParticipantModeratorWithUserId:(NSNumber *)userId inviterId:(NSNumber *)inviterId date:(NSNumber *)date;
+ (Api38_ChannelParticipant_channelParticipantEditor *)channelParticipantEditorWithUserId:(NSNumber *)userId inviterId:(NSNumber *)inviterId date:(NSNumber *)date;
+ (Api38_ChannelParticipant_channelParticipantKicked *)channelParticipantKickedWithUserId:(NSNumber *)userId kickedBy:(NSNumber *)kickedBy date:(NSNumber *)date;
+ (Api38_ChannelParticipant_channelParticipantCreator *)channelParticipantCreatorWithUserId:(NSNumber *)userId;

@end

@interface Api38_ChannelParticipant_channelParticipant : Api38_ChannelParticipant

@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_ChannelParticipant_channelParticipantSelf : Api38_ChannelParticipant

@property (nonatomic, strong, readonly) NSNumber * inviterId;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_ChannelParticipant_channelParticipantModerator : Api38_ChannelParticipant

@property (nonatomic, strong, readonly) NSNumber * inviterId;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_ChannelParticipant_channelParticipantEditor : Api38_ChannelParticipant

@property (nonatomic, strong, readonly) NSNumber * inviterId;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_ChannelParticipant_channelParticipantKicked : Api38_ChannelParticipant

@property (nonatomic, strong, readonly) NSNumber * kickedBy;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_ChannelParticipant_channelParticipantCreator : Api38_ChannelParticipant

@end


@interface Api38_contacts_Blocked : NSObject

@property (nonatomic, strong, readonly) NSArray * blocked;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_Blocked_contacts_blocked *)contacts_blockedWithBlocked:(NSArray *)blocked users:(NSArray *)users;
+ (Api38_contacts_Blocked_contacts_blockedSlice *)contacts_blockedSliceWithCount:(NSNumber *)count blocked:(NSArray *)blocked users:(NSArray *)users;

@end

@interface Api38_contacts_Blocked_contacts_blocked : Api38_contacts_Blocked

@end

@interface Api38_contacts_Blocked_contacts_blockedSlice : Api38_contacts_Blocked

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface Api38_Error : NSObject

@property (nonatomic, strong, readonly) NSNumber * code;

+ (Api38_Error_error *)errorWithCode:(NSNumber *)code text:(NSString *)text;
+ (Api38_Error_richError *)richErrorWithCode:(NSNumber *)code type:(NSString *)type nDescription:(NSString *)nDescription debug:(NSString *)debug requestParams:(NSString *)requestParams;

@end

@interface Api38_Error_error : Api38_Error

@property (nonatomic, strong, readonly) NSString * text;

@end

@interface Api38_Error_richError : Api38_Error

@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSString * nDescription;
@property (nonatomic, strong, readonly) NSString * debug;
@property (nonatomic, strong, readonly) NSString * requestParams;

@end


@interface Api38_ContactLocated : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * distance;

+ (Api38_ContactLocated_contactLocated *)contactLocatedWithUserId:(NSNumber *)userId location:(Api38_GeoPoint *)location date:(NSNumber *)date distance:(NSNumber *)distance;
+ (Api38_ContactLocated_contactLocatedPreview *)contactLocatedPreviewWithPhash:(NSString *)phash hidden:(Api38_Bool *)hidden date:(NSNumber *)date distance:(NSNumber *)distance;

@end

@interface Api38_ContactLocated_contactLocated : Api38_ContactLocated

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_GeoPoint * location;

@end

@interface Api38_ContactLocated_contactLocatedPreview : Api38_ContactLocated

@property (nonatomic, strong, readonly) NSString * phash;
@property (nonatomic, strong, readonly) Api38_Bool * hidden;

@end


@interface Api38_KeyboardButton : NSObject

@property (nonatomic, strong, readonly) NSString * text;

+ (Api38_KeyboardButton_keyboardButton *)keyboardButtonWithText:(NSString *)text;

@end

@interface Api38_KeyboardButton_keyboardButton : Api38_KeyboardButton

@end


@interface Api38_ContactStatus : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_UserStatus * status;

+ (Api38_ContactStatus_contactStatus *)contactStatusWithUserId:(NSNumber *)userId status:(Api38_UserStatus *)status;

@end

@interface Api38_ContactStatus_contactStatus : Api38_ContactStatus

@end


@interface Api38_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Api38_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Api38_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Api38_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Api38_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Api38_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Api38_PhotoSize_photoSizeEmpty : Api38_PhotoSize

@end

@interface Api38_PhotoSize_photoSize : Api38_PhotoSize

@property (nonatomic, strong, readonly) Api38_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Api38_PhotoSize_photoCachedSize : Api38_PhotoSize

@property (nonatomic, strong, readonly) Api38_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Api38_messages_Stickers : NSObject

+ (Api38_messages_Stickers_messages_stickersNotModified *)messages_stickersNotModified;
+ (Api38_messages_Stickers_messages_stickers *)messages_stickersWithPhash:(NSString *)phash stickers:(NSArray *)stickers;

@end

@interface Api38_messages_Stickers_messages_stickersNotModified : Api38_messages_Stickers

@end

@interface Api38_messages_Stickers_messages_stickers : Api38_messages_Stickers

@property (nonatomic, strong, readonly) NSString * phash;
@property (nonatomic, strong, readonly) NSArray * stickers;

@end


@interface Api38_GlobalPrivacySettings : NSObject

@property (nonatomic, strong, readonly) Api38_Bool * noSuggestions;
@property (nonatomic, strong, readonly) Api38_Bool * hideContacts;
@property (nonatomic, strong, readonly) Api38_Bool * hideLocated;
@property (nonatomic, strong, readonly) Api38_Bool * hideLastVisit;

+ (Api38_GlobalPrivacySettings_globalPrivacySettings *)globalPrivacySettingsWithNoSuggestions:(Api38_Bool *)noSuggestions hideContacts:(Api38_Bool *)hideContacts hideLocated:(Api38_Bool *)hideLocated hideLastVisit:(Api38_Bool *)hideLastVisit;

@end

@interface Api38_GlobalPrivacySettings_globalPrivacySettings : Api38_GlobalPrivacySettings

@end


@interface Api38_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Api38_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Api38_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Api38_FileLocation_fileLocationUnavailable : Api38_FileLocation

@end

@interface Api38_FileLocation_fileLocation : Api38_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Api38_InputNotifyPeer : NSObject

+ (Api38_InputNotifyPeer_inputNotifyPeer *)inputNotifyPeerWithPeer:(Api38_InputPeer *)peer;
+ (Api38_InputNotifyPeer_inputNotifyUsers *)inputNotifyUsers;
+ (Api38_InputNotifyPeer_inputNotifyChats *)inputNotifyChats;
+ (Api38_InputNotifyPeer_inputNotifyAll *)inputNotifyAll;

@end

@interface Api38_InputNotifyPeer_inputNotifyPeer : Api38_InputNotifyPeer

@property (nonatomic, strong, readonly) Api38_InputPeer * peer;

@end

@interface Api38_InputNotifyPeer_inputNotifyUsers : Api38_InputNotifyPeer

@end

@interface Api38_InputNotifyPeer_inputNotifyChats : Api38_InputNotifyPeer

@end

@interface Api38_InputNotifyPeer_inputNotifyAll : Api38_InputNotifyPeer

@end


@interface Api38_EncryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;
@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (Api38_EncryptedMessage_encryptedMessage *)encryptedMessageWithRandomId:(NSNumber *)randomId chatId:(NSNumber *)chatId date:(NSNumber *)date bytes:(NSData *)bytes file:(Api38_EncryptedFile *)file;
+ (Api38_EncryptedMessage_encryptedMessageService *)encryptedMessageServiceWithRandomId:(NSNumber *)randomId chatId:(NSNumber *)chatId date:(NSNumber *)date bytes:(NSData *)bytes;

@end

@interface Api38_EncryptedMessage_encryptedMessage : Api38_EncryptedMessage

@property (nonatomic, strong, readonly) Api38_EncryptedFile * file;

@end

@interface Api38_EncryptedMessage_encryptedMessageService : Api38_EncryptedMessage

@end


@interface Api38_ChannelParticipantsFilter : NSObject

+ (Api38_ChannelParticipantsFilter_channelParticipantsRecent *)channelParticipantsRecent;
+ (Api38_ChannelParticipantsFilter_channelParticipantsAdmins *)channelParticipantsAdmins;
+ (Api38_ChannelParticipantsFilter_channelParticipantsKicked *)channelParticipantsKicked;

@end

@interface Api38_ChannelParticipantsFilter_channelParticipantsRecent : Api38_ChannelParticipantsFilter

@end

@interface Api38_ChannelParticipantsFilter_channelParticipantsAdmins : Api38_ChannelParticipantsFilter

@end

@interface Api38_ChannelParticipantsFilter_channelParticipantsKicked : Api38_ChannelParticipantsFilter

@end


@interface Api38_WebPage : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_WebPage_webPageEmpty *)webPageEmptyWithPid:(NSNumber *)pid;
+ (Api38_WebPage_webPagePending *)webPagePendingWithPid:(NSNumber *)pid date:(NSNumber *)date;
+ (Api38_WebPage_webPage *)webPageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type siteName:(NSString *)siteName title:(NSString *)title pdescription:(NSString *)pdescription photo:(Api38_Photo *)photo embedUrl:(NSString *)embedUrl embedType:(NSString *)embedType embedWidth:(NSNumber *)embedWidth embedHeight:(NSNumber *)embedHeight duration:(NSNumber *)duration author:(NSString *)author document:(Api38_Document *)document;

@end

@interface Api38_WebPage_webPageEmpty : Api38_WebPage

@end

@interface Api38_WebPage_webPagePending : Api38_WebPage

@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_WebPage_webPage : Api38_WebPage

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSString * url;
@property (nonatomic, strong, readonly) NSString * displayUrl;
@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSString * siteName;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * pdescription;
@property (nonatomic, strong, readonly) Api38_Photo * photo;
@property (nonatomic, strong, readonly) NSString * embedUrl;
@property (nonatomic, strong, readonly) NSString * embedType;
@property (nonatomic, strong, readonly) NSNumber * embedWidth;
@property (nonatomic, strong, readonly) NSNumber * embedHeight;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * author;
@property (nonatomic, strong, readonly) Api38_Document * document;

@end


@interface Api38_KeyboardButtonRow : NSObject

@property (nonatomic, strong, readonly) NSArray * buttons;

+ (Api38_KeyboardButtonRow_keyboardButtonRow *)keyboardButtonRowWithButtons:(NSArray *)buttons;

@end

@interface Api38_KeyboardButtonRow_keyboardButtonRow : Api38_KeyboardButtonRow

@end


@interface Api38_StickerSet : NSObject

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * shortName;
@property (nonatomic, strong, readonly) NSNumber * count;
@property (nonatomic, strong, readonly) NSNumber * nHash;

+ (Api38_StickerSet_stickerSet *)stickerSetWithFlags:(NSNumber *)flags pid:(NSNumber *)pid accessHash:(NSNumber *)accessHash title:(NSString *)title shortName:(NSString *)shortName count:(NSNumber *)count nHash:(NSNumber *)nHash;

@end

@interface Api38_StickerSet_stickerSet : Api38_StickerSet

@end


@interface Api38_photos_Photo : NSObject

@property (nonatomic, strong, readonly) Api38_Photo * photo;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_photos_Photo_photos_photo *)photos_photoWithPhoto:(Api38_Photo *)photo users:(NSArray *)users;

@end

@interface Api38_photos_Photo_photos_photo : Api38_photos_Photo

@end


@interface Api38_InputContact : NSObject

@property (nonatomic, strong, readonly) NSNumber * clientId;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;

+ (Api38_InputContact_inputPhoneContact *)inputPhoneContactWithClientId:(NSNumber *)clientId phone:(NSString *)phone firstName:(NSString *)firstName lastName:(NSString *)lastName;

@end

@interface Api38_InputContact_inputPhoneContact : Api38_InputContact

@end


@interface Api38_contacts_Contacts : NSObject

+ (Api38_contacts_Contacts_contacts_contacts *)contacts_contactsWithContacts:(NSArray *)contacts users:(NSArray *)users;
+ (Api38_contacts_Contacts_contacts_contactsNotModified *)contacts_contactsNotModified;

@end

@interface Api38_contacts_Contacts_contacts_contacts : Api38_contacts_Contacts

@property (nonatomic, strong, readonly) NSArray * contacts;
@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface Api38_contacts_Contacts_contacts_contactsNotModified : Api38_contacts_Contacts

@end


@interface Api38_ChannelMessagesFilter : NSObject

+ (Api38_ChannelMessagesFilter_channelMessagesFilterEmpty *)channelMessagesFilterEmpty;
+ (Api38_ChannelMessagesFilter_channelMessagesFilter *)channelMessagesFilterWithFlags:(NSNumber *)flags ranges:(NSArray *)ranges;
+ (Api38_ChannelMessagesFilter_channelMessagesFilterCollapsed *)channelMessagesFilterCollapsed;

@end

@interface Api38_ChannelMessagesFilter_channelMessagesFilterEmpty : Api38_ChannelMessagesFilter

@end

@interface Api38_ChannelMessagesFilter_channelMessagesFilter : Api38_ChannelMessagesFilter

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSArray * ranges;

@end

@interface Api38_ChannelMessagesFilter_channelMessagesFilterCollapsed : Api38_ChannelMessagesFilter

@end


@interface Api38_auth_PasswordRecovery : NSObject

@property (nonatomic, strong, readonly) NSString * emailPattern;

+ (Api38_auth_PasswordRecovery_auth_passwordRecovery *)auth_passwordRecoveryWithEmailPattern:(NSString *)emailPattern;

@end

@interface Api38_auth_PasswordRecovery_auth_passwordRecovery : Api38_auth_PasswordRecovery

@end


@interface Api38_InputDocument : NSObject

+ (Api38_InputDocument_inputDocumentEmpty *)inputDocumentEmpty;
+ (Api38_InputDocument_inputDocument *)inputDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputDocument_inputDocumentEmpty : Api38_InputDocument

@end

@interface Api38_InputDocument_inputDocument : Api38_InputDocument

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_contacts_ResolvedPeer : NSObject

@property (nonatomic, strong, readonly) Api38_Peer * peer;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_ResolvedPeer_contacts_resolvedPeer *)contacts_resolvedPeerWithPeer:(Api38_Peer *)peer chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_contacts_ResolvedPeer_contacts_resolvedPeer : Api38_contacts_ResolvedPeer

@end


@interface Api38_InputMedia : NSObject

+ (Api38_InputMedia_inputMediaEmpty *)inputMediaEmpty;
+ (Api38_InputMedia_inputMediaGeoPoint *)inputMediaGeoPointWithGeoPoint:(Api38_InputGeoPoint *)geoPoint;
+ (Api38_InputMedia_inputMediaContact *)inputMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (Api38_InputMedia_inputMediaAudio *)inputMediaAudioWithPid:(Api38_InputAudio *)pid;
+ (Api38_InputMedia_inputMediaDocument *)inputMediaDocumentWithPid:(Api38_InputDocument *)pid;
+ (Api38_InputMedia_inputMediaUploadedAudio *)inputMediaUploadedAudioWithFile:(Api38_InputFile *)file duration:(NSNumber *)duration mimeType:(NSString *)mimeType;
+ (Api38_InputMedia_inputMediaUploadedDocument *)inputMediaUploadedDocumentWithFile:(Api38_InputFile *)file mimeType:(NSString *)mimeType attributes:(NSArray *)attributes;
+ (Api38_InputMedia_inputMediaUploadedThumbDocument *)inputMediaUploadedThumbDocumentWithFile:(Api38_InputFile *)file thumb:(Api38_InputFile *)thumb mimeType:(NSString *)mimeType attributes:(NSArray *)attributes;
+ (Api38_InputMedia_inputMediaUploadedPhoto *)inputMediaUploadedPhotoWithFile:(Api38_InputFile *)file caption:(NSString *)caption;
+ (Api38_InputMedia_inputMediaPhoto *)inputMediaPhotoWithPid:(Api38_InputPhoto *)pid caption:(NSString *)caption;
+ (Api38_InputMedia_inputMediaVideo *)inputMediaVideoWithPid:(Api38_InputVideo *)pid caption:(NSString *)caption;
+ (Api38_InputMedia_inputMediaVenue *)inputMediaVenueWithGeoPoint:(Api38_InputGeoPoint *)geoPoint title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId;
+ (Api38_InputMedia_inputMediaUploadedVideo *)inputMediaUploadedVideoWithFile:(Api38_InputFile *)file duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mimeType:(NSString *)mimeType caption:(NSString *)caption;
+ (Api38_InputMedia_inputMediaUploadedThumbVideo *)inputMediaUploadedThumbVideoWithFile:(Api38_InputFile *)file thumb:(Api38_InputFile *)thumb duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h mimeType:(NSString *)mimeType caption:(NSString *)caption;

@end

@interface Api38_InputMedia_inputMediaEmpty : Api38_InputMedia

@end

@interface Api38_InputMedia_inputMediaGeoPoint : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputGeoPoint * geoPoint;

@end

@interface Api38_InputMedia_inputMediaContact : Api38_InputMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;

@end

@interface Api38_InputMedia_inputMediaAudio : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputAudio * pid;

@end

@interface Api38_InputMedia_inputMediaDocument : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputDocument * pid;

@end

@interface Api38_InputMedia_inputMediaUploadedAudio : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;

@end

@interface Api38_InputMedia_inputMediaUploadedDocument : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Api38_InputMedia_inputMediaUploadedThumbDocument : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) Api38_InputFile * thumb;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Api38_InputMedia_inputMediaUploadedPhoto : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_InputMedia_inputMediaPhoto : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputPhoto * pid;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_InputMedia_inputMediaVideo : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputVideo * pid;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_InputMedia_inputMediaVenue : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputGeoPoint * geoPoint;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * provider;
@property (nonatomic, strong, readonly) NSString * venueId;

@end

@interface Api38_InputMedia_inputMediaUploadedVideo : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_InputMedia_inputMediaUploadedThumbVideo : Api38_InputMedia

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) Api38_InputFile * thumb;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSString * caption;

@end


@interface Api38_InputPeer : NSObject

+ (Api38_InputPeer_inputPeerEmpty *)inputPeerEmpty;
+ (Api38_InputPeer_inputPeerSelf *)inputPeerSelf;
+ (Api38_InputPeer_inputPeerChat *)inputPeerChatWithChatId:(NSNumber *)chatId;
+ (Api38_InputPeer_inputPeerUser *)inputPeerUserWithUserId:(NSNumber *)userId accessHash:(NSNumber *)accessHash;
+ (Api38_InputPeer_inputPeerChannel *)inputPeerChannelWithChannelId:(NSNumber *)channelId accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputPeer_inputPeerEmpty : Api38_InputPeer

@end

@interface Api38_InputPeer_inputPeerSelf : Api38_InputPeer

@end

@interface Api38_InputPeer_inputPeerChat : Api38_InputPeer

@property (nonatomic, strong, readonly) NSNumber * chatId;

@end

@interface Api38_InputPeer_inputPeerUser : Api38_InputPeer

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputPeer_inputPeerChannel : Api38_InputPeer

@property (nonatomic, strong, readonly) NSNumber * channelId;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_Contact : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) Api38_Bool * mutual;

+ (Api38_Contact_contact *)contactWithUserId:(NSNumber *)userId mutual:(Api38_Bool *)mutual;

@end

@interface Api38_Contact_contact : Api38_Contact

@end


@interface Api38_messages_Chats : NSObject

@property (nonatomic, strong, readonly) NSArray * chats;

+ (Api38_messages_Chats_messages_chats *)messages_chatsWithChats:(NSArray *)chats;

@end

@interface Api38_messages_Chats_messages_chats : Api38_messages_Chats

@end


@interface Api38_contacts_MyLink : NSObject

+ (Api38_contacts_MyLink_contacts_myLinkEmpty *)contacts_myLinkEmpty;
+ (Api38_contacts_MyLink_contacts_myLinkRequested *)contacts_myLinkRequestedWithContact:(Api38_Bool *)contact;
+ (Api38_contacts_MyLink_contacts_myLinkContact *)contacts_myLinkContact;

@end

@interface Api38_contacts_MyLink_contacts_myLinkEmpty : Api38_contacts_MyLink

@end

@interface Api38_contacts_MyLink_contacts_myLinkRequested : Api38_contacts_MyLink

@property (nonatomic, strong, readonly) Api38_Bool * contact;

@end

@interface Api38_contacts_MyLink_contacts_myLinkContact : Api38_contacts_MyLink

@end


@interface Api38_InputPrivacyRule : NSObject

+ (Api38_InputPrivacyRule_inputPrivacyValueAllowContacts *)inputPrivacyValueAllowContacts;
+ (Api38_InputPrivacyRule_inputPrivacyValueAllowAll *)inputPrivacyValueAllowAll;
+ (Api38_InputPrivacyRule_inputPrivacyValueAllowUsers *)inputPrivacyValueAllowUsersWithUsers:(NSArray *)users;
+ (Api38_InputPrivacyRule_inputPrivacyValueDisallowContacts *)inputPrivacyValueDisallowContacts;
+ (Api38_InputPrivacyRule_inputPrivacyValueDisallowAll *)inputPrivacyValueDisallowAll;
+ (Api38_InputPrivacyRule_inputPrivacyValueDisallowUsers *)inputPrivacyValueDisallowUsersWithUsers:(NSArray *)users;

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueAllowContacts : Api38_InputPrivacyRule

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueAllowAll : Api38_InputPrivacyRule

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueAllowUsers : Api38_InputPrivacyRule

@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueDisallowContacts : Api38_InputPrivacyRule

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueDisallowAll : Api38_InputPrivacyRule

@end

@interface Api38_InputPrivacyRule_inputPrivacyValueDisallowUsers : Api38_InputPrivacyRule

@property (nonatomic, strong, readonly) NSArray * users;

@end


@interface Api38_messages_DhConfig : NSObject

@property (nonatomic, strong, readonly) NSData * random;

+ (Api38_messages_DhConfig_messages_dhConfigNotModified *)messages_dhConfigNotModifiedWithRandom:(NSData *)random;
+ (Api38_messages_DhConfig_messages_dhConfig *)messages_dhConfigWithG:(NSNumber *)g p:(NSData *)p version:(NSNumber *)version random:(NSData *)random;

@end

@interface Api38_messages_DhConfig_messages_dhConfigNotModified : Api38_messages_DhConfig

@end

@interface Api38_messages_DhConfig_messages_dhConfig : Api38_messages_DhConfig

@property (nonatomic, strong, readonly) NSNumber * g;
@property (nonatomic, strong, readonly) NSData * p;
@property (nonatomic, strong, readonly) NSNumber * version;

@end


@interface Api38_auth_ExportedAuthorization : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (Api38_auth_ExportedAuthorization_auth_exportedAuthorization *)auth_exportedAuthorizationWithPid:(NSNumber *)pid bytes:(NSData *)bytes;

@end

@interface Api38_auth_ExportedAuthorization_auth_exportedAuthorization : Api38_auth_ExportedAuthorization

@end


@interface Api38_ContactRequest : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (Api38_ContactRequest_contactRequest *)contactRequestWithUserId:(NSNumber *)userId date:(NSNumber *)date;

@end

@interface Api38_ContactRequest_contactRequest : Api38_ContactRequest

@end


@interface Api38_messages_AffectedHistory : NSObject

@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;
@property (nonatomic, strong, readonly) NSNumber * offset;

+ (Api38_messages_AffectedHistory_messages_affectedHistory *)messages_affectedHistoryWithPts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount offset:(NSNumber *)offset;

@end

@interface Api38_messages_AffectedHistory_messages_affectedHistory : Api38_messages_AffectedHistory

@end


@interface Api38_account_PasswordInputSettings : NSObject

+ (Api38_account_PasswordInputSettings_account_passwordInputSettings *)account_passwordInputSettings;

@end

@interface Api38_account_PasswordInputSettings_account_passwordInputSettings : Api38_account_PasswordInputSettings

@end


@interface Api38_messages_ChatFull : NSObject

@property (nonatomic, strong, readonly) Api38_ChatFull * fullChat;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_messages_ChatFull_messages_chatFull *)messages_chatFullWithFullChat:(Api38_ChatFull *)fullChat chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_messages_ChatFull_messages_chatFull : Api38_messages_ChatFull

@end


@interface Api38_contacts_ForeignLink : NSObject

+ (Api38_contacts_ForeignLink_contacts_foreignLinkUnknown *)contacts_foreignLinkUnknown;
+ (Api38_contacts_ForeignLink_contacts_foreignLinkRequested *)contacts_foreignLinkRequestedWithHasPhone:(Api38_Bool *)hasPhone;
+ (Api38_contacts_ForeignLink_contacts_foreignLinkMutual *)contacts_foreignLinkMutual;

@end

@interface Api38_contacts_ForeignLink_contacts_foreignLinkUnknown : Api38_contacts_ForeignLink

@end

@interface Api38_contacts_ForeignLink_contacts_foreignLinkRequested : Api38_contacts_ForeignLink

@property (nonatomic, strong, readonly) Api38_Bool * hasPhone;

@end

@interface Api38_contacts_ForeignLink_contacts_foreignLinkMutual : Api38_contacts_ForeignLink

@end


@interface Api38_InputEncryptedChat : NSObject

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

+ (Api38_InputEncryptedChat_inputEncryptedChat *)inputEncryptedChatWithChatId:(NSNumber *)chatId accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputEncryptedChat_inputEncryptedChat : Api38_InputEncryptedChat

@end


@interface Api38_DisabledFeature : NSObject

@property (nonatomic, strong, readonly) NSString * feature;
@property (nonatomic, strong, readonly) NSString * nDescription;

+ (Api38_DisabledFeature_disabledFeature *)disabledFeatureWithFeature:(NSString *)feature nDescription:(NSString *)nDescription;

@end

@interface Api38_DisabledFeature_disabledFeature : Api38_DisabledFeature

@end


@interface Api38_EncryptedFile : NSObject

+ (Api38_EncryptedFile_encryptedFileEmpty *)encryptedFileEmpty;
+ (Api38_EncryptedFile_encryptedFile *)encryptedFileWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash size:(NSNumber *)size dcId:(NSNumber *)dcId keyFingerprint:(NSNumber *)keyFingerprint;

@end

@interface Api38_EncryptedFile_encryptedFileEmpty : Api38_EncryptedFile

@end

@interface Api38_EncryptedFile_encryptedFile : Api38_EncryptedFile

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end


@interface Api38_NotifyPeer : NSObject

+ (Api38_NotifyPeer_notifyPeer *)notifyPeerWithPeer:(Api38_Peer *)peer;
+ (Api38_NotifyPeer_notifyUsers *)notifyUsers;
+ (Api38_NotifyPeer_notifyChats *)notifyChats;
+ (Api38_NotifyPeer_notifyAll *)notifyAll;

@end

@interface Api38_NotifyPeer_notifyPeer : Api38_NotifyPeer

@property (nonatomic, strong, readonly) Api38_Peer * peer;

@end

@interface Api38_NotifyPeer_notifyUsers : Api38_NotifyPeer

@end

@interface Api38_NotifyPeer_notifyChats : Api38_NotifyPeer

@end

@interface Api38_NotifyPeer_notifyAll : Api38_NotifyPeer

@end


@interface Api38_InputPrivacyKey : NSObject

+ (Api38_InputPrivacyKey_inputPrivacyKeyStatusTimestamp *)inputPrivacyKeyStatusTimestamp;

@end

@interface Api38_InputPrivacyKey_inputPrivacyKeyStatusTimestamp : Api38_InputPrivacyKey

@end


@interface Api38_ReplyMarkup : NSObject

@property (nonatomic, strong, readonly) NSNumber * flags;

+ (Api38_ReplyMarkup_replyKeyboardHide *)replyKeyboardHideWithFlags:(NSNumber *)flags;
+ (Api38_ReplyMarkup_replyKeyboardForceReply *)replyKeyboardForceReplyWithFlags:(NSNumber *)flags;
+ (Api38_ReplyMarkup_replyKeyboardMarkup *)replyKeyboardMarkupWithFlags:(NSNumber *)flags rows:(NSArray *)rows;

@end

@interface Api38_ReplyMarkup_replyKeyboardHide : Api38_ReplyMarkup

@end

@interface Api38_ReplyMarkup_replyKeyboardForceReply : Api38_ReplyMarkup

@end

@interface Api38_ReplyMarkup_replyKeyboardMarkup : Api38_ReplyMarkup

@property (nonatomic, strong, readonly) NSArray * rows;

@end


@interface Api38_contacts_Link : NSObject

@property (nonatomic, strong, readonly) Api38_ContactLink * myLink;
@property (nonatomic, strong, readonly) Api38_ContactLink * foreignLink;
@property (nonatomic, strong, readonly) Api38_User * user;

+ (Api38_contacts_Link_contacts_link *)contacts_linkWithMyLink:(Api38_ContactLink *)myLink foreignLink:(Api38_ContactLink *)foreignLink user:(Api38_User *)user;

@end

@interface Api38_contacts_Link_contacts_link : Api38_contacts_Link

@end


@interface Api38_ContactBlocked : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * date;

+ (Api38_ContactBlocked_contactBlocked *)contactBlockedWithUserId:(NSNumber *)userId date:(NSNumber *)date;

@end

@interface Api38_ContactBlocked_contactBlocked : Api38_ContactBlocked

@end


@interface Api38_auth_CheckedPhone : NSObject

@property (nonatomic, strong, readonly) Api38_Bool * phoneRegistered;

+ (Api38_auth_CheckedPhone_auth_checkedPhone *)auth_checkedPhoneWithPhoneRegistered:(Api38_Bool *)phoneRegistered;

@end

@interface Api38_auth_CheckedPhone_auth_checkedPhone : Api38_auth_CheckedPhone

@end


@interface Api38_InputUser : NSObject

+ (Api38_InputUser_inputUserEmpty *)inputUserEmpty;
+ (Api38_InputUser_inputUserSelf *)inputUserSelf;
+ (Api38_InputUser_inputUser *)inputUserWithUserId:(NSNumber *)userId accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputUser_inputUserEmpty : Api38_InputUser

@end

@interface Api38_InputUser_inputUserSelf : Api38_InputUser

@end

@interface Api38_InputUser_inputUser : Api38_InputUser

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_SchemeType : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * predicate;
@property (nonatomic, strong, readonly) NSArray * params;
@property (nonatomic, strong, readonly) NSString * type;

+ (Api38_SchemeType_schemeType *)schemeTypeWithPid:(NSNumber *)pid predicate:(NSString *)predicate params:(NSArray *)params type:(NSString *)type;

@end

@interface Api38_SchemeType_schemeType : Api38_SchemeType

@end


@interface Api38_upload_File : NSObject

@property (nonatomic, strong, readonly) Api38_storage_FileType * type;
@property (nonatomic, strong, readonly) NSNumber * mtime;
@property (nonatomic, strong, readonly) NSData * bytes;

+ (Api38_upload_File_upload_file *)upload_fileWithType:(Api38_storage_FileType *)type mtime:(NSNumber *)mtime bytes:(NSData *)bytes;

@end

@interface Api38_upload_File_upload_file : Api38_upload_File

@end


@interface Api38_InputVideo : NSObject

+ (Api38_InputVideo_inputVideoEmpty *)inputVideoEmpty;
+ (Api38_InputVideo_inputVideo *)inputVideoWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputVideo_inputVideoEmpty : Api38_InputVideo

@end

@interface Api38_InputVideo_inputVideo : Api38_InputVideo

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_MessageRange : NSObject

@property (nonatomic, strong, readonly) NSNumber * minId;
@property (nonatomic, strong, readonly) NSNumber * maxId;

+ (Api38_MessageRange_messageRange *)messageRangeWithMinId:(NSNumber *)minId maxId:(NSNumber *)maxId;

@end

@interface Api38_MessageRange_messageRange : Api38_MessageRange

@end


@interface Api38_Config : NSObject

@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * expires;
@property (nonatomic, strong, readonly) Api38_Bool * testMode;
@property (nonatomic, strong, readonly) NSNumber * thisDc;
@property (nonatomic, strong, readonly) NSArray * dcOptions;
@property (nonatomic, strong, readonly) NSNumber * chatSizeMax;
@property (nonatomic, strong, readonly) NSNumber * broadcastSizeMax;
@property (nonatomic, strong, readonly) NSNumber * forwardedCountMax;
@property (nonatomic, strong, readonly) NSNumber * onlineUpdatePeriodMs;
@property (nonatomic, strong, readonly) NSNumber * offlineBlurTimeoutMs;
@property (nonatomic, strong, readonly) NSNumber * offlineIdleTimeoutMs;
@property (nonatomic, strong, readonly) NSNumber * onlineCloudTimeoutMs;
@property (nonatomic, strong, readonly) NSNumber * notifyCloudDelayMs;
@property (nonatomic, strong, readonly) NSNumber * notifyDefaultDelayMs;
@property (nonatomic, strong, readonly) NSNumber * chatBigSize;
@property (nonatomic, strong, readonly) NSNumber * pushChatPeriodMs;
@property (nonatomic, strong, readonly) NSNumber * pushChatLimit;
@property (nonatomic, strong, readonly) NSArray * disabledFeatures;

+ (Api38_Config_config *)configWithDate:(NSNumber *)date expires:(NSNumber *)expires testMode:(Api38_Bool *)testMode thisDc:(NSNumber *)thisDc dcOptions:(NSArray *)dcOptions chatSizeMax:(NSNumber *)chatSizeMax broadcastSizeMax:(NSNumber *)broadcastSizeMax forwardedCountMax:(NSNumber *)forwardedCountMax onlineUpdatePeriodMs:(NSNumber *)onlineUpdatePeriodMs offlineBlurTimeoutMs:(NSNumber *)offlineBlurTimeoutMs offlineIdleTimeoutMs:(NSNumber *)offlineIdleTimeoutMs onlineCloudTimeoutMs:(NSNumber *)onlineCloudTimeoutMs notifyCloudDelayMs:(NSNumber *)notifyCloudDelayMs notifyDefaultDelayMs:(NSNumber *)notifyDefaultDelayMs chatBigSize:(NSNumber *)chatBigSize pushChatPeriodMs:(NSNumber *)pushChatPeriodMs pushChatLimit:(NSNumber *)pushChatLimit disabledFeatures:(NSArray *)disabledFeatures;

@end

@interface Api38_Config_config : Api38_Config

@end


@interface Api38_BotCommand : NSObject

@property (nonatomic, strong, readonly) NSString * command;
@property (nonatomic, strong, readonly) NSString * pdescription;

+ (Api38_BotCommand_botCommand *)botCommandWithCommand:(NSString *)command pdescription:(NSString *)pdescription;

@end

@interface Api38_BotCommand_botCommand : Api38_BotCommand

@end


@interface Api38_Audio : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Audio_audioEmpty *)audioEmptyWithPid:(NSNumber *)pid;
+ (Api38_Audio_audio *)audioWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date duration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size dcId:(NSNumber *)dcId;

@end

@interface Api38_Audio_audioEmpty : Api38_Audio

@end

@interface Api38_Audio_audio : Api38_Audio

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Api38_contacts_Located : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_Located_contacts_located *)contacts_locatedWithResults:(NSArray *)results users:(NSArray *)users;

@end

@interface Api38_contacts_Located_contacts_located : Api38_contacts_Located

@end


@interface Api38_messages_AffectedMessages : NSObject

@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;

+ (Api38_messages_AffectedMessages_messages_affectedMessages *)messages_affectedMessagesWithPts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount;

@end

@interface Api38_messages_AffectedMessages_messages_affectedMessages : Api38_messages_AffectedMessages

@end


@interface Api38_InputAudio : NSObject

+ (Api38_InputAudio_inputAudioEmpty *)inputAudioEmpty;
+ (Api38_InputAudio_inputAudio *)inputAudioWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputAudio_inputAudioEmpty : Api38_InputAudio

@end

@interface Api38_InputAudio_inputAudio : Api38_InputAudio

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_ResponseIndirect : NSObject

+ (Api38_ResponseIndirect_responseIndirect *)responseIndirect;

@end

@interface Api38_ResponseIndirect_responseIndirect : Api38_ResponseIndirect

@end


@interface Api38_WallPaper : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSNumber * color;

+ (Api38_WallPaper_wallPaper *)wallPaperWithPid:(NSNumber *)pid title:(NSString *)title sizes:(NSArray *)sizes color:(NSNumber *)color;
+ (Api38_WallPaper_wallPaperSolid *)wallPaperSolidWithPid:(NSNumber *)pid title:(NSString *)title bgColor:(NSNumber *)bgColor color:(NSNumber *)color;

@end

@interface Api38_WallPaper_wallPaper : Api38_WallPaper

@property (nonatomic, strong, readonly) NSArray * sizes;

@end

@interface Api38_WallPaper_wallPaperSolid : Api38_WallPaper

@property (nonatomic, strong, readonly) NSNumber * bgColor;

@end


@interface Api38_messages_Messages : NSObject

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_messages_Messages_messages_messages *)messages_messagesWithMessages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (Api38_messages_Messages_messages_messagesSlice *)messages_messagesSliceWithCount:(NSNumber *)count messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (Api38_messages_Messages_messages_channelMessages *)messages_channelMessagesWithFlags:(NSNumber *)flags pts:(NSNumber *)pts count:(NSNumber *)count messages:(NSArray *)messages collapsed:(NSArray *)collapsed chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_messages_Messages_messages_messages : Api38_messages_Messages

@end

@interface Api38_messages_Messages_messages_messagesSlice : Api38_messages_Messages

@property (nonatomic, strong, readonly) NSNumber * count;

@end

@interface Api38_messages_Messages_messages_channelMessages : Api38_messages_Messages

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * count;
@property (nonatomic, strong, readonly) NSArray * collapsed;

@end


@interface Api38_auth_SentCode : NSObject

@property (nonatomic, strong, readonly) Api38_Bool * phoneRegistered;

+ (Api38_auth_SentCode_auth_sentCodePreview *)auth_sentCodePreviewWithPhoneRegistered:(Api38_Bool *)phoneRegistered phoneCodeHash:(NSString *)phoneCodeHash phoneCodeTest:(NSString *)phoneCodeTest;
+ (Api38_auth_SentCode_auth_sentPassPhrase *)auth_sentPassPhraseWithPhoneRegistered:(Api38_Bool *)phoneRegistered;
+ (Api38_auth_SentCode_auth_sentCode *)auth_sentCodeWithPhoneRegistered:(Api38_Bool *)phoneRegistered phoneCodeHash:(NSString *)phoneCodeHash sendCallTimeout:(NSNumber *)sendCallTimeout isPassword:(Api38_Bool *)isPassword;
+ (Api38_auth_SentCode_auth_sentAppCode *)auth_sentAppCodeWithPhoneRegistered:(Api38_Bool *)phoneRegistered phoneCodeHash:(NSString *)phoneCodeHash sendCallTimeout:(NSNumber *)sendCallTimeout isPassword:(Api38_Bool *)isPassword;

@end

@interface Api38_auth_SentCode_auth_sentCodePreview : Api38_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phoneCodeHash;
@property (nonatomic, strong, readonly) NSString * phoneCodeTest;

@end

@interface Api38_auth_SentCode_auth_sentPassPhrase : Api38_auth_SentCode

@end

@interface Api38_auth_SentCode_auth_sentCode : Api38_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phoneCodeHash;
@property (nonatomic, strong, readonly) NSNumber * sendCallTimeout;
@property (nonatomic, strong, readonly) Api38_Bool * isPassword;

@end

@interface Api38_auth_SentCode_auth_sentAppCode : Api38_auth_SentCode

@property (nonatomic, strong, readonly) NSString * phoneCodeHash;
@property (nonatomic, strong, readonly) NSNumber * sendCallTimeout;
@property (nonatomic, strong, readonly) Api38_Bool * isPassword;

@end


@interface Api38_phone_DhConfig : NSObject

@property (nonatomic, strong, readonly) NSNumber * g;
@property (nonatomic, strong, readonly) NSString * p;
@property (nonatomic, strong, readonly) NSNumber * ringTimeout;
@property (nonatomic, strong, readonly) NSNumber * expires;

+ (Api38_phone_DhConfig_phone_dhConfig *)phone_dhConfigWithG:(NSNumber *)g p:(NSString *)p ringTimeout:(NSNumber *)ringTimeout expires:(NSNumber *)expires;

@end

@interface Api38_phone_DhConfig_phone_dhConfig : Api38_phone_DhConfig

@end


@interface Api38_InputChatPhoto : NSObject

+ (Api38_InputChatPhoto_inputChatPhotoEmpty *)inputChatPhotoEmpty;
+ (Api38_InputChatPhoto_inputChatUploadedPhoto *)inputChatUploadedPhotoWithFile:(Api38_InputFile *)file crop:(Api38_InputPhotoCrop *)crop;
+ (Api38_InputChatPhoto_inputChatPhoto *)inputChatPhotoWithPid:(Api38_InputPhoto *)pid crop:(Api38_InputPhotoCrop *)crop;

@end

@interface Api38_InputChatPhoto_inputChatPhotoEmpty : Api38_InputChatPhoto

@end

@interface Api38_InputChatPhoto_inputChatUploadedPhoto : Api38_InputChatPhoto

@property (nonatomic, strong, readonly) Api38_InputFile * file;
@property (nonatomic, strong, readonly) Api38_InputPhotoCrop * crop;

@end

@interface Api38_InputChatPhoto_inputChatPhoto : Api38_InputChatPhoto

@property (nonatomic, strong, readonly) Api38_InputPhoto * pid;
@property (nonatomic, strong, readonly) Api38_InputPhotoCrop * crop;

@end


@interface Api38_Updates : NSObject

+ (Api38_Updates_updatesTooLong *)updatesTooLong;
+ (Api38_Updates_updateShort *)updateShortWithUpdate:(Api38_Update *)update date:(NSNumber *)date;
+ (Api38_Updates_updatesCombined *)updatesCombinedWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seqStart:(NSNumber *)seqStart seq:(NSNumber *)seq;
+ (Api38_Updates_updates *)updatesWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats date:(NSNumber *)date seq:(NSNumber *)seq;
+ (Api38_Updates_updateShortSentMessage *)updateShortSentMessageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount date:(NSNumber *)date media:(Api38_MessageMedia *)media entities:(NSArray *)entities;
+ (Api38_Updates_updateShortMessage *)updateShortMessageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid userId:(NSNumber *)userId message:(NSString *)message pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount date:(NSNumber *)date fwdFromId:(Api38_Peer *)fwdFromId fwdDate:(NSNumber *)fwdDate replyToMsgId:(NSNumber *)replyToMsgId entities:(NSArray *)entities;
+ (Api38_Updates_updateShortChatMessage *)updateShortChatMessageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid fromId:(NSNumber *)fromId chatId:(NSNumber *)chatId message:(NSString *)message pts:(NSNumber *)pts ptsCount:(NSNumber *)ptsCount date:(NSNumber *)date fwdFromId:(Api38_Peer *)fwdFromId fwdDate:(NSNumber *)fwdDate replyToMsgId:(NSNumber *)replyToMsgId entities:(NSArray *)entities;

@end

@interface Api38_Updates_updatesTooLong : Api38_Updates

@end

@interface Api38_Updates_updateShort : Api38_Updates

@property (nonatomic, strong, readonly) Api38_Update * update;
@property (nonatomic, strong, readonly) NSNumber * date;

@end

@interface Api38_Updates_updatesCombined : Api38_Updates

@property (nonatomic, strong, readonly) NSArray * updates;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seqStart;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface Api38_Updates_updates : Api38_Updates

@property (nonatomic, strong, readonly) NSArray * updates;
@property (nonatomic, strong, readonly) NSArray * users;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;

@end

@interface Api38_Updates_updateShortSentMessage : Api38_Updates

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) Api38_MessageMedia * media;
@property (nonatomic, strong, readonly) NSArray * entities;

@end

@interface Api38_Updates_updateShortMessage : Api38_Updates

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) Api38_Peer * fwdFromId;
@property (nonatomic, strong, readonly) NSNumber * fwdDate;
@property (nonatomic, strong, readonly) NSNumber * replyToMsgId;
@property (nonatomic, strong, readonly) NSArray * entities;

@end

@interface Api38_Updates_updateShortChatMessage : Api38_Updates

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * fromId;
@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * ptsCount;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) Api38_Peer * fwdFromId;
@property (nonatomic, strong, readonly) NSNumber * fwdDate;
@property (nonatomic, strong, readonly) NSNumber * replyToMsgId;
@property (nonatomic, strong, readonly) NSArray * entities;

@end


@interface Api38_InitConnection : NSObject

@property (nonatomic, strong, readonly) NSNumber * apiId;
@property (nonatomic, strong, readonly) NSString * deviceModel;
@property (nonatomic, strong, readonly) NSString * systemVersion;
@property (nonatomic, strong, readonly) NSString * appVersion;
@property (nonatomic, strong, readonly) NSString * langCode;
@property (nonatomic, strong, readonly) NSObject * query;

+ (Api38_InitConnection_pinitConnection *)pinitConnectionWithApiId:(NSNumber *)apiId deviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion langCode:(NSString *)langCode query:(NSObject *)query;

@end

@interface Api38_InitConnection_pinitConnection : Api38_InitConnection

@end


@interface Api38_MessageMedia : NSObject

+ (Api38_MessageMedia_messageMediaEmpty *)messageMediaEmpty;
+ (Api38_MessageMedia_messageMediaGeo *)messageMediaGeoWithGeo:(Api38_GeoPoint *)geo;
+ (Api38_MessageMedia_messageMediaContact *)messageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Api38_MessageMedia_messageMediaDocument *)messageMediaDocumentWithDocument:(Api38_Document *)document;
+ (Api38_MessageMedia_messageMediaAudio *)messageMediaAudioWithAudio:(Api38_Audio *)audio;
+ (Api38_MessageMedia_messageMediaUnsupported *)messageMediaUnsupported;
+ (Api38_MessageMedia_messageMediaWebPage *)messageMediaWebPageWithWebpage:(Api38_WebPage *)webpage;
+ (Api38_MessageMedia_messageMediaPhoto *)messageMediaPhotoWithPhoto:(Api38_Photo *)photo caption:(NSString *)caption;
+ (Api38_MessageMedia_messageMediaVideo *)messageMediaVideoWithVideo:(Api38_Video *)video caption:(NSString *)caption;
+ (Api38_MessageMedia_messageMediaVenue *)messageMediaVenueWithGeo:(Api38_GeoPoint *)geo title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId;

@end

@interface Api38_MessageMedia_messageMediaEmpty : Api38_MessageMedia

@end

@interface Api38_MessageMedia_messageMediaGeo : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_GeoPoint * geo;

@end

@interface Api38_MessageMedia_messageMediaContact : Api38_MessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Api38_MessageMedia_messageMediaDocument : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_Document * document;

@end

@interface Api38_MessageMedia_messageMediaAudio : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_Audio * audio;

@end

@interface Api38_MessageMedia_messageMediaUnsupported : Api38_MessageMedia

@end

@interface Api38_MessageMedia_messageMediaWebPage : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_WebPage * webpage;

@end

@interface Api38_MessageMedia_messageMediaPhoto : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_Photo * photo;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_MessageMedia_messageMediaVideo : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_Video * video;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Api38_MessageMedia_messageMediaVenue : Api38_MessageMedia

@property (nonatomic, strong, readonly) Api38_GeoPoint * geo;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * provider;
@property (nonatomic, strong, readonly) NSString * venueId;

@end


@interface Api38_Null : NSObject

+ (Api38_Null_null *)null;

@end

@interface Api38_Null_null : Api38_Null

@end


@interface Api38_DocumentAttribute : NSObject

+ (Api38_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Api38_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Api38_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Api38_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;
+ (Api38_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Api38_InputStickerSet *)stickerset;
+ (Api38_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer;

@end

@interface Api38_DocumentAttribute_documentAttributeImageSize : Api38_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Api38_DocumentAttribute_documentAttributeAnimated : Api38_DocumentAttribute

@end

@interface Api38_DocumentAttribute_documentAttributeVideo : Api38_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Api38_DocumentAttribute_documentAttributeFilename : Api38_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end

@interface Api38_DocumentAttribute_documentAttributeSticker : Api38_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * alt;
@property (nonatomic, strong, readonly) Api38_InputStickerSet * stickerset;

@end

@interface Api38_DocumentAttribute_documentAttributeAudio : Api38_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * performer;

@end


@interface Api38_account_Authorizations : NSObject

@property (nonatomic, strong, readonly) NSArray * authorizations;

+ (Api38_account_Authorizations_account_authorizations *)account_authorizationsWithAuthorizations:(NSArray *)authorizations;

@end

@interface Api38_account_Authorizations_account_authorizations : Api38_account_Authorizations

@end


@interface Api38_ChatPhoto : NSObject

+ (Api38_ChatPhoto_chatPhotoEmpty *)chatPhotoEmpty;
+ (Api38_ChatPhoto_chatPhoto *)chatPhotoWithPhotoSmall:(Api38_FileLocation *)photoSmall photoBig:(Api38_FileLocation *)photoBig;

@end

@interface Api38_ChatPhoto_chatPhotoEmpty : Api38_ChatPhoto

@end

@interface Api38_ChatPhoto_chatPhoto : Api38_ChatPhoto

@property (nonatomic, strong, readonly) Api38_FileLocation * photoSmall;
@property (nonatomic, strong, readonly) Api38_FileLocation * photoBig;

@end


@interface Api38_InputStickerSet : NSObject

+ (Api38_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty;
+ (Api38_InputStickerSet_inputStickerSetID *)inputStickerSetIDWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;
+ (Api38_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName;

@end

@interface Api38_InputStickerSet_inputStickerSetEmpty : Api38_InputStickerSet

@end

@interface Api38_InputStickerSet_inputStickerSetID : Api38_InputStickerSet

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputStickerSet_inputStickerSetShortName : Api38_InputStickerSet

@property (nonatomic, strong, readonly) NSString * shortName;

@end


@interface Api38_BotInfo : NSObject

+ (Api38_BotInfo_botInfoEmpty *)botInfoEmpty;
+ (Api38_BotInfo_botInfo *)botInfoWithUserId:(NSNumber *)userId version:(NSNumber *)version shareText:(NSString *)shareText pdescription:(NSString *)pdescription commands:(NSArray *)commands;

@end

@interface Api38_BotInfo_botInfoEmpty : Api38_BotInfo

@end

@interface Api38_BotInfo_botInfo : Api38_BotInfo

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * version;
@property (nonatomic, strong, readonly) NSString * shareText;
@property (nonatomic, strong, readonly) NSString * pdescription;
@property (nonatomic, strong, readonly) NSArray * commands;

@end


@interface Api38_contacts_Suggested : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_Suggested_contacts_suggested *)contacts_suggestedWithResults:(NSArray *)results users:(NSArray *)users;

@end

@interface Api38_contacts_Suggested_contacts_suggested : Api38_contacts_Suggested

@end


@interface Api38_updates_State : NSObject

@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * qts;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * seq;
@property (nonatomic, strong, readonly) NSNumber * unreadCount;

+ (Api38_updates_State_updates_state *)updates_stateWithPts:(NSNumber *)pts qts:(NSNumber *)qts date:(NSNumber *)date seq:(NSNumber *)seq unreadCount:(NSNumber *)unreadCount;

@end

@interface Api38_updates_State_updates_state : Api38_updates_State

@end


@interface Api38_User : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_User_userEmpty *)userEmptyWithPid:(NSNumber *)pid;
+ (Api38_User_user *)userWithFlags:(NSNumber *)flags pid:(NSNumber *)pid accessHash:(NSNumber *)accessHash firstName:(NSString *)firstName lastName:(NSString *)lastName username:(NSString *)username phone:(NSString *)phone photo:(Api38_UserProfilePhoto *)photo status:(Api38_UserStatus *)status botInfoVersion:(NSNumber *)botInfoVersion;

@end

@interface Api38_User_userEmpty : Api38_User

@end

@interface Api38_User_user : Api38_User

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSString * username;
@property (nonatomic, strong, readonly) NSString * phone;
@property (nonatomic, strong, readonly) Api38_UserProfilePhoto * photo;
@property (nonatomic, strong, readonly) Api38_UserStatus * status;
@property (nonatomic, strong, readonly) NSNumber * botInfoVersion;

@end


@interface Api38_Message : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Message_messageEmpty *)messageEmptyWithPid:(NSNumber *)pid;
+ (Api38_Message_message *)messageWithFlags:(NSNumber *)flags pid:(NSNumber *)pid fromId:(NSNumber *)fromId toId:(Api38_Peer *)toId fwdFromId:(Api38_Peer *)fwdFromId fwdDate:(NSNumber *)fwdDate replyToMsgId:(NSNumber *)replyToMsgId date:(NSNumber *)date message:(NSString *)message media:(Api38_MessageMedia *)media replyMarkup:(Api38_ReplyMarkup *)replyMarkup entities:(NSArray *)entities views:(NSNumber *)views;
+ (Api38_Message_messageService *)messageServiceWithFlags:(NSNumber *)flags pid:(NSNumber *)pid fromId:(NSNumber *)fromId toId:(Api38_Peer *)toId date:(NSNumber *)date action:(Api38_MessageAction *)action;

@end

@interface Api38_Message_messageEmpty : Api38_Message

@end

@interface Api38_Message_message : Api38_Message

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * fromId;
@property (nonatomic, strong, readonly) Api38_Peer * toId;
@property (nonatomic, strong, readonly) Api38_Peer * fwdFromId;
@property (nonatomic, strong, readonly) NSNumber * fwdDate;
@property (nonatomic, strong, readonly) NSNumber * replyToMsgId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Api38_MessageMedia * media;
@property (nonatomic, strong, readonly) Api38_ReplyMarkup * replyMarkup;
@property (nonatomic, strong, readonly) NSArray * entities;
@property (nonatomic, strong, readonly) NSNumber * views;

@end

@interface Api38_Message_messageService : Api38_Message

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * fromId;
@property (nonatomic, strong, readonly) Api38_Peer * toId;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) Api38_MessageAction * action;

@end


@interface Api38_InputFileLocation : NSObject

+ (Api38_InputFileLocation_inputFileLocation *)inputFileLocationWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Api38_InputFileLocation_inputVideoFileLocation *)inputVideoFileLocationWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;
+ (Api38_InputFileLocation_inputEncryptedFileLocation *)inputEncryptedFileLocationWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;
+ (Api38_InputFileLocation_inputAudioFileLocation *)inputAudioFileLocationWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;
+ (Api38_InputFileLocation_inputDocumentFileLocation *)inputDocumentFileLocationWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputFileLocation_inputFileLocation : Api38_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

@end

@interface Api38_InputFileLocation_inputVideoFileLocation : Api38_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputFileLocation_inputEncryptedFileLocation : Api38_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputFileLocation_inputAudioFileLocation : Api38_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end

@interface Api38_InputFileLocation_inputDocumentFileLocation : Api38_InputFileLocation

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_GeoPoint : NSObject

+ (Api38_GeoPoint_geoPointEmpty *)geoPointEmpty;
+ (Api38_GeoPoint_geoPoint *)geoPointWithPlong:(NSNumber *)plong lat:(NSNumber *)lat;
+ (Api38_GeoPoint_geoPlace *)geoPlaceWithPlong:(NSNumber *)plong lat:(NSNumber *)lat name:(Api38_GeoPlaceName *)name;

@end

@interface Api38_GeoPoint_geoPointEmpty : Api38_GeoPoint

@end

@interface Api38_GeoPoint_geoPoint : Api38_GeoPoint

@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSNumber * lat;

@end

@interface Api38_GeoPoint_geoPlace : Api38_GeoPoint

@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) Api38_GeoPlaceName * name;

@end


@interface Api38_InputPhoneCall : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

+ (Api38_InputPhoneCall_inputPhoneCall *)inputPhoneCallWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputPhoneCall_inputPhoneCall : Api38_InputPhoneCall

@end


@interface Api38_ReceivedNotifyMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * flags;

+ (Api38_ReceivedNotifyMessage_receivedNotifyMessage *)receivedNotifyMessageWithPid:(NSNumber *)pid flags:(NSNumber *)flags;

@end

@interface Api38_ReceivedNotifyMessage_receivedNotifyMessage : Api38_ReceivedNotifyMessage

@end


@interface Api38_ChatParticipants : NSObject

@property (nonatomic, strong, readonly) NSNumber * chatId;

+ (Api38_ChatParticipants_chatParticipants *)chatParticipantsWithChatId:(NSNumber *)chatId adminId:(NSNumber *)adminId participants:(NSArray *)participants version:(NSNumber *)version;
+ (Api38_ChatParticipants_chatParticipantsForbidden *)chatParticipantsForbiddenWithFlags:(NSNumber *)flags chatId:(NSNumber *)chatId selfParticipant:(Api38_ChatParticipant *)selfParticipant;

@end

@interface Api38_ChatParticipants_chatParticipants : Api38_ChatParticipants

@property (nonatomic, strong, readonly) NSNumber * adminId;
@property (nonatomic, strong, readonly) NSArray * participants;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_ChatParticipants_chatParticipantsForbidden : Api38_ChatParticipants

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) Api38_ChatParticipant * selfParticipant;

@end


@interface Api38_NearestDc : NSObject

@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSNumber * thisDc;
@property (nonatomic, strong, readonly) NSNumber * nearestDc;

+ (Api38_NearestDc_nearestDc *)nearestDcWithCountry:(NSString *)country thisDc:(NSNumber *)thisDc nearestDc:(NSNumber *)nearestDc;

@end

@interface Api38_NearestDc_nearestDc : Api38_NearestDc

@end


@interface Api38_photos_Photos : NSObject

@property (nonatomic, strong, readonly) NSArray * photos;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_photos_Photos_photos_photos *)photos_photosWithPhotos:(NSArray *)photos users:(NSArray *)users;
+ (Api38_photos_Photos_photos_photosSlice *)photos_photosSliceWithCount:(NSNumber *)count photos:(NSArray *)photos users:(NSArray *)users;

@end

@interface Api38_photos_Photos_photos_photos : Api38_photos_Photos

@end

@interface Api38_photos_Photos_photos_photosSlice : Api38_photos_Photos

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface Api38_contacts_ImportedContacts : NSObject

@property (nonatomic, strong, readonly) NSArray * imported;
@property (nonatomic, strong, readonly) NSArray * retryContacts;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_ImportedContacts_contacts_importedContacts *)contacts_importedContactsWithImported:(NSArray *)imported retryContacts:(NSArray *)retryContacts users:(NSArray *)users;

@end

@interface Api38_contacts_ImportedContacts_contacts_importedContacts : Api38_contacts_ImportedContacts

@end


@interface Api38_Bool : NSObject

+ (Api38_Bool_boolFalse *)boolFalse;
+ (Api38_Bool_boolTrue *)boolTrue;

@end

@interface Api38_Bool_boolFalse : Api38_Bool

@end

@interface Api38_Bool_boolTrue : Api38_Bool

@end


@interface Api38_help_Support : NSObject

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) Api38_User * user;

+ (Api38_help_Support_help_support *)help_supportWithPhoneNumber:(NSString *)phoneNumber user:(Api38_User *)user;

@end

@interface Api38_help_Support_help_support : Api38_help_Support

@end


@interface Api38_ChatLocated : NSObject

@property (nonatomic, strong, readonly) NSNumber * chatId;
@property (nonatomic, strong, readonly) NSNumber * distance;

+ (Api38_ChatLocated_chatLocated *)chatLocatedWithChatId:(NSNumber *)chatId distance:(NSNumber *)distance;

@end

@interface Api38_ChatLocated_chatLocated : Api38_ChatLocated

@end


@interface Api38_MessagesFilter : NSObject

+ (Api38_MessagesFilter_inputMessagesFilterEmpty *)inputMessagesFilterEmpty;
+ (Api38_MessagesFilter_inputMessagesFilterPhotos *)inputMessagesFilterPhotos;
+ (Api38_MessagesFilter_inputMessagesFilterVideo *)inputMessagesFilterVideo;
+ (Api38_MessagesFilter_inputMessagesFilterPhotoVideo *)inputMessagesFilterPhotoVideo;
+ (Api38_MessagesFilter_inputMessagesFilterDocument *)inputMessagesFilterDocument;
+ (Api38_MessagesFilter_inputMessagesFilterAudio *)inputMessagesFilterAudio;
+ (Api38_MessagesFilter_inputMessagesFilterPhotoVideoDocuments *)inputMessagesFilterPhotoVideoDocuments;

@end

@interface Api38_MessagesFilter_inputMessagesFilterEmpty : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterPhotos : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterVideo : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterPhotoVideo : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterDocument : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterAudio : Api38_MessagesFilter

@end

@interface Api38_MessagesFilter_inputMessagesFilterPhotoVideoDocuments : Api38_MessagesFilter

@end


@interface Api38_messages_Dialogs : NSObject

@property (nonatomic, strong, readonly) NSArray * dialogs;
@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_messages_Dialogs_messages_dialogs *)messages_dialogsWithDialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (Api38_messages_Dialogs_messages_dialogsSlice *)messages_dialogsSliceWithCount:(NSNumber *)count dialogs:(NSArray *)dialogs messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_messages_Dialogs_messages_dialogs : Api38_messages_Dialogs

@end

@interface Api38_messages_Dialogs_messages_dialogsSlice : Api38_messages_Dialogs

@property (nonatomic, strong, readonly) NSNumber * count;

@end


@interface Api38_help_InviteText : NSObject

@property (nonatomic, strong, readonly) NSString * message;

+ (Api38_help_InviteText_help_inviteText *)help_inviteTextWithMessage:(NSString *)message;

@end

@interface Api38_help_InviteText_help_inviteText : Api38_help_InviteText

@end


@interface Api38_ContactSuggested : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * mutualContacts;

+ (Api38_ContactSuggested_contactSuggested *)contactSuggestedWithUserId:(NSNumber *)userId mutualContacts:(NSNumber *)mutualContacts;

@end

@interface Api38_ContactSuggested_contactSuggested : Api38_ContactSuggested

@end


@interface Api38_InputPeerNotifySettings : NSObject

@property (nonatomic, strong, readonly) NSNumber * muteUntil;
@property (nonatomic, strong, readonly) NSString * sound;
@property (nonatomic, strong, readonly) Api38_Bool * showPreviews;
@property (nonatomic, strong, readonly) NSNumber * eventsMask;

+ (Api38_InputPeerNotifySettings_inputPeerNotifySettings *)inputPeerNotifySettingsWithMuteUntil:(NSNumber *)muteUntil sound:(NSString *)sound showPreviews:(Api38_Bool *)showPreviews eventsMask:(NSNumber *)eventsMask;

@end

@interface Api38_InputPeerNotifySettings_inputPeerNotifySettings : Api38_InputPeerNotifySettings

@end


@interface Api38_ExportedChatInvite : NSObject

+ (Api38_ExportedChatInvite_chatInviteEmpty *)chatInviteEmpty;
+ (Api38_ExportedChatInvite_chatInviteExported *)chatInviteExportedWithLink:(NSString *)link;

@end

@interface Api38_ExportedChatInvite_chatInviteEmpty : Api38_ExportedChatInvite

@end

@interface Api38_ExportedChatInvite_chatInviteExported : Api38_ExportedChatInvite

@property (nonatomic, strong, readonly) NSString * link;

@end


@interface Api38_DcNetworkStats : NSObject

@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSString * ipAddress;
@property (nonatomic, strong, readonly) NSArray * pings;

+ (Api38_DcNetworkStats_dcPingStats *)dcPingStatsWithDcId:(NSNumber *)dcId ipAddress:(NSString *)ipAddress pings:(NSArray *)pings;

@end

@interface Api38_DcNetworkStats_dcPingStats : Api38_DcNetworkStats

@end


@interface Api38_Authorization : NSObject

@property (nonatomic, strong, readonly) NSNumber * phash;
@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSString * deviceModel;
@property (nonatomic, strong, readonly) NSString * platform;
@property (nonatomic, strong, readonly) NSString * systemVersion;
@property (nonatomic, strong, readonly) NSNumber * apiId;
@property (nonatomic, strong, readonly) NSString * appName;
@property (nonatomic, strong, readonly) NSString * appVersion;
@property (nonatomic, strong, readonly) NSNumber * dateCreated;
@property (nonatomic, strong, readonly) NSNumber * dateActive;
@property (nonatomic, strong, readonly) NSString * ip;
@property (nonatomic, strong, readonly) NSString * country;
@property (nonatomic, strong, readonly) NSString * region;

+ (Api38_Authorization_authorization *)authorizationWithPhash:(NSNumber *)phash flags:(NSNumber *)flags deviceModel:(NSString *)deviceModel platform:(NSString *)platform systemVersion:(NSString *)systemVersion apiId:(NSNumber *)apiId appName:(NSString *)appName appVersion:(NSString *)appVersion dateCreated:(NSNumber *)dateCreated dateActive:(NSNumber *)dateActive ip:(NSString *)ip country:(NSString *)country region:(NSString *)region;

@end

@interface Api38_Authorization_authorization : Api38_Authorization

@end


@interface Api38_messages_AllStickers : NSObject

+ (Api38_messages_AllStickers_messages_allStickersNotModified *)messages_allStickersNotModified;
+ (Api38_messages_AllStickers_messages_allStickers *)messages_allStickersWithPhash:(NSString *)phash sets:(NSArray *)sets;

@end

@interface Api38_messages_AllStickers_messages_allStickersNotModified : Api38_messages_AllStickers

@end

@interface Api38_messages_AllStickers_messages_allStickers : Api38_messages_AllStickers

@property (nonatomic, strong, readonly) NSString * phash;
@property (nonatomic, strong, readonly) NSArray * sets;

@end


@interface Api38_PhoneConnection : NSObject

+ (Api38_PhoneConnection_phoneConnectionNotReady *)phoneConnectionNotReady;
+ (Api38_PhoneConnection_phoneConnection *)phoneConnectionWithServer:(NSString *)server port:(NSNumber *)port streamId:(NSNumber *)streamId;

@end

@interface Api38_PhoneConnection_phoneConnectionNotReady : Api38_PhoneConnection

@end

@interface Api38_PhoneConnection_phoneConnection : Api38_PhoneConnection

@property (nonatomic, strong, readonly) NSString * server;
@property (nonatomic, strong, readonly) NSNumber * port;
@property (nonatomic, strong, readonly) NSNumber * streamId;

@end


@interface Api38_AccountDaysTTL : NSObject

@property (nonatomic, strong, readonly) NSNumber * days;

+ (Api38_AccountDaysTTL_accountDaysTTL *)accountDaysTTLWithDays:(NSNumber *)days;

@end

@interface Api38_AccountDaysTTL_accountDaysTTL : Api38_AccountDaysTTL

@end


@interface Api38_Scheme : NSObject

+ (Api38_Scheme_scheme *)schemeWithSchemeRaw:(NSString *)schemeRaw types:(NSArray *)types methods:(NSArray *)methods version:(NSNumber *)version;
+ (Api38_Scheme_schemeNotModified *)schemeNotModified;

@end

@interface Api38_Scheme_scheme : Api38_Scheme

@property (nonatomic, strong, readonly) NSString * schemeRaw;
@property (nonatomic, strong, readonly) NSArray * types;
@property (nonatomic, strong, readonly) NSArray * methods;
@property (nonatomic, strong, readonly) NSNumber * version;

@end

@interface Api38_Scheme_schemeNotModified : Api38_Scheme

@end


@interface Api38_account_Password : NSObject

@property (nonatomic, strong, readonly) NSData * pnewSalt;
@property (nonatomic, strong, readonly) NSString * emailUnconfirmedPattern;

+ (Api38_account_Password_account_noPassword *)account_noPasswordWithPnewSalt:(NSData *)pnewSalt emailUnconfirmedPattern:(NSString *)emailUnconfirmedPattern;
+ (Api38_account_Password_account_password *)account_passwordWithCurrentSalt:(NSData *)currentSalt pnewSalt:(NSData *)pnewSalt hint:(NSString *)hint hasRecovery:(Api38_Bool *)hasRecovery emailUnconfirmedPattern:(NSString *)emailUnconfirmedPattern;

@end

@interface Api38_account_Password_account_noPassword : Api38_account_Password

@end

@interface Api38_account_Password_account_password : Api38_account_Password

@property (nonatomic, strong, readonly) NSData * currentSalt;
@property (nonatomic, strong, readonly) NSString * hint;
@property (nonatomic, strong, readonly) Api38_Bool * hasRecovery;

@end


@interface Api38_account_PrivacyRules : NSObject

@property (nonatomic, strong, readonly) NSArray * rules;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_account_PrivacyRules_account_privacyRules *)account_privacyRulesWithRules:(NSArray *)rules users:(NSArray *)users;

@end

@interface Api38_account_PrivacyRules_account_privacyRules : Api38_account_PrivacyRules

@end


@interface Api38_messages_Message : NSObject

+ (Api38_messages_Message_messages_messageEmpty *)messages_messageEmpty;
+ (Api38_messages_Message_messages_message *)messages_messageWithMessage:(Api38_Message *)message chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_messages_Message_messages_messageEmpty : Api38_messages_Message

@end

@interface Api38_messages_Message_messages_message : Api38_messages_Message

@property (nonatomic, strong, readonly) Api38_Message * message;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

@end


@interface Api38_PrivacyRule : NSObject

+ (Api38_PrivacyRule_privacyValueAllowContacts *)privacyValueAllowContacts;
+ (Api38_PrivacyRule_privacyValueAllowAll *)privacyValueAllowAll;
+ (Api38_PrivacyRule_privacyValueAllowUsers *)privacyValueAllowUsersWithUsers:(NSArray *)users;
+ (Api38_PrivacyRule_privacyValueDisallowContacts *)privacyValueDisallowContacts;
+ (Api38_PrivacyRule_privacyValueDisallowAll *)privacyValueDisallowAll;
+ (Api38_PrivacyRule_privacyValueDisallowUsers *)privacyValueDisallowUsersWithUsers:(NSArray *)users;

@end

@interface Api38_PrivacyRule_privacyValueAllowContacts : Api38_PrivacyRule

@end

@interface Api38_PrivacyRule_privacyValueAllowAll : Api38_PrivacyRule

@end

@interface Api38_PrivacyRule_privacyValueAllowUsers : Api38_PrivacyRule

@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface Api38_PrivacyRule_privacyValueDisallowContacts : Api38_PrivacyRule

@end

@interface Api38_PrivacyRule_privacyValueDisallowAll : Api38_PrivacyRule

@end

@interface Api38_PrivacyRule_privacyValueDisallowUsers : Api38_PrivacyRule

@property (nonatomic, strong, readonly) NSArray * users;

@end


@interface Api38_account_SentChangePhoneCode : NSObject

@property (nonatomic, strong, readonly) NSString * phoneCodeHash;
@property (nonatomic, strong, readonly) NSNumber * sendCallTimeout;

+ (Api38_account_SentChangePhoneCode_account_sentChangePhoneCode *)account_sentChangePhoneCodeWithPhoneCodeHash:(NSString *)phoneCodeHash sendCallTimeout:(NSNumber *)sendCallTimeout;

@end

@interface Api38_account_SentChangePhoneCode_account_sentChangePhoneCode : Api38_account_SentChangePhoneCode

@end


@interface Api38_MessageAction : NSObject

+ (Api38_MessageAction_messageActionEmpty *)messageActionEmpty;
+ (Api38_MessageAction_messageActionChatCreate *)messageActionChatCreateWithTitle:(NSString *)title users:(NSArray *)users;
+ (Api38_MessageAction_messageActionChatEditTitle *)messageActionChatEditTitleWithTitle:(NSString *)title;
+ (Api38_MessageAction_messageActionChatEditPhoto *)messageActionChatEditPhotoWithPhoto:(Api38_Photo *)photo;
+ (Api38_MessageAction_messageActionChatDeletePhoto *)messageActionChatDeletePhoto;
+ (Api38_MessageAction_messageActionChatAddUser *)messageActionChatAddUserWithUserId:(NSNumber *)userId;
+ (Api38_MessageAction_messageActionChatDeleteUser *)messageActionChatDeleteUserWithUserId:(NSNumber *)userId;
+ (Api38_MessageAction_messageActionSentRequest *)messageActionSentRequestWithHasPhone:(Api38_Bool *)hasPhone;
+ (Api38_MessageAction_messageActionAcceptRequest *)messageActionAcceptRequest;
+ (Api38_MessageAction_messageActionChatJoinedByLink *)messageActionChatJoinedByLinkWithInviterId:(NSNumber *)inviterId;
+ (Api38_MessageAction_messageActionChannelCreate *)messageActionChannelCreateWithTitle:(NSString *)title;

@end

@interface Api38_MessageAction_messageActionEmpty : Api38_MessageAction

@end

@interface Api38_MessageAction_messageActionChatCreate : Api38_MessageAction

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface Api38_MessageAction_messageActionChatEditTitle : Api38_MessageAction

@property (nonatomic, strong, readonly) NSString * title;

@end

@interface Api38_MessageAction_messageActionChatEditPhoto : Api38_MessageAction

@property (nonatomic, strong, readonly) Api38_Photo * photo;

@end

@interface Api38_MessageAction_messageActionChatDeletePhoto : Api38_MessageAction

@end

@interface Api38_MessageAction_messageActionChatAddUser : Api38_MessageAction

@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Api38_MessageAction_messageActionChatDeleteUser : Api38_MessageAction

@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Api38_MessageAction_messageActionSentRequest : Api38_MessageAction

@property (nonatomic, strong, readonly) Api38_Bool * hasPhone;

@end

@interface Api38_MessageAction_messageActionAcceptRequest : Api38_MessageAction

@end

@interface Api38_MessageAction_messageActionChatJoinedByLink : Api38_MessageAction

@property (nonatomic, strong, readonly) NSNumber * inviterId;

@end

@interface Api38_MessageAction_messageActionChannelCreate : Api38_MessageAction

@property (nonatomic, strong, readonly) NSString * title;

@end


@interface Api38_PhoneCall : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_PhoneCall_phoneCallEmpty *)phoneCallEmptyWithPid:(NSNumber *)pid;
+ (Api38_PhoneCall_phoneCall *)phoneCallWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date userId:(NSNumber *)userId calleeId:(NSNumber *)calleeId;

@end

@interface Api38_PhoneCall_phoneCallEmpty : Api38_PhoneCall

@end

@interface Api38_PhoneCall_phoneCall : Api38_PhoneCall

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * calleeId;

@end


@interface Api38_PeerNotifyEvents : NSObject

+ (Api38_PeerNotifyEvents_peerNotifyEventsEmpty *)peerNotifyEventsEmpty;
+ (Api38_PeerNotifyEvents_peerNotifyEventsAll *)peerNotifyEventsAll;

@end

@interface Api38_PeerNotifyEvents_peerNotifyEventsEmpty : Api38_PeerNotifyEvents

@end

@interface Api38_PeerNotifyEvents_peerNotifyEventsAll : Api38_PeerNotifyEvents

@end


@interface Api38_ContactLink : NSObject

+ (Api38_ContactLink_contactLinkUnknown *)contactLinkUnknown;
+ (Api38_ContactLink_contactLinkNone *)contactLinkNone;
+ (Api38_ContactLink_contactLinkHasPhone *)contactLinkHasPhone;
+ (Api38_ContactLink_contactLinkContact *)contactLinkContact;

@end

@interface Api38_ContactLink_contactLinkUnknown : Api38_ContactLink

@end

@interface Api38_ContactLink_contactLinkNone : Api38_ContactLink

@end

@interface Api38_ContactLink_contactLinkHasPhone : Api38_ContactLink

@end

@interface Api38_ContactLink_contactLinkContact : Api38_ContactLink

@end


@interface Api38_help_AppPrefs : NSObject

@property (nonatomic, strong, readonly) NSData * bytes;

+ (Api38_help_AppPrefs_help_appPrefs *)help_appPrefsWithBytes:(NSData *)bytes;

@end

@interface Api38_help_AppPrefs_help_appPrefs : Api38_help_AppPrefs

@end


@interface Api38_contacts_Found : NSObject

@property (nonatomic, strong, readonly) NSArray * results;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

+ (Api38_contacts_Found_contacts_found *)contacts_foundWithResults:(NSArray *)results chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_contacts_Found_contacts_found : Api38_contacts_Found

@end


@interface Api38_PeerNotifySettings : NSObject

+ (Api38_PeerNotifySettings_peerNotifySettingsEmpty *)peerNotifySettingsEmpty;
+ (Api38_PeerNotifySettings_peerNotifySettings *)peerNotifySettingsWithMuteUntil:(NSNumber *)muteUntil sound:(NSString *)sound showPreviews:(Api38_Bool *)showPreviews eventsMask:(NSNumber *)eventsMask;

@end

@interface Api38_PeerNotifySettings_peerNotifySettingsEmpty : Api38_PeerNotifySettings

@end

@interface Api38_PeerNotifySettings_peerNotifySettings : Api38_PeerNotifySettings

@property (nonatomic, strong, readonly) NSNumber * muteUntil;
@property (nonatomic, strong, readonly) NSString * sound;
@property (nonatomic, strong, readonly) Api38_Bool * showPreviews;
@property (nonatomic, strong, readonly) NSNumber * eventsMask;

@end


@interface Api38_SchemeParam : NSObject

@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSString * type;

+ (Api38_SchemeParam_schemeParam *)schemeParamWithName:(NSString *)name type:(NSString *)type;

@end

@interface Api38_SchemeParam_schemeParam : Api38_SchemeParam

@end


@interface Api38_StickerPack : NSObject

@property (nonatomic, strong, readonly) NSString * emoticon;
@property (nonatomic, strong, readonly) NSArray * documents;

+ (Api38_StickerPack_stickerPack *)stickerPackWithEmoticon:(NSString *)emoticon documents:(NSArray *)documents;

@end

@interface Api38_StickerPack_stickerPack : Api38_StickerPack

@end


@interface Api38_UserProfilePhoto : NSObject

+ (Api38_UserProfilePhoto_userProfilePhotoEmpty *)userProfilePhotoEmpty;
+ (Api38_UserProfilePhoto_userProfilePhoto *)userProfilePhotoWithPhotoId:(NSNumber *)photoId photoSmall:(Api38_FileLocation *)photoSmall photoBig:(Api38_FileLocation *)photoBig;

@end

@interface Api38_UserProfilePhoto_userProfilePhotoEmpty : Api38_UserProfilePhoto

@end

@interface Api38_UserProfilePhoto_userProfilePhoto : Api38_UserProfilePhoto

@property (nonatomic, strong, readonly) NSNumber * photoId;
@property (nonatomic, strong, readonly) Api38_FileLocation * photoSmall;
@property (nonatomic, strong, readonly) Api38_FileLocation * photoBig;

@end


@interface Api38_updates_ChannelDifference : NSObject

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * pts;
@property (nonatomic, strong, readonly) NSNumber * timeout;

+ (Api38_updates_ChannelDifference_updates_channelDifferenceEmpty *)updates_channelDifferenceEmptyWithFlags:(NSNumber *)flags pts:(NSNumber *)pts timeout:(NSNumber *)timeout;
+ (Api38_updates_ChannelDifference_updates_channelDifferenceTooLong *)updates_channelDifferenceTooLongWithFlags:(NSNumber *)flags pts:(NSNumber *)pts timeout:(NSNumber *)timeout topMessage:(NSNumber *)topMessage topImportantMessage:(NSNumber *)topImportantMessage readInboxMaxId:(NSNumber *)readInboxMaxId unreadCount:(NSNumber *)unreadCount unreadImportantCount:(NSNumber *)unreadImportantCount messages:(NSArray *)messages chats:(NSArray *)chats users:(NSArray *)users;
+ (Api38_updates_ChannelDifference_updates_channelDifference *)updates_channelDifferenceWithFlags:(NSNumber *)flags pts:(NSNumber *)pts timeout:(NSNumber *)timeout pnewMessages:(NSArray *)pnewMessages otherUpdates:(NSArray *)otherUpdates chats:(NSArray *)chats users:(NSArray *)users;

@end

@interface Api38_updates_ChannelDifference_updates_channelDifferenceEmpty : Api38_updates_ChannelDifference

@end

@interface Api38_updates_ChannelDifference_updates_channelDifferenceTooLong : Api38_updates_ChannelDifference

@property (nonatomic, strong, readonly) NSNumber * topMessage;
@property (nonatomic, strong, readonly) NSNumber * topImportantMessage;
@property (nonatomic, strong, readonly) NSNumber * readInboxMaxId;
@property (nonatomic, strong, readonly) NSNumber * unreadCount;
@property (nonatomic, strong, readonly) NSNumber * unreadImportantCount;
@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

@end

@interface Api38_updates_ChannelDifference_updates_channelDifference : Api38_updates_ChannelDifference

@property (nonatomic, strong, readonly) NSArray * pnewMessages;
@property (nonatomic, strong, readonly) NSArray * otherUpdates;
@property (nonatomic, strong, readonly) NSArray * chats;
@property (nonatomic, strong, readonly) NSArray * users;

@end


@interface Api38_MessageEntity : NSObject

@property (nonatomic, strong, readonly) NSNumber * offset;
@property (nonatomic, strong, readonly) NSNumber * length;

+ (Api38_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Api38_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language;
+ (Api38_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url;

@end

@interface Api38_MessageEntity_messageEntityUnknown : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityMention : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityHashtag : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityBotCommand : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityUrl : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityEmail : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityBold : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityItalic : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityCode : Api38_MessageEntity

@end

@interface Api38_MessageEntity_messageEntityPre : Api38_MessageEntity

@property (nonatomic, strong, readonly) NSString * language;

@end

@interface Api38_MessageEntity_messageEntityTextUrl : Api38_MessageEntity

@property (nonatomic, strong, readonly) NSString * url;

@end


@interface Api38_InputPhoto : NSObject

+ (Api38_InputPhoto_inputPhotoEmpty *)inputPhotoEmpty;
+ (Api38_InputPhoto_inputPhoto *)inputPhotoWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash;

@end

@interface Api38_InputPhoto_inputPhotoEmpty : Api38_InputPhoto

@end

@interface Api38_InputPhoto_inputPhoto : Api38_InputPhoto

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;

@end


@interface Api38_Video : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Video_videoEmpty *)videoEmptyWithPid:(NSNumber *)pid;
+ (Api38_Video_video *)videoWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date duration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Api38_PhotoSize *)thumb dcId:(NSNumber *)dcId w:(NSNumber *)w h:(NSNumber *)h;

@end

@interface Api38_Video_videoEmpty : Api38_Video

@end

@interface Api38_Video_video : Api38_Video

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Api38_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end


@interface Api38_EncryptedChat : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_EncryptedChat_encryptedChatEmpty *)encryptedChatEmptyWithPid:(NSNumber *)pid;
+ (Api38_EncryptedChat_encryptedChatWaiting *)encryptedChatWaitingWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date adminId:(NSNumber *)adminId participantId:(NSNumber *)participantId;
+ (Api38_EncryptedChat_encryptedChatDiscarded *)encryptedChatDiscardedWithPid:(NSNumber *)pid;
+ (Api38_EncryptedChat_encryptedChatRequested *)encryptedChatRequestedWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date adminId:(NSNumber *)adminId participantId:(NSNumber *)participantId gA:(NSData *)gA;
+ (Api38_EncryptedChat_encryptedChat *)encryptedChatWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date adminId:(NSNumber *)adminId participantId:(NSNumber *)participantId gAOrB:(NSData *)gAOrB keyFingerprint:(NSNumber *)keyFingerprint;

@end

@interface Api38_EncryptedChat_encryptedChatEmpty : Api38_EncryptedChat

@end

@interface Api38_EncryptedChat_encryptedChatWaiting : Api38_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * adminId;
@property (nonatomic, strong, readonly) NSNumber * participantId;

@end

@interface Api38_EncryptedChat_encryptedChatDiscarded : Api38_EncryptedChat

@end

@interface Api38_EncryptedChat_encryptedChatRequested : Api38_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * adminId;
@property (nonatomic, strong, readonly) NSNumber * participantId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Api38_EncryptedChat_encryptedChat : Api38_EncryptedChat

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSNumber * adminId;
@property (nonatomic, strong, readonly) NSNumber * participantId;
@property (nonatomic, strong, readonly) NSData * gAOrB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end


@interface Api38_Document : NSObject

@property (nonatomic, strong, readonly) NSNumber * pid;

+ (Api38_Document_documentEmpty *)documentEmptyWithPid:(NSNumber *)pid;
+ (Api38_Document_document *)documentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Api38_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;

@end

@interface Api38_Document_documentEmpty : Api38_Document

@end

@interface Api38_Document_document : Api38_Document

@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Api38_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end


@interface Api38_ImportedContact : NSObject

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSNumber * clientId;

+ (Api38_ImportedContact_importedContact *)importedContactWithUserId:(NSNumber *)userId clientId:(NSNumber *)clientId;

@end

@interface Api38_ImportedContact_importedContact : Api38_ImportedContact

@end


/*
 * Functions 38
 */

@interface Api38: NSObject

+ (Api38_FunctionContext *)messages_getMessagesWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)messages_deleteHistoryWithPeer:(Api38_InputPeer *)peer offset:(NSNumber *)offset;
+ (Api38_FunctionContext *)messages_restoreMessagesWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)messages_getChatsWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)messages_getFullChatWithChatId:(NSNumber *)chatId;
+ (Api38_FunctionContext *)messages_getDhConfigWithVersion:(NSNumber *)version randomLength:(NSNumber *)randomLength;
+ (Api38_FunctionContext *)messages_requestEncryptionWithUserId:(Api38_InputUser *)userId randomId:(NSNumber *)randomId gA:(NSData *)gA;
+ (Api38_FunctionContext *)messages_acceptEncryptionWithPeer:(Api38_InputEncryptedChat *)peer gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Api38_FunctionContext *)messages_discardEncryptionWithChatId:(NSNumber *)chatId;
+ (Api38_FunctionContext *)messages_setEncryptedTypingWithPeer:(Api38_InputEncryptedChat *)peer typing:(Api38_Bool *)typing;
+ (Api38_FunctionContext *)messages_readEncryptedHistoryWithPeer:(Api38_InputEncryptedChat *)peer maxDate:(NSNumber *)maxDate;
+ (Api38_FunctionContext *)messages_sendEncryptedWithPeer:(Api38_InputEncryptedChat *)peer randomId:(NSNumber *)randomId data:(NSData *)data;
+ (Api38_FunctionContext *)messages_sendEncryptedFileWithPeer:(Api38_InputEncryptedChat *)peer randomId:(NSNumber *)randomId data:(NSData *)data file:(Api38_InputEncryptedFile *)file;
+ (Api38_FunctionContext *)messages_sendEncryptedServiceWithPeer:(Api38_InputEncryptedChat *)peer randomId:(NSNumber *)randomId data:(NSData *)data;
+ (Api38_FunctionContext *)messages_receivedQueueWithMaxQts:(NSNumber *)maxQts;
+ (Api38_FunctionContext *)messages_setTypingWithPeer:(Api38_InputPeer *)peer action:(Api38_SendMessageAction *)action;
+ (Api38_FunctionContext *)messages_getStickersWithEmoticon:(NSString *)emoticon phash:(NSString *)phash;
+ (Api38_FunctionContext *)messages_getAllStickersWithPhash:(NSString *)phash;
+ (Api38_FunctionContext *)messages_readHistoryWithPeer:(Api38_InputPeer *)peer maxId:(NSNumber *)maxId offset:(NSNumber *)offset;
+ (Api38_FunctionContext *)messages_deleteMessagesWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)messages_readMessageContentsWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)messages_editChatTitleWithChatId:(NSNumber *)chatId title:(NSString *)title;
+ (Api38_FunctionContext *)messages_editChatPhotoWithChatId:(NSNumber *)chatId photo:(Api38_InputChatPhoto *)photo;
+ (Api38_FunctionContext *)messages_addChatUserWithChatId:(NSNumber *)chatId userId:(Api38_InputUser *)userId fwdLimit:(NSNumber *)fwdLimit;
+ (Api38_FunctionContext *)messages_deleteChatUserWithChatId:(NSNumber *)chatId userId:(Api38_InputUser *)userId;
+ (Api38_FunctionContext *)messages_createChatWithUsers:(NSArray *)users title:(NSString *)title;
+ (Api38_FunctionContext *)messages_sendBroadcastWithContacts:(NSArray *)contacts randomId:(NSArray *)randomId message:(NSString *)message media:(Api38_InputMedia *)media;
+ (Api38_FunctionContext *)messages_getWebPagePreviewWithMessage:(NSString *)message;
+ (Api38_FunctionContext *)messages_forwardMessageWithPeer:(Api38_InputPeer *)peer pid:(NSNumber *)pid randomId:(NSNumber *)randomId;
+ (Api38_FunctionContext *)messages_receivedMessagesWithMaxId:(NSNumber *)maxId;
+ (Api38_FunctionContext *)messages_exportChatInviteWithChatId:(NSNumber *)chatId;
+ (Api38_FunctionContext *)messages_checkChatInviteWithPhash:(NSString *)phash;
+ (Api38_FunctionContext *)messages_importChatInviteWithPhash:(NSString *)phash;
+ (Api38_FunctionContext *)messages_getStickerSetWithStickerset:(Api38_InputStickerSet *)stickerset;
+ (Api38_FunctionContext *)messages_uninstallStickerSetWithStickerset:(Api38_InputStickerSet *)stickerset;
+ (Api38_FunctionContext *)messages_sendMediaWithFlags:(NSNumber *)flags peer:(Api38_InputPeer *)peer replyToMsgId:(NSNumber *)replyToMsgId media:(Api38_InputMedia *)media randomId:(NSNumber *)randomId replyMarkup:(Api38_ReplyMarkup *)replyMarkup;
+ (Api38_FunctionContext *)messages_installStickerSetWithStickerset:(Api38_InputStickerSet *)stickerset disabled:(Api38_Bool *)disabled;
+ (Api38_FunctionContext *)messages_sendMessageWithFlags:(NSNumber *)flags peer:(Api38_InputPeer *)peer replyToMsgId:(NSNumber *)replyToMsgId message:(NSString *)message randomId:(NSNumber *)randomId replyMarkup:(Api38_ReplyMarkup *)replyMarkup entities:(NSArray *)entities;
+ (Api38_FunctionContext *)messages_getDialogsWithOffset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)messages_getHistoryWithPeer:(Api38_InputPeer *)peer offsetId:(NSNumber *)offsetId addOffset:(NSNumber *)addOffset limit:(NSNumber *)limit maxId:(NSNumber *)maxId minId:(NSNumber *)minId;
+ (Api38_FunctionContext *)messages_searchWithFlags:(NSNumber *)flags peer:(Api38_InputPeer *)peer q:(NSString *)q filter:(Api38_MessagesFilter *)filter minDate:(NSNumber *)minDate maxDate:(NSNumber *)maxDate offset:(NSNumber *)offset maxId:(NSNumber *)maxId limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)messages_forwardMessagesWithFlags:(NSNumber *)flags fromPeer:(Api38_InputPeer *)fromPeer pid:(NSArray *)pid randomId:(NSArray *)randomId toPeer:(Api38_InputPeer *)toPeer;
+ (Api38_FunctionContext *)messages_getMessagesViewsWithPeer:(Api38_InputPeer *)peer pid:(NSArray *)pid increment:(Api38_Bool *)increment;
+ (Api38_FunctionContext *)channels_getDialogsWithOffset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)channels_getImportantHistoryWithChannel:(Api38_InputChannel *)channel offsetId:(NSNumber *)offsetId addOffset:(NSNumber *)addOffset limit:(NSNumber *)limit maxId:(NSNumber *)maxId minId:(NSNumber *)minId;
+ (Api38_FunctionContext *)channels_readHistoryWithChannel:(Api38_InputChannel *)channel maxId:(NSNumber *)maxId;
+ (Api38_FunctionContext *)channels_deleteMessagesWithChannel:(Api38_InputChannel *)channel pid:(NSArray *)pid;
+ (Api38_FunctionContext *)channels_deleteUserHistoryWithChannel:(Api38_InputChannel *)channel userId:(Api38_InputUser *)userId;
+ (Api38_FunctionContext *)channels_reportSpamWithChannel:(Api38_InputChannel *)channel userId:(Api38_InputUser *)userId pid:(NSArray *)pid;
+ (Api38_FunctionContext *)channels_getMessagesWithChannel:(Api38_InputChannel *)channel pid:(NSArray *)pid;
+ (Api38_FunctionContext *)channels_getParticipantsWithChannel:(Api38_InputChannel *)channel filter:(Api38_ChannelParticipantsFilter *)filter offset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)channels_getParticipantWithChannel:(Api38_InputChannel *)channel userId:(Api38_InputUser *)userId;
+ (Api38_FunctionContext *)channels_getChannelsWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)channels_getFullChannelWithChannel:(Api38_InputChannel *)channel;
+ (Api38_FunctionContext *)channels_createChannelWithFlags:(NSNumber *)flags title:(NSString *)title about:(NSString *)about users:(NSArray *)users;
+ (Api38_FunctionContext *)channels_editAboutWithChannel:(Api38_InputChannel *)channel about:(NSString *)about;
+ (Api38_FunctionContext *)channels_editAdminWithChannel:(Api38_InputChannel *)channel userId:(Api38_InputUser *)userId role:(Api38_ChannelParticipantRole *)role;
+ (Api38_FunctionContext *)channels_editTitleWithChannel:(Api38_InputChannel *)channel title:(NSString *)title;
+ (Api38_FunctionContext *)channels_editPhotoWithChannel:(Api38_InputChannel *)channel photo:(Api38_InputChatPhoto *)photo;
+ (Api38_FunctionContext *)channels_toggleCommentsWithChannel:(Api38_InputChannel *)channel enabled:(Api38_Bool *)enabled;
+ (Api38_FunctionContext *)channels_checkUsernameWithChannel:(Api38_InputChannel *)channel username:(NSString *)username;
+ (Api38_FunctionContext *)channels_updateUsernameWithChannel:(Api38_InputChannel *)channel username:(NSString *)username;
+ (Api38_FunctionContext *)channels_joinChannelWithChannel:(Api38_InputChannel *)channel;
+ (Api38_FunctionContext *)channels_leaveChannelWithChannel:(Api38_InputChannel *)channel;
+ (Api38_FunctionContext *)channels_inviteToChannelWithChannel:(Api38_InputChannel *)channel users:(NSArray *)users;
+ (Api38_FunctionContext *)channels_kickFromChannelWithChannel:(Api38_InputChannel *)channel userId:(Api38_InputUser *)userId kicked:(Api38_Bool *)kicked;
+ (Api38_FunctionContext *)channels_exportInviteWithChannel:(Api38_InputChannel *)channel;
+ (Api38_FunctionContext *)channels_deleteChannelWithChannel:(Api38_InputChannel *)channel;
+ (Api38_FunctionContext *)auth_checkPhoneWithPhoneNumber:(NSString *)phoneNumber;
+ (Api38_FunctionContext *)auth_sendCallWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash;
+ (Api38_FunctionContext *)auth_signUpWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode firstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (Api38_FunctionContext *)auth_signInWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode;
+ (Api38_FunctionContext *)auth_logOut;
+ (Api38_FunctionContext *)auth_resetAuthorizations;
+ (Api38_FunctionContext *)auth_sendInvitesWithPhoneNumbers:(NSArray *)phoneNumbers message:(NSString *)message;
+ (Api38_FunctionContext *)auth_exportAuthorizationWithDcId:(NSNumber *)dcId;
+ (Api38_FunctionContext *)auth_importAuthorizationWithPid:(NSNumber *)pid bytes:(NSData *)bytes;
+ (Api38_FunctionContext *)auth_sendCodeWithPhoneNumber:(NSString *)phoneNumber smsType:(NSNumber *)smsType apiId:(NSNumber *)apiId apiHash:(NSString *)apiHash langCode:(NSString *)langCode;
+ (Api38_FunctionContext *)auth_sendSmsWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash;
+ (Api38_FunctionContext *)auth_resetAccountPasswordWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (Api38_FunctionContext *)auth_checkPasswordWithPasswordHash:(NSData *)passwordHash;
+ (Api38_FunctionContext *)auth_requestPasswordRecovery;
+ (Api38_FunctionContext *)auth_recoverPasswordWithCode:(NSString *)code;
+ (Api38_FunctionContext *)geo_saveGeoPlaceWithGeoPoint:(Api38_InputGeoPoint *)geoPoint langCode:(NSString *)langCode placeName:(Api38_InputGeoPlaceName *)placeName;
+ (Api38_FunctionContext *)users_getUsersWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)users_getFullUserWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_getContactIDs;
+ (Api38_FunctionContext *)contacts_getStatuses;
+ (Api38_FunctionContext *)contacts_getContactsWithNHash:(NSString *)nHash;
+ (Api38_FunctionContext *)contacts_getRequestsWithOffset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)contacts_getLinkWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_importContactsWithContacts:(NSArray *)contacts replace:(Api38_Bool *)replace;
+ (Api38_FunctionContext *)contacts_getLocatedWithGeoPoint:(Api38_InputGeoPoint *)geoPoint hidden:(Api38_Bool *)hidden radius:(NSNumber *)radius limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)contacts_getSuggestedWithLimit:(NSNumber *)limit;
+ (Api38_FunctionContext *)contacts_sendRequestWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_acceptRequestWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_declineRequestWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_deleteContactWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_clearContactWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_deleteContactsWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)contacts_blockWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_unblockWithPid:(Api38_InputUser *)pid;
+ (Api38_FunctionContext *)contacts_getBlockedWithOffset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)contacts_searchWithQ:(NSString *)q limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)contacts_resolveUsernameWithUsername:(NSString *)username;
+ (Api38_FunctionContext *)contest_saveDeveloperInfoWithVkId:(NSNumber *)vkId name:(NSString *)name phoneNumber:(NSString *)phoneNumber age:(NSNumber *)age city:(NSString *)city;
+ (Api38_FunctionContext *)help_getConfig;
+ (Api38_FunctionContext *)help_getNearestDc;
+ (Api38_FunctionContext *)help_getSchemeWithVersion:(NSNumber *)version;
+ (Api38_FunctionContext *)help_getAppUpdateWithDeviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion langCode:(NSString *)langCode;
+ (Api38_FunctionContext *)help_getInviteTextWithLangCode:(NSString *)langCode;
+ (Api38_FunctionContext *)help_getAppPrefsWithApiId:(NSNumber *)apiId apiHash:(NSString *)apiHash;
+ (Api38_FunctionContext *)help_saveNetworkStatsWithStats:(NSArray *)stats;
+ (Api38_FunctionContext *)help_test;
+ (Api38_FunctionContext *)help_getSupport;
+ (Api38_FunctionContext *)help_getAppChangelogWithDeviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion langCode:(NSString *)langCode;
+ (Api38_FunctionContext *)updates_getState;
+ (Api38_FunctionContext *)updates_subscribeWithUsers:(NSArray *)users;
+ (Api38_FunctionContext *)updates_unsubscribeWithUsers:(NSArray *)users;
+ (Api38_FunctionContext *)updates_getDifferenceWithPts:(NSNumber *)pts date:(NSNumber *)date qts:(NSNumber *)qts;
+ (Api38_FunctionContext *)updates_getChannelDifferenceWithChannel:(Api38_InputChannel *)channel filter:(Api38_ChannelMessagesFilter *)filter pts:(NSNumber *)pts limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)upload_saveFilePartWithFileId:(NSNumber *)fileId filePart:(NSNumber *)filePart bytes:(NSData *)bytes;
+ (Api38_FunctionContext *)upload_getFileWithLocation:(Api38_InputFileLocation *)location offset:(NSNumber *)offset limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)upload_saveBigFilePartWithFileId:(NSNumber *)fileId filePart:(NSNumber *)filePart fileTotalParts:(NSNumber *)fileTotalParts bytes:(NSData *)bytes;
+ (Api38_FunctionContext *)account_unregisterDeviceWithTokenType:(NSNumber *)tokenType token:(NSString *)token;
+ (Api38_FunctionContext *)account_updateNotifySettingsWithPeer:(Api38_InputNotifyPeer *)peer settings:(Api38_InputPeerNotifySettings *)settings;
+ (Api38_FunctionContext *)account_getNotifySettingsWithPeer:(Api38_InputNotifyPeer *)peer;
+ (Api38_FunctionContext *)account_resetNotifySettings;
+ (Api38_FunctionContext *)account_updateProfileWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (Api38_FunctionContext *)account_updateStatusWithOffline:(Api38_Bool *)offline;
+ (Api38_FunctionContext *)account_getWallPapers;
+ (Api38_FunctionContext *)account_registerDeviceWithTokenType:(NSNumber *)tokenType token:(NSString *)token deviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion appSandbox:(Api38_Bool *)appSandbox langCode:(NSString *)langCode;
+ (Api38_FunctionContext *)account_checkUsernameWithUsername:(NSString *)username;
+ (Api38_FunctionContext *)account_updateUsernameWithUsername:(NSString *)username;
+ (Api38_FunctionContext *)account_getPrivacyWithKey:(Api38_InputPrivacyKey *)key;
+ (Api38_FunctionContext *)account_setPrivacyWithKey:(Api38_InputPrivacyKey *)key rules:(NSArray *)rules;
+ (Api38_FunctionContext *)account_deleteAccountWithReason:(NSString *)reason;
+ (Api38_FunctionContext *)account_getAccountTTL;
+ (Api38_FunctionContext *)account_setAccountTTLWithTtl:(Api38_AccountDaysTTL *)ttl;
+ (Api38_FunctionContext *)account_sendChangePhoneCodeWithPhoneNumber:(NSString *)phoneNumber;
+ (Api38_FunctionContext *)account_changePhoneWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode;
+ (Api38_FunctionContext *)account_setPasswordWithCurrentPasswordHash:(NSData *)currentPasswordHash pnewSalt:(NSData *)pnewSalt pnewPasswordHash:(NSData *)pnewPasswordHash hint:(NSString *)hint;
+ (Api38_FunctionContext *)account_updateDeviceLockedWithPeriod:(NSNumber *)period;
+ (Api38_FunctionContext *)account_getAuthorizations;
+ (Api38_FunctionContext *)account_resetAuthorizationWithPhash:(NSNumber *)phash;
+ (Api38_FunctionContext *)account_getPassword;
+ (Api38_FunctionContext *)account_getPasswordSettingsWithCurrentPasswordHash:(NSData *)currentPasswordHash;
+ (Api38_FunctionContext *)account_updatePasswordSettingsWithCurrentPasswordHash:(NSData *)currentPasswordHash pnewSettings:(Api38_account_PasswordInputSettings *)pnewSettings;
+ (Api38_FunctionContext *)photos_getPhotosWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)photos_getWallWithUserId:(Api38_InputUser *)userId offset:(NSNumber *)offset maxId:(NSNumber *)maxId limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)photos_readWallWithUserId:(Api38_InputUser *)userId maxId:(NSNumber *)maxId;
+ (Api38_FunctionContext *)photos_editPhotoWithPid:(Api38_InputPhoto *)pid caption:(NSString *)caption geoPoint:(Api38_InputGeoPoint *)geoPoint;
+ (Api38_FunctionContext *)photos_updateProfilePhotoWithPid:(Api38_InputPhoto *)pid crop:(Api38_InputPhotoCrop *)crop;
+ (Api38_FunctionContext *)photos_uploadPhotoWithFile:(Api38_InputFile *)file caption:(NSString *)caption geoPoint:(Api38_InputGeoPoint *)geoPoint;
+ (Api38_FunctionContext *)photos_uploadProfilePhotoWithFile:(Api38_InputFile *)file caption:(NSString *)caption geoPoint:(Api38_InputGeoPoint *)geoPoint crop:(Api38_InputPhotoCrop *)crop;
+ (Api38_FunctionContext *)photos_deletePhotosWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)photos_restorePhotosWithPid:(NSArray *)pid;
+ (Api38_FunctionContext *)photos_getUserPhotosWithUserId:(Api38_InputUser *)userId offset:(NSNumber *)offset maxId:(NSNumber *)maxId limit:(NSNumber *)limit;
+ (Api38_FunctionContext *)phone_getDhConfig;
+ (Api38_FunctionContext *)phone_requestCallWithUserId:(Api38_InputUser *)userId;
+ (Api38_FunctionContext *)phone_confirmCallWithPid:(Api38_InputPhoneCall *)pid aOrB:(NSData *)aOrB;
+ (Api38_FunctionContext *)phone_declineCallWithPid:(Api38_InputPhoneCall *)pid;
@end
