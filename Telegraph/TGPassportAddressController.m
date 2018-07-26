#import "TGPassportAddressController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"
#import "TGPresentation.h"
#import "TGTelegramNetworking.h"
#import "TGLegacyComponentsContext.h"

#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGPassportFileCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGTwoStepConfig.h"
#import "TGPassportForm.h"
#import "TGPassportFile.h"
#import "TGPassportSignals.h"

#import "TGLoginCountriesController.h"
#import "TGPassportRequestController.h"

#import "TGCustomAlertView.h"

@interface TGPassportAddressController ()
{
    TGPassportDecryptedValue *_address;
    TGPassportDecryptedValue *_document;
    NSString *_countryCode;
 
    bool _documentOnly;
    
    SMetaDisposable *_saveDisposable;
    
    TGCollectionMenuSection *_mainSection;
    TGUsernameCollectionItem *_street1Item;
    TGUsernameCollectionItem *_street2Item;
    TGUsernameCollectionItem *_postcodeItem;
    TGUsernameCollectionItem *_cityItem;
    TGUsernameCollectionItem *_stateItem;
    TGVariantCollectionItem *_countryItem;
    
    TGCommentCollectionItem *_errorsItem;
}
@end

@implementation TGPassportAddressController

- (instancetype)initWithSettings:(SVariable *)settings files:(NSArray *)files documentOnly:(bool)documentOnly inhibitFiles:(bool)inhibitFiles errors:(TGPassportErrors *)errors existing:(bool)existing
{
    self = [super initWithSettings:settings files:files inhibitFiles:inhibitFiles errors:errors existing:existing];
    if (self != nil)
    {
        _documentOnly = documentOnly;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
   
        bool isNarrowScreen = (int)TGScreenSize().width == 320;
        CGFloat minimalInset = 100.0f;
        if (isNarrowScreen)
            minimalInset = 90.0f;

        [_scansSection addItem:[[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Address.ScansHelp")]];
        
        if (!documentOnly)
        {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Address.Address")]];
            
            __weak TGPassportAddressController *weakSelf = self;
            void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf focusOnNextItem:currentItem];
                }
            };
            
            _street1Item = [[TGUsernameCollectionItem alloc] init];
            _street1Item.placeholder = [self placeholder:TGLocalized(@"Passport.Address.Street1Placeholder") clip:isNarrowScreen];
            _street1Item.title = TGLocalized(@"Passport.Address.Street");
            _street1Item.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _street1Item.minimalInset = minimalInset;
            _street1Item.usernameValid = true;
            _street1Item.returnKeyType = UIReturnKeyNext;
            _street1Item.returnPressed = focusOnNextItem;
            _street1Item.usernameChanged = ^(__unused NSString *value) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_changed = true;
                    if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressStreetLine1Key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressStreetLine1Key];
                        [strongSelf updateFieldErrors];
                    }
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_street1Item];
            
            _street2Item = [[TGUsernameCollectionItem alloc] init];
            _street2Item.placeholder = [self placeholder:TGLocalized(@"Passport.Address.Street2Placeholder") clip:isNarrowScreen];
            _street2Item.title = @" ";
            _street2Item.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _street2Item.minimalInset = minimalInset;
            _street2Item.usernameValid = true;
            _street2Item.returnKeyType = UIReturnKeyNext;
            _street2Item.returnPressed = focusOnNextItem;
            _street2Item.usernameChanged = ^(__unused NSString *value) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_changed = true;
                    if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressStreetLine2Key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressStreetLine2Key];
                        [strongSelf updateFieldErrors];
                    }
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_street2Item];
            
            _cityItem = [[TGUsernameCollectionItem alloc] init];
            _cityItem.placeholder = TGLocalized(@"Passport.Address.CityPlaceholder");
            _cityItem.title = TGLocalized(@"Passport.Address.City");
            _cityItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _cityItem.minimalInset = minimalInset;
            _cityItem.usernameValid = true;
            _cityItem.returnKeyType = UIReturnKeyNext;
            _cityItem.returnPressed = focusOnNextItem;
            _cityItem.usernameChanged = ^(__unused NSString *value) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_changed = true;
                    if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressCityKey])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressCityKey];
                        [strongSelf updateFieldErrors];
                    }
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_cityItem];
            
            _stateItem = [[TGUsernameCollectionItem alloc] init];
            _stateItem.placeholder = TGLocalized(@"Passport.Address.RegionPlaceholder");
            _stateItem.title = TGLocalized(@"Passport.Address.Region");
            _stateItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _stateItem.minimalInset = minimalInset;
            _stateItem.usernameValid = true;
            _stateItem.returnKeyType = UIReturnKeyNext;
            _stateItem.returnPressed = focusOnNextItem;
            _stateItem.usernameChanged = ^(__unused NSString *value) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_changed = true;
                    if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressStateKey])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressStateKey];
                        [strongSelf updateFieldErrors];
                    }
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_stateItem];
            
            _countryItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Address.Country") variant:nil action:@selector(countryPressed)];
            _countryItem.minLeftPadding = minimalInset + 20.0f;
            _countryItem.variant = TGLocalized(@"Passport.Address.CountryPlaceholder");
            _countryItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            [items addObject:_countryItem];
            
            _postcodeItem = [[TGUsernameCollectionItem alloc] init];
            _postcodeItem.placeholder = TGLocalized(@"Passport.Address.PostcodePlaceholder");
            _postcodeItem.title = TGLocalized(@"Passport.Address.Postcode");
            _postcodeItem.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            _postcodeItem.keyboardType = UIKeyboardTypeASCIICapable;
            _postcodeItem.minimalInset = minimalInset;
            _postcodeItem.usernameValid = true;
            _postcodeItem.returnPressed = ^(TGUsernameCollectionItem *item)
            {
                [item resignFirstResponder];
            };;
            _postcodeItem.usernameChanged = ^(__unused NSString *value) {
                __strong TGPassportAddressController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_changed = true;
                    if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressPostcodeKey])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressPostcodeKey];
                        [strongSelf updateFieldErrors];
                    }
                    [strongSelf checkInputValues];
                }
            };
            _postcodeItem.shouldChangeText = ^bool(NSString *text)
            {
                if (text.length > 10)
                    return false;
                
                NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-"];
                NSCharacterSet *invalidChars = [validChars invertedSet];
                return [text.uppercaseString rangeOfCharacterFromSet:invalidChars].location == NSNotFound;
            };
            [items addObject:_postcodeItem];
            
            _mainSection = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections insertSection:_mainSection atIndex:0];
        }
        
        TGCollectionMenuSection *topSection = self.menuSections.sections.firstObject;
        UIEdgeInsets topSectionInsets = topSection.insets;
        topSectionInsets.top = 32.0f;
        topSection.insets = topSectionInsets;
    }
    return self;
}

- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly settings:(SVariable *)settings errors:(TGPassportErrors *)errors
{
    self = [self initWithSettings:settings files:document.files documentOnly:documentOnly inhibitFiles:type == TGPassportTypeAddress errors:errors existing:address != nil || document != nil];
    if (self != nil)
    {
        _type = document.type != TGPassportTypeUndefined ? document.type : (address.type != TGPassportTypeUndefined ? address.type : type);
         self.title = [TGPassportAddressController documentDisplayNameForType:_type];
        
        _document = document;
        [self setupWithAddress:address];
        [self updateFieldErrors];
        [self updateFiles];
        [self checkInputValues];
        
        _deleteItem.title = [self deleteTitle];
    }
    return self;
}

- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address documentOnly:(bool)documentOnly uploads:(NSArray *)uploads settings:(SVariable *)settings errors:(TGPassportErrors *)errors
{
    self = [self initWithSettings:settings files:nil documentOnly:documentOnly inhibitFiles:type == TGPassportTypeAddress errors:errors existing:false];
    if (self != nil)
    {
        self.title = [TGPassportAddressController documentDisplayNameForType:type];
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        _type = type;
        [self setupWithAddress:address];
        [self updateFieldErrors];
        
        for (TGPassportFileUpload *upload in uploads)
        {
            [self enqueueFileUpload:upload];
        }
        
        [self checkInputValues];
    }
    return self;
}

- (NSString *)deleteTitle
{
    if (_type == TGPassportTypeAddress)
        return TGLocalized(@"Passport.DeleteAddress");
    else
        return [super deleteTitle];
}

- (NSString *)deleteConfirmationText
{
    if (_type == TGPassportTypeAddress)
        return TGLocalized(@"Passport.DeleteAddressConfirmation");
    else
        return [super deleteConfirmationText];
}

- (void)setupWithAddress:(TGPassportDecryptedValue *)address {
    _address = address;
    if (_address == nil)
        return;
    
    TGPassportAddressData *addressData = (TGPassportAddressData *)address.data;
    _countryCode = addressData.countryCode;
    
    _street1Item.username = addressData.street1;
    _street2Item.username = addressData.street2;
    _cityItem.username = addressData.city;
    _stateItem.username = addressData.state;
    _countryItem.variant = [TGLoginCountriesController countryNameByCountryId:addressData.countryCode code:NULL];
    _countryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    _postcodeItem.username = addressData.postcode;
}

- (void)updateFieldErrors
{
    UIColor *normalColor = self.presentation.pallete.collectionMenuTextColor;
    UIColor *errorColor = self.presentation.pallete.collectionMenuDestructiveColor;
    
    _street1Item.titleColor = normalColor;
    _street2Item.titleColor = normalColor;
    _cityItem.titleColor = normalColor;
    _stateItem.titleColor = normalColor;
    _countryItem.titleColor = normalColor;
    _postcodeItem.titleColor = normalColor;
    
    NSString *errorsString = @"";
    for (TGPassportError *error in [self.errors fieldErrorsForType:TGPassportTypeAddress])
    {
        if ([error.key isEqualToString:TGPassportAddressStreetLine1Key])
            _street1Item.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportAddressStreetLine2Key])
            _street2Item.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportAddressCityKey])
            _cityItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportAddressStateKey])
            _stateItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportAddressCountryCodeKey])
            _countryItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportAddressPostcodeKey])
            _postcodeItem.titleColor = errorColor;
        
        if (error.text.length > 0)
        {
            if (errorsString.length == 0)
                errorsString = error.text;
            else
                errorsString = [errorsString stringByAppendingFormat:@"\n%@", error.text];
        }
    }
    
    if (errorsString.length > 0 && _errorsItem == nil)
    {
        _errorsItem = [[TGCommentCollectionItem alloc] initWithText:errorsString];
        _errorsItem.sizeInset = -10.0f;
        _errorsItem.textColor = self.presentation.pallete.collectionMenuDestructiveColor;
        [_mainSection insertItem:_errorsItem atIndex:1];
    }
    else
    {
        bool changed = ![_errorsItem.text isEqualToString:errorsString];
        _errorsItem.text = errorsString;
        _errorsItem.hidden = errorsString.length == 0;
        
        if (changed)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
            {
                [self.collectionView.collectionViewLayout invalidateLayout];
            } completion:nil];
        }
    }
    
    [self updateFileErrors];
}

- (void)donePressed
{
    if (_saveDisposable == nil)
        _saveDisposable = [[SMetaDisposable alloc] init];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.45];
    
    __weak TGPassportAddressController *weakSelf = self;
    [_saveDisposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        __strong TGPassportAddressController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return [SSignal complete];
        
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        
        bool hasData = !strongSelf->_documentOnly;
        bool hasDocument = strongSelf->_type != TGPassportTypeAddress;
        
        TGPassportDecryptedValue *addressValue = nil;
        if (hasData)
        {
            NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            TGPassportAddressData *addressData = [[TGPassportAddressData alloc] initWithStreet1:[strongSelf->_street1Item.username stringByTrimmingCharactersInSet:whitespaceSet] street2:[strongSelf->_street2Item.username stringByTrimmingCharactersInSet:whitespaceSet] postcode:[strongSelf->_postcodeItem.username stringByTrimmingCharactersInSet:whitespaceSet] city:[strongSelf->_cityItem.username stringByTrimmingCharactersInSet:whitespaceSet] state:[strongSelf->_stateItem.username stringByTrimmingCharactersInSet:whitespaceSet] countryCode:strongSelf->_countryCode secret:request.settings.secret];
            
            addressValue = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypeAddress data:addressData frontSide:nil reverseSide:nil selfie:nil files:nil plainData:nil];
            [signals addObject:[TGPassportSignals saveSecureValue:addressValue secret:request.settings.secret]];
        }
        
        TGPassportDecryptedValue *documentValue = nil;
        if (hasDocument)
        {
            documentValue = [[TGPassportDecryptedValue alloc] initWithType:strongSelf->_type data:nil frontSide:nil reverseSide:nil selfie:nil files:strongSelf.files plainData:nil];
            [signals addObject:[TGPassportSignals saveSecureValue:documentValue secret:request.settings.secret]];
        }
        
        return [[SSignal combineSignals:signals] map:^id(NSArray *next)
        {
            TLSecureValue *updatedAddressValue = next.count > 0 && hasData ? next.firstObject : nil;
            TLSecureValue *updatedDocumentValue = (!hasData && next.count > 0) ? next.firstObject : ((hasData && next.count > 1) ? next.lastObject : nil);
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            TGPassportDecryptedValue *finalAddressValue = [addressValue updateWithValueHash:updatedAddressValue.n_hash];
            if (finalAddressValue != nil)
                result[@"address"] = finalAddressValue;
            
            TGPassportDecryptedValue *finalDocumentValue = [documentValue updateWithValueHash:updatedDocumentValue.n_hash];
            if (finalDocumentValue != nil)
                result[@"document"] = finalDocumentValue;
            
            return result;
        }];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong TGPassportAddressController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [progressWindow dismiss:true];
        
        TGPassportDecryptedValue *addressValue = next[@"address"];
        TGPassportDecryptedValue *documentValue = next[@"document"];
        
        if (strongSelf.completionBlock != nil)
            strongSelf.completionBlock(addressValue, documentValue, strongSelf.errors);
        
        strongSelf->_changed = false;
        [strongSelf.navigationController popViewControllerAnimated:true];
    } error:^(__unused id error)
    {
        [progressWindow dismiss:true];
        
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        [TGCustomAlertView presentAlertWithTitle:displayText message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:^
    {
        
    }]];
}

- (NSString *)placeholder:(NSString *)string clip:(bool)clip
{
    if (!clip)
        return string;
    
    NSArray *components = [string componentsSeparatedByString:@", "];
    if (components.count < 2)
        return string;
    
    NSArray *lessComponents = [components subarrayWithRange:NSMakeRange(0, components.count - 1)];
    return [lessComponents componentsJoinedByString:@", "];
}

- (void)countryPressed
{
    [self presentCountryPicker:false];
}

- (void)presentCountryPicker:(bool)fromNext
{
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] initWithCodes:false];
    countriesController.presentation = self.presentation;
    __weak TGPassportAddressController *weakSelf = self;
    countriesController.countrySelected = ^(__unused int code, NSString *name, NSString *countryId)
    {
        __strong TGPassportAddressController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_countryCode = countryId;
            strongSelf->_countryItem.variant = name;
            strongSelf->_countryItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
            
            if (fromNext && strongSelf->_postcodeItem.username.length == 0)
            {
                TGDispatchAfter(0.5, dispatch_get_main_queue(), ^
                {
                    [strongSelf focusOnItem:strongSelf->_postcodeItem];
                });
            }
            
            strongSelf->_changed = true;
            if ([strongSelf.errors errorForType:TGPassportTypeAddress dataField:TGPassportAddressCountryCodeKey])
            {
                [strongSelf.errors correctErrorForType:TGPassportTypeAddress dataField:TGPassportAddressCountryCodeKey];
                [strongSelf updateFieldErrors];
            }
            [strongSelf checkInputValues];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - View

- (void)checkInputValues
{
    bool hasStreet = _street1Item.username.length > 0;
    bool hasCity = _cityItem.username.length >= 2;
    bool hasCountry = _countryCode.length > 0;
    bool hasStateIfNeeded = ![_countryCode isEqualToString:@"US"] || _stateItem.username.length >= 2;
    bool hasPostcode = _postcodeItem.username.length > 0 && _postcodeItem.username.length <= 12;
    bool hasAddress = (hasStreet && hasCity && hasCountry && hasStateIfNeeded && hasPostcode) || _documentOnly;
    
    bool hasSomeFiles = self.files.count > 0 || _scansSection == nil;
    bool hasNoUploads = self.uploads.count == 0;
    bool hasNoErrors = ([self.errors errorsForType:TGPassportTypeAddress].count + [self.errors errorsForType:_type].count) == 0;
    
    self.navigationItem.rightBarButtonItem.enabled = hasAddress && hasSomeFiles && hasNoUploads && hasNoErrors;
}

- (void)focusOnItem:(TGUsernameCollectionItem *)item {
    NSIndexPath *indexPath = [self indexPathForItem:item];
    if (indexPath != nil) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:true];
        [self.collectionView layoutSubviews];
        if ([item isKindOfClass:[TGUsernameCollectionItem class]]) {
            [((TGUsernameCollectionItem *)item) becomeFirstResponder];
        }
    }
}

- (void)focusOnNextItem:(TGCollectionItem *)currentItem {
    if (currentItem == _street1Item)
        [self focusOnItem:_street2Item];
    else if (currentItem == _street2Item)
        [self focusOnItem:_cityItem];
    else if (currentItem == _cityItem)
        [self focusOnItem:_stateItem];
    else if (currentItem == _stateItem)
        [self presentCountryPicker:true];
}

+ (NSString *)documentDisplayNameForType:(TGPassportType)type
{
    switch (type)
    {
        case TGPassportTypeAddress:
            return TGLocalized(@"Passport.Address.TypeResidentialAddress");
            
        case TGPassportTypeUtilityBill:
            return TGLocalized(@"Passport.Address.TypeUtilityBill");
            
        case TGPassportTypeBankStatement:
            return TGLocalized(@"Passport.Address.TypeBankStatement");
            
        case TGPassportTypeRentalAgreement:
            return TGLocalized(@"Passport.Address.TypeRentalAgreement");
            
        case TGPassportTypePassportRegistration:
            return TGLocalized(@"Passport.Address.TypePassportRegistration");
            
        case TGPassportTypeTemporaryRegistration:
            return TGLocalized(@"Passport.Address.TypeTemporaryRegistration");
            
        default:
            return nil;
    }
}

- (TGPassportType)type
{
    return _type;
}

- (bool)shouldScanDocument
{
    return false;
}

@end
