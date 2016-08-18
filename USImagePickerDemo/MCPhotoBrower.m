//
//  MCPhotoBrower.m
//  USImagePickerController
//
//  Created by 马汝军 on 15/8/29.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "MCPhotoBrower.h"
#import "USAssetsPageViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MCPhotoBrower ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation MCPhotoBrower

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataSource = [NSMutableArray array];
    
    [self fetchAssets];
}

- (void)fetchAssets
{
    if ([PHPhotoLibrary class]) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        if ([options respondsToSelector:@selector(fetchLimit)]) {
            options.fetchLimit =  50;
        }
        
        PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
        
        [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_dataSource.count == 49) {
                *stop = YES;
            }
            
            if (asset && [asset isKindOfClass:[PHAsset class]]) {
                [_dataSource addObject:asset];
            }
        }];
        
        [self pushAssetsPageViewController];
        
        return;
    }
    
    ALAssetsGroupEnumerationResultsBlock groupBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (_dataSource.count == 49) {
            *stop = YES;
        }
        
        if (asset) {
            [_dataSource addObject:asset];
        }
    };
    
    ALAssetsFilter *assetsFilter =  [ALAssetsFilter allPhotos];
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets){
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:groupBlock];
                
                [self pushAssetsPageViewController];
            }
            *stop = YES;
        }
    };
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:libraryBlock
                                failureBlock:nil];
}

- (void)updateTitle:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"%@ / %@", @(index), @(_dataSource.count)];
}

- (void)pushAssetsPageViewController
{
    USAssetsPageViewController *pageVC = [[USAssetsPageViewController alloc] initWithAssets:_dataSource];
    pageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    __weak typeof(self) weak_self = self;
    [pageVC setIndexChangedHandler:^(NSInteger index) {
        [weak_self updateTitle:index];
    }];
    pageVC.pageIndex = 0;
    
    [self.view addSubview:pageVC.view];
    [self addChildViewController:pageVC];
    
    NSDictionary *views = @{@"view":pageVC.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];
}

@end
