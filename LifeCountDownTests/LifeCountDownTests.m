//
//  LifeCountDownTests.m
//  LifeCountDownTests
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LifeCountDownTests.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LifeCountDownTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    ViewController *vc = [[ViewController alloc] init];
    [vc verifyPlist];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *testPath = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.

    STAssertEqualObjects(testPath, [vc getPath], @"Ensure path is set correctly");    
}

@end