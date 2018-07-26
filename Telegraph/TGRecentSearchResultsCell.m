#import "TGRecentSearchResultsCell.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGRecentSearchResultsCell ()
{
    UIImageView *_iconView;
    UILabel *_labelView;
}

@end

@implementation TGRecentSearchResultsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecentSearchResultsItemLoupe.png"]];
        [self.contentView addSubview:_iconView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = [UIColor blackColor];
        _labelView.font = TGSystemFontOfSize(17.0f);
        [self.contentView addSubview:_labelView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    if (presentation == nil || _presentation == presentation)
        return;
    
    _presentation = presentation;
    
    self.backgroundColor = presentation.pallete.backgroundColor;
    self.selectedBackgroundView.backgroundColor = presentation.pallete.selectionColor;
    
    _labelView.textColor = presentation.pallete.textColor;
    _iconView.image = TGTintedImage(_iconView.image, presentation.pallete.textColor);
}

- (void)setTitle:(NSString *)title
{
    _labelView.text = title;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _iconView.frame = (CGRect){{18.0f, CGFloor((self.frame.size.height - _iconView.frame.size.height) / 2.0f)}, _iconView.frame.size};
    
    CGSize labelSize = [_labelView sizeThatFits:CGSizeMake(self.frame.size.width - 44.0f - 10.0f, CGFLOAT_MAX)];
    _labelView.frame = (CGRect){{44.0f, CGFloor((self.frame.size.height - labelSize.height) / 2.0f)}, labelSize};
}

@end
