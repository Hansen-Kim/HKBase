//
//  NSObject+PerformVariableArguments.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 perform selector with various arguments
 */
@interface NSObject (PerformVariableArguments)

#pragma mark - default
/**
 base method of performSelector:withObject: with various arguments (va_list)

 @param selector selector for execution
 @param args vaious arguments
 @return result of methods
 */
- (__nullable id)performSelector:(SEL)selector withArgs:(va_list)args;
/**
 performSelector:withObject:afterDelay: with various arguments (va_list)

 @param selector selector for execution
 @param args vaious arguments
 @param delay delay to execution
 */
- (void)performSelector:(SEL)selector withArgs:(va_list)args afterDelay:(NSTimeInterval)delay;
/**
 performSelector:withObject:afterDelay:modes: with various arguments (va_list)

 @param selector selector for execution
 @param args vaious arguments
 @param delay delay to execution
 @param modes runloopmode
 */
- (void)performSelector:(SEL)selector withArgs:(va_list)args afterDelay:(NSTimeInterval)delay modes:(NSArray<NSRunLoopMode> *)modes;

/**
 base method of performSelector:withObject: with various arguments
 
 @param selector selector for execution
 @param ... vaious arguments
 @return result of methods
 */
- (__nullable id)performSelectorWithArguments:(SEL)selector, ...;
/**
 performSelector:withObject:afterDelay: with various arguments
 
 @param delay delay to execution
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorAfterDelay:(NSTimeInterval)delay selectorAndArguments:(SEL)selector, ...;
/**
 performSelector:withObject:afterDelay:modes: with various arguments
 
 @param delay delay to execution
 @param modes runloopmode
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorAfterDelay:(NSTimeInterval)delay modes:(NSArray<NSRunLoopMode> *)modes selectorAndArguments:(SEL)selector, ...;

#pragma mark - with thread
/**
 performSelector:onThread:withObject:waitUntilDone:modes: with various arguments (va_list)

 @param selector selector for execution
 @param thread thread on execution
 @param args vaious arguments
 @param waitUntilDone wait until method execution done
 @param modes runloopmode
 */
- (void)performSelector:(SEL)selector onThread:(NSThread *)thread withArgs:(va_list)args waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSRunLoopMode> *)modes;

/**
 performSelector:onThread:withObject:waitUntilDone: with various arguments
 
 @param thread thread on execution
 @param waitUntilDone wait until method execution done
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorOnThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone selectorAndArguments:(SEL)selector, ...;
/**
 performSelector:onThread:withObject:waitUntilDone:modes: with various arguments
 
 @param thread thread on execution
 @param waitUntilDone wait until method execution done
 @param selector selector for execution
 @param modes runloopmode
 @param ... vaious arguments
 */
- (void)performSelectorOnThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSRunLoopMode> *)modes selectorAndArguments:(SEL)selector, ...;

/**
 performSelectorOnMainThread:withObject:waitUntilDone: with various arguments
 
 @param waitUntilDone wait until method execution done
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorOnMainThreadWithWaitUntilDone:(BOOL)waitUntilDone selectorAndArguments:(SEL)selector, ...;
/**
 performSelectorOnMainThread:withObject:waitUntilDone:modes: with various arguments
 
 @param waitUntilDone wait until method execution done
 @param selector selector for execution
 @param modes runloopmode
 @param ... vaious arguments
 */
- (void)performSelectorOnMainThreadWithWaitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSRunLoopMode> *)modes selectorAndArguments:(SEL)selector, ...;

/**
 performSelectorInBackground:withObject: with various arguments (va_list)
 
 @param selector selector for execution
 @param args vaious arguments
 */
- (void)performSelectorInBackground:(SEL)selector withArgs:(va_list)args;
/**
 performSelectorInBackground:withObject: with various arguments
 
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorInBackgroundWithArguments:(SEL)selector, ...;

@end

@interface NSRunLoop (PerformVariableArguments)

/**
 performSelector:target:argument:order:modes: with various arguments (va_list)

 @param selector selector for execution
 @param target execution target
 @param args vaious arguments
 @param order schedule order
 @param modes runloopmode
 */
- (void)performSelector:(SEL)selector target:(id)target args:(va_list)args order:(NSUInteger)order modes:(NSArray<NSRunLoopMode> *)modes;
/**
 performSelector:target:argument:order:modes: with various arguments (va_list)
 
 @param target execution target
 @param order schedule order
 @param modes runloopmode
 @param selector selector for execution
 @param ... vaious arguments
 */
- (void)performSelectorWithTarget:(id)target order:(NSUInteger)order modes:(NSArray<NSRunLoopMode>*)modes selectorAndArguments:(SEL)selector, ...;

@end

NS_ASSUME_NONNULL_END
