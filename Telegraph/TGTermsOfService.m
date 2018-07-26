#import "TGTermsOfService.h"

#import "TLhelp_TermsOfService$help_termsOfService.h"
#import "TGMessage+Telegraph.h"

@implementation TGTermsOfService

- (instancetype)initWithTL:(TLhelp_TermsOfService *)tl
{
    self = [super init];
    if (self != nil)
    {
        if ([tl isKindOfClass:[TLhelp_TermsOfService$help_termsOfService class]])
        {
            TLhelp_TermsOfService$help_termsOfService *terms = (TLhelp_TermsOfService$help_termsOfService *)tl;
            _text = terms.text;
            _entities = [TGMessage parseTelegraphEntities:terms.entities];
            _popup = terms.flags & (1 << 0);
            if (terms.flags & (1 << 1))
                _minimumAgeRequired = @(terms.min_age_confirm);
            
            _identifier = terms.n_id.data;
        }
        else
            return nil;
    }
    return self;
}

@end
