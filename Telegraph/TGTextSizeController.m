/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTextSizeController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCheckCollectionItem.h"

@interface TGTextSizeController ()
{
    NSArray *_textSizes;
}

@end

@implementation TGTextSizeController

- (id)initWithTextSize:(int)textSize
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"ChatSettings.TextSize")];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        _textSizes = @[@(16), @(18), @(20), @(24), @(32), @(40)];
        
        NSMutableArray *textSizeSectionItems = [[NSMutableArray alloc] init];
        
        for (NSNumber *nSize in _textSizes)
        {
            TGCheckCollectionItem *checkItem = [[TGCheckCollectionItem alloc] initWithTitle:[[NSString alloc] initWithFormat:@"%d%@", [nSize intValue], TGLocalized(@"ChatSettings.TextSizeUnits")] action:@selector(textSizeItemPressed:)];
            [checkItem setIsChecked:[nSize intValue] == textSize];
            [textSizeSectionItems addObject:checkItem];
        }
        
        TGCollectionMenuSection *textSizesSection = [[TGCollectionMenuSection alloc] initWithItems:textSizeSectionItems];
        
        UIEdgeInsets topSectionInsets = textSizesSection.insets;
        topSectionInsets.top = 32.0f;
        textSizesSection.insets = topSectionInsets;
        [self.menuSections addSection:textSizesSection];
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    id<TGTextSizeControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(textSizeController:didFinishPickingWithTextSize:)])
        [delegate textSizeController:self didFinishPickingWithTextSize:[self _selectedTextSize]];
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (int)_selectedTextSize
{
    int index = -1;
    for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[0]).items)
    {
        if ([item isKindOfClass:[TGCheckCollectionItem class]])
        {
            index++;
            
            if (((TGCheckCollectionItem *)item).isChecked)
                return [_textSizes[index] intValue];
        }
    }
    
    return 16;
}

- (void)textSizeItemPressed:(TGCheckCollectionItem *)checkItem
{
    checkItem.isChecked = true;
    
    int index = -1;
    for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[0]).items)
    {
        if ([item isKindOfClass:[TGCheckCollectionItem class]])
        {
            index++;
            
            if (item != checkItem)
                ((TGCheckCollectionItem *)item).isChecked = false;
        }
    }
}

@end
