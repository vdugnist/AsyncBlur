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
    UIImage *_originalImage;
}

- (instancetype)init {
    if (self = [super init]) {
        _blurRadius = kDefaultBlurRadius;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _originalImage = self.image;
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
    
    _originalImage = image;
    [self blurAndSetImage:image];
}

- (void)blurAndSetImage:(UIImage *)image {
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

- (void)setBlurRadius:(CGFloat)blurRadius {
    _blurRadius = blurRadius;
    [self blurAndSetImage:_originalImage];
}

@end
