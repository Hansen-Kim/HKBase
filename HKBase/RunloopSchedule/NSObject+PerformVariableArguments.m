//
//  NSObject+PerformVariableArguments.m
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

#import "NSObject+PerformVariableArguments.h"
#import "NSInvocation+VariableArguments.h"

@interface NSObject (PerformVarableArgumentsPrivate)

- (nullable id)HK_performInvocation:(NSInvocation *)invocation;

@end

@implementation NSObject (PerformVariableArguments)

#pragma mark - default
- (nullable id)performSelector:(SEL)selector withArgs:(va_list)args {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:selector args:args];
    [invocation retainArguments];
    
    id result = [self HK_performInvocation:invocation];
    
    return result;
}

- (void)performSelector:(SEL)selector withArgs:(va_list)args afterDelay:(NSTimeInterval)delay {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:selector args:args];
    [invocation retainArguments];
    
    [self performSelector:@selector(HK_performInvocation:)
               withObject:invocation
               afterDelay:delay];
}

- (void)performSelector:(SEL)selector withArgs:(va_list)args afterDelay:(NSTimeInterval)delay modes:(NSArray<NSRunLoopMode> *)modes {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:selector args:args];
    [invocation retainArguments];
    
    [self performSelector:@selector(HK_performInvocation:)
               withObject:invocation
               afterDelay:delay
                  inModes:modes];
}

- (id)performSelectorWithArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    id result = [self performSelector:selector withArgs:args];
    
    va_end(args);
    
    return result;
}

- (void)performSelectorAfterDelay:(NSTimeInterval)delay selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector withArgs:args afterDelay:delay];
    
    va_end(args);
}

- (void)performSelectorAfterDelay:(NSTimeInterval)delay modes:(NSArray<NSString *> *)modes selectorAndArguments:(SEL)selector, ...{
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector withArgs:args afterDelay:delay modes:modes];
    
    va_end(args);
}

#pragma mark - with thread
- (void)performSelector:(SEL)selector onThread:(NSThread *)thread withArgs:(va_list)args waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSRunLoopMode> *)modes {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:selector args:args];
    [invocation retainArguments];
    
    if (waitUntilDone && [thread isEqual:NSThread.currentThread]) {
        [self HK_performInvocation:invocation];
    } else {
        [self performSelector:@selector(HK_performInvocation:)
                     onThread:thread
                   withObject:invocation
                waitUntilDone:waitUntilDone
                        modes:modes];
    }
}

- (void)performSelectorOnThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector
                 onThread:thread
                 withArgs:args
            waitUntilDone:waitUntilDone
                    modes:@[(__bridge NSRunLoopMode)kCFRunLoopCommonModes]];
    
    va_end(args);
}

- (void)performSelectorOnThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSString *> *)modes selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector
                 onThread:thread
                 withArgs:args
            waitUntilDone:waitUntilDone
                    modes:modes];
    
    va_end(args);
}

- (void)performSelectorOnMainThreadWithWaitUntilDone:(BOOL)waitUntilDone selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector
                 onThread:NSThread.mainThread
                 withArgs:args
            waitUntilDone:waitUntilDone
                    modes:@[(__bridge NSString*)kCFRunLoopCommonModes]];
    
    va_end(args);
}

- (void)performSelectorOnMainThreadWithWaitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSRunLoopMode> *)modes selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector
                 onThread:NSThread.mainThread
                 withArgs:args
            waitUntilDone:waitUntilDone
                    modes:modes];
    
    va_end(args);
}

- (void)performSelectorInBackground:(SEL)selector withArgs:(va_list)args {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:selector args:args];
    [invocation retainArguments];
    
    [self performSelectorInBackground:@selector(HK_performInvocation:)
                           withObject:invocation];
}

- (void)performSelectorInBackgroundWithArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelectorInBackground:selector withArgs:args];
    
    va_end(args);
}

@end

@implementation NSRunLoop (PerformSelectorVarableArguments)

- (void)performSelector:(SEL)selector target:(id)target args:(va_list)args order:(NSUInteger)order modes:(NSArray<NSRunLoopMode> *)modes {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target
                                                         selector:selector
                                                             args:args];
    [invocation retainArguments];
    
    [self performSelector:@selector(HK_performInvocation:)
                   target:target
                 argument:invocation
                    order:order
                    modes:modes];
}

- (void)performSelectorWithTarget:(id)target order:(NSUInteger)order modes:(NSArray<NSRunLoopMode> *)modes selectorAndArguments:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    
    [self performSelector:selector
                   target:target
                     args:args
                    order:order
                    modes:modes];
    
    va_end(args);
}

@end

@implementation NSObject (PerformVarableArgumentsPrivate)

- (nullable id)HK_performInvocation:(NSInvocation *)invocation {
    id result = nil;
    [invocation invoke];
    
    if (invocation.methodSignature.methodReturnType[0] == '@') {
        [invocation getReturnValue:(void*)&result];
    }
    
    return result;
}

@end
