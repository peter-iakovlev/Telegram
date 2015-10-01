#import "TGReplyHeaderImageModel.h"

#import "TGSignalImageViewModel.h"

#import "TGImageUtils.h"

#import "TGModernImageViewModel.h"

@interface TGReplyHeaderImageModel ()
{
}

@end

@implementation TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming text:(NSString *)text imageSignalGenerator:(SSignal *(^)())imageSignalGenerator imageSignalIdentifier:(NSString *)imageSignalIdentifier icon:(UIImage *)icon truncateTextInTheMiddle:(bool)truncateTextInTheMiddle system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:text truncateTextInTheMiddle:truncateTextInTheMiddle textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:44.0f system:system];
    if (self != nil)
    {
        _imageModel = [[TGSignalImageViewModel alloc] init];
        [_imageModel setSignalGenerator:imageSignalGenerator identifier:imageSignalIdentifier];
        _imageModel.skipDrawInContext = true;
        [self addSubmodel:_imageModel];
        
        if (icon != nil)
        {
            _iconModel = [[TGModernImageViewModel alloc] initWithImage:icon];
            _iconModel.skipDrawInContext = true;
            [_iconModel sizeToFit];
            [self addSubmodel:_iconModel];
        }
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    _imageModel.parentOffset = itemPosition;
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    _iconModel.parentOffset = itemPosition;
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
}

- (void)layoutForContainerSize:(CGSize)containerSize updateContent:(bool *)updateContent
{
    if (containerSize.width < 90.0f)
    {
        _leftInset = 0.0f;
        _imageModel.hidden = true;
        _iconModel.hidden = true;
    }
    else
    {
        _leftInset = 44.0f;
        _imageModel.hidden = false;
        _iconModel.hidden = false;
    }
    
    [super layoutForContainerSize:containerSize updateContent:updateContent];
    
    CGFloat imageSize = _system ? 35.0f : (31.0f + TGRetinaPixel);
    _imageModel.frame = CGRectMake(11.0f, 7.0f, imageSize, imageSize);
    
    if (_iconModel != nil)
    {
        _iconModel.frame = CGRectMake(_imageModel.frame.origin.x + TGRetinaFloor((_imageModel.frame.size.width - _iconModel.frame.size.width) / 2.0f), _imageModel.frame.origin.y + TGRetinaFloor((_imageModel.frame.size.height - _iconModel.frame.size.height) / 2.0f), _iconModel.frame.size.width, _iconModel.frame.size.height);
    }
}

@end
