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

/** 图片加载状态发生变化时的通知 */
FOUNDATION_EXPORT NSString * const USImageLoadingStatusChangedNotification;

@interface USAssetScrollView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;

/** 是否正在加载图片中：Loading动画 出现的时候没有效果，消失的时候会有一个渐隐效果 */
@property (nonatomic, assign) BOOL isLoading;

- (void)initWithImage:(UIImage *)image;

- (void)initWithALAsset:(ALAsset *)asset;

- (void)initWithPHAsset:(PHAsset *)asset;

- (void)doubleTapWithPoint:(CGPoint)point;

@end
