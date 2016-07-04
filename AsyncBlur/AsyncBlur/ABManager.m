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
    [self renderBlurForImage:image radius:@(kDefaultRadius) andSetInImageView:imageView];
}

+ (void)renderBlurForImage:(UIImage *)image radius:(NSNumber *)radius andSetInImageView:(UIImageView *)imageView
{
    BlurTask *task = [BlurTask new];
    task.image = image;
    task.blurRadius = radius;
    task.imageView = imageView;
    
    [[self sharedInstance] addTask:task];
}

+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView withCallback:(void (^)(UIImage *))callback
{
    [self renderBlurForImage:image forImageView:imageView radius:@(kDefaultRadius) withCallback:callback];
}

+ (void)renderBlurForImage:(UIImage *)image forImageView:(UIImageView *)imageView radius:(NSNumber *)radius withCallback:(void (^)(UIImage *))callback
{
    BlurTask *task = [BlurTask new];
    task.image = image;
    task.imageView = imageView;
    task.blurCallback = callback;
    task.blurRadius = radius;
    
    [[self sharedInstance] addTask:task];
}


- (void)addTask:(BlurTask *)task {
    [self.tasks addObject:task];
    [self startRenderring];
}

- (void)startRenderring {
    if (_isRenderring) return;
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
    __weak ABManager *weakSelf = self;
    
    void(^completeWithImage)(UIImage *) = ^(UIImage *blurred) {
        if (task.imageView && task.blurCallback) {
            task.blurCallback(blurred);
        } else if (task.imageView) {
            [task.imageView setImage:blurred];
        }
        
        [weakSelf renderNextImage];
    };
    
    if (!task.blurRadius.floatValue) {
        completeWithImage(task.image);
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        UIImage *blurred = [task.image ab_blurredImageWithRadius:task.blurRadius];
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            completeWithImage(blurred);
        });
    });
}

@end
