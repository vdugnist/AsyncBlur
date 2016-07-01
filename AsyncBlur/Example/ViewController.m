//
//  ViewController.m
//  AsyncBlur
//
//  Created by Vladislav Dugnist on 7/1/16.
//  Copyright © 2016 Vladislav Dugnist. All rights reserved.
//

#import "ViewController.h"
#import "AsyncBlur.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.slider addTarget:self action:@selector(sliderDidScroll:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderDidScroll:(UISlider *)slider {
    UIImage *image = [UIImage imageNamed:@"lena"];
    CGFloat maxBlur = 20;
    CGFloat currentBlur = slider.value * maxBlur;
    
    [ABManager renderBlurForImage:image radius:@(currentBlur) andSetInImageView:self.imageView];
}

@end
