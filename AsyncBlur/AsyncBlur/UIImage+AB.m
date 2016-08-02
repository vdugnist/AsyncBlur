//
//  UIImage+AB.m
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import "UIImage+AB.h"
#import <Accelerate/Accelerate.h>

static CGFloat const kGausianToTentRadiusRatio = 5;

@implementation UIImage (AB)

#pragma mark - Core graphic implementation

- (UIImage *)ab_blurredImageWithRadius:(NSNumber *)radius
{
    CGSize screenSizeInPoints = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    return [self ab_blurredImageWithRadius:radius scaledToSize:CGSizeMake(screenSizeInPoints.width * scale, screenSizeInPoints.height * scale)];
}

#pragma mark - Accelerate framework implementation

- (UIImage *)ab_blurredImageWithRadius:(NSNumber *)radius scaledToSize:(CGSize)size {
    if (radius.floatValue <= 0) {
        return self;
    }
    
    vImage_Buffer srcBuffer;
    vImage_Error error = [self ab_getVImageBuffer:&srcBuffer scaledToSize:size];
    
    if (error != kvImageNoError) {
        return self;
    }
    
    
    vImage_Buffer dstBuffer = {
        .height = srcBuffer.height,
        .width = srcBuffer.width,
        .rowBytes = srcBuffer.rowBytes,
        .data = malloc(srcBuffer.height * srcBuffer.rowBytes * sizeof(uint8_t))
    };
    
    uint32_t boxSize = trunc(radius.floatValue * kGausianToTentRadiusRatio);
    boxSize |= 1;
    
    error = vImageTentConvolve_ARGB8888(&srcBuffer, &dstBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    free(srcBuffer.data);
    
    if (error != kvImageNoError) {
        free(dstBuffer.data);
        return self;
    }
    
    vImage_CGImageFormat format = [[self class] argb888Format];
    CGImageRef cgResult = vImageCreateCGImageFromBuffer(&dstBuffer, &format, NULL, NULL, kvImageNoFlags, &error);
    free(dstBuffer.data);

    if (error != kvImageNoError) {
        CGImageRelease(cgResult);
        return self;
    }

    UIImage *result = [UIImage imageWithCGImage:cgResult scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgResult);
    
    return result;
}


- (vImage_Error)ab_getVImageBuffer:(vImage_Buffer *)resultBuffer scaledToSize:(CGSize)size {
    CGFloat ratio = 0;
    
    if (self.size.width > size.width) {
        ratio = size.width / self.size.width;
    }
    
    if (self.size.height > size.height) {
        ratio = MIN(ratio, size.height / self.size.height);
    }
    
    if (!ratio) {
        ratio = 1;
    }
    
    CGSize resultSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    CGImageRef sourceRef = self.CGImage;
    vImage_Buffer srcBuffer;

    vImage_CGImageFormat format = [[self class] argb888Format];
    vImage_Error error = vImageBuffer_InitWithCGImage(&srcBuffer, &format, NULL, sourceRef, kvImageNoFlags);
    
    if (error != kvImageNoError) {
        free(srcBuffer.data);
        return error;
    }
    
    if (ratio == 1) {
        *resultBuffer = srcBuffer;
        return kvImageNoError;
    }
    
    const NSUInteger dstWidth = (NSUInteger)resultSize.width;
    const NSUInteger dstHeight = (NSUInteger)resultSize.height;
    const NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(sourceRef);
    const NSUInteger dstBytesPerRow = bytesPerPixel * dstWidth;
    uint8_t* dstData = (uint8_t*)calloc(dstHeight * dstWidth * bytesPerPixel, sizeof(uint8_t));
    vImage_Buffer dstBuffer = {
        .data = dstData,
        .height = dstHeight,
        .width = dstWidth,
        .rowBytes = dstBytesPerRow
    };
    
    error = vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageHighQualityResampling);
    free(srcBuffer.data);
    
    if (error != kvImageNoError)
    {
        free(dstData);
        return error;
    }

    *resultBuffer = dstBuffer;
    return kvImageNoError;
}

+ (vImage_CGImageFormat)argb888Format {
    vImage_CGImageFormat format = {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = NULL,
        .bitmapInfo = (CGBitmapInfo)kCGImageAlphaFirst,
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault,
    };
    
    return format;
}


@end
