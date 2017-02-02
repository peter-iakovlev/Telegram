#import "TransformImageView.h"

#import "DrawingContext.h"
#import "TGSharedMediaUtils.h"

#import "TGModernGalleryTransitionView.h"

@implementation TransformImageArguments

- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius {
    return [self initWithImageSize:imageSize boundingSize:boundingSize cornerRadius:cornerRadius scaleToFit:false];
}

- (instancetype)initWithImageSize:(CGSize)imageSize boundingSize:(CGSize)boundingSize cornerRadius:(CGFloat)cornerRadius scaleToFit:(bool)scaleToFit {
    self = [super init];
    if (self != nil) {
        _imageSize = imageSize;
        _boundingSize = boundingSize;
        _cornerRadius = cornerRadius;
        _scaleToFit = scaleToFit;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TransformImageArguments class]] && CGSizeEqualToSize(_imageSize, ((TransformImageArguments *)object)->_imageSize) && CGSizeEqualToSize(_boundingSize, ((TransformImageArguments *)object)->_boundingSize) && _cornerRadius == ((TransformImageArguments *)object)->_cornerRadius;
}

@end

@interface TransformImageView () <TGModernGalleryTransitionView> {
    SMetaDisposable *_disposable;
    SVariable *_arguments;
}

@end

@implementation TransformImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _disposable = [[SMetaDisposable alloc] init];
        _arguments = [[SVariable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

- (void)setArguments:(TransformImageArguments *)arguments {
    [_arguments set:[SSignal single:arguments]];
}

- (void)setSignal:(SSignal *)signal {
    SVariable *arguments = _arguments;
    
    SSignal *result = [[[SSignal combineSignals:@[signal, [arguments signal]]] deliverOnThreadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool]] mapToThrottled:^SSignal *(NSArray *values) {
        return [SSignal defer:^SSignal *{
            DrawingContext *(^transform)(TransformImageArguments *) = values[0];
            return [SSignal single:transform(values[1]).generateImage];
        }];
    }];
    
    __weak TransformImageView *weakSelf = self;
    [_disposable setDisposable:[[result deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *next) {
        __strong TransformImageView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            /*if strongSelf.alphaTransitionOnFirstUpdate && strongSelf.contents == nil {
                strongSelf.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.15)
            }*/
            strongSelf.layer.contents = (__bridge id)[next CGImage];
            if (strongSelf != nil) {
                if (strongSelf->_imageUpdated) {
                    strongSelf->_imageUpdated();
                }
            }
        }
    }]];
}

- (UIImage *)transitionImage {
    id contents = self.layer.contents;
    if (contents != nil) {
        return [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(contents)];
    } else {
        return nil;
    }
}

@end
