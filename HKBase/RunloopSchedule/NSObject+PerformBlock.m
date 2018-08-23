//
//  NSObject+PerformBlock.m
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

#import "NSObject+PerformBlock.h"

@interface NSObject (PerformBlockPrivate)

- (void)HK_performBlock;

@end

@implementation NSObject (PerformBlock)

#pragma mark - default
+ (id)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay {
    [(id)block performSelector:@selector(HK_performBlock) withObject:nil afterDelay:delay];
    
    return block;
}

+ (id)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay inModes:(NSArray<NSString *> *)modes {
    [(id)block performSelector:@selector(HK_performBlock) withObject:nil afterDelay:delay inModes:modes];
    
    return block;
}

#pragma mark - with thread
+ (id)performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSString *> *)modes {
    return [self performBlock:block onThread:NSThread.mainThread waitUntilDone:waitUntilDone modes:modes];
}

+ (id)performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)waitUntilDone {
    return [self performBlock:block onThread:NSThread.mainThread waitUntilDone:waitUntilDone];
}

+ (id)performBlock:(void(^)(void))block onThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone modes:(NSArray<NSString *> *)modes {
    if (waitUntilDone && [thread isEqual:[NSThread currentThread]]) {
        block();
    } else {
        [(id)block performSelector:@selector(HK_performBlock) onThread:thread
                        withObject:nil waitUntilDone:waitUntilDone modes:modes];
    }
    
    return block;
}

+ (id)performBlock:(void(^)(void))block onThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone {
    return [self performBlock:block onThread:thread
                waitUntilDone:waitUntilDone modes:@[(__bridge NSString *)kCFRunLoopCommonModes]];
}

+ (id)performBlockInBackground:(void (^)(void))block {
    [(id)block performSelectorInBackground:@selector(HK_performBlock) withObject:nil];
    
    return block;
}

@end

@implementation NSRunLoop (PerformBlock)

- (id)performBlock:(void(^)(void))block order:(NSUInteger)order modes:(NSArray<NSString *> *)modes {
    [self performSelector:@selector(HK_performBlock) target:(id)block argument:nil order:order modes:modes];
    
    return block;
}

@end


@implementation NSObject (PerformBlockPrivate)

- (void)HK_performBlock {
    void(^block)(void) = (void(^)(void))self;
    
    block();
}

@end
