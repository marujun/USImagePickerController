//
//  USAssetScrollView.m
//  CollectionView
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetScrollView.h"

#define ScreenSize (((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width):[UIScreen mainScreen].bounds.size)

#define USFullScreenImageMinLength  1500.f

@interface USAssetScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) id asset;
@property (nonatomic, strong) UIImage *image;

@end

@implementation USAssetScrollView

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
    self.showsVerticalScrollIndicator   = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom                    = YES;
    self.backgroundColor                = [UIColor clearColor];
    self.decelerationRate               = UIScrollViewDecelerationRateFast;
    self.delegate                       = self;
    
    [self setupViews];
}

#pragma mark - Setup

- (void)setupViews
{
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    self.imageView = imageView;
    [self addSubview:self.imageView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicatorView = activityView;
    [self addSubview:self.indicatorView];
    
    NSDictionary *views = @{@"frameView":self.indicatorView, @"superView":self};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[frameView]-(<=1)-[superView]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[frameView]-(<=1)-[superView]"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil views:views]];
}

- (void)initWithImage:(UIImage *)image
{
    if (!image || ![image isKindOfClass:[UIImage class]]) return;
    
    _image = image;
    
    _imageView.image = image;
    _imageView.bounds = [self boundsOfImage:image forSize:ScreenSize];
    _imageView.center = CGPointMake(ScreenSize.width/2, ScreenSize.height/2);
    
    [self setMaximumZoomScale];
}

- (void)initWithALAsset:(ALAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[ALAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset] && self.image) {
        [self initWithImage:self.image];
        return;
    }
    
    self.image = nil;
    self.asset = asset;
    
    [self.indicatorView startAnimating];
    
    __weak USAssetScrollView *weak_self = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fullImage) {
                [weak_self initWithImage:fullImage];
                [weak_self.indicatorView stopAnimating];
            }
        });
    });
}

- (void)initWithPHAsset:(PHAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset] && self.image) {
        [self initWithImage:self.image];
        return;
    }
    
    self.image = nil;
    self.asset = asset;
    
    __weak USAssetScrollView *weak_self = self;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    
    CGFloat scale =  MAX(1.0, MIN(asset.pixelWidth, asset.pixelHeight)/USFullScreenImageMinLength);
    CGSize retinaScreenSize = CGSizeMake(asset.pixelWidth/scale, asset.pixelHeight/scale);
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:retinaScreenSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (result) {
                                                    [weak_self initWithImage:result];
                                                }
                                            }];
}

#pragma mark - 双击手势触发
- (void)doubleTapWithPoint:(CGPoint)point
{
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    } else {
        [self zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)setMaximumZoomScale
{
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    float scale = _imageView.image.size.width/(ScreenSize.width*scale_screen);
    
    self.maximumZoomScale = MAX(scale, 2);
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
