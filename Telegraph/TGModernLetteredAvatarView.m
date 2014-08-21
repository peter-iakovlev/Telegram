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
    int32_t _uid;
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
    return [[NSString alloc] initWithFormat:@"TGModernLetteredAvatarView/%@/%@/%@/%@/%" PRId32 "", self.currentFilter, _avatarUri, _firstName, _lastName, _uid];
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
    _uid = uid;
    
    _avatarUri = nil;
    
    [self loadUserPlaceholderWithSize:self.frame.size uid:_uid firstName:_firstName lastName:_lastName placeholder:placeholder];
}

@end
