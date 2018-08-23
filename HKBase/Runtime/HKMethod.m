//
//  HKMethod.m
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

#import "HKMethod.h"
#import "HKRuntimeUtility.h"
#import <objc/runtime.h>

@interface HKMethod () {
    NSString *_objCType;
}

- (instancetype)initWithSelector:(SEL)selector implementation:(IMP)implementation objCType:(const char *)objCType;
- (instancetype)initWithMethod:(Method)method;

@end

@implementation HKMethod

+ (instancetype)methodWithSelector:(SEL)selector implementation:(IMP)implementation objCType:(const char *)objCType {
    return [[self alloc] initWithSelector:selector implementation:implementation objCType:objCType];
}

+ (instancetype)methodWithSelector:(SEL)selector block:(id)block {
    const char *objCType = NULL;
    IMP implementation = HKGetBlockImplementation(block, &objCType);
    return [self methodWithSelector:selector implementation:implementation objCType:objCType];
}
    
- (instancetype)initWithSelector:(SEL)selector implementation:(IMP)implementation objCType:(const char *)objCType {
    self = [super init];
    if (self) {
        _selector = selector;
        _implementation = implementation;
        _objCType = [NSString stringWithUTF8String:objCType];
    }
    return self;
}

- (instancetype)initWithMethod:(Method)method {
    self = [super init];
    if (self) {
        _selector = method_getName(method);
        _implementation = method_getImplementation(method);
        _objCType = [NSString stringWithUTF8String:method_getTypeEncoding(method)];
    }
    return self;
}

+ (instancetype)classMethodWithClass:(__unsafe_unretained Class)class selector:(SEL)selector {
    Method method = class_getClassMethod(class, selector);
    return method ? [[self alloc] initWithMethod:method] : nil;
}

+ (instancetype)instanceMethodWithClass:(__unsafe_unretained Class)class selector:(SEL)selector {
    Method method = class_getInstanceMethod(class, selector);
    return method ? [[self alloc] initWithMethod:method] : nil;
}

#pragma mark - properties

@dynamic objCType;

- (const char *)objCType {
    return _objCType.UTF8String;
}

@end


@implementation NSObject (HKMethod)

@dynamic classMethods;
@dynamic instanceMethods;

static NSArray<HKMethod *> * _Nullable HKGetMethods(__unsafe_unretained Class class) {
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(class, &count);
    
    NSArray<HKMethod *> *result = nil;
    if (count) {
        NSMutableArray<HKMethod *> *methods = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int index = 0; index < count; index++) {
            [methods addObject:[[HKMethod alloc] initWithMethod:methodList[index]]];
        }
        result = methods;
    }
    methodList ? free(methodList) : nil;

    return result;
}

+ (nullable NSArray<HKMethod *> *)classMethods {
    return HKGetMethods(objc_getMetaClass(class_getName(self)));
}

+ (nullable NSArray<HKMethod *> *)instanceMethods {
    return HKGetMethods(self);
}

+ (nullable IMP)replaceClassMethod:(HKMethod *)method {
    IMP result = NULL;
    Class metaclass = objc_getMetaClass(class_getName(self));
    
    result = class_replaceMethod(metaclass, method.selector, method.implementation, method.objCType);
    Class class = self.superclass;
    while (!result) {
        metaclass = objc_getMetaClass(class_getName(class));
        result = class_getMethodImplementation(metaclass, method.selector);
        class = class.superclass;
        if (!class) {
            break;
        }
    }
    
    return result;
}

+ (nullable IMP)replaceInstanceMethod:(HKMethod *)method {
    IMP result = NULL;
    result = class_replaceMethod(self, method.selector, method.implementation, method.objCType);
    Class class = self.superclass;
    while (!result) {
        result = class_getMethodImplementation(class, method.selector);
        class = class.superclass;
        if (!class) {
            break;
        }
    }
    
    return result;
}

@end
