#import "TGPaymentForm.h"

@implementation TGInvoicePrice

- (instancetype)initWithLabel:(NSString *)label amount:(int64_t)amount {
    self = [super init];
    if (self != nil) {
        _label = label;
        _amount = amount;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGInvoicePrice class]] && TGStringCompare(_label, ((TGInvoicePrice *)object)->_label) && _amount == ((TGInvoicePrice *)object)->_amount;
}

@end

@implementation TGInvoice

- (instancetype)initWithIsTest:(bool)isTest nameRequested:(bool)nameRequested phoneRequested:(bool)phoneRequested emailRequested:(bool)emailRequested shippingAddressRequested:(bool)shippingAddressRequested flexible:(bool)flexible currency:(NSString *)currency prices:(NSArray<TGInvoicePrice *> *)prices {
    self = [super init];
    if (self != nil) {
        _isTest = isTest;
        _nameRequested = nameRequested;
        _phoneRequested = phoneRequested;
        _emailRequested = emailRequested;
        _shippingAddressRequested = shippingAddressRequested;
        _flexible = flexible;
        _currency = currency;
        _prices = prices;
    }
    return self;
}

- (bool)requiresShippingInfo {
    return _nameRequested || _phoneRequested || _emailRequested || _shippingAddressRequested;
}

@end

@implementation TGPostAddress

- (instancetype)initWithStreetLine1:(NSString *)streetLine1 streetLine2:(NSString *)streetLine2 city:(NSString *)city state:(NSString *)state countryIso2:(NSString *)countryIso2 postCode:(NSString *)postCode {
    self = [super init];
    if (self != nil) {
        _streetLine1 = streetLine1;
        _streetLine2 = streetLine2;
        _city = city;
        _state = state;
        _countryIso2 = countryIso2;
        _postCode = postCode;
    }
    return self;
}

- (NSString *)descriptionWithSeparator:(NSString *)separator {
    NSMutableString *string = [[NSMutableString alloc] init];
    if (_streetLine1.length != 0) {
        [string appendString:_streetLine1];
    }
    if (_streetLine2.length != 0) {
        if (string.length != 0) {
            [string appendString:separator];
        }
        [string appendString:_streetLine2];
    }
    if (_city.length != 0) {
        if (string.length != 0) {
            [string appendString:separator];
        }
        [string appendString:_city];
    }
    if (_state.length != 0) {
        if (string.length != 0) {
            [string appendString:separator];
        }
        [string appendString:_state];
    }
    if (_countryIso2.length != 0) {
        if (string.length != 0) {
            [string appendString:separator];
        }
        [string appendString:_countryIso2];
    }
    return string;
}

@end

@implementation TGPaymentRequestedInfo

- (instancetype)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email shippingAddress:(TGPostAddress *)shippingAddress {
    self = [super init];
    if (self != nil) {
        _name = name;
        _phone = phone;
        _email = email;
        _shippingAddress = shippingAddress;
    }
    return self;
}

- (bool)satisfiesInvoice:(TGInvoice *)invoice {
    if (invoice.shippingAddressRequested && _shippingAddress == nil) {
        return false;
    }
    if (invoice.nameRequested && [_name length] == 0) {
        return false;
    }
    if (invoice.phoneRequested && [_phone length] == 0) {
        return false;
    }
    if (invoice.emailRequested && [_email length] == 0) {
        return false;
    }
    return true;
}

@end

@implementation TGPaymentSavedCredentialsCard

- (instancetype)initWithCardId:(NSString *)cardId title:(NSString *)title {
    self = [super init];
    if (self != nil) {
        _cardId = cardId;
        _title = title;
    }
    return self;
}

@end

@implementation TGPaymentCredentialsStripeToken

- (instancetype)initWithTokenId:(NSString *)tokenId title:(NSString *)title saveCredentials:(bool)saveCredentials {
    self = [super init];
    if (self != nil) {
        _tokenId = tokenId;
        _title = title;
        _saveCredentials = saveCredentials;
    }
    return self;
}

@end

@implementation TGPaymentCredentialsWebToken

- (instancetype)initWithData:(NSString *)data saveCredentials:(bool)saveCredentials {
    self = [super init];
    if (self != nil) {
        _data = data;
        _saveCredentials = saveCredentials;
    }
    return self;
}

@end

@implementation TGPaymentCredentialsSaved

- (instancetype)initWithCardId:(NSString *)cardId tmpPassword:(NSData *)tmpPassword {
    self = [super init];
    if (self != nil) {
        _cardId = cardId;
        _tmpPassword = tmpPassword;
    }
    return self;
}

@end

@implementation TGPaymentForm

- (instancetype)initWithCanSaveCredentials:(bool)canSaveCredentials passwordMissing:(bool)passwordMissing botId:(int32_t)botId url:(NSString *)url invoice:(TGInvoice *)invoice providerId:(int32_t)providerId nativeProvider:(NSString *)nativeProvider nativeParams:(NSString *)nativeParams savedInfo:(TGPaymentRequestedInfo *)savedInfo savedCredentials:(TGPaymentSavedCredentialsCard *)savedCredentials {
    self = [super init];
    if (self != nil) {
        _canSaveCredentials = canSaveCredentials;
        _passwordMissing = passwordMissing;
        _botId = botId;
        _url = url;
        _invoice = invoice;
        _providerId = providerId;
        _nativeProvider = nativeProvider;
        _nativeParams = nativeParams;
        _savedInfo = savedInfo;
        _savedCredentials = savedCredentials;
    }
    return self;
}

@end

@implementation TGShippingOption

- (instancetype)initWithOptionId:(NSString *)optionId title:(NSString *)title prices:(NSArray<TGInvoicePrice *> *)prices {
    self = [super init];
    if (self != nil) {
        _optionId = optionId;
        _title = title;
        _prices = prices;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TGShippingOption class]] && _optionId == ((TGShippingOption *)object)->_optionId && TGStringCompare(_title, ((TGShippingOption *)object)->_title) && TGObjectCompare(_prices, ((TGShippingOption *)object)->_prices)) {
        return true;
    } else {
        return false;
    }
}

@end

@implementation TGValidatedRequestedInfo

- (instancetype)initWithInfoId:(NSString *)infoId shippingOptions:(NSArray<TGShippingOption *> *)shippingOptions {
    self = [super init];
    if (self != nil) {
        _infoId = infoId;
        _shippingOptions = shippingOptions;
    }
    return self;
}

@end

@implementation TGPaymentReceipt

- (instancetype)initWithDate:(int32_t)date botId:(int32_t)botId invoice:(TGInvoice *)invoice providerId:(int32_t)providerId info:(TGPaymentRequestedInfo *)info shippingOption:(TGShippingOption *)shippingOption currency:(NSString *)currency totalAmount:(int64_t)totalAmount credentialsTitle:(NSString *)credentialsTitle {
    self = [super init];
    if (self != nil) {
        _date = date;
        _botId = botId;
        _invoice = invoice;
        _providerId = providerId;
        _info = info;
        _shippingOption = shippingOption;
        _currency = currency;
        _totalAmount = totalAmount;
        _credentialsTitle = credentialsTitle;
    }
    return self;
}

@end
