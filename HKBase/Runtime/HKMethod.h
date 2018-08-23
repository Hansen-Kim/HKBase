//
//  HKMethod.h
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
 Extend Methods in run time
 cf. Method in objc/runtime.h
 */
@interface HKMethod : NSObject

/**
 Method's name
 */
@property (nonatomic, readonly) SEL selector;
/**
 Method signature's objCType
 */
@property (nonatomic, readonly) const char *objCType;
/**
 Method's IMP
 */
@property (nonatomic, readonly) IMP implementation;

/**
 New Method by Function

 @param selector method's name
 @param implementation Method's Implementation by Function
 @param objCType Method's ObjCType
 @return New Methods
 */
+ (instancetype)methodWithSelector:(SEL)selector implementation:(IMP)implementation objCType:(const char *)objCType;
/**
 New Method by Block Handler
 
 @param selector method's name
 @param block Method's Implementation by Block
 @return New Methods
 */
+ (instancetype)methodWithSelector:(SEL)selector block:(id)block; // block ==> returnType^(block)(id self, ...)

/**
 Class Method

 @param aClass class
 @param selector method's name
 @return class method
 */
+ (nullable instancetype)classMethodWithClass:(__unsafe_unretained Class)aClass selector:(SEL)selector;
/**
 Instance Method

 @param aClass class
 @param selector method's name
 @return instance method
 */
+ (nullable instancetype)instanceMethodWithClass:(__unsafe_unretained Class)aClass selector:(SEL)selector;

@end

@interface NSObject (HKMethod)

/**
 all class methods
 */
@property (class, nonatomic, nullable, readonly) NSArray<HKMethod *> *classMethods;
/**
 all instance methods
 */
@property (class, nonatomic, nullable, readonly) NSArray<HKMethod *> *instanceMethods;

/**
 add or replace (if method exists) class method

 @param method method for replace
 @return previous method's IMP (if exists)
 */
+ (nullable IMP)replaceClassMethod:(HKMethod *)method; // add or replace
/**
 add or replace (if method exists) instance method
 
 @param method method for replace
 @return previous method's IMP (if exists)
 */
+ (nullable IMP)replaceInstanceMethod:(HKMethod *)method; // add or replace

@end

NS_ASSUME_NONNULL_END
