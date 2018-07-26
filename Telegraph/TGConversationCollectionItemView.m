#import "TGConversationCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGRemoteImageView.h>

#import <LegacyComponents/TGLetteredAvatarView.h>

#import "TGPresentation.h"

@interface TGConversationCollectionItemViewContent : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) TGPresentation *presentation;

@end

@implementation TGConversationCollectionItemViewContent

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.contentMode = UIViewContentModeLeft;
        self.opaque = false;
    }
    return self;
}

- (void)drawRect:(CGRect)__unused rect
{
    static UIFont *titleFont = nil;
    CGColorRef titleColor = self.presentation.pallete.collectionMenuTextColor.CGColor;
    
    static UIFont *statusFont = nil;
    static dispatch_once_t onceToken;
    CGColorRef regularStatusColor = self.presentation.pallete.collectionMenuVariantColor.CGColor;
    dispatch_once(&onceToken, ^ {
        titleFont = TGMediumSystemFontOfSize(17.0f);
        statusFont = TGSystemFontOfSize(13.0f);
    });
    
    CGRect bounds = self.bounds;
    CGFloat availableWidth = bounds.size.width - 20.0f - 1.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize titleSize = [_title sizeWithFont:titleFont];
    
    titleSize.width = MIN(titleSize.width, availableWidth - 30.0f);
    
    CGContextSetFillColorWithColor(context, titleColor);
    CGFloat titleVerticalOffset = 0.0f;
    if (_status.length == 0) {
        titleVerticalOffset = 8.0f;
    }
    [_title drawInRect:CGRectMake(1.0f, 1.0f + titleVerticalOffset, titleSize.width, titleSize.height) withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize statusSize = [_status sizeWithFont:statusFont];
    CGContextSetFillColorWithColor(context, regularStatusColor);
    [_status drawInRect:CGRectMake(1.0f, 23.0f - TGRetinaPixel, MIN(statusSize.width, availableWidth), statusSize.height) withFont:statusFont lineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    [self setNeedsDisplay];
}

@end

@interface TGConversationCollectionItemView () {
    TGConversation *_conversation;
    TGLetteredAvatarView *_avatarView;
    TGConversationCollectionItemViewContent *_content;
}

@end

@implementation TGConversationCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.separatorInset = 65.0f;
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [self.contentView addSubview:_avatarView];
        
        _content = [[TGConversationCollectionItemViewContent alloc] init];
        [self.contentView addSubview:_content];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    [_content setPresentation:presentation];
}

- (void)setConversation:(TGConversation *)conversation {
    _conversation = conversation;
    _content.title = conversation.chatTitle;
    [_content setNeedsDisplay];
    
    [self setAvatarUri:conversation.chatPhotoSmall];
}

- (void)setAvatarUri:(NSString *)avatarUri
{
    UIImage *placeholder = [self.presentation.images avatarPlaceholderWithDiameter:40.0f];
    
    if (avatarUri.length == 0) {
        [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) conversationId:_conversation.conversationId title:_conversation.chatTitle placeholder:placeholder];
    } else if (!TGStringCompare([_avatarView currentUrl], avatarUri)) {
        [_avatarView loadImage:avatarUri filter:@"circle:40x40" placeholder:placeholder];
    }
}

- (void)layoutSubviews
{
    CGFloat leftInset = self.safeAreaInset.left;
    self.separatorInset = 65.0f + leftInset;
    
    CGFloat rightInset = self.safeAreaInset.right;
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _avatarView.frame = CGRectMake(leftInset + 14.0f, 4.0f + TGRetinaPixel, 40.0f, 40.0f);
    
    CGRect contentFrame = CGRectMake(65.0f + leftInset, 4.0f, bounds.size.width - 65.0f - rightInset, bounds.size.height - 8.0f);
    if (!CGSizeEqualToSize(_content.frame.size, contentFrame.size))
        [_content setNeedsDisplay];
    _content.frame = contentFrame;
}

@end
