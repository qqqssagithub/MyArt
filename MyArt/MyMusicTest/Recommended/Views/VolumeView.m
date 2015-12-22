//
//  VolumeView.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/20.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "VolumeView.h"

@implementation VolumeView

- (IBAction)volume:(id)sender {
    self.volume(((UISlider *)sender).value);
}

- (IBAction)hidden:(id)sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y + self.bounds.size.height);
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
