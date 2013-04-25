//
//  LifeCountDownTests.m
//  LifeCountDownTests
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LifeCountDownTests.h"
#import "ViewController.h"

@implementation LifeCountDownTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.

    [super tearDown];
}

- (void)testExample {
    ViewController *vc = [[ViewController alloc] init];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.
    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path], @"We should have no plist yet");
}

@end