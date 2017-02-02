/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernSendMessageActor.h"

@class TGDocumentMediaAttachment;
@class TGImageMediaAttachment;

@interface TGModernSendCommonMessageActor : TGModernSendMessageActor

+ (TGDocumentMediaAttachment *)remoteDocumentByGiphyId:(NSString *)giphyId;
+ (void)setRemoteDocumentForGiphyId:(NSString *)giphyId document:(TGDocumentMediaAttachment *)document;
+ (TGImageMediaAttachment *)remoteImageByRemoteUrl:(NSString *)url;
+ (void)setRemoteImageForRemoteUrl:(NSString *)url image:(TGImageMediaAttachment *)image;
+ (void)clearRemoteMediaMapping;
+ (NSArray *)convertEntities:(NSArray *)entities;

- (void)conversationSendMessageRequestSuccess:(id)result;
- (void)conversationSendMessageQuickAck;
- (void)conversationSendMessageRequestFailed:(NSString *)errorText;

@end
