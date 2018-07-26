#import <LegacyComponents/LegacyComponents.h>

@interface TGPassportBirthDateItemView : TGMenuSheetItemView

- (instancetype)initWithValue:(NSDate *)date minValue:(NSDate *)minValue maxValue:(NSDate *)maxValue;
- (NSDate *)value;

@end
