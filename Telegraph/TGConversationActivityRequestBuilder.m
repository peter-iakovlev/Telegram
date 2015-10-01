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
    if ([activity isEqualToString:@"typing"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
            self.cancelToken = [TGTelegraphInstance doReportEncryptedConversationTypingActivity:[options[@"encryptedConversationId"] longLongValue] accessHash:[options[@"accessHash"] longLongValue] actor:self];
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageTypingAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"recordingAudio"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageRecordAudioAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingAudio"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageUploadAudioAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingPhoto"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageUploadPhotoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"recordingVideo"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageRecordVideoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingVideo"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageUploadVideoAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"uploadingDocument"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageUploadDocumentAction alloc] init] actor:self];
        }
    }
    else if ([activity isEqualToString:@"pickingLocation"])
    {
        if ([options[@"encryptedConversationId"] longLongValue] != 0)
        {
            
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doReportConversationActivity:conversationId accessHash:0 activity:[[TLSendMessageAction$sendMessageGeoLocationAction alloc] init] actor:self];
        }
    }
    else
    {
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
