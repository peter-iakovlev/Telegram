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
    TGCheckCollectionItem *_defaultCheckItem;
    NSNumber *_defaultSoundId;
}

@end

@implementation TGAlertSoundController

- (id)initWithTitle:(NSString *)title soundInfoList:(NSArray *)soundInfoList defaultId:(NSNumber *)defaultId
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:title];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        _defaultSoundId = defaultId;
        _soundInfoList = soundInfoList;
        
        NSMutableArray *alertTonesSectionItems = [[NSMutableArray alloc] init];
        [alertTonesSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.AlertTones")]];
        
        NSMutableArray *classicTonesSectionItems = [[NSMutableArray alloc] init];
        [classicTonesSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.ClassicTones")]];

        bool hasSelected = false;
        for (int groupId = 0; groupId < 2; groupId++)
        {
            int index = -1;
            for (NSDictionary *desc in _soundInfoList)
            {
                index++;
                
                if ([desc[@"groupId"] intValue] != groupId)
                    continue;
                
                if (groupId == 0 && index == 1 && defaultId != nil)
                {
                    _defaultCheckItem = [[TGCheckCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"UserInfo.NotificationsDefaultSound"), [TGAlertSoundController soundNameFromId:defaultId.intValue]] action:@selector(alertTonePressed:)];
                    [alertTonesSectionItems addObject:_defaultCheckItem];
                }
                
                TGCheckCollectionItem *checkItem = [[TGCheckCollectionItem alloc] initWithTitle:desc[@"title"] action:@selector(alertTonePressed:)];
                if (index == 1)
                    checkItem.requiresFullSeparator = true;
                
                [checkItem setIsChecked:[desc[@"selected"] boolValue]];
                if (checkItem.isChecked)
                    hasSelected = true;
                
                if (groupId == 0)
                    [alertTonesSectionItems addObject:checkItem];
                else
                    [classicTonesSectionItems addObject:checkItem];
            }
        }
        
        if (!hasSelected)
            _defaultCheckItem.isChecked = true;
        
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

+ (NSString *)soundNameFromId:(int)soundId
{
    if (soundId == 0 || soundId == 1)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId];
    if (soundId >= 2 && soundId <= 9)
        return [TGAppDelegateInstance classicAlertSoundTitles][MAX(0, soundId - 2)];
    if (soundId >= 100 && soundId <= 111)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId - 100 + 1];
    return @"";
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    NSNumber *soundId = [self _selectedSoundId];
    
    id<TGAlertSoundControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(alertSoundController:didFinishPickingWithSoundInfo:)])
        [delegate alertSoundController:self didFinishPickingWithSoundInfo:soundId ? _soundInfoList[soundId.intValue] : nil];
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)alertTonePressed:(TGCheckCollectionItem *)checkCollectionItem
{
    NSIndexPath *indexPath = [self indexPathForItem:checkCollectionItem];
    if (indexPath != nil)
    {
        [self _selectItem:checkCollectionItem];
        if (checkCollectionItem == _defaultCheckItem)
        {
            if (_defaultSoundId.intValue != 0)
                [TGAppDelegateInstance playNotificationSound:[NSString stringWithFormat:@"%d", _defaultSoundId.intValue]];
        }
        else
        {
            [self _playSoundWithId:[self soundIdFromItemIndexPath:indexPath]];
        }
    }
}

- (int)soundIdFromItemIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (_defaultCheckItem != nil && indexPath.row > 1)
            return (indexPath.row - 2);
        else
            return (indexPath.row - 1);
    } else {
        return (indexPath.row - 1 + ((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count - 1) - (_defaultCheckItem != nil ? 1 : 0);
    }
}

- (NSNumber *)_selectedSoundId
{
    if (_defaultCheckItem.isChecked)
        return nil;
    
    for (int sectionIndex = 0; sectionIndex < (int)self.menuSections.sections.count; sectionIndex++)
    {
        int index = -1;
        for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[sectionIndex]).items)
        {
            index++;
            
            if ([item isKindOfClass:[TGCheckCollectionItem class]])
            {
                if (((TGCheckCollectionItem *)item).isChecked)
                    return @([self soundIdFromItemIndexPath:[NSIndexPath indexPathForItem:index inSection:sectionIndex]]);
            }
        }
    }
    
    return nil;
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
