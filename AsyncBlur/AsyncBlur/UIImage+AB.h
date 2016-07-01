//
//  UIImage+AB.h
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (AB)

- (UIImage *)ab_blurredImageWithRadius:(NSNumber *)radius;

@end
