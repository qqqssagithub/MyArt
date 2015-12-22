//
//  SongViewController.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "SongViewController.h"
#import "SongCollectionViewCell.h"
#import "SongsModel.h"

#define URL_SONG @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.diy.gedan&page_no=%ld&page_size=28&from=ios&version=5.5.1&from=ios&channel=appstore"

#define URL_SONGMODEL @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.diy.gedanInfo&from=ios&listid=%@&version=5.5.1&from=ios&channel=appstore"

@interface SongViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *songList;
@property (nonatomic) NSMutableArray *songData;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isRefreshing;

@end

@implementation SongViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 - 49);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customUI];
    self.page = 1;
    self.dataSource = [[NSMutableArray alloc] init];
    self.songData = [[NSMutableArray alloc] init];
    self.songList = [[NSMutableArray alloc] init];
    [self fetchData:1];
    [self createRefreshHeadView];
    [self createRefreshFootView];
    
    
    [self setupBaseKVNProgressUI];
}

#pragma mark - UI

- (void)setupBaseKVNProgressUI
{
    // See the documentation of all appearance propoerties
    [KVNProgress appearance].statusColor = [UIColor darkGrayColor];
    [KVNProgress appearance].statusFont = [UIFont systemFontOfSize:17.0f];
    [KVNProgress appearance].circleStrokeForegroundColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
    [KVNProgress appearance].backgroundFillColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
    [KVNProgress appearance].backgroundTintColor = [UIColor whiteColor];
    [KVNProgress appearance].successColor = [UIColor darkGrayColor];
    [KVNProgress appearance].errorColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleSize = 75.0f;
    [KVNProgress appearance].lineWidth = 2.0f;
}


- (void)customUI{
    [self.collectionView registerNib:[UINib nibWithNibName:@"SongCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"coll"];
    
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.minimumLineSpacing = 40;
    flowLayout.itemSize=CGSizeMake((SCREEN_WIDTH - 60) / 2, (SCREEN_WIDTH - 60) / 2 + 50);
    
    self.collectionView.collectionViewLayout = flowLayout;
}

- (void)createRefreshHeadView
{
    //防止循环引用
    __weak typeof(self) weakSelf = self;
    [self.collectionView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        //如果正在刷新中，直接返回
        if (weakSelf.isRefreshing) {
            return ;
        }
        weakSelf.isRefreshing = YES;
        weakSelf.page = 1;
        [self fetchData:weakSelf.page];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //刷新结束
            //1:刷表
            [weakSelf.collectionView reloadData];
            //2:设置刷新状态为NO
            weakSelf.isRefreshing = NO;
            //3:通知刷新视图，结束刷新
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView headerEndRefreshingWithResult:JHRefreshResultSuccess];
        });
    }];
}

- (void)createRefreshFootView
{
    __weak typeof(self) weakSelf = self;
    [self.collectionView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        if (weakSelf.isRefreshing) {
            return ;
        }
        weakSelf.isRefreshing = YES;
        weakSelf.page++;
        [self fetchData:weakSelf.page];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //上拉加载更多结束
            [weakSelf.collectionView reloadData];
            weakSelf.isRefreshing = NO;
            //让footView 结束刷新状态
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView footerEndRefreshing];
        });
    }];
}


#pragma mark - 网络请求

- (void)fetchData:(NSInteger)page{
    [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:URL_SONG, self.page] success:^(id responsData) {
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        for (SongModel *model in [SongsModel parseRespondsData:responsData]) {
            [self.dataSource addObject:model];
        }
        [self.collectionView reloadData];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"coll" forIndexPath:indexPath];
    SongsModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell updateWithModel:model];
    return cell;
}


//调整边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [KVNProgress showWithStatus:@"歌单加载中..."];
    [self.songData removeAllObjects];
    [self.songList removeAllObjects];
    [self fenchSongData:indexPath.row];
}

- (void)fenchSongData:(NSInteger)index{//获取列表
    [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:URL_SONGMODEL, ((SongsModel *)self.dataSource[index]).listid] success:^(id responsData) {
        NSArray *arr = responsData[@"content"];
        for (NSDictionary *dic in arr) {
            NSString *song_id = dic[@"song_id"];
            [self.songData addObject:song_id];
        }
        [self loadSongList];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)loadSongList{
    for (int i = 0; i < self.songData.count; i++) {
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, self.songData[i], SONG_URL_X] success:^(id responsData) {
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            [self.songList addObject:oneSong];
            if (self.songList.count == self.songData.count) {
                self.loadMusic(self.songList);
                [KVNProgress dismiss];
            }
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
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
