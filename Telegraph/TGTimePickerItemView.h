#import <LegacyComponents/LegacyComponents.h>

@interface TGTimePickerItemView : TGMenuSheetItemView

- (instancetype)initWithValue:(int)value;

- (NSDate *)dateValue;

@end
