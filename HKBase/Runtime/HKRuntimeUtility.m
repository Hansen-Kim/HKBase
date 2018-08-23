//
//  HKRuntimeUtility.m
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

#import "HKRuntimeUtility.h"
#import "HKProperty.h"
#import <objc/runtime.h>

typedef struct _HKBlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
} HKBlockDescriptor;


typedef struct _HKBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    HKBlockDescriptor *descriptor;
} HKBlock;


typedef NS_ENUM(int, HKBlockFlag) {
    HKBlockFlagHasCopyDispose =       1 << 25,
    HKBlockFlagHasCTOR =              1 << 26,
    HKBlockFlagIsGlobal =             1 << 28,
    HKBlockFlagHasSTRET =             1 << 29,
    HKBlockFlagHasSignature =         1 << 30,
};

static const char *HKGetBlockObjCType(id block) {
    const char *result = NULL;
    if (block != nil) {
        HKBlock *info = (__bridge HKBlock *)block;
        int index = info->flags & HKBlockFlagHasCopyDispose ? 2 : 0;
        
        result = info->descriptor->rest[index];
    }
    return result;
}

static const char *HKRemoveWrongObjCType(const char *objCType) {
    const char *result = NULL;
    if (objCType) {
        NSMutableString *string = [NSMutableString stringWithUTF8String:objCType];
        NSRange search = NSMakeRange(0, string.length);
        
        while (YES) {
            NSRange range = [string rangeOfString:@"\"" options:0 range:search];
            if (range.location == NSNotFound) {
                break;
            }
            
            NSRange delete = range;
            search.location = NSMaxRange(range);
            search.length = [string length] - search.location;
            
            range = [string rangeOfString:@"\"" options:0 range:search];
            
            if (range.location == NSNotFound) {
                break;
            } else {
                delete.length = range.location - delete.location + 1;
                [string deleteCharactersInRange:delete];
            }
            
            search.location = range.location - delete.length + 1;
            search.length = [string length] - search.location;
        }
        
        result = string.UTF8String;
    }
    
    return result;
}

static const char *HKConvertCurrentObjCType(const char *objCType) {
    if (objCType != NULL) {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:objCType];
        return signature.methodObjCType;
    }
    return NULL;
}

const char *HKMakeObjcTypeString(const char *returnType, ...) {
    va_list args;
    va_start(args, returnType);
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"%s@:", returnType];
    const char *argumentType = NULL;
    while ((argumentType = va_arg(args, const char *))) {
        [result appendFormat:@"%s", argumentType];
    }
    va_end(args);
    
    return result.UTF8String;
}

IMP HKGetBlockImplementation(id block, const char * _Nullable * _Nonnull objCType) {
    *objCType = HKConvertCurrentObjCType(HKRemoveWrongObjCType(HKGetBlockObjCType(block)));
    return imp_implementationWithBlock(block);
}

BOOL HKIsPropertyNumberSupport(HKProperty *property) {
    static const char *supportedCTypes[] = {
        @encode(BOOL), @encode(bool),
        @encode(char), @encode(unsigned char),
        @encode(short), @encode(unsigned short),
        @encode(int), @encode(unsigned int),
        @encode(long), @encode(unsigned long),
        @encode(long long), @encode(unsigned long long),
        @encode(float), @encode(double),
    };
    static const NSInteger numberOfSupportedCTypes = sizeof(supportedCTypes) / sizeof(supportedCTypes[0]);
    
    BOOL result = NO;
    const char *objCType = property.objCType;
    
    for (NSInteger index = 0; index < numberOfSupportedCTypes; index++) {
        if (strcmp(objCType, supportedCTypes[index]) == 0) {
            result = YES;
            break;
        }
    }
    
    return result;
}

BOOL HKIsSupportedProperty(HKProperty *property) {
    switch (property.objCType[0]) {
        case '[':
        case '(':
        case '#':
        case ':':
        case '^':
        case 'b':
        case '?':
            return NO;
        default:
            return YES;
    }
}

@implementation NSMethodSignature (RuntimeUtility)

@dynamic methodObjCType;

- (const char *)methodObjCType {
    NSMutableString *result = [NSMutableString stringWithFormat:@"%s@:", self.methodReturnType];
    
    for (NSInteger index = 2; index < [self numberOfArguments]; index++) {
        [result appendFormat:@"%s", [self getArgumentTypeAtIndex:index]];
    }
    
    return result.UTF8String;
}

@end
