//
//  HKArray.h
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
 Parse array to model array automaticaly
 use in HKModel
 
 declare with HKArrayDeclare(ObjectType) and HKArrayImplementation(ObjectType)
 if allocating this class will return an NSMutableArray
 */
@interface HKArray<ObjectType> : NSMutableArray<ObjectType>

/**
 Class of ObjectType
 */
@property (class, nonatomic, unsafe_unretained, readonly) Class objectClass;

@end

NS_ASSUME_NONNULL_END

/**
 Use HKArray(ObjectType) instead of NSArray<ObjectType *> for parse

 @param className class into place array
 @return Array class
 */
#define HKArray(className)  className ## Array

/**
 Declare Array for parse
 declare HKArrayDeclare(ObjectType) first to use HKArray(ObjectType)

 @param className class into place array
*/
#define HKArrayDeclare(className) \
@class className; \
@interface HKArray(className) : HKArray<className *> \
@end

/**
 Implementation Array for Parse
 declare HKArrayImplementation(ObjectType) in .m file firset to use HKArray(ObjectType)

 @param className class into place array
 */
#define HKArrayImplementation(className) \
@implementation HKArray(className) \
+ (__unsafe_unretained Class)objectClass { return className.class; } \
@end
