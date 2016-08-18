//
//  USImagePickerController+Protect.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USImagePickerController.h"
#import "USImagePickerController+Macro.h"

#define USFullScreenImageMaxPixelSize       2400.f
#define USAspectRatioHDImageMaxPixelSize    4000.f

NS_ASSUME_NONNULL_BEGIN

@interface USImagePickerController (USImagePickerControllerProtectedMethods)

@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

/**
 *  返回单例对象ALAssetsLibrary
 */
+ (ALAssetsLibrary *)defaultAssetsLibrary NS_DEPRECATED_IOS(4_0, 8_0, "Use PHImageManager instead");

- (void)setSelectedOriginalImage:(BOOL)allowsOriginalImage;

@end


@interface ALAsset (USImagePickerControllerProtectedMethods)

@end

@interface PHAsset (USImagePickerControllerProtectedMethods)

+ (BOOL)targetSizeNeedsSupportiPad;

+ (CGSize)targetSizeByCompatibleiPad:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
