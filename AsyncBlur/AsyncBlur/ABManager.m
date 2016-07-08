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
@property (nonatomic) BOOL isRenderring;
@property (nonatomic) NSMutableArray *tasks;
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
    
    if (!task.blurRadius.floatValue || !task.image || TARGET_IPHONE_SIMULATOR) {
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
    if (_isRenderring) {
        return;
    }
    
    [self renderNextImage];
}

- (void)renderNextImage
{
    if (!_tasks.count) {
        _isRenderring = NO;
        return;
    }
    
    _isRenderring = YES;
    
    BlurTask *taskToRender = [_tasks lastObject];
    
    NSIndexSet *unnecessaryTasks = [_tasks indexesOfObjectsPassingTest:^BOOL(BlurTask* task, NSUInteger idx, BOOL *stop) {
        return !task.imageView || task.imageView == taskToRender.imageView;
    }];
    
    [_tasks removeObjectsAtIndexes:unnecessaryTasks];
    
    [self executeTask:taskToRender];
}

- (void)executeTask:(BlurTask *)task
{
    if (!task.blurRadius.floatValue) {
        completeTask(task, task.image);
        [self renderNextImage];
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        UIImage *blurred = [task.image ab_blurredImageWithRadius:task.blurRadius];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeTask(task, blurred);
            [self renderNextImage];
        });
    });
}

void completeTask(BlurTask *task, UIImage *blurredImage) {
    if (task.imageView && task.blurCallback) {
        task.blurCallback(blurredImage);
    } else if (task.imageView) {
        [task.imageView setImage:blurredImage];
    }
}

@end
