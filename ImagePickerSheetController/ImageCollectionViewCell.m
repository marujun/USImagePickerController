//
//  ImageCollectionViewCell.m
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "USImagePickerController+Protect.h"

@interface ImageCollectionViewCell ()

@property (nonatomic, assign) PHImageRequestID requestID;

@end

@implementation ImageCollectionViewCell

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = RGBACOLOR(205, 205, 205, 1);
    
    [self addSubview:_imageView];
}

- (void)updateWithPHAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize
{
    NSInteger tag = self.tag + 1;
    self.tag = tag;
    
    [_phImageManager cancelImageRequest:self.requestID];
    
    _requestID = [_phImageManager requestImageForAsset:phAsset
                                            targetSize:[PHAsset targetSizeByCompatibleiPad:targetSize]
                                           contentMode:PHImageContentModeAspectFill
                                               options:_requestOptions
                                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                             if (self.tag == tag && result) {
                                                 _imageView.image = result;
                                             }
                                         }];
}

- (void)updateWithALAsset:(ALAsset *)alAsset targetSize:(CGSize)targetSize
{
    NSInteger tag = self.tag + 1;
    self.tag = tag;
    
    NSString *identifier = [alAsset defaultRepresentation].url.absoluteString;
    
    UIImage *image = _alImageManager[identifier];
    
    if (image) {
        _imageView.image = image;
        return;
    }
    
    _imageView.image = alAsset.aspectRatioThumbnailImage;
    
    if (MIN(targetSize.width, targetSize.height) < (MIN(_imageView.image.size.width, _imageView.image.size.height)+20)) {
        return;
    }
    
    __weak ImageCollectionViewCell *weak_self = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *targetImage = [alAsset thumbnailImageWithMaxPixelSize:MAX(targetSize.width, targetSize.height)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.tag == tag && targetImage) {
                weak_self.imageView.image = targetImage;
                [weak_self.alImageManager setValue:targetImage forKeyPath:identifier];
            }
        });
    });
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _imageView.image = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

@end
