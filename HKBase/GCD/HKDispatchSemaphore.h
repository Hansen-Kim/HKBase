//
//  HKDispatchSemaphore.h
//	Create on 2018. 8. 23.
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

/**
 dispatch_semaphore_t -> object
 semaphoreWithValue: return (dispatch_semaphore_t)
*/
@interface HKDispatchSemaphore : NSObject

/**
 equal with dispatch_semaphore_create(...)
 
 @param value starting value
 @return dispatch semaphore
 */
+ (instancetype)semaphoreWithValue:(NSInteger)value;


/**
 equal with dispatch_semaphore_wait(...) forever
 */
- (void)wait;
/**
 equal with dispatch_semaphore_wait(...)

 @param timeout waiting timeout
 */
- (void)waitWithTimeout:(NSTimeInterval)timeout;
/**
 equal with dispatch_semaphore_signal(...)
 */
- (void)signal;

@end

@interface HKDispatchSemaphore (Unavailable)

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
