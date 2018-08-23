//
//  HKEnum.m
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

#import "HKEnum.h"
#import "HKRuntimeUtility.h"
#import "HKProperty.h"
#import "HKMethod.h"

@interface HKEnum () {
    @package
    NSInteger _value;
    NSString *_stringValue;
}

+ (void)HK_initializeClassPropertyWithName:(NSString *)name;
- (void)HK_initializeByBase:(__kindof HKEnum *)base;
- (id(^)(void))HK_findSwitchAction:(va_list)args;

@end

@interface HKEnumStorage () {
    NSMutableDictionary<NSString *, __kindof HKEnum *> *_allEnums;
    
    NSArray<NSString *> *_allKeys;
    NSArray<NSNumber *> *_allValues;
    NSArray<NSString *> *_allStringValues;
    NSMutableDictionary<NSString *, NSArray<id> *> *_allProperties;
}

- (__kindof HKEnum *)HK_makeEnumForKey:(NSString *)key;

@end

@implementation HKEnum

@dynamic currentStorage;
@dynamic serializeToString;

+ (__kindof HKEnumStorage *)currentStorage {
    return nil;
}

+ (NSArray<__kindof HKEnum *> *)allEnums {
    return self.currentStorage.allEnums;
}

+ (BOOL)isSerializeToString {
    return NO;
}

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    HKEnum *result = nil;
    if ([serializedObject isKindOfClass:NSNumber.class]) {
        result = [self enumWithValue:((NSNumber *)serializedObject).integerValue];
    } else if ([serializedObject isKindOfClass:NSString.class]) {
        result = [self enumWithStringValue:serializedObject];
    }
    return result;
}

- (id)serializedObject {
    return self.class.isSerializeToString ? self.stringValue : @(self.value);
}

+ (instancetype)enumWithValue:(NSInteger)value {
    return [self.currentStorage enumForValue:value];
}

+ (instancetype)enumWithStringValue:(NSString *)stringValue {
    return [self.currentStorage enumForStringValue:stringValue];
}

+ (void)HK_initializeClassPropertyWithName:(NSString *)name {
    SEL selector = NSSelectorFromString(name);
    HKMethod *method = [HKMethod methodWithSelector:selector block:^id(Class self) {
        return [self.currentStorage enumForKey:name];
    }];
    [self replaceClassMethod:method];
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        NSInteger value = [decoder decodeIntegerForKey:NSStringFromSelector(@selector(value))];
        __kindof HKEnum *base = [self.class.currentStorage enumForValue:value];
        [self HK_initializeByBase:base];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:_value forKey:NSStringFromSelector(@selector(value))];
}

@dynamic supportsSecureCoding;
+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HKEnum *result = [[self.class alloc] init];
    result->_value = _value;
    result->_stringValue = _stringValue;
    [result HK_initializeByBase:self];
    return result;
}

#pragma mark - properties

- (NSUInteger)hash {
    return NSStringFromClass(self.class).hash + _value;
}

- (BOOL)isEqual:(__kindof HKEnum *)object {
    return self.hash == object.hash;
}

#pragma mark - public methods

- (NSComparisonResult)compare:(__kindof HKEnum *)other {
    return [@(_value) compare:@(other.value)];
}

- (nullable id)switchWithDefaultHandler:(id (^)(void))defaultHandler, ... {
    va_list args;
    va_start(args, defaultHandler);
    id(^action)(void) = [self HK_findSwitchAction:args];
    action = action ?: defaultHandler;
    
    id result = action ? action() : nil;
    va_end(args);
    
    return result;
}

#pragma mark - private methods

- (void)HK_initializeByBase:(__kindof HKEnum *)base {
    Class class = self.class;
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [self setObject:[self objectForProperty:property] forProperty:property];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKEnum.class]);
}

- (id(^)(void))HK_findSwitchAction:(va_list)args {
    id result = nil;
    
    BOOL correct = NO;
    id argument = nil;
    while (YES) {
        argument = va_arg(args, id);
        if(argument) {
            if (correct) {
                if (![argument isKindOfClass:self.class]) {
                    result = argument;
                    break;
                }
            } else {
                if([argument isEqual:self]) {
                    correct = YES;
                }
            }
        } else {
            break;
        }
    }
    
    return result;
}

@end

static NSArray<NSString *> *HKGetComponents(NSString *string) {
    NSArray<NSString *> *components = [string componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:components.count];
    NSCharacterSet *charset = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    for (NSString *component in components) {
        [result addObject:[component stringByTrimmingCharactersInSet:charset]];
    }
    return result;
}

@implementation HKEnumStorage : NSObject

@dynamic sharedStorage;

- (void)registerEnumArguments:(NSString *)arguments {
    _allKeys = [HKGetComponents(arguments) copy];
    for (NSString *key in _allKeys) {
        [self.enumClass HK_initializeClassPropertyWithName:key];
    }
}

- (void)registerValues:(NSArray<NSNumber *> *)values {
    _allValues = [values copy];
}

- (void)registerStringValues:(NSArray<NSString *> *)stringValues {
    _allStringValues = [stringValues copy];
}

- (void)registerObject:(NSArray<id> *)objects propertyName:(NSString *)propertyName {
    if (!_allProperties) {
        _allProperties = [NSMutableDictionary dictionary];
    }
    _allProperties[propertyName] = [objects copy];
}

- (nullable __kindof HKEnum *)enumForKey:(NSString *)key {
    if (!_allEnums) {
        _allEnums = [NSMutableDictionary dictionaryWithCapacity:_allKeys.count];
    }
    __kindof HKEnum *result = _allEnums[key];
    if (!result) {
        result = [self HK_makeEnumForKey:key];
        _allEnums[key] = result;
    }
    return result;
}

- (nullable __kindof HKEnum *)enumForValue:(NSInteger)value {
    NSInteger index = _allValues ? [_allValues indexOfObject:@(value)] : value;
    
    @try {
        return index != NSNotFound ? [self enumForKey:_allKeys[index]] : nil;
    } @catch (__unused NSException *exception) {
        return nil;
    }
}

- (nullable __kindof HKEnum *)enumForStringValue:(NSString *)stringValue {
    NSInteger index = [_allStringValues ?: _allKeys indexOfObject:stringValue];
    
    return index != NSNotFound ? [self enumForKey:_allKeys[index]] : nil;
}

#pragma mark - properties
@dynamic allEnums;
@dynamic enumClass;

- (__unsafe_unretained Class)enumClass {
    return HKEnum.class;
}

- (NSArray<__kindof HKEnum *> *)allEnums {
    NSMutableArray<__kindof HKEnum *> *result = [NSMutableArray arrayWithCapacity:_allKeys.count];
    for (NSString *key in _allKeys) {
        [result addObject:[self enumForKey:key]];
    }
    return result;
}

#pragma mark - private methods

- (nullable __kindof HKEnum *)HK_makeEnumForKey:(NSString *)key {
    NSInteger index = [_allKeys indexOfObject:key];
    
    __kindof HKEnum *result = [[self.enumClass alloc] init];
    result->_value = _allValues ? _allValues[index].integerValue : index;
    result->_stringValue = _allStringValues ? [_allStringValues[index] copy] : [key copy];
    for (NSString *propertyName in _allProperties) {
        NSArray<id> *properyValues = _allProperties[propertyName];
        HKProperty *property = [HKProperty propertyWithClass:self.enumClass name:propertyName];
        [result setObject:properyValues[index] forProperty:property];
    }
    return result;
}

@end
