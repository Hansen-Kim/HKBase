//
//  HKDispatchQueue.m
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

#import "HKDispatchQueue.h"

static const void *kHKDispatchQueueSpecificKey = &kHKDispatchQueueSpecificKey;

static HKDispatchQueue *HKDispatchQueueMakeSpecific(dispatch_queue_t queue) {
    if (!dispatch_queue_get_specific(queue, kHKDispatchQueueSpecificKey)) {
        dispatch_queue_set_specific(queue, kHKDispatchQueueSpecificKey, &queue, NULL);
    }
    return (id)queue;
}

static BOOL HKDispatchQueueIsCurrentQueue(dispatch_queue_t queue) {
    return dispatch_get_specific(kHKDispatchQueueSpecificKey) == dispatch_queue_get_specific(queue, kHKDispatchQueueSpecificKey);
}

@implementation HKDispatchQueuePriority
@end
HKEnumImplementation(HKDispatchQueuePriority, High, Default, Low, Background)
HKEnumRegisterValues(HKDispatchQueuePriority, DISPATCH_QUEUE_PRIORITY_HIGH, DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_PRIORITY_LOW, DISPATCH_QUEUE_PRIORITY_BACKGROUND)

@interface HKDispatchQueueAttribute ()
@property (nonatomic, readonly) dispatch_queue_attr_t attribute;
@end
@implementation HKDispatchQueueAttribute
@dynamic attribute;
- (dispatch_queue_attr_t)attribute {
    return (__bridge dispatch_queue_attr_t)((void *)self.value);
}
@end
HKEnumImplementation(HKDispatchQueueAttribute, Serial, Concurrent)
HKEnumRegisterValues(HKDispatchQueueAttribute, (NSInteger)DISPATCH_QUEUE_SERIAL, (NSInteger)DISPATCH_QUEUE_CONCURRENT);

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation HKDispatchQueue

@dynamic mainQueue;
+ (instancetype)mainQueue {
    return HKDispatchQueueMakeSpecific(dispatch_get_main_queue());
}

+ (instancetype)globalQueueWithPriority:(HKDispatchQueuePriority *)priority {
    return HKDispatchQueueMakeSpecific(dispatch_get_global_queue((long)priority.value, 0));
}

+ (instancetype)queueWithName:(NSString *)name {
    return [self queueWithName:name attribute:HKDispatchQueueAttribute.Serial];
}

+ (instancetype)queueWithName:(NSString *)name attribute:(HKDispatchQueueAttribute *)attribute {
    return HKDispatchQueueMakeSpecific(dispatch_queue_create(name.UTF8String, attribute.attribute));
}

@end

#pragma GCC disgnostic pop

@implementation NSObject (HKDispatchQueue)

- (dispatch_queue_t)HK_dispatchQueue {
    return (dispatch_queue_t)self;
}

- (void)perform:(void(^)(void))block {
    HKDispatchQueueIsCurrentQueue(self.HK_dispatchQueue) ? block() : dispatch_sync(self.HK_dispatchQueue, block);
}

- (void)performAsync:(void(^)(void))block {
    dispatch_async(self.HK_dispatchQueue, block);
}

- (void)perform:(void(^)(void))block afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.HK_dispatchQueue, block);
}

- (void)perform:(void(^)(NSUInteger index))block iterationCount:(NSUInteger)count {
    dispatch_apply((size_t)count, self.HK_dispatchQueue, (void(^)(size_t))block);
}

- (void)suspendDispatchQueue {
    dispatch_suspend(self.HK_dispatchQueue);
}

- (void)resumeDispatchQueue {
    dispatch_resume(self.HK_dispatchQueue);
}

@end
