//
//  USAssetsViewController.m
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetsViewController.h"
#import "USAssetCollectionCell.h"

#define MinAssetItemLength     80.f
#define AssetItemSpace         2.f

@interface USAssetsViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray *allAssets;
@property (nonatomic, assign) NSUInteger displaySelectedNum;

//PHAsset 生成缩略图及缓存时需要的数据
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, assign) CGSize thumbnailTargetSize;
@property (nonatomic, strong) PHImageRequestOptions *thumbnailRequestOptions;

@end

@implementation USAssetsViewController

- (USImagePickerController *)picker {
    return (USImagePickerController *)self.navigationController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self refreshTitle];
    
    [self setupAssets];
    [self resetCachedAssetImages];
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_displaySelectedNum==_selectedAssets.count) return;
    
    [self.collectionView reloadData];
    
    [self refreshTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateCachedAssetImages];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _displaySelectedNum = _selectedAssets.count;
}

- (void)refreshTitle
{
    if (self.picker.allowsMultipleSelection) {
        if (self.selectedAssets.count) self.title = [NSString stringWithFormat:@"%zd张照片",self.selectedAssets.count];
        else self.title = @"选择照片";
    }
    else {
        if (self.assetCollection) self.title = self.assetCollection.localizedTitle;
        else self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
}


#pragma mark - Setup

- (void)setupViews
{
    NSInteger lineMaxCount = 1;
    while ((lineMaxCount*MinAssetItemLength+(lineMaxCount+1)*AssetItemSpace) <= [[UIScreen mainScreen] bounds].size.width) {
        lineMaxCount ++;
    }
    lineMaxCount --;
    
//    lineMaxCount = MAX(4, lineMaxCount);  //一排最少4个
    CGFloat itemLength = ([[UIScreen mainScreen] bounds].size.width-AssetItemSpace*(lineMaxCount-1))/lineMaxCount;
    
    self.flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
    self.flowLayout.minimumInteritemSpacing = AssetItemSpace;
    self.flowLayout.minimumLineSpacing = AssetItemSpace;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 0);
    
    if (PHPhotoLibraryClass) {
        _thumbnailRequestOptions = [[PHImageRequestOptions alloc] init];
        _thumbnailRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _thumbnailRequestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        
        NSInteger retinaMultiplier  = MIN([UIScreen mainScreen].scale, 2);
        _thumbnailTargetSize = CGSizeMake(self.flowLayout.itemSize.width * retinaMultiplier, self.flowLayout.itemSize.height * retinaMultiplier);
    }
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    NSString *identifier = NSStringFromClass([USAssetCollectionCell class]);
    UINib *cellNib = [UINib nibWithNibName:identifier bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:identifier];
    
//    if(self.picker.allowsMultipleSelection){
//        _rightNavButton = [UIButton newRoundButtonWithTitle:@"下一步" image:[UIImage imageNamed:@"pub_nav_next"]
//                                                     target:self action:@selector(rightNavButtonAction:)];
//        
//        if (self.picker.enablePanSelect) {
//            _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//            _panGestureRecognizer.delegate = self;
//            [self.view addGestureRecognizer:_panGestureRecognizer];
//        }
//        
//        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//        [self.collectionView addGestureRecognizer:_tapGestureRecognizer];
//        
//        if (_panGestureRecognizer) {
//            [_panGestureRecognizer requireGestureRecognizerToFail:_tapGestureRecognizer];
//        }
//    }
//    else {
//        _rightNavButton = [UIButton newRoundButtonWithTitle:@"取消" image:nil target:self action:@selector(rightNavButtonAction:)];
//    }
//    [self setNavigationRightView:_rightNavButton];
}

- (void)setupAssets
{
    self.allAssets = [[NSMutableArray alloc] init];
    
    if (self.assetCollection) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)self.assetCollection;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSArray *fetchArray = [fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, fetchResult.count)]];
        [self.allAssets addObjectsFromArray:fetchArray];
        
        return;
    }
    
    [self.indicatorView startAnimating];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {
            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [self.allAssets insertObject:asset atIndex:0];
            }
        }
        else {
            [self.indicatorView stopAnimating];
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (CGRect)imageRectWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    CGRect rect = [_flowLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
    
    return [self.collectionView convertRect:rect toView:self.view];
}

- (void)scrollIndexToVisible:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    NSArray *visibleArray = [self.collectionView indexPathsForVisibleItems];
    if (![visibleArray containsObject:indexPath]) {
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([USAssetCollectionCell class]);
    USAssetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.imageManager = self.imageManager;
    cell.thumbnailTargetSize = _thumbnailTargetSize;
    cell.thumbnailRequestOptions = _thumbnailRequestOptions;
    
    [cell bind:[self assetAtIndexPath:indexPath] selected:YES];
//    cell.indexPath = indexPath;
//    cell.collectionView = collectionView;
//    
//    if (IsCameraItem(indexPath)) {
//        [cell bind:nil selected:NO];
//        cell.userInteractionEnabled = YES;
//    }
//    else {
//        PHAsset *asset = [self assetAtIndexPath:indexPath];
//        
//        cell.selectedQueue = _selectedQueue;
//        cell.imageManager = self.imageManager;
//        cell.thumbnailTargetSize = _thumbnailTargetSize;
//        cell.thumbnailRequestOptions = _thumbnailRequestOptions;
//        
//        //控制是否已上传此照片显示与否
//        if (_dateSameDiff == 0) {
//            cell.coverLabel.hidden = !self.picker.uploadedDateMapper || !self.picker.uploadedDateMapper[asset.modifiedDate];
//        }
//        else {
//            __block BOOL hasSame = NO;
//            NSDate *photo_date = asset.modifiedDate;
//            
//            [self.picker.uploadedDateMapper enumerateKeysAndObjectsUsingBlock:^(NSDate *date, id  _Nonnull obj, BOOL * _Nonnull stop) {
//                double difference = fabs([photo_date timeIntervalSinceDate:date]*1000);
//                if (difference <= _dateSameDiff) {
//                    hasSame = YES;
//                    *stop = YES;
//                }
//            }];
//            
//            cell.coverLabel.hidden = !hasSame;
//        }
//        
//        [cell bind:asset selected:_selectedAssets[asset.localIdentifier]?YES:NO];
//        
//        if(self.picker.allowsMultipleSelection){
//            cell.checkButton.hidden = NO;
//            cell.checkButton.alpha = 1;
//            cell.userInteractionEnabled = NO;
//        } else {
//            cell.checkButton.hidden = YES;
//            cell.checkButton.alpha = 0;
//            cell.userInteractionEnabled = YES;
//        }
//        cell.warningImageView.hidden = [self couldSelectImage:asset.dimensions];
//    }
    
    return cell;
}

#pragma mark - Asset images caching

- (void)resetCachedAssetImages
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (NSArray *)indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allAttributes = [self.flowLayout layoutAttributesForElementsInRect:rect];
    
    if (allAttributes.count == 0)
        return nil;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allAttributes.count];
    
    for (UICollectionViewLayoutAttributes *attributes in allAttributes) {
        NSIndexPath *indexPath = attributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    
    return indexPaths;
}

- (void)updateCachedAssetImages
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    
    if (!isViewVisible)
        return;
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self indexPathsForElementsInRect:removedRect];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            } addedHandler:^(CGRect addedRect) {
                                NSArray *indexPaths = [self indexPathsForElementsInRect:addedRect];
                                [addedIndexPaths addObjectsFromArray:indexPaths];
                            }];
        
        [self startCachingThumbnailsForIndexPaths:addedIndexPaths];
        [self stopCachingThumbnailsForIndexPaths:removedIndexPaths];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (id)assetAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if(index < 0 || index>=self.allAssets.count){
        return nil;
    }
    return [self.allAssets objectAtIndex:index];
}


- (void)startCachingThumbnailsForIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        
        if (!asset) break;
        
        [self.imageManager startCachingImagesForAssets:@[asset]
                                            targetSize:_thumbnailTargetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:_thumbnailRequestOptions];
    }
}

- (void)stopCachingThumbnailsForIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        
        if (!asset) break;
        
        [self.imageManager stopCachingImagesForAssets:@[asset]
                                           targetSize:_thumbnailTargetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:_thumbnailRequestOptions];
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void)dealloc
{
    [self.imageManager stopCachingImagesForAllAssets];
}

@end
