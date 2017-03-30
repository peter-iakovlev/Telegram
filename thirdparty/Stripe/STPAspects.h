//
//  Aspects.h
//  Aspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, STPAspectOptions) {
    STPAspectPositionAfter   = 0,            /// Called after the original implementation (default)
    STPAspectPositionInstead = 1,            /// Will replace the original implementation.
    STPAspectPositionBefore  = 2,            /// Called before the original implementation.
    
    STPAspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque Aspect Token that allows to deregister the hook.
@protocol STPAspectToken <NSObject>

/// Deregisters an aspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The AspectInfo protocol is the first parameter of our block syntax.
@protocol STPAspectInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 Aspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. Aspects is meant for view/controller code that is not called a 1000 times per second.

 Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (STPAspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block Aspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<STPAspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<STPAspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the aspect.
+ (id<STPAspectToken>)stp_aspect_hookSelector:(SEL)selector
                                  withOptions:(STPAspectOptions)options
                                   usingBlock:(id)block
                                        error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<STPAspectToken>)stp_aspect_hookSelector:(SEL)selector
                                  withOptions:(STPAspectOptions)options
                                   usingBlock:(id)block
                                        error:(NSError **)error;

@end

void linkAspectsCategory(void);


typedef NS_ENUM(NSUInteger, STPAspectErrorCode) {
    STPAspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    STPAspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    STPAspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only AspectPositionBefore is allowed.
    STPAspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    STPAspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    STPAspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    STPAspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    STPAspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const STPAspectErrorDomain;
