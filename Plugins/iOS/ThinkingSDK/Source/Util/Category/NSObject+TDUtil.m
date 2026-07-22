//
//  NSObject+TDUtil.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/18.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "NSObject+TDUtil.h"
#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

@implementation NSObject (TDUtil)

+ (NSValue *)valueForPrimitivePointer:(void *)pointer objCType:(const char *)type
{
    // CASE marcro inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
#define CASE(ctype, selectorpart) \
if(strcmp(type, @encode(ctype)) == 0) { \
return [NSNumber numberWith ## selectorpart: *(ctype *)pointer]; \
}
    
    CASE(BOOL, Bool);
    CASE(unsigned char, UnsignedChar);
    CASE(short, Short);
    CASE(unsigned short, UnsignedShort);
    CASE(int, Int);
    CASE(unsigned int, UnsignedInt);
    CASE(long, Long);
    CASE(unsigned long, UnsignedLong);
    CASE(long long, LongLong);
    CASE(unsigned long long, UnsignedLongLong);
    CASE(float, Float);
    CASE(double, Double);
    
#undef CASE
    
    NSValue *value = nil;
    @try {
        value = [NSValue valueWithBytes:pointer objCType:type];
    } @catch (NSException *exception) {
        // Certain type encodings are not supported by valueWithBytes:objCType:. Just fail silently if an exception is thrown.
    }
    
    return value;
}


+ (BOOL)isTollFreeBridgedValue:(id)value forCFType:(const char *)typeEncoding
{
    // See https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html
#define CASE(cftype, foundationClass) \
if(strcmp(typeEncoding, @encode(cftype)) == 0) { \
return [value isKindOfClass:[foundationClass class]]; \
}
    
    CASE(CFArrayRef, NSArray);
    CASE(CFAttributedStringRef, NSAttributedString);
    CASE(CFCalendarRef, NSCalendar);
    CASE(CFCharacterSetRef, NSCharacterSet);
    CASE(CFDataRef, NSData);
    CASE(CFDateRef, NSDate);
    CASE(CFDictionaryRef, NSDictionary);
    CASE(CFErrorRef, NSError);
    CASE(CFLocaleRef, NSLocale);
    CASE(CFMutableArrayRef, NSMutableArray);
    CASE(CFMutableAttributedStringRef, NSMutableAttributedString);
    CASE(CFMutableCharacterSetRef, NSMutableCharacterSet);
    CASE(CFMutableDataRef, NSMutableData);
    CASE(CFMutableDictionaryRef, NSMutableDictionary);
    CASE(CFMutableSetRef, NSMutableSet);
    CASE(CFMutableStringRef, NSMutableString);
    CASE(CFNumberRef, NSNumber);
    CASE(CFReadStreamRef, NSInputStream);
    CASE(CFRunLoopTimerRef, NSTimer);
    CASE(CFSetRef, NSSet);
    CASE(CFStringRef, NSString);
    CASE(CFTimeZoneRef, NSTimeZone);
    CASE(CFURLRef, NSURL);
    CASE(CFWriteStreamRef, NSOutputStream);
    
#undef CASE
    
    return NO;
}


+ (id)performSelector:(SEL)selector onTarget:(id)target withArguments:(NSArray *)arguments{
    
    if ([target respondsToSelector:selector]) {
        
        NSMethodSignature *signature = [target methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:target];
        [invocation setSelector:selector];
        [invocation retainArguments];
        
        // Always self and _cmd
        NSUInteger numberOfArguments = [signature numberOfArguments];
        for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; argumentIndex++) {
            NSUInteger argumentsArrayIndex = argumentIndex - 2;
            
            id argumentObject = [arguments count] > argumentsArrayIndex ? [arguments objectAtIndex:argumentsArrayIndex] : nil;
            
            // NSNull in the arguments array can be passed as a placeholder to indicate nil. We only need to set the argument if it will be non-nil.
            if (argumentObject && ![argumentObject isKindOfClass:[NSNull class]]) {
                const char *typeEncodingCString = [signature getArgumentTypeAtIndex:argumentIndex];
                if (typeEncodingCString[0] == @encode(id)[0] || typeEncodingCString[0] == @encode(Class)[0] || [self isTollFreeBridgedValue:argumentObject forCFType:typeEncodingCString]) {
                    // Object
                    [invocation setArgument:&argumentObject atIndex:argumentIndex];
                } else if (strcmp(typeEncodingCString, @encode(CGColorRef)) == 0
#if TARGET_OS_IOS
                           && [argumentObject isKindOfClass:[UIColor class]]
#elif TARGET_OS_OSX
                           && [argumentObject isKindOfClass:[NSColor class]]
#endif
                           ) {
                    // Bridging UIColor to CGColorRef
                    CGColorRef colorRef = [argumentObject CGColor];
                    [invocation setArgument:&colorRef atIndex:argumentIndex];
                } else if ([argumentObject isKindOfClass:[NSValue class]]) {
                    // Primitive boxed in NSValue
                    NSValue *argumentValue = (NSValue *)argumentObject;
                    
                    // Ensure that the type encoding on the NSValue matches the type encoding of the argument in the method signature
                    if (strcmp([argumentValue objCType], typeEncodingCString) != 0) {
                        return nil;
                    }
                    
                    NSUInteger bufferSize = 0;
                    @try {
                        // NSGetSizeAndAlignment barfs on type encoding for bitfields.
                        NSGetSizeAndAlignment(typeEncodingCString, &bufferSize, NULL);
                    } @catch (NSException *exception) { }
                    
                    if (bufferSize > 0) {
                        void *buffer = calloc(bufferSize, 1);
                        [argumentValue getValue:buffer];
                        [invocation setArgument:buffer atIndex:argumentIndex];
                        free(buffer);
                    }
                }
            }
        }
        
        // Try to invoke the invocation but guard against an exception being thrown.
        BOOL successfullyInvoked = NO;
        @try {
            // Some methods are not fit to be called...
            // Looking at you -[UIResponder(UITextInputAdditions) _caretRect]
            [invocation invoke];
            successfullyInvoked = YES;
        } @catch (NSException *exception) {
            // Bummer...
        }
        
        // Retreive the return value and box if necessary.
        id returnObject = nil;
        if (successfullyInvoked) {
            const char *returnType = [signature methodReturnType];
            if (returnType[0] == @encode(id)[0] || returnType[0] == @encode(Class)[0]) {
                __unsafe_unretained id objectReturnedFromMethod = nil;
                [invocation getReturnValue:&objectReturnedFromMethod];
                returnObject = objectReturnedFromMethod;
            } else if (returnType[0] != @encode(void)[0]) {
                void *returnValue = malloc([signature methodReturnLength]);
                if (returnValue) {
                    [invocation getReturnValue:returnValue];
                    returnObject = [self valueForPrimitivePointer:returnValue objCType:returnType];
                    free(returnValue);
                }
            }
        }
        
        return returnObject;
    }
    
    return nil;
}


@end
