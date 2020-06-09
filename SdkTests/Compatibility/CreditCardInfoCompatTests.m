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

    Address *address = [[Address alloc] init];
    address.address1 = @"123 Fake St";
    address.address2 = @"Suite 9874";
    address.city = @"Seattle";
    address.state = @"WA";
    address.zip = @"98121";
    address.country = @"US";
    address.phoneNumber = @"206-555-1234";

    info.address = address;
    info.shippingAddress = [[Address alloc] initFrom:address];
    info.shippingAddress.address1 = @"321 Wall St";

    info.number = [SpreedlySecureOpaqueStringBuilder buildFrom:@"4111111111111111"];
    info.verificationValue = [SpreedlySecureOpaqueStringBuilder buildFrom:@"919"];
    info.year = @2050;
    info.month = @12;

    NSDictionary *json = [info toJson:NULL];
    XCTAssertEqualObjects(json[@"full_name"], @"Dolly Dog");
    XCTAssertEqualObjects(json[@"first_name"], @"Dolly");
    XCTAssertEqualObjects(json[@"last_name"], @"Dog");
    XCTAssertEqualObjects(json[@"company"], @"Border LLC");

    XCTAssertEqualObjects(json[@"address1"], address.address1);
    XCTAssertEqualObjects(json[@"address2"], address.address2);
    XCTAssertEqualObjects(json[@"city"], address.city);
    XCTAssertEqualObjects(json[@"state"], address.state);
    XCTAssertEqualObjects(json[@"zip"], address.zip);
    XCTAssertEqualObjects(json[@"country"], address.country);
    XCTAssertEqualObjects(json[@"phone_number"], address.phoneNumber);

    XCTAssertEqualObjects(json[@"shipping_address1"], @"321 Wall St");
    XCTAssertEqualObjects(json[@"shipping_address2"], address.address2);
    XCTAssertEqualObjects(json[@"shipping_city"], address.city);
    XCTAssertEqualObjects(json[@"shipping_state"], address.state);
    XCTAssertEqualObjects(json[@"shipping_zip"], address.zip);
    XCTAssertEqualObjects(json[@"shipping_country"], address.country);
    XCTAssertEqualObjects(json[@"shipping_phone_number"], address.phoneNumber);

    XCTAssertEqualObjects(json[@"number"], @"4111111111111111");
    XCTAssertEqualObjects(json[@"verification_value"], @"919");
    XCTAssertEqualObjects(json[@"year"], @2050);
    XCTAssertEqualObjects(json[@"month"], @12);
}

@end
