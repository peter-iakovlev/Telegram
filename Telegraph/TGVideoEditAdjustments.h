#import "TGMediaEditingContext.h"

@interface TGVideoEditAdjustments : NSObject <TGMediaEditAdjustments>

@property (nonatomic, readonly) NSTimeInterval trimStartValue;
@property (nonatomic, readonly) NSTimeInterval trimEndValue;

- (bool)rotationApplied;
- (bool)trimApplied;

- (NSDictionary *)dictionary;

- (bool)cropOrRotationAppliedForAvatar:(bool)__unused forAvatar;
- (bool)isCropAndRotationEqualWith:(id<TGMediaEditAdjustments>)adjusments;

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize
                                       cropRect:(CGRect)cropRect
                                cropOrientation:(UIImageOrientation)cropOrientation
                          cropLockedAspectRatio:(CGFloat)cropLockedAspectRatio
                                 trimStartValue:(NSTimeInterval)trimStartValue
                                   trimEndValue:(NSTimeInterval)trimEndValue;

+ (instancetype)editAdjustmentsWithDictionary:(NSDictionary *)dictionary;

@end

typedef TGVideoEditAdjustments TGMediaVideoEditAdjustments;
