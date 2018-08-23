//
//  HKArray.m
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

#import "HKArray.h"
#import "HKModel.h"

@implementation HKArray

@dynamic objectClass;
+ (__unsafe_unretained Class)objectClass {
    return NSObject.class;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return (HKArray *)[NSMutableArray allocWithZone:zone];
}

+ (instancetype)modelWithSerializedObject:(id)serializedObject {
    HKArray *result = nil;
    
    if ([serializedObject isKindOfClass:NSArray.class]) {
        result = [self arrayWithCapacity:((NSArray *)serializedObject).count];
        Class objectClass = self.objectClass;
        BOOL isModel = [objectClass conformsToProtocol:@protocol(HKModel)];
        for (id value in serializedObject) {
            id object = isModel ? [objectClass modelWithSerializedObject:value] : value;
            object ? [result addObject:object] : nil;
        }
    }
    
    return result;
}

@end
