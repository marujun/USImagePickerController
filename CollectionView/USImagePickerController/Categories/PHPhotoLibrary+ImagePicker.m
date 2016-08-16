//
//  PHPhotoLibrary+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHPhotoLibrary+ImagePicker.h"

@implementation PHPhotoLibrary (ImagePicker)

+ (void)topLevelUserCollectionWithTitle:(NSString *)title completionHandler:(void(^)(PHAssetCollection *collection, NSError *error))completionHandler
{
    PHAssetCollection *collection = [self existingTopLevelUserCollectionWithTitle:title];
    if (collection) {
        completionHandler?completionHandler(collection, nil):nil;
    }
    else {
        //使用输入名称创建一个新的相册
        __block NSString *localIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            
            localIdentifier = [collectonRequest placeholderForCreatedAssetCollection].localIdentifier;
            
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    completionHandler?completionHandler(nil, error):nil;
                }
                else {
                    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[localIdentifier] options:nil];
                    completionHandler?completionHandler([fetchResult firstObject], nil):nil;
                }
            });
        }];
    }
}

+ (PHAssetCollection *)existingTopLevelUserCollectionWithTitle:(NSString *)title;
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"localizedTitle == %@", title];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:options];
    if (fetchResult.count) {
        return fetchResult.firstObject;
    }
    
    return nil;
}

+ (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(void(^)(PHAsset *asset, NSError *error))completionHandler
{
    [self writeImageWithObject:image toAlbum:toAlbum completionHandler:completionHandler];
}

+ (void)writeImageFromFilePath:(NSString *)filePath toAlbum:(NSString *)toAlbum completionHandler:(void(^)(PHAsset *asset, NSError *error))completionHandler
{
    [self writeImageWithObject:filePath toAlbum:toAlbum completionHandler:completionHandler];
}

+ (void)writeImageWithObject:(id)object toAlbum:(NSString *)toAlbum completionHandler:(void(^)(PHAsset *asset, NSError *error))completionHandler
{
    [self topLevelUserCollectionWithTitle:toAlbum completionHandler:^(PHAssetCollection *collection, NSError *error) {
        if (error) {
            completionHandler?completionHandler(nil, error):nil;
            return ;
        }
        
        //把照片写入相册
        __block NSString *localIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //请求创建一个Asset
            PHAssetChangeRequest *assetRequest = nil;
            if ([object isKindOfClass:[UIImage class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:object];
            } else if ([object isKindOfClass:[NSString class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:object]];
            }
            assetRequest.creationDate = [NSDate date];
            
            //不提供AssetCollection则默认放到CameraRoll中
            if(collection){
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加照片
                [collectonRequest addAssets:@[placeHolder]];
            }
            
            localIdentifier = [[assetRequest placeholderForCreatedAsset] localIdentifier];
            
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    completionHandler?completionHandler(nil, error):nil;
                }
                else {
                    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
                    completionHandler?completionHandler([fetchResult firstObject], nil):nil;
                }
            });
        }];
    }];
}

@end
