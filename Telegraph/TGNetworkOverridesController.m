#import "TGNetworkOverridesController.h"

#import "TGSwitchCollectionItem.h"
#import "TGCollectionMultilineInputItem.h"
#import "TGButtonCollectionItem.h"

#import "TGAlertView.h"

@interface TGNetworkOverridesController () {
    TGCollectionMultilineInputItem *_tcpPrefixItem;
    
    NSArray *_datacenterAddressItems;
}

@end

@implementation TGNetworkOverridesController

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.title = @"Network Overrides";
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(restartPressed)]];
        
        _tcpPrefixItem = [[TGCollectionMultilineInputItem alloc] init];
        _tcpPrefixItem.placeholder = @"TCP payload prefix";
        _tcpPrefixItem.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"network_tcpPayloadPrefix"];
        
        TGCollectionMenuSection *generalSection = [[TGCollectionMenuSection alloc] initWithItems:@[_tcpPrefixItem]];
        generalSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, generalSection.insets.bottom, 0.0f);
        [self.menuSections addSection:generalSection];
        
        NSMutableArray *datacenterAddressItems = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 5; i++) {
            TGCollectionMultilineInputItem *item = [[TGCollectionMultilineInputItem alloc] init];
            item.placeholder = [NSString stringWithFormat:@"Datacenter %d", (int)i + 1];
            item.text = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"network_datacenterAddress_%d", (int)i + 1]];
            
            [datacenterAddressItems addObject:item];
        }
        _datacenterAddressItems = datacenterAddressItems;
        TGButtonCollectionItem *resetDatacenterAddresses = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset" action:@selector(resetDatacenterAddresses)];
        
        TGCollectionMenuSection *datacenterAddressOverridesSection = [[TGCollectionMenuSection alloc] initWithItems:[_datacenterAddressItems arrayByAddingObjectsFromArray:@[resetDatacenterAddresses]]];
        [self.menuSections addSection:datacenterAddressOverridesSection];
    }
    return self;
}

- (bool)validate {
    NSRegularExpression *tcpPrefixRegex = [[NSRegularExpression alloc] initWithPattern:@"^([0-9a-fA-F][0-9a-fA-F])?$" options:0 error:nil];
    
    if ([tcpPrefixRegex matchesInString:_tcpPrefixItem.text == nil ? @"" : _tcpPrefixItem.text options:0 range:NSMakeRange(0, _tcpPrefixItem.text.length)].count == 0) {
        [[[TGAlertView alloc] initWithTitle:nil message:@"Invalid TCP payload prefix" cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        
        return false;
    }
    
    NSRegularExpression *datacenterAddressListRegex = [[NSRegularExpression alloc] initWithPattern:@"^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+(:[0-9]+)?)?$" options:0 error:nil];
    for (int i = 0; i < (int)_datacenterAddressItems.count; i++) {
        NSString *text = ((TGCollectionMultilineInputItem *)_datacenterAddressItems[i]).text;
        if ([datacenterAddressListRegex matchesInString:text == nil ? @"" : text options:0 range:NSMakeRange(0, text.length)].count == 0) {
            [[[TGAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Invalid address for DC %d", i + 1] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            return false;
        }
    }
    return true;
}

- (void)restartPressed {
    if ([self validate]) {
        if (_tcpPrefixItem.text.length != 0) {
            [[NSUserDefaults standardUserDefaults] setObject:_tcpPrefixItem.text forKey:@"network_tcpPayloadPrefix"];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"network_tcpPayloadPrefix"];
        }
        
        for (NSInteger i = 0; i < 5; i++) {
            NSString *text = ((TGCollectionMultilineInputItem *)_datacenterAddressItems[i]).text;
            if (text.length != 0) {
                [[NSUserDefaults standardUserDefaults] setObject:text forKey:[NSString stringWithFormat:@"network_datacenterAddress_%d", (int)i + 1]];
            } else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"network_datacenterAddress_%d", (int)i + 1]];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        TGDispatchAfter(1.0, dispatch_get_main_queue(), ^{
            exit(0);
        });
    }
}

- (void)resetDatacenterAddresses {
    for (TGCollectionMultilineInputItem *item in _datacenterAddressItems) {
        item.text = @"";
    }
}

@end
