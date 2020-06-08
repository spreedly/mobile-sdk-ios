//
//  CreditCardInfoCompatTests.m
//  SdkTests
//
//  Created by Eli Thompson on 6/8/20.
//

#import <XCTest/XCTest.h>
#import <CoreSdk/CoreSdk-Swift.h>

@interface CreditCardInfoCompatTests : XCTestCase

@end

@implementation CreditCardInfoCompatTests

- (void)testCanCreateAndGetJsonDictionary {
    CreditCardInfo *info = [[CreditCardInfo alloc] init];
    info.fullName = @"Dolly Dog";
    info.firstName = @"Dolly";
    info.lastName = @"Dog";
    info.company = @"Border LLC";
    info.address.address1 = @"123 Fake St";

    NSDictionary *json = [info toJson:NULL];
    XCTAssertEqualObjects(json[@"full_name"], @"Dolly Dog");
    XCTAssertEqualObjects(json[@"first_name"], @"Dolly");
    XCTAssertEqualObjects(json[@"last_name"], @"Dog");
    XCTAssertEqualObjects(json[@"company"], @"Border LLC");
    XCTAssertEqualObjects(json[@"address1"], @"123 Fake St");
}

@end
