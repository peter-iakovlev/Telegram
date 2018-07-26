#import "TGCollectionItem.h"
#import <SSignalKit/SSignalKit.h>

@interface TGPassportFileCollectionItem : TGCollectionItem

@property (nonatomic, copy) void (^action)(TGPassportFileCollectionItem *);
@property (nonatomic, copy) void (^removeRequested)(TGPassportFileCollectionItem *);

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) SSignal *imageSignal;
@property (nonatomic, strong) SSignal *progressSignal;
@property (nonatomic) bool isRequired;
@property (nonatomic) bool imageViewHidden;

@property (nonatomic, weak) id file;

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(TGPassportFileCollectionItem *))action removeRequested:(void (^)(TGPassportFileCollectionItem *))removeRequested;

- (void)resetAnimated:(bool)animated;

- (CGSize)imageSize;
- (UIView *)imageView;

@end
