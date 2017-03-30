#import "TGShippingMethodController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCheckCollectionItem.h"

#import "TGPaymentForm.h"

@interface TGShippingMethodController () {
    UIBarButtonItem *_doneItem;
    
    NSArray<TGCheckCollectionItem *> *_optionItems;
    NSArray<TGShippingOption *> *_options;
}

@end

@implementation TGShippingMethodController

- (instancetype)initWithOptions:(NSArray<TGShippingOption *> *)options currentOption:(TGShippingOption *)currentOption {
    self = [super init];
    if (self != nil) {
        self.title = TGLocalized(@"Checkout.ShippingOption.Title");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        self.navigationItem.rightBarButtonItem = _doneItem;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.ShippingOption.Header")]];
        
        _options = options;
        NSMutableArray *optionItems = [[NSMutableArray alloc] init];
        for (TGShippingOption *option in options) {
            TGCheckCollectionItem *item = [[TGCheckCollectionItem alloc] initWithTitle:option.title action:@selector(optionSelected:)];
            item.isChecked = currentOption != nil && [option isEqual:currentOption];
            [items addObject:item];
            [optionItems addObject:item];
        }
        _optionItems = optionItems;
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 16.0f, 0.0f);
        _doneItem.enabled = currentOption != nil;
        
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    for (NSUInteger i = 0; i < _optionItems.count; i++) {
        if (_optionItems[i].isChecked) {
            if (_completed) {
                _completed(_options[i]);
                break;
            }
        }
    }
}

- (void)optionSelected:(TGCheckCollectionItem *)checkCollectionItem
{
    for (TGCheckCollectionItem *item in _optionItems) {
        if (item == checkCollectionItem) {
            item.isChecked = true;
        } else{
            item.isChecked = false;
        }
    }
    _doneItem.enabled = true;
}

@end
