#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

@interface TransformImageArguments : NSObject

@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) CGSize boundingSize;
@property (nonatomic, readonly) CGFloat cornerRadius;
@property (nonatomic, readonly) bool scaleToFit;
@property (nonatomic, readonly) bool autoSize;

- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius;
- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius scaleToFit:(bool)scaleToFit;
- (instancetype)initAutoSizeWithBoundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius;

@end

@interface TransformImageView : UIView

@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, copy) void (^imageUpdated)();

- (void)setArguments:(TransformImageArguments *)arguments;
- (void)setSignal:(SSignal *)signal;

- (void)reset;

@end
