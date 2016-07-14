//
//  PHAsset+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"
#import "USImagePickerController+Macro.h"

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
    CGFloat scale =  MAX(1.0, MIN(self.pixelWidth, self.pixelHeight)/USFullScreenImageMinLength);
    CGSize retinaScreenSize = CGSizeMake(self.pixelWidth/scale, self.pixelHeight/scale);
    
    return [self imageAspectFitWithSize:retinaScreenSize];
}

- (UIImage *)aspectRatioThumbnailImage
{
    return [self aspectRatioImage:200];
}

- (UIImage *)aspectRatioHDImage
{
    UIImage *image;
    if (self.dimensions.height > self.dimensions.width) {
        if (self.dimensions.height > USAspectRatioHDImageMaxLength) {
            image = [self imageAspectFitWithSize:CGSizeMake(self.dimensions.width / self.dimensions.height * USAspectRatioHDImageMaxLength, USAspectRatioHDImageMaxLength)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
        }
    }
    else {
        if (self.dimensions.width > USAspectRatioHDImageMaxLength) {
            image = [self imageAspectFitWithSize:CGSizeMake(USAspectRatioHDImageMaxLength, self.dimensions.width / self.dimensions.height * USAspectRatioHDImageMaxLength)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
        }
    }
    
    return image;
}

- (UIImage *)aspectRatioImage:(NSInteger)miniLength
{
    CGFloat scale = MIN(self.pixelWidth, self.pixelHeight)/(1.f*miniLength);
    CGSize targetSize = CGSizeMake(MIN(self.pixelWidth/scale, miniLength*4.f), MIN(self.pixelHeight/scale, miniLength*4.f));
    
    return [self imageAspectFitWithSize:targetSize];
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

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
}

@end
