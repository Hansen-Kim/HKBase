//
//  HKCardTest.m
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
#import "HKCardResponse.h"

@interface HKCardTest : XCTestCase

@property (nonatomic, strong) NSDictionary *JSON;
@property (nonatomic, strong) NSError *error;

@end

@implementation HKCardTest

- (void)setUp {
    [super setUp];

    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"Cards" ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:path];
    NSDictionary *serializedObject = [NSJSONSerialization JSONObjectWithData:JSONData options:(NSJSONReadingOptions)0 error:&error];
    
    self.JSON = serializedObject;
    self.error = error;
}

- (void)tearDown {
    self.JSON = nil;
    self.error = nil;
    [super tearDown];
}

- (void)testCards {
    XCTAssertNil(self.error, @"JSON serialize fail: %@", self.error.localizedFailureReason);
    
    HKCardResponse *response = [HKCardResponse modelWithSerializedObject:self.JSON];
    NSArray<HKCard *> *cards = response.header.success ? response.cards : nil;
    XCTAssertNotNil(cards, @"HKCard deserialize fail");
    
    XCTAssertTrue(cards.count == [self.JSON[@"cards"] count], @"cards count failed -> card count(%zd)", cards.count);
    NSArray<HKCard *> *masterCards = [cards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"brand == %@", HKBrand.Master]];
    XCTAssertTrue(masterCards.count == 2, @"filter master card count failed, master card count(%zd)", masterCards.count);
}

@end
