//
//  PHPhotoLibrary+ImagePicker.h
//  CollectionView
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHPhotoLibrary (ImagePicker)

/** 通过名称去查找相册，如果相册不存在则新建一个相册 */
- (void)topLevelUserCollectionWithTitle:(NSString *)title completionHandler:(void(^)(PHAssetCollection *collection, NSError *error))completionHandler;

/** 通过名称去查找相册，如果相册不存在则返回nil */
- (PHAssetCollection *)existingTopLevelUserCollectionWithTitle:(NSString *)title;

/** 把图片保存到相册，如果相册不存在则新建一个相册 */
- (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(void(^)(PHAsset *asset, NSError *error))completionHandler;

/** 把图片文件保存到相册(需提供文件路径)，如果相册不存在则新建一个相册 */
- (void)writeImageFromFilePath:(NSString *)filePath toAlbum:(NSString *)toAlbum completionHandler:(void(^)(PHAsset *asset, NSError *error))completionHandler;

@end
