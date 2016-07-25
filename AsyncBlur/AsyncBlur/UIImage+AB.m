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
    CGSize screenSizeInPoints = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    return [self ab_blurredImageWithRadius:radius scaledToSize:CGSizeMake(screenSizeInPoints.width * scale, screenSizeInPoints.height * scale)];
}

- (UIImage *)ab_blurredImageWithRadius:(NSNumber *)radius scaledToSize:(CGSize)size {    
    if (!radius.floatValue) {
        return self;
    }
    
    UIImage *imageToBlur = [self ab_imageScaledToFit:size];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[imageToBlur CGImage]] forKey:kCIInputImageKey];
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

- (UIImage *)ab_imageScaledToFit:(CGSize)size {
    CGFloat ratio = 0;
    
    if (self.size.width > size.width) {
        ratio = size.width / self.size.width;
    }
    
    if (self.size.height > size.height) {
        ratio = MIN(ratio, size.height / self.size.height);
    }
    
    if (!ratio) {
        return self;
    }
    
    CGSize resultSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    UIGraphicsBeginImageContext(resultSize);
    [self drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
