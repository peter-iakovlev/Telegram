#import "TGSecretChatUserInfoController.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGUserInfoVariantCollectionItem.h"

#import "TGEncryptionKeyViewController.h"

#import "TGActionSheet.h"

#import <MTProtoKit/MTEncryption.h>

@interface TGSecretChatUserInfoController ()
{
    TGUserInfoVariantCollectionItem *_encryptionKeyItem;
    
    int _selfDestructTimer;
    int64_t _peerId;
    int64_t _encryptedConversationId;

    NSData *_additionalSignature;
    NSData *_encryptionKeySignature;
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
        
        NSData *additionalSignature = nil;
        _encryptionKeySignature = [TGDatabaseInstance() encryptionKeySignatureForConversationId:_peerId additionalSignature:&additionalSignature];
        _additionalSignature = additionalSignature;
        
        [self setTitleText:TGLocalized(@"SecretChat.Title")];
        
        _encryptionKeyItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Profile.EncryptionKey") variant:nil action:@selector(encryptionKeyPressed)];
        
        _selfDestructTimer = [TGDatabaseInstance() messageLifetimeForPeerId:_peerId];
        
        [self _updateSecretDataItems];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
               [[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/conversation", _peerId]
            ] watcher:self];
        }];
    }
    return self;
}

- (void)_updateSecretDataItems
{
    bool needsReload = false;
    
    if (_encryptionKeySignature.length == 0)
    {
        NSIndexPath *sharedMediaIndexPath = [self indexPathForItem:self.sharedMediaItem];
        if (sharedMediaIndexPath != nil)
        {
            [self.menuSections deleteItemFromSection:sharedMediaIndexPath.section atIndex:sharedMediaIndexPath.item];
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
            
            if ([self indexPathForItem:_encryptionKeyItem] == nil)
            {
                [self.menuSections addItemToSection:dataSectionIndex item:_encryptionKeyItem];
                needsReload = true;
            }
        }
    }
    
    if ((_encryptionKeySignature.length == 0) != (_encryptionKeyItem.variantImage == nil))
    {
        if (_encryptionKeySignature.length == 0)
            _encryptionKeyItem.variantImage = nil;
        else
        {
            NSData *hashData = _encryptionKeySignature;
            _encryptionKeyItem.variantImage = TGIdenticonImage(hashData, _additionalSignature, CGSizeMake(24, 24));
        }
    }
    
    if (needsReload)
        [self.collectionView reloadData];
}

- (void)encryptionKeyPressed
{
    [self.navigationController pushViewController:[[TGEncryptionKeyViewController alloc] initWithEncryptedConversationId:_encryptedConversationId userId:self.uid] animated:true];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/conversation", _peerId]])
    {
        NSData *additionalSignature = nil;
        NSData *keySignatureData = [TGDatabaseInstance() encryptionKeySignatureForConversationId:_peerId additionalSignature:&additionalSignature];
        TGDispatchOnMainThread(^
        {
            if ((keySignatureData != nil) != (_encryptionKeySignature != nil))
            {
                _encryptionKeySignature = keySignatureData;
                _additionalSignature = additionalSignature;
                
                [self _updateSecretDataItems];
            }
        });
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

@end
