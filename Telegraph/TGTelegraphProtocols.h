/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef Telegraph_TGTelegraphProtocols_h
#define Telegraph_TGTelegraphProtocols_h

#import "TL/TLMetaScheme.h"

@protocol TGRawHttpActor <NSObject>

- (void)httpRequestSuccess:(NSString *)url response:(NSData *)response;
- (void)httpRequestFailed:(NSString *)url;

@optional

- (void)httpRequestProgress:(NSString *)url progress:(float)progress;

@end

@protocol TGRawHttpFileActor <NSObject>

- (void)httpFileDownloadSuccess:(NSString *)url;
- (void)httpFileDownloadFailed:(NSString *)url;

@end

@protocol TGFileUploadActor <NSObject>

- (void)filePartUploadSuccess:(int)partId;
- (void)filePartUploadFailed:(int)partId;

@end

@protocol TGFileDownloadActor <NSObject>

- (void)fileDownloadSuccess:(int64_t)volumeId fileId:(int)fileId secret:(int64_t)secret data:(NSData *)data;
- (void)fileDownloadFailed:(int64_t)volumeId fileId:(int)fileId secret:(int64_t)secret;
- (void)fileDownloadProgress:(int64_t)volumeId fileId:(int)fileId secret:(int64_t)secret progress:(float)progress;

@optional

- (void)filePartDownloadProgress:(TLInputFileLocation *)location offset:(int)offset length:(int)length packetLength:(int)packetLength progress:(float)progress;
- (void)filePartDownloadSuccess:(TLInputFileLocation *)location offset:(int)offset length:(int)length data:(NSData *)data;
- (void)filePartDownloadFailed:(TLInputFileLocation *)location offset:(int)offset length:(int)length;

@end

@protocol TGPeerSettingsActorProtocol <NSObject>

- (void)peerNotifySettingsRequestSuccess:(TLPeerNotifySettings *)settings;
- (void)peerNotifySettingsRequestFailed;

@end

@protocol TGContactDeleteActorProtocol <NSObject>

- (void)deleteContactsSuccess:(NSArray *)uids;
- (void)deleteContactsFailed:(NSArray *)uids;

@end

@protocol TGLocateContactsProtocol <NSObject>

- (void)locateSuccess:(TLcontacts_Located *)locatedContacts;
- (void)locateFailed;

@end

@protocol TGDeleteChatMemberProtocol <NSObject>

- (void)deleteMemberSuccess:(TLUpdates *)statedMessage;
- (void)deleteMemberFailed;

@end

#endif
