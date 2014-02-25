/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 DateCalculationUtilTest.h
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of Nathan Wisman nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

- (void)testHelpViewCountry {
    HelpView *hv = [[HelpView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    XCTAssertNotNil([hv helpTextLbl], @"Label should not yet be instantiated");
    XCTAssertEqual([hv.helpTextLbl numberOfLines], 0, @"Number of lines should always be 0 to allow for dynamic label resizing");
    XCTAssertEqual([hv.helpTextLbl textColor], [UIColor blackColor], @"Label text color should be black");
    XCTAssertEqual([hv.helpTextLbl backgroundColor], [UIColor clearColor], @"Label text color should be black");
    XCTAssertEqual([hv.helpTextLbl lineBreakMode], NSLineBreakByWordWrapping);

    [hv setText:@"United States" btnInt:1];

    XCTAssertEqualObjects(hv.helpTextLbl.text, @"Country of residence is a strong indicator of life expectancy.\n\nUnited States\n\nSOURCE: Life expectancy: Life expectancy by country, 2011, World Health Organization", @"Country label should have life expectancy for both genders");
}

@end