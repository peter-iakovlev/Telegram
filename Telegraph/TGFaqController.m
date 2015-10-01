#import "TGFaqController.h"

#import "ActionStage.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGCollectionBottonDisclosureItem.h"

#import "TGStringUtils.h"

static NSArray *cachedResult = nil;

@interface TGFaqController () <ASWatcher>
{
    UIActivityIndicatorView *_activityIndicator;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGFaqController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"Settings.FAQ");
        
        if (cachedResult == nil)
        {
            _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
            [ActionStageInstance() requestActor:@"/faq" options:nil watcher:self];
        }
        else
            [self setCategories:cachedResult];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_activityIndicator == nil && self.menuSections.sections.count == 0)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
}

- (void)setCategories:(NSArray *)categories
{
    if (_activityIndicator != nil)
    {
        self.collectionView.alpha = 0.0f;
        [UIView animateWithDuration:0.25 animations:^
        {
            self.collectionView.alpha = 1.0f;
            _activityIndicator.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [_activityIndicator removeFromSuperview];
            [_activityIndicator stopAnimating];
            _activityIndicator = nil;
        }];
    }
    
    while (self.menuSections.sections.count != 0)
    {
        [self.menuSections deleteSection:0];
    }
    
    for (NSDictionary *category in categories)
    {
        if (((NSArray *)category[@"subcategories"]).count == 0)
            continue;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:[category[@"title"] uppercaseString]]];
        
        for (NSDictionary *subcategory in category[@"subcategories"])
        {
            NSString *title = subcategory[@"title"];
            if ([title hasPrefix:@"Q: "])
                title = [title substringFromIndex:@"Q: ".length];
            title = [TGStringUtils stringByUnescapingFromHTML:title];
            TGCollectionBottonDisclosureItem *item = [[TGCollectionBottonDisclosureItem alloc] initWithTitle:title text:subcategory[@"text"]];
            __weak TGFaqController *weakSelf = self;
            item.expandedChanged = ^(__unused TGCollectionBottonDisclosureItem *item)
            {
                __strong TGFaqController *strongSelf = weakSelf;
                //[UIView animateWithDuration:0.2 animations:^
                //{
                    [strongSelf.collectionLayout invalidateLayout];
                    [strongSelf.collectionView layoutSubviews];
                //}];
            };
            item.followAnchor = ^(NSString *anchor)
            {
                __strong TGFaqController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    NSInteger categoryIndex = -1;
                    NSInteger itemIndex = -1;
                    for (NSDictionary *category in categories)
                    {
                        categoryIndex++;
                        
                        if ([category[@"anchor"] isEqualToString:anchor])
                            break;
                        
                        NSInteger subcategoryIndex = -1;
                        for (NSDictionary *subcategory in category[@"subcategories"])
                        {
                            if ([subcategory[@"anchor"] isEqualToString:anchor])
                            {
                                itemIndex = subcategoryIndex;
                                break;
                            }
                        }
                        
                        if (itemIndex != -1)
                            break;
                    }
                    
                    if (categoryIndex != -1)
                    {
                        NSIndexPath *indexPath = nil;
                        if (itemIndex != -1)
                            indexPath = [NSIndexPath indexPathForItem:itemIndex + 1 inSection:categoryIndex];
                        else
                            indexPath = [NSIndexPath indexPathForItem:0 inSection:categoryIndex];
                        
                        if (indexPath != nil)
                        {
                            [strongSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:true];
                        }
                    }
                }
            };
            [items addObject:item];
        }
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
        [self.menuSections addSection:section];
    }
    
    if (self.menuSections.sections.count != 0)
    {
        TGCollectionMenuSection *topSection = self.menuSections.sections.firstObject;
        UIEdgeInsets insets = topSection.insets;
        insets.top = 32.0f;
        topSection.insets = insets;
    }
    
    [self.collectionView reloadData];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:@"/faq"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                cachedResult = result;
                [self setCategories:result];
            }
        });
    }
}

@end
