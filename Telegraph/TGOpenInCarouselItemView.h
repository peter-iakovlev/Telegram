#import "TGMenuSheetItemView.h"

@interface TGOpenInCarouselItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^itemPressed)(void);

- (instancetype)initWithAppItems:(NSArray *)appItems title:(NSString *)title;

@end
