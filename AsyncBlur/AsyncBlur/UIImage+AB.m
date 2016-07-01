//
//  UIImage+AB.m
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import "UIImage+AB.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (AB)

- (UIImage *)ab_blurredImageWithRadius:(NSNumber *)radius
{
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[self CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:radius forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGRect rect          = [outputImage extent];
    
    rect = CGRectMake(0, 0, rect.size.width + rect.origin.x * 2, rect.size.height + rect.origin.y * 2);
 
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:rect];
    UIImage *image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return image;
}

@end
