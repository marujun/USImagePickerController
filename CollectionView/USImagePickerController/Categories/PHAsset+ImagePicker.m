//
//  PHAsset+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"

@implementation PHAsset (ImagePicker)

- (CGSize)dimensions
{
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (NSDate *)modifiedDate
{
    return [self creationDate];
}

- (UIImage *)fullScreenImage
{
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous  = YES;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        NSLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    CGFloat scale =  MAX(1.0, MIN(self.pixelWidth, self.pixelHeight)/USFullScreenImageMinLength);
    CGSize retinaScreenSize = CGSizeMake(self.pixelWidth/scale, self.pixelHeight/scale);
    
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:retinaScreenSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                @autoreleasepool {
                                                    image = result;
                                                }
                                            }];
    return image;
}

- (UIImage *)aspectRatioThumbnailImage
{
    return [self aspectRatioImage:200];
}

- (UIImage *)aspectRatioImage:(NSInteger)miniLength
{
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous  = YES;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        NSLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    CGFloat scale = MIN(self.pixelWidth, self.pixelHeight)/(1.f*miniLength);
    CGSize targetSize = CGSizeMake(MIN(self.pixelWidth/scale, miniLength*4.f), MIN(self.pixelHeight/scale, miniLength*4.f));
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                @autoreleasepool {
                                                    image = result;
                                                }
                                            }];
    return image;
}

- (NSData *)originalImageData
{
    __block NSData *data;
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        NSLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                      options:imageRequestOptions
                                                resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                                                    @autoreleasepool {
                                                        data = imageData;
                                                    }
                                                }];
    return data;
}

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
}

@end
