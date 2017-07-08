/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernLetteredAvatarViewModel.h"

#import "TGModernLetteredAvatarView.h"

@interface TGModernLetteredAvatarViewModel ()
{
    CGSize _size;
    UIImage *_placeholder;
    NSString *_filter;
    
    NSString *_avatarUri;
    
    NSString *_firstName;
    NSString *_lastName;
    NSString *_title;
    int32_t _uid;
    int64_t _groupId;
}

@end

@implementation TGModernLetteredAvatarViewModel

- (instancetype)initWithSize:(CGSize)size placeholder:(UIImage *)placeholder
{
    self = [super init];
    if (self != nil)
    {
        _size = size;
        _placeholder = placeholder;
        _filter = [[NSString alloc] initWithFormat:@"circle:%dx%d", (int)_size.width, (int)_size.height];
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernLetteredAvatarView class];
}

- (void)_updateViewStateIdentifier
{
    if (_avatarUri.length != 0)
    {
        self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGModernRemoteImageView/%@/%@/%@/%@/%" PRId32 "", _filter, _avatarUri, nil, nil, 0];
    }
    else
    {
        self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGModernRemoteImageView/%@/%@/%@/%@/%" PRId32 "", nil, nil, _firstName, _lastName, _uid];
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _updateViewStateIdentifier];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernLetteredAvatarView *view = (TGModernLetteredAvatarView *)[self boundView];
    [view setSingleFontSize:16.0f doubleFontSize:16.0f useBoldFont:false];
    view.fadeTransition = true;
    
    if (_avatarUri.length == 0) {
        if (_uid != 0) {
            [view setFirstName:_firstName lastName:_lastName uid:_uid placeholder:_placeholder];
        } else if (_groupId != 0) {
            [view setTitle:_title groupId:_groupId placeholder:_placeholder];
        } else {
            [view setFirstName:_firstName lastName:_lastName uid:0 placeholder:_placeholder];
        }
    } else {
        [view setAvatarUri:_avatarUri filter:_filter placeholder:_placeholder];
    }
}

- (void)setAvatarUri:(NSString *)avatarUri
{
    _avatarUri = avatarUri;
    
    _firstName = nil;
    _lastName = nil;
    _uid = 0;
    TGModernLetteredAvatarView *view = (TGModernLetteredAvatarView *)[self boundView];
    if (view != nil)
    {
        if (_avatarUri.length == 0)
            [view setFirstName:_firstName lastName:_lastName uid:_uid placeholder:_placeholder];
        else
            [view setAvatarUri:_avatarUri filter:_filter placeholder:_placeholder];
    }
}

- (void)setAvatarFirstName:(NSString *)firstName lastName:(NSString *)lastName uid:(int32_t)uid
{
    _avatarUri = nil;
    _firstName = firstName;
    _lastName = lastName;
    _title = nil;
    _uid = uid;
    _groupId = 0;
    
    TGModernLetteredAvatarView *view = (TGModernLetteredAvatarView *)[self boundView];
    if (view != nil)
    {
        if (_avatarUri.length == 0)
            [view setFirstName:_firstName lastName:_lastName uid:_uid placeholder:_placeholder];
        else
            [view setAvatarUri:_avatarUri filter:_filter placeholder:_placeholder];
    }
}

- (void)setAvatarTitle:(NSString *)title groupId:(int64_t)groupId
{
    _avatarUri = nil;
    _firstName = nil;
    _lastName = nil;
    _title = title;
    _uid = 0;
    _groupId = groupId;
    
    TGModernLetteredAvatarView *view = (TGModernLetteredAvatarView *)[self boundView];
    if (view != nil)
    {
        if (_avatarUri.length == 0)
            [view setTitle:_title groupId:_groupId placeholder:_placeholder];
        else
            [view setAvatarUri:_avatarUri filter:_filter placeholder:_placeholder];
    }
}

@end
