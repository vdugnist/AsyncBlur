//
//  UIImage+AB.m
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import <objc/runtime.h>
#import <Accelerate/Accelerate.h>
#import "UIImage+AB.h"

static CGFloat const kGausianToTentRadiusRatio = 5;

@interface ABImageCache : NSObject

@property (nonatomic, strong) NSValue *scaledNonBlurredBuffer;

@end

@implementation ABImageCache

- (void)dealloc {
    if (self.scaledNonBlurredBuffer) {
        vImage_Buffer buffer;
        [self.scaledNonBlurredBuffer getValue:&buffer];
        free(buffer.data);
    }
}

@end

@interface UIImage ()

@property (nonatomic, strong) ABImageCache *abImageCache;

@end

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
    
    vImage_Error(^completeWithBufferAndError)(vImage_Buffer buffer, vImage_Error error) = ^vImage_Error(vImage_Buffer buffer, vImage_Error error) {
        if (!self.abImageCache && error == kvImageNoError) {
            self.abImageCache = [ABImageCache new];
            self.abImageCache.scaledNonBlurredBuffer = [NSValue valueWithBytes:&buffer objCType:@encode(vImage_Buffer)];
        }
        
        *resultBuffer = buffer;
        return error;
    };
    
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
    
    if (self.abImageCache != nil) {
        vImage_Buffer buffer;
        [self.abImageCache.scaledNonBlurredBuffer getValue:&buffer];
        if (buffer.width == (vImagePixelCount)resultSize.width &&
            buffer.height == (vImagePixelCount)resultSize.height) {
            return completeWithBufferAndError(buffer, kvImageNoError);
        }
    }
    
    CGImageRef sourceRef = self.CGImage;
    vImage_Buffer srcBuffer;

    vImage_CGImageFormat format = [[self class] argb888Format];
    vImage_Error error = vImageBuffer_InitWithCGImage(&srcBuffer, &format, NULL, sourceRef, kvImageNoFlags);
    
    if (error != kvImageNoError) {
        free(srcBuffer.data);
        return error;
    }
    
    if (ratio == 1) {
        return completeWithBufferAndError(srcBuffer, error);
    }
    
    const vImagePixelCount dstWidth = (vImagePixelCount)resultSize.width;
    const vImagePixelCount dstHeight = (vImagePixelCount)resultSize.height;
    const vImagePixelCount bytesPerPixel = (vImagePixelCount)CGImageGetBitsPerPixel(sourceRef);
    const vImagePixelCount dstBytesPerRow = bytesPerPixel * dstWidth;
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

    return completeWithBufferAndError(dstBuffer, error);
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

- (ABImageCache *)abImageCache {
    return objc_getAssociatedObject(self, @selector(abImageCache));
}

- (void)setAbImageCache:(ABImageCache *)abImageCache {
    objc_setAssociatedObject(self, @selector(abImageCache), abImageCache, OBJC_ASSOCIATION_RETAIN);
}

@end
