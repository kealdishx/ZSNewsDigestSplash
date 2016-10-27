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

+ (void)startAnimationWithCompletion:(completion)completionBlock;

@end
