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

/**
 注意事项：
  8.1~8.2：即使PHImageRequestOptions的resizeMode设置为PHImageRequestOptionsResizeModeExact，使用requestImageForAsset获取到的图片尺寸也和设置的targetSize不一致；并且获取PHPhotoLibrary的速度特别慢！
  8.3~8.4：当图片的imageOrientation不是UIImageOrientationUp时，使用requestImageForAsset获取到的图片尺寸和设置的targetSize的宽高是颠倒的；如果PHImageRequestOptions设置了normalizedCropRect，返回的图片内容和设置的裁剪区域的内容完全不一样！
           http://stackoverflow.com/questions/30288789/requesting-images-to-phimagemanager-results-in-wrong-image-in-ios-8-3

  所以想要正常使用没有BUG,还是只支持到iOS9吧！！！
 */

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
