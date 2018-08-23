//
//  HKClass.m
//
//  Copyright © 2018 Hansen Kim ( https://hansenkim.blogspot.com )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HKClass.h"
#import "HKRuntimeUtility.h"
#import <objc/runtime.h>

static BOOL isRuntimeClass(__unused id self, __unused SEL _cmd) {
    return YES;
}

@implementation NSObject (HKClass)

@dynamic runtimeClass;
+ (BOOL)isRuntimeClass {
    return NO;
}

+ (__unsafe_unretained __nullable Class)registerSubclassFromSuperClass:(__unsafe_unretained Class)superclass className:(NSString *)className extend:(void (^)(__unsafe_unretained Class subclass))extend {
    const char *name = className.UTF8String;
    
    Class result = objc_getClass(name);
    if (result) {
        return [result isSubclassOfClass:superclass] ? result : NULL;
    }
    
    result = objc_allocateClassPair(superclass, name, 0);
    if (result) {
        objc_registerClassPair(result);
        
        class_replaceMethod(objc_getMetaClass(name), @selector(isRuntimeClass), (IMP)isRuntimeClass, HKMakeObjcTypeString(@encode(BOOL), NULL));
        extend ? extend(result) : nil;
    }
    
    return result;
}

+ (__unsafe_unretained __nullable Class)registerSubclassWithClassName:(NSString *)className extend:(nullable void(^)(__unsafe_unretained Class subclass))extend {
    return [self registerSubclassFromSuperClass:self className:className extend:extend];
}

- (BOOL)subclassingWithClass:(__unsafe_unretained Class)subclass {
    Class class = self.class;
    return [subclass isSubclassOfClass:class] && (class == object_setClass(self, subclass));
}

- (BOOL)restoreToSuperclass {
    Class class = self.class;
    return [class isRuntimeClass] && (class == object_setClass(self, class.superclass));
}

@end
