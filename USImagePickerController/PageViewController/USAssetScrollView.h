//
//  USAssetScrollView.h
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface USAssetScrollView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)initWithImage:(UIImage *)image;

- (void)initWithALAsset:(ALAsset *)asset;

- (void)initWithPHAsset:(PHAsset *)asset;

- (void)doubleTapWithPoint:(CGPoint)point;

@end
