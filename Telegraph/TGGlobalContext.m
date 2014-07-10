#import "TGGlobalContext.h"

#import "TGDatabaseContext.h"
#import "TGContactsContext.h"

@interface TGGlobalContext ()
{
    NSString *_name;
    NSString *_path;
    
    TGDatabaseContext *_databaseContext;
    TGContactsContext *_contactsContext;
}

@end

@implementation TGGlobalContext

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self != nil)
    {
        _name = name;
        _path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"contexts"] stringByAppendingPathComponent:_name];
        [[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:true attributes:nil error:nil];
        
        _databaseContext = [[TGDatabaseContext alloc] initWithGlobalContext:self];
        //TGDispatchAfter(10.0, dispatch_get_main_queue(), ^{
            _contactsContext = [[TGContactsContext alloc] init];
        //});
    }
    return self;
}

- (NSString *)path
{
    return _path;
}

- (TGDatabaseContext *)databaseContext
{
    return _databaseContext;
}

- (TGContactsContext *)contactsContext
{
    return _contactsContext;
}

@end
