#import "TGUserInfoCollectionItem.h"

#import "TGUserInfoCollectionItemView.h"

#import "TGRemoteImageView.h"
#import "TGDateUtils.h"

@interface TGUserInfoCollectionItem ()
{
    TGUser *_user;
    bool _editing;
    
    NSString *_updatingFirstName;
    NSString *_updatingLastName;
    UIImage *_updatingAvatar;
    bool _hasUpdatingAvatar;
    
    NSString *_editingFirstName;
    NSString *_editingLastName;
    
    bool _firstBind;
}

@end

@implementation TGUserInfoCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.selectable = false;
        self.highlightable = false;
        _firstBind = true;
        
        _automaticallyManageUserPresence = true;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (Class)itemViewClass
{
    return [TGUserInfoCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 97.0f + _additinalHeight);
}

- (NSString *)currentFirstName
{
    return (_updatingFirstName != nil || _updatingLastName != nil) ? _updatingFirstName : (_useRealName ? _user.realFirstName : [_user.firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
}

- (NSString *)currentLastName
{
    return (_updatingFirstName != nil || _updatingLastName != nil) ? _updatingLastName : (_useRealName ? _user.realLastName : [_user.lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
}

- (void)bindView:(TGUserInfoCollectionItemView *)view
{
    [super bindView:view];
    
    view.itemHandle = _actionHandle;
    
    [view setAvatarOffset:_avatarOffset];
    [view setNameOffset:_nameOffset];
    [view setFirstName:[self currentFirstName] lastName:[self currentLastName] uidForPlaceholderCalculation:_user.uid];
    view.isVerified = _user.isVerified;
    
    if (!_disableAvatar)
    {
        if (_hasUpdatingAvatar)
            [view setAvatarImage:_updatingAvatar animated:false];
        else
            [view setAvatarUri:_user.photoUrlSmall animated:false synchronous:_firstBind];
    }
    
    if (_automaticallyManageUserPresence)
    {
        bool active = false;
        NSString *status = [self stringForPresence:_user.presence accentColored:&active];
        [view setStatus:status active:active];
    }
    else
        [view setStatus:_customStatus active:false];
    
    [view setUpdatingAvatar:_hasUpdatingAvatar animated:false];
    
    if (_editing)
    {
        _editingFirstName = _useRealName ? _user.realFirstName : _user.firstName;
        _editingLastName = _useRealName ? _user.realLastName : _user.lastName;
    }
    
    [view setEditing:_editing animated:false];
    
    [view setShowCall:_showCall];
    
    _firstBind = false;
}

- (void)unbindView
{
    ((TGUserInfoCollectionItemView *)[self boundView]).itemHandle = nil;
    
    [super unbindView];
}

- (void)setUser:(TGUser *)user animated:(bool)animated
{
    _user = user;
    
    if (!_editing)
    {
        _editingFirstName = user.realFirstName;
        _editingLastName = user.realLastName;
    }
    
    if ([self boundView] != nil)
    {
        TGUserInfoCollectionItemView *view = (TGUserInfoCollectionItemView *)[self boundView];
        
        [view setFirstName:[self currentFirstName] lastName:[self currentLastName] uidForPlaceholderCalculation:_user.uid];
        
        if (!_disableAvatar)
        {
            if (_hasUpdatingAvatar)
            {
                if (_updatingAvatar != nil)
                    [view setAvatarImage:_updatingAvatar animated:animated];
            }
            else
            {
                [view setAvatarUri:_user.photoUrlSmall animated:animated synchronous:false];
            }
        }
        
        if (_automaticallyManageUserPresence)
        {
            bool active = false;
            NSString *status = [self stringForPresence:_user.presence accentColored:&active];
            [view setStatus:status active:active];
        }
        
        view.isVerified = _user.isVerified;
    }
}

- (void)setCustomStatus:(NSString *)customStatus
{
    _customStatus = customStatus;
    
    if (!_automaticallyManageUserPresence)
        [(TGUserInfoCollectionItemView *)self.boundView setStatus:_customStatus active:false];
}

- (void)setEditing:(bool)editing animated:(bool)animated
{
    _editing = editing;
    
    if (self.view != nil)
        [((TGUserInfoCollectionItemView *)self.view) setEditing:editing animated:animated];
    
    if (_editing)
    {
        _editingFirstName = _useRealName ? _user.realFirstName : _user.firstName;
        _editingLastName = _useRealName ? _user.realLastName : _user.lastName;
    }
}

- (void)setUpdatingFirstName:(NSString *)updatingFirstName updatingLastName:(NSString *)updatingLastName
{
    if (!TGStringCompare(_updatingFirstName, updatingFirstName) || !TGStringCompare(_updatingLastName, updatingLastName))
    {
        _updatingFirstName = updatingFirstName;
        _updatingLastName = updatingLastName;
        
        [((TGUserInfoCollectionItemView *)[self boundView]) setFirstName:[self currentFirstName] lastName:[self currentLastName] uidForPlaceholderCalculation:_user.uid];
    }
}

- (void)setUpdatingAvatar:(UIImage *)updatingAvatar hasUpdatingAvatar:(bool)hasUpdatingAvatar
{
    if (_updatingAvatar != updatingAvatar || _hasUpdatingAvatar != hasUpdatingAvatar)
    {
        _updatingAvatar = updatingAvatar;
        _hasUpdatingAvatar = hasUpdatingAvatar;
        
        if ([self boundView] != nil)
        {
            TGUserInfoCollectionItemView *view = (TGUserInfoCollectionItemView *)[self boundView];
            
            if (!_disableAvatar)
            {
                if (_hasUpdatingAvatar)
                    [view setAvatarImage:_updatingAvatar animated:false];
                else
                    [view setAvatarUri:_user.photoUrlSmall animated:false synchronous:false];
            }
            
            [view setUpdatingAvatar:_hasUpdatingAvatar animated:true];
        }
    }
}

- (void)resetUpdatingAvatar:(NSString *)url
{
    _updatingAvatar = nil;
    _hasUpdatingAvatar = false;
    
    if ([self boundView] != nil)
    {
        TGUserInfoCollectionItemView *view = (TGUserInfoCollectionItemView *)[self boundView];
     
        if (!_disableAvatar)
        {
            if (url != nil)
                [view setAvatarUri:url animated:false synchronous:false];
        }
        
        [view setUpdatingAvatar:_hasUpdatingAvatar animated:true];
    }
}

- (void)setHasUpdatingAvatar:(bool)hasUpdatingAvatar
{
    _hasUpdatingAvatar = hasUpdatingAvatar;
    
    if ([self boundView] != nil)
    {
        TGUserInfoCollectionItemView *view = (TGUserInfoCollectionItemView *)[self boundView];
        [view setUpdatingAvatar:_hasUpdatingAvatar animated:true];
    }
}

- (bool)hasUpdatingAvatar
{
    return _updatingAvatar;
}

- (void)updateTimestamp
{
    if (_automaticallyManageUserPresence)
    {
        bool active = false;
        NSString *status = [self stringForPresence:_user.presence accentColored:&active];
        [(TGUserInfoCollectionItemView *)[self boundView] setStatus:status active:active];
    }
}

- (NSString *)stringForPresence:(TGUserPresence)presence accentColored:(bool *)accentColored
{
    if (presence.online)
    {
        if (accentColored != NULL)
            *accentColored = true;
        return TGLocalized(@"Presence.online");
    }
    if (presence.lastSeen != 0)
        return [TGDateUtils stringForRelativeLastSeen:presence.lastSeen];
    
    return TGLocalized(@"Presence.offline");
}

- (id)avatarView
{
    return [(TGUserInfoCollectionItemView *)[self boundView] avatarView];
}

- (id)visibleAvatarView
{
    if (self.view != nil)
        return [((TGUserInfoCollectionItemView *)self.view) avatarView];
    
    return nil;
}

- (void)makeNameFieldFirstResponder
{
    [((TGUserInfoCollectionItemView *)self.view) makeNameFieldFirstResponder];
}

- (void)copyUpdatingAvatarToCacheWithUri:(NSString *)uri
{
    if ([self boundView] != nil && _updatingAvatar != nil && uri != nil)
    {
        [[TGRemoteImageView sharedCache] cacheImage:_updatingAvatar withData:nil url:[[NSString alloc] initWithFormat:@"{filter:circle:64x64}%@", uri] availability:TGCacheMemory];
    }
}

- (NSString *)editingFirstName
{
    return _editingFirstName;
}

- (NSString *)editingLastName
{
    return _editingLastName;
}

- (void)setShowCall:(bool)showCall
{
    _showCall = showCall;
    [((TGUserInfoCollectionItemView *)self.view) setShowCall:showCall];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"avatarTapped"] || [action isEqualToString:@"callTapped"])
    {
        [_interfaceHandle requestAction:action options:options];
    }
    else if ([action isEqualToString:@"editingNameChanged"])
    {
        if ([options[@"field"] isEqualToString:@"firstName"])
            _editingFirstName = options[@"text"];
        else if ([options[@"field"] isEqualToString:@"lastName"])
            _editingLastName = options[@"text"];
        
        [_interfaceHandle requestAction:@"editingNameChanged" options:nil];
    }
}

@end
