//
//  ZommViewsController.m
//  imageZoom
//
//  Created by 孙国志 on 14/11/5.
//  Copyright (c) 2014年 孙国志. All rights reserved.
//

#import "PhotosBrowserController.h"
#import "ZoomViewController.h"
#import "BrowserToolbar.h"
#import "PhotoItem.h"

#define KSpace 20   //图片之间的间隙
#define KToolBarHeight  44  //boolBar的高度

@interface PhotosBrowserController ()<UIScrollViewDelegate>

/**
 * 用于容纳多个视图控制器用于多图浏览
 */
@property (nonatomic, strong) UIScrollView *mainScrollView;

/**
 * 工具栏，功能自定
 */
@property (nonatomic, strong) BrowserToolbar *toolBar;

/**
 * 当前显示的页面的索引
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 * 回调用
 */
@property (nonatomic, copy) finishBlock block;
@end

@implementation PhotosBrowserController

- (instancetype)initWithImageArr:(NSArray *)imageArr imageIndex:(NSInteger)index finish:(finishBlock)block
{
    if (self = [super init])
    {
        self.photos = imageArr;
        self.currentIndex = index;
        self.block = block;
        self.zoomViewControllers = [@[] mutableCopy];
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark life cycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)loadView
{
    [super loadView];
    [self setUp];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.toolBar hidden:.7];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUp
{
    [self initScrollView];
    [self initToolBar];
}
//添加toolBar
- (void)initToolBar
{
    self.toolBar = [[BrowserToolbar alloc] initWithFrame:(CGRect){
        {0   ,[UIScreen mainScreen].bounds.size.height - KToolBarHeight},
        {[UIScreen mainScreen].bounds.size.width   ,KToolBarHeight}
    }];
    [self.toolBar setCurrentPageNumber:self.currentIndex + 1 andTotoal:self.photos.count];
    self.toolBar.backgroundColor = [UIColor whiteColor];
    self.toolBar.alpha = 0.9;
    [self.view addSubview:self.toolBar];
}
//添加ScrollView 多图浏览用
- (void)initScrollView
{
    CGSize mainScreenSize = [UIScreen mainScreen].bounds.size;
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){
        {0  ,0},
        {mainScreenSize.width + KSpace ,mainScreenSize.height}
    }];
    self.mainScrollView.delegate = self;
    self.mainScrollView.backgroundColor = [UIColor blackColor];
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.contentSize = CGSizeMake(self.photos.count * (mainScreenSize.width + KSpace), mainScreenSize.height);
    self.mainScrollView.contentOffset = CGPointMake(_currentIndex * (mainScreenSize.width + KSpace), 0);
    
    [self.view addSubview:self.mainScrollView];
    
    [self addPhotosInScrollView];
}
//将多组viewController添加到scrollView上
- (void)addPhotosInScrollView
{
    CGSize mainScreenSize = [UIScreen mainScreen].bounds.size;
    [self.photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIView *zoomView = [[UIView alloc] initWithFrame:CGRectMake(idx * (KSpace + mainScreenSize.width), 0, mainScreenSize.width,mainScreenSize.height)];
        zoomView.backgroundColor = [UIColor blackColor];
        ZoomViewController *viewController = [[ZoomViewController alloc] initWithImageView:obj finish:self.block];
        if (idx != _currentIndex)
        {
            [viewController.view setHidden:YES];
            viewController.isCurrentPage = NO;
        }
        else
        {
            viewController.isCurrentPage = YES;
        }
        
        [zoomView addSubview:viewController.view];
        [self addChildViewController:viewController];
        [self.zoomViewControllers addObject:viewController];
        [self.mainScrollView addSubview:zoomView];
    }];
}

#pragma mark ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.toolBar show:0.3f];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.toolBar hidden:0.7];
    [self setCurrentPage:(self.mainScrollView.contentOffset.x + KSpace)/(self.view.frame.size.width + KSpace)];
}

- (void)setCurrentPage:(NSInteger)pageIndex
{
    [self.toolBar setCurrentPageNumber:pageIndex + 1];
    [self.zoomViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZoomViewController *zoomViewController = obj;
        if (pageIndex == idx)
        {
            zoomViewController.isCurrentPage = YES;
        }
        else
        {
            zoomViewController.isCurrentPage = NO;
            [zoomViewController resetImageFrame];
        }
    }];
}

@end
