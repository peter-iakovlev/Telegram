#import "TGPassportIdentityController.h"

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
#import "TGPassportErrors.h"
#import "TGPassportICloud.h"
#import "TGPassportLanguageMap.h"

#import "PhotoResources.h"
#import "ImageResourceDatas.h"

#import "TGLoginCountriesController.h"
#import "TGPassportRequestController.h"
#import "TGPassportScanController.h"

#import "TGCustomActionSheet.h"
#import "TGCustomAlertView.h"

#import "TGPassportBirthDateMenu.h"
#import "TGPassportGenderMenu.h"

@interface TGPassportIdentityController ()
{
    TGPassportDecryptedValue *_details;
    TGPassportDecryptedValue *_document;
    TGPassportGender _gender;
    NSString *_birthDate;
    NSString *_countryCode;
    NSString *_residenceCountryCode;
    NSString *_expiryDate;
    
    bool _editing;
    bool _documentOnly;
    bool _selfieRequired;
    bool _translationRequired;
    bool _nativeNames;
    
    bool _forceNativeNamesVisible;
    
    bool _scrollToSelfie;
    bool _scrollToTranslation;
    bool _scrollToNativeNames;
    
    SMetaDisposable *_ocrDisposable;
    
    TGPassportFile *_frontSide;
    TGPassportFileUpload *_frontSideUpload;
    SMetaDisposable *_frontSideUploadDisposable;
    SVariable *_frontSideProgress;
    
    TGPassportFile *_reverseSide;
    TGPassportFileUpload *_reverseSideUpload;
    SMetaDisposable *_reverseSideUploadDisposable;
    SVariable *_reverseSideProgress;
    
    TGPassportFile *_selfie;
    TGPassportFileUpload *_selfieUpload;
    SMetaDisposable *_selfieUploadDisposable;
    SVariable *_selfieProgress;
    
    SMetaDisposable *_saveDisposable;
    
    TGPassportLanguageMap *_languageMap;
    SMetaDisposable *_langDisposable;
    
    TGCollectionMenuSection *_sidesSection;
    TGPassportFileCollectionItem *_frontItem;
    TGPassportFileCollectionItem *_reverseItem;
    TGPassportFileCollectionItem *_selfieItem;
    TGPassportFileCollectionItem *_translationItem;
    
    NSString *_firstNameNative;
    NSString *_middleNameNative;
    NSString *_lastNameNative;
    
    TGUsernameCollectionItem *_firstNameItem;
    TGUsernameCollectionItem *_middleNameItem;
    TGUsernameCollectionItem *_lastNameItem;
    
    TGCollectionMenuSection *_nativeNameSection;
    TGCommentCollectionItem *_nativeTitleItem;
    TGUsernameCollectionItem *_firstNameNativeItem;
    TGUsernameCollectionItem *_middleNameNativeItem;
    TGUsernameCollectionItem *_lastNameNativeItem;
    TGCommentCollectionItem *_nativeCommentItem;
    
    TGCollectionMenuSection *_mainSection;
    TGCommentCollectionItem *_errorsItem;
    TGVariantCollectionItem *_genderItem;
    TGVariantCollectionItem *_birthDateItem;
    TGVariantCollectionItem *_countryItem;
    TGVariantCollectionItem *_residenceCountryItem;
    TGUsernameCollectionItem *_documentNoItem;
    TGVariantCollectionItem *_expiryItem;
    
    TGButtonCollectionItem *_scanItem;
}

@property (nonatomic, copy) bool (^checkLatinOnly)(NSString *);

@end

@implementation TGPassportIdentityController

- (instancetype)initWithSettings:(SVariable *)settings files:(NSDictionary *)files documentOnly:(bool)documentOnly inhibitFiles:(bool)inhibitFiles selfie:(bool)selfie translation:(bool)translation nativeNames:(bool)nativeNames editing:(bool)editing errors:(TGPassportErrors *)errors existing:(bool)existing
{
    bool needsTranslation = (translation || editing) && !inhibitFiles;
    NSArray *fileTypes = needsTranslation ? @[@(TGPassportDocumentFileTypeTranslation)] : @[];
    self = [super initWithSettings:settings files:files fileTypes:fileTypes errors:errors existing:existing];
    if (self != nil)
    {
        _editing = editing;
        _documentOnly = documentOnly;
        _selfieRequired = selfie;
        _translationRequired = translation;
        _nativeNames = nativeNames;
        
        self.checkLatinOnly = ^bool(NSString *text)
        {
            NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ- "];
            NSCharacterSet *invalidChars = [validChars invertedSet];
            return [text.uppercaseString rangeOfCharacterFromSet:invalidChars].location == NSNotFound;
        };
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        CGFloat minimalInset = 124.0f;
                
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if (!inhibitFiles)
        {
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.FilesTitle")]];
            [items addObject:[[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Identity.ScansHelp")]];
            [self updateSides];
            
            _sidesSection = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections insertSection:_sidesSection atIndex:0];
                    
            items = [[NSMutableArray alloc] init];
        }
    
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.DocumentDetails")]];
        
        __weak TGPassportIdentityController *weakSelf = self;
        void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
            __strong TGPassportIdentityController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf focusOnNextItem:currentItem];
            }
        };
        
        if (!documentOnly)
        {
            if (!_editing && TGLocalized(@"Passport.Identity.LatinNameHelp").length > 0)
            {
                TGCommentCollectionItem *nameHelpItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Identity.LatinNameHelp")];
                nameHelpItem.sizeInset = -10.0f;
                [items addObject:nameHelpItem];
            }
            
            for (TGPassportError *error in [errors fieldErrorsForType:TGPassportTypePersonalDetails])
            {
                if ([error.key isEqualToString:TGPassportIdentityFirstNameNativeKey] || [error.key isEqualToString:TGPassportIdentityMiddleNameNativeKey] || [error.key isEqualToString:TGPassportIdentityLastNameNativeKey])
                {
                    _forceNativeNamesVisible = true;
                }
            }
            
            _firstNameItem = [[TGUsernameCollectionItem alloc] init];
            _firstNameItem.placeholder = TGLocalized(@"Passport.Identity.NamePlaceholder");
            _firstNameItem.title = TGLocalized(@"Passport.Identity.Name");
            _firstNameItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _firstNameItem.keyboardType = UIKeyboardTypeASCIICapable;
            _firstNameItem.minimalInset = minimalInset;
            _firstNameItem.usernameValid = true;
            _firstNameItem.returnKeyType = UIReturnKeyNext;
            _firstNameItem.returnPressed = focusOnNextItem;
            _firstNameItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityFirstNameKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_firstNameItem];
            
            _middleNameItem = [[TGUsernameCollectionItem alloc] init];
            _middleNameItem.placeholder = TGLocalized(@"Passport.Identity.MiddleNamePlaceholder");
            _middleNameItem.title = TGLocalized(@"Passport.Identity.MiddleName");
            _middleNameItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _middleNameItem.keyboardType = UIKeyboardTypeASCIICapable;
            _middleNameItem.minimalInset = minimalInset;
            _middleNameItem.usernameValid = true;
            _middleNameItem.returnKeyType = UIReturnKeyNext;
            _middleNameItem.returnPressed = focusOnNextItem;
            _middleNameItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityMiddleNameKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_middleNameItem];
            
            _lastNameItem = [[TGUsernameCollectionItem alloc] init];
            _lastNameItem.placeholder = TGLocalized(@"Passport.Identity.SurnamePlaceholder");
            _lastNameItem.title = TGLocalized(@"Passport.Identity.Surname");
            _lastNameItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _lastNameItem.keyboardType = UIKeyboardTypeASCIICapable;
            _lastNameItem.minimalInset = minimalInset;
            _lastNameItem.usernameValid = true;
            _lastNameItem.returnKeyType = UIReturnKeyNext;
            _lastNameItem.returnPressed = focusOnNextItem;
            _lastNameItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityLastNameKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [items addObject:_lastNameItem];
            
            NSMutableArray *nameItems = [[NSMutableArray alloc] init];
            if (TGLocalized(@"Passport.Identity.NativeNameTitle").length > 0)
            {
                _nativeTitleItem = [[TGCommentCollectionItem alloc] initWithText:@""];
                _nativeTitleItem.sizeInset = -10.0f;
                [nameItems addObject:_nativeTitleItem];
            }
            
            _firstNameNativeItem = [[TGUsernameCollectionItem alloc] init];
            _firstNameNativeItem.placeholder = TGLocalized(@"Passport.Identity.NamePlaceholder");
            _firstNameNativeItem.title = TGLocalized(@"Passport.Identity.Name");
            _firstNameNativeItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _firstNameNativeItem.keyboardType = UIKeyboardTypeDefault;
            _firstNameNativeItem.minimalInset = minimalInset;
            _firstNameNativeItem.usernameValid = true;
            _firstNameNativeItem.returnKeyType = UIReturnKeyNext;
            _firstNameNativeItem.returnPressed = focusOnNextItem;
            _firstNameNativeItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityFirstNameNativeKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [nameItems addObject:_firstNameNativeItem];
            
            _middleNameNativeItem = [[TGUsernameCollectionItem alloc] init];
            _middleNameNativeItem.placeholder = TGLocalized(@"Passport.Identity.MiddleNamePlaceholder");
            _middleNameNativeItem.title = TGLocalized(@"Passport.Identity.MiddleName");
            _middleNameNativeItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _middleNameNativeItem.keyboardType = UIKeyboardTypeDefault;
            _middleNameNativeItem.minimalInset = minimalInset;
            _middleNameNativeItem.usernameValid = true;
            _middleNameNativeItem.returnKeyType = UIReturnKeyNext;
            _middleNameNativeItem.returnPressed = focusOnNextItem;
            _middleNameNativeItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityMiddleNameNativeKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [nameItems addObject:_middleNameNativeItem];
            
            _lastNameNativeItem = [[TGUsernameCollectionItem alloc] init];
            _lastNameNativeItem.placeholder = TGLocalized(@"Passport.Identity.SurnamePlaceholder");
            _lastNameNativeItem.title = TGLocalized(@"Passport.Identity.Surname");
            _lastNameNativeItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
            _lastNameNativeItem.keyboardType = UIKeyboardTypeDefault;
            _lastNameNativeItem.minimalInset = minimalInset;
            _lastNameNativeItem.usernameValid = true;
            _lastNameNativeItem.returnKeyType = UIReturnKeyNext;
            _lastNameNativeItem.returnPressed = focusOnNextItem;
            _lastNameNativeItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    NSString *key = TGPassportIdentityLastNameNativeKey;
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
                    if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:key])
                    {
                        [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:key];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            [nameItems addObject:_lastNameNativeItem];
            
            if (TGLocalized(@"Passport.Identity.NativeNameHelp").length > 0)
            {
                _nativeCommentItem = [[TGCommentCollectionItem alloc] initWithText:@""];
                [nameItems addObject:_nativeCommentItem];
            }
            
            _nativeNameSection = [[TGCollectionMenuSection alloc] initWithItems:nameItems];
            
            _birthDateItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.DateOfBirth") variant:nil action:@selector(birthDatePressed)];
            _birthDateItem.minLeftPadding = minimalInset + 20.0f;
            _birthDateItem.variant = TGLocalized(@"Passport.Identity.DateOfBirthPlaceholder");
            _birthDateItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            _birthDateItem.deselectAutomatically = true;
            [items addObject:_birthDateItem];
            
            _genderItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.Gender") variant:nil action:@selector(genderPressed)];
            _genderItem.minLeftPadding = minimalInset + 20.0f;
            _genderItem.variant = TGLocalized(@"Passport.Identity.GenderPlaceholder");
            _genderItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            _genderItem.deselectAutomatically = true;
            [items addObject:_genderItem];
            
            _countryItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.Country") variant:nil action:@selector(countryPressed)];
            _countryItem.minLeftPadding = minimalInset + 20.0f;
            _countryItem.variant = TGLocalized(@"Passport.Identity.CountryPlaceholder");
            _countryItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            [items addObject:_countryItem];
            
            _residenceCountryItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.ResidenceCountry") variant:nil action:@selector(residenceCountryPressed)];
            _residenceCountryItem.minLeftPadding = minimalInset + 20.0f;
            _residenceCountryItem.variant = TGLocalized(@"Passport.Identity.ResidenceCountryPlaceholder");
            _residenceCountryItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            [items addObject:_residenceCountryItem];
        }
        
        if (!inhibitFiles)
        {
            _documentNoItem = [[TGUsernameCollectionItem alloc] init];
            _documentNoItem.placeholder = TGLocalized(@"Passport.Identity.DocumentNumberPlaceholder");
            _documentNoItem.title = TGLocalized(@"Passport.Identity.DocumentNumber");
            _documentNoItem.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            _documentNoItem.keyboardType = UIKeyboardTypeASCIICapable;
            _documentNoItem.minimalInset = minimalInset;
            _documentNoItem.usernameValid = true;
            _documentNoItem.returnKeyType = UIReturnKeyNext;
            _documentNoItem.returnPressed = focusOnNextItem;
            _documentNoItem.usernameChanged = ^(__unused NSString *value)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf setChanged:true];
                    bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:strongSelf->_type];
                    if ([strongSelf.errors errorForType:strongSelf->_type dataField:TGPassportIdentityDocumentNumberKey])
                    {
                        [strongSelf.errors correctErrorForType:strongSelf->_type dataField:TGPassportIdentityDocumentNumberKey];
                        updateFieldErrors = true;
                    }
                    if (updateFieldErrors)
                        [strongSelf updateFieldErrors];
                    [strongSelf checkInputValues];
                }
            };
            _documentNoItem.shouldChangeText = ^bool(NSString *text)
            {
                NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-"];
                NSCharacterSet *invalidChars = [validChars invertedSet];
                return [text.uppercaseString rangeOfCharacterFromSet:invalidChars].location == NSNotFound;
            };
            [items addObject:_documentNoItem];
            
            _expiryItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.ExpiryDate") variant:nil action:@selector(expiryDatePressed)];
            _expiryItem.minLeftPadding = minimalInset + 20.0f;
            _expiryItem.variant = TGLocalized(@"Passport.Identity.ExpiryDatePlaceholder");
            _expiryItem.variantColor = self.presentation.pallete.collectionMenuPlaceholderColor;
            _expiryItem.deselectAutomatically = true;
            [items addObject:_expiryItem];
        }
        
        _mainSection = [[TGCollectionMenuSection alloc] initWithItems:items];

        TGCollectionMenuSection *topSection = _mainSection;
        UIEdgeInsets topSectionInsets = topSection.insets;
        topSectionInsets.top = 32.0f;
        topSection.insets = topSectionInsets;
        [self.menuSections insertSection:_mainSection atIndex:0];
    }
    return self;
}

- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly selfie:(bool)selfie translation:(bool)translation nativeNames:(bool)nativeNames editing:(bool)editing settings:(SVariable *)settings errors:(TGPassportErrors *)errors
{
    NSArray *translationFiles = document.translation ?: @[];
    self = [self initWithSettings:settings files:@{@(TGPassportDocumentFileTypeTranslation):translationFiles} documentOnly:documentOnly inhibitFiles:type == TGPassportTypePersonalDetails selfie:selfie translation:translation nativeNames:nativeNames editing:editing errors:errors existing:details != nil || document != nil];
    if (self != nil)
    {
        _type = document.type != TGPassportTypeUndefined ? document.type : (details.type != TGPassportTypeUndefined ? details.type : type);
        self.title = [TGPassportIdentityController documentDisplayNameForType:_type];
        
        _document = document;
        _frontSide = document.frontSide;
        _reverseSide = document.reverseSide;
        _selfie = document.selfie;
        [self setupWithDetails:details];
        
        TGPassportDocumentData *documentData = (TGPassportDocumentData *)document.data;
        _expiryDate = documentData.expiryDate;
        
        [self updateFieldErrors];
        
        _documentNoItem.username = documentData.documentNumber;
                
        if ([documentData.expiryDate isEqualToString:@""])
        {
            _expiryItem.variant = TGLocalized(@"Passport.Identity.ExpiryDateNone");
            _expiryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
        }
        else if (documentData.expiryDate.length > 0)
        {
            NSDate *date = [[TGPassportIdentityController dateFormatter] dateFromString:documentData.expiryDate];
            _expiryItem.variant = [TGPassportIdentityController localizedStringFromDate:date];
            _expiryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
        }
        
        if (type == TGPassportTypePersonalDetails)
        {
            TGCollectionMenuSection *scanSection = nil;
            if (details == nil)
            {
                _scanItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.ScanPassport") action:@selector(scanPressed)];
                _scanItem.iconOffset = CGPointMake(0.0f, -TGScreenPixel);
                _scanItem.leftInset = 50.0f;
                _scanItem.icon = self.presentation.images.passportScanIcon;
                
                scanSection = [[TGCollectionMenuSection alloc] initWithItems:@[_scanItem, [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.ScanPassportHelp")]]];
            }
            
            TGCollectionMenuSection *topSection = scanSection ?: _mainSection;
            
            UIEdgeInsets topSectionInsets = _mainSection.insets;
            topSectionInsets.top = 0.0f;
            _mainSection.insets = topSectionInsets;
            
            topSectionInsets = topSection.insets;
            topSectionInsets.top = 32.0f;
            topSection.insets = topSectionInsets;
    
            [self.menuSections insertSection:scanSection atIndex:0];
        }

        [self updateFiles];
        [self updateSides];
        [self checkInputValues];
        
        _deleteItem.title = [self deleteTitle];
    }
    return self;
}

- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details documentOnly:(bool)documentOnly selfie:(bool)selfie translation:(bool)translation nativeNames:(bool)nativeNames editing:(bool)editing upload:(TGPassportFileUpload *)upload settings:(SVariable *)settings errors:(TGPassportErrors *)errors
{
    self = [self initWithSettings:settings files:nil documentOnly:documentOnly inhibitFiles:type == TGPassportTypePersonalDetails selfie:selfie translation:translation nativeNames:nativeNames editing:editing errors:errors existing:false];
    if (self != nil)
    {
        self.title = [TGPassportIdentityController documentDisplayNameForType:type];
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        _type = type;
        
        [self setupWithDetails:details];
        [self updateFieldErrors];
        
        if (upload != nil)
            [self enqueueFrontSideUpload:upload];
        
        [self updateFiles];
        [self checkInputValues];
    }
    return self;
}

- (void)dealloc
{
    [_frontSideUploadDisposable dispose];
    [_reverseSideUploadDisposable dispose];
    [_selfieUploadDisposable dispose];
    [_ocrDisposable dispose];
    [_langDisposable dispose];
}

+ (NSString *)localizedStringFromDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (void)setLanguagesSignal:(SSignal *)languagesSignal
{
    if (_langDisposable == nil)
        _langDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGPassportIdentityController *weakSelf = self;
    [_langDisposable setDisposable:[[languagesSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGPassportLanguageMap *next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
            
            strongSelf->_languageMap = next;
            [strongSelf updateNativeNameSection:false];
    }]];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _scanItem.icon = presentation.images.passportScanIcon;
}

- (void)setScrollToSelfie
{
    _scrollToSelfie = true;
}

- (void)setScrollToTranslation
{
    _scrollToTranslation = true;
}

- (void)setScrollToNativeNames
{
    _scrollToNativeNames = true;
}

- (NSString *)deleteTitle
{
    if (_type == TGPassportTypePersonalDetails)
        return TGLocalized(@"Passport.DeletePersonalDetails");
    else
        return [super deleteTitle];
}

- (NSString *)deleteConfirmationText
{
    if (_type == TGPassportTypePersonalDetails)
        return TGLocalized(@"Passport.DeletePersonalDetailsConfirmation");
    else
        return [super deleteConfirmationText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_scrollToSelfie)
    {
        _scrollToSelfie = false;
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height)
            [self.collectionView setContentOffset:CGPointMake(0.0f, self.collectionView.contentSize.height - self.collectionView.frame.size.height) animated:true];
    } else if (_scrollToTranslation)
    {
        _scrollToTranslation = false;
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height)
            [self.collectionView setContentOffset:CGPointMake(0.0f, self.collectionView.contentSize.height - self.collectionView.frame.size.height) animated:true];
    } else if (_scrollToNativeNames)
    {
        _scrollToNativeNames = false;
        NSUInteger sectionIndex = [self.menuSections.sections indexOfObject:_nativeNameSection];
        if (sectionIndex == NSNotFound)
            return;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:true];
    }
}

- (void)setupWithDetails:(TGPassportDecryptedValue *)details
{
    _details = details;
    
    TGPassportPersonalDetailsData *personalData = (TGPassportPersonalDetailsData *)details.data;

    _firstNameNative = personalData.firstNameNative;
    _middleNameNative = personalData.middleNameNative;
    _lastNameNative = personalData.lastNameNative;
    
    _countryCode = personalData.countryCode;
    _residenceCountryCode = personalData.residenceCountryCode;
    _birthDate = personalData.birthDate;
    _gender = personalData.gender;
    
    _firstNameItem.username = personalData.firstName;
    _firstNameItem.shouldChangeText = self.checkLatinOnly;
    _firstNameItem.keyboardType = UIKeyboardTypeASCIICapable;
    
    _middleNameItem.username = personalData.middleName;
    _middleNameItem.shouldChangeText = self.checkLatinOnly;
    _middleNameItem.keyboardType = UIKeyboardTypeASCIICapable;
    
    _lastNameItem.username = personalData.lastName;
    _lastNameItem.shouldChangeText = self.checkLatinOnly;
    _lastNameItem.keyboardType = UIKeyboardTypeASCIICapable;
    
    _firstNameNativeItem.username = _firstNameNative;
    _middleNameNativeItem.username = _middleNameNative;
    _lastNameNativeItem.username = _lastNameNative;
    
    [self updateNativeNameSection:false];
    
    if (_details == nil)
        return;
    
    if (personalData.birthDate.length > 0)
    {
        NSDate *date = [[TGPassportIdentityController dateFormatter] dateFromString:personalData.birthDate];
        _birthDateItem.variant = [TGPassportIdentityController localizedStringFromDate:date];
        _birthDateItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    }
    
    if (personalData.gender != TGPassportGenderUndefined)
    {
        _genderItem.variant = personalData.gender == TGPassportGenderMale ? TGLocalized(@"Passport.Identity.GenderMale") : TGLocalized(@"Passport.Identity.GenderFemale");
        _genderItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    }
    
    if (personalData.countryCode.length > 0)
    {
        _countryItem.variant = [TGLoginCountriesController localizedCountryNameByCountryId:personalData.countryCode];
        _countryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    }
    
    if (personalData.residenceCountryCode.length > 0)
    {
        _residenceCountryItem.variant = [TGLoginCountriesController localizedCountryNameByCountryId:personalData.residenceCountryCode];
        _residenceCountryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    }
}

- (void)updateFieldErrors
{
    UIColor *normalColor = self.presentation.pallete.collectionMenuTextColor;
    UIColor *errorColor = self.presentation.pallete.collectionMenuDestructiveColor;
    
    _firstNameItem.titleColor = normalColor;
    _middleNameItem.titleColor = normalColor;
    _lastNameItem.titleColor = normalColor;
    _genderItem.titleColor = normalColor;
    _birthDateItem.titleColor = normalColor;
    _countryItem.titleColor = normalColor;
    _residenceCountryItem.titleColor = normalColor;
    _firstNameNativeItem.titleColor = normalColor;
    _middleNameNativeItem.titleColor = normalColor;
    _lastNameNativeItem.titleColor = normalColor;
    
    NSString *errorsString = @"";
    for (TGPassportError *error in [self.errors fieldErrorsForType:TGPassportTypePersonalDetails])
    {
        if ([error.key isEqualToString:TGPassportIdentityFirstNameKey])
            _firstNameItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityMiddleNameKey])
            _middleNameItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityLastNameKey])
            _lastNameItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityGenderKey])
            _genderItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityDateOfBirthKey])
            _birthDateItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityCountryCodeKey])
            _countryItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityResidenceCountryCodeKey])
            _residenceCountryItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityFirstNameNativeKey])
            _firstNameNativeItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityMiddleNameNativeKey])
            _middleNameNativeItem.titleColor = errorColor;
        else if ([error.key isEqualToString:TGPassportIdentityLastNameNativeKey])
            _lastNameNativeItem.titleColor = errorColor;
        
        if (error.text.length > 0)
        {
            if (errorsString.length == 0)
                errorsString = error.text;
            else
                errorsString = [errorsString stringByAppendingFormat:@"\n%@", error.text];
        }
    }
    
    if (_type != TGPassportTypePersonalDetails)
    {
        _documentNoItem.titleColor = normalColor;
        _expiryItem.titleColor = normalColor;
        
        for (TGPassportError *error in [self.errors fieldErrorsForType:_type])
        {
            if ([error.key isEqualToString:TGPassportIdentityDocumentNumberKey])
                _documentNoItem.titleColor = errorColor;
            else if ([error.key isEqualToString:TGPassportIdentityExpiryDateKey])
                _expiryItem.titleColor = errorColor;
            
            if (error.text.length > 0)
            {
                if (errorsString.length == 0)
                    errorsString = error.text;
                else
                    errorsString = [errorsString stringByAppendingFormat:@"\n%@", error.text];
            }
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

- (bool)correctMainErrorIfNeeded:(TGPassportType)type
{
    bool updateFieldErrors = false;
    if ([self.errors errorForTypeMain:type])
    {
        [self.errors correctMainErrorForType:type];
        updateFieldErrors = true;
    }
    return updateFieldErrors;
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (NSString *)transliterateName:(NSString *)name
{
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"абвгдеёжзийклмнопрстуфхцчшщъыьэюя"];
    bool isCyrillic = [[name lowercaseString] rangeOfCharacterFromSet:set].location != NSNotFound;
    
    if (isCyrillic)
        return [[TGPassportMRZ transliterateRussianName:[name uppercaseString]] capitalizedString];
    
    NSMutableString *buffer = [name mutableCopy];
    CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)buffer;
    CFStringTransform(bufferRef, NULL, kCFStringTransformToLatin, false);
    CFStringTransform(bufferRef, NULL, kCFStringTransformStripDiacritics, false);
    return buffer;
}

- (void)donePressed
{
    if (_saveDisposable == nil)
        _saveDisposable = [[SMetaDisposable alloc] init];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.45];
    
    __weak TGPassportIdentityController *weakSelf = self;
    [_saveDisposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return [SSignal complete];
        
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        
        bool hasData = !strongSelf->_documentOnly;
        bool hasDocument = strongSelf->_type != TGPassportTypePersonalDetails;
        
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        TGPassportDecryptedValue *detailsValue = nil;
        if (hasData)
        {
            NSString *firstName = strongSelf->_firstNameItem.username;
            NSString *middleName = strongSelf->_middleNameItem.username;
            NSString *lastName = strongSelf->_lastNameItem.username;
            
            NSString *firstNameNative = strongSelf->_firstNameNativeItem.username ?: _firstNameNative;
            NSString *middleNameNative = strongSelf->_middleNameNativeItem.username ? : _middleNameNative;
            NSString *lastNameNative = strongSelf->_lastNameNativeItem.username ?: _lastNameNative;
            
            if (_nativeNames && ![strongSelf requiresNativeNameForCountry:strongSelf->_residenceCountryCode])
            {
                if (firstNameNative.length == 0)
                    firstNameNative = firstName;
                if (middleNameNative.length == 0)
                    middleNameNative = middleName;
                if (lastNameNative.length == 0)
                    lastNameNative = lastName;
            }
            
            NSDictionary *unknownFields = @{};
            TGPassportDecryptedValue *previousDetails = strongSelf->_details;
            if (previousDetails != nil)
            {
                TGPassportPersonalDetailsData *previousData = (TGPassportPersonalDetailsData *)previousDetails.data;
                if ([previousData isKindOfClass:[TGPassportPersonalDetailsData class]])
                    unknownFields = previousData.unknownFields;
            }
            
            TGPassportPersonalDetailsData *detailsData = [[TGPassportPersonalDetailsData alloc] initWithFirstName:[firstName stringByTrimmingCharactersInSet:whitespaceSet] middleName:[middleName stringByTrimmingCharactersInSet:whitespaceSet] lastName:[lastName stringByTrimmingCharactersInSet:whitespaceSet] firstNameNative:[firstNameNative stringByTrimmingCharactersInSet:whitespaceSet] middleNameNative:[middleNameNative stringByTrimmingCharactersInSet:whitespaceSet] lastNameNative:[lastNameNative stringByTrimmingCharactersInSet:whitespaceSet] birthDate:strongSelf->_birthDate gender:strongSelf->_gender countryCode:strongSelf->_countryCode residenceCountryCode:strongSelf->_residenceCountryCode unknownFields:unknownFields secret:request.settings.secret];
            
            detailsValue = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypePersonalDetails data:detailsData frontSide:nil reverseSide:nil selfie:nil translation:nil files:nil plainData:nil];
            [signals addObject:[TGPassportSignals saveSecureValue:detailsValue secret:request.settings.secret]];
        }
        
        TGPassportDecryptedValue *documentValue = nil;
        if (hasDocument)
        {
            NSDictionary *unknownFields = @{};
            TGPassportDecryptedValue *previousDocument = strongSelf->_document;
            if (previousDocument != nil)
            {
                TGPassportDocumentData *previousData = (TGPassportDocumentData *)previousDocument.data;
                if ([previousData isKindOfClass:[TGPassportDocumentData class]])
                    unknownFields = previousData.unknownFields;
            }
            
            TGPassportDocumentData *documentData = [[TGPassportDocumentData alloc] initWithDocumentNumber:[strongSelf->_documentNoItem.username stringByTrimmingCharactersInSet:whitespaceSet] expiryDate:strongSelf->_expiryDate unknownFields:unknownFields secret:request.settings.secret];
            documentValue = [[TGPassportDecryptedValue alloc] initWithType:strongSelf->_type data:documentData frontSide:strongSelf->_frontSide reverseSide:strongSelf->_reverseSide selfie:strongSelf->_selfie translation:strongSelf.files[@(TGPassportDocumentFileTypeTranslation)] files:nil plainData:nil];
            [signals addObject:[TGPassportSignals saveSecureValue:documentValue secret:request.settings.secret]];
        }
        
        return [[SSignal combineSignals:signals] map:^id(NSArray *next)
        {
            TLSecureValue *updatedDetailsValue = next.count > 0 && hasData ? next.firstObject : nil;
            TLSecureValue *updatedDocumentValue = (!hasData && next.count > 0) ? next.firstObject : ((hasData && next.count > 1) ? next.lastObject : nil);
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            TGPassportDecryptedValue *finalDetailsValue = [detailsValue updateWithValueHash:updatedDetailsValue.n_hash];
            if (finalDetailsValue != nil)
                result[@"details"] = finalDetailsValue;
            
            TGPassportDecryptedValue *finalDocumentValue = [documentValue updateWithValueHash:updatedDocumentValue.n_hash];
            if (finalDocumentValue != nil)
                result[@"document"] = finalDocumentValue;
            
            return result;
        }];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [progressWindow dismiss:true];
        
        TGPassportDecryptedValue *detailsValue = next[@"details"];
        TGPassportDecryptedValue *documentValue = next[@"document"];
        
        if (strongSelf.completionBlock != nil)
            strongSelf.completionBlock(detailsValue, documentValue, strongSelf.errors);
        
        strongSelf->_changed = false;
        [strongSelf.navigationController popViewControllerAnimated:true];
    } error:^(id error)
    {
        [progressWindow dismiss:true];
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"APP_VERSION_OUTDATED"])
        {
            [strongSelf presentUpdateAppAlert];
            return;
        }
        else if ([errorText isEqualToString:@"PASSWORD_REQUIRED"])
        {
            [strongSelf.navigationController.presentingViewController dismissViewControllerAnimated:true completion:nil];
        }
        
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        [TGCustomAlertView presentAlertWithTitle:displayText message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:nil]];
}

- (void)uploadScanPressed:(TGPassportFileCollectionItem *)item menuController:(TGMenuSheetController *)menuController
{
    [self.view endEditing:true];
    
    bool identity = _type == TGPassportTypeDriversLicense || _type == TGPassportTypeIdentityCard;
    bool selfie = item == _selfieItem;
    
    TGPassportAttachIntent intent = selfie ? TGPassportAttachIntentSelfie : (identity ? TGPassportAttachIntentIdentityCard : TGPassportAttachIntentDefault);
    
    __weak TGPassportIdentityController *weakSelf = self;
    [TGPassportAttachMenu presentWithContext:[TGLegacyComponentsContext shared] parentController:self menuController:menuController title:nil intent:intent uploadAction:^(SSignal *resultSignal, void (^dismissPicker)(void))
    {
        dismissPicker();
        
        [[[resultSignal mapToSignal:^SSignal *(id value)
        {
            if ([value isKindOfClass:[NSDictionary class]])
            {
                return [SSignal single:value];
            }
            else if ([value isKindOfClass:[NSURL class]])
            {
                return [[TGPassportICloud fetchICloudFileWith:value] map:^id(NSURL *url)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:url.path];
                    
                    CGFloat maxSide = 2048.0f;
                    CGSize imageSize = TGFitSize(image.size, CGSizeMake(maxSide, maxSide));
                    UIImage *scaledImage = MAX(image.size.width, image.size.height) > maxSide ? TGScaleImageToPixelSize(image, imageSize) : image;
                    
                    CGFloat thumbnailSide = 60.0f * TGScreenScaling();
                    CGSize thumbnailSize = TGFitSize(scaledImage.size, CGSizeMake(thumbnailSide, thumbnailSide));
                    UIImage *thumbnailImage = TGScaleImageToPixelSize(scaledImage, thumbnailSize);
                    
                    return @{@"image": image, @"thumbnail": thumbnailImage };
                }];
            }
            return [SSignal complete];
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
        {
            TGPassportFileUpload *upload = [[TGPassportFileUpload alloc] initWithImage:next[@"image"] thumbnailImage:next[@"thumbnail"] date:(int32_t)[[NSDate date] timeIntervalSince1970]];
            
            if (item == _frontItem)
                [self enqueueFrontSideUpload:upload];
            else if (item == _reverseItem)
                [self enqueueReverseSideUpload:upload];
            else if (item == _selfieItem)
                [self enqueueSelfieUpload:upload];
        }];
    } sourceView:self.view sourceRect:^CGRect{
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [item.view convertRect:item.view.bounds toView:strongSelf.view];
        return CGRectZero;
    } barButtonItem:nil];
}

+ (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    });
    return dateFormatter;
}

- (void)birthDatePressed
{
    [self presentBirthDatePicker:false];
}

- (void)presentBirthDatePicker:(bool)fromNext
{
    [self.view endEditing:true];
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:now];
    [comps setYear:[comps year] - 18];
    NSDate *maxDate = [gregorian dateFromComponents:comps];
    
    NSDate *currentValue = nil;
    if (_birthDate.length > 0)
        currentValue = [[TGPassportIdentityController dateFormatter] dateFromString:_birthDate];
    
    __weak TGPassportIdentityController *weakSelf = self;
    [TGPassportBirthDateMenu presentInParentController:self context:[TGLegacyComponentsContext shared] title:TGLocalized(@"Passport.Identity.DateOfBirth") value:currentValue minValue:nil maxValue:maxDate optional:false completed:^(NSDate *value)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_birthDate = [[TGPassportIdentityController dateFormatter] stringFromDate:value];
        NSString *string = [TGPassportIdentityController localizedStringFromDate:value];
        strongSelf->_birthDateItem.variant = string;
        strongSelf->_birthDateItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
        
        if (fromNext && strongSelf->_gender == TGPassportGenderUndefined)
        {
            TGDispatchAfter(0.4, dispatch_get_main_queue(), ^
            {
                [strongSelf presentGenderPicker:true];
            });
        }
        
        [strongSelf setChanged:true];
        bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
        if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityDateOfBirthKey])
        {
            [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityDateOfBirthKey];
            updateFieldErrors = true;
        }
        if (updateFieldErrors)
            [strongSelf updateFieldErrors];
        [strongSelf checkInputValues];
    } dismissed:nil sourceView:self.view sourceRect:nil];
}

- (void)expiryDatePressed
{
    [self.view endEditing:true];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:6];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *minDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    NSDate *currentValue = nil;
    if (_expiryDate.length > 0)
        currentValue = [[TGPassportIdentityController dateFormatter] dateFromString:_expiryDate];
    
    __weak TGPassportIdentityController *weakSelf = self;
    [TGPassportBirthDateMenu presentInParentController:self context:[TGLegacyComponentsContext shared] title:TGLocalized(@"Passport.Identity.ExpiryDate") value:currentValue minValue:minDate maxValue:nil optional:true completed:^(NSDate *value)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSString *string = value ? [TGPassportIdentityController localizedStringFromDate:value] : TGLocalized(@"Passport.Identity.ExpiryDateNone");
        strongSelf->_expiryItem.variant = string;
        strongSelf->_expiryItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
        
        if (value == nil)
        {
            strongSelf->_expiryDate = @"";
        }
        else
        {
            strongSelf->_expiryDate = [[TGPassportIdentityController dateFormatter] stringFromDate:value];
        }
        
        [strongSelf setChanged:true];
        bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
        if ([strongSelf.errors errorForType:strongSelf->_type dataField:TGPassportIdentityExpiryDateKey])
        {
            [strongSelf.errors correctErrorForType:strongSelf->_type dataField:TGPassportIdentityExpiryDateKey];
            updateFieldErrors = true;
        }
        if (updateFieldErrors)
            [strongSelf updateFieldErrors];
        [strongSelf checkInputValues];
    } dismissed:nil sourceView:self.view sourceRect:nil];
}

- (void)genderPressed
{
    [self presentGenderPicker:false];
}

- (void)presentGenderPicker:(bool)fromNext
{
    [self.view endEditing:true];
    
    __weak TGPassportIdentityController *weakSelf = self;
    [TGPassportGenderMenu presentInParentController:self context:[TGLegacyComponentsContext shared] value:nil completed:^(NSNumber *value)
     {
         __strong TGPassportIdentityController *strongSelf = weakSelf;
         if (strongSelf == nil)
             return;
         
         if (value.integerValue == 1)
         {
             [strongSelf setChanged:true];
             strongSelf->_gender = TGPassportGenderMale;
             strongSelf->_genderItem.variant = TGLocalized(@"Passport.Identity.GenderMale");
             strongSelf->_genderItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
         }
         else if (value.integerValue == 2)
         {
             [strongSelf setChanged:true];
             strongSelf->_gender = TGPassportGenderFemale;
             strongSelf->_genderItem.variant = TGLocalized(@"Passport.Identity.GenderFemale");
             strongSelf->_genderItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
         }
         else
         {
             strongSelf->_gender = TGPassportGenderUndefined;
             strongSelf->_genderItem.variant = TGLocalized(@"Passport.Identity.GenderPlaceholder");
             strongSelf->_genderItem.variantColor = strongSelf.presentation.pallete.collectionMenuPlaceholderColor;
         }
         
         if (value.integerValue != 0 && fromNext && strongSelf->_countryCode.length == 0)
         {
            TGDispatchAfter(0.4, dispatch_get_main_queue(), ^
            {
                [strongSelf presentCountryPicker:true];
            });
         }
         
         bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
         if (value.integerValue != 0 && [strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityGenderKey])
         {
             [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityGenderKey];
             updateFieldErrors = true;
         }
         if (updateFieldErrors)
             [strongSelf updateFieldErrors];
         [strongSelf checkInputValues];
     } dismissed:nil sourceView:self.view sourceRect:nil];
}

- (void)countryPressed
{
    [self presentCountryPicker:false];
}

- (void)residenceCountryPressed
{
    [self presentResidenceCountryPicker:false];
}

- (void)presentCountryPicker:(bool)fromNext
{
    [self.view endEditing:true];
    
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] initWithCodes:false];
    countriesController.presentation = self.presentation;
    __weak TGPassportIdentityController *weakSelf = self;
    countriesController.countrySelected = ^(__unused int code, NSString *name, NSString *countryId)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_countryCode = countryId;
        
        strongSelf->_countryItem.variant = name;
        strongSelf->_countryItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
        
        if (fromNext && strongSelf->_residenceCountryCode.length == 0)
        {
            TGDispatchAfter(0.4, dispatch_get_main_queue(), ^
            {
                [strongSelf presentResidenceCountryPicker:true];
            });
        }
        
        [strongSelf setChanged:true];
        bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
        if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityCountryCodeKey])
        {
            [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityCountryCodeKey];
            updateFieldErrors = true;
        }
        if (updateFieldErrors)
            [strongSelf updateFieldErrors];
        [strongSelf checkInputValues];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)presentResidenceCountryPicker:(bool)fromNext
{
    [self.view endEditing:true];
    
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] initWithCodes:false];
    countriesController.presentation = self.presentation;
    __weak TGPassportIdentityController *weakSelf = self;
    countriesController.countrySelected = ^(__unused int code, NSString *name, NSString *countryId)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_residenceCountryCode = countryId;
        
        strongSelf->_residenceCountryItem.variant = name;
        strongSelf->_residenceCountryItem.variantColor = strongSelf.presentation.pallete.collectionMenuTextColor;
        
        if (fromNext && strongSelf->_documentNoItem != nil && strongSelf->_documentNoItem.username.length == 0)
        {
            TGDispatchAfter(0.4, dispatch_get_main_queue(), ^
            {
                [strongSelf focusOnItem:strongSelf->_documentNoItem];
            });
        }
        
        [strongSelf setChanged:true];
        bool updateFieldErrors = [strongSelf correctMainErrorIfNeeded:TGPassportTypePersonalDetails];
        if ([strongSelf.errors errorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityResidenceCountryCodeKey])
        {
            [strongSelf.errors correctErrorForType:TGPassportTypePersonalDetails dataField:TGPassportIdentityResidenceCountryCodeKey];
            updateFieldErrors = true;
        }
        if (updateFieldErrors)
            [strongSelf updateFieldErrors];
        [strongSelf checkInputValues];
        
        [strongSelf updateNativeNameSection:true];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - Selfie

- (NSArray *)allFiles
{
    NSMutableArray *baseFiles = [[NSMutableArray alloc] init];
    if (_frontSideUpload != nil)
        [baseFiles addObject:_frontSideUpload];
    if (_frontSide != nil)
        [baseFiles addObject:_frontSide];
    if (_reverseSideUpload != nil)
        [baseFiles addObject:_reverseSideUpload];
    if (_reverseSide != nil)
        [baseFiles addObject:_reverseSide];
    if (_selfieUpload != nil)
        [baseFiles addObject:_selfieUpload];
    else if (_selfie != nil)
        [baseFiles addObject:_selfie];
    [baseFiles addObjectsFromArray:[super allFiles]];
    return baseFiles;
}

- (CGSize)thumbnailSizeForFile:(id)file
{
    if ([file isEqual:_frontSide] || [file isEqual:_frontSideUpload])
        return _frontItem.imageSize;
    if ([file isEqual:_reverseSide] || [file isEqual:_reverseSideUpload])
        return _reverseItem.imageSize;
    if ([file isEqual:_selfie] || [file isEqual:_selfieUpload])
        return _selfieItem.imageSize;
    return [super thumbnailSizeForFile:file];
}

- (void)updateHiddenFile:(TGPassportFile *)hiddenFile
{
    [super updateHiddenFile:hiddenFile];
    
    _frontItem.imageViewHidden = [_frontItem.file isEqual:hiddenFile];
    _reverseItem.imageViewHidden = [_reverseItem.file isEqual:hiddenFile];
    _selfieItem.imageViewHidden = [_selfieItem.file isEqual:hiddenFile];
}

- (TGPassportFileCollectionItem *)itemForFile:(TGPassportFile *)passportFile
{
    if ([passportFile isEqual:_frontItem.file])
        return _frontItem;
    if ([passportFile isEqual:_reverseItem.file])
        return _reverseItem;
    if ([passportFile isEqual:_selfieItem.file])
        return _selfieItem;
    return [super itemForFile:passportFile];
}

- (void)viewFileItem:(TGPassportFileCollectionItem *)fileItem
{
    if (fileItem.file != nil)
    {
        [self.view endEditing:true];
        
        __weak TGPassportIdentityController *weakSelf = self;
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.sourceRect = ^CGRect
        {
            __strong TGPassportIdentityController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [fileItem.view convertRect:fileItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        };
        
        __weak TGMenuSheetController *weakController = controller;
        TGMenuSheetButtonItemView *viewItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.FilesView") type:TGMenuSheetButtonTypeDefault action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
            
            __strong TGPassportIdentityController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf viewFile:fileItem.file];
        }];
        
        TGMenuSheetButtonItemView *uploadItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.FilesUploadNew") type:TGMenuSheetButtonTypeDefault action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            __strong TGPassportIdentityController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf uploadScanPressed:fileItem menuController:strongController];
        }];
        
        TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Delete") type:TGMenuSheetButtonTypeDestructive action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
            
            __strong TGPassportDocumentController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf deleteFile:fileItem.file];
        }];
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        }];
        
        [controller setItemViews:@[ viewItem, uploadItem, deleteItem, cancelItem ]];
        
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
    else
    {
        [self uploadScanPressed:fileItem menuController:nil];
    }
}

- (void)deleteFile:(TGPassportFile *)file
{
    bool updated = false;
    if ([file isEqual:_frontSide] || [file isEqual:_frontSideUpload])
    {
        _frontSide = nil;
        _frontSideUpload = nil;
        _frontSideProgress = nil;
        
        [self.errors correctFrontSideErrorForType:self.type];
        
        [self updateSides];
        [self updateFieldErrors];
        [self checkInputValues];
        updated = true;
    }
    else if ([file isEqual:_reverseSide] || [file isEqual:_reverseSideUpload])
    {
        _reverseSide = nil;
        _reverseSideUpload = nil;
        _reverseSideProgress = nil;
        
        [self.errors correctReverseSideErrorForType:self.type];
        
        [self updateSides];
        [self updateFieldErrors];
        [self checkInputValues];
        updated = true;
    }
    else if ([file isEqual:_selfie] || [file isEqual:_selfieUpload])
    {
        _selfie = nil;
        _selfieUpload = nil;
        _selfieProgress = nil;
        
        [self.errors correctSelfieErrorForType:self.type];
        
        [self updateSides];
        [self updateFieldErrors];
        [self checkInputValues];
        updated = true;
    }
    
    [super deleteFile:file];
    
    if (!updated)
        [self updateFieldErrors];
}

- (void)scanMRZIfNeeded:(TGPassportFileUpload *)fileUpload
{
    if (![self shouldScanDocument])
        return;
    
    bool driversLicense = _type == TGPassportTypeDriversLicense;
    
    __weak TGPassportIdentityController *weakSelf = self;
    _ocrDisposable = [[SMetaDisposable alloc] init];
    [_ocrDisposable setDisposable:[[[TGPassportOCR recognizeDataInImage:fileUpload.image shouldBeDriversLicense:driversLicense] deliverOn:[SQueue mainQueue]] startWithNext:^(TGPassportMRZ *next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf applyScannedMRZ:next ignoreDocument:false];
    }]];
}

- (void)enqueueFrontSideUpload:(TGPassportFileUpload *)fileUpload
{
    _frontSide = nil;
    [self.errors correctFrontSideErrorForType:self.type];
    
    _frontSideUpload = fileUpload;
    [self setChanged:true];
    
    _frontSideProgress = [[SVariable alloc] init];
    
    if (_frontSideUploadDisposable == nil)
        _frontSideUploadDisposable = [[SMetaDisposable alloc] init];
    
    NSData *data = UIImageJPEGRepresentation(fileUpload.image, 0.89);
    NSData *thumbnailData = UIImageJPEGRepresentation(fileUpload.thumbnailImage, 0.6);
    
    __weak TGPassportIdentityController *weakSelf = self;
    [_frontSideUploadDisposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        return [TGPassportSignals uploadSecureData:data thumbnailData:thumbnailData secret:request.settings.secret];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[NSNumber class]])
        {
            [strongSelf->_frontSideProgress set:[SSignal single:next]];
        }
        else if ([next isKindOfClass:[TGPassportFile class]])
        {
            TGPassportFile *file = (TGPassportFile *)next;
            strongSelf->_frontSide = file;
            strongSelf->_frontSideUpload = nil;
            strongSelf->_frontSideProgress = nil;
            
            [strongSelf updateSides];
            [strongSelf checkInputValues];
        }
    } completed:^
    {
    }]];
    
    [self scanMRZIfNeeded:fileUpload];
    [self updateSides];
    [self checkInputValues];
}

- (void)enqueueReverseSideUpload:(TGPassportFileUpload *)fileUpload
{
    _reverseSide = nil;
    [self.errors correctReverseSideErrorForType:self.type];
    
    _reverseSideUpload = fileUpload;
    [self setChanged:true];
    
    _reverseSideProgress = [[SVariable alloc] init];
    
    if (_reverseSideUploadDisposable == nil)
        _reverseSideUploadDisposable = [[SMetaDisposable alloc] init];
    
    NSData *data = UIImageJPEGRepresentation(fileUpload.image, 0.89);
    NSData *thumbnailData = UIImageJPEGRepresentation(fileUpload.thumbnailImage, 0.6);
    
    __weak TGPassportIdentityController *weakSelf = self;
    [_reverseSideUploadDisposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        return [TGPassportSignals uploadSecureData:data thumbnailData:thumbnailData secret:request.settings.secret];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[NSNumber class]])
        {
            [strongSelf->_reverseSideProgress set:[SSignal single:next]];
        }
        else if ([next isKindOfClass:[TGPassportFile class]])
        {
            TGPassportFile *file = (TGPassportFile *)next;
            strongSelf->_reverseSide = file;
            strongSelf->_reverseSideUpload = nil;
            strongSelf->_reverseSideProgress = nil;
            
            [strongSelf updateSides];
            [strongSelf checkInputValues];
        }
    } completed:nil]];
    
    [self scanMRZIfNeeded:fileUpload];
    [self updateSides];
    [self checkInputValues];
}

- (void)enqueueSelfieUpload:(TGPassportFileUpload *)fileUpload
{
    _selfie = nil;
    [self.errors correctSelfieErrorForType:self.type];
    
    _selfieUpload = fileUpload;
    [self setChanged:true];
    
    _selfieProgress = [[SVariable alloc] init];
    
    if (_selfieUploadDisposable == nil)
        _selfieUploadDisposable = [[SMetaDisposable alloc] init];
    
    NSData *data = UIImageJPEGRepresentation(fileUpload.image, 0.89);
    NSData *thumbnailData = UIImageJPEGRepresentation(fileUpload.thumbnailImage, 0.6);
    
    __weak TGPassportIdentityController *weakSelf = self;
    [_selfieUploadDisposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        return [TGPassportSignals uploadSecureData:data thumbnailData:thumbnailData secret:request.settings.secret];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[NSNumber class]])
        {
            [strongSelf->_selfieProgress set:[SSignal single:next]];
        }
        else if ([next isKindOfClass:[TGPassportFile class]])
        {
            TGPassportFile *file = (TGPassportFile *)next;
            strongSelf->_selfie = file;
            strongSelf->_selfieUpload = nil;
            
            [strongSelf updateSides];
            [strongSelf checkInputValues];
        }
    } completed:nil]];
    
    [self updateSides];
    [self checkInputValues];
}

- (void)updateNativeNameSection:(bool)animated
{
    animated = false;
    NSUInteger sectionIndex = [self.menuSections.sections indexOfObject:_nativeNameSection];
    NSUInteger mainSectionIndex = [self.menuSections.sections indexOfObject:_mainSection];
    if (mainSectionIndex == NSNotFound)
        return;
    
    bool sectionShouldBeVisible = [self requiresNativeName] || _forceNativeNamesVisible;
    
    bool changed = true;
    if (sectionIndex != NSNotFound)
    {
        if (!sectionShouldBeVisible) {
            changed = true;
            [self.menuSections deleteSection:sectionIndex];
        }
    }
    else
    {
        if (sectionShouldBeVisible)
        {
            changed = true;
            [self.menuSections insertSection:_nativeNameSection atIndex:mainSectionIndex + 1];
        }
    }
    
    if (sectionShouldBeVisible)
    {
        NSString *title = nil;
        NSString *help = nil;
        NSString *languageName = [self languageNameForCountry:_residenceCountryCode];
        if (languageName.length == 0)
        {
            NSString *countryName = [TGLoginCountriesController localizedCountryNameByCountryId:_residenceCountryCode];
            title = [NSString stringWithFormat:TGLocalized(@"Passport.Identity.NativeNameGenericTitle"), [countryName uppercaseString]];
            help = [NSString stringWithFormat:TGLocalized(@"Passport.Identity.NativeNameGenericHelp"), countryName];
        }
        else
        {
            title = [NSString stringWithFormat:TGLocalized(@"Passport.Identity.NativeNameTitle"), [languageName uppercaseString]];
            help = TGLocalized(@"Passport.Identity.NativeNameHelp");
        }
        _nativeTitleItem.text = title;
        _nativeCommentItem.text = help;
    }
    
    if (animated)
        [self.menuSections commitRecordedChanges:self.collectionView];
    else if (changed)
        [self.collectionView reloadData];
}

- (void)updateSides
{
    if (_sidesSection == nil)
        return;
    
    __weak TGPassportIdentityController *weakSelf = self;
    
    bool hasReverseSide = _type == TGPassportTypeIdentityCard || _type == TGPassportTypeDriversLicense;
    bool hasFrontSide = hasReverseSide || _type == TGPassportTypePassport || _type == TGPassportTypeInternalPassport;
    
    if (hasFrontSide)
    {
        TGPassportFileCollectionItem *item = _frontItem;
        if (item == nil)
        {
            NSString *title = hasReverseSide ? TGLocalized(@"Passport.Identity.FrontSide") : TGLocalized(@"Passport.Identity.MainPage");
            item = [[TGPassportFileCollectionItem alloc] initWithTitle:title action:nil removeRequested:nil];
            item.deselectAutomatically = true;
            switch (_type) {
                case TGPassportTypePassport:
                case TGPassportTypeInternalPassport:
                    item.icon = TGImageNamed(@"PassportPassport");
                    break;
                    
                case TGPassportTypeIdentityCard:
                    item.icon = TGImageNamed(@"PassportId");
                    break;
                    
                case TGPassportTypeDriversLicense:
                    item.icon = TGImageNamed(@"PassportDriver");
                    break;
                    
                default:
                    break;
            }
            
            item.action = ^(TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf viewFileItem:item];
            };
            
            _frontItem = item;
            [_sidesSection insertItem:item atIndex:_sidesSection.items.count - 1];
        }
        
        id file = _frontSide ?: _frontSideUpload;
        item.file = file;
        item.deselectAutomatically = true;
        
        if (_frontSide != nil)
        {
            item.progressSignal = [[TGTelegraphInstance.mediaBox resourceStatus:secureResource(file, false)] map:^id(MediaResourceStatus *status)
            {
                switch (status.status)
                {
                    case MediaResourceStatusLocal:
                        return nil;
                    case MediaResourceStatusRemote:
                        return @0.0;
                    case MediaResourceStatusFetching:
                        return @(status.progress);
                    default:
                        return nil;
                }
            }];
            [item setImageSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, file, true)];
            
            item.removeRequested = ^(TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf deleteFile:item.file];
            };
            
            TGPassportError *error = [self.errors errorForTypeFrontSide:self.type];
            if (error.text.length > 0)
            {
                item.subtitle = error.text;
                item.isRequired = true;
            }
            else
            {
                item.subtitle = [TGDateUtils stringForPreciseDate:_frontSide.date];
                item.isRequired = false;
            }
        }
        else if (_frontSideUpload != nil)
        {
            item.progressSignal = _frontSideProgress.signal;
            [item setImageSignal:secureUploadThumbnailTransform(_frontSideUpload.thumbnailImage)];
            
            item.removeRequested = ^(__unused TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_frontSideUpload = nil;
                    strongSelf->_frontSideProgress = nil;
                    [strongSelf->_frontSideUploadDisposable setDisposable:nil];
                    
                    [strongSelf updateSides];
                    [strongSelf checkInputValues];
                }
            };
            
            item.subtitle = [TGDateUtils stringForPreciseDate:_frontSideUpload.date];
            item.isRequired = false;
        }
        else
        {
            item.progressSignal = [SSignal single:nil];
            [item setImageSignal:nil];
            
            item.removeRequested = nil;
            item.subtitle = hasReverseSide ? TGLocalized(@"Passport.Identity.FrontSideHelp") : TGLocalized(@"Passport.Identity.MainPageHelp");
            
            [item resetAnimated:true];
            item.isRequired = false;
        }
        
        item.imageViewHidden = [file isEqual:_hiddenFile];
    }
    
    if (hasReverseSide)
    {
        TGPassportFileCollectionItem *item = _reverseItem;
        if (item == nil)
        {
            item = [[TGPassportFileCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.ReverseSide") action:nil removeRequested:nil];
            item.deselectAutomatically = true;
            item.icon = TGImageNamed(@"PassportReverse");
            
            item.action = ^(TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf viewFileItem:item];
            };
            
            _reverseItem = item;
            
            NSUInteger frontItemIndex = [_sidesSection indexOfItem:_frontItem];
            if (frontItemIndex != NSNotFound)
                [_sidesSection insertItem:item atIndex:frontItemIndex + 1];
            else
                [_sidesSection insertItem:item atIndex:_sidesSection.items.count - 1];
        }
        
        id file = _reverseSide ?: _reverseSideUpload;
        item.file = file;
        item.deselectAutomatically = true;
        
        if (_reverseSide != nil)
        {
            item.progressSignal = [[TGTelegraphInstance.mediaBox resourceStatus:secureResource(file, false)] map:^id(MediaResourceStatus *status)
            {
                switch (status.status)
                {
                    case MediaResourceStatusLocal:
                        return nil;
                    case MediaResourceStatusRemote:
                        return @0.0;
                    case MediaResourceStatusFetching:
                        return @(status.progress);
                    default:
                        return nil;
                }
            }];
            [item setImageSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, file, true)];
            
            item.removeRequested = ^(TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf deleteFile:item.file];
            };
            
            TGPassportError *error = [self.errors errorForTypeReverseSide:self.type];
            if (error.text.length > 0)
            {
                item.subtitle = error.text;
                item.isRequired = true;
            }
            else
            {
                item.subtitle = [TGDateUtils stringForPreciseDate:_reverseSide.date];
                item.isRequired = false;
            }
        }
        else if (_reverseSideUpload != nil)
        {
            item.progressSignal = _reverseSideProgress.signal;
            [item setImageSignal:secureUploadThumbnailTransform(_reverseSideUpload.thumbnailImage)];
            
            item.removeRequested = ^(__unused TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_reverseSideUpload = nil;
                    strongSelf->_reverseSideProgress = nil;
                    [strongSelf->_reverseSideUploadDisposable setDisposable:nil];
                    
                    [strongSelf updateSides];
                    [strongSelf checkInputValues];
                }
            };
            
            item.subtitle = [TGDateUtils stringForPreciseDate:_reverseSideUpload.date];
            item.isRequired = false;
        }
        else
        {
            item.progressSignal = [SSignal single:nil];
            [item setImageSignal:nil];
            
            item.removeRequested = nil;
            item.subtitle = TGLocalized(@"Passport.Identity.ReverseSideHelp");
            
            [item resetAnimated:true];
            item.isRequired = false;
        }
        
        item.imageViewHidden = [file isEqual:_hiddenFile];
    }
    
    if (_selfieRequired || _editing)
    {
        TGPassportFileCollectionItem *item = _selfieItem;
        if (item == nil)
        {
            item = [[TGPassportFileCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Identity.Selfie") action:nil removeRequested:nil];
            item.deselectAutomatically = true;
            item.icon = TGImageNamed(@"PassportSelfie");
            
            item.action = ^(TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf viewFileItem:item];
            };
            
            _selfieItem = item;
            [_sidesSection insertItem:item atIndex:_sidesSection.items.count - 1];
        }
        
        id file = _selfie ?: _selfieUpload;
        item.file = file;
        item.deselectAutomatically = true;
        
        if (_selfie != nil)
        {
            item.progressSignal = [[TGTelegraphInstance.mediaBox resourceStatus:secureResource(file, false)] map:^id(MediaResourceStatus *status)
            {
                 switch (status.status)
                 {
                     case MediaResourceStatusLocal:
                         return nil;
                     case MediaResourceStatusRemote:
                         return @0.0;
                     case MediaResourceStatusFetching:
                         return @(status.progress);
                     default:
                         return nil;
                 }
            }];
            [item setImageSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, file, true)];
            
            item.removeRequested = ^(__unused TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf deleteFile:item.file];
            };
            
            TGPassportError *error = [self.errors errorForTypeSelfie:self.type];
            if (error.text.length > 0)
            {
                item.subtitle = error.text;
                item.isRequired = true;
            }
            else
            {
                item.subtitle = [TGDateUtils stringForPreciseDate:_selfie.date];
                item.isRequired = false;
            }
        }
        else if (_selfieUpload != nil)
        {
            item.progressSignal = _selfieProgress.signal;
            [item setImageSignal:secureUploadThumbnailTransform(_selfieUpload.thumbnailImage)];
            
            item.removeRequested = ^(__unused TGPassportFileCollectionItem *item)
            {
                __strong TGPassportIdentityController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_selfieUpload = nil;
                    strongSelf->_selfieProgress = nil;
                    [strongSelf->_selfieUploadDisposable setDisposable:nil];
                
                    [strongSelf updateSides];
                    [strongSelf checkInputValues];
                }
            };
            
            item.subtitle = [TGDateUtils stringForPreciseDate:_selfieUpload.date];
            item.isRequired = false;
        }
        else
        {
            item.progressSignal = [SSignal single:nil];
            [item setImageSignal:nil];
            
            item.removeRequested = nil;
            item.subtitle = TGLocalized(@"Passport.Identity.SelfieHelp");
            
            [item resetAnimated:true];
            item.isRequired = false;
        }
        
        item.imageViewHidden = [file isEqual:_hiddenFile];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:nil];
    [self checkInputValues];
}

#pragma mark - View

- (NSString *)languageNameForCountry:(NSString *)country
{
    if (country.length == 0)
        return nil;
    
    NSString *lang = _languageMap.map[[country uppercaseString]];
    if (lang == nil)
        return nil;
    
    NSString *string = TGLocalized([NSString stringWithFormat:@"Passport.Language.%@", lang]);
    return string;
}

- (bool)requiresNativeNameForCountry:(NSString *)country
{
    if (country.length == 0)
        return false;
    
    NSString *lang = _languageMap.map[[country uppercaseString]];
    if ([lang isEqualToString:@"en"])
        return false;
    
    return true;
}

- (bool)requiresNativeName
{
    return (_nativeNames || _editing) && [self requiresNativeNameForCountry:_residenceCountryCode];
}

- (void)checkInputValues
{
    bool hasName = (_firstNameItem.username.length > 0 && _firstNameItem.username.length <= 255) && (_lastNameItem.username.length > 0 && _lastNameItem.username.length <= 255) && _middleNameItem.username.length <= 255;
    bool hasNativeNamefNeeded = ![self requiresNativeName] || ((_firstNameNativeItem.username.length > 0 && _firstNameNativeItem.username.length <= 255) && (_lastNameNativeItem.username.length > 0 && _lastNameNativeItem.username.length <= 255) && _middleNameNativeItem.username.length <= 255);
    
    bool hasCountry = _countryCode.length > 0;
    bool hasResidenceCountry = _residenceCountryCode.length > 0;
    bool hasBirthDate = _birthDate.length > 0;
    bool hasGender = _gender != TGPassportGenderUndefined;
    bool hasPersonalDetails = (hasName && hasNativeNamefNeeded && hasCountry && hasResidenceCountry && hasBirthDate && hasGender) || _documentOnly;
    
    bool hasDocumentNumber = _documentNoItem == nil || (_documentNoItem.username.length > 0 && _documentNoItem.username.length <= 24);
    bool hasAllSides = (_frontItem == nil || _frontSide != nil) && (_reverseItem == nil || _reverseSide != nil) && (_selfieItem == nil || _selfie != nil || _editing);
    bool hasTranslation = _fileSections[@(TGPassportDocumentFileTypeTranslation)] == nil || self.files[@(TGPassportDocumentFileTypeTranslation)].count > 0 || _editing;
    bool hasNoUploads = _frontSideUpload == nil && _reverseSideUpload == nil && _selfieUpload == nil && ![self hasActiveUploads];
    bool hasNoErrors = ([self.errors errorsForType:TGPassportTypePersonalDetails].count + [self.errors errorsForType:_type].count) == 0;
    
    self.navigationItem.rightBarButtonItem.enabled = hasPersonalDetails && hasDocumentNumber && hasAllSides && hasTranslation && hasNoUploads && hasNoErrors;
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
    if (currentItem == _firstNameItem)
        [self focusOnItem:_middleNameItem];
    else if (currentItem == _middleNameItem)
        [self focusOnItem:_lastNameItem];
    else if (currentItem == _lastNameItem)
        [self presentBirthDatePicker:true];
    else if (currentItem == _documentNoItem)
        [self expiryDatePressed];
    else if (currentItem == _firstNameNativeItem)
        [self focusOnItem:_middleNameNativeItem];
    else if (currentItem == _middleNameNativeItem)
        [self focusOnItem:_lastNameNativeItem];
}

+ (NSString *)documentDisplayNameForType:(TGPassportType)type
{
    switch (type)
    {
        case TGPassportTypePersonalDetails:
            return TGLocalized(@"Passport.Identity.TypePersonalDetails");
        
        case TGPassportTypePassport:
            return TGLocalized(@"Passport.Identity.TypePassport");
            
        case TGPassportTypeIdentityCard:
            return TGLocalized(@"Passport.Identity.TypeIdentityCard");
            
        case TGPassportTypeDriversLicense:
            return TGLocalized(@"Passport.Identity.TypeDriversLicense");
            
        case TGPassportTypeInternalPassport:
            return TGLocalized(@"Passport.Identity.TypeInternalPassport");
            
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
    return true;
}

- (bool)isTypeAccepted:(TGPassportType)type
{
    for (TGPassportRequiredType *requiredType in self.acceptedTypes)
    {
        if (requiredType.type == type)
            return true;
    }
    return false;
}

- (void)applyScannedMRZ:(TGPassportMRZ *)mrz ignoreDocument:(bool)ignoreDocument
{
    if (!ignoreDocument)
    {
        if ([mrz.documentType isEqualToString:@"P"] && _type != TGPassportTypePassport)
        {
            if (![self isTypeAccepted:TGPassportTypePassport])
                return;
            
            _type = TGPassportTypePassport;
            self.title = [TGPassportIdentityController documentDisplayNameForType:_type];
            [self updateSides];
        }
        else if ([mrz.documentType isEqualToString:@"I"] && _type != TGPassportTypeIdentityCard)
        {
            if (![self isTypeAccepted:TGPassportTypeIdentityCard])
                return;
            
            _type = TGPassportTypeIdentityCard;
            self.title = [TGPassportIdentityController documentDisplayNameForType:_type];
            [self updateSides];
        }
        else if ([mrz.documentType isEqualToString:@"DL"] && _type != TGPassportTypeDriversLicense)
        {
            if (![self isTypeAccepted:TGPassportTypeDriversLicense])
                return;
            
            _type = TGPassportTypeDriversLicense;
            self.title = [TGPassportIdentityController documentDisplayNameForType:_type];
            [self updateSides];
        }
    }
    
    [self setChanged:true];
    
    NSString *firstName = [mrz.firstName capitalizedString];
    NSString *firstNameNative = [mrz.nativeFirstName capitalizedString];
    NSString *lastName = [mrz.lastName capitalizedString];
    NSString *lastNameNative = [mrz.nativeLastName capitalizedString];
    NSString *middleName = [mrz.middleName capitalizedString];
    NSString *middleNameNative = [mrz.nativeMiddleName capitalizedString];
    
    if (_firstNameItem.username.length == 0)
        _firstNameItem.username = firstName;
    if (_firstNameNativeItem.username.length == 0)
    {
        _firstNameNativeItem.username = firstNameNative;
        _firstNameNative = firstNameNative;
    }
    
    if (_middleNameItem.username.length == 0)
        _middleNameItem.username = middleName;
    if (_middleNameNativeItem.username.length == 0)
    {
        _middleNameNativeItem.username = middleNameNative;
        _middleNameNative = middleNameNative;
    }
    
    if (_lastNameItem.username.length == 0)
        _lastNameItem.username = lastName;
    if (_lastNameNativeItem.username.length == 0)
    {
        _lastNameNativeItem.username = lastNameNative;
        _lastNameNative = lastNameNative;
    }
    
    if (_birthDate == nil && mrz.birthDate != nil)
    {
        _birthDate = [[TGPassportIdentityController dateFormatter] stringFromDate:mrz.birthDate];
        _birthDateItem.variant = [TGPassportIdentityController localizedStringFromDate:mrz.birthDate];
        _birthDateItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
    }
    
    if (_gender == TGPassportGenderUndefined)
    {
        if ([mrz.gender isEqualToString:@"M"])
        {
            _gender = TGPassportGenderMale;
            _genderItem.variant = TGLocalized(@"Passport.Identity.GenderMale");
            _genderItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
        }
        else if ([mrz.gender isEqualToString:@"F"])
        {
            _gender = TGPassportGenderFemale;
            _genderItem.variant = TGLocalized(@"Passport.Identity.GenderFemale");
            _genderItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
        }
    }
    
    if (_countryCode.length == 0)
    {
        if (mrz.nationality.length > 0)
        {
            NSString *countryCode = [TGLoginCountriesController countryCodeByMRZCode:mrz.nationality];
            if (countryCode != nil)
            {
                _countryCode = countryCode;
                _countryItem.variant = [TGLoginCountriesController localizedCountryNameByCountryId:_countryCode];
                _countryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
            }
        }
    }
    
    if (_residenceCountryCode.length == 0)
    {
        if (mrz.issuingCountry.length > 0)
        {
            NSString *countryCode = [TGLoginCountriesController countryCodeByMRZCode:mrz.issuingCountry];
            if (countryCode != nil)
            {
                _residenceCountryCode = countryCode;
                _residenceCountryItem.variant = [TGLoginCountriesController localizedCountryNameByCountryId:_residenceCountryCode];
                _residenceCountryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
            }
        }
    }
    
    if (!ignoreDocument)
    {
        if (_documentNoItem.username.length == 0)
            _documentNoItem.username = mrz.documentNumber;
        
        if (_expiryDate.length == 0)
        {
            if (mrz.expiryDate != nil)
            {
                _expiryDate = [[TGPassportIdentityController dateFormatter] stringFromDate:mrz.expiryDate];
                _expiryItem.variant = [TGPassportIdentityController localizedStringFromDate:mrz.expiryDate];
                _expiryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
            }
            else if ([mrz.documentSubtype isEqualToString:@"N"])
            {
                _expiryDate = @"";
                _expiryItem.variant = TGLocalized(@"Passport.Identity.ExpiryDateNone");
                _expiryItem.variantColor = self.presentation.pallete.collectionMenuTextColor;
            }
        }
    }
    
    TGCollectionItemView *topItem = _firstNameItem.boundView ?: _documentNoItem.boundView;
    CGRect topFrame = [topItem convertRect:topItem.bounds toView:self.collectionView];
    UIView *snapshotView = [self.collectionView resizableSnapshotViewFromRect:CGRectMake(0, topFrame.origin.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height - topFrame.origin.y) afterScreenUpdates:false withCapInsets:UIEdgeInsetsZero];
    
    snapshotView.frame = CGRectMake(0.0f, topFrame.origin.y, snapshotView.frame.size.width, snapshotView.frame.size.height);
    [self.collectionView addSubview:snapshotView];
    
    [UIView animateWithDuration:0.2 animations:^
    {
        snapshotView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
    
    [self checkInputValues];
    [self updateNativeNameSection:true];
}

- (void)scanPressed
{
    TGPassportScanController *controller = [[TGPassportScanController alloc] init];
    controller.presentation = self.presentation;
    
    __weak TGPassportIdentityController *weakSelf = self;
    controller.finishedWithMRZ = ^(TGPassportMRZ *mrz)
    {
        __strong TGPassportIdentityController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf applyScannedMRZ:mrz ignoreDocument:true];
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
    };
    [self.navigationController pushViewController:controller animated:true];
}

@end
