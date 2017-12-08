#import "TGWatchController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGBridgePresetsService.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGWatchReplyCollectionItem.h"

@interface TGWatchController ()
{
    NSMutableArray *_presetItems;
    
    NSDictionary *_currentPresets;
}
@end

@implementation TGWatchController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"AppleWatch.Title")];
        
        NSArray *presetIdentifiers = [TGBridgePresetsService presetIdentifiers];
        _currentPresets = [TGBridgePresetsService currentPresets];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AppleWatch.ReplyPresets")]];
        
        _presetItems = [[NSMutableArray alloc] init];
        for (NSString *identifier in presetIdentifiers)
        {
            NSString *placeholder = TGLocalized([NSString stringWithFormat:@"Watch.%@", identifier]);
            TGWatchReplyCollectionItem *item = [[TGWatchReplyCollectionItem alloc] initWithIdentifier:identifier value:_currentPresets[identifier] placeholder:placeholder];
            [_presetItems addObject:item];
            
            __weak TGWatchController *weakSelf = self;
            __weak TGWatchReplyCollectionItem *weakItem = item;
            item.inputReturned = ^
            {
                __strong TGWatchController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGWatchReplyCollectionItem *strongItem = weakItem;
                if (strongItem == nil)
                    return;
                
                [strongSelf inputReturnedFromItem:strongItem];
            };
            [items addObject:item];
        }
        
        [items addObject:[[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"AppleWatch.ReplyPresetsHelp")]];

        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 10.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)inputReturnedFromItem:(TGWatchReplyCollectionItem *)item
{
    NSUInteger index = [_presetItems indexOfObject:item];
    if (index == NSNotFound || index >= _presetItems.count - 1)
    {
        [item resignFirstResponder];
        return;
    }
    
    TGWatchReplyCollectionItem *nextItem = [_presetItems objectAtIndex:index + 1];
    [nextItem becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSMutableDictionary *newPresets = [[NSMutableDictionary alloc] init];
    for (TGWatchReplyCollectionItem *item in _presetItems)
    {
        if (item.value.length > 0 && [item.value hasNonWhitespaceCharacters])
            newPresets[item.identifier] = item.value;
    }
    
    if (![newPresets isEqual:_currentPresets])
        [TGBridgePresetsService storePresets:newPresets];
}

@end
