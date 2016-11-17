//
//  BlurManager.h
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage, UIImageView;

NS_ASSUME_NONNULL_BEGIN

@interface ABManager : NSObject


/**
 Blurring on simulator is disabled by default for performance reasons.
 @param shouldBlurOnSimulator pass here YES to enable blur on simulator. NO by default.
 */
+ (void)setShouldBlurOnSimulator:(BOOL)shouldBlurOnSimulator;


/**
 Blur image with default radius and set in image view. If image view is nil, nothing will happen.
 Image view is also used for optimization: if you call this method with one image view and different images, 
 only last operation in queue will be executed. It's useful for blurring background in table view cells or other
 collections. 
 
 @param image image to blur
 @param imageView imageView to set result in
 */
+ (void)renderBlurForImage:(UIImage *)image andSetInImageView:(nullable UIImageView *)imageView;


/**
 Blur image with given radius and set in image view. If image view is nil, nothing will happen.
 With zero blur radius you'll get original image.
 Image view is also used for optimization: if you call this method with one image view and different images
 or with different blur radius, only last operation in queue will be executed.

 @param image image to blur
 @param radius blur radius
 @param imageView image view to set result in
 */
+ (void)renderBlurForImage:(UIImage *)image radius:(CGFloat)radius andSetInImageView:(nullable UIImageView *)imageView;



/**
 Blur image with default radius. If callback is passed, will not set result in image view.
 If callback is not passed, will set result in image view.
 Image view is also used for optimization: if you call this method with one image view and different images,
 only last operation in queue will be executed. It's useful for blurring background in table view cells or other
 collections.
 
 @param image image to blur
 @param imageView image view to set result in
 @param callback callback with result
 */
+ (void)renderBlurForImage:(UIImage *)image
              forImageView:(nullable UIImageView *)imageView
              withCallback:(void (^ _Nullable)(UIImage *blurredImage))callback;

/**
 Blur image with given radius. If callback passed, will not set result in image view.
 If callback is not passed, will set result in image view.
 Image view is also used for optimization: if you call this method with one image view and different images
 or with different blur radius, only last operation in queue will be executed.
 
 @param image image to blur
 @param imageView image view to set result in
 @param raius blur radius
 @param callback callback with result
 */
+ (void)renderBlurForImage:(UIImage *)image
              forImageView:(nullable UIImageView *)imageView
                    radius:(CGFloat)radius
              withCallback:(void (^ _Nullable)(UIImage *blurredImage))callback;

@end

NS_ASSUME_NONNULL_END
