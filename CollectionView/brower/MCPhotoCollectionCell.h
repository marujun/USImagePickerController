//
//  MCPhotoCollectionCell.h
//  CollectionView
//
//  Created by 马汝军 on 15/8/29.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+AutoLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ScreenSize (((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width):[UIScreen mainScreen].bounds.size)

@interface MCPhotoCollectionCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (CGRect)boundsOfImage:(UIImage *)image forSize:(CGSize)size;

- (void)initWithAsset:(ALAsset *)asset index:(NSInteger)index;

- (void)doubleTapWithPoint:(CGPoint)point index:(NSInteger)index;

@end
