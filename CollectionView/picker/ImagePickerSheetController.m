//
//  ImagePickerSheetController.m
//  CollectionView
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImagePickerSheetController.h"
#import "ImageCollectionViewCell.h"
#import "ImagePreviewTableViewCell.h"
#import "AnimationController.h"

@interface ImagePickerSheetController ()

@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *selectedImageIndices;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableDictionary *imageManager;

@property (nonatomic, assign) BOOL enlargedPreviews;
@property (nonatomic, strong) NSMutableDictionary *supplementaryViews;

@end

@implementation ImagePickerSheetController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    _actions = [NSMutableArray array];
    _assets = [NSMutableArray array];
    _selectedImageIndices = [NSMutableArray array];
    _supplementaryViews = [NSMutableDictionary dictionary];
    _imageManager = [NSMutableDictionary dictionary];
    
    _enlargedPreviews = false;
    _tableViewPreviewRowHeight = 140.0;
    _tableViewEnlargedPreviewRowHeight = 243;
    _collectionViewInset = 5.0;
    _collectionViewCheckmarkInset = 3.5;
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    [self fetchAssets];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] init];
    _tableView.accessibilityIdentifier = @"ImagePickerSheet";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.alwaysBounceVertical = false;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    _tableView.separatorInset = UIEdgeInsetsZero;
    [_tableView registerClass:[ImagePreviewTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ImagePreviewTableViewCell class])];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    _collectionView = [[ImagePickerCollectionView alloc] init];
    _collectionView.accessibilityIdentifier = @"ImagePickerSheetPreview";
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.allowsMultipleSelection = true;
    _collectionView.imagePreviewLayout.sectionInset = UIEdgeInsetsMake(_collectionViewInset, _collectionViewInset, _collectionViewInset, _collectionViewInset);
    _collectionView.imagePreviewLayout.showsSupplementaryViews = false;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.alwaysBounceHorizontal = true;
    [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class])];
    [_collectionView registerClass:[PreviewSupplementaryView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PreviewSupplementaryView class])];
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.accessibilityIdentifier = @"ImagePickerSheetBackground";
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3961];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [_backgroundView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:_backgroundView];
    [self.view addSubview:_tableView];
}

- (void)addAction:(ImageAction *)action
{
    __block ImageAction *cancelActions = nil;
    [_actions enumerateObjectsUsingBlock:^(ImageAction *obj, NSUInteger idx, BOOL *stop) {
        if (obj.style == ImageActionStyleCancel) {
            cancelActions = obj;
        }
    }];
    
    if (cancelActions && action.style==ImageActionStyleCancel) {
        [NSException raise:NSInternalInconsistencyException format:@"ImagePickerSheetController can only have one action with a style of .Cancel"];
    }
    
    [_actions addObject:action];
}

- (void)setActions:(NSMutableArray *)actions
{
    _actions = actions;
    
    if ([self isViewLoaded]) {
        [self reloadButtons];
        
        [self.view setNeedsLayout];
    }
}

- (void)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
    
}

- (void)fetchAssets
{
    ALAssetsGroupEnumerationResultsBlock groupBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (index == 50) {
            *stop = YES;
        }
        
        if (asset) {
            [_assets addObject:asset];
        }
    };
    
    ALAssetsFilter *assetsFilter =  [ALAssetsFilter allPhotos];
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets){
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:groupBlock];
            }
            *stop = YES;
        }
    };
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:libraryBlock
                               failureBlock:nil];
}

- (void)reloadButtons
{
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Images
- (CGSize)sizeForAsset:(ALAsset *)asset
{
    CGSize  size = asset.defaultRepresentation.dimensions;
    CGFloat proportion = size.width/size.height;
    
    CGFloat rowHeight = _enlargedPreviews ? _tableViewEnlargedPreviewRowHeight :_tableViewPreviewRowHeight;
    CGFloat height = rowHeight - 2.0*_collectionViewInset;
    
    return CGSizeMake((CGFloat)(floorf((float)(proportion*height))), height);
}

- (CGSize)targetSizeForAssetOfSize:(CGSize)size
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    return CGSizeMake(scale*size.width, size.height);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return _actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_assets.count > 0) {
            return _enlargedPreviews ? _tableViewEnlargedPreviewRowHeight : _tableViewPreviewRowHeight;
        }
        
        return 0;
    }
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ImagePreviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ImagePreviewTableViewCell class]) forIndexPath:indexPath];
        cell.collectionView = _collectionView;
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0);
        
        return cell;
    }
    
//    ImageAction *action = _actions[indexPath.row];
//    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
//    cell.textLabel.textAlignment = NSTextAlignmentCenter;
//    cell.textLabel.textColor = tableView.tintColor;
//    cell.textLabel.font = [UIFont systemFontOfSize:21];
//    cell.textLabel.text = _selectedImageIndices.count>0 ? action.secondaryTitle(_numberOfSelectedImages) : action.title;
//    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
    [_actions[indexPath.row] handle:_numberOfSelectedImages];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _assets.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.imageView.image = [_imageManager objectForKey:@(indexPath.section)];
    if (!cell.imageView.image) {
        ALAsset *asset = _assets[indexPath.section];
        cell.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    }
    
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.selected = [_selectedImageIndices containsObject:@(indexPath.section)];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PreviewSupplementaryView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                        withReuseIdentifier:NSStringFromClass([PreviewSupplementaryView class])
                                                                               forIndexPath:indexPath];
    view.userInteractionEnabled = false;
    view.buttonInset = UIEdgeInsetsMake(0.0, _collectionViewCheckmarkInset, _collectionViewCheckmarkInset, 0.0);
    view.selected = [_selectedImageIndices containsObject:@(indexPath.section)];
    
    [_supplementaryViews setObject:view forKey:@(indexPath.section)];
    
    return view;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self sizeForAsset:_assets[indexPath.section]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat inset = 2.0 * _collectionViewCheckmarkInset;
    CGSize size = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGFloat imageWidth = [PreviewSupplementaryView checkmarkImage].size.width;
    
    return CGSizeMake(imageWidth + inset, size.height);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_imageManager[@(indexPath.section)]) {
        ALAsset *asset = _assets[indexPath.section];
        [_imageManager setObject:[UIImage imageWithCGImage:asset.aspectRatioThumbnail] forKey:@(indexPath.section)];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_maximumSelection && _selectedImageIndices.count >= _maximumSelection && _selectedImageIndices.count) {
        NSNumber *previousItemIndex = [_selectedImageIndices firstObject];
        [_supplementaryViews[previousItemIndex] setSelected:false];
        
        [_selectedImageIndices removeObjectAtIndex:0];
    }
    
    [_selectedImageIndices addObject:@(indexPath.section)];
    
    if (!_enlargedPreviews) {
        _enlargedPreviews = true;
        
        _collectionView.imagePreviewLayout.invalidationCenteredIndexPath = indexPath;
        
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:0.3 animations:^{
            [_tableView beginUpdates];
            [_tableView endUpdates];
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self reloadButtons];
            _collectionView.imagePreviewLayout.showsSupplementaryViews = true;
        }];
    }
    else {
        UICollectionViewCell *cell = [self collectionView:_collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            CGPoint contentOffset = CGPointMake(CGRectGetMidX(cell.frame)-collectionView.frame.size.width/2.0, 0.0);
            contentOffset.x = MAX(contentOffset.x, -collectionView.contentInset.left);
            contentOffset.x = MIN(contentOffset.x, collectionView.contentSize.width - collectionView.frame.size.width + collectionView.contentInset.right);
            
            [collectionView setContentOffset:contentOffset animated:true];
        }
        [self reloadButtons];
    }
    
    [_supplementaryViews[@(indexPath.section)] setSelected:true];
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _backgroundView.frame = self.view.bounds;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    CGFloat tableViewHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];
    for (int i=0; i<[_tableView numberOfRowsInSection:1]; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        tableViewHeight += [self tableView:_tableView heightForRowAtIndexPath:indexPath];
    }
    
    _tableView.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                  CGRectGetMaxY(self.view.bounds)-tableViewHeight,
                                  self.view.bounds.size.width,
                                  tableViewHeight);
}

#pragma mark - Transitioning
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return (id)[[AnimationController alloc] init:self presenting:true];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return (id)[[AnimationController alloc] init:self presenting:false];
}

@end
