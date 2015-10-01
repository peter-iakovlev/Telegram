#import "TGCollectionItem.h"

@interface TGCollectionBottonDisclosureItem : TGCollectionItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) bool expanded;

@property (nonatomic, copy) void (^expandedChanged)(TGCollectionBottonDisclosureItem *);
@property (nonatomic, copy) void (^followAnchor)(NSString *);

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text;

@end
