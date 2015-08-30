//
//  MCPhotoCollectionCell.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/29.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "MCPhotoCollectionCell.h"

@interface MCPhotoCollectionCell ()
{
    NSInteger myIndex;
}

@end

@implementation MCPhotoCollectionCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = true;
        
        _scrollView = [[UIScrollView alloc] initForAutoLayout];
        _scrollView.maximumZoomScale = 2;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.delegate = self;
        [self.contentView addSubview:_scrollView];
        [_scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
    }
    
    return self;
}


#pragma mark - 双击手势触发
- (void)doubleTapWithPoint:(CGPoint)point index:(NSInteger)index
{
    if (myIndex != index) {
        return;
    }
    
    if (_scrollView.zoomScale > 1) {
        [_scrollView setZoomScale:1 animated:YES];
    } else {
        [_scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)initWithAsset:(ALAsset *)asset index:(NSInteger)index
{
    myIndex = index;
    
    _scrollView.zoomScale = 1.0;
    
    _imageView.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    _imageView.bounds = [self boundsOfImage:_imageView.image forSize:ScreenSize];
    _imageView.center = CGPointMake(ScreenSize.width/2, ScreenSize.height/2);
    
    [self setMaximumZoomScale];
}

- (void)setMaximumZoomScale
{
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    float scale = _imageView.image.size.width/(ScreenSize.width*scale_screen);
    
    _scrollView.maximumZoomScale = MAX(scale, 2);
}

- (CGRect)boundsOfImage:(UIImage *)image forSize:(CGSize)size
{
    CGSize imageSize = image.size;
    CGSize viewSize = size;
    
    CGSize finalSize = CGSizeZero;
    
    if (imageSize.width / imageSize.height < viewSize.width / viewSize.height) {
        finalSize.height = viewSize.height;
        finalSize.width = viewSize.height / imageSize.height * imageSize.width;
    }
    else {
        finalSize.width = viewSize.width;
        finalSize.height = viewSize.width / imageSize.width * imageSize.height;
    }
    return CGRectMake(0, 0, finalSize.width, finalSize.height);
}

#pragma mark UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *zoomView = _imageView;
    
    CGSize boundSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    
    CGFloat offsetX = (boundSize.width > contentSize.width)? (boundSize.width - contentSize.width)/2 : 0.0;
    CGFloat offsetY = (boundSize.height > contentSize.height)? (boundSize.height - contentSize.height)/2 : 0.0;
    
    zoomView.center = CGPointMake(contentSize.width/2 + offsetX, contentSize.height/2 + offsetY);
}

@end
