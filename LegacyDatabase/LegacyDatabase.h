//
//  LegacyDatabase.h
//  LegacyDatabase
//
//  Created by Peter on 9/26/16.
//
//

#import <UIKit/UIKit.h>

//! Project version number for LegacyDatabase.
FOUNDATION_EXPORT double LegacyDatabaseVersionNumber;

//! Project version string for LegacyDatabase.
FOUNDATION_EXPORT const unsigned char LegacyDatabaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LegacyDatabase/PublicHeader.h>

#import <LegacyDatabase/sqlite3.h>
#import <LegacyDatabase/sqlite3ext.h>
#import <LegacyDatabase/TGLegacyDatabase.h>
#import <LegacyDatabase/TGLegacyUser.h>

#import <LegacyDatabase/TGDatacenterConnectionContext.h>
#import <LegacyDatabase/lmdb.h>
#import <LegacyDatabase/midl.h>
#import <LegacyDatabase/TGShareContext.h>
#import <LegacyDatabase/TGShareMtSerialization.h>
#import <LegacyDatabase/TGShareContextSignal.h>
#import <LegacyDatabase/PSLMDBKeyValueReaderWriter.h>
#import <LegacyDatabase/TGModernCache.h>
#import <LegacyDatabase/PSData.h>
#import <LegacyDatabase/PSKeyValueReader.h>
#import <LegacyDatabase/PSKeyValueStore.h>
#import <LegacyDatabase/PSKeyValueWriter.h>
#import <LegacyDatabase/PSLMDBKeyValueCursor.h>
#import <LegacyDatabase/PSLMDBKeyValueReaderWriter.h>
#import <LegacyDatabase/PSLMDBKeyValueStore.h>
#import <LegacyDatabase/PSLMDBTable.h>
#import <LegacyDatabase/TGMemoryCache.h>
#import <LegacyDatabase/TGPoolWithTimeout.h>
#import <LegacyDatabase/ApiLayer70.h>

#import <LegacyDatabase/TGPeerId.h>
#import <LegacyDatabase/TGContactModel.h>
#import <LegacyDatabase/TGUserModel.h>
#import <LegacyDatabase/TGFileLocation.h>
#import <LegacyDatabase/TGChannelChatModel.h>
#import <LegacyDatabase/TGGroupChatModel.h>
#import <LegacyDatabase/TGPrivateChatModel.h>

#import <LegacyDatabase/TGChatListSignal.h>
#import <LegacyDatabase/TGChatListAvatarSignal.h>
#import <LegacyDatabase/TGSendMessageSignals.h>
#import <LegacyDatabase/TGUploadedMessageContentMedia.h>
#import <LegacyDatabase/TGUploadMediaSignals.h>
#import <LegacyDatabase/TGShareContactSignals.h>
#import <LegacyDatabase/TGShareLocationSignals.h>
#import <LegacyDatabase/TGShareRecentPeersSignals.h>
#import <LegacyDatabase/TGSearchSignals.h>
#import <LegacyDatabase/TGUploadedMessageContent.h>
#import <LegacyDatabase/TGUploadedMessageContentText.h>

#import <LegacyDatabase/TGGeometry.h>
#import <LegacyDatabase/TGColor.h>
#import <LegacyDatabase/TGRoundImage.h>
#import <LegacyDatabase/TGScaleImage.h>
