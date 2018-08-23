//
//  HKModel.h
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

#pragma mark - protocol
/**
 model
 */
@protocol HKModel <NSObject, NSCopying, NSSecureCoding>

@required
/**
 initialize model from serialize object (ex. JSON Object)

 @param serializedObject serialize object (ex. JSON Object)
 @return model object
 */
+ (nullable instancetype)modelWithSerializedObject:(id)serializedObject;
/**
 model to serialize object (ex. JSON Object)
 */
@property (nonatomic, readonly, nullable) id serializedObject;

@optional
/**
 all keys for key_value
 */
@property (nonatomic, readonly) NSArray<NSString *> *allKeys;

/**
 set object for key from serialize object

 @param serializedObject value in serialize object
 @param key key
 */
- (void)setSerializedObject:(nullable id)serializedObject forKey:(NSString *)key;
/**
 serialized object for key

 @param key key
 @return serialized object
 */
- (nullable id)serializedObjectForKey:(NSString *)key;

@end

#pragma mark - model object
/**
 base model object
 parse Dictionary to model automatically
 */
@interface HKModel : NSObject
<HKModel>

/**
 methods for subscript (ie.model[@"key"])

 @param object object for set
 @param key key
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key;
/**
 methods for subscript (ie.model[@"key"])
 
 @param key key
 @return object for key
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

@end

#pragma mark - foundation model object
@interface NSString (HKModel)
<HKModel>
@end

@interface NSNumber (HKModel)
<HKModel>
@end

@interface NSURL (HKModel)
<HKModel>
@end

@interface NSData (HKModel)
<HKModel>
@end

@interface NSDictionary (HKModel)
<HKModel>
@end

@interface NSArray (HKModel)
<HKModel>
@end

NS_ASSUME_NONNULL_END
