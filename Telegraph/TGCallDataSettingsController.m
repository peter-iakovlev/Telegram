#import "TGCallDataSettingsController.h"

#import "TGAppDelegate.h"

#import "TGRegularCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"

@interface TGCallDataSettingsController ()
{
    TGRegularCheckCollectionItem *_neverItem;
    TGRegularCheckCollectionItem *_mobileItem;
    TGRegularCheckCollectionItem *_alwaysItem;
    
}
@end

@implementation TGCallDataSettingsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"CallSettings.UseLessData")];
    
        _neverItem = [[TGRegularCheckCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.Never") action:@selector(neverPressed)];
        _neverItem.deselectAutomatically = true;
        _mobileItem = [[TGRegularCheckCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.OnMobile") action:@selector(mobilePressed)];
        _mobileItem.deselectAutomatically = true;
        _alwaysItem = [[TGRegularCheckCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.Always") action:@selector(alwaysPressed)];
        _alwaysItem.deselectAutomatically = true;
        
        [self _setMode:TGAppDelegateInstance.callsDataUsageMode save:false];
        
        TGCollectionMenuSection *mainSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
            _neverItem,
            _mobileItem,
            _alwaysItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"CallSettings.UseLessDataLongDescription")]
        ]];
        
        UIEdgeInsets topSectionInsets = mainSection.insets;
        topSectionInsets.top = 32.0f;
        mainSection.insets = topSectionInsets;
        
        [self.menuSections addSection:mainSection];

    }
    return self;
}

- (void)neverPressed
{
    [self _setMode:0 save:true];
}

- (void)mobilePressed
{
    [self _setMode:1 save:true];
}

- (void)alwaysPressed
{
    [self _setMode:2 save:true];
}

- (void)_setMode:(int)mode save:(bool)save
{
    _neverItem.isChecked = (mode == 0);
    _mobileItem.isChecked = (mode == 1);
    _alwaysItem.isChecked = (mode == 2);
    
    if (save)
    {
        TGAppDelegateInstance.callsDataUsageMode = mode;
        [TGAppDelegateInstance saveSettings];
        
        if (self.onModeChanged != nil)
            self.onModeChanged(mode);
    }
}

@end
