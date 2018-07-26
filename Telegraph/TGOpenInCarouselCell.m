#import "TGOpenInCarouselCell.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGImageView.h>

#import "TGOpenInAppItem.h"
#import "TGOpenInSignals.h"

#import <LegacyComponents/TGMenuSheetController.h>

NSString *const TGOpenInCarouselCellIdentifier = @"TGOpenInCarouselCell";
const CGFloat TGOpenInCarouselCellIconCornerRadius = 16.0f;

@interface TGOpenInCarouselCell ()
{
    TGImageView *_imageView;
    UIImageView *_cornersView;
    UILabel *_titleLabel;
}
@end

@implementation TGOpenInCarouselCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(10.0f, 14.0f, 60.0f, 60.0f)];
        [self addSubview:_imageView];
        
        _cornersView = [[UIImageView alloc] init];
        _cornersView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cornersView.frame = _imageView.frame;
        [self addSubview:_cornersView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_imageView.frame) + 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGSystemFontOfSize(11.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setCornersImage:(UIImage *)cornersImage
{
    _cornersView.image = cornersImage;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    _pallete = pallete;
    self.backgroundColor = pallete.backgroundColor;
    _titleLabel.backgroundColor = pallete.backgroundColor;
    _titleLabel.textColor = pallete.textColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setAppItem:(TGOpenInAppItem *)appItem
{
    _titleLabel.text = appItem.title;

    SSignal *iconSignal = nil;
    if (appItem.appIcon != nil)
        iconSignal = [SSignal single:appItem.appIcon];
    else
        iconSignal = [TGOpenInSignals iconForAppItem:appItem];
    
    [_imageView setSignal:iconSignal];
}

@end
