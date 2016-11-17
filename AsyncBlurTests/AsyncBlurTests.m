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

- (void)testProgressiveRenderToZero {
    UIImageView *imageViewForTest = [UIImageView new];
    UIImage *originalImage = [UIImage imageNamed:@"lena"];
    __block UIImage *lastImage = nil;
    
    for (int i = 100; i >= 0; i--) {
        [ABManager renderBlurForImage:originalImage forImageView:imageViewForTest radius:i withCallback:^(UIImage *blurredImage) {
            NSLog(@"%@", blurredImage);
            lastImage = blurredImage;
        }];
    }
    
    NSUInteger timeoutToRender = 10;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for check last render result"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutToRender * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(originalImage, lastImage);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:timeoutToRender + 1 handler:^(NSError * _Nullable error) {
        XCTAssert(!error);
    }];
}

@end
