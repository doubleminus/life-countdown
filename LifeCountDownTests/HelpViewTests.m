//
//  HelpViewTests.m
//  Life Count
//
//  Created by Nathan Wisman on 2/25/14.
//
//

#import <XCTest/XCTest.h>
#import "HelpView.h"

@interface HelpViewTests : XCTestCase

@end

@implementation HelpViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample {
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);

    HelpView *hv = [[HelpView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
  //  XCTAssertEqual([hv get], <#a2#>, <#format...#>)
}

@end
