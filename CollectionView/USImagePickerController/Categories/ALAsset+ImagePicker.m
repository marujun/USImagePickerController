//
//  ALAsset+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "ALAsset+ImagePicker.h"
#import "USImagePickerController.h"
#import "USImagePickerController+Protect.h"

@implementation ALAsset (ImagePicker)

- (CGSize)dimensions
{
    return self.defaultRepresentation.dimensions;
}

- (NSDate *)modifiedDate
{
    return [self valueForProperty:ALAssetPropertyDate];;
}

- (NSString *)localIdentifier
{
    return self.defaultRepresentation.url.absoluteString;
}

- (UIImage *)fullScreenImage
{
    return [UIImage imageWithCGImage:self.defaultRepresentation.fullScreenImage];
}

- (UIImage *)aspectRatioThumbnailImage
{
    return [UIImage imageWithCGImage:self.aspectRatioThumbnail];
}

- (NSData *)originalImageData
{
    NSData *data = nil;
    @autoreleasepool {
        ALAssetRepresentation *representation = self.defaultRepresentation;
        Byte *buffer = (Byte*)malloc((size_t)representation.size);
        
        NSError *error;
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(NSUInteger)representation.size error:&error];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
}

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    __block ALAsset *imageAsset = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[USImagePickerController defaultAssetsLibrary] assetForURL:[NSURL URLWithString:identifier]
                                                        resultBlock:^(ALAsset *asset) {
                                                            @autoreleasepool {
                                                                imageAsset = asset;
                                                            }
                                                            
                                                            dispatch_semaphore_signal(sema);
                                                        }
                                                       failureBlock:^(NSError *error) {
                                                           dispatch_semaphore_signal(sema);
                                                       }];
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return imageAsset;
}

@end
