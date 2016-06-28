//
//  USAssetItemViewController.m
//  CollectionView
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetItemViewController.h"
#import "USAssetScrollView.h"

@interface USAssetItemViewController () 

@end

@implementation USAssetItemViewController

+ (instancetype)viewControllerForAsset:(id)asset
{
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(id)asset
{
    if (self = [super init]) {
        _asset = asset;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadAssetScrollView];
}

#pragma mark - Setup

- (void)setupViews
{
    _scrollView = [USAssetScrollView newAutoLayoutView];
    [self.view addSubview:_scrollView];
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view layoutIfNeeded];
}

- (void)reloadAssetScrollView
{
    if ([_asset isKindOfClass:[PHAsset class]]) {
        [self.scrollView initWithPHAsset:_asset];
    }
    else if ([_asset isKindOfClass:[ALAsset class]]) {
        [self.scrollView initWithALAsset:_asset];
    }
    else if ([_asset isKindOfClass:[UIImage class]]) {
        [self.scrollView initWithImage:_asset];
    }
    else if ([_asset isKindOfClass:[NSString class]]) {
        //需要从网络下载图片
//        __weak USAssetScrollView *weak_view = self.scrollView;
//        [weak_view.indicatorView startAnimating];
//        
//        [UIImage imageWithURL:_asset complete:^(UIImage *image){
//            [weak_view initWithImage:image];
//            [weak_view.indicatorView stopAnimating];
//        }];
    }
}

#pragma mark - 监控横竖屏切换

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        [self reloadAssetScrollView];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
