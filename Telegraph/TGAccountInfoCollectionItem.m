/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAccountInfoCollectionItem.h"

#import "TGUserInfoCollectionItemView.h"

@interface TGAccountInfoCollectionItem ()
{
    int _synchronizationStatus;
}

@end

@implementation TGAccountInfoCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.automaticallyManageUserPresence = false;
        self.useRealName = true;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.additinalHeight = 5.0f;
            self.avatarOffset = CGSizeMake(2.0f, 2.0f + (([UIScreen mainScreen].scale > 1.0f + FLT_EPSILON) ? 0.5f : 0.0f));
            self.nameOffset = CGSizeMake(2.0f, 1.0f);
        }
    }
    return self;
}

- (void)bindView:(TGUserInfoCollectionItemView *)view
{
    [super bindView:view];
    
    bool active = false;
    NSString *status = [self stringForSynchronizationStatus:_synchronizationStatus active:&active];
    [view setStatus:status active:active];
}

- (NSString *)stringForSynchronizationStatus:(int)status active:(bool *)active
{
    NSString *text = @"";
    
    if (status == 1)
        text = TGLocalized(@"State.connecting");
    else if (status == 2)
        text = TGLocalized(@"State.updating");
    else
    {
        text = TGLocalized(@"Presence.online");
        if (active != NULL)
            *active = true;
    }
    
    return text;
}

- (void)setSynchronizationStatus:(int)status
{
    _synchronizationStatus = status;
    
    if (self.view != nil)
    {
        bool active = false;
        NSString *status = [self stringForSynchronizationStatus:_synchronizationStatus active:&active];
        [((TGUserInfoCollectionItemView *)self.view) setStatus:status active:active];
    }
}

- (void)localizationUpdated
{
    if (self.view != nil)
    {
        bool active = false;
        NSString *status = [self stringForSynchronizationStatus:_synchronizationStatus active:&active];
        [((TGUserInfoCollectionItemView *)self.view) setStatus:status active:active];
    }
}

@end
