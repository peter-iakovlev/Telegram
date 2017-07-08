#import "TGConversationActivityRequestBuilder.h"

#import "ActionStage.h"

#import "TGAppDelegate.h"

#import "TGTelegraph.h"

#import "TL/TLMetaScheme.h"

@implementation TGConversationActivityRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/activity/@";
}

- (void)execute:(NSDictionary *)options
{
    NSRange range = [self.path rangeOfString:@")/activity/("];
    int64_t conversationId = [[self.path substringWithRange:NSMakeRange(18, range.location - 18)] longLongValue];
    
    NSString *activity = [self.path substringWithRange:NSMakeRange(range.location + range.length, self.path.length - range.location - range.length - 1)];
    NSString *previousType = options[@"previousType"];
    
    if ([activity isEqualToString:@"typing"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
            self.cancelToken = [TGTelegraphInstance doReportEncryptedConversationTypingActivity:[options[@"encryptedConversationId"] longLongValue] accessHash:[options[@"accessHash"] longLongValue] actor:self];
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageTypingAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"recordingAudio"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageRecordAudioAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"recordingVideoMessage"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageRecordRoundAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingVideoMessage"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageUploadRoundAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingAudio"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageUploadAudioAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingPhoto"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageUploadPhotoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"recordingVideo"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageRecordVideoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingVideo"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageUploadVideoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingDocument"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageUploadDocumentAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"pickingLocation"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageGeoLocationAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"playingGame"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageGamePlayAction alloc] init] actor:self];
        }
    }
    else if (![activity isEqualToString:previousType] && ![previousType isEqualToString:@"typing"])
    {
        self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:[options[@"accessHash"] longLongValue] activity:[[TLSendMessageAction$sendMessageCancelAction alloc] init] actor:self];
    } else {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)reportTypingActivitySuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)reportTypingActivityFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        
        self.cancelToken = nil;
    }
    
    [super cancel];
}

@end
