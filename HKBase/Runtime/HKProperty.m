//
//  HKProperty.m
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

#import "HKProperty.h"
#import "HKInstanceVariable.h"
#import "HKRuntimeUtility.h"

#import <objc/runtime.h>

@interface HKProperty () {
    __unsafe_unretained Class _class;
    NSString *_objCType;
}

- (instancetype)initWithClass:(Class)class property:(objc_property_t)property;
- (void)HK_setAttributeByPropertyAttribute:(objc_property_attribute_t)propertyAttribute;

@end

@implementation HKProperty

+ (instancetype)propertyWithClass:(__unsafe_unretained Class)class name:(NSString *)name {
    objc_property_t property = class_getProperty(class, name.UTF8String);
    return property ? [[self alloc] initWithClass:class property:property] : nil;
}

- (instancetype)initWithClass:(Class)class property:(objc_property_t)property {
    self = [super init];
    if (self) {
        _class = class;
        _name = [NSString stringWithUTF8String:property_getName(property)];
        
        unsigned int count = 0;
        objc_property_attribute_t *attributeList = property_copyAttributeList(property, &count);
        for (unsigned int index = 0; index < count; index++) {
            [self HK_setAttributeByPropertyAttribute:attributeList[index]];
        }
        
        attributeList ? free(attributeList) : nil;
        
        if (!_readOnly && !_setter) {
            NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[_name substringToIndex:1] uppercaseString], [_name length] > 1 ? [_name substringFromIndex:1] : @""];
            _setter = NSSelectorFromString(setterName);
        }
        
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
    }
    return self;
}

#pragma mark - private

- (void)HK_setAttributeByPropertyAttribute:(objc_property_attribute_t)propertyAttribute {
    switch (propertyAttribute.name[0]) {
        case 'N':
            _attribute |= HKPropertyAttributeNonatomic;
            break;
        case 'W':
            _attribute |= HKPropertyAttributeWeak;
            break;
        case '&':
            _attribute |= HKPropertyAttributeStrong;
            break;
        case 'C':
            _attribute |= HKPropertyAttributeCopy;
            break;
        case 'T':
            _objCType = [NSString stringWithUTF8String:propertyAttribute.value];
            break;
        case 'D':
            _dynamic = YES;
            break;
        case 'R':
            _readOnly = YES;
            break;
        case 'S':
            _setter = sel_registerName(propertyAttribute.value);
            break;
        case 'G':
            _getter = sel_registerName(propertyAttribute.value);
            break;
        case 'V':
            _instanceVariable = [HKInstanceVariable instanceVariableWithClass:_class name:[NSString stringWithUTF8String:propertyAttribute.value]];
            break;
        default:
            break;
    }
}
        
#pragma mark - properties
@dynamic objCType;
@dynamic object;
@dynamic propertyClass;

- (const char *)objCType {
    return _objCType.UTF8String;
}

- (BOOL)isObject {
    return self.objCType[0] == '@';
}

- (__unsafe_unretained Class)propertyClass {
    static __strong NSRegularExpression *_expression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _expression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z0-9_]+" options:0 error:nil];
    });
    
    Class result = NULL;
    NSString *objCType = [NSString stringWithUTF8String:self.objCType];
    if ([objCType hasPrefix:@"@\""] && [objCType hasSuffix:@"\""]) {
        NSRange range = [_expression rangeOfFirstMatchInString:objCType options:(NSMatchingOptions)0 range:NSMakeRange(0, objCType.length)];
        result = (range.location != NSNotFound && range.length > 0) ? NSClassFromString([objCType substringWithRange:range]) : nil;
    }
    return result;
}

@end

@implementation NSObject (HKProperty)

@dynamic properties;

+ (NSArray<HKProperty *> *)properties {
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(self, &count);
    
    NSArray<HKProperty *> *result = nil;
    if (count) {
        NSMutableArray<HKProperty *> *properties = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int index = 0; index < count; index++) {
            [properties addObject:[[HKProperty alloc] initWithClass:self property:propertyList[index]]];
        }
        result = properties;
    }
    
    propertyList ? free(propertyList) : nil;
    
    return result;
}

- (void)setObject:(id)object forProperty:(HKProperty *)property {
    if (property.object || [object isKindOfClass:NSNumber.class]) {
        [self setValue:object forKey:property.name];
    } else if ([object isKindOfClass:NSValue.class]) {
        HKInstanceVariable *variable = property.instanceVariable;
        if (variable) {
            NSUInteger size = 0;
            NSGetSizeAndAlignment(property.objCType, &size, NULL);
            
            if (size) {
                void *value = malloc((size_t)size);
                [object getValue:value];
                
                [self setValue:value forInstanceVariable:variable];
                free(value);
            }
        }
    }
}

- (id)objectForProperty:(HKProperty *)property {
    id result = nil;
    if (property.object) {
        result = [self valueForKey:property.name];
    } else {
        HKInstanceVariable *variable = property.instanceVariable;
        if (variable) {
            NSUInteger size = 0;
            NSGetSizeAndAlignment(property.objCType, &size, NULL);
            
            if (size) {
                void *value = malloc((size_t)size);
                [self getValue:value forInstanceVariable:variable];
                result = HKIsPropertyNumberSupport(property) ? [NSNumber value:value withObjCType:property.objCType] : [NSValue value:value withObjCType:property.objCType];
                
                free(value);
            }
        }
    }
    return result;
}

@end
