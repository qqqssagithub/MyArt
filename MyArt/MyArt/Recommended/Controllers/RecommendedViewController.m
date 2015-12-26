//
//  RecommendedViewController.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "RecommendedViewController.h"
#import "RecommendedModel.h"
#import "MainTableViewCell.h"
#import "DBSphereView.h"

#define URL @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.diy.gedanInfo&from=ios&listid=5126&version=5.5.1&from=ios&channel=appstore"

@interface RecommendedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bigActivityView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UIView *tempView;

@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *songList;

@property (nonatomic, retain) DBSphereView *sphereView;

@end



@implementation RecommendedViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tempView.layer.cornerRadius = 5.0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songList = [NSMutableArray array];
    [self.activityView startAnimating];
    [self.bigActivityView startAnimating];
    self.activityView.hidesWhenStopped = YES;
    self.bigActivityView.hidesWhenStopped = YES;
    self.dataSource = [NSMutableArray array];
    [self.loadButton setTitle:@"精彩内容加载中..." forState:UIControlStateNormal];
    self.loadButton.enabled = NO;
    [self fetchData];
}

#pragma mark - UI
- (void)customMainView{
    [_topImageView sd_setImageWithURL:[self.dataSource lastObject][@"pic_w700"]];
    [UIView animateWithDuration:0.5 animations:^{
        _topImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        UITapGestureRecognizer * tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGR:)];
        [_topImageView addGestureRecognizer:tapGR];
        _titleLabel.text = [self.dataSource lastObject][@"title"];
        _tagLabel.text = [self.dataSource lastObject][@"tag"];
        _descLabel.text = [self.dataSource lastObject][@"desc"];
    }];
}

- (void)tapGR:(UITapGestureRecognizer *)tapGR{
    [self.view addSubview:self.sphereView];
    self.topImageView.alpha = 0.1;
}

#pragma mark - 网络请求

- (void)fetchData{
    [[NetDataEngine sharedInstance] GET:URL success:^(id responsData) {
        self.dataSource = [RecommendedModel parseRespondsData:responsData];
        [self loadSongList];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)loadSongList{
    for (int i = 0; i < self.dataSource.count - 1; i++) {
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, ((RecommendedModel *)(self.dataSource[i])).song_id, SONG_URL_X] success:^(id responsData) {
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            [self.songList addObject:oneSong];
            if (self.songList.count == self.dataSource.count - 1) {
                [UIView animateWithDuration:0.5 animations:^{
                    _topImageView.alpha =0.0;
                    self.activityView.alpha = 0.0;
                    self.bigActivityView.alpha = 0.0;
                    self.tempLabel.alpha = 0.0;
                    self.tempView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self customMainView];
                    [self.activityView stopAnimating];
                    [self.bigActivityView stopAnimating];
                    [self.tempLabel removeFromSuperview];
                    [self.tempView removeFromSuperview];
                    self.tempLabel = nil;
                    self.tempView = nil;
                    [self.loadButton setTitle:@"进入歌曲列表  >>>>>>" forState:UIControlStateNormal];
                    self.loadButton.enabled = YES;
                    _topImageView.userInteractionEnabled = YES;
                }];
            }
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - 加载音乐
- (IBAction)nextMusic:(id)sender {
    self.loadMusic(self.songList);
}


- (DBSphereView *)sphereView{
    _sphereView = [[DBSphereView alloc] initWithFrame:CGRectMake(5, 5, self.topImageView.bounds.size.width - 10, self.topImageView.bounds.size.width - 10)];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < self.songList.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = 4000 + i;
        [btn setTitle:((SongModel *)self.songList[i]).author forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:arc4random()%256/256.0 green:(arc4random()%256)/256.0 blue:(arc4random()%256)/256.0 alpha:1] forState:UIControlStateNormal];
        btn.lineBreakMode = NSLineBreakByTruncatingTail;
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        btn.frame = CGRectMake(0, 0, 50, 20);
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:btn];
        [_sphereView addSubview:btn];
    }
    [_sphereView setCloudTags:array];
    _sphereView.backgroundColor = [UIColor clearColor];
    return _sphereView;
}

- (void)buttonPressed:(UIButton *)btn{
    self.loadSong(btn.tag - 4000, self.songList);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
