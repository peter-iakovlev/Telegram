//
//  STPAddressViewModel.h
//  Stripe
//
//  Created by Jack Flintermann on 4/21/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPAddress.h"
#import "STPAddressFieldTableViewCell.h"

@class STPAddressViewModel;

@protocol STPAddressViewModelDelegate <NSObject>

- (void)addressViewModelDidChange:(STPAddressViewModel *)addressViewModel;
- (void)addressViewModel:(STPAddressViewModel *)addressViewModel addedCellAtIndex:(NSUInteger)index;
- (void)addressViewModel:(STPAddressViewModel *)addressViewModel removedCellAtIndex:(NSUInteger)index;

@end

@interface STPAddressViewModel : NSObject

@property(nonatomic, readonly) NSArray<STPAddressFieldTableViewCell *> *addressCells;
@property(nonatomic, weak) id<STPAddressViewModelDelegate>delegate;
@property(nonatomic) UIResponder *previousField;
@property(nonatomic)STPAddress *address;
@property(nonatomic, readonly)BOOL isValid;

- (instancetype)initWithRequiredBillingFields:(STPBillingAddressFields)requiredBillingAddressFields;
- (STPAddressFieldTableViewCell *)cellAtIndex:(NSInteger)index;

@end
