#import <Foundation/Foundation.h>

@interface TGInstantPageMedia : NSObject

@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, strong, readonly) id media;
@property (nonatomic, readonly) int64_t groupedId;

- (instancetype)initWithIndex:(NSInteger)index media:(id)media groupedId:(int64_t)groupedId;

- (NSString *)caption;

@end
