
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TAAspectOptions) {
    TAAspectPositionAfter   = 0,
    TAAspectPositionInstead = 1,           
    TAAspectPositionBefore  = 2,
    TAAspectOptionAutomaticRemoval = 1 << 3
};


@protocol TAAspectToken <NSObject>

- (BOOL)remove;

@end

@protocol TAAspectInfo <NSObject>

- (id)instance;

- (NSInvocation *)originalInvocation;

- (NSArray *)arguments;

@end

@interface NSObject (TAAspects)

+ (id<TAAspectToken>)ta_aspect_hookSelector:(SEL)selector
                           withOptions:(TAAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

- (id<TAAspectToken>)ta_aspect_hookSelector:(SEL)selector
                           withOptions:(TAAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, TAAspectErrorCode) {
    TAAspectErrorSelectorBlacklisted,
    TAAspectErrorDoesNotRespondToSelector,
    TAAspectErrorSelectorDeallocPosition,
    TAAspectErrorSelectorAlreadyHookedInClassHierarchy,
    TAAspectErrorFailedToAllocateClassPair,
    TAAspectErrorMissingBlockSignature,
    TAAspectErrorIncompatibleBlockSignature,

    TAAspectErrorRemoveObjectAlreadyDeallocated = 100  
};

extern NSString *const TAAspectErrorDomain;
