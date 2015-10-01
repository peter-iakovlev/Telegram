#import "TGSharedMediaSectionHeaderView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGSharedMediaSectionHeaderView ()
{
    UILabel *_dateLabel;
    UILabel *_summaryLabel;
}

@end

@implementation TGSharedMediaSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.92f];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor blackColor];
        _dateLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_dateLabel];
        
        _summaryLabel = [[UILabel alloc] init];
        _summaryLabel.backgroundColor = [UIColor clearColor];
        _summaryLabel.textColor = UIColorRGB(0xb3b3b3);
        _summaryLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_summaryLabel];
    }
    return self;
}

- (void)setDateString:(NSString *)dateString summaryString:(NSString *)summaryString
{
    _dateLabel.text = dateString;
    [_dateLabel sizeToFit];
    
    _summaryLabel.text = summaryString;
    [_summaryLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dateLabel.frame = (CGRect){{8.0f, TGRetinaFloor((self.bounds.size.height - _dateLabel.frame.size.height) / 2.0f)}, _dateLabel.frame.size};
    _summaryLabel.frame = (CGRect){{self.bounds.size.width - _summaryLabel.frame.size.width - 8.0f, TGRetinaFloor((self.bounds.size.height - _summaryLabel.frame.size.height) / 2.0f)}, _summaryLabel.frame.size};
}

@end
