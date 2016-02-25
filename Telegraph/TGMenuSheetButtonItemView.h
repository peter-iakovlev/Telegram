#import "TGMenuSheetItemView.h"

typedef enum
{
    TGMenuSheetButtonTypeDefault,
    TGMenuSheetButtonTypeCancel,
    TGMenuSheetButtonTypeDestructive,
    TGMenuSheetButtonTypeSend
} TGMenuSheetButtonType;

@interface TGMenuSheetButtonItemView : TGMenuSheetItemView

@property (nonatomic, strong) NSString *title;

- (instancetype)initWithTitle:(NSString *)title type:(TGMenuSheetButtonType)type action:(void (^)(void))action;

@end
