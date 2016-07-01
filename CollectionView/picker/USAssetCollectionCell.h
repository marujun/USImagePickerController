//
//  USAssetCollectionCell.h
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetsViewController.h"

@interface USAssetCollectionCell : UICollectionViewCell

@property (nonatomic, assign) CGSize thumbnailTargetSize;
@property (nonatomic, weak) PHImageRequestOptions *thumbnailRequestOptions;
@property (nonatomic, weak) PHCachingImageManager *imageManager;

- (void)bind:(id)asset selected:(BOOL)selected;

@end
