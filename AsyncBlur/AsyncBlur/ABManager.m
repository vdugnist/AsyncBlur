//
//  BlurManager.m
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABManager.h"
#import "UIImage+AB.h"

@interface BlurTask : NSObject
@property (nonatomic) UIImage *image;
@property (nonatomic) NSNumber *blurRadius;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) void (^blurCallback)(UIImage *blurredImage);
@end

@implementation BlurTask
@end

@interface ABManager ()
@property BOOL isRenderring;
@property (nonatomic) NSMutableArray *tasks;
@property (nonatomic) dispatch_queue_t blurQueue;
@end

static CGFloat const kDefaultRadius = 35.0;

@implementation ABManager

+ (ABManager *)sharedInstance
{
    static ABManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ABManager new];
        manager.tasks = [NSMutableArray new];
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
        manager.blurQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], attributes);
    });
    return manager;
}

+ (void)renderBlurForImage:(UIImage *)image andSetInImageView:(UIImageView *)imageView
{
    return [self renderBlurForImage:image radius:@(kDefaultRadius) andSetInImageView:imageView];
}

+ (void)renderBlurForImage:(UIImage *)image radius:(NSNumber *)radius andSetInImageView:(UIImageView *)imageView
{
    return [self renderBlurForImage:image forImageView:imageView radius:radius withCallback:nil];
}

+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView withCallback:(void (^)(UIImage *))callback
{
    return [self renderBlurForImage:image forImageView:imageView radius:@(kDefaultRadius) withCallback:callback];
}

+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView radius:(NSNumber *)radius withCallback:(void (^)(UIImage *))callback
{
    BlurTask *task = [BlurTask new];
    task.image = image;
    task.imageView = imageView;
    task.blurCallback = callback;
    task.blurRadius = radius;
    
    if ((task.blurRadius.floatValue <= 0) || !task.image || TARGET_IPHONE_SIMULATOR) {
        [[self sharedInstance] removeTasksSimilarTo:task];
        completeTask(task, task.image);
        return;
    }
    
    [[self sharedInstance] addTask:task];
}


- (void)addTask:(BlurTask *)task {
    [self.tasks addObject:task];
    [self startRenderring];
}

- (void)startRenderring {
    if (self.isRenderring) {
        return;
    }
    
    [self renderNextImage];
}

- (void)renderNextImage
{
    if (!_tasks.count) {
        self.isRenderring = NO;
        return;
    }
    
    self.isRenderring = YES;
    
    BlurTask *taskToRender = [_tasks lastObject];
    [self removeTasksSimilarTo:taskToRender];
    [self executeTask:taskToRender];
}

- (void)removeTasksSimilarTo:(BlurTask *)task {
    @synchronized (self) {
        NSIndexSet *unnecessaryTasks = [_tasks indexesOfObjectsPassingTest:^BOOL(BlurTask* obj, NSUInteger idx, BOOL *stop) {
            return !obj.imageView || obj.imageView == task.imageView;
        }];
        
        [_tasks removeObjectsAtIndexes:unnecessaryTasks];
    }
}

- (void)executeTask:(BlurTask *)task
{
    if (!task.blurRadius.floatValue) {
        completeTask(task, task.image);
        [self renderNextImage];
        return;
    }
    
    dispatch_async(self.blurQueue, ^{
        UIImage *blurred = nil;
        
        if (task.imageView) {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize imageSizeInPoints = task.imageView.frame.size;
            CGSize imageSizeInPixels = CGSizeMake(imageSizeInPoints.width * scale, imageSizeInPoints.height * scale);
            blurred = [task.image ab_blurredImageWithRadius:task.blurRadius scaledToSize:imageSizeInPixels];
        } else {
            blurred = [task.image ab_blurredImageWithRadius:task.blurRadius];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeTask(task, blurred);
            [self renderNextImage];
        });
    });
}

void completeTask(BlurTask *task, UIImage *blurredImage) {
    if (task.blurCallback) {
        task.blurCallback(blurredImage);
    } else if (task.imageView) {
        [task.imageView setImage:blurredImage];
    }
}

@end
