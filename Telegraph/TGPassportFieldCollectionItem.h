#import "TGCollectionItem.h"
#import "TGPassportForm.h"

@interface TGPassportFieldCollectionItem : TGCollectionItem

@property (nonatomic) SEL action;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSArray *errors;
@property (nonatomic) bool isChecked;
@property (nonatomic) bool isRequired;

@property (nonatomic) TGPassportRequiredType *type;
@property (nonatomic, strong) NSArray *acceptedTypes;

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action;

@end
