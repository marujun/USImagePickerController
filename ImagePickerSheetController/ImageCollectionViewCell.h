//
//  ImageCollectionViewCell.h
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, weak) NSMutableDictionary *alImageManager;

@property (nonatomic, weak) PHCachingImageManager *phImageManager;
@property (nonatomic, weak) PHImageRequestOptions *requestOptions;

- (void)updateWithPHAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize;

- (void)updateWithALAsset:(ALAsset *)alAsset targetSize:(CGSize)targetSize;

@end
