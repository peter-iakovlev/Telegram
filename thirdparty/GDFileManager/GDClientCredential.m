//
//  GDCredential.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDClientCredential.h"
#import "GDAPIToken.h"

@interface GDClientCredential ()

@property (nonatomic, copy, readonly) NSString *apiTokenKey;
@property (nonatomic, copy, readonly) NSString *apiTokenClassName;

@end

@implementation GDClientCredential

@synthesize apiToken = _apiToken;

- (id)initWithUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    if ((self = [super init])) {
        _userID = [userID copy];
        _apiToken = apiToken;
        _apiTokenKey = apiToken.key;
        _apiTokenClassName = NSStringFromClass([apiToken class]);
    }
    
    return self;
}

- (BOOL)isValid
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)canBeRenewed
{
    return NO;
}

- (NSComparisonResult)compare:(GDClientCredential *)otherCredential
{
    return [[self description] compare:[otherCredential description]];
}

- (GDAPIToken *)apiToken
{
    if (!_apiToken && _apiTokenKey) {
        Class apiTokenClass = NSClassFromString(self.apiTokenClassName);
        if ([apiTokenClass isSubclassOfClass:[GDAPIToken class]]) {
            _apiToken = [apiTokenClass tokenForKey:self.apiTokenKey];
        }
    }
    
    return _apiToken;
}

#pragma mark - NSCoding

static NSString *const kUserIDCoderKey = @"userID";
static NSString *const kAPITokenCoderKey = @"apiToken";
static NSString *const kAPITokenKeyCoderKey = @"apiTokenKey";
static NSString *const kAPITokenClassCoderKey = @"apiTokenClassKey";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        _userID = [aDecoder decodeObjectForKey:kUserIDCoderKey];
        _apiTokenKey = [aDecoder decodeObjectForKey:kAPITokenKeyCoderKey];
        _apiTokenClassName = [aDecoder decodeObjectForKey:kAPITokenClassCoderKey];
        
        if (!_apiTokenKey) {
            _apiToken = [aDecoder decodeObjectForKey:kAPITokenCoderKey];
            _apiTokenKey = _apiToken.key;
            _apiTokenClassName = NSStringFromClass([_apiToken class]);
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID forKey:kUserIDCoderKey];
    [aCoder encodeObject:self.apiTokenKey forKey:kAPITokenKeyCoderKey];
    [aCoder encodeObject:self.apiTokenClassName forKey:kAPITokenClassCoderKey];
}


@end
