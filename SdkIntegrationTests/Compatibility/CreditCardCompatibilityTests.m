//
//  CreditCardTests.m
//  SdkIntegrationTests
//
//  Created by Eli Thompson on 6/10/20.
//

#import <XCTest/XCTest.h>
#import <CoreSdk/CoreSdk-Swift.h>
#import "SdkIntegrationTests-Swift.h"

@interface CreditCardCompatibilityTests : XCTestCase

@end

@implementation CreditCardCompatibilityTests

- (void)testCanCreateCreditCard {
    CreditCardInfo *info = [[CreditCardInfo alloc]
            initWithFirstName:@"Dolly"
                     lastName:@"Dog"
                       number:SPRHelpers.secureTestCardNumber
            verificationValue:SPRHelpers.secureVerificationValue
                         year:2030
                        month:12
    ];
    info.company = @"Growlers LLC";

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

    id <SPRClient> client = [SPRHelpers createClient];
    SPRSingleTransaction *transaction = [client createPaymentMethodFrom:info];

    XCTestExpectation *expectation = [self expectationWithDescription:@"can create"];
    [transaction subscribeOnSuccess:^(SPRTransaction *t) {
        XCTAssertNotNil(t.token);

        SPRCreditCardResult *result = t.creditCard;
        XCTAssertNotNil(result.token);
        XCTAssertEqual(result.paymentMethodType, SPRPaymentMethodTypeCreditCard);
        XCTAssertEqual(result.storageState, SPRStorageStateCached);
        XCTAssertEqualObjects(result.firstName, @"Dolly");
        XCTAssertEqualObjects(result.lastName, @"Dog");
        XCTAssertEqualObjects(result.company, @"Growlers LLC");
        
        XCTAssertEqualObjects(result.lastFourDigits, @"1111");
        XCTAssertEqualObjects(result.firstSixDigits, @"411111");
        XCTAssertEqual(result.year, 2030);
        XCTAssertEqual(result.month, 12);
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
