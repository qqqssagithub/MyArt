//
//  MostColor.m
//  MyArt
//
//  Created by 007 on 16/5/13.
//  Copyright © 2016年 陈少文. All rights reserved.
//

#import "MostColor.h"

//static void RGBtoHSV( float r, float g, float b, float* h, float* s, float* v)
//{
//    float min, max, delta;
//    min = MIN( r, MIN( g, b ));
//    max = MAX( r, MAX( g, b ));
//    *v = max;               // v
//    delta = max - min;
//    if( max != 0 )
//        *s = delta / max;       // s
//    else {
//        // r = g = b = 0        // s = 0, v is undefined
//        *s = 0;
//        *h = -1;
//        return;
//    }
//    if( r == max )
//        *h = ( g - b ) / delta;     // between yellow & magenta
//    else if( g == max )
//        *h = 2 + ( b - r ) / delta; // between cyan & yellow
//    else
//        *h = 4 + ( r - g ) / delta; // between magenta & cyan
//    *h *= 60;               // degrees
//    if( *h < 0 )
//        *h += 360;
//}

@implementation MostColor

- (BOOL)mostColor:(UIImage*)image{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(SCREEN_WIDTH /2, 30);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    
    if (data == NULL) return nil;
    
    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    
    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {
            
            int offset = 4*(x*y);
            
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];
            
            NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
            [cls addObject:clr];
            
        }
    }
    CGContextRelease(context);
    
    
    //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    
    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;
    
    while ( (curColor = [enumerator nextObject]) != nil )
    {
        NSUInteger tmpCount = [cls countForObject:curColor];
        
        if ( tmpCount < MaxCount ) continue;
        
        MaxCount=tmpCount;
        MaxColor=curColor;
        
    }

    
    BOOL isWhite;
    
    if ([MaxColor[0] intValue] >240 && [MaxColor[1] intValue] >240 && [MaxColor[2] intValue] >240 && [MaxColor[3] intValue] >240) {
        isWhite = YES;
    } else {
        isWhite = NO;
    }
    
//    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
    return isWhite;
}

@end
