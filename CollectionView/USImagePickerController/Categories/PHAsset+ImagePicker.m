//
//  PHAsset+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"
#import "USImagePickerController+Macro.h"
#import "PHAsset+ImagePicker.m"
#import "USImagePickerController+Protect.h"

@implementation PHAsset (ImagePicker)

- (CGSize)dimensions
{
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (NSDate *)modifiedDate
{
    return [self creationDate];
}

- (NSString *)originalFilename
{
    NSString *fname = nil;
    
    if (NSClassFromString(@"PHAssetResource")) {
        NSArray *resources = [PHAssetResource assetResourcesForAsset:self];
        fname = [(PHAssetResource *)[resources firstObject] originalFilename];
    }
    
    if (!fname) {
        fname = [self valueForKey:@"filename"];
    }
    return fname;
}

- (UIImage *)fullScreenImage
{
    return [self thumbnailImageWithMaxPixelSize:USFullScreenImageMaxPixelSize];
}

- (UIImage *)aspectRatioThumbnailImage
{
    CGFloat minPixelSize = 256.f;
    CGFloat maxPixelSize = 1280.f;
    
    CGSize imageSize = CGSizeZero;
    
    if (self.pixelHeight > self.pixelWidth) {
        if (self.pixelHeight / self.pixelWidth > maxPixelSize / minPixelSize) {
            imageSize = CGSizeMake(floorf(maxPixelSize * self.pixelWidth / self.pixelHeight), maxPixelSize);
        } else {
            imageSize = CGSizeMake(minPixelSize, ceilf(minPixelSize * self.pixelHeight / self.pixelWidth));
        }
    } else {
        if (self.pixelWidth / self.pixelHeight > maxPixelSize / minPixelSize) {
            imageSize = CGSizeMake(maxPixelSize, floorf(maxPixelSize * self.pixelHeight / self.pixelWidth));
        } else {
            imageSize = CGSizeMake(ceilf(minPixelSize * self.pixelWidth / self.pixelHeight), minPixelSize);
        }
    }
    
    return [self imageAspectFitWithSize:imageSize];
}

- (UIImage *)aspectRatioHDImage
{
    return [self thumbnailImageWithMaxPixelSize:USAspectRatioHDImageMaxPixelSize];
}

- (NSData *)originalImageData
{
    __block NSData *data;
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        USPickerLog(@"download image data from iCloud: %.1f%%", 100*progress);
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

- (UIImage *)thumbnailImageWithMaxPixelSize:(CGFloat)maxPixelSize
{
    UIImage *image;
    if (self.dimensions.height > self.dimensions.width) {
        if (self.dimensions.height > maxPixelSize) {
            image = [self imageAspectFitWithSize:CGSizeMake(self.dimensions.width / self.dimensions.height * maxPixelSize, maxPixelSize)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
        }
    }
    else {
        if (self.dimensions.width > maxPixelSize) {
            image = [self imageAspectFitWithSize:CGSizeMake(maxPixelSize, self.dimensions.height / self.dimensions.width * maxPixelSize)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
        }
    }
    
    return image;
}

- (UIImage *)imageAspectFitWithSize:(CGSize)size
{
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous  = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        USPickerLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:size
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                @autoreleasepool {
                                                    image = result;
                                                }
                                            }];
    return image;
}

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
}

@end
