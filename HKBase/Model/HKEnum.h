//
//  HKEnum.h
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
#import "HKModel.h"

NS_ASSUME_NONNULL_BEGIN

@class HKEnumStorage;

/**
 Enum class like Swift Enum
 usage example>
 HKWeekday.h
 @interface HKWeekday : HKEnum
 @property (nonatomic, strong, readonly) UIColor *textColor;
 @end
 HKEnumDeclare(HKWeekDay, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
 
 HKWeekday.m
 @interface HKWeekday ()
 @property (nonatomic, strong) UIColor *textColor;
 @end
 @implementation HKWeekday
 @end
 HKEnumImplementation(HKWeekDay, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
 HKEnumRegisterValues(HKWeekDay, 1, 2, 3, 4, 5, 6, 7) // no required(optional)
 HKEnumRegisterStringValues(HKWeekDay, @"Mon", @"The", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun") // no required(optional)
 HKEnumRegisterProperties(HKWeekDay, textColor, UIColor.blackColor, UIColor.blackColor, UIColor.blackColor, UIColor.blackColor, UIColor.blackColor, UIColor.blueColor, UIColor.redColor) // no required(optional)
 */
@interface HKEnum : NSObject
<HKModel>

#pragma mark - class methods

/**
 Enum Object Storage
 Do not use it immediacy
 */
@property (class, nonatomic, readonly) __kindof HKEnumStorage *currentStorage;
/**
 All Enum Objects
 */
@property (class, nonatomic, readonly) NSArray<__kindof HKEnum *> *allEnums;
/**
 if return YES serializedObjectForKey: NEModel methods return NSString * else return NSInteger
 */
@property (class, nonatomic, readonly, getter=isSerializeToString) BOOL serializeToString; // default : NO

/**
 Enum of value

 @param value enum value
 @return enum object has current value
 */
+ (instancetype)enumWithValue:(NSInteger)value;
/**
 Enum of string value

 @param stringValue enum string value
 @return enum object has current string value
 */
+ (instancetype)enumWithStringValue:(NSString *)stringValue;

#pragma mark - instance methods

/**
 integer value of Enum
 */
@property (nonatomic, readonly) NSInteger value;
/**
 string value of Enum
 */
@property (nonatomic, readonly) NSString *stringValue;

/**
 compare other Enum

 @param other other Enum
 @return comparison result
 */
- (NSComparisonResult)compare:(__kindof HKEnum *)other;

/**
 switch with enum
 
 usage example >
 [weekday swichWithDefaultHandler:^id { return UIColor.blackColor; },
    HKWeekday.Saturday,
    ^id { return UIColor.blueColor; },
    HKWeekday.Sunday,
    ^id { return UIColor.redColor; },
    nil];
 or
 [weekday swichWithDefaultHandler:^id { return nil; },
    HKWeekDay.Monday, HKWeekDay.Tuesday, HKWeekDay.Wednesday, HKWeekDay.Thursday, HKWeekDay.Friday,
    ^ id { return UIColor.blackColor; },
    HKWeekday.Saturday,
    ^id { return UIColor.blueColor; },
    HKWeekday.Sunday,
    ^id { return UIColor.redColor; },
    nil];

 @param defaultHandler block for excution at default: in switch(...) { ... }
 @return result of current switch block;
 */
- (nullable id)switchWithDefaultHandler:(id(^)(void))defaultHandler, ... NS_REQUIRES_NIL_TERMINATION;

@end

/**
 @required
 Enum Values Declare using category
 before using this func. declare "@interface classname : HKEnum @end" first

 @param className Enum class name
 @param ... Enum Value Names
 */
#define HKEnumDeclare(className, ...) \
\
@class className; \
typedef className *className ## Ptr; \
@interface className (className ## Property) \
@property (class, nonatomic, nonnull, readonly) className ## Ptr __VA_ARGS__; \
@end

/**
 @required
 Enum Values Implementation using category
 before using this func. declare "@implementation classname @end" first in .m file
 
 @param className Enum class name
 @param ... Enum Value Names
 */
#define HKEnumImplementation(className, ...) \
\
@interface className ## EnumStorage : HKEnumStorage \
@end \
\
@implementation className (className ## Property) \
@dynamic __VA_ARGS__; \
+ (void)load { \
    [self.currentStorage registerEnumArguments:@#__VA_ARGS__]; \
} \
+ (__kindof HKEnumStorage *)currentStorage { \
    static className ## EnumStorage *currentStorage = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        currentStorage = [[className ## EnumStorage alloc] init]; \
    }); \
    return currentStorage; \
} \
@end \
\
@implementation className ## EnumStorage \
- (__unsafe_unretained Class)enumClass { \
    return className.class; \
} \
@end

/**
 @optional
 Enum Values register integer value using category
 before using this func. declare HKEnumImplementation(...) first in .m file
 if you do not use this func, set integer values sequentially
 
 @param className Enum class name
 @param ... Enum integer values
 */
#define HKEnumRegisterValues(className, ...) \
\
@implementation className (className ## Values) \
+ (void)load { \
    const NSInteger arguments[] = { __VA_ARGS__ }; \
    const NSInteger numberOfArguments = sizeof(arguments) / sizeof(arguments[0]); \
    NSMutableArray<NSNumber *> *values = [NSMutableArray arrayWithCapacity:numberOfArguments]; \
    for (NSInteger index = 0; index < numberOfArguments; index++) { \
        [values addObject:@(arguments[index])]; \
    } \
    [self.currentStorage registerValues:values]; \
} \
@end

/**
 @optional
 Enum Values register string value using category
 before using this func. declare HKEnumImplementation(...) first in .m file
 if you do not use this func, set string value by enum names
 
 @param className Enum class name
 @param ... Enum string values
 */
#define HKEnumRegisterStringValues(className, ...) \
\
@implementation className (className ## StringValues) \
+ (void)load { \
    [self.currentStorage registerStringValues:@[__VA_ARGS__]]; \
} \
@end

/**
 Enum Values register property using category
 before using this func. declare HKEnumImplementation(...) first in .m file
 if you do not use this func, set nil to property

 @param className Enum class name
 @param property property name for set
 @param ... value into place property
 */
#define HKEnumRegisterProperties(className, property, ...) \
\
@implementation className (className ## property ## Properties) \
+ (void)load { \
    [self.currentStorage registerObject:@[__VA_ARGS__] propertyName:@#property]; \
} \
@end

@interface HKEnum (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 Enum Storage
 Do not use it immediacy
 */
@interface HKEnumStorage : NSObject

@property (class, nonatomic, readonly) __kindof HKEnumStorage *sharedStorage;

@property (nonatomic, unsafe_unretained, readonly) Class enumClass;
@property (nonatomic, strong, readonly) NSArray<__kindof HKEnum *> *allEnums;

- (void)registerEnumArguments:(NSString *)arguments;
- (void)registerValues:(NSArray<NSNumber *> *)values;
- (void)registerStringValues:(NSArray<NSString *> *)stringValues;
- (void)registerObject:(NSArray<id> *)objects propertyName:(NSString *)propertyName;

- (nullable __kindof HKEnum *)enumForKey:(NSString *)key;
- (nullable __kindof HKEnum *)enumForValue:(NSInteger)value;
- (nullable __kindof HKEnum *)enumForStringValue:(NSString *)stringValue;

@end

NS_ASSUME_NONNULL_END
