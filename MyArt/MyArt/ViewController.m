//
//  ViewController.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/5.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "ViewController.h"
#import "RecommendedViewController.h"
#import "SongViewController.h"
#import "ListViewController.h"
#import "RadioViewController.h"
#import "MainTableViewCell.h"
#import "RecommendedModel.h"
#import "SongModel.h"
#import "SearchModel.h"
#import "LrcTableViewCell.h"
#import "SongDetail.h"

#define URL_SEARCH @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.merge&query=%@&page_size=15&page_no=1&type=-1&format=json&from=ios&version=5.5.1&from=ios&channel=appstore"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mine;
@property (nonatomic) NSArray *SongArray;
@property (nonatomic) BOOL IS_LIKE;
@property (nonatomic) BOOL IS_LIKEOPEN;
@property (nonatomic) SongDetail *oneSongDetail;
@property (nonatomic) NSArray *songs;

@property (weak, nonatomic) IBOutlet UIButton *search;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic) BOOL IS_SEARCHING;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonWidth;

@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSMutableArray *searchDate;

@property (weak, nonatomic) IBOutlet UIImageView *playViewBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UIView *imageV;
@property (weak, nonatomic) IBOutlet UIImageView *starImgV;
@property (weak, nonatomic) IBOutlet UITableView *lrcTableView;


@property (nonatomic) UIView *headerView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *headerLabel;


#pragma mark - baseView
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightA;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightD;


#pragma mark - player
@property (nonatomic) AVQueuePlayer *queuePlayer;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) MPNowPlayingInfoCenter *infoCenter;
@property (nonatomic) NSMutableArray *playerItems;

@property (weak, nonatomic) IBOutlet UISlider *audioSlider;//播放进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;//缓存进度条
@property (nonatomic) CGFloat totalSecond;//歌曲总时间(用秒计算)
@property (nonatomic) CGFloat currentSecond;//当前时间
@property (nonatomic) double buffer;//缓冲时间
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *hiddenLrcButton;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (nonatomic) PlayButtonView *playButtonView;
@property (nonatomic) VolumeView *volumeView;
@property (nonatomic) UIView *playPointView;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) CGPoint tempPoint;
@property (nonatomic) UIDynamicAnimator *animation;//物理动效
@property (weak, nonatomic) IBOutlet UIView *playBottomView;

#pragma mark - VC
@property (nonatomic) RecommendedViewController *recommendedVC;
@property (nonatomic) SongViewController *songVC;
@property (nonatomic) ListViewController *listVC;
@property (nonatomic) RadioViewController *radioVC;

#pragma mark - mainButtonView
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIButton *recommended;
@property (weak, nonatomic) IBOutlet UIButton *song;
@property (weak, nonatomic) IBOutlet UIButton *list;
@property (weak, nonatomic) IBOutlet UIButton *radio;

#pragma mark - tableView
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) SongModel *oneSong;

#pragma mark - lrcTableView
@property (nonatomic) NSMutableArray *timeArray;
@property (nonatomic) NSMutableArray *lrcArray;
@property (nonatomic) NSString *lrc;

#pragma mark _ tempViews
@property (nonatomic) UIView *tempView;
@property (nonatomic) UIAlertView *tempAlertView;

typedef NS_ENUM(NSInteger, CirculationMode) {
    CirculationModeIsCycle = 1,
    CirculationModeIsSingleCycle = 2,
    CirculationModeIsOrder = 3,
    CirculationModeIsRandom = 4,
};

@property(nonatomic) CirculationMode cycleMode;



@end


@implementation ViewController


#pragma mark - 预设播放控制View
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _tempAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"播放列表中没有任何歌曲" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    self.cycleMode = CirculationModeIsCycle;
    [_playButtonView.cycleButton setImage:[UIImage imageNamed:@"xunhuan1"] forState:UIControlStateNormal];
    
    self.baseView.backgroundColor = [UIColor colorWithRed:0.16 green:0.72 blue:1.0 alpha:1.0];
    self.menuView.backgroundColor = [UIColor colorWithRed:0.16 green:0.72 blue:1.0 alpha:1.0];
    
    
    self.cancelButtonWidth.constant = SCREEN_WIDTH / 8;
    self.heightA.constant = SCREEN_HEIGHT / 40;
    self.heightB.constant = SCREEN_HEIGHT / 80;
    self.heightC.constant = SCREEN_HEIGHT / 40;
    self.heightD.constant = SCREEN_HEIGHT / 40;
    [self.playView layoutIfNeeded];
    
    
    UINib *nib = [UINib nibWithNibName:@"PlayButtonView" bundle:nil];
    UINib *nibVolume = [UINib nibWithNibName:@"VolumeView" bundle:nil];
    _playButtonView = [[nib instantiateWithOwner:nil options:nil] firstObject];
    _volumeView = [[nibVolume instantiateWithOwner:nib options:nil] firstObject];
    _playButtonView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.playBottomView.bounds.size.height);
    [_playButtonView layoutIfNeeded];
    _volumeView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.playBottomView.bounds.size.height);
    [_volumeView layoutIfNeeded];
    [self.view addSubview:_playButtonView];
    [self.view addSubview:_volumeView];
    [self.view bringSubviewToFront:self.playPointView];
    self.isPlaying = NO;
    
    //开启高亮动画
    [_playButtonView.cycleButton setShowsTouchWhenHighlighted:YES];
    [_playButtonView.previousButton setShowsTouchWhenHighlighted:YES];
    [_playButtonView.playButton setShowsTouchWhenHighlighted:YES];
    [_playButtonView.nextButton setShowsTouchWhenHighlighted:YES];
    [_playButtonView.otherButton setShowsTouchWhenHighlighted:YES];
    [self.hiddenLrcButton setShowsTouchWhenHighlighted:YES];
    [self.hideButton setShowsTouchWhenHighlighted:YES];
    
    __block typeof(self) weakSelf = self;
    _playButtonView.operation = ^(UIButton *button){
        if (button.tag == 201) {
            if (weakSelf.cycleMode == CirculationModeIsCycle) {
                weakSelf.cycleMode = CirculationModeIsSingleCycle;
                [weakSelf.playButtonView.cycleButton setImage:[UIImage imageNamed:@"danqu1"] forState:UIControlStateNormal];
                return;
            }
            if (weakSelf.cycleMode == CirculationModeIsSingleCycle) {
                weakSelf.cycleMode = CirculationModeIsRandom;
                [weakSelf.playButtonView.cycleButton setImage:[UIImage imageNamed:@"suiji1"] forState:UIControlStateNormal];
                return;
            }
            if (weakSelf.cycleMode == CirculationModeIsRandom) {
                weakSelf.cycleMode = CirculationModeIsCycle;
                [weakSelf.playButtonView.cycleButton setImage:[UIImage imageNamed:@"xunhuan1"] forState:UIControlStateNormal];
                return;
            }
        }
        if (button.tag == 202) {//上
            [weakSelf previousMusic];
        }
        if (button.tag == 203) {
            if (!weakSelf.isPlaying) {
                [weakSelf.queuePlayer play];
                [weakSelf.playButtonView.playButton setImage:[UIImage imageNamed:@"zantingduan3"] forState:UIControlStateNormal];
                weakSelf.isPlaying = YES;
            } else {
                [weakSelf.queuePlayer pause];
                [weakSelf.playButtonView.playButton setImage:[UIImage imageNamed:@"bf"] forState:UIControlStateNormal];
                weakSelf.isPlaying = NO;
            }
            return;
        }
        if (button.tag == 204) {//下
            [weakSelf nextMusic];
        }
        if (button.tag == 205) {
            [UIView animateWithDuration:0.4 animations:^{
                [weakSelf.view bringSubviewToFront:weakSelf.volumeView];
                weakSelf.volumeView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.playBottomView.bounds.size.height, weakSelf.playBottomView.bounds.size.width, weakSelf.playBottomView.bounds.size.height);
            }];
            return;
        }
    };
    _volumeView.volume = ^(float value){
        weakSelf.queuePlayer.volume = value;
    };
}

- (void)previousMusic{
    self.progressView.progress = 0.0;
    if (self.cycleMode == CirculationModeIsRandom) {
        [self playAtIndex:random()%(self.playerItems.count)];
        return;
    }
    AVPlayerItem *currentItem = [self.queuePlayer currentItem];
    NSInteger currentInex = [self.playerItems indexOfObject:currentItem];
    if (self.cycleMode == CirculationModeIsSingleCycle) {
        [self playAtIndex:currentInex];
        return;
    }
    if (currentInex == self.playerItems.count - 1) {
        currentInex = 0;
        [self playAtIndex:currentInex];
        return;
    }
    currentInex--;
    [self playAtIndex:currentInex];
    return;
}

- (void)nextMusic{
    self.progressView.progress = 0.0;
    if (self.cycleMode == CirculationModeIsRandom) {
        [self playAtIndex:random()%(self.playerItems.count)];
        return;
    }
    AVPlayerItem *currentItem = [self.queuePlayer currentItem];
    NSInteger currentInex = [self.playerItems indexOfObject:currentItem];
    if (self.cycleMode == CirculationModeIsSingleCycle) {
        [self playAtIndex:currentInex];
        return;
    }
    if (currentInex == self.playerItems.count - 1) {
        currentInex = 0;
        [self playAtIndex:currentInex];
        return;
    }
    currentInex++;
    [self playAtIndex:currentInex];
    return;
}

#pragma mark - 载入界面
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化播放界面
    [self customPlayView];
    
    //添加播放点
    [self.view addSubview:self.playPointView];
    
    //初始化播放序列
    [self customPlayer];
    
    //开启后台模式
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    //添加播放状态监听
    [self addPlayingStateKVO];
    
    //显示当前的播放时间和更新进度
    [self updateSchedule];
    
    //开始接收远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    //添加中断播放监听
    [self addInterruptKVO];
    
    //添加物理动效和手势
    [self addAnimationAndGesture];
    
    //定制主显示视图
    [self customMainView];
    
}

- (void)customMainView{
    self.infoLabel.text = @"推荐";
    _recommendedVC = [[RecommendedViewController alloc] initWithNibName:@"RecommendedViewController" bundle:nil];
    _recommendedVC.view.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    [_recommendedVC.view layoutIfNeeded];
    
    [self addChildViewController:_recommendedVC];
    [self.containerView addSubview:_recommendedVC.view];
    [_recommendedVC didMoveToParentViewController:self];
    
    __weak typeof(self) weakSelf = self;
    _recommendedVC.loadSong = ^(NSInteger tag, NSMutableArray *songList){
        [weakSelf.view addSubview:weakSelf.tempView];
        weakSelf.dataSource = songList;
        [weakSelf.queuePlayer pause];
        [weakSelf removePlayingStateKVO];
        [weakSelf openPlayViewWithCell];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf cuntomSongList:tag];
        });
    };

    
    self.currentViewController = _recommendedVC;
    self.recommended.selected = YES;
    [self.view bringSubviewToFront:self.playPointView];
    
    [self callingBlock:_recommendedVC title:@"每日新歌推荐"];
}

- (void)callingBlock:(BaseViewController *)oneVC title:(NSString *)title{
    __weak typeof(self) weakSelf = self;
    oneVC.loadMusic = ^(NSMutableArray *data){
        weakSelf.dataSource = data;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        weakSelf.tableView.delegate = weakSelf;
        weakSelf.tableView.dataSource = weakSelf;
        [weakSelf.view addSubview:weakSelf.tableView];
        [weakSelf.view bringSubviewToFront:weakSelf.playPointView];
        
        [weakSelf.tableView registerNib:[UINib nibWithNibName:@"MainTableViewCell" bundle:nil] forCellReuseIdentifier:@"xxx"];
        weakSelf.left.constant = 30.0;
        weakSelf.top.constant = 30.0;
        weakSelf.bottom.constant = 30.0;
        weakSelf.right.constant = 30.0;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.baseView.alpha = 0.5;
            [weakSelf.baseView layoutIfNeeded];
            weakSelf.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }];
        [weakSelf costomHeaderView:title];
    };
}

- (void)costomHeaderView:(NSString *)title{
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    self.tableView.tableHeaderView = self.headerView;
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    self.imageView.image = [UIImage imageNamed:@"back2.jpg"];
    [self.headerView addSubview:self.imageView];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"<<" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backMainView) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 27, 30, 30);
    [self.headerView addSubview:button];
    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.text = title;
    self.headerLabel.frame = CGRectMake(0, 0, 150, 30);
    self.headerLabel.center = CGPointMake(self.headerView.center.x, self.headerView.center.y + 10);
    self.headerLabel.textAlignment = 1;
    self.headerLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.headerLabel];
    
    self.tableView.tableHeaderView = self.headerView;
    
}

- (void)backMainView{
    self.IS_LIKE = NO;
    self.left.constant = -20.0;
    self.top.constant = -20.0;
    self.bottom.constant = 0.0;
    self.right.constant = -20.0;
    [UIView animateWithDuration:0.4 animations:^{
        self.baseView.alpha = 1.0;
        [self.baseView layoutIfNeeded];
        self.tableView.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeTable) userInfo:nil repeats:NO];
}

- (void)removeTable{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

#pragma mark - 主界面控制按钮
- (IBAction)recommendedButton:(id)sender {
    [(UIButton *)sender setShowsTouchWhenHighlighted:YES];
    self.infoLabel.text = @"推荐";
    if (self.currentViewController == _recommendedVC) {
        return;
    }
    
    self.currentViewController = _recommendedVC;
    self.song.selected = NO;
    self.recommended.selected = YES;
    self.list.selected = NO;
    self.radio.selected = NO;
    
    [self.containerView bringSubviewToFront:_recommendedVC.view];
    [self.view bringSubviewToFront:self.playPointView];
}

- (IBAction)songButton:(id)sender {
    self.infoLabel.text = @"歌单";
    [(UIButton *)sender setShowsTouchWhenHighlighted:YES];
    if (self.currentViewController == _songVC) {
        return;
    }
    if (_songVC == nil) {
        _songVC = [[SongViewController alloc] initWithNibName:@"SongViewController" bundle:nil];
        _songVC.view.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
        [self addChildViewController:_songVC];
        [self.containerView addSubview:_songVC.view];
        [_songVC didMoveToParentViewController:self];
        [self callingBlock:_songVC title:@"歌单详情列表"];
    } else {
        [self.containerView bringSubviewToFront:_songVC.view];;
    }
    
    self.currentViewController = _songVC;
    self.song.selected = YES;
    self.recommended.selected = NO;
    self.list.selected = NO;
    self.radio.selected = NO;
    
    [self.view bringSubviewToFront:self.playPointView];
}

- (IBAction)listButton:(id)sender {
    self.infoLabel.text = @"榜单";
    [(UIButton *)sender setShowsTouchWhenHighlighted:YES];
    if (self.currentViewController == _listVC) {
        return;
    }
    if (_listVC == nil) {
        _listVC = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
        _listVC.view.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
        [self addChildViewController:_listVC];
        [self.containerView addSubview:_listVC.view];
        [_listVC didMoveToParentViewController:self];
        [self callingBlock:_listVC title:@"榜单TOP30"];
    } else {
        [self.containerView bringSubviewToFront:_listVC.view];;
    }
    
    self.currentViewController = _listVC;
    self.song.selected = NO;
    self.recommended.selected = NO;
    self.list.selected = YES;
    self.radio.selected = NO;
    
    [self.view bringSubviewToFront:self.playPointView];
}

- (IBAction)radioButton:(id)sender {
    self.infoLabel.text = @"电台";
    [(UIButton *)sender setShowsTouchWhenHighlighted:YES];
    if (self.currentViewController == _radioVC) {
        return;
    }
    if (_radioVC == nil) {
        _radioVC = [[RadioViewController alloc] initWithNibName:@"RadioViewController" bundle:nil];
        _radioVC.view.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
        [self addChildViewController:_radioVC];
        [self.containerView addSubview:_radioVC.view];
        [_radioVC didMoveToParentViewController:self];
        
        __weak typeof(self) weakSelf = self;
        _radioVC.openPlayViewBlock = ^(NSMutableArray *songList){
            weakSelf.dataSource = songList;
            [weakSelf.queuePlayer pause];
            [weakSelf removePlayingStateKVO];
            [weakSelf openPlayViewWithCell];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf cuntomSongList:arc4random()%10];
            });
        };
    } else {
        [self.containerView bringSubviewToFront:_radioVC.view];;
    }
    
    self.currentViewController = _radioVC;
    self.song.selected = NO;
    self.recommended.selected = NO;
    self.list.selected = NO;
    self.radio.selected = YES;
    
    [self.view bringSubviewToFront:self.playPointView];
}

#pragma mark - 初始化播放器
- (void)customPlayer{
    self.playerItems = [[NSMutableArray alloc] init];
    self.queuePlayer = [[AVQueuePlayer alloc] init];
    self.SongArray = [SongDetail MR_findAll];
    [self.queuePlayer pause];
    /*
     AVPlayerActionAtItemEndAdvance	= 0,//继续
     AVPlayerActionAtItemEndPause	= 1,//暂停
     AVPlayerActionAtItemEndNone		= 2,
     */
    //设置循环状态
    
    self.queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    [self addObserver:self forKeyPath:@"currentSecond"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

#pragma mark - 初始化播放界面 以及 控制按钮
- (void)customPlayView{
    self.timeArray = [NSMutableArray array];
    self.lrcArray = [NSMutableArray array];
    [_lrcTableView registerNib:[UINib nibWithNibName:@"LrcTableViewCell" bundle:nil] forCellReuseIdentifier:@"lrc"];
    _lrcTableView.backgroundColor = [UIColor clearColor];
    _lrcTableView.showsVerticalScrollIndicator = NO;
    _lrcTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 2)];
    view.backgroundColor = [UIColor clearColor];
    _lrcTableView.tableHeaderView = view;
    _lrcTableView.tableFooterView = view;
    
    self.progressView.tintColor=[UIColor whiteColor];
    self.progressView.trackTintColor=[UIColor grayColor];
    self.progressView.progress = 0.0;
    
    self.audioSlider.minimumTrackTintColor = [UIColor colorWithRed:0.16 green:0.72 blue:1.0 alpha:1.0];
    self.audioSlider.maximumTrackTintColor = [UIColor clearColor];
    self.audioSlider.value = 0.0;//初始化播放进度条
}


//播放指定位置
- (IBAction)audioSliderValue:(UISlider *)sender {
    [self.queuePlayer seekToTime:CMTimeMakeWithSeconds(self.totalSecond * self.audioSlider.value, self.queuePlayer.currentItem.duration.timescale)];
}

//隐藏播放页面
- (IBAction)hidePlayView:(id)sender {
    [(UIButton *)sender setShowsTouchWhenHighlighted:YES];
    self.hideButton.userInteractionEnabled = NO;
    self.isOpen = NO;

    [_tempView removeFromSuperview];
    _tempView = nil;
    
    //渐隐动效
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 1;
    [self.playView.layer removeAllAnimations];
    [self.playView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.playButtonView.frame = CGRectMake(0, SCREEN_HEIGHT, self.playButtonView.bounds.size.width, self.playButtonView.bounds.size.height);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(opacity) userInfo:nil repeats:NO];
}

- (void)opacity{
    self.playButtonView.alpha = 0.0;
    self.playView.alpha = 0.0;
    [self performTransactionAnimation];
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(movePlayPointView) userInfo:nil repeats:NO];
    
}

- (void)movePlayPointView{
    [UIView animateWithDuration:0.3 animations:^{
        self.playPointView.center = self.tempPoint;
    }];
    self.playPointView.userInteractionEnabled = YES;
}

#pragma mark - 添加播放控制点
- (UIView *)playPointView{
    if (_playPointView == nil) {
        _playPointView = [[UIView alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 114, 50, 50)];
        _playPointView.backgroundColor = [UIColor lightGrayColor];
        _playPointView.layer.cornerRadius = 25;
        self.tempPoint = _playPointView.center;
        self.isOpen = NO;
    }
    return _playPointView;
}

#pragma mark - 添加播放控制点上的物理动效和手势
- (void)addAnimationAndGesture{
    //物理动效
    self.animation = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    //添加点击手势
    UITapGestureRecognizer * tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGR:)];
    [self.playPointView addGestureRecognizer:tapGR];
    
    //添加移动手势
    UIPanGestureRecognizer * panGR=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGR:)];
    [self.playPointView addGestureRecognizer:panGR];
}

//点击手势
-(void)tapGR:(UITapGestureRecognizer *)tapGR{
    [self.view bringSubviewToFront:self.playPointView];
    if (self.dataSource.count == 0 && self.searchDate.count == 0 && self.SongArray.count == 0) {
        [_tempAlertView show];
        return;
    }
    [self openPlayViewWithCell];
}


//拖动手势
- (void)panGR:(UIPanGestureRecognizer *)panGes{
    if (panGes.state == UIGestureRecognizerStateBegan) {
        [self.animation removeAllBehaviors];
    } else if (panGes.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [panGes translationInView:self.baseView];
        CGPoint center = self.playPointView.center;
        center.x += offset.x;
        center.y += offset.y;
        self.playPointView.center = center;
        [panGes setTranslation:CGPointZero inView:self.baseView];
        
    } else if (panGes.state == UIGestureRecognizerStateCancelled || panGes.state == UIGestureRecognizerStateEnded) {
    }
}


#pragma mark - 显示当前的播放时间和更新进度
- (void)updateSchedule{
    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        for (NSInteger index = 0; index < self.timeArray.count; index++) {
            if ([self.currentTime.text isEqualToString:self.timeArray[index]]) {
                LrcTableViewCell *cell = (LrcTableViewCell *)[self.lrcTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                LrcTableViewCell *beforeCell = (LrcTableViewCell *)[self.lrcTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]];
                [self.lrcTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                beforeCell.lrcLabel.textColor = [UIColor whiteColor];
                cell.lrcLabel.textColor = [UIColor redColor];
            }

        }
 
        if (self.isPlaying) {
            [self.queuePlayer play];
        }
        
        self.currentSecond = (float)time.value / (float)time.timescale;
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            self.currentTime.text = [self convertTime:self.currentSecond];
            self.audioSlider.value = self.currentSecond / self.totalSecond;//更新播放进度条
        } else {
            self.currentTime.text = [self convertTime:self.currentSecond];
            self.audioSlider.value = self.currentSecond / self.totalSecond;//更新播放进度条
        }
    };
    
    [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                   queue:dispatch_get_main_queue()
                                              usingBlock:observerBlock];
}

#pragma mark - 添加锁屏界面显示
- (void)addLockScreenView{
    if(NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
        if (self.IS_LIKEOPEN) {
            [dict setObject:self.oneSongDetail.title forKey:MPMediaItemPropertyTitle];
            [dict setObject:self.oneSongDetail.author forKey:MPMediaItemPropertyArtist];
            [dict setObject:self.oneSongDetail.album_title forKey:MPMediaItemPropertyAlbumTitle];
            [dict setObject:[NSString stringWithFormat:@"%f", self.totalSecond] forKey:MPMediaItemPropertyPlaybackDuration];
            //[dict setObject:@"这是歌词" forKey:MPMediaItemPropertyLyrics];
            UIImage *image = [UIImage imageNamed:@"cdbg"];
            [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:image]forKey:MPMediaItemPropertyArtwork];
            UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.oneSongDetail.pic_radio];
            if (newImage != nil) {
                [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:newImage]forKey:MPMediaItemPropertyArtwork];
            }
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        } else {
            [dict setObject:self.oneSong.title forKey:MPMediaItemPropertyTitle];
            [dict setObject:self.oneSong.author forKey:MPMediaItemPropertyArtist];
            [dict setObject:self.oneSong.album_title forKey:MPMediaItemPropertyAlbumTitle];
            [dict setObject:[NSString stringWithFormat:@"%f", self.totalSecond] forKey:MPMediaItemPropertyPlaybackDuration];
            //[dict setObject:@"这是歌词" forKey:MPMediaItemPropertyLyrics];
            UIImage *image = [UIImage imageNamed:@"cdbg"];
            [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:image]forKey:MPMediaItemPropertyArtwork];
            UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.oneSong.pic_radio];
            if (newImage != nil) {
                [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:newImage]forKey:MPMediaItemPropertyArtwork];
            }
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }
    }
    
}

#pragma mark - 添加中断播放监听
- (void)addInterruptKVO{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleInterrupt:) name:AVAudioSessionInterruptionNotification object:nil];
}

//中断播发后的回调
- (void)handleInterrupt:(NSNotification*)notification{
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
        } else if([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeEnded]]){
            [self.queuePlayer play];
        }
    }
}

#pragma mark - 添加播放状态监听 以及 状态回调
- (void)addPlayingStateKVO{
    [self.queuePlayer addObserver:self forKeyPath:@"currentItem"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
}


//播放状态KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentItem"]) {
        if (self.IS_LIKEOPEN) {
            [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"aixin"] forState:UIControlStateNormal];
        } else {
            NSArray *Songs = [SongDetail MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"song_id = %@", self.oneSong.song_id]];
            if (Songs.count == 0) {
                [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"aixin(空)"] forState:UIControlStateNormal];
            } else if (Songs.count > 0) {
                [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"aixin"] forState:UIControlStateNormal];
            }
        }
        [self currentMusicIndexInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLockScreenView];
        });
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        self.totalSecond = self.queuePlayer.currentItem.duration.value / self.queuePlayer.currentItem.duration.timescale;//转换成秒
        self.totalTime.text = [self convertTime:self.totalSecond];
        
        CMTime duration = self.queuePlayer.currentItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        double time = [self availableDuration];// 计算缓冲进度
        self.buffer = time / totalDuration;
        self.progressView.progress = time / totalDuration ;
    }
    
    if ([keyPath isEqualToString:@"currentSecond"]) {
        if (((int)self.currentSecond - (int)self.totalSecond == 1.00 || (int)self.currentSecond - (int)self.totalSecond == -1.00) && self.currentSecond != 0) {
            [self nextMusic];
        }
    }
}


//刷新歌曲名称等信息
- (void)currentMusicIndexInfo{
    if (self.IS_LIKEOPEN) {
        self.songLabel.text = self.oneSongDetail.title;
        self.author.text = [NSString stringWithFormat:@"%@ - %@", self.oneSongDetail.author, self.oneSongDetail.album_title];
        [self.starImgV sd_setImageWithURL:[NSURL URLWithString:self.oneSongDetail.pic_radio]];
    } else {
        self.songLabel.text = self.oneSong.title;
        self.author.text = [NSString stringWithFormat:@"%@ - %@", self.oneSong.author, self.oneSong.album_title];
        [self.starImgV sd_setImageWithURL:[NSURL URLWithString:self.oneSong.pic_radio]];
    }
    
    [self backImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self backImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self backImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self backImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self backImage];
    });
}

- (void)backImage{
    if (self.IS_LIKEOPEN) {
        UIImage *tempImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.oneSongDetail.pic_radio];
        //dispatch_async(dispatch_queue_create("queue", NULL), ^ {
            if (tempImage == nil) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    self.playViewBackImageView.image = [self blurryImage:[UIImage imageNamed:@"bg"] withBlurLevel: 0.9];
                //});
                self.starImgV.image = [UIImage imageNamed:@"bg"];
            } else {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    self.playViewBackImageView.image = [self blurryImage:tempImage withBlurLevel: 0.9];
                //});
            }
        //});
    } else {
        UIImage *tempImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.oneSong.pic_radio];
       // dispatch_async(dispatch_queue_create("queue", NULL), ^ {
            if (tempImage == nil) {
               // dispatch_async(dispatch_get_main_queue(), ^{
                    self.playViewBackImageView.image = [self blurryImage:[UIImage imageNamed:@"bg"] withBlurLevel: 0.9];
                //});
                self.starImgV.image = [UIImage imageNamed:@"bg"];
            } else {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    self.playViewBackImageView.image = [self blurryImage:tempImage withBlurLevel: 0.9];
               // });
            }
        //});
    }
}

// 计算缓冲进度
- (double)availableDuration {
    NSArray *loadedTimeRanges = [self.queuePlayer.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    double durationSeconds = CMTimeGetSeconds(timeRange.duration);//计算当前缓冲进度
    return durationSeconds;
}

//label时间转换
- (NSString *)convertTime:(CGFloat)second{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    return [formatter stringFromDate:timeDate];
}

#pragma mark - 远程控制接收与事件(耳机和锁屏控制)
- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            NSLog(@"UIEventSubtypeRemoteControlPlay");//播放
            [self.queuePlayer play];
            self.isPlaying = !self.isPlaying;
            [self.playButtonView.playButton setImage:[UIImage imageNamed:@"zantingduan3"] forState:UIControlStateNormal];
        }else if(event.subtype == UIEventSubtypeRemoteControlPause)
        {
            NSLog(@"UIEventSubtypeRemoteControlPause");//暂停
            [self.queuePlayer pause];
            self.isPlaying = !self.isPlaying;
            [self.playButtonView.playButton setImage:[UIImage imageNamed:@"bf"] forState:UIControlStateNormal];
        }
        else if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
            NSLog(@"UIEventSubtypeRemoteControlPause");//耳机控制
            if (self.isPlaying) {
                [self.queuePlayer pause];
                [self.playButtonView.playButton setImage:[UIImage imageNamed:@"bf"] forState:UIControlStateNormal];
            }else{
                [self.queuePlayer play];
                [self.playButtonView.playButton setImage:[UIImage imageNamed:@"zantingduan3"] forState:UIControlStateNormal];
            }
            self.isPlaying = !self.isPlaying;
        }else if(event.subtype == UIEventSubtypeRemoteControlNextTrack){
            NSLog(@"UIEventSubtypeRemoteControlNextTrack");//下一曲
            [self nextMusic];
        }else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
            NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");//上一曲
            [self previousMusic];
        }
    }
}

//切换上一首歌调用的方法   ----可否变成播放指定曲目?
- (void)playAtIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self currentLrc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.lrcTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self.lrcTableView reloadData];
        });
    });
    if (!self.IS_SEARCHING) {
        self.oneSong = self.dataSource[index];
    }
    if (self.IS_LIKEOPEN) {
        self.oneSongDetail = self.SongArray[index];
    }
    [self.queuePlayer removeAllItems];
    if ([self.queuePlayer canInsertItem:self.playerItems[index] afterItem:nil]) {
        [self.playerItems[index] seekToTime:kCMTimeZero];
        [self.queuePlayer insertItem:self.playerItems[index] afterItem:nil];
    }
    [self.queuePlayer play];


    CMTime duration = ((AVPlayerItem *)self.playerItems[index]).duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    if (!isnan(totalDuration)) {
        CGFloat second = duration.value / duration.timescale;//转换成秒
        self.totalTime.text = [self convertTime:second];
        double time = [self availableDuration];
        self.progressView.progress = time / totalDuration;
    }
    
    
    //[self.queuePlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    
}

#pragma mark - POP
-(void)performTransactionAnimation
{
    self.playButtonView.alpha = 1.0;
    [self.playPointView pop_removeAllAnimations];
    
    POPSpringAnimation *boundsAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    boundsAnim.springBounciness = 0;
    boundsAnim.springSpeed = 10;
    
    [self.playPointView.layer pop_addAnimation:boundsAnim forKey:@"AnimateBounds"];
    
    
    if (self.isOpen) {
        self.playPointView.layer.cornerRadius = 0;
        boundsAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];//动画完成后的fram
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openPlayView) userInfo:nil repeats:NO];
        
    } else {
        self.playPointView.layer.cornerRadius = 25;
        boundsAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 50, 50)];
    }
}

- (void)openPlayView{
    //显现播放页面
    CABasicAnimation *opacityAnimationA = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimationA.fromValue = @(0.0);
    opacityAnimationA.toValue = @(1.0);
    opacityAnimationA.duration = 0.4;
    [self.playView.layer removeAllAnimations];
    [self.playView.layer addAnimation:opacityAnimationA forKey:@"opacity"];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.playButtonView.frame = CGRectMake(0, SCREEN_HEIGHT - self.playBottomView.bounds.size.height, self.playBottomView.bounds.size.width, self.playBottomView.bounds.size.height);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(changeAlpha) userInfo:nil repeats:NO];
}

- (void)changeAlpha{
    self.playView.alpha = 1.0;
}


#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.IS_SEARCHING && !self.isOpen) {
        return self.searchDate.count;
    }
    if (tableView == self.lrcTableView) {
        if (self.lrcArray.count == 0) {
            return 1;
        }
        return self.lrcArray.count;
    }
    if (self.IS_LIKE) {
        return self.SongArray.count;
    }
    return self.dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        MainTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"xxx" forIndexPath:indexPath];
        if (self.IS_SEARCHING) {
            SearchModel *searchModel = [self.searchDate objectAtIndex:indexPath.row];
            [cell updateWithSearchModel:searchModel];
        } else if (self.IS_LIKE) {
            SongDetail *oneSongDetail = [self.SongArray objectAtIndex:indexPath.row];
            [cell updateWithSongDetail:oneSongDetail];
        } else {
            SongModel *songModel = [self.dataSource objectAtIndex:indexPath.row];
            [cell updateWithModel:songModel];
        }
        return cell;
    }
    
    LrcTableViewCell *cell = [self.lrcTableView dequeueReusableCellWithIdentifier:@"lrc" forIndexPath:indexPath];
    if (self.lrcArray.count == 0) {
        cell.lrcLabel.text = @"暂时没有歌词!";
        cell.lrcLabel.textColor = [UIColor redColor];
    } else {
        cell.lrcLabel.text = self.lrcArray[indexPath.row];
        cell.lrcLabel.textColor = [UIColor whiteColor];
    }
    cell.userInteractionEnabled = NO;

    cell.lrcLabel.lineBreakMode = NSLineBreakByClipping;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tableView && self.IS_SEARCHING) {
        [_searchBar resignFirstResponder];
        self.cancelButton.alpha = 1.0;
        [self.view bringSubviewToFront:self.cancelButton];
    }

    CGFloat yOffset = self.tableView.contentOffset.y;
    if (yOffset < 0) {
        CGFloat factor = -yOffset + 70;
        CGRect f = CGRectMake(-(SCREEN_WIDTH*factor/70 - SCREEN_WIDTH)/2, yOffset, SCREEN_WIDTH*factor/70, factor);
        self.imageView.frame = f;
    }else {
        CGRect f = self.headerView.frame;
        f.origin.y = 0;
        self.headerView.frame = f;
        self.imageView.frame = CGRectMake(0, f.origin.y, SCREEN_WIDTH, 70);
    }
}


//转跳播放页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.IS_LIKEOPEN && self.IS_LIKE) {
        if ([((SongDetail *)self.SongArray[indexPath.row]).song_id isEqualToString:self.oneSongDetail.song_id] && self.oneSong != nil) {
            [self openPlayViewWithCell];
            return;
        }
    }
    self.IS_LIKEOPEN = NO;
    self.collectionButton.userInteractionEnabled = YES;
    if (self.IS_SEARCHING) {
        if ([((SearchModel *)self.searchDate[indexPath.row]).song_id isEqualToString:self.oneSong.song_id] && self.oneSong != nil) {
            [self openPlayViewWithCell];
            return;
        }
    }
    if ([((SongModel *)self.dataSource[indexPath.row]).song_id isEqualToString:self.oneSong.song_id] && self.oneSong != nil) {
        [self openPlayViewWithCell];
        return;
    }
    [self removePlayingStateKVO];
    [self openPlayViewWithCell];
    if (self.IS_SEARCHING) {
        [self.view endEditing:YES];
        self.cancelButton.alpha = 1.0;
        [self.view bringSubviewToFront:self.cancelButton];
        [self.view bringSubviewToFront:self.playPointView];
        [self cuntomSongList:indexPath.row];
        return;
    }
//    if (self.IS_LIKE) {
//        [self cuntomSongList:indexPath.row];
//        return;
//    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self cuntomSongList:indexPath.row];
    });
}


- (void)openPlayViewWithCell{
    [self.view bringSubviewToFront:self.playView];
    [self.view bringSubviewToFront:self.playButtonView];
    self.playPointView.userInteractionEnabled = NO;
    self.hideButton.userInteractionEnabled = YES;
    self.isOpen = YES;
    self.tempPoint = self.playPointView.center;
    
    [self.animation removeAllBehaviors];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.playPointView snapToPoint:self.view.center];
    [self.animation addBehavior:snap];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(performTransactionAnimation) userInfo:nil repeats:NO];
}

- (void)cuntomSongList:(NSInteger)index{
    if (!self.IS_SEARCHING && !self.IS_LIKE) {
        [self.playerItems removeAllObjects];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:((SongModel *)self.dataSource[i]).songFiles[0]]];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
            [item addObserver:self
                   forKeyPath:@"loadedTimeRanges"
                      options:NSKeyValueObservingOptionNew context:nil];
            [self.playerItems addObject:item];
        }
        self.oneSong = self.dataSource[index];
        [self loadMusic:index];
    } else if (self.IS_SEARCHING) {
        [self.playerItems removeAllObjects];
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, ((SearchModel *)(self.searchDate[index])).song_id, SONG_URL_X] success:^(id responsData) {
            self.oneSong = [SongModel parseRespondsData:responsData];
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.oneSong.songFiles[0]]];
            AVPlayerItem *item = [[AVPlayerItem alloc]initWithAsset:asset];
            [item addObserver:self
                   forKeyPath:@"loadedTimeRanges"
                      options:NSKeyValueObservingOptionNew context:nil];
            [self.playerItems addObject:item];
            [self loadMusic:0];
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [self.playerItems removeAllObjects];
        self.IS_LIKEOPEN = YES;
        self.collectionButton.userInteractionEnabled = NO;
        for (NSInteger i = 0; i < self.SongArray.count; i++) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Documents/%@.mp3", NSHomeDirectory(), ((SongDetail *)self.SongArray[i]).song_id]]];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
            [item addObserver:self
                   forKeyPath:@"loadedTimeRanges"
                      options:NSKeyValueObservingOptionNew context:nil];
            [self.playerItems addObject:item];
        }
        self.oneSongDetail = self.SongArray[index];
        [self loadMusic:index];
    }
}

#pragma mark - 加载Music
- (void)loadMusic:(NSInteger)index{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self currentLrc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.lrcTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self.lrcTableView reloadData];
        });
    });
    [self.queuePlayer removeAllItems];
    if ([self.queuePlayer canInsertItem:self.playerItems[index] afterItem:nil]) {
        [self.playerItems[index] seekToTime:kCMTimeZero];
        [self.queuePlayer insertItem:self.playerItems[index] afterItem:nil];
    }
    [self.queuePlayer play];
    self.isPlaying = YES;
    [self.playButtonView.playButton setImage:[UIImage imageNamed:@"zantingduan3"] forState:UIControlStateNormal];
}

//删除监听
- (void)removePlayingStateKVO{
    for (NSInteger index = 0; index < self.playerItems.count; index++) {
        AVPlayerItem *item = self.playerItems[index];
        [item removeObserver:self
                  forKeyPath:@"loadedTimeRanges"
                     context:nil];
    }
}

#pragma mark - searchBar
- (IBAction)search:(UIButton *)sender {
    [self.view addSubview:self.searchBar];
    [UIView animateWithDuration:0.2 animations:^{
        _searchBar.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
    }];
}

- (UISearchBar *)searchBar{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 20, SCREEN_WIDTH, 44)];
    _searchDate = [[NSMutableArray alloc] init];
    _searchBar.delegate=self;
    _searchBar.placeholder = @"歌名 歌手";
    [_searchBar becomeFirstResponder];
    _searchBar.showsCancelButton = YES;
    self.IS_SEARCHING = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"MainTableViewCell" bundle:nil] forCellReuseIdentifier:@"xxx"];
    [self.view bringSubviewToFront:self.playPointView];
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }];
    return _searchBar;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [_searchDate removeAllObjects];
    NSString *tempUrl = [NSString stringWithFormat:URL_SEARCH, searchText];
    NSString *url = [tempUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NetDataEngine sharedInstance] GET:url success:^(id responsData) {
        _searchDate = [SearchModel parseRespondsData:responsData];
        [_tableView reloadData];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (IBAction)cancelSearchBar:(id)sender {
    [self searchBarCancelButtonClicked:_searchBar];
    self.cancelButton.alpha = 0.0;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    self.IS_SEARCHING = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _searchBar.frame = CGRectMake(SCREEN_WIDTH, 20, SCREEN_WIDTH, 44);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(removeTable) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(removeSearch) userInfo:nil repeats:NO];
}

- (void)removeSearch{
    [_searchBar removeFromSuperview];
    _searchBar = nil;
}


#pragma mark - 模糊图片
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    //CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    
    return returnImage;
}

#pragma mark - Lrc
- (IBAction)hiddenLrc:(id)sender {
    if (self.lrcTableView.alpha == 0.0) {
        self.lrcTableView.alpha = 1.0;
        self.imageV.alpha = 0.0;
    } else {
        self.lrcTableView.alpha = 0.0;
        self.imageV.alpha = 1.0;
    }
}

- (void)currentLrc{
    [self.timeArray removeAllObjects];
    [self.lrcArray removeAllObjects];
    NSInteger index = 0;
    NSString *url = [self.oneSong.lrclink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.IS_LIKEOPEN) {
        _lrc = self.oneSongDetail.lrc;
    } else {
        _lrc = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];

    }
    NSArray *arr = [_lrc componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        if ([str hasPrefix:@"[00:0"]) {
            break;
        }
        index++;
    }
    if (arr.count != 0) {
        for (NSInteger i = index; i < arr.count - 1; i++) {
            NSString *tempTimeItem = arr[i];
            if (tempTimeItem.length >= 10) {
                NSString *timeItem = [arr[i] substringWithRange:NSMakeRange(1, 5)];
                [self.timeArray addObject:timeItem];
                NSString *lrcItem = [arr[i] substringFromIndex:10];
                [self.lrcArray addObject:lrcItem];
            }
        }
    }
    [self.lrcTableView reloadData];
}

- (UIView *)tempView{
    _tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width)];
    _tempView.backgroundColor = [UIColor clearColor];
    return _tempView;
}

#pragma mark - collectionButton
- (IBAction)collectionAndUncollection:(id)sender {
    if (self.IS_LIKEOPEN) {
        self.songs = [SongDetail MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"song_id = %@", self.oneSongDetail.song_id]];
    } else {
        self.songs = [SongDetail MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"song_id = %@", self.oneSong.song_id]];
    }
    if (self.songs.count == 0) {
        [self insertSongDetail];
        [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"aixin"] forState:UIControlStateNormal];
    } else if (self.songs.count > 0) {
        SongDetail *oneSongDetail = self.songs[0];
        [self deleteSongDetail:oneSongDetail];
        [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"aixin(空)"] forState:UIControlStateNormal];
    }
}

- (void)insertSongDetail{
    NSURL *url=[NSURL URLWithString:self.oneSong.songFiles[0]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath,NSURLResponse *response) {
        
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [downloadURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", self.oneSong.song_id]];
        
    } completionHandler:^(NSURLResponse *response,NSURL *filePath, NSError *error) {
        SongDetail *oneSongDetail = [SongDetail MR_createEntity];
        oneSongDetail.song_id = self.oneSong.song_id;
        oneSongDetail.pic_small = self.oneSong.pic_small;
        oneSongDetail.pic_radio = self.oneSong.pic_radio;
        oneSongDetail.title = self.oneSong.title;
        oneSongDetail.author = self.oneSong.author;
        oneSongDetail.album_title = self.oneSong.album_title;
        oneSongDetail.lrc = self.lrc;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        NSLog(@"收藏成功");
        self.SongArray = [SongDetail MR_findAll];
        if (self.IS_LIKEOPEN) {
            [self.tableView reloadData];
        }
    }];
    [downloadTask resume];
}

- (void)deleteSongDetail:(SongDetail *)oneSongDetail{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/Documents/%@.mp3", NSHomeDirectory(), oneSongDetail.song_id] error:nil];
    [oneSongDetail MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    self.SongArray = [SongDetail MR_findAll];
    if (self.IS_LIKEOPEN) {
        [self.tableView reloadData];
    }
    NSLog(@"取消收藏");
}

- (IBAction)like:(id)sender {
    [self addTableViewWhitTitle:@"我的收藏"];
    self.IS_LIKE = YES;
}

- (void)addTableViewWhitTitle:(NSString *)title{
    self.SongArray = [SongDetail MR_findAll];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.playPointView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MainTableViewCell" bundle:nil] forCellReuseIdentifier:@"xxx"];
    self.left.constant = 30.0;
    self.top.constant = 30.0;
    self.bottom.constant = 30.0;
    self.right.constant = 30.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.baseView.alpha = 0.5;
        [self.baseView layoutIfNeeded];
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    [self costomHeaderView:title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
