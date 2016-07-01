//
//  ABImageView.h
//  AsyncBlur
//
//  Created by Dugnist Vladislav on 01/06/16.
//  Copyright (c) 2016 MachineLearningWorks. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ABImageView : UIImageView

@property (nonatomic) CGFloat blurRadius;
@property (nonatomic) BOOL disableBlur;

@end
