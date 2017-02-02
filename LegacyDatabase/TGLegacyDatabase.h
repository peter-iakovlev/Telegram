#import <Foundation/Foundation.h>

@class TGLegacyUser;

@interface TGLegacyDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (NSArray<TGLegacyUser *> *)contactUsersMatchingQuery:(NSString *)query;
- (NSArray<TGLegacyUser *> *)contactUsersMatchingPhone:(NSString *)phoneNumber;

@end
