#import "TGMeContactsCell.h"

#import "TGLetteredAvatarView.h"

#import "TGUser.h"

#import "TGFont.h"

#import "TGPhoneUtils.h"

@interface TGMeContactsCell () {
    TGLetteredAvatarView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_descriptionLabel;
}

@end

@implementation TGMeContactsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(14.0f, 6.0f, 60.0f, 60.0f)];
        [_avatarView setSingleFontSize:24.0f doubleFontSize:24.0f useBoldFont:false];
        [self.contentView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGSystemFontOfSize(20.0);
        [self.contentView addSubview:_nameLabel];
        
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = UIColorRGB(0x8e8e93);
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = TGSystemFontOfSize(13.0);
        [self.contentView addSubview:_descriptionLabel];
    }
    return self;
}

- (void)setUser:(TGUser *)user {
    CGSize size = CGSizeMake(60.0f, 60.0f);
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (user.photoUrlSmall.length != 0) {
        [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
    } else {
        [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    }
    
    _nameLabel.text = [user displayName];
    _descriptionLabel.text = [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftInset = 90.0f;
    CGFloat rightInset = 16.0f;
    
    CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
    nameSize.width = MIN(nameSize.width, self.bounds.size.width - leftInset - rightInset);
    
    _nameLabel.frame = CGRectMake(leftInset, 15.0f, nameSize.width, nameSize.height);
    
    CGSize descriptionSize = [_descriptionLabel.text sizeWithFont:_descriptionLabel.font];
    descriptionSize.width = MIN(descriptionSize.width, self.bounds.size.width - leftInset - rightInset);
    _descriptionLabel.frame = CGRectMake(leftInset, 41.0f, descriptionSize.width, descriptionSize.height);
}

@end
