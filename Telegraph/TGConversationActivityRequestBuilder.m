#import "TGConversationActivityRequestBuilder.h"

#import "ActionStage.h"

#import "TGAppDelegate.h"

#import "TGTelegraph.h"

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
            self.cancelToken = [TGTelegraphInstance doReportConversationTypingActivity:conversationId requestBuilder:self];
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
