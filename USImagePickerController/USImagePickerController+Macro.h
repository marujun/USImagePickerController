//
//  USImagePickerController+Macro.h
//  USImagePickerController
//
//  Created by marujun on 16/7/14.
//  Copyright © 2016年 marujun. All rights reserved.
//

//8.1以下的系统获取不到相机胶卷，继续使用ALAssetsLibrary
#define PHPhotoLibraryClass ((NSFoundationVersionNumber<NSFoundationVersionNumber_iOS_8_1)?nil:NSClassFromString(@"PHPhotoLibrary"))

/**
 注意事项：
 8.1~8.2：即使PHImageRequestOptions的resizeMode设置为PHImageRequestOptionsResizeModeExact，使用requestImageForAsset获取到的图片尺寸也和设置的targetSize不一致；并且获取PHPhotoLibrary的速度特别慢！
 8.3~8.4：当图片的imageOrientation不是UIImageOrientationUp时，使用requestImageForAsset获取到的图片尺寸和设置的targetSize的宽高是颠倒的；如果PHImageRequestOptions设置了normalizedCropRect，返回的图片内容和设置的裁剪区域的内容完全不一样！
 http://stackoverflow.com/questions/30288789/requesting-images-to-phimagemanager-results-in-wrong-image-in-ios-8-3
 
 所以想要正常使用一些高级功能没有BUG，还是只支持到iOS9吧；如果只是简单的用于获取全屏图和原图可以从iOS8开始支持！！！
 */

#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define USPickerTintColor   RGBACOLOR(26,178,10,1)  //模仿微信的绿色

#ifdef DEBUG
#define USPickerLog(fmt,...)    NSLog((@"[%@][%d] " fmt),[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,##__VA_ARGS__)
#else
#define USPickerLog(fmt,...)
#endif
