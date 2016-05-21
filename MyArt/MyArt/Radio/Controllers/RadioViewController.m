//
//  RadioViewController.m
//  MyMusicTest
//
//  Created by qqqssa on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "RadioViewController.h"
#import "RadioModel.h"


#define URL_CH @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.radio.getChannelSong&channelid=%@&channelname=%@&pn=0&rn=59&format=json&from=ios&baiduid=1bb92ffcf38c17a7d8a3b3e75361f0a85c8b7054&version=5.5.1&from=ios&channel=appstore"

@interface RadioViewController () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, copy) NSArray *radioNames;
@property (nonatomic, copy) NSArray *radioPic;
@property (nonatomic, copy) NSArray *tag;
@property (nonatomic) NSMutableArray *jingdianlaoge;
@property (nonatomic) NSMutableArray *rege;
@property (nonatomic) NSMutableArray *chengmingqu;
@property (nonatomic) NSMutableArray *oumei;
@property (nonatomic) NSMutableArray *wangluo;
@property (nonatomic) NSMutableArray *suibiantingting;
@property (nonatomic) NSMutableArray *dianyingyuansheng;

@property (nonatomic) NSMutableArray *songList;

@property (weak, nonatomic) IBOutlet UIImageView *imgV;

@property (nonatomic) UIAlertController *alertController;

@property (nonatomic) UILabel *label;

@property (nonatomic) NSString *tempRadioName;
@property (nonatomic) NSMutableArray *tempRadioArr;
@property (nonatomic) BOOL reload;

@end


@implementation RadioViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.imgV.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 -49);
    self.carousel.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 -49);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.radioNames = @[@"经典老歌", @"劲爆热歌", @"成名金曲", @"流行欧美", @"网络歌曲", @"随便听听", @"电影原声"];
    self.radioPic = @[@"jd.png", @"jg.png", @"cmq.png", @"om.png", @"wl.png", @"sbtt.png", @"dy.png"];
    self.tag = @[@(3000), @(3001), @(3002), @(3003), @(3004), @(3005), @(3006)];
    self.carousel.type = iCarouselTypeInvertedTimeMachine;
    self.carousel.pagingEnabled = YES;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    //初始化界面时的遮挡视图
    [KVNProgress showWithStatus:@"电台加载上线中,请稍等..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KVNProgress dismiss];
    });
    
    
    self.jingdianlaoge = [NSMutableArray array];
    self.rege = [NSMutableArray array];
    self.chengmingqu = [NSMutableArray array];
    self.oumei = [NSMutableArray array];
    self.wangluo = [NSMutableArray array];
    self.suibiantingting = [NSMutableArray array];
    self.dianyingyuansheng = [NSMutableArray array];
    
    self.songList = [[NSMutableArray alloc] init];
    
    [self loadRadio];
    
    
    //点击加载失败的频道时弹出的提示框
    _alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"此电台频道初始化失败,请重新加载" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reloadRadio:self.tempRadioName];
    }];
    [_alertController addAction:okAction];
    
    
    
}

#pragma mark - UI

- (void)loadRadio{
    NSArray *chArr = @[@"public_shiguang_jingdianlaoge", @"public_tuijian_rege", @"public_tuijian_chengmingqu", @"public_yuzhong_oumei", @"public_tuijian_wangluo", @"public_tuijian_suibiantingting", @"public_fengge_dianyingyuansheng"];
    NSArray *dataArr = @[self.jingdianlaoge, self.rege, self.chengmingqu, self.oumei, self.wangluo, self.suibiantingting, self.dianyingyuansheng];
    for (NSInteger index = 0; index < 7; index ++) {
        [self fetchData:[self getdate] ch:chArr[index] data:dataArr[index]];
    }
}

- (void)reloadRadio:(NSString *)radioName{
    [KVNProgress showWithStatus:@"电台重载中..."];
    self.reload = YES;
    [self fetchData:[self getdate] ch:radioName data:self.jingdianlaoge];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tempRadioArr.count == 0) {
            [KVNProgress showErrorWithStatus:@"电台重载失败"];
        }
    });
}

#pragma mark - iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 7;
}



//时光机
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.7, SCREEN_WIDTH * 0.7)];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGR:)];
        [imageView addGestureRecognizer:tapGR];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        //倒影
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.20f;
        imageView.reflectionGap = 20.0f;//倒影距离原物体的距离
        //投影
        imageView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        imageView.shadowBlur = 6.0f;
        imageView.cornerRadius = SCREEN_WIDTH * 0.7 /1;
        view = imageView;
        
//        UIImageView *imageView0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.7, SCREEN_WIDTH * 0.7)];
//        imageView0.center = view.center;
//        imageView0.layer.cornerRadius = SCREEN_WIDTH * 0.7 /2;
//        imageView0.image = [UIImage imageNamed:self.radioPic[index]];
//        [view addSubview:imageView0];
        
        imageView.tag = [self.tag[index] integerValue];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
        self.label.text = self.radioNames[index];
        self.label.textColor = [UIColor purpleColor];
        [imageView addSubview:self.label];
    }
    
    ((FXImageView *)view).image = [UIImage imageNamed:self.radioPic[index]];
    return view;

}

-(void)tapGR:(UITapGestureRecognizer *)tapGR{
    NSInteger index = tapGR.view.tag;
    switch (index) {
        case 3000:
            if (self.jingdianlaoge.count == 0) {
                self.tempRadioName = @"public_shiguang_jingdianlaoge";
                self.tempRadioArr = self.jingdianlaoge;
                [self presentViewController:_alertController animated:YES completion:nil];
                return;
            }
            self.openPlayViewBlock(self.jingdianlaoge);
            break;
        case 3001:
            if (self.rege.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_rege";
                self.tempRadioArr = self.rege;
                return;
            }
            self.openPlayViewBlock(self.rege);
            //public_tuijian_rege
            break;
        case 3002:
            if (self.chengmingqu.count == 0) {
                self.tempRadioArr = self.chengmingqu;
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_chengmingqu";
                return;
            }
            self.openPlayViewBlock(self.chengmingqu);
            //public_tuijian_chengmingqu
            break;
        case 3003:
            if (self.oumei.count == 0) {
                self.tempRadioArr = self.oumei;
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_yuzhong_oumei";
                return;
            }
            self.openPlayViewBlock(self.oumei);
            //public_yuzhong_oumei
            break;
        case 3004:
            if (self.wangluo.count == 0) {
                self.tempRadioArr = self.wangluo;
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_wangluo";
                return;
            }
            self.openPlayViewBlock(self.wangluo);
            //public_tuijian_wangluo
            break;
        case 3005:
            if (self.suibiantingting.count == 0) {
                self.tempRadioArr = self.suibiantingting;
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_suibiantingting";
                return;
            }
            self.openPlayViewBlock(self.suibiantingting);
            //public_tuijian_suibiantingting
            break;
        case 3006:
            if (self.dianyingyuansheng.count == 0) {
                self.tempRadioArr = self.dianyingyuansheng;
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_fengge_dianyingyuansheng";
                return;
            }
            self.openPlayViewBlock(self.dianyingyuansheng);
            //public_fengge_dianyingyuansheng
            break;
 
        default:
            break;
    }
}

- (void)loadSongList:(NSMutableArray *)data songData:songList{
    [self.songList removeAllObjects];
    for (int i = 0; i < data.count - 2; i++) {
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, data[i], SONG_URL_X] success:^(id responsData) {
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            //[self.songList addObject:oneSong];
            if (oneSong.songFiles.count != 0) {
                [songList addObject:oneSong];
            }
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}


- (NSString *)getdate{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH";
    NSString *formatDate = [format stringFromDate:[NSDate date]];
    NSLog(@"现在几点钟:%@", formatDate);
    return formatDate;
}

- (void)fetchData:(NSString *)page ch:(NSString *)ch data:(NSMutableArray *)songList{
    static int i = 0; static int j = 0; j = 0;
    NSString *url = [NSString stringWithFormat:URL_CH, page, ch];
    //[[NSString stringWithFormat:URL_CH, page, ch] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    [[NetDataEngine sharedInstance] GET:url success:^(id responsData) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic in responsData[@"result"][@"songlist"]) {
            //NSString *song_id = dic[@"songid"];
            if ([dic[@"songid"] isKindOfClass:[NSString class]]) {
                [arr addObject:dic[@"songid"]];
            }
            //[arr addObject:song_id];
        }
        i++; j++;
        [self loadSongList:arr songData:songList];
        NSLog(@"第%d次加载数据完成", i);
        if (i == 7) {
            NSLog(@"全部数据加载完成");
            [KVNProgress dismiss];
        } else if (j == 1 && self.reload) {
            [KVNProgress dismiss];
            self.reload = NO;
        }
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
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
