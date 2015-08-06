//
//  ActivityViewController.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityHeaderView.h"
#import "ActivityFooterView.h"
#import "ActivityCollectionCell.h"

@interface ActivityViewController ()

@property (strong, nonatomic) NSMutableArray *originalArray;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

static NSString *const cellIdentifier = @"ActivityCollectionCell";
static NSString *const headerIdentifier = @"ActivityHeaderView";
static NSString *const footerIdentifier = @"ActivityFooterView";

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"活动模板";
    
    _originalArray = [NSMutableArray array];
    for (int i=0; i<32; i++) {
        [_originalArray addObject:@(i)];
    }
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"activity_layout" ofType:@"json"];
    NSArray *templateArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:kNilOptions error:NULL];
    
//    _activityLayout.loopitemSpace = 10;
//    _activityLayout.randomLastShortSection = YES;
//    _activityLayout.interitemSpace = 10;
//    _activityLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _activityLayout.headerHeight = 50;
//    _activityLayout.footerHeight = 30;
//    _activityLayout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0);
//    _activityLayout.footerInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    [_activityLayout setLayoutTemplate:templateArray];
    _dataSource = [_activityLayout dataSourceWithArray:_originalArray];
    
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    
    nib = [UINib nibWithNibName:headerIdentifier bundle:nil];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader withReuseIdentifier:headerIdentifier];
    
    nib = [UINib nibWithNibName:footerIdentifier bundle:nil];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter withReuseIdentifier:footerIdentifier];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    
    if([kind isEqual:MCCollectionActivityKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    }
    else if([kind isEqual:MCCollectionActivityKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItem indexPath.section:%ld indexPath.row:%ld",(long)indexPath.section, (long)indexPath.row);
    
    [collectionView performBatchUpdates:^{
        
        id obj = _dataSource[indexPath.section][indexPath.row];
        NSInteger index = [_originalArray indexOfObject:obj];
        [_originalArray removeObjectAtIndex:index];
        
        NSInteger count = [_dataSource[indexPath.section] count];
        if (count > 1) {
            [_dataSource[indexPath.section] removeObjectAtIndex:indexPath.row];
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
        else{
            [_dataSource removeObjectAtIndex:indexPath.section];
            [collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }
    } completion:nil];
    
//    id obj = _dataSource[indexPath.section][indexPath.row];
//    NSInteger index = [_originalArray indexOfObject:obj];
//    [_originalArray removeObjectAtIndex:index];
//
//    _dataSource = [_activityLayout dataSourceWithArray:_originalArray];
//    [_activityLayout invalidateLayout];
}

@end
