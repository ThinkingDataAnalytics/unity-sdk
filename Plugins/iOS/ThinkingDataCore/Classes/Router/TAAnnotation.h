//
//  TAAnnotation.h
//  Pods
//
//  Created by wwango on 2022/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef ThinkingModSectName

#define ThinkingModSectName "ThinkingMods"

#endif

#ifndef ThinkingServiceSectName

#define ThinkingServiceSectName "ThinkingServices"

#endif


#define ThinkingDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))


#define ThinkingMod(name) \
char * k##name##_mod ThinkingDATA(ThinkingMods) = ""#name"";

#define ThinkingService(servicename,impl) \
char * k##servicename##_service ThinkingDATA(ThinkingServices) = "{ \""#servicename"\" : \""#impl"\"}";

@interface TAAnnotation : NSObject

@end

NS_ASSUME_NONNULL_END
