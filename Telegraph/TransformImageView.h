#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

@interface TransformImageArguments : NSObject

@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) CGSize boundingSize;
@property (nonatomic, readonly) CGFloat cornerRadius;
@property (nonatomic, readonly) bool scaleToFit;

- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius;
- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius scaleToFit:(bool)scaleToFit;

@end

@interface TransformImageView : UIView

@property (nonatomic, copy) void (^imageUpdated)();

- (void)setArguments:(TransformImageArguments *)arguments;
- (void)setSignal:(SSignal *)signal;

@end
