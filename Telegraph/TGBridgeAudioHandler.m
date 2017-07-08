#import "TGBridgeAudioHandler.h"
#import "TGBridgeAudioSubscription.h"

#import "TGBridgeAudioMediaAttachment+TGAudioMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment+TGDocumentMediaAttachment.h"

#import "TGBridgeCommon.h"
#import "TGBridgeServer.h"

#import "TGBridgeAudioEncoder.h"
#import "TGBridgeAudioDecoder.h"

#import "TGDownloadAudioSignal.h"
#import "TGSendAudioSignal.h"

#import "TGMessage.h"
#import "TGBridgeMessage+TGMessage.h"

@implementation TGBridgeAudioHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)server
{
    if ([subscription isKindOfClass:[TGBridgeAudioSubscription class]])
    {
        TGBridgeAudioSubscription *audioSubscription = (TGBridgeAudioSubscription *)subscription;
        int64_t identifier = 0;
        int64_t conversationId = audioSubscription.conversationId;
        int32_t messageId = audioSubscription.messageId;
        NSString *audioPath = nil;
        TGMediaAttachment *attachment = nil;
        
        if ([audioSubscription.attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
        {
            TGBridgeAudioMediaAttachment *bridgeAudioAttachment = (TGBridgeAudioMediaAttachment *)audioSubscription.attachment;
            identifier = audioSubscription.identifier;
            
            TGAudioMediaAttachment *audioAttachment = [TGBridgeAudioMediaAttachment tgAudioMediaAttachmentWithBridgeAudioMediaAttachment:bridgeAudioAttachment];
            audioPath = audioAttachment.localFilePath;
            attachment = audioAttachment;
        }
        else if ([audioSubscription.attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
        {
            TGBridgeDocumentMediaAttachment *bridgeDocumentAttachment = (TGBridgeDocumentMediaAttachment *)audioSubscription.attachment;
            identifier = bridgeDocumentAttachment.documentId;
            
            TGDocumentMediaAttachment *documentAttachment = [TGBridgeDocumentMediaAttachment tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:bridgeDocumentAttachment];
            audioPath = [TGDownloadAudioSignal pathForDocumentMediaAttachment:documentAttachment];
            attachment = documentAttachment;
        }
        
        bool audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
        
        SSignal *(^convertSignal)(NSURL *) = ^(NSURL *url)
        {
            return [[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
                return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                {
                    TGBridgeAudioDecoder *decoder = [[TGBridgeAudioDecoder alloc] initWithURL:url];
                    [decoder startWithCompletion:^(NSURL *result)
                    {
                        NSURL *finalURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.%@", result.lastPathComponent, @"m4a"] relativeToURL:server.temporaryFilesURL];
                        [[NSFileManager defaultManager] moveItemAtURL:result toURL:finalURL error:nil];
                        
                        if (result != nil)
                        {
                            [subscriber putNext:finalURL];
                            [subscriber putCompletion];
                        }
                        else
                        {
                            [subscriber putError:nil];
                        }
                    }];
                    
                    return [[SBlockDisposable alloc] initWithBlock:^
                    {
                        [decoder stop];
                    }];
                }];
            }];
        };
        
        SSignal *(^sendSignal)(NSURL *, NSString *) = ^SSignal *(NSURL *url, NSString *key)
        {
            return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
            {
                [server sendFileWithURL:url metadata:@{ TGBridgeIncomingFileTypeKey: TGBridgeIncomingFileTypeAudio, TGBridgeIncomingFileIdentifierKey: key }];
                [subscriber putNext:@true];
                [subscriber putCompletion];
                return nil;
            }];
        };
        
        SSignal *(^processSignal)(NSURL *) = ^(NSURL *url)
        {
            return [convertSignal(url) mapToSignal:^(NSURL *resultUrl)
            {
                return sendSignal(resultUrl, [NSString stringWithFormat:@"%lld", identifier]);
            }];
        };
        
        if (audioDownloaded)
        {
            return processSignal([NSURL fileURLWithPath:audioPath]);
        }
        else
        {
            return [[TGDownloadAudioSignal downloadAudioWithAttachment:attachment conversationId:conversationId messageId:messageId] mapToSignal:^(NSString *audioPath)
            {
                return processSignal([NSURL fileURLWithPath:audioPath]);
            }];
        }
    }
    else if ([subscription isKindOfClass:[TGBridgeAudioSentSubscription class]])
    {
        return [server pipeForKey:@"sentAudio"];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeAudioSubscription class], [TGBridgeAudioSentSubscription class] ];
}

+ (void)handleIncomingAudioWithURL:(NSURL *)url metadata:(NSDictionary *)metadata server:(TGBridgeServer *)server
{
    [TGBridgeServer serverQueueIsCurrent];
    
    int64_t uniqueId = [metadata[TGBridgeIncomingFileRandomIdKey] int64Value];
    int64_t peerId = [metadata[TGBridgeIncomingFilePeerIdKey] int64Value];
    int32_t replyToMid = [metadata[TGBridgeIncomingFileReplyToMidKey] int32Value];
    
    NSString *signalKey = [[NSString alloc] initWithFormat:@"convertAudio_%lld", uniqueId];
    [[[server server] onNext:^(TGBridgeServer *server) {
        [server startSignalForKey:signalKey producer:^SSignal *{
            SSignal *convertSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
            {
                TGBridgeAudioEncoder *encoder = [[TGBridgeAudioEncoder alloc] initWithURL:url];
                if (encoder != nil)
                {
                    [encoder startWithCompletion:^(TGDataItem *dataItem, int32_t duration, TGLiveUploadActorData *liveData)
                    {
                        if (dataItem != nil)
                        {
                            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                            result[@"dataItem"] = dataItem;
                            result[@"duration"] = @(duration);
                            if (liveData != nil)
                                result[@"liveData"] = liveData;
                            
                            [subscriber putNext:result];
                            [subscriber putCompletion];
                        }
                        else
                        {
                            [subscriber putError:nil];
                        }
                    }];
                }
                else
                {
                    [subscriber putError:nil];
                }
                
                return nil;
            }];
            
            return [convertSignal mapToSignal:^SSignal *(NSDictionary *result)
            {
                return [[TGSendAudioSignal sendAudioWithPeerId:peerId tempDataItem:result[@"dataItem"] liveData:result[@"liveData"] duration:[result[@"duration"] int32Value] localAudioId:uniqueId replyToMid:replyToMid] onNext:^(TGMessage *next)
                {
                    for (TGMediaAttachment *attachment in next.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                        {
                            TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                            if (audioAttachment.audioId != 0)
                            {
                                TGBridgeMessage *bridgeMessage = [TGBridgeMessage messageWithTGMessage:next conversation:nil];
                                for (TGBridgeMediaAttachment *bridgeAttachment in bridgeMessage.media)
                                {
                                    if ([bridgeAttachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
                                    {
                                        TGBridgeAudioMediaAttachment *bridgeAudioAttachment = (TGBridgeAudioMediaAttachment *)bridgeAttachment;
                                        bridgeAudioAttachment.localAudioId = uniqueId;
                                    }
                                }
                                
                                [server putNext:bridgeMessage forKey:@"sentAudio"];
                            }
                        }
                        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        {
                            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                            if (documentAttachment.documentId != 0)
                            {
                                TGBridgeMessage *bridgeMessage = [TGBridgeMessage messageWithTGMessage:next conversation:nil];
                                for (TGBridgeMediaAttachment *bridgeAttachment in bridgeMessage.media)
                                {
                                    if ([bridgeAttachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
                                    {
                                        TGBridgeDocumentMediaAttachment *bridgeDocumentAttachment = (TGBridgeDocumentMediaAttachment *)bridgeAttachment;
                                        bridgeDocumentAttachment.localDocumentId = uniqueId;
                                    }
                                }
                                
                                [server putNext:bridgeMessage forKey:@"sentAudio"];
                            }
                        }
                    }
                }];
            }];
        }];
    }] startWithNext:nil];
}

@end
