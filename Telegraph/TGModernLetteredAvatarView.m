/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernLetteredAvatarView.h"

@interface TGModernLetteredAvatarView ()
{
    NSString *_avatarUri;
    NSString *_firstName;
    NSString *_lastName;
    NSString *_title;
    int32_t _uid;
    int64_t _groupId;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernLetteredAvatarView

- (void)willBecomeRecycled
{
    [self prepareForRecycle];
}

- (NSString *)viewStateIdentifier
{
    if (_viewStateIdentifier)
    {
    }
    
    return [[NSString alloc] initWithFormat:@"TGModernLetteredAvatarView/%@/%@/%@/%@/%" PRId32 "/%@/%lld", self.currentFilter, _avatarUri, _firstName, _lastName, _uid, _title, _groupId];
}

- (void)setAvatarUri:(NSString *)avatarUri filter:(NSString *)filter placeholder:(UIImage *)placeholder
{
    _avatarUri = avatarUri;
    
    _uid = 0;
    _firstName = nil;
    _lastName = nil;
    
    [self loadImage:avatarUri filter:filter placeholder:placeholder forceFade:false];
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uid:(int32_t)uid placeholder:(UIImage *)placeholder
{
    _firstName = firstName;
    _lastName = lastName;
    _title = nil;
    _uid = uid;
    _groupId = 0;
    
    _avatarUri = nil;
    
    [self loadUserPlaceholderWithSize:self.frame.size uid:_uid firstName:_firstName lastName:_lastName placeholder:placeholder];
}

- (void)setTitle:(NSString *)title groupId:(int64_t)groupId placeholder:(UIImage *)placeholder
{
    _firstName = nil;
    _lastName = nil;
    _title = title;
    _uid = 0;
    _groupId = groupId;
    
    _avatarUri = nil;
    
    [self loadGroupPlaceholderWithSize:self.frame.size conversationId:_groupId title:_title placeholder:placeholder];
}

@end
