//
//  ViewController.m
//  ZSNewsDigestSplash
//
//  Created by zakariyyaSv on 2016/10/26.
//  Copyright © 2016年 zakariyyaSv. All rights reserved.
//

#import "ViewController.h"
#import "ZSSplashManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [ZSSplashManager startAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZSSplashManager stopAnimationWithCompletion:nil];
    });
}


@end
