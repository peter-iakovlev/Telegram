#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGMenuSheetCheckItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^action)(void);

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(void))action checked:(bool)checked;

- (void)setPresentation:(TGPresentation *)presentation;

@end
