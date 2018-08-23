//
//  HKOption.m
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

#import "HKOption.h"
#import "HKRuntimeUtility.h"
#import "HKProperty.h"
#import "HKMethod.h"

NSString *const kHKOptionEmptyStringValue = @"Empty";

@interface HKOption () {
    @package
    NSInteger _value;
    NSString *_stringValue;
}

+ (void)HK_initializeClassPropertyWithName:(NSString *)name;
- (void)HK_initializeByBase:(__kindof HKOption *)base;

@end

@interface HKOptionStorage () {
    NSMutableDictionary<NSString *, __kindof HKOption *> *_allOptions;
    
    NSArray<NSString *> *_allKeys;
    NSArray<NSNumber *> *_allValues;
    NSArray<NSString *> *_allStringValues;
    
    __kindof HKOption *_emptyOption;
}

@property (nonatomic, readonly) __kindof HKOption *Empty;

- (__kindof HKOption *)HK_makeOptionForKey:(NSString *)key;
- (NSArray<HKOption *> *)HK_optionsForValue:(NSInteger)value;
- (NSString *)HK_stringValueForValue:(NSInteger)value;

@end

@implementation HKOption

@dynamic currentStorage;
@dynamic serializeToString;

+ (__kindof HKOptionStorage *)currentStorage {
    return nil;
}

+ (NSArray<__kindof HKOption *> *)allOptions {
    return self.currentStorage.allOptions;
}

+ (BOOL)isSerializeToString {
    return NO;
}

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    HKOption *result = nil;
    if ([serializedObject isKindOfClass:NSNumber.class]) {
        result = [self optionWithValue:((NSNumber *)serializedObject).integerValue];
    } else if ([serializedObject isKindOfClass:NSString.class]) {
        result = [self optionWithStringValue:serializedObject];
    }
    return result;
}

- (id)serializedObject {
    return self.class.isSerializeToString ? self.stringValue : @(self.value);
}

+ (instancetype)optionWithValue:(NSInteger)value {
    return [self.currentStorage optionForValue:value];
}

+ (instancetype)optionWithShift:(NSInteger)shift {
    return [self.currentStorage optionForValue:1 << shift];
}

+ (instancetype)optionWithStringValue:(NSString *)stringValue {
    return [self.currentStorage optionForStringValue:stringValue];
}

+ (void)HK_initializeClassPropertyWithName:(NSString *)name {
    SEL selector = NSSelectorFromString(name);
    HKMethod *classMethod = [HKMethod methodWithSelector:selector block:^id (Class self) {
        return [self.currentStorage optionForKey:name];
    }];
    [self replaceClassMethod:classMethod];
    HKMethod *instanceMethod = [HKMethod methodWithSelector:selector block:^id (__kindof HKOption *self) {
        return [self orWithOption:[self.class.currentStorage optionForKey:name]];
    }];
    [self replaceInstanceMethod:instanceMethod];
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        NSInteger value = [decoder decodeIntegerForKey:NSStringFromSelector(@selector(value))];
        __kindof HKOption *base = [self.class.currentStorage optionForValue:value];
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
    HKOption *result = [[self.class alloc] init];
    result->_value = _value;
    result->_stringValue = _stringValue;
    [result HK_initializeByBase:self];
    return result;
}

#pragma mark - properties

@dynamic Reverse;

- (NSUInteger)hash {
    return NSStringFromClass(self.class).hash + _value;
}

- (BOOL)isEqual:(__kindof HKOption *)object {
    return self.hash == object.hash;
}

- (__kindof HKOption *)Reverse {
    __kindof HKOption *result = [[self.class alloc] init];
    NSInteger value = ~_value;
    NSString *stringValue = [_stringValue stringByAppendingFormat:@".%@", NSStringFromSelector(_cmd)];
    
    result->_value = value;
    result->_stringValue = stringValue;
    
    return result;
}

#pragma mark - public methods

- (NSComparisonResult)compare:(__kindof HKOption *)other {
    return [@(_value) compare:@(other.value)];
}

- (__kindof HKOption *)orWithOption:(__kindof HKOption *)option {
    __kindof HKOption *result = [self copy];
    NSInteger value = result.value | option.value;
    NSString *stringValue = [self.class.currentStorage HK_stringValueForValue:value];
    
    result->_value = value;
    result->_stringValue = stringValue;
    
    return result;
}

- (__kindof HKOption *)andWithOption:(__kindof HKOption *)option {
    __kindof HKOption *result = [self copy];
    NSInteger value = result.value & option.value;
    NSString *stringValue = [self.class.currentStorage HK_stringValueForValue:value];
    
    result->_value = value;
    result->_stringValue = stringValue;
    return result;
}

- (__kindof HKOption *)xorWithOption:(__kindof HKOption *)option {
    __kindof HKOption *result = [self copy];
    NSInteger value = result.value ^ option.value;
    NSString *stringValue = [self.class.currentStorage HK_stringValueForValue:value];
    
    result->_value = value;
    result->_stringValue = stringValue;
    return result;
}

- (__kindof HKOption *)insertOption:(__kindof HKOption *)option {
    return [self orWithOption:option];
}

- (__kindof HKOption *)deleteOption:(__kindof HKOption *)option {
    return [self andWithOption:option.Reverse];
}

- (BOOL)containOption:(__kindof HKOption *)option {
    return (self.value & option.value) == option.value;
}

#pragma mark - private methods

- (void)HK_initializeByBase:(__kindof HKOption *)base {
    Class class = self.class;
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [self setObject:[self objectForProperty:property] forProperty:property];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKOption.class]);
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

@implementation HKOptionStorage : NSObject

@dynamic sharedStorage;

- (void)registerOptionArguments:(NSString *)arguments {
    _allKeys = [HKGetComponents(arguments) copy];
    for (NSString *key in _allKeys) {
        [self.optionClass HK_initializeClassPropertyWithName:key];
    }
}

- (void)registerValues:(NSArray<NSNumber *> *)values {
    _allValues = [values copy];
}

- (void)registerStringValues:(NSArray<NSString *> *)stringValues {
    _allStringValues = [stringValues copy];
}

- (nullable __kindof HKOption *)optionForKey:(NSString *)key {
    if (!_allOptions) {
        _allOptions = [NSMutableDictionary dictionaryWithCapacity:_allKeys.count];
    }
    __kindof HKOption *result = _allOptions[key];
    if (!result) {
        result = [self HK_makeOptionForKey:key];
        _allOptions[key] = result;
    }
    return [result copy];
}

- (nullable __kindof HKOption *)optionForValue:(NSInteger)value {
    __kindof HKOption *result = nil;
    NSArray<__kindof HKOption *> *options = [self HK_optionsForValue:value];
    for (__kindof HKOption *option in options) {
        result = result ? [result orWithOption:option] : result;
    }
    return result;
}

- (nullable __kindof HKOption *)optionForStringValue:(NSString *)stringValue {
    __kindof HKOption *result = nil;
    NSArray<NSString *> *components = [stringValue componentsSeparatedByString:@"."];
    NSArray<NSString *> *allStringValues = _allStringValues ?: _allKeys;
    for (NSInteger index = 0; index < allStringValues.count; index++) {
        if ([components containsObject:allStringValues[index]]) {
            HKOption *option = [self optionForKey:_allKeys[index]];
            result = result ? [result orWithOption:option] : option;
        }
    }
    
    return [result copy];
}

#pragma mark - properties
@dynamic allOptions;
@dynamic optionClass;
@dynamic Empty;

- (__unsafe_unretained Class)optionClass {
    return HKOption.class;
}

- (NSArray<__kindof HKOption *> *)allOptions {
    NSMutableArray<__kindof HKOption *> *result = [NSMutableArray arrayWithCapacity:_allKeys.count];
    for (NSString *key in _allKeys) {
        [result addObject:[self optionForKey:key]];
    }
    return result;
}

- (__kindof HKOption *)Empty {
    if (!_emptyOption) {
        _emptyOption = [[self.optionClass alloc] init];
        _emptyOption->_stringValue = kHKOptionEmptyStringValue;
    }
    return _emptyOption;
}

#pragma mark - private methods

- (nullable __kindof HKOption *)HK_makeOptionForKey:(NSString *)key {
    NSInteger index = [_allKeys indexOfObject:key];
    
    __kindof HKOption *result = [[self.optionClass alloc] init];
    result->_value = _allValues ? _allValues[index].integerValue : 1 << index;
    result->_stringValue = _allStringValues ? [_allStringValues[index] copy] : [key copy];
    return result;
}

- (NSArray<HKOption *> *)HK_optionsForValue:(NSInteger)value {
    NSMutableArray<__kindof HKOption *> *result = [NSMutableArray arrayWithCapacity:_allKeys.count];
    if (value) {
        for (HKOption *option in self.allOptions) {
            if ((value & option.value) == option.value) {
                [result addObject:option];
            }
        }
    }
    return result.count ? result : @[self.Empty];
}

- (NSString *)HK_stringValueForValue:(NSInteger)value {
    NSArray<NSString *> *result = [[self HK_optionsForValue:value] valueForKeyPath:@"stringValue"];
    return [result componentsJoinedByString:@"."];
}

@end
