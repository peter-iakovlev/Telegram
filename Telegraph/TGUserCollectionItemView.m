/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserCollectionItemView.h"

#import "TGRemoteImageView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGLetteredAvatarView.h"

@interface TGUserCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_disclosureIndicator;
    
    TGLetteredAvatarView *_avatarView;
}

@end

@implementation TGUserCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [self.editingContentView addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self.editingContentView addSubview:_titleLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self.editingContentView addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setShowAvatar:(bool)showAvatar
{
    _avatarView.hidden = !showAvatar;
    self.separatorInset = showAvatar ? (15.0f + 40.0f + 8.0f) : 15.0f;
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation avatarUri:(NSString *)avatarUri
{
    if (firstName.length != 0 && lastName.length != 0)
    {
        _titleLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
    }
    else if (firstName.length != 0)
        _titleLabel.text = firstName;
    else if (lastName.length != 0)
        _titleLabel.text = lastName;
    else
        _titleLabel.text = @"";
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 39.0f, 39.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (avatarUri.length == 0)
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:uidForPlaceholderCalculation firstName:firstName lastName:lastName placeholder:placeholder];
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
        [_avatarView loadImage:avatarUri filter:@"circle:40x40" placeholder:placeholder];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat leftInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    
    if (!_avatarView.hidden)
    {
        _avatarView.frame = CGRectMake(leftInset + 12.0f, CGFloor((bounds.size.height - _avatarView.frame.size.height) / 2.0f), _avatarView.frame.size.width, _avatarView.frame.size.height);
        leftInset += _avatarView.frame.size.width + 10.0f;
    }
    
    _titleLabel.frame = CGRectMake(15.0f + leftInset, CGFloor((bounds.size.height - 26.0f) / 2), bounds.size.width - 15.0f - leftInset - 40.0f, 26.0f);
    
    _disclosureIndicator.alpha = self.showsDeleteIndicator ? 0.0f : 1.0f;
    _disclosureIndicator.frame = CGRectMake(bounds.size.width + (self.showsDeleteIndicator ? 0.0f : (-_disclosureIndicator.frame.size.width - 15.0f)) , CGFloor((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
}

#pragma mark -

- (void)deleteAction
{
    id<TGUserCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(userCollectionItemViewRequestedDeleteAction:)])
        [delegate userCollectionItemViewRequestedDeleteAction:self];
}

@end
