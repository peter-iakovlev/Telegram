#import "TGStickersMenu.h"
#import "TGMaskStickersSignals.h"
#import "TGStickersSignals.h"

#import "TGStringUtils.h"

#import "TGViewController.h"
#import "TGMenuSheetController.h"
#import "TGStickersCollectionItemView.h"

#import "TGSendMessageSignals.h"

#import "TGShareMenu.h"

#import "TGProgressWindow.h"

#import "TGArchivedStickerPacksAlert.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

const int64_t TGStickersBultinPackIdentifier = 1842540969984001;

@implementation TGStickersMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController stickerPackReference:(id<TGStickerPackReference>)packReference showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))stickerPackHidden sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
{
    return [self presentWithParentController:parentController packReference:packReference stickerPack:nil showShareAction:showShareAction sendSticker:sendSticker stickerPackRemoved:stickerPackRemoved stickerPackHidden:stickerPackHidden stickerPackArchived:false stickerPackIsMask:false sourceView:sourceView sourceRect:sourceRect centered:false];
}

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController stickerPackReference:(id<TGStickerPackReference>)packReference showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool))stickerPackHidden sourceView:(UIView *)sourceView centered:(bool)centered
{
    return [self presentWithParentController:parentController packReference:packReference stickerPack:nil showShareAction:showShareAction sendSticker:sendSticker stickerPackRemoved:stickerPackRemoved stickerPackHidden:stickerPackHidden stickerPackArchived:false stickerPackIsMask:false sourceView:sourceView sourceRect:nil centered:centered];
}

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController stickerPack:(TGStickerPack *)stickerPack showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))stickerPackHidden stickerPackArchived:(bool)stickerPackArchived stickerPackIsMask:(bool)stickerPackIsMask sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
{
    return [self presentWithParentController:parentController packReference:stickerPack.packReference stickerPack:stickerPack showShareAction:showShareAction sendSticker:sendSticker stickerPackRemoved:stickerPackRemoved stickerPackHidden:stickerPackHidden stickerPackArchived:stickerPackArchived stickerPackIsMask:stickerPackIsMask sourceView:sourceView sourceRect:sourceRect centered:false];
}


+ (TGMenuSheetController *)presentWithParentController:(TGViewController *)parentController packReference:(id<TGStickerPackReference>)packReference stickerPack:(TGStickerPack *)stickerPack showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))__unused stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))__unused stickerPackHidden stickerPackArchived:(bool)stickerPackArchived stickerPackIsMask:(bool)stickerPackIsMask sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect centered:(bool)centered
{
    return [self presentWithParentController:parentController packReference:packReference stickerPack:stickerPack showShareAction:showShareAction sendSticker:sendSticker stickerPackRemoved:stickerPackRemoved stickerPackHidden:stickerPackHidden stickerPackArchived:stickerPackArchived stickerPackIsMask:stickerPackIsMask sourceView:sourceView sourceRect:sourceRect centered:centered existingController:nil];
}

+ (TGMenuSheetController *)presentWithParentController:(TGViewController *)parentController packReference:(id<TGStickerPackReference>)packReference stickerPack:(TGStickerPack *)stickerPack showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))__unused stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))__unused stickerPackHidden stickerPackArchived:(bool)stickerPackArchived stickerPackIsMask:(bool)stickerPackIsMask sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect centered:(bool)centered existingController:(TGMenuSheetController *)existingController {
    bool isBuiltinStickerPack = false;
    if ([packReference isKindOfClass:[TGStickerPackIdReference class]])
    {
        TGStickerPackIdReference *idReference = (TGStickerPackIdReference *)packReference;
        isBuiltinStickerPack = (idReference.packId == TGStickersBultinPackIdentifier);
    }
    
    if (centered)
    {
        sourceRect = ^CGRect
        {
            return CGRectMake(CGRectGetMidX(sourceView.frame), CGRectGetMidY(sourceView.frame), 0, 0);
        };
    }
    
    TGMenuSheetController *controller = nil;
    if (existingController != nil) {
        controller = existingController;
    } else {
        controller = [[TGMenuSheetController alloc] init];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.sourceRect = sourceRect;
        controller.permittedArrowDirections = centered ? 0 : (UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight);
    }
    controller.packIsArchived = stickerPackArchived;
    controller.packIsMask = stickerPackIsMask;
    __weak TGMenuSheetController *weakController = controller;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    TGStickersCollectionItemView *collectionItem = [[TGStickersCollectionItemView alloc] init];
    collectionItem.hasShare = showShareAction;
    if (sendSticker != nil)
    {
        collectionItem.sendSticker = ^(TGDocumentMediaAttachment *sticker)
        {
            sendSticker(sticker);
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        };
    }
    collectionItem.openLink = ^(NSString *link) {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
        
        if ([link hasPrefix:@"mention://"])
        {
            NSString *domain = [link substringFromIndex:@"mention://".length];
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@,profile)", domain] options:@{@"domain": domain, @"profile": @true, @"keepStack": @true} flags:0 watcher:TGTelegraphInstance];
        }
    };
    [itemViews addObject:collectionItem];

    TGMenuSheetButtonItemView *modifyItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:nil type:TGMenuSheetButtonTypeDefault action:nil];
    [itemViews addObject:modifyItem];
    
    TGMenuSheetButtonItemView *shareItem = nil;
    if (!isBuiltinStickerPack)
    {
        if (showShareAction)
        {
            shareItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.ContextMenuShare") type:TGMenuSheetButtonTypeDefault action:[self shareButtonActionForController:controller stickerPack:stickerPack]];
            [itemViews addObject:shareItem];
        }
        
        bool installed = (stickerPack != nil) ? true : ([TGMaskStickersSignals isStickerPackInstalled:packReference] || [TGStickersSignals isStickerPackInstalled:packReference]);
        [TGStickersMenu updateModifyButtonItemView:modifyItem installed:installed stickerPack:stickerPack isBuiltin:false];
    }
    else
    {
        NSArray *stickerPacks = [TGStickersSignals cachedStickerPacks][@"packs"];
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            if ([stickerPack.packReference isEqual:packReference])
            {
                [TGStickersMenu updateModifyButtonItemView:modifyItem installed:!stickerPack.hidden stickerPack:stickerPack isBuiltin:true];
                break;
            }
        }
        
        NSArray *maskStickerPacks = [TGMaskStickersSignals cachedStickerPacks][@"packs"];
        for (TGStickerPack *stickerPack in maskStickerPacks)
        {
            if ([stickerPack.packReference isEqual:packReference])
            {
                [TGStickersMenu updateModifyButtonItemView:modifyItem installed:!stickerPack.hidden stickerPack:stickerPack isBuiltin:true];
                break;
            }
        }
    }
    collectionItem.collapseInLandscape = (shareItem != nil);
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelButton];
    
    [controller setItemViews:itemViews animated:existingController != nil];
    if (existingController == nil) {
        [controller presentInViewController:parentController sourceView:sourceView animated:true];
    }
    
    SSignal *combinedSignal = nil;
    if (stickerPack != nil)
    {
        bool isInstalled = false;
        if (stickerPack.isMask) {
            isInstalled = [TGMaskStickersSignals isStickerPackInstalled:stickerPack.packReference];
        } else {
            isInstalled = [TGStickersSignals isStickerPackInstalled:stickerPack.packReference];
        }
        combinedSignal = [SSignal single:@{ @"stickerPack": stickerPack, @"installed": @(isInstalled), @"isMask": @(stickerPack.isMask) }];
    }
    else
    {
        combinedSignal = [SSignal combineSignals:@[ [TGStickersSignals stickerPackInfo:packReference], [[TGStickersSignals stickerPacks] take:1], [[TGMaskStickersSignals stickerPacks] take:1] ]];
        combinedSignal = [combinedSignal map:^NSDictionary *(NSArray *values)
        {
            TGStickerPack *stickerPack = values[0];
            NSArray *currentStickerPacks = values[1][@"packs"];
            NSArray *currentMaskStickerPacks = values[2][@"packs"];
            
            bool installed = false;
            for (TGStickerPack *currentStickerPack in currentStickerPacks)
            {
                if ([stickerPack.packReference isEqual:currentStickerPack.packReference])
                {
                    installed = !isBuiltinStickerPack || !stickerPack.hidden;
                    break;
                }
            }
            for (TGStickerPack *currentStickerPack in currentMaskStickerPacks)
            {
                if ([stickerPack.packReference isEqual:currentStickerPack.packReference])
                {
                    installed = !isBuiltinStickerPack || !stickerPack.hidden;
                    break;
                }
            }
            
            return @{ @"stickerPack": stickerPack, @"installed": @(installed), @"isMask": @(stickerPack.isMask), @"animated": @true };
        }];
    }
    
    SMetaDisposable *stickerPackDisposable = [[SMetaDisposable alloc] init];
    [controller.disposables add:stickerPackDisposable];
    [stickerPackDisposable setDisposable:[[combinedSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        TGStickerPack *stickerPack = next[@"stickerPack"];
        bool installed = [next[@"installed"] boolValue];
        bool animated = [next[@"animated"] boolValue];
        bool isMask = [next[@"isMask"] boolValue];
        
        [collectionItem setStickerPack:stickerPack animated:animated];
        modifyItem.action = [TGStickersMenu modifyButtonActionForItemView:modifyItem packReference:packReference stickerPack:stickerPack controller:strongController firstInstallation:!installed isBuiltin:isBuiltinStickerPack installed:installed isMask:isMask];
        [TGStickersMenu updateModifyButtonItemView:modifyItem installed:installed stickerPack:stickerPack isBuiltin:isBuiltinStickerPack];
        
        shareItem.action = [TGStickersMenu shareButtonActionForController:strongController stickerPack:stickerPack];
    } error:^(__unused id error)
    {
        [collectionItem setFailed];
    } completed:nil]];
    
    return controller;
}

+ (void)shareStickerPack:(TGStickerPack *)stickerPack menuController:(TGMenuSheetController *)menuController
{
    if (stickerPack == nil)
        return;
    
    NSString *shortName = nil;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        shortName = ((TGStickerPackIdReference *)stickerPack.packReference).shortName;
    else if ([stickerPack.packReference isKindOfClass:[TGStickerPackShortnameReference class]])
        shortName = ((TGStickerPackShortnameReference *)stickerPack.packReference).shortName;
    
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"https://t.me/addstickers/%@", shortName]];
    
    [TGShareMenu presentInParentController:nil menuController:menuController buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
    {
        [[UIPasteboard generalPasteboard] setString:url.absoluteString];
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        [[TGShareSignals shareText:url.absoluteString toPeerIds:peerIds caption:caption] startWithNext:nil];
    } externalShareItemSignal:[SSignal single:url] sourceView:menuController.sourceView sourceRect:menuController.sourceRect barButtonItem:nil];
}


+ (void (^)(void))modifyButtonActionForItemView:(TGMenuSheetButtonItemView *)itemView packReference:(id<TGStickerPackReference>)packReference stickerPack:(TGStickerPack *)stickerPack controller:(TGMenuSheetController *)controller firstInstallation:(bool)firstInstallation isBuiltin:(bool)isBuiltin installed:(bool)installed isMask:(bool)isMask
{
    bool packIsArchived = controller.packIsArchived;
    bool packIsMask = isMask;
    if (stickerPack.isMask) {
        packIsMask = true;
    }
    if (packReference == nil) {
        packReference = stickerPack.packReference;
    }
    __weak UIViewController *weakParentController = controller.parentController;
    __weak TGMenuSheetController *weakController = controller;
    __weak TGMenuSheetButtonItemView *weakItemView = itemView;
    if (installed)
    {
        return ^
        {
            __strong TGMenuSheetButtonItemView *strongItemView = weakItemView;
            __strong TGMenuSheetController *strongController = weakController;
            if (strongItemView == nil || strongController == nil)
                return;
         
            if (isBuiltin)
            {
                [[TGStickersSignals toggleStickerPackHidden:packReference hidden:true] startWithNext:nil];
            }
            else
            {
                if (packIsMask) {
                    [[TGMaskStickersSignals removeStickerPack:packReference hintArchived:packIsArchived] startWithNext:nil];
                } else {
                    [[TGStickersSignals removeStickerPack:packReference hintArchived:packIsArchived] startWithNext:nil];
                }
            }
            
            [TGStickersMenu updateModifyButtonItemView:strongItemView installed:false stickerPack:stickerPack isBuiltin:isBuiltin];
            strongItemView.action = [TGStickersMenu modifyButtonActionForItemView:strongItemView packReference:packReference stickerPack:stickerPack controller:strongController firstInstallation:firstInstallation isBuiltin:isBuiltin installed:false isMask:stickerPack.isMask];
        };
    }
    else
    {
        return ^
        {
            __strong TGMenuSheetButtonItemView *strongItemView = weakItemView;
            __strong TGMenuSheetController *strongController = weakController;
            if (strongItemView == nil || strongController == nil)
                return;
            
            if (isBuiltin)
            {
                [[TGStickersSignals toggleStickerPackHidden:packReference hidden:false] startWithNext:nil];
  
                [TGStickersMenu updateModifyButtonItemView:strongItemView installed:true stickerPack:stickerPack isBuiltin:isBuiltin];
            }
            else
            {
                if (firstInstallation) {
                    [[[TGProgressWindow alloc] init] dismissWithSuccess];
                }
                
                SSignal *installStickerPackAndGetArchivedSignal = packIsMask ? [TGMaskStickersSignals installStickerPackAndGetArchived:packReference hintUnarchive:packIsArchived] : [TGStickersSignals installStickerPackAndGetArchived:packReference hintUnarchive:packIsArchived];
                    
                [[installStickerPackAndGetArchivedSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *archivedPacks)
                {
                    if (archivedPacks.count != 0) {
                        __strong TGViewController *strongParentController = (TGViewController *)weakParentController;
                        if ([strongParentController isKindOfClass:[TGViewController class]]) {
                            TGArchivedStickerPacksAlert *previewWindow = [[TGArchivedStickerPacksAlert alloc] initWithParentController:strongParentController stickerPacks:archivedPacks];
                            __weak TGArchivedStickerPacksAlert *weakPreviewWindow = previewWindow;
                            previewWindow.view.dismiss = ^
                            {
                                __strong TGArchivedStickerPacksAlert *strongPreviewWindow = weakPreviewWindow;
                                if (strongPreviewWindow != nil)
                                    [strongPreviewWindow dismiss];
                            };
                            previewWindow.hidden = false;
                        }
                    }
                }];
                
                if (firstInstallation)
                    [controller dismissAnimated:true];
                else
                    [TGStickersMenu updateModifyButtonItemView:strongItemView installed:true stickerPack:stickerPack isBuiltin:isBuiltin];
            }
            strongItemView.action = [TGStickersMenu modifyButtonActionForItemView:strongItemView packReference:packReference stickerPack:stickerPack controller:strongController firstInstallation:firstInstallation isBuiltin:isBuiltin installed:true isMask:stickerPack.isMask];
        };
    }
}

+ (void (^)(void))shareButtonActionForController:(TGMenuSheetController *)controller stickerPack:(TGStickerPack *)stickerPack
{
    __weak TGMenuSheetController *weakController = controller;
    return ^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController != nil)
            [TGStickersMenu shareStickerPack:stickerPack menuController:strongController];
    };
}

+ (void)updateModifyButtonItemView:(TGMenuSheetButtonItemView *)itemView installed:(bool)installed stickerPack:(TGStickerPack *)stickerPack isBuiltin:(bool)isBuiltin
{
    NSInteger count = stickerPack.documents.count;
    if (isBuiltin)
    {
        if (installed)
        {
            [itemView setTitle:TGLocalized(@"StickerPack.HideStickers")];
            [itemView setButtonType:TGMenuSheetButtonTypeDestructive];
        }
        else
        {
            [itemView setTitle:TGLocalized(@"StickerPack.ShowStickers")];
            [itemView setButtonType:TGMenuSheetButtonTypeDefault];
        }
    }
    else
    {
        if (installed)
        {
            NSString *title = TGLocalized(@"StickerPack.Remove");
            if (stickerPack != nil && count > 0)
            {
                title = [NSString stringWithFormat:TGLocalized([TGStringUtils integerValueFormat:stickerPack.isMask ? @"StickerPack.RemoveMaskCount_" : @"StickerPack.RemoveStickerCount_" value:count]), [NSString stringWithFormat:@"%d", (int)stickerPack.documents.count]];
            }
            [itemView setTitle:title];
            [itemView setButtonType:TGMenuSheetButtonTypeDestructive];
        }
        else
        {
            NSString *title = TGLocalized(@"StickerPack.Add");
            if (stickerPack != nil & count > 0)
            {
                title = [NSString stringWithFormat:TGLocalized([TGStringUtils integerValueFormat:stickerPack.isMask ? @"StickerPack.AddMaskCount_" : @"StickerPack.AddStickerCount_" value:count]), [NSString stringWithFormat:@"%d", (int)stickerPack.documents.count]];
            }
            [itemView setTitle:title];
            [itemView setButtonType:TGMenuSheetButtonTypeDefault];
        }
    }
}

@end
