#import "TGPhotoToolCell.h"

#import "PGPhotoTool.h"

#import "TGPhotoEditorInterfaceAssets.h"

NSString * const TGPhotoToolCellKind = @"TGPhotoToolCellKind";

@interface TGPhotoToolCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_valueLabel;
}
@end

@implementation TGPhotoToolCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 50) / 2, 0, 50, 50)];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.frame.origin.y + _imageView.frame.size.height + 2, frame.size.width, 17)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [TGPhotoEditorInterfaceAssets editorItemTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [TGPhotoEditorInterfaceAssets editorItemTitleColor];
        _titleLabel.highlightedTextColor = [TGPhotoEditorInterfaceAssets editorActiveItemTitleColor];
        [self addSubview:_titleLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height - 2, frame.size.width, 20)];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.font = [TGFont systemFontOfSize:11];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.textColor = [TGPhotoEditorInterfaceAssets accentColor];
        [self addSubview:_valueLabel];
    }
    return self;
}

- (void)setPhotoTool:(PGPhotoTool *)photoTool
{
    _imageView.image = photoTool.image;
    _titleLabel.text = photoTool.title;
    _titleLabel.highlighted = ([photoTool stringValue] != nil);
    if ([photoTool.value isKindOfClass:[NSNumber class]])
    {
        _valueLabel.frame = CGRectMake(-1.5f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height - 2, self.frame.size.width, 20);
    }
    else
    {
        _valueLabel.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height - 2, self.frame.size.width, 20);
    }
    _valueLabel.text = [photoTool stringValue];
}

- (void)setSelected:(BOOL)__unused selected
{

}

- (void)setHighlighted:(BOOL)__unused highlighted
{

}

@end
