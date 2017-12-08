#import "TGMigratedChannelConversationHeaderView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernViewContext.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

@interface TGMigratedChannelConversationHeaderView () {
    UIImageView *_backgrounView;
    
    TGModernViewContext *_context;
    NSString *_title;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UILabel *_textLabel;
}

@end

@implementation TGMigratedChannelConversationHeaderView

- (instancetype)initWithContext:(TGModernViewContext *)context title:(NSString *)title {
    self = [super init];
    if (self != nil) {
        _context = context;
        _title = title;
        
        _backgrounView = [[UIImageView alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground]];
        [self addSubview:_backgrounView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
        titleStyle.lineSpacing = 5.0f;
        titleStyle.lineBreakMode = NSLineBreakByWordWrapping;
        titleStyle.alignment = NSTextAlignmentCenter;
        
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:TGLocalized(@"Group.MigratedNoticeTitle"), title] attributes:@{NSParagraphStyleAttributeName: titleStyle, NSFontAttributeName: _titleLabel.font}];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.font = TGMediumSystemFontOfSize(14.0f);
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.text = TGLocalized(@"Group.MigratedNoticeSubtitle");
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = TGSystemFontOfSize(14.0f);
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineSpacing = 2.0f;
        textStyle.paragraphSpacing = 3.0f;
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentNatural;
        
        _textLabel.attributedText = [[NSAttributedString alloc] initWithString:TGLocalized(@"Group.MigratedNoticeText") attributes:@{NSParagraphStyleAttributeName: textStyle, NSFontAttributeName: _textLabel.font}];
        
        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)sizeToFit {
    CGFloat maxWidth = 280.0f;
    UIEdgeInsets insets = UIEdgeInsetsMake(16.0, 14.0f, 16.0f, 14.0f);
    CGFloat titleSubtitleSpacing = 9.0f;
    CGFloat subtitleTextSubtitleSpacing = 5.0f;
    
    CGSize titleSize = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake(maxWidth - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    titleSize.width = CGCeil(titleSize.width);
    titleSize.height = CGCeil(titleSize.height);
    
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font constrainedToSize:CGSizeMake(maxWidth - insets.left - insets.right, CGFLOAT_MAX)];
    subtitleSize.width = CGCeil(subtitleSize.width);
    subtitleSize.height = CGCeil(subtitleSize.height);
    
    CGSize textSize = [_textLabel.attributedText boundingRectWithSize:CGSizeMake(maxWidth - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    CGFloat contentWidth = MAX(MAX(titleSize.width, subtitleSize.width), textSize.width);
    CGFloat contentHeight = titleSize.height + titleSubtitleSpacing + subtitleSize.height + subtitleTextSubtitleSpacing + textSize.height;
    CGSize contentSize = CGSizeMake(insets.left + insets.right + contentWidth, insets.right + insets.top + contentHeight);
    
    _titleLabel.frame = CGRectMake(CGFloor((contentSize.width - titleSize.width) / 2.0f), insets.top, titleSize.width, titleSize.height);
    
    _subtitleLabel.frame = CGRectMake(insets.left, CGRectGetMaxY(_titleLabel.frame) + titleSubtitleSpacing, subtitleSize.width, subtitleSize.height);
    
    _textLabel.frame = CGRectMake(insets.left, CGRectGetMaxY(_subtitleLabel.frame) + subtitleTextSubtitleSpacing, textSize.width, textSize.height);
    
    CGRect frame = self.frame;
    frame.size = contentSize;
    self.frame = frame;
    
    _backgrounView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
}

@end
