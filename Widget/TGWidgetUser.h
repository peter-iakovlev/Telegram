#import <Foundation/Foundation.h>

@interface TGWidgetUser : NSObject <NSCoding>
{
    int32_t _identifier;
    NSString *_firstName;
    NSString *_lastName;
    NSString *_avatarPath;
}

@property (nonatomic, readonly) int32_t identifier;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *avatarPath;

- (NSString *)initials;

@end
