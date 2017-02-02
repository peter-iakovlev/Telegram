#import "TGShareMenu.h"

#import "TGAppDelegate.h"
#import "TGViewController.h"
#import "TGMenuSheetController.h"
#import "TGProgressWindow.h"

#import "TGShareSearchItemView.h"
#import "TGShareCollectionItemView.h"
#import "TGShareSendButtonItemView.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGGlobalMessageSearchSignals.h"
#import "TGChatSearchController.h"
#import "TGConversation.h"
#import "TGUser.h"

@interface TGDocumentInteractionControllerHandle : NSObject <UIDocumentInteractionControllerDelegate>
{
    UIDocumentInteractionController *_controller;
    id _selfRetain;
}

- (instancetype)initWithController:(UIDocumentInteractionController *)controller;

@end

@implementation TGShareMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction shareAction:(void (^)(NSArray *peerIds, NSString *caption))shareAction externalShareItemSignal:(id)externalShareItemSignal sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem
{
    void (^externalShareBlock)(TGViewController *, UIView *, CGRect (^)(void)) = ^(TGViewController *viewController, UIView *sourceView, CGRect (^sourceRect)(void))
    {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.2];
        
        [[externalShareItemSignal onDispose:^
        {
            [progressWindow dismiss:true];
        }] startWithNext:^(id next)
        {
            if (next == nil)
                return;
            
            if ([next isKindOfClass:[NSURL class]] && [(NSURL *)next isFileURL])
            {
                UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:next];
                if (barButtonItem != nil)
                    [interactionController presentOptionsMenuFromBarButtonItem:barButtonItem animated:true];
                else
                    [interactionController presentOptionsMenuFromRect:sourceRect() inView:sourceView animated:true];
                
                __unused id handle = [[TGDocumentInteractionControllerHandle alloc] initWithController:interactionController];
            }
            else
            {
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[next] applicationActivities:nil];
                if (iosMajorVersion() >= 8 && TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassRegular && (sourceView != nil || barButtonItem != nil))
                {
                    if (barButtonItem != nil)
                    {
                        activityController.popoverPresentationController.barButtonItem = barButtonItem;
                    }
                    else
                    {
                        activityController.popoverPresentationController.sourceView = sourceView;
                        if (sourceRect != nil)
                            activityController.popoverPresentationController.sourceRect = sourceRect();
                    }
                    activityController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                }
                [viewController presentViewController:activityController animated:true completion:nil];
            }
            
            [progressWindow dismiss:true];
        }];
    };
    
    if (shareAction == nil && externalShareItemSignal != nil)
    {
        externalShareBlock(parentController, sourceView, sourceRect);
        return nil;
    }
    
    TGMenuSheetController *controller = nil;
    if (menuController == nil)
    {
        controller = [[TGMenuSheetController alloc] init];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.followsKeyboard = true;
    }
    else
    {
        controller = menuController;
        controller.followsKeyboard = true;
    }
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = sourceRect;
    controller.barButtonItem = barButtonItem;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    TGShareCollectionItemView *collectionItem = [[TGShareCollectionItemView alloc] init];
    collectionItem.hasActionButton = (buttonTitle.length > 0);
    
    TGShareSearchItemView *searchItem = [[TGShareSearchItemView alloc] init];
    
    __weak TGMenuSheetController *weakController = controller;
    if (externalShareItemSignal != nil)
    {
        [searchItem setExternalButtonHidden:false];
        searchItem.externalPressed = ^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
            
            externalShareBlock((TGViewController *)strongController.parentController, strongController.sourceView, strongController.sourceRect);
        };
    }

    __weak TGShareCollectionItemView *weakCollectionItem = collectionItem;
    TGShareSendButtonItemView *sendItem = [[TGShareSendButtonItemView alloc] initWithActionTitle:buttonTitle action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
        
        if (buttonAction != nil)
            buttonAction();
    } sendAction:^(NSString *caption)
    {
        __strong TGMenuSheetController *strongController = weakController;
        __strong TGShareCollectionItemView *strongCollectionItem = weakCollectionItem;
        if (strongController == nil || strongCollectionItem == nil || shareAction == nil)
            return;
        
        if (shareAction != nil)
            shareAction(strongCollectionItem.peerIds, caption);
        
        [strongController dismissAnimated:true];
    }];
    
    __weak TGShareSendButtonItemView *weakSendItem = sendItem;
    searchItem.didBeginSearch = ^
    {
        __strong TGShareCollectionItemView *strongCollectionItem = weakCollectionItem;
        __strong TGShareSendButtonItemView *strongSendItem = weakSendItem;
        if (strongCollectionItem == nil || strongSendItem == nil)
            return;
        
        [strongCollectionItem setExpanded];
        [strongCollectionItem searchBegan];
        [strongSendItem setCollapsed:true];
    };
    
    __weak TGShareSearchItemView *weakSearchItem = searchItem;
    searchItem.didEndSearch = ^(bool reload)
    {
        __strong TGShareCollectionItemView *strongCollectionItem = weakCollectionItem;
        __strong TGShareSendButtonItemView *strongSendItem = weakSendItem;
        if (strongCollectionItem == nil || strongSendItem == nil)
            return;
        
        [strongCollectionItem setSearchQuery:nil updateActivity:^(bool active)
        {
            __strong TGShareSearchItemView *strongSearchItem = weakSearchItem;
            if (strongSearchItem == nil)
                return;
            
            [strongSearchItem setShowActivity:active];
        }];
        [strongCollectionItem searchEnded:reload];
        [strongSendItem setCollapsed:false];
    };
    
    searchItem.textChanged = ^(NSString *searchText)
    {
        __strong TGShareCollectionItemView *strongCollectionItem = weakCollectionItem;
        if (strongCollectionItem == nil)
            return;
        
        [strongCollectionItem setSearchQuery:searchText updateActivity:^(bool active)
        {
            __strong TGShareSearchItemView *strongSearchItem = weakSearchItem;
            if (strongSearchItem == nil)
                return;
            
            [strongSearchItem setShowActivity:active];
        }];
    };
    
    sendItem.didBeginEditingComment = ^
    {
        __strong TGShareCollectionItemView *strongCollectionItem = weakCollectionItem;
        if (strongCollectionItem != nil)
            [strongCollectionItem setExpanded];
    };
    
    collectionItem.selectionChanged = ^(NSArray *selectedPeerIds, NSDictionary *peers)
    {
        __strong TGShareSendButtonItemView *strongSendItem = weakSendItem;
        __strong TGShareSearchItemView *strongSearchItem = weakSearchItem;
        if (strongSendItem == nil || strongSearchItem == nil)
            return;
        
        [strongSendItem setSelectedCount:selectedPeerIds.count];
        [strongSearchItem setSelectedPeerIds:selectedPeerIds peers:peers];
    };
    
    collectionItem.searchResultSelected = ^
    {
        __strong TGShareSearchItemView *strongSearchItem = weakSearchItem;
        if (strongSearchItem != nil)
            [searchItem finishSearch];
    };
    
    collectionItem.dismissCommentView = ^
    {
        __strong TGShareSendButtonItemView *strongSendItem = weakSendItem;
        if (strongSendItem != nil)
            [strongSendItem dismissCommentView];
    };
    
    [itemViews addObject:searchItem];
    [itemViews addObject:collectionItem];
    [itemViews addObject:sendItem];
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelButton];
    
    if (menuController == nil)
    {
        [controller setItemViews:itemViews];
        [controller presentInViewController:parentController sourceView:sourceView animated:true];
    }
    else
    {
        [controller setItemViews:itemViews animated:true];
    }
    
    return controller;
}

@end


@implementation TGDocumentInteractionControllerHandle

- (instancetype)initWithController:(UIDocumentInteractionController *)controller
{
    self = [super init];
    if (self != nil)
    {
        _controller = controller;
        _controller.delegate = self;
        _selfRetain = self;
    }
    return self;
}

- (void)dispose
{
    _controller.delegate = nil;
    _selfRetain = nil;
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)__unused controller
{
    [self dispose];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)__unused controller didEndSendingToApplication:(NSString *)__unused application
{
    [self dispose];
}

@end
