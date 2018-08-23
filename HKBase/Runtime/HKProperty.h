//
//  HKProperty.h
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

/**
 property attibute in @property

 - HKPropertyAttributeAtomic: matching atomic
 - HKPropertyAttributeNonatomic: matching nonatomic
 
 - HKPropertyAttributeAssign: matching assign
 - HKPropertyAttributeWeak: matching weak
 - HKPropertyAttributeStrong: matching strong
 - HKPropertyAttributeCopy: matching copy
 */
typedef NS_OPTIONS(NSInteger, HKPropertyAttribute) {
    HKPropertyAttributeAtomic       = 0x00,
    HKPropertyAttributeNonatomic    = 0x01,
    
    HKPropertyAttributeAssign       = 0x00,
    HKPropertyAttributeWeak         = 0x10,
    HKPropertyAttributeStrong       = 0x20,
    HKPropertyAttributeCopy         = 0x40,
};

@class HKInstanceVariable;

NS_ASSUME_NONNULL_BEGIN

/**
 Extend Property
 cf. objc_property_t objc/runtime.h
 */
@interface HKProperty : NSObject

/**
 property's name
 */
@property (nonatomic, readonly) NSString *name;
/**
 property setter name
 */
@property (nonatomic, readonly, nullable) SEL setter;
/**
 property getter name
 */
@property (nonatomic, readonly) SEL getter;
/**
 property attribute
 */
@property (nonatomic, readonly) HKPropertyAttribute attribute;
/**
 property matched instance variable
 example > @synthesize value = _value
    property(value)'s instance variable is _value
 */
@property (nonatomic, readonly, nullable) HKInstanceVariable *instanceVariable;

/**
 property's objCType
 */
@property (nonatomic, readonly) const char *objCType;

/**
 is property readonly (@property (readonly))
 */
@property (nonatomic, readonly, getter=isReadOnly) BOOL readOnly;
/**
 is property dynamic (@dynamic value in .m file)
 */
@property (nonatomic, readonly, getter=isDynamic) BOOL dynamic;

/**
 is property ObjectType is Object(id) type
 */
@property (nonatomic, readonly, getter=isObject) BOOL object;
/**
 if property is object return that object's class
 */
@property (nonatomic, nullable, unsafe_unretained, readonly) Class propertyClass;

/**
 property of name in class

 @param aClass class
 @param name property name
 @return property
 */
+ (nullable instancetype)propertyWithClass:(__unsafe_unretained Class)aClass name:(NSString *)name;

@end

@interface NSObject (HKProperty)

/**
 all properties of class
 */
@property (class, nonatomic, nullable, readonly) NSArray<HKProperty *> *properties;

/**
 set object to property

 @param object object for set to property
 @param property property for key (like setValue:forKey:'s key)
 */
- (void)setObject:(id)object forProperty:(HKProperty *)property;
/**
 object of property

 @param property property for get
 @return property for key (like valueForKey:'s key)
 */
- (id)objectForProperty:(HKProperty *)property;

@end

NS_ASSUME_NONNULL_END
