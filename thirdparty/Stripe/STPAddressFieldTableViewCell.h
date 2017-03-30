//
//  STPAddressFieldTableViewCell.h
//  Stripe
//
//  Created by Ben Guo on 4/13/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPTheme.h"
#import "STPFormTextField.h"
#import "STPPostalCodeValidator.h"

typedef NS_ENUM(NSInteger, STPAddressFieldType) {
    STPAddressFieldTypeName,
    STPAddressFieldTypeLine1,
    STPAddressFieldTypeLine2,
    STPAddressFieldTypeCity,
    STPAddressFieldTypeState,
    STPAddressFieldTypeZip,
    STPAddressFieldTypeCountry,
    STPAddressFieldTypeEmail,
    STPAddressFieldTypePhone,
};

@class STPFormTextField, STPAddressFieldTableViewCell;

@protocol STPAddressFieldTableViewCellDelegate <NSObject>

- (void)addressFieldTableViewCellDidUpdateText:(STPAddressFieldTableViewCell *)cell;
- (void)addressFieldTableViewCellDidBackspaceOnEmpty:(STPAddressFieldTableViewCell *)cell;

@optional
- (void)addressFieldTableViewCellDidReturn:(STPAddressFieldTableViewCell *)cell;
@property (nonatomic, copy) NSString *addressFieldTableViewCountryCode;

@end

@interface STPAddressFieldTableViewCell : UITableViewCell

- (instancetype)initWithType:(STPAddressFieldType)type
                    contents:(NSString *)contents
                  lastInList:(BOOL)lastInList
                    delegate:(id<STPAddressFieldTableViewCellDelegate>)delegate;

@property(nonatomic)STPAddressFieldType type;
@property(nonatomic, copy) NSString *caption;
@property(nonatomic, weak, readonly) STPFormTextField *textField;
@property(nonatomic, copy) NSString *contents;
@property(nonatomic)STPTheme *theme;

- (void)delegateCountryCodeDidChange:(NSString *)countryCode;

@end
