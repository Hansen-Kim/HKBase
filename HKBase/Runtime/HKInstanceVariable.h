//
//  HKInstanceVariable.h
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
 Extend InstanceVariable
 cf. Ivar in objc/runtime.h
 */
@interface HKInstanceVariable : NSObject

/**
 instance variable's name
 */
@property (nonatomic, readonly) NSString *name;
/**
 instance variable's objCType
 */
@property (nonatomic, readonly) const char *objCType;

/**
 class's instance variable of name

 @param aClass class
 @param name instance variable name
 @return instance variable
 */
+ (instancetype)instanceVariableWithClass:(__unsafe_unretained Class)aClass name:(NSString *)name;

@end

@interface NSObject (HKInstanceVariable)

/**
 all instance variable of class
 */
@property (class, nonatomic, nullable, readonly) NSArray<HKInstanceVariable *> *instanceVariables;

/**
 set object to instance variable

 @param value value for set to instance variable (pointer)
 @param instanceVariable instance variable for key (like setValue:forKey:'s key)
 */
- (void)setValue:(void *)value forInstanceVariable:(HKInstanceVariable *)instanceVariable;
/**
 object of instance variable
 
 @param value out value (pointer)
 @param instanceVariable instanceVariable for key (like valueForKey:'s key)
 */
- (void)getValue:(void *)value forInstanceVariable:(HKInstanceVariable *)instanceVariable;

@end

NS_ASSUME_NONNULL_END
