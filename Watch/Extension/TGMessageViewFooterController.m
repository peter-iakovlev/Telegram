#import "TGMessageViewFooterController.h"

#import "TGDateUtils.h"

#import "TGBridgeMessage.h"

NSString *const TGMessageViewFooterIdentifier = @"TGMessageViewFooter";

@implementation TGMessageViewFooterController

- (void)updateWithMessage:(TGBridgeMessage *)message channel:(bool)channel
{
    self.dateLabel.text = [TGDateUtils stringForFullDate:message.date];
    self.timeLabel.text = [TGDateUtils stringForShortTime:message.date];
    
    self.forwardLabel.text = TGLocalized(@"MessageView.Forward");
    self.replyLabel.text = TGLocalized(@"MessageView.Reply");
    self.viewLabel.text = TGLocalized(@"MessageView.ViewOnPhone");
    
    if (channel)
    {
        self.forwardButton.hidden = true;
        self.replyButton.hidden = true;
    }
}

- (IBAction)forwardButtonPressedAction
{
    if (self.forwardPressed != nil)
        self.forwardPressed();
}

- (IBAction)replyButtonPressedAction
{
    if (self.replyPressed != nil)
        self.replyPressed();
}

- (IBAction)viewButtonPressedAction
{
    if (self.viewPressed != nil)
        self.viewPressed();
}

+ (NSString *)identifier
{
    return TGMessageViewFooterIdentifier;
}

@end
