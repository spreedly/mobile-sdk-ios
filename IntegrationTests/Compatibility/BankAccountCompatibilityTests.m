//
//  BandAccountTests.m
//  SdkIntegrationTests
//
//  Created by Eli Thompson on 6/10/20.
//

#import <XCTest/XCTest.h>
#import <Spreedly/Spreedly-Swift.h>
#import "IntegrationTests-Swift.h"

@interface BankAccountCompatibilityTests : XCTestCase

@end

@implementation BankAccountCompatibilityTests

- (void)testCanCreateBankAccount {
    BankAccountInfo *info = [[BankAccountInfo alloc] init];
    info.firstName = @"Dolly";
    info.lastName = @"Dog";
    info.routingNumber = SPRHelpers.testBankRoutingNumber;
    info.accountNumber = SPRHelpers.secureBankAccountNumber;
    info.accountType = BankAccountTypeChecking;
    info.accountHolderType = BankAccountHolderTypePersonal;

    id <SPRClient> client = [SPRHelpers createClient];
    SPRSingleTransaction *transaction = [client createPaymentMethodFrom:info];

    XCTestExpectation *expectation = [self expectationWithDescription:@"can create"];
    [transaction subscribeOnSuccess:^(SPRTransaction *t) {
        XCTAssertNotNil(t.token);

        SPRBankAccountResult *result = t.bankAccount;
        XCTAssertNotNil(result.token);
        XCTAssertEqual(result.paymentMethodType, SPRPaymentMethodTypeBankAccount);
        XCTAssertEqual(result.storageState, SPRStorageStateCached);
        XCTAssertNil(result.bankName);
        XCTAssertEqualObjects(result.firstName, @"Dolly");
        XCTAssertEqualObjects(result.lastName, @"Dog");
        XCTAssertEqual(result.accountType, BankAccountTypeChecking);
        XCTAssertEqual(result.accountHolderType, BankAccountHolderTypePersonal);
        XCTAssertEqualObjects(result.routingNumberDisplayDigits, @"021");
        XCTAssertEqualObjects(result.accountNumberDisplayDigits, @"3210");
        XCTAssertEqualObjects(result.routingNumber, @"021*");
        XCTAssertEqualObjects(result.accountNumber, @"*3210");
        [expectation fulfill];
    }                       onError:^(NSError *error) {
        XCTFail();
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
