#import "TGConversationCollectionItemView.h"

#import "TGRemoteImageView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGLetteredAvatarView.h"

#import "TGConversation.h"

@interface TGConversationCollectionItemViewContent : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *status;

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
    static CGColorRef titleColor = NULL;
    
    static UIFont *statusFont = nil;
    static dispatch_once_t onceToken;
    static CGColorRef regularStatusColor = NULL;
    dispatch_once(&onceToken, ^ {
        titleFont = TGMediumSystemFontOfSize(17.0f);
        statusFont = TGSystemFontOfSize(13.0f);
        
        titleColor = CGColorRetain([UIColor blackColor].CGColor);
        regularStatusColor = CGColorRetain(UIColorRGB(0xb3b3b3).CGColor);
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

- (void)setConversation:(TGConversation *)conversation {
    _conversation = conversation;
    _content.title = conversation.chatTitle;
    [_content setNeedsDisplay];
    
    [self setAvatarUri:conversation.chatPhotoSmall];
}

- (void)setAvatarUri:(NSString *)avatarUri
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
    
    if (avatarUri.length == 0) {
        [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) conversationId:_conversation.conversationId title:_conversation.chatTitle placeholder:placeholder];
    } else if (!TGStringCompare([_avatarView currentUrl], avatarUri)) {
        [_avatarView loadImage:avatarUri filter:@"circle:40x40" placeholder:placeholder];
    }
}

- (void)layoutSubviews
{
    CGFloat leftInset = false ? 38.0f : 0.0f;
    self.separatorInset = 65.0f + leftInset;
    
    CGFloat rightInset = 0.0f;
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _avatarView.frame = CGRectMake(leftInset + 14.0f, 4.0f + TGRetinaPixel, 40.0f, 40.0f);
    
    CGRect contentFrame = CGRectMake(65.0f + leftInset, 4.0f, bounds.size.width - 65.0f - rightInset, bounds.size.height - 8.0f);
    if (!CGSizeEqualToSize(_content.frame.size, contentFrame.size))
        [_content setNeedsDisplay];
    _content.frame = contentFrame;
}

@end
