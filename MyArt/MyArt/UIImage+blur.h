//
//  UIImage+blur.h
//  MyArt
//
//  Created by 007 on 16/5/21.
//  Copyright © 2016年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (blur)

/**
参数 tintColor 上层蒙层的颜色
*/
- (UIImage *)blurWithColor:(UIColor *)tintColor;

@end
