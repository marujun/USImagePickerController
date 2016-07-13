//
//  PHAsset+ImagePicker.h
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <Photos/Photos.h>

#define USFullScreenImageMinLength       1500.f
#define USAspectRatioHDImageMaxLength    4000.f

@interface PHAsset (ImagePicker)

- (CGSize)dimensions;

- (NSDate *)modifiedDate;

- (NSString *)filename;

- (UIImage *)fullScreenImage;

- (UIImage *)aspectRatioThumbnailImage;

- (UIImage *)aspectRatioHDImage;

- (NSData *)originalImageData;

/**
 *  通过照片的localIdentifier获取对应的PHAsset实例
 *
 *  @param identifier 照片的localIdentifier，例如：DBA1FCE0-39BE-40FE-9A34-292A19835469/L0/001
 *
 *  @return PHAsset实例
 */
+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier;

@end
