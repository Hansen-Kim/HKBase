//
//  HKDispatchQueue.h
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

#import "HKEnum.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapping constants use in dispatch_get_global_queue(long **"identifier"**, long flag)
    .High = DISPATCH_QUEUE_PRIORITY_HIGH
    .Default = DISPATCH_QUEUE_PRIORITY_DEFAULT
    .Low = DISPATCH_QUEUE_PRIORITY_LOW
    .Background = DISPATCH_QUEUE_PRIORITY_BACKGROUND
 */
@interface HKDispatchQueuePriority : HKEnum
@end
HKEnumDeclare(HKDispatchQueuePriority, High, Default, Low, Background)

/**
 Wrapping constants use in dispatch_queue_create(const char *name, dispatch_queue_attr_t **"attr"**)
    .Serial = DISPATCH_QUEUE_SERIAL
    .Concurrent = DISPATCH_QUEUE_CONCURRENT
 */
@interface HKDispatchQueueAttribute : HKEnum
@end
HKEnumDeclare(HKDispatchQueueAttribute, Serial, Concurrent)

/**
 dispatch_queue_t -> object
 mainQueue, globalQueueWithPriority:, queueWithName:, queueWithName:attribute: return (dispatch_queue_t)
 */
@interface HKDispatchQueue : NSObject

#pragma mark - class methods
/**
 equal with dispatch_queue_get_main_queue()
 */
@property (class, nonatomic, readonly) HKDispatchQueue *mainQueue;

/**
 equal with dispatch_get_global_queue(...)

 @param priority priorty of global queue
 @return global dispatch queue
 */
+ (instancetype)globalQueueWithPriority:(HKDispatchQueuePriority *)priority;
/**
 equal to dispatch_queue_create(...)
 == queueWithName:name attribute:HKDispatchQueueAttribute.Serial
 
 @param name name of dispatch queue
 @return created dispatch queue
 */
+ (instancetype)queueWithName:(nullable NSString *)name;
/**
 equal to dispatch_queue_create(...)

 @param name name of dispatch queue
 @param attribute attribute in (serial queue, concurrent queue)
 @return created dispatch queue
 */
+ (instancetype)queueWithName:(nullable NSString *)name attribute:(HKDispatchQueueAttribute *)attribute;

#pragma mark - instance methods

/**
 equal to dispatch_sync(...)

 @param block block to synchronus execution
 */
- (void)perform:(void(^)(void))block;
/**
 equal to dispatch_async(...)
 
 @param block block to asynchronus execution
 */
- (void)performAsync:(void(^)(void))block;

/**
 equal to dispatch_after(...)
 
 @param block block to asynchronus execution after delay
 */
- (void)perform:(void(^)(void))block afterDelay:(NSTimeInterval)delay;

/**
 equal to dispatch_apply

 @param block block to asynchronus execution iteration
 @param count iteration count
 */
- (void)perform:(void(^)(NSUInteger index))block iterationCount:(NSUInteger)count;

/**
 suspend dispatch queue
 */
- (void)suspendDispatchQueue;
/**
 resume dispatch queue
 */
- (void)resumeDispatchQueue;

@end

@interface HKDispatchQueue (Unavailable)

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
