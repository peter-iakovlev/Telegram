#import "TGUpdateAppController.h"

#import "TGApplication.h"

#import "TGUpdateAppInfo.h"
#import "TGUpdateAppInfoItem.h"
#import "TGButtonCollectionItem.h"

@interface TGUpdateAppController ()
{
    TGUpdateAppInfo *_updateInfo;
}
@end

@implementation TGUpdateAppController

- (instancetype)initWithUpdateInfo:(TGUpdateAppInfo *)updateInfo
{
    self = [super init];
    if (self != nil)
    {
        _updateInfo  = updateInfo;
        
        self.title = TGLocalized(@"Update.Title");
        
        if (updateInfo.popup)
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Update.Skip") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        }
        
        TGUpdateAppInfoItem *infoItem = [[TGUpdateAppInfoItem alloc] init];
        infoItem.title = [NSString stringWithFormat:TGLocalized(@"Update.AppVersion"), updateInfo.version];
        infoItem.text = updateInfo.text;
        infoItem.entities = updateInfo.entities;
        infoItem.followLink = ^(NSString *url)
        {
            [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:url]];
        };
        
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[infoItem]];
        [self.menuSections addSection:infoSection];
        
        TGButtonCollectionItem *updateItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Update.UpdateApp") action:@selector(updatePressed)];
        updateItem.alignment = NSTextAlignmentCenter;
        updateItem.deselectAutomatically = true;
        TGCollectionMenuSection *buttonSection = [[TGCollectionMenuSection alloc] initWithItems:@[updateItem]];
        [self.menuSections addSection:buttonSection];
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)updatePressed
{
    NSNumber *appStoreId = @686449807;
#ifdef TELEGRAM_APPSTORE_ID
    appStoreId = TELEGRAM_APPSTORE_ID;
#endif
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appStoreId]];
    [[UIApplication sharedApplication] openURL:appStoreURL];
}

@end
