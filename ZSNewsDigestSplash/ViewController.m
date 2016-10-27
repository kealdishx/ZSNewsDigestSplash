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
    
    [ZSSplashManager startAnimationWithCompletion:nil];
}


@end
