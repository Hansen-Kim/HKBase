//
//  HKInstanceVariable.m
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

#import "HKInstanceVariable.h"
#import <objc/runtime.h>

@interface HKInstanceVariable () {
    NSString *_objCType;
    
    @package
    __unsafe_unretained Class _class;
    ptrdiff_t _offset;
}

- (instancetype)initWithClass:(__unsafe_unretained Class)class variable:(Ivar)variable;

@end

@implementation HKInstanceVariable

+ (instancetype)instanceVariableWithClass:(__unsafe_unretained Class)class name:(NSString *)name {
    Ivar variable = class_getInstanceVariable(class, name.UTF8String);
    return variable ? [[self alloc] initWithClass:class variable:variable] : nil;
}

- (instancetype)initWithClass:(__unsafe_unretained Class)class variable:(Ivar)variable {
    self = [super init];
    if (self) {
        _class = class;
        _name = [NSString stringWithUTF8String:ivar_getName(variable)];
        _objCType = [NSString stringWithUTF8String:ivar_getTypeEncoding(variable)];
        _offset = ivar_getOffset(variable);
    }
    return self;
}

#pragma mark - properties
@dynamic objCType;

- (const char *)objCType {
    return _objCType.UTF8String;
}

@end

@implementation NSObject (HKInstanceVariable)

@dynamic instanceVariables;

+ (NSArray<HKInstanceVariable *> *)instanceVariables {
    unsigned int count = 0;
    Ivar *variableList = class_copyIvarList(self, &count);
    
    NSArray<HKInstanceVariable *> *result = nil;
    if (count) {
        NSMutableArray<HKInstanceVariable *> *variables = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int index = 0; index < count; index++) {
            [variables addObject:[[HKInstanceVariable alloc] initWithClass:self variable:variableList[index]]];
        }
        result = variables;
    }
    return result;
}

static void * _Nullable HKGetInstanceVariablePointer(id self, HKInstanceVariable *instanceVariable) {
    void *result = NULL;
    if ([self isKindOfClass:instanceVariable->_class]) {
        result = (__bridge void *)self + instanceVariable->_offset;
    }
    return result;
}

- (void)setValue:(void *)value forInstanceVariable:(HKInstanceVariable *)instanceVariable {
    void *pointer = HKGetInstanceVariablePointer(self, instanceVariable);
    if (pointer) {
        NSUInteger size = 0;
        NSGetSizeAndAlignment(instanceVariable.objCType, &size, NULL);
        
        memcpy(pointer, value, (size_t)size);
    }
}

- (void)getValue:(void *)value forInstanceVariable:(HKInstanceVariable *)instanceVariable {
    void *pointer = HKGetInstanceVariablePointer(self, instanceVariable);
    if (pointer) {
        NSUInteger size = 0;
        NSGetSizeAndAlignment(instanceVariable.objCType, &size, NULL);

        memcpy(value, pointer, (size_t)size);
    }
}

@end
