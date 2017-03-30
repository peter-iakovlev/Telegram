//
//  Aspects.m
//  Aspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import "STPAspects.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define STPAspectLog(...)
//#define STPAspectLog(...) do { NSLog(__VA_ARGS__); }while(0)
#define STPAspectLogError(...) do { NSLog(__VA_ARGS__); }while(0)

// Block internals.
typedef NS_OPTIONS(int, STPAspectBlockFlags) {
	STPAspectBlockFlagsHasCopyDisposeHelpers = (1 << 25),
	STPAspectBlockFlagsHasSignature          = (1 << 30)
};
typedef struct _STPAspectBlock {
	__unused Class isa;
	STPAspectBlockFlags flags;
	__unused int reserved;
	void (__unused *invoke)(struct _STPAspectBlock *block, ...);
	struct {
		unsigned long int reserved;
		unsigned long int size;
		// requires STPAspectBlockFlagsHasCopyDisposeHelpers
		void (*copy)(void *dst, const void *src);
		void (*dispose)(const void *);
		// requires STPAspectBlockFlagsHasSignature
		const char *signature;
		const char *layout;
	} *descriptor;
	// imported variables
} *STPAspectBlockRef;

@interface STPAspectInfo : NSObject <STPAspectInfo>
- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation;
@property (nonatomic, unsafe_unretained, readonly) id instance;
@property (nonatomic, strong, readonly) NSArray *arguments;
@property (nonatomic, strong, readonly) NSInvocation *originalInvocation;
@end

// Tracks a single aspect.
@interface STPAspectIdentifier : NSObject
+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(STPAspectOptions)options block:(id)block error:(NSError **)error;
- (BOOL)invokeWithInfo:(id<STPAspectInfo>)info;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id block;
@property (nonatomic, strong) NSMethodSignature *blockSignature;
@property (nonatomic, weak) id object;
@property (nonatomic, assign) STPAspectOptions options;
@end

// Tracks all aspects for an object/class.
@interface STPAspectsContainer : NSObject
- (void)addAspect:(STPAspectIdentifier *)aspect withOptions:(STPAspectOptions)injectPosition;
- (BOOL)removeAspect:(id)aspect;
- (BOOL)hasAspects;
@property (atomic, copy) NSArray *beforeAspects;
@property (atomic, copy) NSArray *insteadAspects;
@property (atomic, copy) NSArray *afterAspects;
@end

@interface STPAspectTracker : NSObject
- (id)initWithTrackedClass:(Class)trackedClass;
@property (nonatomic, strong) Class trackedClass;
@property (nonatomic, readonly) NSString *trackedClassName;
@property (nonatomic, strong) NSMutableSet *selectorNames;
@property (nonatomic, strong) NSMutableDictionary *selectorNamesToSubclassTrackers;
- (void)addSubclassTracker:(STPAspectTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName;
- (void)removeSubclassTracker:(STPAspectTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName;
- (BOOL)subclassHasHookedSelectorName:(NSString *)selectorName;
- (NSSet *)subclassTrackersHookingSelectorName:(NSString *)selectorName;
@end

@interface NSInvocation (STPAspects)
- (NSArray *)stp_aspects_arguments;
@end

#define STPAspectPositionFilter 0x07

#define STPAspectError(errorCode, errorDescription) do { \
STPAspectLogError(@"STPAspects: %@", errorDescription); \
if (error) { *error = [NSError errorWithDomain:STPAspectErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorDescription}]; }}while(0)

NSString *const STPAspectErrorDomain = @"STPAspectErrorDomain";
static NSString *const STPAspectsSubclassSuffix = @"_STPAspects_";
static NSString *const STPAspectsMessagePrefix = @"stpaspects_";

@implementation NSObject (Aspects)

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Aspects API

+ (id<STPAspectToken>)stp_aspect_hookSelector:(SEL)selector
                      withOptions:(STPAspectOptions)options
                       usingBlock:(id)block
                            error:(NSError **)error {
    return stp_aspect_add((id)self, selector, options, block, error);
}

/// @return A token which allows to later deregister the aspect.
- (id<STPAspectToken>)stp_aspect_hookSelector:(SEL)selector
                      withOptions:(STPAspectOptions)options
                       usingBlock:(id)block
                            error:(NSError **)error {
    return stp_aspect_add(self, selector, options, block, error);
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

static id stp_aspect_add(id self, SEL selector, STPAspectOptions options, id block, NSError **error) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);
    NSCParameterAssert(block);

    __block STPAspectIdentifier *identifier = nil;
    stp_aspect_performLocked(^{
        if (stp_aspect_isSelectorAllowedAndTrack(self, selector, options, error)) {
            STPAspectsContainer *aspectContainer = stp_aspect_getContainerForObject(self, selector);
            identifier = [STPAspectIdentifier identifierWithSelector:selector object:self options:options block:block error:error];
            if (identifier) {
                [aspectContainer addAspect:identifier withOptions:options];

                // Modify the class to allow message interception.
                stp_aspect_prepareClassAndHookSelector(self, selector, error);
            }
        }
    });
    return identifier;
}

static BOOL stp_aspect_remove(STPAspectIdentifier *aspect, NSError **error) {
    NSCAssert([aspect isKindOfClass:STPAspectIdentifier.class], @"Must have correct type.");

    __block BOOL success = NO;
    stp_aspect_performLocked(^{
        id self = aspect.object; // strongify
        if (self) {
            STPAspectsContainer *aspectContainer = stp_aspect_getContainerForObject(self, aspect.selector);
            success = [aspectContainer removeAspect:aspect];

            stp_aspect_cleanupHookedClassAndSelector(self, aspect.selector);
            // destroy token
            aspect.object = nil;
            aspect.block = nil;
            aspect.selector = NULL;
        }else {
            NSString *errrorDesc = [NSString stringWithFormat:@"Unable to deregister hook. Object already deallocated: %@", aspect];
            STPAspectError(STPAspectErrorRemoveObjectAlreadyDeallocated, errrorDesc);
        }
    });
    return success;
}

static void stp_aspect_performLocked(dispatch_block_t block) {
    static OSSpinLock aspect_lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&aspect_lock);
    block();
    OSSpinLockUnlock(&aspect_lock);
}

static SEL stp_aspect_aliasForSelector(SEL selector) {
    NSCParameterAssert(selector);
	return NSSelectorFromString([STPAspectsMessagePrefix stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]);
}

static NSMethodSignature *stp_aspect_blockMethodSignature(id block, NSError **error) {
    STPAspectBlockRef layout = (__bridge void *)block;
	if (!(layout->flags & STPAspectBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        STPAspectError(STPAspectErrorMissingBlockSignature, description);
        return nil;
    }
	void *desc = layout->descriptor;
	desc += 2 * sizeof(unsigned long int);
	if (layout->flags & STPAspectBlockFlagsHasCopyDisposeHelpers) {
		desc += 2 * sizeof(void *);
    }
	if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        STPAspectError(STPAspectErrorMissingBlockSignature, description);
        return nil;
    }
	const char *signature = (*(const char **)desc);
	return [NSMethodSignature signatureWithObjCTypes:signature];
}

static BOOL stp_aspect_isCompatibleBlockSignature(NSMethodSignature *blockSignature, id object, SEL selector, NSError **error) {
    NSCParameterAssert(blockSignature);
    NSCParameterAssert(object);
    NSCParameterAssert(selector);

    BOOL signaturesMatch = YES;
    NSMethodSignature *methodSignature = [[object class] instanceMethodSignatureForSelector:selector];
    if (blockSignature.numberOfArguments > methodSignature.numberOfArguments) {
        signaturesMatch = NO;
    }else {
        if (blockSignature.numberOfArguments > 1) {
            const char *blockType = [blockSignature getArgumentTypeAtIndex:1];
            if (blockType[0] != '@') {
                signaturesMatch = NO;
            }
        }
        // Argument 0 is self/block, argument 1 is SEL or id<STPAspectInfo>. We start comparing at argument 2.
        // The block can have less arguments than the method, that's ok.
        if (signaturesMatch) {
            for (NSUInteger idx = 2; idx < blockSignature.numberOfArguments; idx++) {
                const char *methodType = [methodSignature getArgumentTypeAtIndex:idx];
                const char *blockType = [blockSignature getArgumentTypeAtIndex:idx];
                // Only compare parameter, not the optional type data.
                if (!methodType || !blockType || methodType[0] != blockType[0]) {
                    signaturesMatch = NO; break;
                }
            }
        }
    }

    if (!signaturesMatch) {
        NSString *description = [NSString stringWithFormat:@"Block signature %@ doesn't match %@.", blockSignature, methodSignature];
        STPAspectError(STPAspectErrorIncompatibleBlockSignature, description);
        return NO;
    }
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class + Selector Preparation

static BOOL stp_aspect_isMsgForwardIMP(IMP impl) {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

static IMP stp_aspect_getMsgForwardIMP(__unused NSObject *self, __unused SEL selector) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method = class_getInstanceMethod(self.class, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);

            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

static void stp_aspect_prepareClassAndHookSelector(NSObject *self, SEL selector, NSError **error) {
    NSCParameterAssert(selector);
    Class klass = stp_aspect_hookClass(self, error);
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (!stp_aspect_isMsgForwardIMP(targetMethodIMP)) {
        // Make a method alias for the existing method implementation, it not already copied.
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = stp_aspect_aliasForSelector(selector);
        if (![klass instancesRespondToSelector:aliasSelector]) {
            __unused BOOL addedAlias = class_addMethod(klass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
            NSCAssert(addedAlias, @"Original implementation for %@ is already copied to %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        }

        // We use forwardInvocation to hook in.
        class_replaceMethod(klass, selector, stp_aspect_getMsgForwardIMP(self, selector), typeEncoding);
        STPAspectLog(@"Aspects: Installed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }
}

// Will undo the runtime changes made.
static void stp_aspect_cleanupHookedClassAndSelector(NSObject *self, SEL selector) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);

	Class klass = object_getClass(self);
    BOOL isMetaClass = class_isMetaClass(klass);
    if (isMetaClass) {
        klass = (Class)self;
    }

    // Check if the method is marked as forwarded and undo that.
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (stp_aspect_isMsgForwardIMP(targetMethodIMP)) {
        // Restore the original method implementation.
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = stp_aspect_aliasForSelector(selector);
        Method originalMethod = class_getInstanceMethod(klass, aliasSelector);
        IMP originalIMP = method_getImplementation(originalMethod);
        NSCAssert(originalMethod, @"Original implementation for %@ not found %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);

        class_replaceMethod(klass, selector, originalIMP, typeEncoding);
        STPAspectLog(@"Aspects: Removed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }

    // Deregister global tracked selector
    stp_aspect_deregisterTrackedSelector(self, selector);

    // Get the aspect container and check if there are any hooks remaining. Clean up if there are not.
    STPAspectsContainer *container = stp_aspect_getContainerForObject(self, selector);
    if (!container.hasAspects) {
        // Destroy the container
        stp_aspect_destroyContainerForObject(self, selector);

        // Figure out how the class was modified to undo the changes.
        NSString *className = NSStringFromClass(klass);
        if ([className hasSuffix:STPAspectsSubclassSuffix]) {
            Class originalClass = NSClassFromString([className stringByReplacingOccurrencesOfString:STPAspectsSubclassSuffix withString:@""]);
            NSCAssert(originalClass != nil, @"Original class must exist");
            object_setClass(self, originalClass);
            STPAspectLog(@"Aspects: %@ has been restored.", NSStringFromClass(originalClass));

            // We can only dispose the class pair if we can ensure that no instances exist using our subclass.
            // Since we don't globally track this, we can't ensure this - but there's also not much overhead in keeping it around.
            //objc_disposeClassPair(object.class);
        }else {
            // Class is most likely swizzled in place. Undo that.
            if (isMetaClass) {
                stp_aspect_undoSwizzleClassInPlace((Class)self);
            }else if (self.class != klass) {
            	stp_aspect_undoSwizzleClassInPlace(klass);
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Hook Class

static Class stp_aspect_hookClass(NSObject *self, NSError **error) {
    NSCParameterAssert(self);
	Class statedClass = self.class;
	Class baseClass = object_getClass(self);
	NSString *className = NSStringFromClass(baseClass);

    // Already subclassed
	if ([className hasSuffix:STPAspectsSubclassSuffix]) {
		return baseClass;

        // We swizzle a class object, not a single object.
	}else if (class_isMetaClass(baseClass)) {
        return stp_aspect_swizzleClassInPlace((Class)self);
        // Probably a KVO'ed class. Swizzle in place. Also swizzle meta classes in place.
    }else if (statedClass != baseClass) {
        return stp_aspect_swizzleClassInPlace(baseClass);
    }

    // Default case. Create dynamic subclass.
	const char *subclassName = [className stringByAppendingString:STPAspectsSubclassSuffix].UTF8String;
	Class subclass = objc_getClass(subclassName);

	if (subclass == nil) {
		subclass = objc_allocateClassPair(baseClass, subclassName, 0);
		if (subclass == nil) {
            NSString *errrorDesc = [NSString stringWithFormat:@"objc_allocateClassPair failed to allocate class %s.", subclassName];
            STPAspectError(STPAspectErrorFailedToAllocateClassPair, errrorDesc);
            return nil;
        }

		stp_aspect_swizzleForwardInvocation(subclass);
		stp_aspect_hookedGetClass(subclass, statedClass);
		stp_aspect_hookedGetClass(object_getClass(subclass), statedClass);
		objc_registerClassPair(subclass);
	}

	object_setClass(self, subclass);
	return subclass;
}

static NSString *const STPAspectsForwardInvocationSelectorName = @"__stp_aspects_forwardInvocation:";
static void stp_aspect_swizzleForwardInvocation(Class klass) {
    NSCParameterAssert(klass);
    // If there is no method, replace will act like class_addMethod.
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__STP_ASPECTS_ARE_BEING_CALLED__, "v@:@");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(STPAspectsForwardInvocationSelectorName), originalImplementation, "v@:@");
    }
    STPAspectLog(@"Aspects: %@ is now aspect aware.", NSStringFromClass(klass));
}

static void stp_aspect_undoSwizzleForwardInvocation(Class klass) {
    NSCParameterAssert(klass);
    Method originalMethod = class_getInstanceMethod(klass, NSSelectorFromString(STPAspectsForwardInvocationSelectorName));
    Method objectMethod = class_getInstanceMethod(NSObject.class, @selector(forwardInvocation:));
    // There is no class_removeMethod, so the best we can do is to retore the original implementation, or use a dummy.
    IMP originalImplementation = method_getImplementation(originalMethod ?: objectMethod);
    class_replaceMethod(klass, @selector(forwardInvocation:), originalImplementation, "v@:@");

    STPAspectLog(@"Aspects: %@ has been restored.", NSStringFromClass(klass));
}

static void stp_aspect_hookedGetClass(Class class, Class statedClass) {
    NSCParameterAssert(class);
    NSCParameterAssert(statedClass);
	Method method = class_getInstanceMethod(class, @selector(class));
	IMP newIMP = imp_implementationWithBlock(^(__unused id self) {
		return statedClass;
	});
	class_replaceMethod(class, @selector(class), newIMP, method_getTypeEncoding(method));
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Swizzle Class In Place

static void _stp_aspect_modifySwizzledClasses(void (^block)(NSMutableSet *swizzledClasses)) {
    static NSMutableSet *swizzledClasses;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClasses = [NSMutableSet new];
    });
    @synchronized(swizzledClasses) {
        block(swizzledClasses);
    }
}

static Class stp_aspect_swizzleClassInPlace(Class klass) {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);

    _stp_aspect_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        if (![swizzledClasses containsObject:className]) {
            stp_aspect_swizzleForwardInvocation(klass);
            [swizzledClasses addObject:className];
        }
    });
    return klass;
}

static void stp_aspect_undoSwizzleClassInPlace(Class klass) {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);

    _stp_aspect_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        if ([swizzledClasses containsObject:className]) {
            stp_aspect_undoSwizzleForwardInvocation(klass);
            [swizzledClasses removeObject:className];
        }
    });
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Aspect Invoke Point

// This is a macro so we get a cleaner stack trace.
#define stp_aspect_invoke(aspects, info) \
for (STPAspectIdentifier *aspect in aspects) {\
    [aspect invokeWithInfo:info];\
    if (aspect.options & STPAspectOptionAutomaticRemoval) { \
        aspectsToRemove = [aspectsToRemove?:@[] arrayByAddingObject:aspect]; \
    } \
}

// This is the swizzled forwardInvocation: method.
static void __STP_ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, __unused SEL selector, NSInvocation *invocation) {
    NSCParameterAssert(self);
    NSCParameterAssert(invocation);
    SEL originalSelector = invocation.selector;
	SEL aliasSelector = stp_aspect_aliasForSelector(invocation.selector);
    invocation.selector = aliasSelector;
    STPAspectsContainer *objectContainer = objc_getAssociatedObject(self, aliasSelector);
    STPAspectsContainer *classContainer = stp_aspect_getContainerForClass(object_getClass(self), aliasSelector);
    STPAspectInfo *info = [[STPAspectInfo alloc] initWithInstance:self invocation:invocation];
    NSArray *aspectsToRemove = nil;

    // Before hooks.
    stp_aspect_invoke(classContainer.beforeAspects, info);
    stp_aspect_invoke(objectContainer.beforeAspects, info);

    // Instead hooks.
    BOOL respondsToAlias = YES;
    if (objectContainer.insteadAspects.count || classContainer.insteadAspects.count) {
        stp_aspect_invoke(classContainer.insteadAspects, info);
        stp_aspect_invoke(objectContainer.insteadAspects, info);
    }else {
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:aliasSelector])) {
                [invocation invoke];
                break;
            }
        }while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }

    // After hooks.
    stp_aspect_invoke(classContainer.afterAspects, info);
    stp_aspect_invoke(objectContainer.afterAspects, info);

    // If no hooks are installed, call original implementation (usually to throw an exception)
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSEL = NSSelectorFromString(STPAspectsForwardInvocationSelectorName);
        if ([self respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSEL, invocation);
        }else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }

    // Remove any hooks that are queued for deregistration.
    [aspectsToRemove makeObjectsPerformSelector:@selector(remove)];
}
#undef stp_aspect_invoke

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Aspect Container Management

// Loads or creates the aspect container.
static STPAspectsContainer *stp_aspect_getContainerForObject(NSObject *self, SEL selector) {
    NSCParameterAssert(self);
    SEL aliasSelector = stp_aspect_aliasForSelector(selector);
    STPAspectsContainer *aspectContainer = objc_getAssociatedObject(self, aliasSelector);
    if (!aspectContainer) {
        aspectContainer = [STPAspectsContainer new];
        objc_setAssociatedObject(self, aliasSelector, aspectContainer, OBJC_ASSOCIATION_RETAIN);
    }
    return aspectContainer;
}

static STPAspectsContainer *stp_aspect_getContainerForClass(Class klass, SEL selector) {
    NSCParameterAssert(klass);
    STPAspectsContainer *classContainer = nil;
    do {
        classContainer = objc_getAssociatedObject(klass, selector);
        if (classContainer.hasAspects) break;
    }while ((klass = class_getSuperclass(klass)));

    return classContainer;
}

static void stp_aspect_destroyContainerForObject(id<NSObject> self, SEL selector) {
    NSCParameterAssert(self);
    SEL aliasSelector = stp_aspect_aliasForSelector(selector);
    objc_setAssociatedObject(self, aliasSelector, nil, OBJC_ASSOCIATION_RETAIN);
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selector Blacklist Checking

static NSMutableDictionary *stp_aspect_getSwizzledClassesDict() {
    static NSMutableDictionary *swizzledClassesDict;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClassesDict = [NSMutableDictionary new];
    });
    return swizzledClassesDict;
}

static BOOL stp_aspect_isSelectorAllowedAndTrack(NSObject *self, SEL selector, STPAspectOptions options, NSError **error) {
    static NSSet *disallowedSelectorList;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });

    // Check against the blacklist.
    NSString *selectorName = NSStringFromSelector(selector);
    if ([disallowedSelectorList containsObject:selectorName]) {
        NSString *errorDescription = [NSString stringWithFormat:@"Selector %@ is blacklisted.", selectorName];
        STPAspectError(STPAspectErrorSelectorBlacklisted, errorDescription);
        return NO;
    }

    // Additional checks.
    STPAspectOptions position = options&STPAspectPositionFilter;
    if ([selectorName isEqualToString:@"dealloc"] && position != STPAspectPositionBefore) {
        NSString *errorDesc = @"AspectPositionBefore is the only valid position when hooking dealloc.";
        STPAspectError(STPAspectErrorSelectorDeallocPosition, errorDesc);
        return NO;
    }

    if (![self respondsToSelector:selector] && ![self.class instancesRespondToSelector:selector]) {
        NSString *errorDesc = [NSString stringWithFormat:@"Unable to find selector -[%@ %@].", NSStringFromClass(self.class), selectorName];
        STPAspectError(STPAspectErrorDoesNotRespondToSelector, errorDesc);
        return NO;
    }

    // Search for the current class and the class hierarchy IF we are modifying a class object
    if (class_isMetaClass(object_getClass(self))) {
        Class klass = [self class];
        NSMutableDictionary *swizzledClassesDict = stp_aspect_getSwizzledClassesDict();
        Class currentClass = [self class];

        STPAspectTracker *tracker = swizzledClassesDict[currentClass];
        if ([tracker subclassHasHookedSelectorName:selectorName]) {
            NSSet *subclassTracker = [tracker subclassTrackersHookingSelectorName:selectorName];
            NSSet *subclassNames = [subclassTracker valueForKey:@"trackedClassName"];
            NSString *errorDescription = [NSString stringWithFormat:@"Error: %@ already hooked subclasses: %@. A method can only be hooked once per class hierarchy.", selectorName, subclassNames];
            STPAspectError(STPAspectErrorSelectorAlreadyHookedInClassHierarchy, errorDescription);
            return NO;
        }

        do {
            tracker = swizzledClassesDict[currentClass];
            if ([tracker.selectorNames containsObject:selectorName]) {
                if (klass == currentClass) {
                    // Already modified and topmost!
                    return YES;
                }
                NSString *errorDescription = [NSString stringWithFormat:@"Error: %@ already hooked in %@. A method can only be hooked once per class hierarchy.", selectorName, NSStringFromClass(currentClass)];
                STPAspectError(STPAspectErrorSelectorAlreadyHookedInClassHierarchy, errorDescription);
                return NO;
            }
        } while ((currentClass = class_getSuperclass(currentClass)));

        // Add the selector as being modified.
        currentClass = klass;
        STPAspectTracker *subclassTracker = nil;
        do {
            tracker = swizzledClassesDict[currentClass];
            if (!tracker) {
                tracker = [[STPAspectTracker alloc] initWithTrackedClass:currentClass];
                swizzledClassesDict[(id<NSCopying>)currentClass] = tracker;
            }
            if (subclassTracker) {
                [tracker addSubclassTracker:subclassTracker hookingSelectorName:selectorName];
            } else {
                [tracker.selectorNames addObject:selectorName];
            }

            // All superclasses get marked as having a subclass that is modified.
            subclassTracker = tracker;
        }while ((currentClass = class_getSuperclass(currentClass)));
	} else {
		return YES;
	}

    return YES;
}

static void stp_aspect_deregisterTrackedSelector(id self, SEL selector) {
    if (!class_isMetaClass(object_getClass(self))) return;

    NSMutableDictionary *swizzledClassesDict = stp_aspect_getSwizzledClassesDict();
    NSString *selectorName = NSStringFromSelector(selector);
    Class currentClass = [self class];
    STPAspectTracker *subclassTracker = nil;
    do {
        STPAspectTracker *tracker = swizzledClassesDict[currentClass];
        if (subclassTracker) {
            [tracker removeSubclassTracker:subclassTracker hookingSelectorName:selectorName];
        } else {
            [tracker.selectorNames removeObject:selectorName];
        }
        if (tracker.selectorNames.count == 0 && tracker.selectorNamesToSubclassTrackers) {
            [swizzledClassesDict removeObjectForKey:currentClass];
        }
        subclassTracker = tracker;
    }while ((currentClass = class_getSuperclass(currentClass)));
}

@end

@implementation STPAspectTracker

- (id)initWithTrackedClass:(Class)trackedClass {
    if (self = [super init]) {
        _trackedClass = trackedClass;
        _selectorNames = [NSMutableSet new];
        _selectorNamesToSubclassTrackers = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)subclassHasHookedSelectorName:(NSString *)selectorName {
    return self.selectorNamesToSubclassTrackers[selectorName] != nil;
}

- (void)addSubclassTracker:(STPAspectTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName {
    NSMutableSet *trackerSet = self.selectorNamesToSubclassTrackers[selectorName];
    if (!trackerSet) {
        trackerSet = [NSMutableSet new];
        self.selectorNamesToSubclassTrackers[selectorName] = trackerSet;
    }
    [trackerSet addObject:subclassTracker];
}
- (void)removeSubclassTracker:(STPAspectTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName {
    NSMutableSet *trackerSet = self.selectorNamesToSubclassTrackers[selectorName];
    [trackerSet removeObject:subclassTracker];
    if (trackerSet.count == 0) {
        [self.selectorNamesToSubclassTrackers removeObjectForKey:selectorName];
    }
}
- (NSSet *)subclassTrackersHookingSelectorName:(NSString *)selectorName {
    NSMutableSet *hookingSubclassTrackers = [NSMutableSet new];
    for (STPAspectTracker *tracker in self.selectorNamesToSubclassTrackers[selectorName]) {
        if ([tracker.selectorNames containsObject:selectorName]) {
            [hookingSubclassTrackers addObject:tracker];
        }
        [hookingSubclassTrackers unionSet:[tracker subclassTrackersHookingSelectorName:selectorName]];
    }
    return hookingSubclassTrackers;
}
- (NSString *)trackedClassName {
    return NSStringFromClass(self.trackedClass);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@, trackedClass: %@, selectorNames:%@, subclass selector names: %@>", self.class, self, NSStringFromClass(self.trackedClass), self.selectorNames, self.selectorNamesToSubclassTrackers.allKeys];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSInvocation (STPAspects)

@implementation NSInvocation (STPAspects)

// Thanks to the ReactiveCocoa team for providing a generic solution for this.
- (id)stp_aspect_argumentAtIndex:(NSUInteger)index {
	const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
	// Skip const type qualifier.
	if (argType[0] == _C_CONST) argType++;

#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)
	if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
		__autoreleasing id returnObj;
		[self getArgument:&returnObj atIndex:(NSInteger)index];
		return returnObj;
	} else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getArgument:&theClass atIndex:(NSInteger)index];
        return theClass;
        // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
	} else if (strcmp(argType, @encode(char)) == 0) {
		WRAP_AND_RETURN(char);
	} else if (strcmp(argType, @encode(int)) == 0) {
		WRAP_AND_RETURN(int);
	} else if (strcmp(argType, @encode(short)) == 0) {
		WRAP_AND_RETURN(short);
	} else if (strcmp(argType, @encode(long)) == 0) {
		WRAP_AND_RETURN(long);
	} else if (strcmp(argType, @encode(long long)) == 0) {
		WRAP_AND_RETURN(long long);
	} else if (strcmp(argType, @encode(unsigned char)) == 0) {
		WRAP_AND_RETURN(unsigned char);
	} else if (strcmp(argType, @encode(unsigned int)) == 0) {
		WRAP_AND_RETURN(unsigned int);
	} else if (strcmp(argType, @encode(unsigned short)) == 0) {
		WRAP_AND_RETURN(unsigned short);
	} else if (strcmp(argType, @encode(unsigned long)) == 0) {
		WRAP_AND_RETURN(unsigned long);
	} else if (strcmp(argType, @encode(unsigned long long)) == 0) {
		WRAP_AND_RETURN(unsigned long long);
	} else if (strcmp(argType, @encode(float)) == 0) {
		WRAP_AND_RETURN(float);
	} else if (strcmp(argType, @encode(double)) == 0) {
		WRAP_AND_RETURN(double);
	} else if (strcmp(argType, @encode(BOOL)) == 0) {
		WRAP_AND_RETURN(BOOL);
	} else if (strcmp(argType, @encode(bool)) == 0) {
		WRAP_AND_RETURN(BOOL);
	} else if (strcmp(argType, @encode(char *)) == 0) {
		WRAP_AND_RETURN(const char *);
	} else if (strcmp(argType, @encode(void (^)(void))) == 0) {
		__unsafe_unretained id block = nil;
		[self getArgument:&block atIndex:(NSInteger)index];
		return [block copy];
	} else {
		NSUInteger valueSize = 0;
		NSGetSizeAndAlignment(argType, &valueSize, NULL);

		unsigned char valueBytes[valueSize];
		[self getArgument:valueBytes atIndex:(NSInteger)index];

		return [NSValue valueWithBytes:valueBytes objCType:argType];
	}
	return nil;
#undef WRAP_AND_RETURN
}

- (NSArray *)stp_aspects_arguments {
	NSMutableArray *argumentsArray = [NSMutableArray array];
	for (NSUInteger idx = 2; idx < self.methodSignature.numberOfArguments; idx++) {
		[argumentsArray addObject:[self stp_aspect_argumentAtIndex:idx] ?: NSNull.null];
	}
	return [argumentsArray copy];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - STPAspectIdentifier

@implementation STPAspectIdentifier

+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(STPAspectOptions)options block:(id)block error:(NSError **)error {
    NSCParameterAssert(block);
    NSCParameterAssert(selector);
    NSMethodSignature *blockSignature = stp_aspect_blockMethodSignature(block, error);
    if (!stp_aspect_isCompatibleBlockSignature(blockSignature, object, selector, error)) {
        return nil;
    }

    STPAspectIdentifier *identifier = nil;
    if (blockSignature) {
        identifier = [STPAspectIdentifier new];
        identifier.selector = selector;
        identifier.block = block;
        identifier.blockSignature = blockSignature;
        identifier.options = options;
        identifier.object = object; // weak
    }
    return identifier;
}

- (BOOL)invokeWithInfo:(id<STPAspectInfo>)info {
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    NSInvocation *originalInvocation = info.originalInvocation;
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;

    // Be extra paranoid. We already check that on hook registration.
    if (numberOfArguments > originalInvocation.methodSignature.numberOfArguments) {
        STPAspectLogError(@"Block has too many arguments. Not calling %@", info);
        return NO;
    }

    // The `self` of the block will be the STPAspectInfo. Optional.
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&info atIndex:1];
    }
    
	void *argBuf = NULL;
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
		NSUInteger argSize;
		NSGetSizeAndAlignment(type, &argSize, NULL);
        
		if (!(argBuf = reallocf(argBuf, argSize))) {
            STPAspectLogError(@"Failed to allocate memory for block invocation.");
			return NO;
		}
        
		[originalInvocation getArgument:argBuf atIndex:idx];
		[blockInvocation setArgument:argBuf atIndex:idx];
    }
    
    [blockInvocation invokeWithTarget:self.block];
    
    if (argBuf != NULL) {
        free(argBuf);
    }
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, SEL:%@ object:%@ options:%tu block:%@ (#%tu args)>", self.class, self, NSStringFromSelector(self.selector), self.object, self.options, self.block, self.blockSignature.numberOfArguments];
}

- (BOOL)remove {
    return stp_aspect_remove(self, NULL);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - STPAspectsContainer

@implementation STPAspectsContainer

- (BOOL)hasAspects {
    return self.beforeAspects.count > 0 || self.insteadAspects.count > 0 || self.afterAspects.count > 0;
}

- (void)addAspect:(STPAspectIdentifier *)aspect withOptions:(STPAspectOptions)options {
    NSParameterAssert(aspect);
    NSUInteger position = options&STPAspectPositionFilter;
    switch (position) {
        case STPAspectPositionBefore:  self.beforeAspects  = [(self.beforeAspects ?:@[]) arrayByAddingObject:aspect]; break;
        case STPAspectPositionInstead: self.insteadAspects = [(self.insteadAspects?:@[]) arrayByAddingObject:aspect]; break;
        case STPAspectPositionAfter:   self.afterAspects   = [(self.afterAspects  ?:@[]) arrayByAddingObject:aspect]; break;
    }
}

- (BOOL)removeAspect:(id)aspect {
    for (NSString *aspectArrayName in @[NSStringFromSelector(@selector(beforeAspects)),
                                        NSStringFromSelector(@selector(insteadAspects)),
                                        NSStringFromSelector(@selector(afterAspects))]) {
        NSArray *array = [self valueForKey:aspectArrayName];
        NSUInteger index = [array indexOfObjectIdenticalTo:aspect];
        if (array && index != NSNotFound) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
            [newArray removeObjectAtIndex:index];
            [self setValue:newArray forKey:aspectArrayName];
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, before:%@, instead:%@, after:%@>", self.class, self, self.beforeAspects, self.insteadAspects, self.afterAspects];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - STPAspectInfo

@implementation STPAspectInfo

@synthesize arguments = _arguments;

- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation {
    NSCParameterAssert(instance);
    NSCParameterAssert(invocation);
    if (self = [super init]) {
        _instance = instance;
        _originalInvocation = invocation;
    }
    return self;
}

- (NSArray *)arguments {
    // Lazily evaluate arguments, boxing is expensive.
    if (!_arguments) {
        _arguments = self.originalInvocation.stp_aspects_arguments;
    }
    return _arguments;
}

@end

void linkAspectsCategory(void) {}
