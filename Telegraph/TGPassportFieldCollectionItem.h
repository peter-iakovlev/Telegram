#import "TGCollectionItem.h"

@interface TGPassportFieldCollectionItem : TGCollectionItem

@property (nonatomic) SEL action;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSArray *errors;
@property (nonatomic) bool isChecked;
@property (nonatomic) bool isRequired;

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action;

@end
