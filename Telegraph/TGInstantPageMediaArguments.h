#import <Foundation/Foundation.h>

@interface TGInstantPageMediaArguments : NSObject

@property (nonatomic, readonly) bool interactive;

- (instancetype)initWithInteractive:(bool)interactive;

@end

@interface TGInstantPageImageMediaArguments : TGInstantPageMediaArguments

@property (nonatomic, readonly) bool roundCorners;
@property (nonatomic, readonly) bool fit;

- (instancetype)initWithInteractive:(bool)interactive roundCorners:(bool)roundCorners fit:(bool)fit;

@end

@interface TGInstantPageVideoMediaArguments : TGInstantPageMediaArguments

@property (nonatomic, readonly) bool autoplay;

- (instancetype)initWithInteractive:(bool)interactive autoplay:(bool)autoplay;

@end
