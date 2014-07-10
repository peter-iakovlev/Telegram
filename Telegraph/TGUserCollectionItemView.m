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

@interface TGUserCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_disclosureIndicator;
}

@end

@implementation TGUserCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
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

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (void)setAvatarUrl:(NSString *)__unused avatarUrl
{
    static UIImage *genericPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        genericPlaceholder = [UIImage imageNamed:@"ModernContactListPhotoPlaceholder.png"];
    });
    
    //[_avatarView loadImage:avatarUrl filter:@"circle:36x36" placeholder:genericPlaceholder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat leftInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    
    _titleLabel.frame = CGRectMake(15.0f + leftInset, floorf((bounds.size.height - 26.0f) / 2), bounds.size.width - 15.0f - leftInset - 40.0f, 26.0f);
    
    _disclosureIndicator.alpha = self.showsDeleteIndicator ? 0.0f : 1.0f;
    _disclosureIndicator.frame = CGRectMake(bounds.size.width + (self.showsDeleteIndicator ? 0.0f : (-_disclosureIndicator.frame.size.width - 15.0f)) , floorf((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
}

#pragma mark -

- (void)deleteAction
{
    id<TGUserCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(userCollectionItemViewRequestedDeleteAction:)])
        [delegate userCollectionItemViewRequestedDeleteAction:self];
}

@end
