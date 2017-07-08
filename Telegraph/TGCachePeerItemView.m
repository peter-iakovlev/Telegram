#import "TGCachePeerItemView.h"

#import "TGFont.h"
#import "TGLetteredAvatarView.h"

#import "TGUser.h"
#import "TGConversation.h"

#import "TGStringUtils.h"

@interface TGCachePeerItemView () {
    TGLetteredAvatarView *_avatarView;
    UILabel *_titleLabel;
    UILabel *_sizeLabel;
    UIImageView *_disclosureIndicator;
}

@end

@implementation TGCachePeerItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:false];
        
        [self.contentView addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(17.0f);
        [self.contentView addSubview:_titleLabel];
        
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.textColor = UIColorRGB(0x8e8e93);
        _sizeLabel.font = TGSystemFontOfSize(17.0f);
        [self.contentView addSubview:_sizeLabel];
        
        self.separatorInset = 65.0f;
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self.contentView addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setPeer:(id)peer totalSize:(int64_t)totalSize {
    CGSize size = CGSizeMake(40.0f, 40.0f);
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
    
    int64_t peerId = 0;
    bool isSecret = false;
    
    if ([peer isKindOfClass:[TGConversation class]]) {
        TGConversation *conversation = peer;
        peerId = conversation.conversationId;
        isSecret = conversation.isEncrypted;
        if (conversation.additionalProperties[@"user"] != nil) {
            TGUser *user = conversation.additionalProperties[@"user"];
            
            if (user.photoUrlSmall.length != 0) {
                [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
            } else {
                [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
            }
            _titleLabel.text = user.displayName;
        } else {
            if (conversation.chatPhotoSmall.length != 0) {
                [_avatarView loadImage:conversation.chatPhotoSmall filter:@"circle:60x60" placeholder:placeholder];
            } else {
                [_avatarView loadGroupPlaceholderWithSize:size conversationId:conversation.conversationId title:conversation.chatTitle placeholder:placeholder];
            }
            _titleLabel.text = conversation.chatTitle;
        }
    } else if ([peer isKindOfClass:[TGUser class]]) {
        TGUser *user = peer;
        
        peerId = user.uid;
        if (user.photoUrlSmall.length != 0) {
            [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
        } else {
            [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        }
        _titleLabel.text = user.displayName;
    }
    
    _titleLabel.textColor = isSecret ? UIColorRGB(0x00a629) : [UIColor blackColor];
    _sizeLabel.text = [TGStringUtils stringForFileSize:totalSize];
    
    //_peerId = peerId;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _avatarView.frame = CGRectMake(14.0f, 4.0f, 40.0, 40.0f);
    
    _disclosureIndicator.frame = CGRectMake(self.bounds.size.width - _disclosureIndicator.frame.size.width - 15, CGFloor((self.bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    CGSize sizeSize = [_sizeLabel.text sizeWithFont:_sizeLabel.font];
    sizeSize.width = CGCeil(sizeSize.width);
    sizeSize.height = CGCeil(sizeSize.height);
    _sizeLabel.frame = CGRectMake(_disclosureIndicator.frame.origin.x - sizeSize.width - 11.0, CGFloor((self.bounds.size.height - sizeSize.height) / 2.0f), sizeSize.width, sizeSize.height);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(CGRectGetMinX(_sizeLabel.frame) - 10.0f - CGRectGetMaxX(_avatarView.frame) - 12.0f, CGCeil(titleSize.width));
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarView.frame) + 12.0f, CGFloor((self.bounds.size.height - titleSize.height) / 2.0f), titleSize.width, titleSize.height);
}

@end
