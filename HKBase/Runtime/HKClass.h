//
//  HKClass.h
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
 Class Extend Utility in runtime
 */
@interface NSObject (HKClass)

/**
 is Extened in runtime class
 */
@property (class, nonatomic, readonly, getter=isRuntimeClass) BOOL runtimeClass;

/**
 Subclassing class
 example >
 [class registerSubclassFromSuperClass:NSObject.class className:@"HKObject" extend:^(Class subclass) {
    HKMethod *method = [HKMethod methodWithSelector:@selector(method:) block:^(id self, id arg) {
        NSLog(@"method extend");
    }];
    [subclass replaceInstanceMethod:method];
 }];

 @param superclass class for subclassing
 @param className new class name
 @param extend block for subclass extend
 @return subclassed class
 */
+ (__unsafe_unretained __nullable Class)registerSubclassFromSuperClass:(__unsafe_unretained Class)superclass className:(NSString *)className extend:(void (^)(__unsafe_unretained Class subclass))extend;
/**
 Subclassing class
 equal [class registerSubclassFromSuperClass:self className:className extend:extend];

 @param className new class name
 @param extend block for subclass extend
 @return subclassed class
 */
+ (__unsafe_unretained __nullable Class)registerSubclassWithClassName:(NSString *)className extend:(nullable void(^)(__unsafe_unretained Class subclass))extend;

/**
 subclassing self to subclass

 @param subclass class to subclassing
 @return success
 */
- (BOOL)subclassingWithClass:(__unsafe_unretained Class)subclass;
/**
 restore to super class

 @return success
 */
- (BOOL)restoreToSuperclass;

@end

NS_ASSUME_NONNULL_END
