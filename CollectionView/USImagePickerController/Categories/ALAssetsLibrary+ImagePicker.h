//
//  ALAssetsLibrary+ImagePicker.h
//  CollectionView
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (ImagePicker)

/** 把图片保存到相册，如果相册不存在则新建一个相册 */
- (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(void (^)(ALAsset *asset, NSError *error))completionHandler;

/** 把A相册中的图片添加到B相册中，如果相册不存在则新建一个相册 */
- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)toAlbum completionHandler:(void (^)(ALAsset *asset, NSError *error))completionHandler;

@end
