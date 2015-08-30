//
//  MCPhotoBrower.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/29.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "MCPhotoBrower.h"
#import "MCPhotoCollectionCell.h"

@interface MCPhotoBrower () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSInteger _currentIndex;
    NSMutableArray *_dataSource;
}

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation MCPhotoBrower

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _dataSource = [NSMutableArray array];
    
    self.view.clipsToBounds = true;
    
    NSString *identifier = NSStringFromClass([MCPhotoCollectionCell class]);
    [_collectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    
    _flowCollectionLayout.itemSize = ScreenSize;
    _flowCollectionLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _flowCollectionLayout.minimumLineSpacing = 20;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self fetchAssets];
    
    //添加单双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)fetchAssets
{
    ALAssetsGroupEnumerationResultsBlock groupBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (_dataSource.count == 49) {
            *stop = YES;
        }
        
        if (asset) {
            [_dataSource addObject:asset];
        }
    };
    
    ALAssetsFilter *assetsFilter =  [ALAssetsFilter allPhotos];
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets){
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:groupBlock];
                
                _currentIndex = MIN(2, _dataSource.count-1);
                
                self.title = [NSString stringWithFormat:@"%@ / %@", @(_currentIndex+1), @(_dataSource.count)];
                [_collectionView reloadData];
                
                [self scrollToCurrentItemAnimated:NO];
            }
            *stop = YES;
        }
    };
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:libraryBlock
                                failureBlock:nil];
}

#pragma mark - 单双击手势触发
- (void)handleDoubleTap:(UITapGestureRecognizer*)tap
{
    CGPoint touchPoint = [tap locationInView:tap.view];
    
    NSArray *cellArray = _collectionView.visibleCells;
    for (MCPhotoCollectionCell *cell in cellArray) {
        [cell doubleTapWithPoint:touchPoint index:_currentIndex];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer*)tap
{
    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];//显示导航栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];  // 显示状态栏
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];//隐藏导航栏
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];  // 隐藏状态栏
    }
}

- (void)scrollToCurrentItemAnimated:(BOOL)animated
{
    CGPoint offset = CGPointMake(_collectionView.bounds.size.width*_currentIndex, 0.0);
    [_collectionView setContentOffset:offset animated:NO];
}

#pragma mark - 监控横竖屏切换

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        
        [self scrollToCurrentItemAnimated:NO];
        
        [_flowCollectionLayout setItemSize:ScreenSize];
        [_flowCollectionLayout invalidateLayout];
        
        [_collectionView reloadData];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([MCPhotoCollectionCell class]);
    MCPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell initWithAsset:_dataSource[indexPath.row] index:indexPath.row];
    
    return cell;
}

#pragma mark UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];//隐藏导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];  // 隐藏状态栏
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    _currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.title = [NSString stringWithFormat:@"%@ / %@", @(_currentIndex+1), @(_dataSource.count)];
}

@end
