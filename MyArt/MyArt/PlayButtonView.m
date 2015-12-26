//
//  PlayButtonView.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "PlayButtonView.h"

@implementation PlayButtonView

- (IBAction)cycleState:(id)sender {
    self.operation((UIButton *)sender);
    NSLog(@"");
}

//播放和暂停
- (IBAction)playAndPause:(id)sender {
    self.operation((UIButton *)sender);
}

//下一首
- (IBAction)playNext:(id)sender {
    self.operation((UIButton *)sender);
}

//上一首
- (IBAction)playPrevious:(id)sender {
    self.operation((UIButton *)sender);
}

- (IBAction)other:(id)sender {
    self.operation((UIButton *)sender);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
