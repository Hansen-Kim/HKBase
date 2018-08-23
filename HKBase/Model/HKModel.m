//
//  HKModel.m
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

#import "HKModel.h"
#import "HKRuntimeUtility.h"
#import "HKProperty.h"
#import "HKInstanceVariable.h"

#define HKSerializedObject(value) ([value conformsToProtocol:@protocol(HKModel)] ? ((id<HKModel>)value).serializedObject : value)

#pragma mark - model object
@interface HKModel ()

- (void)HK_decodeWithCoder:(NSCoder *)decoder;
- (void)HK_setSerializedObject:(id)serializedObject forKey:(NSString *)key byProperty:(HKProperty *)property;

@end

@implementation HKModel

//NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self HK_decodeWithCoder:decoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    Class class = self.class;
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                id object = [self objectForProperty:property];
                object ? [coder encodeObject:object forKey:property.name] : nil;
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKModel.class]);
}

@dynamic supportsSecureCoding;
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)HK_decodeWithCoder:(NSCoder *)decoder {
    Class class = self.class;
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [self setObject:[decoder decodeObjectForKey:property.name] forProperty:property];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKModel.class]);
}

// NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    Class class = self.class;
    HKModel *result = [[class allocWithZone:zone] init];
    
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [result setObject:[self objectForProperty:property] forProperty:property];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKModel.class]);
    
    return result;
}

// HKModel
+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    Class class = self;
    HKModel *result = [[class alloc] init];
    
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [result setSerializedObject:[serializedObject valueForKey:property.name] forKey:property.name];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKModel.class]);
    
    return result;
}

- (id)serializedObject {
    NSArray<NSString *> *allKeys = self.allKeys;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:allKeys.count];
    for (NSString *key in allKeys) {
        result[key] = [self serializedObjectForKey:key];
    }
    return result;
}

@dynamic allKeys;
- (NSArray<NSString *> *)allKeys {
    Class class = self.class;
    NSMutableArray *result = [NSMutableArray array];
    
    do {
        for (HKProperty *property in class.properties) {
            if (!property.dynamic && !property.readOnly) {
                [result addObject:property.name];
            }
        }
    } while ([(class = class.superclass) isSubclassOfClass:HKModel.class]);

    return result;

}

- (void)HK_setSerializedObject:(id)serializedObject forKey:(NSString *)key byProperty:(HKProperty *)property {
    if (property) {
        const char *objCType = property.objCType;
        id value = serializedObject;
        
        if(HKIsSupportedProperty(property)) {
            if (value) {
                if (objCType[0] == '@' || objCType[0] == '*' || [value isKindOfClass:[NSNumber class]] ||
                    (HKIsPropertyNumberSupport(property) && [value isKindOfClass:[NSString class]])) {
                    Class propertyClass = property.propertyClass;
                    if ([propertyClass conformsToProtocol:@protocol(HKModel)]) {
                        value = [propertyClass modelWithSerializedObject:value];
                    }
                    [self setValue:value forKey:key];
                } else if ([value isKindOfClass:[NSValue class]]) {
                    HKInstanceVariable *variable = property.instanceVariable;
                    if (variable) {
                        NSUInteger size = 0;
                        NSGetSizeAndAlignment(objCType, &size, NULL);
                        
                        void *buffer = malloc((size_t)size);
                        [value getValue:buffer];
                        
                        [self setValue:buffer forInstanceVariable:variable];
                        
                        free(buffer);
                    }
                }
            }
        }
    }
}

- (void)setSerializedObject:(id)serializedObject forKey:(NSString *)key {
    [self HK_setSerializedObject:serializedObject forKey:key byProperty:[HKProperty propertyWithClass:self.class name:key]];
}

- (id)serializedObjectForKey:(NSString *)key {
    id result = nil;
    
    HKProperty *property = [HKProperty propertyWithClass:self.class name:key];
    
    if(HKIsSupportedProperty(property)) {
        result = [self valueForKey:key];
        result = [result conformsToProtocol:@protocol(HKModel)] ? ((id<HKModel>)result).serializedObject : nil;
    }
    
    return result;
}

- (NSString *)description {
    return [[self serializedObject] description];
}

- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key {
    [self setValue:object forKey:key];
}

- (nullable id)objectForKeyedSubscript:(NSString *)key {
    return [self valueForKey:key];
}


@end

#pragma mark - foundation model object
@implementation NSString (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSString *result = nil;
    if ([serializedObject isKindOfClass:NSString.class]) {
        result = [serializedObject copy];
    } else if ([serializedObject isKindOfClass:NSNumber.class]) {
        result = ((NSNumber *)serializedObject).stringValue;
    } else if ([serializedObject isKindOfClass:NSData.class]) {
        result = [[NSString alloc] initWithData:serializedObject encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id)serializedObject {
    return [self copy];
}

// methods for parse exception
- (char)charValue {
    return (char)(self.boolValue);
}

- (unsigned long long)unsignedLongLongValue {
    return strtoull(self.UTF8String, NULL, 0);
}

- (unsigned short)unsignedShortValue {
    return (unsigned short)(self.unsignedLongLongValue);
}

- (unsigned char)unsignedCharValue {
    return (unsigned char)(self.unsignedLongLongValue);
}

@end


@implementation NSNumber (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSNumber *result = nil;
    if ([serializedObject isKindOfClass:NSNumber.class]) {
        result = [serializedObject copy];
    } else if ([serializedObject isKindOfClass:NSString.class]) {
        result = @(((NSString *)serializedObject).doubleValue);
    } else if ([serializedObject isKindOfClass:NSData.class]) {
        result = @([[NSString alloc] initWithData:serializedObject encoding:NSUTF8StringEncoding].doubleValue);
    }
    return result;
}

- (id)serializedObject {
    return [self copy];
}

@end

@implementation NSURL (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSURL *result = nil;
    if (![serializedObject isKindOfClass:NSNumber.class]) {
        NSString *URLString = [NSString modelWithSerializedObject:serializedObject];
        if (URLString.length) {
            result = [NSURL URLWithString:URLString];
        }
    }
    return result;
}

- (id)serializedObject {
    return self.absoluteString;
}

@end

@implementation NSData (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSData *result = nil;
    if ([serializedObject isKindOfClass:NSData.class]) {
        result = [serializedObject copy];
    } else if ([serializedObject isKindOfClass:NSString.class]) {
        result = [((NSString *)serializedObject) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([serializedObject isKindOfClass:NSDictionary.class] || [serializedObject isKindOfClass:NSArray.class]) {
        result = [NSJSONSerialization dataWithJSONObject:serializedObject options:(NSJSONWritingOptions)0 error:nil];
    }
    return result;
}

- (id)serializedObject {
    return [self copy];
}

@end

@implementation NSDictionary (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSDictionary *result = nil;
    if ([serializedObject respondsToSelector:@selector(allKeys)]) {
        NSArray *allKeys = [serializedObject allKeys];
        if ([allKeys isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:allKeys.count];
            for (id key in allKeys) {
                if ([key isKindOfClass:NSString.class]) {
                    dictionary[key] = [serializedObject valueForKey:key];
                }
            }
            result = dictionary;
        }
    }
    return result;
}

- (id)serializedObject {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self.allKeys) {
        result[key] = HKSerializedObject(self[key]);
    }
    return result;
}

@end

@implementation NSArray (HKModel)

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    NSArray *result = nil;
    if ([serializedObject isKindOfClass:NSArray.class]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:((NSArray *)serializedObject).count];
        for (id value in serializedObject) {
            [array addObject:value];
        }
        result = array;
    }
    return result;
}

- (id)serializedObject {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id value in self) {
        id object = HKSerializedObject(value);
        object ? [result addObject:object] : nil;
    }
    return result;
}

@end
