//
//  USImagePickerController.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+ImagePicker.h"
#import "ALAsset+ImagePicker.h"
#import "PHPhotoLibrary+ImagePicker.h"
#import "ALAssetsLibrary+ImagePicker.h"

@protocol USImagePickerControllerDelegate;

@interface USImagePickerController : UINavigationController

@property (nonatomic, weak) id <UINavigationControllerDelegate, USImagePickerControllerDelegate> delegate;

/*!
 @property
 @brief 是否允许编辑选择的照片，默认为NO
 */
@property (nonatomic, assign) BOOL allowsEditing;

/*!
 @property
 @brief 裁剪已选照片时的遮罩区域尺寸的宽高比(allowsEditing必须设置为YES)，默认为1
 */
@property (nonatomic, assign) CGFloat cropMaskAspectRatio;

/*!
 @property
 @brief 是否允许选择多张照片，默认为NO
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/*!
 @property
 @brief 在允许选择多张照片的情况，最大选择张数，默认无限制
 */
@property (nonatomic, assign) NSInteger maxSelectNumber;

/*!
 @property
 @brief 是否已选择使用原图，默认为NO
 */
@property (nonatomic, assign, readonly) BOOL selectedOriginalImage;

/*!
 @property
 @brief 用户自定义flags
 */
@property (nonatomic, assign) NSInteger flags;

@end


@protocol USImagePickerControllerDelegate <NSObject>

@optional

/** 当allowsEditing为NO时mediaImage为经过处理的高清图 */
- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithImage:(UIImage *)mediaImage;

/** 当allowsEditing为NO时才会执行该代理函数 */
- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithAsset:(id)asset;

/** 当allowsMultipleSelection为YES时才会执行该代理函数 */
- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets;

/** 点击取消按钮的时候执行该代理函数 */
- (void)imagePickerControllerDidCancel:(USImagePickerController *)picker;

@end