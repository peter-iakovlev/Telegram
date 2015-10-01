#import "TGModernDataImageView.h"

@interface TGModernDataImageView ()
{
    NSString *_uri;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernDataImageView

- (void)willBecomeRecycled
{
    [self reset];
}

- (NSString *)viewStateIdentifier
{
    if (_viewStateIdentifier != nil)
    {
    }
    
    return [[NSString alloc] initWithFormat:@"TGModernDataImageView/%@", _uri];
}

- (void)reset
{
    _uri = nil;
    
    [super reset];
}

- (void)loadUri:(NSString *)uri withOptions:(NSDictionary *)options
{
    _uri = uri;
    
    [super loadUri:uri withOptions:options];
}

@end
