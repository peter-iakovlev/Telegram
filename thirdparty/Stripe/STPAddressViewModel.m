//
//  STPAddressViewModel.m
//  Stripe
//
//  Created by Jack Flintermann on 4/21/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPAddressViewModel.h"
#import "NSArray+Stripe_BoundSafe.h"
#import "STPPostalCodeValidator.h"

@interface STPAddressViewModel()<STPAddressFieldTableViewCellDelegate>

@property(nonatomic)STPBillingAddressFields requiredBillingAddressFields;
@property(nonatomic)NSArray<STPAddressFieldTableViewCell *> *addressCells;
@property(nonatomic)BOOL showingPostalCodeCell;
@end

@implementation STPAddressViewModel

@synthesize addressFieldTableViewCountryCode = _addressFieldTableViewCountryCode;

- (instancetype)initWithRequiredBillingFields:(STPBillingAddressFields)requiredBillingAddressFields {
    self = [super init];
    if (self) {
        _requiredBillingAddressFields = requiredBillingAddressFields;
        _addressFieldTableViewCountryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
        
        switch (requiredBillingAddressFields) {
            case STPBillingAddressFieldsNone:
                _addressCells = @[];
                break;
            case STPBillingAddressFieldsZip:
                _addressCells = @[
                                  // Postal code cell will be added later if necessary
                                  ];
                break;
            case STPBillingAddressFieldsFull:
                _addressCells = @[
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeName contents:@"" lastInList:NO delegate:self],
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeLine1 contents:@"" lastInList:NO delegate:self],
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeLine2 contents:@"" lastInList:NO delegate:self],
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeCity contents:@"" lastInList:NO delegate:self],
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeState contents:@"" lastInList:NO delegate:self],
                                  // Postal code cell will be added later if necessary
                                  [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeCountry contents:_addressFieldTableViewCountryCode lastInList:YES delegate:self],
                                  ];
                break;
        }
        
        [self updatePostalCodeCellIfNecessary];
    }
    return self;
}

- (void)updatePostalCodeCellIfNecessary {
    STPPostalCodeType postalCodeType = [STPPostalCodeValidator postalCodeTypeForCountryCode:_addressFieldTableViewCountryCode];
    BOOL shouldBeShowingPostalCode = (postalCodeType != STPCountryPostalCodeTypeNotRequired);
    if (shouldBeShowingPostalCode && !self.showingPostalCodeCell) {
        switch (self.requiredBillingAddressFields) {
            case STPBillingAddressFieldsNone:
                // Do nothing
                break;
            case STPBillingAddressFieldsZip:
                self.addressCells = @[
                                      [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeZip contents:@"" lastInList:YES delegate:self]
                                      ];
                [self.delegate addressViewModel:self addedCellAtIndex:0];
                [self.delegate addressViewModelDidChange:self];
                break;
            case STPBillingAddressFieldsFull: {
                // Add after STPAddressFieldTypeState
                NSUInteger stateFieldIndex = [self.addressCells indexOfObjectPassingTest:^BOOL(STPAddressFieldTableViewCell * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
                    return (obj.type == STPAddressFieldTypeState);
                }];
                
                if (stateFieldIndex != NSNotFound) {
                    NSUInteger zipFieldIndex = stateFieldIndex + 1;
                    
                    NSMutableArray<STPAddressFieldTableViewCell *> *mutableAddressCells = self.addressCells.mutableCopy;
                    [mutableAddressCells insertObject:[[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypeZip contents:@"" lastInList:NO delegate:self]
                                              atIndex:zipFieldIndex];
                    self.addressCells = mutableAddressCells.copy;
                    [self.delegate addressViewModel:self addedCellAtIndex:zipFieldIndex];
                    [self.delegate addressViewModelDidChange:self];
                }
                break;             
            }
        }

    }
    else if (!shouldBeShowingPostalCode && self.showingPostalCodeCell) {
        switch (self.requiredBillingAddressFields) {
            case STPBillingAddressFieldsNone:
                // Do nothing
                break;
            case STPBillingAddressFieldsZip:
                self.addressCells = @[];
                [self.delegate addressViewModel:self removedCellAtIndex:0];
                [self.delegate addressViewModelDidChange:self];
                break;
            case STPBillingAddressFieldsFull: {
                NSUInteger zipFieldIndex = [self.addressCells indexOfObjectPassingTest:^BOOL(STPAddressFieldTableViewCell * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
                    return (obj.type == STPAddressFieldTypeZip);
                }];
                
                if (zipFieldIndex != NSNotFound) {
                    NSMutableArray<STPAddressFieldTableViewCell *> *mutableAddressCells = self.addressCells.mutableCopy;
                    [mutableAddressCells removeObjectAtIndex:zipFieldIndex];
                    self.addressCells = mutableAddressCells.copy;
                    [self.delegate addressViewModel:self removedCellAtIndex:zipFieldIndex];
                    [self.delegate addressViewModelDidChange:self];
                }
                break;             
            }
        }
    }
    self.showingPostalCodeCell = shouldBeShowingPostalCode;
}

- (STPAddressFieldTableViewCell *)cellAtIndex:(NSInteger)index {
    return self.addressCells[index];
}

- (void)addressFieldTableViewCellDidReturn:(STPAddressFieldTableViewCell *)cell {
    [[self cellAfterCell:cell] becomeFirstResponder];
}

- (void)addressFieldTableViewCellDidBackspaceOnEmpty:(STPAddressFieldTableViewCell *)cell {
    if ([self.addressCells indexOfObject:cell] == 0) {
        [self.previousField becomeFirstResponder];
    } else {
        [[self cellBeforeCell:cell] becomeFirstResponder];
    }
}

- (void)addressFieldTableViewCellDidUpdateText:(__unused STPAddressFieldTableViewCell *)cell {
    [self.delegate addressViewModelDidChange:self];
}

- (BOOL)isValid {
    return [self.address containsRequiredFields:self.requiredBillingAddressFields];
}

- (void)setAddressFieldTableViewCountryCode:(NSString *)addressFieldTableViewCountryCode {
    if (addressFieldTableViewCountryCode.length > 0 // ignore if someone passing in nil or empty and keep our current setup
        && ![_addressFieldTableViewCountryCode isEqualToString:addressFieldTableViewCountryCode]) {
        _addressFieldTableViewCountryCode = addressFieldTableViewCountryCode.copy;
        [self updatePostalCodeCellIfNecessary];
        for (STPAddressFieldTableViewCell *cell in self.addressCells) {
            [cell delegateCountryCodeDidChange:_addressFieldTableViewCountryCode];
        }
    }
}

- (void)setAddress:(STPAddress *)address {
    self.addressFieldTableViewCountryCode = address.country;
    
    for (STPAddressFieldTableViewCell *cell in self.addressCells) {
        switch (cell.type) {
            case STPAddressFieldTypeName:
                cell.contents = address.name;
                break;
            case STPAddressFieldTypeLine1:
                cell.contents = address.line1;
                break;
            case STPAddressFieldTypeLine2:
                cell.contents = address.line2;
                break;
            case STPAddressFieldTypeCity:
                cell.contents = address.city;
                break;
            case STPAddressFieldTypeState:
                cell.contents = address.state;
                break;
            case STPAddressFieldTypeZip:
                cell.contents = address.postalCode;
                break;
            case STPAddressFieldTypeCountry:
                cell.contents = address.country;
                break;
            case STPAddressFieldTypeEmail:
                cell.contents = address.email;
                break;
            case STPAddressFieldTypePhone:
                cell.contents = address.phone;
                break;
        }
    }
}

- (STPAddress *)address {
    STPAddress *address = [STPAddress new];
    for (STPAddressFieldTableViewCell *cell in self.addressCells) {
        
        switch (cell.type) {
            case STPAddressFieldTypeName:
                address.name = cell.contents;
                break;
            case STPAddressFieldTypeLine1:
                address.line1 = cell.contents;
                break;
            case STPAddressFieldTypeLine2:
                address.line2 = cell.contents;
                break;
            case STPAddressFieldTypeCity:
                address.city = cell.contents;
                break;
            case STPAddressFieldTypeState:
                address.state = cell.contents;
                break;
            case STPAddressFieldTypeZip:
                address.postalCode = cell.contents;
                break;
            case STPAddressFieldTypeCountry:
                address.country = cell.contents;
                break;
            case STPAddressFieldTypeEmail:
                address.email = cell.contents;
                break;
            case STPAddressFieldTypePhone:
                address.phone = cell.contents;
                break;
        }
    }
    return address;
}

- (STPAddressFieldTableViewCell *)cellBeforeCell:(STPAddressFieldTableViewCell *)cell {
    NSInteger index = [self.addressCells indexOfObject:cell];
    return [self.addressCells stp_boundSafeObjectAtIndex:index - 1];
}

- (STPAddressFieldTableViewCell *)cellAfterCell:(STPAddressFieldTableViewCell *)cell {
    NSInteger index = [self.addressCells indexOfObject:cell];
    return [self.addressCells stp_boundSafeObjectAtIndex:index + 1];
}

@end
