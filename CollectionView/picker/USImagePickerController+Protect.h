//
//  USImagePickerController+Protect.h
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

//8.3以下的系统获取不到相机胶卷，继续使用ALAssetsLibrary
#define PHPhotoLibraryClass ((NSFoundationVersionNumber<NSFoundationVersionNumber_iOS_8_3)?nil:NSClassFromString(@"PHPhotoLibrary"))


NS_ASSUME_NONNULL_BEGIN

@interface USImagePickerController (USImagePickerControllerProtectedMethods)

@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

/**
 *  返回单例对象ALAssetsLibrary
 */
+ (ALAssetsLibrary *)defaultAssetsLibrary NS_DEPRECATED_IOS(4_0, 8_0, "Use PHImageManager instead");

@end

NS_ASSUME_NONNULL_END
