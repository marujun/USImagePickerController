//
//  PickerDemoViewController.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "PickerDemoViewController.h"

@interface PickerDemoViewController ()

@end

@implementation PickerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imageLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
}


#pragma mark -  UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 30;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"PickerCollectionCell" forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

@end
