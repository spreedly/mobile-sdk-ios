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
    info.shippingAddress.address1 = @"321 Wall St";
    info.number = [SpreedlySecureOpaqueStringBuilder buildFrom: @"4111111111111111"];
    info.verificationValue = [SpreedlySecureOpaqueStringBuilder buildFrom: @"919"];
    info.year = @2050;
    info.month = @12;

    NSDictionary *json = [info toJson:NULL];
    XCTAssertEqualObjects(json[@"full_name"], @"Dolly Dog");
    XCTAssertEqualObjects(json[@"first_name"], @"Dolly");
    XCTAssertEqualObjects(json[@"last_name"], @"Dog");
    XCTAssertEqualObjects(json[@"company"], @"Border LLC");
    XCTAssertEqualObjects(json[@"address1"], @"123 Fake St");
    XCTAssertEqualObjects(json[@"shipping_address1"], @"321 Wall St");

    XCTAssertEqualObjects(json[@"number"], @"4111111111111111");
    XCTAssertEqualObjects(json[@"verification_value"], @"919");
    XCTAssertEqualObjects(json[@"year"], @2050);
    XCTAssertEqualObjects(json[@"month"], @12);
}

@end
