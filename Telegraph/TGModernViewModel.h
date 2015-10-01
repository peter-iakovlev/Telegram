/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGModernViewStorage.h"

@protocol TGModernView;

@interface TGModernViewModel : NSObject
{
    @private
    struct {
        int hasNoView : 1;
        int skipDrawInContext : 1;
        int disableSubmodelAutomaticBinding : 1;
        int viewUserInteractionDisabled : 1;
    } _modelFlags;
}

@property (nonatomic, strong) id modelId;

@property (nonatomic, strong) NSString *viewStateIdentifier;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint parentOffset;
@property (nonatomic) float alpha;
@property (nonatomic) bool hidden;

@property (nonatomic, strong, readonly) NSArray *submodels;

@property (nonatomic, copy) void (^unbindAction)();

- (bool)hasNoView;
- (void)setHasNoView:(bool)hasNoView;

- (bool)skipDrawInContext;
- (void)setSkipDrawInContext:(bool)skipDrawInContext;

- (bool)disableSubmodelAutomaticBinding;
- (void)setDisableSubmodelAutomaticBinding:(bool)disableSubmodelAutomaticBinding;

- (bool)viewUserInteractionDisabled;
- (void)setViewUserInteractionDisabled:(bool)viewUserInteractionDisabled;

- (Class)viewClass;
- (UIView<TGModernView> *)_dequeueView:(TGModernViewStorage *)viewStorage;

- (UIView<TGModernView> *)boundView;
- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage;
- (void)unbindView:(TGModernViewStorage *)viewStorage;
- (void)moveViewToContainer:(UIView *)container;

- (void)_offsetBoundViews:(CGSize)offset;

- (void)drawInContext:(CGContextRef)context;
- (void)drawSubmodelsInContext:(CGContextRef)context;

- (void)sizeToFit;
- (CGRect)bounds;

- (bool)containsSubmodel:(TGModernViewModel *)model;
- (void)addSubmodel:(TGModernViewModel *)model;
- (void)insertSubmodel:(TGModernViewModel *)model aboveSubmodel:(TGModernViewModel *)aboveSubmodel;
- (void)removeSubmodel:(TGModernViewModel *)model viewStorage:(TGModernViewStorage *)viewStorage;
- (void)layoutForContainerSize:(CGSize)containerSize;

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict;
- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict ifPresentInDict:(NSMutableDictionary *)anotherDict;
- (void)restoreBoundModelViewFramesRecursively:(NSMutableDictionary *)dict;

@end
