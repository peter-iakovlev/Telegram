#import "TGTimePickerItemView.h"

@interface TGTimePickerItemView ()
{
    UIDatePicker *_pickerView;
}
@end

@implementation TGTimePickerItemView

- (instancetype)initWithValue:(int)value
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 216.0)];
        _pickerView.datePickerMode = UIDatePickerModeTime;
        _pickerView.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _pickerView.date = [NSDate dateWithTimeIntervalSince1970:value];
        [self addSubview:_pickerView];
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    if (iosMajorVersion() >= 7)
        [_pickerView setValue:pallete.textColor forKey:@"textColor"];
}

- (NSDate *)dateValue
{
    return _pickerView.date;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    if ((int)screenHeight == 320)
        return 168.0f;
    
    return 216.0f;
}

- (bool)requiresDivider
{
    return true;
}

- (void)layoutSubviews
{
    _pickerView.frame = self.bounds;
}

@end
