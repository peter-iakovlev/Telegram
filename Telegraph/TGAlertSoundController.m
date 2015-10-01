/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAlertSoundController.h"

#import "TGHeaderCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGAppDelegate.h"

@interface TGAlertSoundController ()
{
    NSArray *_soundInfoList;
}

@end

@implementation TGAlertSoundController

- (id)initWithTitle:(NSString *)title soundInfoList:(NSArray *)soundInfoList
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:title];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        _soundInfoList = soundInfoList;
        
        NSMutableArray *alertTonesSectionItems = [[NSMutableArray alloc] init];
        [alertTonesSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.AlertTones")]];
        
        NSMutableArray *classicTonesSectionItems = [[NSMutableArray alloc] init];
        [classicTonesSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.ClassicTones")]];

        for (int groupId = 0; groupId < 2; groupId++)
        {
            int index = -1;
            for (NSDictionary *desc in _soundInfoList)
            {
                index++;
                
                if ([desc[@"groupId"] intValue] != groupId)
                    continue;
                
                TGCheckCollectionItem *checkItem = [[TGCheckCollectionItem alloc] initWithTitle:desc[@"title"] action:@selector(alertTonePressed:)];
                
                if (index == 1)
                    checkItem.requiresFullSeparator = true;
                
                [checkItem setIsChecked:[desc[@"selected"] boolValue]];
                
                if (groupId == 0)
                    [alertTonesSectionItems addObject:checkItem];
                else
                    [classicTonesSectionItems addObject:checkItem];
            }
        }
        
        TGCollectionMenuSection *alertTonesSection = [[TGCollectionMenuSection alloc] initWithItems:alertTonesSectionItems];
        
        UIEdgeInsets topSectionInsets = alertTonesSection.insets;
        topSectionInsets.top = 32.0f;
        alertTonesSection.insets = topSectionInsets;
        [self.menuSections addSection:alertTonesSection];
        
        if (classicTonesSectionItems.count > 1)
        {
            TGCollectionMenuSection *classicTonesSection = [[TGCollectionMenuSection alloc] initWithItems:classicTonesSectionItems];
            [self.menuSections addSection:classicTonesSection];
        }
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    int soundId = [self _selectedSoundId];
    
    if (soundId != -1)
    {
        id<TGAlertSoundControllerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(alertSoundController:didFinishPickingWithSoundInfo:)])
            [delegate alertSoundController:self didFinishPickingWithSoundInfo:_soundInfoList[soundId]];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)alertTonePressed:(TGCheckCollectionItem *)checkCollectionItem
{
    NSIndexPath *indexPath = [self indexPathForItem:checkCollectionItem];
    if (indexPath != nil)
    {
        [self _selectItem:checkCollectionItem];
        [self _playSoundWithId:[self soundIdFromItemIndexPath:indexPath]];
    }
}

- (int)soundIdFromItemIndexPath:(NSIndexPath *)indexPath
{
    return (int)(indexPath.section == 0 ? (indexPath.row - 1) : (indexPath.row - 1 + ((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count - 1));
}

- (int)_selectedSoundId
{
    for (int sectionIndex = 0; sectionIndex < (int)self.menuSections.sections.count; sectionIndex++)
    {
        int index = -1;
        for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[sectionIndex]).items)
        {
            index++;
            
            if ([item isKindOfClass:[TGCheckCollectionItem class]])
            {
                if (((TGCheckCollectionItem *)item).isChecked)
                    return [self soundIdFromItemIndexPath:[NSIndexPath indexPathForItem:index inSection:sectionIndex]];
            }
        }
    }
    
    return -1;
}

- (void)_selectItem:(TGCheckCollectionItem *)checkCollectionItem
{
    for (int sectionIndex = 0; sectionIndex < (int)self.menuSections.sections.count; sectionIndex++)
    {
        for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[sectionIndex]).items)
        {
            if ([item isKindOfClass:[TGCheckCollectionItem class]])
            {
                if (item == checkCollectionItem)
                    [(TGCheckCollectionItem *)item setIsChecked:true];
                else
                    [(TGCheckCollectionItem *)item setIsChecked:false];
            }
        }
    }
}

- (void)_playSoundWithId:(int)soundId
{
    if (soundId != 0 && [(NSString *)_soundInfoList[soundId][@"soundName"] length] != 0)
    {
        [TGAppDelegateInstance playNotificationSound:_soundInfoList[soundId][@"soundName"]];
    }
}

@end
