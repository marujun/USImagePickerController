//
//  ImageCollectionViewCell.m
//  CollectionView
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImageCollectionViewCell.h"

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
    
    [self addSubview:_imageView];
}

- (void)updateWithPHAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize
{
    NSInteger tag = self.tag + 1;
    self.tag = tag;
    
    [_imageManager cancelImageRequest:self.requestID];
    
    _requestID = [_imageManager requestImageForAsset:phAsset
                                          targetSize:targetSize
                                         contentMode:PHImageContentModeAspectFill
                                             options:_requestOptions
                                       resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                           if (self.tag == tag) {
                                               _imageView.image = result;
                                           }
                                       }];
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
