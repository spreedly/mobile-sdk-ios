//
//  CreditCardTests.m
//  SdkIntegrationTests
//
//  Created by Eli Thompson on 6/10/20.
//

#import <XCTest/XCTest.h>
#import <CoreSdk/CoreSdk-Swift.h>
#import "SdkIntegrationTests-Swift.h"

@interface CreditCardTests : XCTestCase

@end

@implementation CreditCardTests

- (void)testCanCreateCreditCard {
    CreditCardInfo *info = [[CreditCardInfo alloc]
            initWithFirstName:@"Dolly"
                     lastName:@"Dog"
                       number:SPRHelpers.secureTestCardNumber
            verificationValue:SPRHelpers.secureVerificationValue
                         year:2030
                        month:12
    ];

    id <SPRClient> client = [SPRHelpers createClient];
    SPRSingleTransaction *transaction = [client createPaymentMethodWithCreditCard:info];

    XCTestExpectation *expectation = [self expectationWithDescription:@"can create"];
    [transaction subscribeOnSuccess:^(SPRTransaction *t) {
        XCTAssertNotNil(t.token);

        SPRCreditCardResult *result = t.creditCard;
        XCTAssertNotNil(result.token);
        XCTAssertEqualObjects(result.firstName, @"Dolly");
        XCTAssertEqualObjects(result.lastName, @"Dog");
        XCTAssertEqualObjects(result.lastFourDigits, @"1111");
        XCTAssertEqual(result.year, 2030);
        XCTAssertEqual(result.month, 12);
        [expectation fulfill];
    }                       onError:^(NSError *error) {
        XCTFail();
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
