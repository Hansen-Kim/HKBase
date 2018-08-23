//
//  NSObject+PerformBlock.h
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

@interface NSObject (PerformBlock)

#pragma mark - default
/**
 perform block execution after delay

 @param block block hander for execution
 @param delay after delay
 @return token to cancel
 */
+ (id)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay;
/**
 perform block execution after delay with runloop mode
 
 @param block block hander for execution
 @param delay after delay
 @param modes runloopmode
 @return token to cancel
 */
+ (id)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay inModes:(NSArray<NSString *> *)modes;

#pragma mark - with thread
/**
 perform block execution on main thread

 @param block block hander for execution
 @param waitUntilDone wait until method execution done
 @param modes runloopmode
 @return token to cancel
 */
+ (id)performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSString *> *)modes;
/**
 perform block execution on main thread with runloop mode
 
 @param block block hander for execution
 @param waitUntilDone wait until method execution done
 @return token to cancel
 */
+ (id)performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)waitUntilDone;

/**
 perform block execution on thread with runloop mode

 @param block block hander for execution
 @param thread thread on execution
 @param waitUntilDone wait until method execution done
 @param modes runloopmode
 @return token to cancel
 */
+ (id)performBlock:(void(^)(void))block onThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSString *> *)modes;
/**
 perform block execution on thread
 
 @param block block hander for execution
 @param thread thread on execution
 @param waitUntilDone wait until method execution done
 @return token to cancel
 */
+ (id)performBlock:(void(^)(void))block onThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone;

/**
 perform block in background

 @param block block hander for execution
 @return token to cancel
 */
+ (id)performBlockInBackground:(void (^)(void))block;

@end

@interface NSRunLoop (PerformBlock)

/**
 schedule to perform blcok execution in runloop

 @param block block hander for execution
 @param order schedule order
 @param modes runloopmode
 @return token to cancel
 */
- (id)performBlock:(void(^)(void))block order:(NSUInteger)order modes:(NSArray<NSString *> *)modes;

@end

NS_ASSUME_NONNULL_END
