//
//  ApplePAyCompatibilityTests.m
//  SdkIntegrationTests
//
//  Created by Eli Thompson on 6/11/20.
//

#import <XCTest/XCTest.h>
#import <Spreedly/Spreedly-Swift.h>
#import "IntegrationTests-Swift.h"

@interface ApplePayCompatibilityTests : XCTestCase

@end

@implementation ApplePayCompatibilityTests

- (void)testCanCreateApplePay {
    ApplePayInfo *info = [[ApplePayInfo alloc]
            initWithFirstName:@"Dolly"
                     lastName:@"Dog"
             paymentTokenData:SPRHelpers.paymentTokenData

    ];
    info.testCardNumber = SPRHelpers.testCardNumber;
    info.company = @"LSGD Partners";

    Address *address = [[Address alloc] init];
    address.address1 = @"123 Fake St";
    address.address2 = @"Suite #200";
    address.city = @"Springfield";
    address.state = @"OR";
    address.zip = @"97475";
    address.country = @"US";
    address.phoneNumber = @"541-555-2222";
    info.address = address;

    info.shippingAddress = [[Address alloc] initFrom:address];
    info.shippingAddress.address1 = @"321 Wall St";

    info.email = @"doll@dog.com";

    id <SPRClient> client = [SPRHelpers createClient];
    SPRSingleTransaction *transaction = [client createPaymentMethodFrom:info];

    XCTestExpectation *expectation = [self expectationWithDescription:@"can create"];
    [transaction subscribeOnSuccess:^(SPRTransaction *t) {
        XCTAssertNotNil(t.token);

        SPRCreditCardResult *result = t.applePay;
        XCTAssertNotNil(result.token);
        XCTAssertEqual(result.paymentMethodType, SPRPaymentMethodTypeApplePay);
        XCTAssertEqual(result.storageState, SPRStorageStateCached);
        XCTAssertEqualObjects(result.firstName, info.firstName);
        XCTAssertEqualObjects(result.lastName, info.lastName);
        XCTAssertEqualObjects(result.company, info.company);

        XCTAssertEqualObjects(result.lastFourDigits, @"1111");
        XCTAssertEqualObjects(result.firstSixDigits, @"411111");
        XCTAssertEqual(result.year, 2022);
        XCTAssertEqual(result.month, 3);
        XCTAssertEqualObjects(result.cardType, @"visa");

        XCTAssertEqualObjects(result.address, info.address);
        XCTAssertEqualObjects(result.shippingAddress, info.shippingAddress);

        [expectation fulfill];
    }                       onError:^(NSError *error) {
        XCTFail();
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
