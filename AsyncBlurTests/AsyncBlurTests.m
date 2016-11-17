//
//  AsyncBlurTests.m
//  AsyncBlurTests
//
//  Created by Vladislav Dugnist on 8/11/16.
//  Copyright © 2016 Vladislav Dugnist. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ABManager.h"

@interface AsyncBlurTests : XCTestCase

@end

@implementation AsyncBlurTests

+ (void)setUp {
    [ABManager setShouldBlurOnSimulator:YES];
}

- (void)testMultipleBlurForSameImageViewWillNotRenderAllOperations {
    NSUInteger operationsCount = 100;
    UIImageView *imageViewForTest = [UIImageView new];
    UIImage *originalImage = [UIImage imageNamed:@"lena"];
    __block NSUInteger count = 0;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for render all tasks"];

    for (NSInteger i = operationsCount; i >= 0; i--) {
        [ABManager renderBlurForImage:originalImage forImageView:imageViewForTest radius:i withCallback:^(UIImage *blurredImage) {
            count++;
            
            if (i == 0) {
                [expectation fulfill];
            }
        }];
    }
    
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssert(!error);
    }];
    
    // first and last operation
    XCTAssert(count == 2);
}

- (void)testZeroBlurReturnsSameImage {
    UIImage *originalImage = [UIImage imageNamed:@"lena"];
    __block BOOL blockCalled = NO;
    
    [ABManager renderBlurForImage:originalImage forImageView:nil radius:0 withCallback:^(UIImage * _Nonnull blurredImage) {
        XCTAssert(blurredImage == originalImage);
        blockCalled = YES;
    }];
    
    XCTAssert(blockCalled);
}

@end
