//
//  BlurManager.h
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage, UIImageView;

@interface ABManager : NSObject

+ (void)setShouldBlurOnSimulator:(BOOL)shouldBlurOnSimulator;

+ (void)renderBlurForImage:(UIImage *)image andSetInImageView:(UIImageView *)imageView;
+ (void)renderBlurForImage:(UIImage *)image radius:(CGFloat)radius andSetInImageView:(UIImageView *)imageView;

+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView withCallback:(void (^)(UIImage *blurredImage))callback;
+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView radius:(CGFloat)radius withCallback:(void (^)(UIImage *blurredImage))callback;


@end
