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
    NSString *_status;
    bool _active;
    
    NSString *_phoneNumber;
    NSString *_username;
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

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)bindView:(TGUserInfoCollectionItemView *)view
{
    [super bindView:view];
    
    [view setStatus:_status active:_active];
    [view setShowDisclosureIndicator:self.hasDisclosureIndicator];
    [view setPhoneNumber:_phoneNumber];
    [view setUsername:_username];
    [view setShowCameraIcon:_showCameraIcon];
}

- (void)setHasDisclosureIndicator:(bool)flag
{
    _hasDisclosureIndicator = flag;
    [(TGUserInfoCollectionItemView *)self.boundView setShowDisclosureIndicator:flag];
}

- (void)setShowCameraIcon:(bool)flag
{
    _showCameraIcon = flag;
    [(TGUserInfoCollectionItemView *)self.boundView setShowCameraIcon:flag];
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    [((TGUserInfoCollectionItemView *)self.view) setPhoneNumber:phoneNumber];
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    [((TGUserInfoCollectionItemView *)self.view) setUsername:username];
}

- (void)setStatus:(NSString *)status active:(bool)active
{
    _status = status;
    _active = active;
    [((TGUserInfoCollectionItemView *)self.view) setStatus:status active:active];
}

- (void)localizationUpdated
{
}

@end
