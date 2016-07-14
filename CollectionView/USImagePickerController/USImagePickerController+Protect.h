//
//  USImagePickerController+Protect.h
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"
#import "ALAsset+ImagePicker.h"
#import "USImagePickerController+Macro.h"

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
