/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoController.h"

#import "ActionStage.h"
#import "TGDatabase.h"

#import "TGUserInfoCollectionItem.h"

@interface TGUserInfoController ()
{
    TGUser *_user;
}

@end

@implementation TGUserInfoController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _userInfoItem = [[TGUserInfoCollectionItem alloc] init];
        _userInfoItem.transparent = true;
        _userInfoItem.interfaceHandle = _actionHandle;
        
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _userInfoItem
        ]];
        UIEdgeInsets infoSectionInsets = infoSection.insets;
        infoSectionInsets.bottom = 0.0f;
        infoSection.insets = infoSectionInsets;
        [self.menuSections addSection:infoSection];
        
        _callsSection = [[TGCollectionMenuSection alloc] init];
        UIEdgeInsets callsSectionInsets = _callsSection.insets;
        callsSectionInsets.bottom = 0.0f;
        _callsSection.insets = callsSectionInsets;
        [self.menuSections addSection:_callsSection];
        
        _phonesSection = [[TGCollectionMenuSection alloc] init];
        UIEdgeInsets phonesSectionInsets = _phonesSection.insets;
        phonesSectionInsets.bottom = 0.0f;
        _phonesSection.insets = phonesSectionInsets;
        [self.menuSections addSection:_phonesSection];
        
        _usernameSection = [[TGCollectionMenuSection alloc] init];
        UIEdgeInsets aboutSectionInsets = _usernameSection.insets;
        aboutSectionInsets.top = 0.0f;
        aboutSectionInsets.bottom = 22.0f;
        _usernameSection.insets = aboutSectionInsets;
        [self.menuSections addSection:_usernameSection];
        
        _actionsSection = [[TGCollectionMenuSection alloc] init];
        UIEdgeInsets actionsSectionInsets = _actionsSection.insets;
        actionsSectionInsets.bottom = 44.0f;
        _actionsSection.insets = actionsSectionInsets;
        [self.menuSections addSection:_actionsSection];
    }
    return self;
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)__unused action options:(id)__unused options
{
}

- (void)actionStageResourceDispatched:(NSString *)__unused path resource:(id)__unused resource arguments:(id)__unused arguments
{
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
}

@end
