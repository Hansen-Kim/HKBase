//
//  HKRuntimeTest.m
//	Create on 2018. 8. 23.
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


#import <XCTest/XCTest.h>
#import <HKBase/HKBase.h>

#import "HKTestObject.h"

@interface HKRuntimeTest : XCTestCase

@property (nonatomic, strong) HKTestObject *object;

@end

@implementation HKRuntimeTest

- (void)setUp {
    [super setUp];
    HKTestObject *object = [[HKTestObject alloc] init];
    object.name = @"Hansen Kim";
    object.age = @(38);
    object.weight = 74.3;
    
    object.rect = (HKRect){ .x = 10.0, .y = 20.0, .width = 30.0, .height = 40.0 };
    
    self.object = object;
}

- (void)tearDown {
    self.object = nil;
    [super tearDown];
}

- (void)testSubclassing {
    Class subclass = [HKTestObject registerSubclassWithClassName:@"HKRuntimeTestObject" extend:^(Class subclass) {
        HKMethod *method = [HKMethod methodWithSelector:NSSelectorFromString(@"setX:") block:^(HKTestObject *self, double x) {
            HKRect rect = self.rect;
            rect.x = x;
            self.rect = rect;
        }];
        [subclass replaceInstanceMethod:method];
    }];
    XCTAssertTrue([NSStringFromClass(subclass) isEqualToString:@"HKRuntimeTestObject"], @"register subclass failed: %@", NSStringFromClass(subclass));

    [self.object subclassingWithClass:subclass];
    XCTAssertTrue([self.object.class isEqual:subclass], @"subclassing failed: %@", NSStringFromClass(self.object.class));
    
    [self.object performSelectorWithArguments:NSSelectorFromString(@"setX:"), 20.0];
    XCTAssertTrue(self.object.rect.x == 20.0, @"instance method replace failed");
}

- (void)testProperty {
    {
        HKProperty *property = [HKProperty propertyWithClass:self.object.class name:@"name"];
        XCTAssertTrue((property.attribute & HKPropertyAttributeCopy) == HKPropertyAttributeCopy, @"name doesn't have copy attribute");
        [self.object setObject:@"Other man" forProperty:property];
        XCTAssertTrue([self.object.name isEqualToString:@"Other man"], @"setObject:forProperty:(name) failed");
    }
    
    {
        HKProperty *property = [HKProperty propertyWithClass:self.object.class name:@"age"];
        XCTAssertTrue((property.attribute & HKPropertyAttributeStrong) == HKPropertyAttributeStrong, @"age doesn't have strong attribute");
        [self.object setObject:@(20) forProperty:property];
        XCTAssertTrue([self.object.age isEqualToNumber:@(20)], @"setObject:forProperty:(age) failed");
    }

    {
        HKProperty *property = [HKProperty propertyWithClass:self.object.class name:@"weight"];
        XCTAssertTrue((property.attribute & HKPropertyAttributeNonatomic) == HKPropertyAttributeNonatomic, @"age doesn't have strong attribute");
        [self.object setObject:@(20) forProperty:property];
        XCTAssertTrue([self.object.age isEqualToNumber:@(20)], @"setObject:forProperty:(age) failed");
    }
}

- (void)testInstanceVariable {
    HKProperty *property = [HKProperty propertyWithClass:self.object.class name:@"rect"];
    HKRect rect;
    [self.object getValue:&rect forInstanceVariable:property.instanceVariable];
    
    XCTAssertTrue(HKRectIsEqual(rect, self.object.rect), @"getValue:ForInstanceVariable:(rect) failed");
    
    rect.x = 30.0; rect.y = 40.0; rect.width = 10.0; rect.height = 20.0;
    [self.object setValue:&rect forInstanceVariable:property.instanceVariable];
    
    XCTAssertTrue(HKRectIsEqual(rect, self.object.rect), @"setValue:ForInstanceVariable:(rect) failed");
}

@end
