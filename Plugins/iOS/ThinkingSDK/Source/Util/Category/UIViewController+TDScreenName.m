//
//  UIViewController+TDScreenName.m
//  ThinkingSDK
//

#import "UIViewController+TDScreenName.h"

#import <TargetConditionals.h>
#if TARGET_OS_IOS

#import <dlfcn.h>

static NSSet<NSString *> *TDSwiftUIWrapperTypeNames(void) {
    static NSSet<NSString *> *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 补充 NavigationView / NavigationStack：它们常被用作 UIHostingController 的直接根视图，
        // 需要穿透进去找用户真正命名的内容视图。
        types = [NSSet setWithObjects:
                 @"AnyView",
                 @"_ConditionalContent",
                 @"ModifiedContent",
                 @"TupleView",
                 @"EmptyView",
                 @"Spacer",
                 @"Divider",
                 @"Section",
                 @"Group",
                 @"Optional",
                 @"NavigationView",
                 @"NavigationStack",
                 nil];
    });
    return types;
}

static BOOL TDIsSwiftUIWrapperTypeName(NSString *typeName) {
    if (typeName.length == 0) {
        return YES;
    }
    if ([TDSwiftUIWrapperTypeNames() containsObject:typeName]) {
        return YES;
    }
    if ([typeName hasPrefix:@"_"]) {
        return YES;
    }
    return NO;
}

static NSInteger TDReadMangledLength(NSString *mangled, NSUInteger *index) {
    NSUInteger cursor = *index;
    NSInteger length = 0;
    while (cursor < mangled.length) {
        unichar character = [mangled characterAtIndex:cursor];
        if (character < '0' || character > '9') {
            break;
        }
        length = length * 10 + (character - '0');
        cursor++;
    }
    *index = cursor;
    return length;
}

static NSString *TDSubstring(NSString *string, NSUInteger index, NSInteger length) {
    if (length <= 0 || index + length > string.length) {
        return nil;
    }
    return [string substringWithRange:NSMakeRange(index, (NSUInteger)length)];
}

static NSString *TDSwiftDemangle(NSString *mangledName) {
    if (mangledName.length == 0) {
        return nil;
    }

    typedef char *(*TDSwiftDemangleFunc)(const char *, size_t, char *, size_t *, uint32_t);
    static TDSwiftDemangleFunc demangle = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        demangle = (TDSwiftDemangleFunc)dlsym(RTLD_DEFAULT, "swift_demangle");
    });
    if (!demangle) {
        return nil;
    }

    const char *mangledCString = mangledName.UTF8String;
    if (!mangledCString) {
        return nil;
    }

    size_t outputSize = 0;
    char *output = demangle(mangledCString, strlen(mangledCString), NULL, &outputSize, 0);
    if (!output) {
        return nil;
    }

    NSString *demangled = [NSString stringWithUTF8String:output];
    free(output);
    if ([demangled isEqualToString:mangledName]) {
        return nil;
    }
    return demangled;
}

static NSString *TDLastPathComponent(NSString *qualifiedName) {
    if (qualifiedName.length == 0) {
        return nil;
    }
    NSArray<NSString *> *parts = [qualifiedName componentsSeparatedByString:@"."];
    return parts.lastObject;
}

static NSString *TDExtractBalancedGenericArgument(NSString *text, NSUInteger startIndex) {
    if (startIndex >= text.length || [text characterAtIndex:startIndex] != '<') {
        return nil;
    }

    NSInteger depth = 0;
    NSUInteger index = startIndex;
    while (index < text.length) {
        unichar character = [text characterAtIndex:index];
        if (character == '<') {
            depth++;
        } else if (character == '>') {
            depth--;
            if (depth == 0) {
                return [text substringWithRange:NSMakeRange(startIndex + 1, index - startIndex - 1)];
            }
        }
        index++;
    }
    return nil;
}

// 修复：增加递归深度上限，防止异常 demangled 字符串触发无限递归。
static NSString *TDReadableNameFromDemangledTypeWithDepth(NSString *typeName, NSUInteger depth) {
    if (depth > 20 || typeName.length == 0) {
        return nil;
    }

    NSRange genericRange = [typeName rangeOfString:@"<"];
    NSString *rootType = genericRange.location == NSNotFound ?
        typeName :
        [typeName substringToIndex:genericRange.location];
    NSString *readableName = TDLastPathComponent(rootType);

    // Treat as a transparent wrapper if:
    // 1. Name is empty or a known SwiftUI wrapper (AnyView, NavigationView, etc.)
    // 2. The fully-qualified root type is from the SwiftUI module (e.g. SwiftUI.RootView,
    //    SwiftUI.NoStyleContext, SwiftUI.SidebarStyleContext, SwiftUI.NavigationColumnModifier).
    //    These are SwiftUI-internal types; drill into their generic argument to find the
    //    user-defined view (e.g. UIHostingController<SwiftUI.RootView<UserView>> → UserView).
    BOOL isSwiftUIModuleType = [rootType hasPrefix:@"SwiftUI."];
    if (readableName.length == 0 || TDIsSwiftUIWrapperTypeName(readableName) || isSwiftUIModuleType) {
        if (genericRange.location != NSNotFound) {
            NSString *nestedType = TDExtractBalancedGenericArgument(typeName, genericRange.location);
            return TDReadableNameFromDemangledTypeWithDepth(nestedType, depth + 1);
        }
        return nil;
    }
    return readableName;
}

static NSString *TDReadableNameFromDemangledType(NSString *typeName) {
    return TDReadableNameFromDemangledTypeWithDepth(typeName, 0);
}

static NSString *TDScreenNameFromDemangledString(NSString *demangled) {
    static NSArray<NSString *> *hostingMarkers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hostingMarkers = @[
            @"UIHostingController<",
            @"PresentationHostingController<",
            @"PlatformViewController<"
        ];
    });

    for (NSString *marker in hostingMarkers) {
        NSRange markerRange = [demangled rangeOfString:marker];
        if (markerRange.location == NSNotFound) {
            continue;
        }

        NSUInteger genericStart = NSMaxRange(markerRange) - 1;
        NSString *genericArgument = TDExtractBalancedGenericArgument(demangled, genericStart);
        NSString *readableName = TDReadableNameFromDemangledType(genericArgument);
        if (readableName.length > 0) {
            return readableName;
        }
    }

    NSRange hostingRange = [demangled rangeOfString:@"HostingController"];
    if (hostingRange.location != NSNotFound) {
        return @"UIHostingController";
    }

    // For non-HostingController VCs from the SwiftUI module (e.g. SwiftUI.SidebarStyleContext),
    // return the demangled string as-is so callers can detect and skip SwiftUI internal types.
    if ([demangled hasPrefix:@"SwiftUI."]) {
        return demangled;
    }

    return TDLastPathComponent(demangled);
}

static NSString *TDParseMangledGenericType(NSString *mangled, NSUInteger *index);

static NSString *TDParseMangledNestedGenerics(NSString *mangled, NSUInteger index) {
    if (index >= mangled.length || [mangled characterAtIndex:index] != 'G') {
        return nil;
    }
    index++;
    return TDParseMangledGenericType(mangled, &index);
}

static NSString *TDParseMangledGenericType(NSString *mangled, NSUInteger *index) {
    NSUInteger cursor = *index;
    if (cursor >= mangled.length) {
        return nil;
    }

    unichar marker = [mangled characterAtIndex:cursor];

    // 修复：新增 C（class）和 O（enum）类型标记，处理逻辑与 V（struct）完全一致。
    // Swift mangling 中 V/C/O 后均跟 <module-len><module><name-len><name> 结构。
    if (marker == 'V' || marker == 'C' || marker == 'O') {
        cursor++;
        NSInteger moduleLength = TDReadMangledLength(mangled, &cursor);
        NSString *moduleName = TDSubstring(mangled, cursor, moduleLength);
        cursor += MAX(moduleLength, 0);

        NSInteger typeLength = TDReadMangledLength(mangled, &cursor);
        NSString *typeName = TDSubstring(mangled, cursor, typeLength);
        cursor += MAX(typeLength, 0);
        *index = cursor;

        if (typeName.length == 0) {
            return nil;
        }
        if (!TDIsSwiftUIWrapperTypeName(typeName) && ![moduleName isEqualToString:@"SwiftUI"]) {
            return typeName;
        }
        return TDParseMangledNestedGenerics(mangled, cursor);
    }

    // 修复：S[digits]_ 是替换引用（back-reference），指向之前已出现过的类型，
    // 无法在没有完整替换表的情况下还原，原实现错误地尝试读取 length+name。
    // 正确做法：跳过整个替换标记（S 后跟可选数字再跟 _），返回 nil 让上层 fallback。
    if (marker == 'S') {
        cursor++;
        while (cursor < mangled.length && [mangled characterAtIndex:cursor] != '_') {
            cursor++;
        }
        if (cursor < mangled.length) {
            cursor++; // 跳过结尾的 '_'
        }
        *index = cursor;
        return nil;
    }

    return nil;
}

static NSString *TDScreenNameFromMangledString(NSString *mangled) {
    NSRange hostingRange = [mangled rangeOfString:@"HostingController"];
    if (hostingRange.location == NSNotFound) {
        return nil;
    }

    NSUInteger cursor = NSMaxRange(hostingRange);
    // 修复：Swift mangling 中泛型标记 'G' 紧跟在 HostingController 之后，
    // 直接检查当前字符比 rangeOfString:@"G" 更可靠，
    // 避免模块名或类名中包含字母 'G' 时提前误匹配。
    if (cursor >= mangled.length || [mangled characterAtIndex:cursor] != 'G') {
        return @"UIHostingController";
    }
    cursor++; // 跳过 'G'

    NSString *parsedName = TDParseMangledGenericType(mangled, &cursor);
    if (parsedName.length > 0) {
        return parsedName;
    }
    return @"UIHostingController";
}

@implementation UIViewController (TDScreenName)

+ (NSString *)td_screenNameForViewController:(UIViewController *)viewController {
    if (!viewController) {
        return @"";
    }
    return [self td_screenNameForClass:[viewController class]];
}

+ (NSString *)td_screenNameForClass:(Class)viewControllerClass {
    if (!viewControllerClass) {
        return @"";
    }

    NSString *className = NSStringFromClass(viewControllerClass);
    if (className.length == 0) {
        return @"";
    }

    if (![className hasPrefix:@"_Tt"]) {
        return className;
    }

    NSString *demangled = TDSwiftDemangle(className);
    if (demangled.length > 0) {
        NSString *demangledScreenName = TDScreenNameFromDemangledString(demangled);
        if (demangledScreenName.length > 0) {
            return demangledScreenName;
        }
    }

    NSString *mangledScreenName = TDScreenNameFromMangledString(className);
    if (mangledScreenName.length > 0) {
        return mangledScreenName;
    }

    return className;
}

@end

#endif // TARGET_OS_IOS
