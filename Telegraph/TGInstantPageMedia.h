#import <Foundation/Foundation.h>

@interface TGInstantPageMedia : NSObject

@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, strong, readonly) id media;

- (instancetype)initWithIndex:(NSInteger)index media:(id)media;

- (NSString *)caption;

@end
