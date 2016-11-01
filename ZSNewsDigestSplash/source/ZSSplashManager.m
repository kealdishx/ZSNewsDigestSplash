//
//  ZSSplashManager.m
//  ZSNewsDigestSplash
//
//  Created by zakariyyaSv on 2016/10/26.
//  Copyright © 2016年 zakariyyaSv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSSplashManager.h"
#import "ZSDotLayer.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define colorRed RGB(252,63,146)
#define colorOrange RGB(253,148,38)
#define colorDarkGreen RGB(34,108,172)
#define colorLightGreen RGB(37,223,155)
#define colorYellow RGB(254,209,48)
#define colorBlue RGB(34,199,252)

static int count = 0;
static const CGFloat preAnimDuration = 0.3f;
static const CGFloat circleRadius = 30;
static const CGFloat dotRadius = 6;
static CGFloat dotCircleDuration = 1.5;
static const CGFloat lineDuration = 2.0f;
static const CGFloat delayInterval = 0.15f;
static const int dotCount = 6;
static const CGFloat lineLength = 20;
static NSString *const dotCircleAnimName = @"dotCircleAnimName";
static NSString *const bounceAnimName = @"bounceAnimName";
static NSString *const circleMaskAnimName = @"circleMaskAnimaName";
static NSString *const lineAnimationName = @"lineAnimationName";
static NSString *const animKey = @"animKey";

@interface ZSSplashManager()<CAAnimationDelegate>

@property (nonatomic,assign) CGPoint center;

@property (nonatomic,strong) UIView *baseView;

@property (nonatomic,strong) NSMutableArray *dotLayerArr;

@property (nonatomic,strong) NSMutableArray *dotAnimationArr;

@property (nonatomic,strong) ZSDotLayer *centerCircleLayer;

@property (nonatomic,strong) dispatch_source_t colourTimer;

@property (nonatomic,assign) CGColorRef topDotColor;

@property (nonatomic,assign) BOOL isAnimating;

@property (nonatomic,strong) CABasicAnimation *circleMaskAnimation;

@property (nonatomic,assign) CFAbsoluteTime startTime;

@property (nonatomic,strong) completion completionBlock;

@end

@implementation ZSSplashManager

#pragma mark - class method
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static ZSSplashManager *_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZSSplashManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)startAnimation{
    [[self sharedInstance] startAnimation];
}

+ (void)stopAnimationWithCompletion:(completion)completion{
    [[self sharedInstance] stopAnimationWithCompletion:completion];
}

+ (void)setDotCircleDuration:(CFTimeInterval)duration{
    dotCircleDuration = duration;
}

#pragma mark - private method
- (void)startAnimation{
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    
    [self createDotLayers];
    [UIView animateWithDuration:preAnimDuration animations:^{
        self.baseView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            for (ZSDotLayer *dotLayer in self.dotLayerArr) {
                [self addDotCircleAnimationTodotLayer:dotLayer];
            }
            self.startTime = CFAbsoluteTimeGetCurrent();
            dispatch_resume(self.colourTimer);
        }
    }];
    
}

- (void)stopAnimationWithCompletion:(completion)completion{
    if (!_isAnimating) {
        return;
    }
    
    // stop timer
    dispatch_source_cancel(self.colourTimer);
    self.colourTimer = nil;
    count = 0;
    
    for (ZSDotLayer *dotLayer in self.dotLayerArr) {
        [dotLayer removeAllAnimations];
    }
    
    CFTimeInterval interval = CFAbsoluteTimeGetCurrent() - self.startTime;
    CGFloat endAngle = 1.0 * interval / dotCircleDuration * 2.0 * M_PI;
    for (ZSDotLayer *dotLayer in self.dotLayerArr) {
        int dotTag = [dotLayer.name intValue];
        CGFloat angle = (dotTag + 2) * M_PI / 3.0;
        CGPoint startPoint = CGPointMake(self.center.x + circleRadius * cos(endAngle - angle), self.center.y + circleRadius * sin(endAngle - angle));
        dotLayer.position = startPoint;
        CAKeyframeAnimation *linePositionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        linePositionAnimation.path = [self linePositionPathWithStartPoint:startPoint angle:endAngle - angle].CGPath;
        linePositionAnimation.duration = lineDuration;
        linePositionAnimation.beginTime = CACurrentMediaTime() + delayInterval;
        linePositionAnimation.fillMode = kCAFillModeBoth;
        linePositionAnimation.removedOnCompletion = NO;
        linePositionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        linePositionAnimation.delegate = self;
        [linePositionAnimation setValue:lineAnimationName forKey:animKey];
        [dotLayer addAnimation:linePositionAnimation forKey:lineAnimationName];
    }
    
    if (completion) {
        self.completionBlock = completion;
    }
}

- (void)changeDotLayerColor{
    count++;
    for (ZSDotLayer *layer in self.dotLayerArr) {
        int tag = [layer.name intValue];
        layer.fillColor = [self dotLayerColorWithTag: abs(tag - count)].CGColor;
        if (tag == dotCount - 1) {
            self.topDotColor = layer.fillColor;
        }
    }
}

- (UIColor *)dotLayerColorWithTag:(int)tag{
    UIColor *dotColor;
    switch (tag % dotCount) {
        case 0:
            dotColor = colorOrange;
            break;
        case 1:
            dotColor = colorDarkGreen;
            break;
        case 2:
            dotColor = colorYellow;
            break;
        case 3:
            dotColor = colorBlue;
            break;
        case 4:
            dotColor = colorLightGreen;
            break;
        case 5:
            dotColor = colorRed;
            break;
        default:
            break;
    }
    return dotColor;
}

- (void)createDotLayers{
    if (!self.baseView) {
        return;
    }
    for (int i = 0; i < dotCount; i++) {
        ZSDotLayer *dotLayer = [[ZSDotLayer alloc] initWithCircleCenter:[self dotLayerCenterWithTag:i] radius:dotRadius];
        dotLayer.name = [NSString stringWithFormat:@"%d",i];
        dotLayer.fillColor = [self dotLayerColorWithTag:i].CGColor;
        [self.dotLayerArr addObject:dotLayer];
        [self.baseView.layer addSublayer:dotLayer];
    }
    
}

- (CGPoint)dotLayerCenterWithTag:(int)tag{
    CGPoint dotCenter = CGPointMake(self.center.x + circleRadius * cos(tag * M_PI / 3.0), self.center.y + circleRadius * sin(tag * M_PI / 3.0));
    return dotCenter;
}

- (void)addDotCircleAnimationTodotLayer:(ZSDotLayer *)dotlayer{
    int tag = [dotlayer.name intValue];
    CAKeyframeAnimation *dotCircleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    dotCircleAnimation.path = [self activityPathWithStartAngle: tag * M_PI / 3.0].CGPath;
    dotCircleAnimation.duration = dotCircleDuration;
    dotCircleAnimation.repeatCount = HUGE_VALF;
    dotCircleAnimation.removedOnCompletion = NO;
    dotCircleAnimation.fillMode = kCAFillModeForwards;
    dotCircleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [dotCircleAnimation setValue:dotCircleAnimName forKey:animKey];
    [dotlayer addAnimation:dotCircleAnimation forKey:dotCircleAnimName];
}

- (UIBezierPath *)activityPathWithStartAngle:(CGFloat)startAngle{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.center radius:circleRadius startAngle:startAngle endAngle: startAngle - 2.0 * M_PI  clockwise:NO];
    return path;
}

- (UIBezierPath *)linePositionPathWithStartPoint:(CGPoint)startPoint angle:(CGFloat)angle{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:CGPointMake(self.center.x + (lineLength + circleRadius) * cos(angle), self.center.y + (lineLength + circleRadius) * sin(angle))];
    [path addLineToPoint:self.center];
    return path;
}

- (void)removeDotLayers{
    if (!self.centerCircleLayer) {
        return;
    }
    if (self.dotLayerArr.count > 0) {
        CAKeyframeAnimation *bounceAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnim.values = @[@1,@4,@1,@0];
        bounceAnim.duration = 1.0;
        bounceAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        bounceAnim.removedOnCompletion = NO;
        bounceAnim.fillMode = kCAFillModeForwards;
        bounceAnim.delegate = self;
        [bounceAnim setValue:bounceAnimName forKey:animKey];
        [self.centerCircleLayer addAnimation:bounceAnim forKey:bounceAnimName];
        
        for (ZSDotLayer *layer in self.dotLayerArr) {
            layer.hidden = YES;
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
        [self.dotLayerArr removeAllObjects];

    }
    
}

- (void)addCircleMaskAnimation{
    CGFloat maxRadius = sqrt(pow(self.baseView.bounds.size.width * 0.5, 2) + pow(self.baseView.bounds.size.height * 0.5, 2));
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = [self circlePathWithRadius:maxRadius].CGPath;
    self.baseView.layer.mask = maskLayer;
    CABasicAnimation *circleMaskAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    circleMaskAnim.duration = 0.5;
    circleMaskAnim.delegate = self;
    circleMaskAnim.fromValue = (__bridge id)[self circlePathWithRadius:dotRadius].CGPath;
    circleMaskAnim.toValue = (__bridge id)[self circlePathWithRadius:maxRadius].CGPath;
    [circleMaskAnim setValue:circleMaskAnim forKey:circleMaskAnimName];
    [maskLayer addAnimation:circleMaskAnim forKey:circleMaskAnimName];
    
}

- (UIBezierPath *)circlePathWithRadius:(CGFloat)radius{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.baseView.bounds];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES]];
    return path;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSString *value = [anim valueForKey:animKey];
    if ([value isEqualToString:lineAnimationName]) {
        
        [self removeDotLayers];
    }
    else if ([value isEqualToString:bounceAnimName]) {
        
        self.centerCircleLayer.hidden = YES;
        [self.centerCircleLayer removeAllAnimations];
        [self.centerCircleLayer removeFromSuperlayer];
        self.centerCircleLayer = nil;
        [self addCircleMaskAnimation];
        
    }
    else{
            
        self.baseView.hidden = YES;
        [self.baseView removeFromSuperview];
        self.baseView = nil;
        _isAnimating = NO;
        if (self.completionBlock) {
            self.completionBlock();
        }
    }
    
}

#pragma mark - lazy method
- (UIView *)baseView{
    if (!_baseView) {
        _baseView = [[UIView alloc] init];
        _baseView.backgroundColor = [UIColor whiteColor];
        _baseView.hidden = NO;
        _baseView.alpha = 0;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            _baseView.frame = window.bounds;
            self.center = CGPointMake(window.bounds.size.width * 0.5, window.bounds.size.height * 0.5);
            [window addSubview:_baseView];
        }
        else {
            NSLog(@"window not exists!");
            return nil;
        }
    }
    return _baseView;
}

- (NSMutableArray *)dotLayerArr{
    if (!_dotLayerArr) {
        _dotLayerArr = [NSMutableArray arrayWithCapacity:dotCount];
    }
    return _dotLayerArr;
}

- (NSMutableArray *)dotAnimationArr{
    if (!_dotAnimationArr) {
        _dotAnimationArr = [NSMutableArray arrayWithCapacity:dotCount];
    }
    return _dotAnimationArr;
}

- (ZSDotLayer *)centerCircleLayer{
    if (!_centerCircleLayer) {
        _centerCircleLayer = [[ZSDotLayer alloc] initWithCircleCenter:self.center radius:dotRadius];
        _centerCircleLayer.fillColor = self.topDotColor;
        [self.baseView.layer addSublayer:_centerCircleLayer];
    }
    return _centerCircleLayer;
}

- (dispatch_source_t)colourTimer{
    if (!_colourTimer) {
        _colourTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        if (_colourTimer) {
            dispatch_source_set_timer(_colourTimer, dispatch_walltime(NULL, 0), 0.1 * NSEC_PER_SEC, 0.001);
            dispatch_source_set_event_handler(_colourTimer, ^{
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self changeDotLayerColor];
               });
            });
        }
    }
    return _colourTimer;
}

@end
