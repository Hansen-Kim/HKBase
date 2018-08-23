//
//  NSInvocation+VariableArguments.m
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

#import "NSInvocation+VariableArguments.h"

@implementation NSInvocation (VariableArguments)

+ (instancetype)invocationWithTarget:(id)target selector:(SEL)selector args:(va_list)args {
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *result = [self invocationWithMethodSignature:signature];
    
    result.target = target;
    result.selector = selector;
    
#if __x86_64__
    for (NSUInteger index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        
        if (strcmp(type, @encode(float)) && strcmp(type, @encode(double))) {
            if (type[0] != '@' && type[0] != '^' && type[0] != '*' &&
                strcmp(type, @encode(long)) && strcmp(type, @encode(unsigned long)) &&
                strcmp(type, @encode(int)) && strcmp(type, @encode(unsigned int)) &&
                strcmp(type, @encode(short)) && strcmp(type, @encode(unsigned short)) &&
                strcmp(type, @encode(char)) && strcmp(type, @encode(unsigned char))) {
                NSUInteger size = 0;
                NSGetSizeAndAlignment(type, &size, NULL);
                [result setArgument:args->overflow_arg_area atIndex:index];
                args->overflow_arg_area += size;
            } else {
                void *arg = NULL;
                if (args->gp_offset < (6 * 8)) {
                    arg = args->reg_save_area + args->gp_offset;
                    args->gp_offset += 8;
                } else {
                    arg = args->overflow_arg_area;
                    args->overflow_arg_area += 8;
                }
                
                [result setArgument:arg atIndex:index];
            }
        } else {
            void *arg = NULL;
            
            if (args->fp_offset < ( 6 * 8 + 16 * 16 )) {
                arg = args->reg_save_area + args->fp_offset;
                args->fp_offset += 16;
            } else {
                arg = args->overflow_arg_area;
                args->overflow_arg_area += 16;
            }
            
            if (!strcmp(type, @encode(float))) {
                float value = *(double*)arg;
                [result setArgument:(void*)&value atIndex:index];
            } else {
                [result setArgument:arg atIndex:index];
            }
        }
    }
#else
    void *arg = (void *)args;
    
    for (NSUInteger index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        
        NSUInteger size = 0, align = 0;
        NSGetSizeAndAlignment(type, &size, &align);
        
        NSUInteger mod = (NSUInteger)arg % align;
        arg += mod > 0 ? (align - mod) : 0;
        
        if (strcmp(type, @encode(float))) {
            [result setArgument:arg atIndex:index];
        } else {
            float value = *(double *)arg;
            [result setArgument:(void *)&value atIndex:index];
            size = sizeof(double);
        }
        
        arg += size;
    }
#endif
    
    return result;
}

+ (instancetype)invocationWithTarget:(id)target selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    NSInvocation *result = [self invocationWithTarget:target selector:selector args:args];
    va_end(args);
    
    return result;
}

@end
