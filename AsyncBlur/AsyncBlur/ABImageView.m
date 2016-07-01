//
//  ABImageView.m
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//


#import "ABImageView.h"
#import "ABManager.h"

static CGFloat const kAnimationDuration = 1.0;
static CGFloat const kDefaultBlurRadius = 35.0;

@implementation ABImageView {
    __block BOOL _animating;
}

- (instancetype)init {
    if (self = [super init]) {
        _blurRadius = kDefaultBlurRadius;
    }
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (TARGET_IPHONE_SIMULATOR || self.disableBlur || !image) {
        [self.layer removeAllAnimations];
        [super setImage:nil];
        return;
    }
    
    __weak ABImageView *weakSelf = self;
    
    [ABManager renderBlurForImage:image forImageView:self radius:@(self.blurRadius) withCallback:^(UIImage *blurredImage) {
        [weakSelf.layer removeAllAnimations];
        
        [UIView transitionWithView:weakSelf
                          duration:kAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            [weakSelf ab_setImage:blurredImage];
                        } completion:nil];
    }];
    
}

- (void)ab_setImage:(UIImage *)image
{
    [super setImage:image];
}

@end
