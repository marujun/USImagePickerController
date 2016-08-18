//
//  ALAsset+ImagePicker.h
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (ImagePicker)

- (CGSize)dimensions;

- (NSDate *)modifiedDate;

- (NSString *)originalFilename;

- (NSString *)localIdentifier;

- (UIImage *)fullScreenImage;

- (UIImage *)aspectRatioThumbnailImage;

- (UIImage *)aspectRatioHDImage;

- (NSData *)originalImageData;

- (UIImage *)thumbnailImageWithMaxPixelSize:(CGFloat)maxPixelSize;

/**
 *  通过照片的路径获取对应的ALAsset实例
 *
 *  @param identifier 照片的路径，例如：assets-library://asset/asset.JPG?id=DBA1FCE0-39BE-40FE-9A34-292A19835469&ext=JPG
 *
 *  @return ALAsset实例
 */
+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier;

/**
 *  Get metadata dictionary of an asset (the kind with {Exif}, {GPS}, etc...
 *
 *  @param completionHandler This block is passed a dictionary of metadata properties. See ImageIO framework for parsing/reading these. This parameter may be nil.
 */
- (void)requestMetadataWithCompletionHandler:(void(^)(NSDictionary *metadata))completionHandler;

@end
