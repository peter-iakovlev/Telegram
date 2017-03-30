#import "TGEmbedMenu.h"

#import "TGImageUtils.h"

#import "TGViewController.h"
#import "TGMenuSheetController.h"
#import "TGMenuSheetView.h"

#import "TGEmbedItemView.h"
#import "TGEmbedPIPPlaceholderView.h"

#import "TGWebPageMediaAttachment.h"

#import "TGSendMessageSignals.h"

#import "TGEmbedPIPController.h"

#import "TGOpenInMenu.h"
#import "TGShareMenu.h"

@implementation TGEmbedMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController attachment:(TGWebPageMediaAttachment *)attachment peerId:(int64_t)peerId messageId:(int32_t)messageId cancelPIP:(bool)cancelPIP sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
{
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.sourceRect = sourceRect;
    controller.permittedArrowDirections = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    TGEmbedItemView *embedView = [[TGEmbedItemView alloc] initWithWebPageAttachment:attachment preview:false peerId:peerId messageId:messageId];
    embedView.parentController = parentController;
    [itemViews addObject:embedView];
    
    TGWebPageMediaAttachment *webPage = attachment;
    __weak TGMenuSheetController *weakController = controller;
    
    TGMenuSheetButtonItemView *openItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        __strong TGWebPageMediaAttachment *strongWebPage = webPage;
        
        [TGOpenInMenu presentInParentController:nil menuController:strongController title:TGLocalized(@"Map.OpenIn") webPageAttachment:strongWebPage buttonTitle:nil buttonAction:nil sourceView:sourceView sourceRect:sourceRect barButtonItem:nil];
    }];
    [itemViews addObject:openItem];
    
    TGMenuSheetButtonItemView *shareItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.ContextMenuShare") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        __strong TGWebPageMediaAttachment *strongWebPage = webPage;
        
        [TGShareMenu presentInParentController:nil menuController:strongController buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
        {
            [[UIPasteboard generalPasteboard] setString:strongWebPage.url];
        } shareAction:^(NSArray *peerIds, NSString *caption)
        {
            [[TGShareSignals shareText:attachment.url toPeerIds:peerIds caption:caption] startWithNext:nil];
        } externalShareItemSignal:[SSignal single:[NSURL URLWithString:strongWebPage.url]] sourceView:sourceView sourceRect:sourceRect barButtonItem:nil];
    }];
    [itemViews addObject:shareItem];
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController != nil)
            [strongController dismissAnimated:true];
    }];
    [itemViews addObject:cancelItem];
    
    [controller setItemViews:itemViews];
    
    if (cancelPIP)
    {
        [embedView.pipPlaceholderView setSolidColor];
        
        controller.willPresent = ^(CGFloat offset)
        {
            CGPoint viewOffset = CGPointZero;
            if (offset > FLT_EPSILON)
            {
                viewOffset.y = -offset;
                
                if (TGIsPad())
                {
                    viewOffset.x += TGMenuSheetPhoneEdgeInsets.left;
                    viewOffset.y += TGMenuSheetPhoneEdgeInsets.top;
                }
            }
            
            [TGEmbedPIPController cancelPictureInPictureWithOffset:viewOffset];
        };
    }
    
    [controller presentInViewController:parentController sourceView:sourceView animated:true];
    
    return controller;
}

+ (bool)isEmbedMenuController:(TGMenuSheetController *)menuController
{
    for (TGMenuSheetView *itemView in menuController.itemViews)
    {
        if ([itemView isKindOfClass:[TGEmbedItemView class]])
            return true;
    }
    
    return false;
}

@end
