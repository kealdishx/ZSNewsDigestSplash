//
//  ZSSplashManager.h
//  ZSNewsDigestSplash
//
//  Created by zakariyyaSv on 2016/10/26.
//  Copyright © 2016年 zakariyyaSv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion)();

@interface ZSSplashManager : NSObject

// set interval of dot circle animation cycle, default is 1.5s.
+ (void)setDotCircleDuration:(CFTimeInterval)duration;

// begin circle animation
+ (void)startAnimation;

// end circle animation and remove animation view.
+ (void)stopAnimationWithCompletion:(completion)completion;

@end
