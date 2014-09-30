/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSecretChatUserInfoController.h"

#import "ActionStage.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGUserInfoVariantCollectionItem.h"

#import "TGEncryptionKeyViewController.h"

#import "TGActionSheet.h"

#import <MTProtoKit/MTEncryption.h>
#import "TGImageUtils.h"
#import "TGStringUtils.h"

@interface TGSecretChatUserInfoController ()
{
    TGUserInfoVariantCollectionItem *_selfDestructTimerItem;
    TGUserInfoVariantCollectionItem *_encryptionKeyItem;
    
    int _selfDestructTimer;
    int64_t _peerId;
    int64_t _encryptedConversationId;
    
    NSData *_encryptionKey;
}

@end

@implementation TGSecretChatUserInfoController

- (instancetype)initWithUid:(int32_t)uid encryptedConversationId:(int64_t)encryptedConversationId
{
    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:encryptedConversationId createIfNecessary:false];
    
    self = [super initWithUid:uid withoutActions:true sharedMediaPeerId:peerId sharedMediaOptions:@{@"encryptedConversationId": @(encryptedConversationId), @"isEncrypted": @(true)}];
    if (self != nil)
    {
        _peerId = peerId;
        _encryptedConversationId = encryptedConversationId;
        
        _encryptionKey = [TGDatabaseInstance() encryptionKeyForConversationId:peerId keyFingerprint:NULL];
        
        [self setTitleText:TGLocalized(@"SecretChat.Title")];
        
        _selfDestructTimerItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Profile.MessageLifetime") variant:nil action:@selector(selfDestructTimerPressed)];
        _selfDestructTimerItem.deselectAutomatically = true;
        _encryptionKeyItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Profile.EncryptionKey") variant:nil action:@selector(encryptionKeyPressed)];
        
        _selfDestructTimer = [TGDatabaseInstance() messageLifetimeForPeerId:_peerId];
        
        [self _updateSecretDataItems];
        [self _updateSelfDestructTimer];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
               [[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/conversation", _peerId],
               [[NSString alloc] initWithFormat:@"/tg/encrypted/messageLifetime/(%" PRId64 ")", _peerId]
            ] watcher:self];
        }];
    }
    return self;
}

- (void)_updateSecretDataItems
{
    bool needsReload = false;
    
    if (_encryptionKey.length == 0)
    {
        NSIndexPath *sharedMediaIndexPath = [self indexPathForItem:self.sharedMediaItem];
        if (sharedMediaIndexPath != nil)
        {
            [self.menuSections deleteItemFromSection:sharedMediaIndexPath.section atIndex:sharedMediaIndexPath.item];
            needsReload = true;
        }
        
        NSIndexPath *timerIndexPath = [self indexPathForItem:_selfDestructTimerItem];
        if (timerIndexPath != nil)
        {
            [self.menuSections deleteItemFromSection:timerIndexPath.section atIndex:timerIndexPath.item];
            needsReload = true;
        }
        
        NSIndexPath *keyIndexPath = [self indexPathForItem:_encryptionKeyItem];
        if (keyIndexPath != nil)
        {
            [self.menuSections deleteItemFromSection:keyIndexPath.section atIndex:keyIndexPath.item];
            needsReload = true;
        }
    }
    else
    {
        NSUInteger dataSectionIndex = [self indexForSection:self.sharedMediaSection];
        if (dataSectionIndex != NSNotFound)
        {
            if ([self indexPathForItem:self.sharedMediaItem] == nil)
            {
                [self.menuSections addItemToSection:dataSectionIndex item:self.sharedMediaItem];
                needsReload = true;
            }
            
            if ([self indexPathForItem:_selfDestructTimerItem] == nil)
            {
                [self.menuSections addItemToSection:dataSectionIndex item:_selfDestructTimerItem];
                needsReload = true;
            }
            
            if ([self indexPathForItem:_encryptionKeyItem] == nil)
            {
                [self.menuSections addItemToSection:dataSectionIndex item:_encryptionKeyItem];
                needsReload = true;
            }
        }
    }
    
    if ((_encryptionKey.length == 0) != (_encryptionKeyItem.variantImage == nil))
    {
        if (_encryptionKey.length == 0)
            _encryptionKeyItem.variantImage = nil;
        else
        {
            NSData *hashData = MTSha1(_encryptionKey);
            _encryptionKeyItem.variantImage = TGIdenticonImage(hashData, CGSizeMake(24, 24));
        }
    }
    
    if (needsReload)
        [self.collectionView reloadData];
}

- (void)selfDestructTimerPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    NSArray *values = @[@0, @2, @5, @(1 * 60), @(1 * 60 * 60), @(1 * 60 * 60 * 24), @(7 * 60 * 60 * 24)];
    
    int index = -1;
    for (NSNumber *item in values)
    {
        index++;
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[item intValue] == 0 ? TGLocalized(@"Profile.MessageLifetimeForever") : [TGStringUtils stringForMessageTimerSeconds:[item intValue]] action:[[NSString alloc] initWithFormat:@"%@", values[index]]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGSecretChatUserInfoController *controller, NSString *action)
    {
        if (![action isEqualToString:@"cancel"])
            [controller _commitSetSelfDestructTimer:[action intValue]];
    } target:self] showInView:self.view];
}


- (void)_commitSetSelfDestructTimer:(int)value
{
    if (value != _selfDestructTimer)
    {
        _selfDestructTimer = value;
        
        [TGDatabaseInstance() setMessageLifetimeForPeerId:_peerId encryptedConversationId:_encryptedConversationId messageLifetime:value writeToActionQueue:true];
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        [self _updateSelfDestructTimer];
    }
}

- (void)encryptionKeyPressed
{
    [self.navigationController pushViewController:[[TGEncryptionKeyViewController alloc] initWithEncryptedConversationId:_encryptedConversationId userId:self.uid] animated:true];
}

- (void)_updateSelfDestructTimer
{
    int messageLifetime = _selfDestructTimer;
    if (messageLifetime == 0)
        _selfDestructTimerItem.variant = TGLocalized(@"Profile.MessageLifetimeForever");
    else
        _selfDestructTimerItem.variant = [TGStringUtils stringForShortMessageTimerSeconds:messageLifetime];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path hasPrefix:@"/tg/encrypted/messageLifetime/"])
    {
        TGDispatchOnMainThread(^
        {
            _selfDestructTimer = [resource intValue];
            [self _updateSelfDestructTimer];
        });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/conversation", _peerId]])
    {
        int64_t keyId = 0;
        NSData *keyData = [TGDatabaseInstance() encryptionKeyForConversationId:_peerId keyFingerprint:&keyId];
        TGDispatchOnMainThread(^
        {
            if ((keyData != nil) != (_encryptionKey != nil))
            {
                _encryptionKey = keyData;
                
                
                
                [self _updateSecretDataItems];
            }
        });
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

@end
