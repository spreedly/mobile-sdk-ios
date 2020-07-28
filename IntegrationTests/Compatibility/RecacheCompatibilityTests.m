//
// Created by Eli Thompson on 7/28/20.
//

#import <XCTest/XCTest.h>
#import <Spreedly/Spreedly-Swift.h>
#import "IntegrationTests-Swift.h"

@interface RecacheCompatibilityTests : XCTestCase
@end

@implementation RecacheCompatibilityTests

- (void)testCanRecache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"recache"];
    NSError *createCardError;
    SPRSingleTransaction *transaction = [SPRHelpers createCardWithRetained:YES error:&createCardError];
    [transaction subscribeOnSuccess:^(SPRTransaction *t) {
        SPRCreditCardResult *result = (SPRCreditCardResult *) t.paymentMethod;
        id <SPRSecureOpaqueString> verificationValue = [SPRSecureOpaqueStringBuilder buildFrom:[SPRHelpers verificationValue]];
        id <SPRClient> client = [SPRHelpers createClient];

        [[client recacheWithToken:result.token verificationValue:verificationValue] subscribeOnSuccess:^(SPRTransaction *recacheTransaction) {
            XCTAssertEqualObjects(recacheTransaction.transactionType, @"RecacheSensitiveData");
            XCTAssert(recacheTransaction.succeeded);
            [expectation fulfill];
        }                                                                                      onError:^(NSError *err) {
            XCTFail(@"recache operation failed");
            [expectation fulfill];
        }];

    }                       onError:^(NSError *err) {
        XCTFail(@"create card operation failed");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    XCTAssertNil(createCardError);
}

@end
