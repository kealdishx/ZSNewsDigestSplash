//
//  ZSDotLayer.m
//  ZSNewsDigestSplash
//
//  Created by zakariyyaSv on 2016/10/26.
//  Copyright © 2016年 zakariyyaSv. All rights reserved.
//

#import "ZSDotLayer.h"
#import <UIKit/UIKit.h>

@implementation ZSDotLayer

- (instancetype)initWithCircleCenter:(CGPoint)center radius:(CGFloat)radius{
    if (self = [super init]) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointZero radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        self.path = path.CGPath;
        self.position = center;
        self.strokeColor = [UIColor clearColor].CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
    }
    return self;
}

@end
