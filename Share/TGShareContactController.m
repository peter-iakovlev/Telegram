#import "TGShareContactController.h"
#import "TGVCard.h"
#import <AddressBook/AddressBook.h>

#import "TGChatListAvatarSignal.h"

#import "TGShareContactUserInfoCell.h"
#import "TGShareContactFieldCell.h"

#import "RMPhoneFormat.h"

@interface TGShareContactController () <UITableViewDataSource, UITableViewDelegate>
{
    TGShareContext *_context;
    TGVCard *_vcard;
    UITableView *_tableView;
    
    NSMutableSet *_skippedUniqueIds;
}
@end

@implementation TGShareContactController

- (instancetype)initWithContext:(TGShareContext *)context vCard:(TGVCard *)vcard uid:(int32_t)uid
{
    self = [super init];
    if (self != nil)
    {
        _context = context;
        _vcard = vcard;
        _skippedUniqueIds = [[NSMutableSet alloc] init];
     
        self.title = NSLocalizedString(@"Share.ContactInfo", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    _tableView.backgroundColor = [UIColor whiteColor];
}

- (void)donePressed
{
    TGVCard *vcard = [self vcardForCheckedItems];
    NSString *phone = [vcard.phones.values.firstObject value];
    TGPhoneNumberModel *phoneNumber = [[TGPhoneNumberModel alloc] initWithPhoneNumber:phone label:nil];
    TGContactModel *contact = [[TGContactModel alloc] initWithFirstName:vcard.firstName.value lastName:vcard.lastName.value phoneNumbers:@[phoneNumber] vcard:vcard];
    
    if (self.completionBlock != nil)
        self.completionBlock(contact);
}

- (TGVCard *)vcardForCheckedItems
{    
    return [_vcard vcardBySkippingItemsWithIds:_skippedUniqueIds];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            
        case 1: {
            if (_vcard.firstName.value.length == 0 && _vcard.lastName.value.length == 0 && _vcard.organization.value.length > 0)
                return 0;
            else
                return (_vcard.organization != nil || _vcard.department != nil || _vcard.jobTitle != nil) ? 1 : 0;
        }
            
        case 2:
            return _vcard.phones.values.count;
            
        case 3:
            return _vcard.emails.values.count;
            
        case 4:
            return _vcard.urls.values.count;
            
        case 5:
            return _vcard.addresses.values.count;
            
        case 6:
            return _vcard.birthday != nil ? 1 : 0;
            
        case 7:
            return _vcard.socialProfiles.values.count;
            
        case 8:
            return _vcard.instantMessengers.values.count;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TGShareContactUserInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"info"];
        if (cell == nil)
            cell = [[TGShareContactUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"info"];
        
        NSString *initials = @"";
        NSMutableArray *nameComponents = [[NSMutableArray alloc] init];
        if (_vcard.prefix.value.length > 0)
            [nameComponents addObject:_vcard.prefix.value];
        if (_vcard.firstName.value.length > 0) {
            [nameComponents addObject:_vcard.firstName.value];
            initials = [_vcard.firstName.value substringToIndex:1];
        }
        if (_vcard.middleName != nil)
            [nameComponents addObject:_vcard.middleName.value];
        if (_vcard.lastName.value.length > 0) {
            [nameComponents addObject:_vcard.lastName.value];
            initials = [initials stringByAppendingString:[_vcard.lastName.value substringToIndex:1]];
        }
        if (_vcard.suffix.value.length > 0)
            [nameComponents addObject:_vcard.suffix.value];
        
        NSString *name = [nameComponents componentsJoinedByString:@" "];
        if (_vcard.firstName.value.length == 0 && _vcard.lastName.value.length == 0 && _vcard.organization.value.length > 0) {
            name = _vcard.organization.value;
            initials = name.length > 0 ? [name substringToIndex:1] : @"";
        }
        
        SSignal *signal = [TGChatListAvatarSignal chatListAvatarWithContext:_context letters:initials peerId:TGPeerIdPrivateMake(0) imageSize:CGSizeMake(66.0f, 66.0f)];
        [cell setName:name avatarSignal:signal];
        
        return cell;
    } else {
        TGVCardValueArray *array = nil;
        switch (indexPath.section) {
            case 2:
                array = _vcard.phones;
                break;
                
            case 3:
                array = _vcard.emails;
                break;
                
            case 4:
                array = _vcard.urls;
                break;
                
            case 5:
                array = _vcard.addresses;
                break;
                
            case 7:
                array = _vcard.socialProfiles;
                break;
                
            case 8:
                array = _vcard.instantMessengers;
                break;
                
            default:
                break;
        }
        
        TGShareContactFieldCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"field"];
        if (cell == nil)
            cell = [[TGShareContactFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"field"];
        
        int64_t uniqueId = 0;
        NSString *label = nil;
        NSString *stringValue = nil;
        if (indexPath.section == 1)
        {
            label = NSLocalizedString(@"Share.ContactJob", nil);
            
            NSMutableSet *uniqueIds = [[NSMutableSet alloc] init];
            
            NSMutableArray *jobComponents = [[NSMutableArray alloc] init];
            if (_vcard.organization != nil) {
                [jobComponents addObject:_vcard.organization.value];
                [uniqueIds addObject:@(_vcard.organization.uniqueId)];
            }
            if (_vcard.department != nil) {
                [jobComponents addObject:_vcard.department.value];
                [uniqueIds addObject:@(_vcard.department.uniqueId)];
            }
            if (_vcard.jobTitle != nil) {
                [jobComponents addObject:_vcard.jobTitle.value];
                [uniqueIds addObject:@(_vcard.jobTitle.uniqueId)];
            }
            
            stringValue = [jobComponents componentsJoinedByString:@" - "];
            cell.uniqueIds = uniqueIds;
        }
        else if (indexPath.section == 5)
        {
            TGVCardValueArrayItem *item = array.values[indexPath.row];
            label = (__bridge NSString *)(ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)(item.label)));
            
            NSDictionary *dict = (NSDictionary *)item.value;
            
            NSMutableArray *addressComponents = [[NSMutableArray alloc] init];
            NSArray *keys = @[ @"Street", @"City", @"State", @"Country", @"ZIP" ];
            
            for (NSString *key in keys) {
                if ([dict[key] length] > 0)
                    [addressComponents addObject:dict[key]];
            }
            
            stringValue = [addressComponents componentsJoinedByString:@"\n"];
        }
        else if (indexPath.section == 6)
        {
            TGVCardValueDate *valueDate = _vcard.birthday;
            label = NSLocalizedString(@"Share.ContactBirthday", nil);
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:valueDate.value];
            if (components.year == 1604) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMMM dd"];
                stringValue = [dateFormatter stringFromDate:valueDate.value];
            }
            else {
                stringValue = [NSDateFormatter localizedStringFromDate:valueDate.value dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
            }
            
            uniqueId = valueDate.uniqueId;
        }
        else
        {
            TGVCardValueArrayItem *item = array.values[indexPath.row];
            label = (__bridge NSString *)(ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)(item.label)));
            if (array.objectType == [NSString class]) {
                stringValue = (NSString *)item.value;
                
                if (indexPath.section == 2) {
                    stringValue = [[RMPhoneFormat instance] format:stringValue implicitPlus:false];
                }
            } else {
                NSDictionary *dict = (NSDictionary *)item.value;
                if (dict[@"username"] != nil) {
                    if ([dict[@"service"] isEqualToString:(NSString *)kABPersonSocialProfileServiceTwitter]) {
                        stringValue = [NSString stringWithFormat:@"@%@", dict[@"username"]];
                    } else {
                        stringValue = dict[@"username"];
                    }
                }
                
                if (dict[@"service"] != nil) {
                    if (dict[@"url"] != nil) {
                        label = [TGShareContactController labelForSocialService:dict[@"service"]];
                    } else {
                        label = [TGShareContactController labelForInstantMessenger:dict[@"service"]];
                    }
                }
            }
            uniqueId = item.uniqueId;
        }
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 60.0f, 0.0f, 0.0f);
        cell.uniqueId = uniqueId;
        [cell setLabel:label value:stringValue];
        
        if (cell.uniqueIds != nil) {
            bool allSkipped = true;
            for (NSNumber *uniqueId in cell.uniqueIds) {
                if (![_skippedUniqueIds containsObject:uniqueId]) {
                    allSkipped = false;
                    break;
                }
            }
            [cell setChecked:!allSkipped];
        } else {
            [cell setChecked:![_skippedUniqueIds containsObject:@(uniqueId)]];
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.row < [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 || indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.bounds) / 2.0f, 0.0f, CGRectGetWidth(cell.bounds) / 2.0);
    else
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 60.0f, 0.0f, 0.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    TGShareContactFieldCell *cell = (TGShareContactFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setChecked:!cell.checked animated:true];
    
    if (cell.checked) {
        if (cell.uniqueIds != nil) {
            for (NSNumber *uniqueId in cell.uniqueIds) {
                [_skippedUniqueIds removeObject:uniqueId];
            }
        } else {
            [_skippedUniqueIds removeObject:@(cell.uniqueId)];
        }
    }
    else {
        if (cell.uniqueIds != nil) {
            for (NSNumber *uniqueId in cell.uniqueIds) {
                [_skippedUniqueIds addObject:uniqueId];
            }
        } else {
            [_skippedUniqueIds addObject:@(cell.uniqueId)];
        }
    }
    
    bool hasPhone = false;
    for (TGVCardValueArrayItem *item in _vcard.phones.values)
    {
        if (![_skippedUniqueIds containsObject:@(item.uniqueId)]) {
            hasPhone = true;
            break;
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = hasPhone;
}

+ (NSString *)labelForSocialService:(NSString *)service {
    NSString *label = service;
    if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceTwitter])
        label = @"Twitter";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceFacebook])
        label = @"Facebook";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceFlickr])
        label = @"Flickr";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceLinkedIn])
        label = @"LinkedIn";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceMyspace])
        label = @"Myspace";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceSinaWeibo])
        label = @"Sina Weibo";
    return label;
}

+ (NSString *)labelForInstantMessenger:(NSString *)service {
    NSString *label = service;
    if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceFacebook])
        label = @"Facebook Messenger";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceGoogleTalk])
        label = @"Google Talk";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceGaduGadu])
        label = @"Gadu-Gadu";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceMSN])
        label = @"MSN Messenger";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceYahoo])
        label = @"Yahoo! Messenger";
    return label;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 97.0f;
    }
    else if (indexPath.section == 5) {
        TGVCardValueArrayItem *item = _vcard.addresses.values[indexPath.row];
        
        NSDictionary *dict = (NSDictionary *)item.value;
        
        NSMutableArray *addressComponents = [[NSMutableArray alloc] init];
        NSArray *keys = @[ @"Street", @"City", @"State", @"Country", @"ZIP" ];
        
        for (NSString *key in keys) {
            if ([dict[key] length] > 0)
                [addressComponents addObject:dict[key]];
        }
        
        NSString *stringValue = [addressComponents componentsJoinedByString:@"\n"];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:stringValue attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:17.0f] }];
        CGSize size = [string boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        return ceil(size.height) + 40.0f;
    } else {
        return 60.0f;
    }
}

@end
