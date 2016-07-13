//
//  USImagePickerController+Protect.h
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"
#import "ALAsset+ImagePicker.h"

//8.1以下的系统获取不到相机胶卷，继续使用ALAssetsLibrary
#define PHPhotoLibraryClass ((NSFoundationVersionNumber<NSFoundationVersionNumber_iOS_8_1)?nil:NSClassFromString(@"PHPhotoLibrary"))

#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define USPickerTintColor   RGBACOLOR(26,178,10,1)  //模仿微信的绿色


NS_ASSUME_NONNULL_BEGIN

@interface USImagePickerController (USImagePickerControllerProtectedMethods)

@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

/**
 *  返回单例对象ALAssetsLibrary
 */
+ (ALAssetsLibrary *)defaultAssetsLibrary NS_DEPRECATED_IOS(4_0, 8_0, "Use PHImageManager instead");


- (void)setSelectedOriginalImage:(BOOL)allowsOriginalImage;

@end

NS_ASSUME_NONNULL_END
