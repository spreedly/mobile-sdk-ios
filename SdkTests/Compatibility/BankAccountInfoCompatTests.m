//
// Created by Eli Thompson on 6/8/20.
//

#import <XCTest/XCTest.h>
#import <CoreSdk/CoreSdk-Swift.h>

@interface BankAccountInfoCompatTests : XCTestCase

@end

@implementation BankAccountInfoCompatTests


- (void)testCanCreateAndGetJsonDictionary {
    BankAccountInfo *info = [[BankAccountInfo alloc] init];
    info.fullName = @"Dolly Dog";
    info.firstName = @"Dolly";
    info.lastName = @"Dog";
    info.company = @"Border LLC";
    info.address.address1 = @"123 Fake St";
    info.shippingAddress.address1 = @"321 Wall St";
    info.bankAccountNumber = [SpreedlySecureOpaqueStringBuilder buildFrom: @"9876543210"];
    info.bankRoutingNumber = @"021000021";
    info.bankAccountType = BankAccountTypeSavings;
    info.bankAccountHolderType = BankAccountHolderTypeBusiness;

    NSDictionary *json = [info toJson:NULL];
    NSDictionary *expected = @{
            @"full_name": @"Dolly Dog",
            @"first_name": @"Dolly",
            @"last_name": @"Dog",
            @"company": @"Border LLC",
            @"address1": @"123 Fake St",
            @"shipping_address1": @"321 Wall St",
            @"bank_account_number": @"9876543210",
            @"bank_routing_number": @"021000021",
            @"bank_account_holder_type": @"business",
            @"bank_account_type": @"savings"
    };

    XCTAssertEqualObjects(json, expected);
}

@end
