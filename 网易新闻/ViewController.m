//
//  ViewController.m
//  网易新闻
//
//  Created by kun on 16/8/17.
//  Copyright © 2016年 kun. All rights reserved.
//

#import "ViewController.h"
#import "TopLineViewController.h"
#import "HotViewController.h"
#import "SocialViewController.h"
#import "ReaderViewController.h"
#import "ScienceViewController.h"
#import "VideoViewController.h"

#define ScreenW ([UIScreen mainScreen].bounds.size.width)
#define ScreenH ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) NSMutableArray *titleButtons;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"网易新闻";
    // 添加标题滚动视图
    [self setupTitleScrollView];
    // 添加内容滚动视图
    [self setupContentScrollView];
    // 添加所有自控制器
    [self setupAllChildViewController];
    // 添加所有标题
    [self setupAllTitle];
    // 处理标题点击
    // iOS7以后，导航控制器中scrollView顶部会添加64的额外滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark - 添加标题滚动视图
- (void)setupTitleScrollView
{
    // 创建titleScrollview
    UIScrollView *titleScrollView = [[UIScrollView alloc] init];
    CGFloat y = self.navigationController.navigationBarHidden ? 20 : 64;
    titleScrollView.frame = CGRectMake(0, y, self.view.bounds.size.width, 44);
    titleScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:titleScrollView];
    _titleScrollView = titleScrollView;
}
#pragma mark - 添加内容滚动视图
- (void)setupContentScrollView
{
    // 创建contentScrollview
    UIScrollView *contentScrollview = [[UIScrollView alloc] init];
    CGFloat y = CGRectGetMaxY(self.titleScrollView.frame);
    contentScrollview.frame = CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height - y);
    [self.view addSubview:contentScrollview];
    _contentScrollView = contentScrollview;
    // 设置contentScrollView的属性
    // 分页
    self.contentScrollView.pagingEnabled = YES;
    // 弹簧
    self.contentScrollView.bounces = NO;
    // 指示器
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    // 设置代理,监听内容滚动视图 什么时候滚动完成
    self.contentScrollView.delegate = self;
    
}
#pragma mark - 添加所有自控制器
- (void)setupAllChildViewController
{
    // 头条
    TopLineViewController *vc1 = [[TopLineViewController alloc] init];
    vc1.title = @"头条";
    [self addChildViewController:vc1];
    // 热点
    HotViewController *vc2 = [[HotViewController alloc] init];
    vc2.title = @"热点";
    [self addChildViewController:vc2];
    // 视频
    VideoViewController *vc3 = [[VideoViewController alloc] init];
    vc3.title = @"视频";
    [self addChildViewController:vc3];
    // 社会
    SocialViewController *vc4 = [[SocialViewController alloc] init];
    vc4.title = @"社会";
    [self addChildViewController:vc4];
    // 订阅
    ReaderViewController *vc5 = [[ReaderViewController alloc] init];
    vc5.title = @"订阅";
    [self addChildViewController:vc5];
    // 科技
    ScienceViewController *vc6 = [[ScienceViewController alloc] init];
    vc6.title = @"科技";
    [self addChildViewController:vc6];
    
}
#pragma mark - 添加所有标题
- (void)setupAllTitle
{
    // 添加所有标题按钮
    NSUInteger count = self.childViewControllers.count;
    CGFloat btnW = self.titleScrollView.bounds.size.width / 4.0;
    CGFloat btnH = self.titleScrollView.bounds.size.height;
    CGFloat btnX = 0;
    for ( int i = 0; i < count; i++ )
    {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIViewController *vc = self.childViewControllers[i];
        [titleButton setTitle:vc.title forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnX = i * btnW;
        titleButton.frame = CGRectMake(btnX, 0, btnW, btnH);
        // 监听按钮点击
        [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.tag = i;
        [self.titleScrollView addSubview:titleButton];
        // 把标题按钮添加到数组里
        [self.titleButtons addObject:titleButton];
        if ( 0 == i )
        {
            [self titleClick:titleButton];
        }
    }
    // 设置标题的滚动范围
    [self.titleScrollView setContentSize:CGSizeMake(count * btnW, 0)];
    // 设置内容的滚动范围
    self.contentScrollView.contentSize = CGSizeMake(count * ScreenW, 0);
}
#pragma makr - 标题点击事件
- (void)titleClick:(UIButton *)button
{
    NSInteger index = button.tag;
    // 标题颜色 变成 红色
    [self selectButton:button];
    // 把对应子控制器的View添加上去
    [self setupOneViewController:index];
    // 内容滚动视图滚动到对应的位置
    CGFloat x = index * [UIScreen mainScreen].bounds.size.width;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
}
- (void)setupOneViewController:(NSInteger)index
{
    UIViewController *vc = self.childViewControllers[index];
    if ( vc.view.superview )
        return;
    CGFloat x = index * [UIScreen mainScreen].bounds.size.width;
    vc.view.frame = CGRectMake(x, 0, [UIScreen mainScreen].bounds.size.width, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:vc.view];
}
#pragma mark - 选中标题
- (void)selectButton:(UIButton *)button
{
    if ( _selectedButton )
    {
        _selectedButton.transform = CGAffineTransformIdentity;
        [_selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // 标题居中
    [self setupTitleCenter:button];
    button.transform = CGAffineTransformMakeScale(1.3, 1.3);
    _selectedButton = button;
}
#pragma mark - 标题剧中
- (void)setupTitleCenter:(UIButton *)button
{
    // 本质：修改titleScrollView偏移量
    CGFloat offSetX = button.center.x - ScreenW * 0.5;
    if ( offSetX < 0 )
        offSetX = 0;
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - ScreenW;
    if ( offSetX > maxOffsetX )
        offSetX = maxOffsetX;
    [self.titleScrollView setContentOffset:CGPointMake(offSetX, 0) animated:YES];
}
#pragma mark - 字体缩放
- (void)setupTitleScale:(UIButton *)button
{
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 获取标题角标
    NSInteger i = scrollView.contentOffset.x / ScreenW;
    // 获取标题
    UIButton *titleButton = self.titleButtons[i];
    // 选中标题
    [self selectButton:titleButton];
    // 把对应子控制器的view添加上去
    [self setupOneViewController:i];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 进行字体缩放
    // 1，缩放比例 2，缩放哪两个按钮
    NSInteger leftI = scrollView.contentOffset.x / ScreenW;
    NSInteger rightI = leftI + 1;
    // 获取左边的按钮
    UIButton *leftBtn = self.titleButtons[leftI];
    // 获取右边的按钮
    UIButton *rightBtn;
    NSUInteger count = self.titleButtons.count;
    if ( rightI < count )
        rightBtn = self.titleButtons[rightI];
    CGFloat scaleR = scrollView.contentOffset.x / ScreenW;
    scaleR -= leftI;
    CGFloat scaleL = 1 - scaleR;
    rightBtn.transform = CGAffineTransformMakeScale(scaleR * 0.3 + 1, scaleR * 0.3 + 1);
    leftBtn.transform = CGAffineTransformMakeScale(scaleL * 0.3 + 1, scaleL * 0.3 + 1);
    // 颜色渐变
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
}
#pragma mark - getter methods
- (NSMutableArray *)titleButtons
{
    if ( nil == _titleButtons )
    {
        _titleButtons = [NSMutableArray array];
    }
    return _titleButtons;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
