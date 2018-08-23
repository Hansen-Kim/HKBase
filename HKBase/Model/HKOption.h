//
//  HKOption.h
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

@class HKOptionStorage;

OBJC_EXTERN NSString *const kHKOptionEmptyStringValue;

/**
 Option set class like Swift Option set
 usage example>
 HKShipping.h
 @interface HKShipping : HKOption
 @end
 HKOptionDeclare(HKShipping, NextDay, Standard, Free, Payed) // required

 HKShipping.m
 @implementation HKShipping
 @end
 HKOptionImplementation(HKShipping, NextDay, Standard, Free, Payed) // required
 HKOptionRegisterValues(HKShipping, 0x01, 0x02, 0x10, 0x20) // no required(optional)
 HKOptionRegisterStringValues(HKShipping, @"Fast Shipping", @"Standard Shipping", @"Free", @"Payed") // no required(optional)
 */
@interface HKOption : NSObject
<HKModel>

#pragma mark - class methods

/**
 Option set Object Storage
 Do not use it immediacy
 */
@property (class, nonatomic, readonly) __kindof HKOptionStorage *currentStorage;
/**
 All Option set Objects
 */
@property (class, nonatomic, readonly) NSArray<__kindof HKOption *> *allOptions;
/**
 if return YES serializedObjectForKey: NEModel methods return NSString * else return NSInteger
 */
@property (class, nonatomic, readonly, getter=isSerializeToString) BOOL serializeToString; // default : NO

/**
 Option set of value
 
 @param value enum value
 @return enum object has current value
 */
+ (instancetype)optionWithValue:(NSInteger)value;
/**
 Enum of shift (ex. 1 << **"shift"**)
 
 @param shift 1 << shift
 @return enum object has current shift
 */
+ (instancetype)optionWithShift:(NSInteger)shift;
/**
 Option set of string value
 
 @param stringValue enum string value
 @return enum object has current string value
 */
+ (instancetype)optionWithStringValue:(NSString *)stringValue;

#pragma mark - instance methods

/**
 integer value of Option set
 */
@property (nonatomic, readonly) NSInteger value;
/**
 string value of Option set
 if merge options string value are component joined @"."
 */
@property (nonatomic, readonly) NSString *stringValue;

/**
 Option set has reverse integer value (~value)
 */
@property (nonatomic, readonly) __kindof HKOption *Reverse;

/**
 compare other Option set
 
 @param other other Option set
 @return comparison result
 */
- (NSComparisonResult)compare:(__kindof HKOption *)other;

/**
 result = self | option

 @param option other Option
 @return or calculated
 */
- (__kindof HKOption *)orWithOption:(__kindof HKOption *)option;
/**
 result = self & option
 
 @param option other Option
 @return and calculated
 */
- (__kindof HKOption *)andWithOption:(__kindof HKOption *)option;
/**
 result = self ^ option
 
 @param option other Option
 @return xor calculated
 */
- (__kindof HKOption *)xorWithOption:(__kindof HKOption *)option;

/**
 result = self | option
 
 @param option other Option
 @return inserted other Option
 */
- (__kindof HKOption *)insertOption:(__kindof HKOption *)option;
/**
 result = self & ~option

 @param option other Option
 @return deleted other Option
 */
- (__kindof HKOption *)deleteOption:(__kindof HKOption *)option;

/**
 result of contain

 @param option other Option
 @return result of contain
 */
- (BOOL)containOption:(__kindof HKOption *)option;

@end

/**
 Option set Values Declare using category
 before using this func. declare "@interface classname : HKOption @end" first
 
 @param className Option set class name
 @param ... Option set Value Names
 */
#define HKOptionDeclare(className, ...) \
\
@class className; \
typedef className *className ## Ptr; \
@interface className (className ## ClassProperty) \
@property (class, nonatomic, nonnull, readonly) className ## Ptr __VA_ARGS__; \
@end \
@interface className (className ## InstanceProperty) \
@property (nonatomic, nonnull, readonly) className ## Ptr __VA_ARGS__; \
@end


/**
 Option set Values Implementation using category
 before using this func. declare "@implementation classname @end" first in .m file
 
 @param className Option set class name
 @param ... Option set Value Names
 */
#define HKOptionImplementation(className, ...) \
\
@interface className ## OptionStorage : HKOptionStorage \
@end \
\
@implementation className (className ## ClassProperty) \
@dynamic __VA_ARGS__; \
+ (void)load { \
    [self.currentStorage registerOptionArguments:@#__VA_ARGS__]; \
} \
+ (__kindof HKOptionStorage *)currentStorage { \
    static className ## OptionStorage *currentStorage = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        currentStorage = [[className ## OptionStorage alloc] init]; \
    }); \
    return currentStorage; \
} \
@end \
@implementation className (className ## InstanceProperty) \
@dynamic __VA_ARGS__; \
@end \
\
@implementation className ## OptionStorage \
- (__unsafe_unretained Class)optionClass { \
    return className.class; \
} \
@end

/**
 @optional
 Option set Values register integer value using category
 before using this func. declare HKOptionImplementation(...) first in .m file
 if you do not use this func, set integer values shift sequentially
 
 @param className Option set class name
 @param ... Option set integer values
 */
#define HKOptionRegisterValues(className, ...) \
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
 Option set Values register string value using category
 before using this func. declare HKOptionImplementation(...) first in .m file
 if you do not use this func, set string value by enum names
 
 @param className Option set class name
 @param ... Option set string values
 */
#define HKOptionRegisterStringValues(className, ...) \
\
@implementation className (className ## StringValues) \
+ (void)load { \
    [self.currentStorage registerStringValues:@[__VA_ARGS__]]; \
} \
@end

@interface HKOption (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 Option set Storage
 Do not use it immediacy
 */
@interface HKOptionStorage : NSObject

@property (class, nonatomic, readonly) __kindof HKOptionStorage *sharedStorage;

@property (nonatomic, unsafe_unretained, readonly) Class optionClass;
@property (nonatomic, strong, readonly) NSArray<__kindof HKOption *> *allOptions;

- (void)registerOptionArguments:(NSString *)arguments;
- (void)registerValues:(NSArray<NSNumber *> *)values;
- (void)registerStringValues:(NSArray<NSString *> *)stringValues;

- (nullable __kindof HKOption *)optionForKey:(NSString *)key;
- (nullable __kindof HKOption *)optionForValue:(NSInteger)value;
- (nullable __kindof HKOption *)optionForStringValue:(NSString *)stringValue;

@end

NS_ASSUME_NONNULL_END
