//
//  NetworkRefreshFailedView.m
//  MyArt
//
//  Created by 007 on 16/4/26.
//  Copyright © 2016年 陈少文. All rights reserved.
//

#import "NetworkRefreshFailedView.h"

@implementation NetworkRefreshFailedView

- (id)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH +10, SCREEN_HEIGHT -64 -49);
        self.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        label.text = @"网络不给力呀! >_<|||\n点击界面刷新";
        label.textColor = [UIColor colorWithRed:0.16 green:0.72 blue:1.0 alpha:1.0];
        label.center = self.center;
        label.textAlignment = 1;
        label.numberOfLines = 0;
        [self addSubview:label];
        self.userInteractionEnabled = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
