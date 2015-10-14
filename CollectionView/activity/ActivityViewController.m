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

@interface ActivityCollectionHeaderView : UICollectionReusableView
@end
@implementation ActivityCollectionHeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}
@end

@interface ActivityCollectionFooterView : UICollectionReusableView
@end
@implementation ActivityCollectionFooterView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}
@end

@interface ActivityViewController () <USActivityListLayoutDelegate>

@property (strong, nonatomic) NSMutableArray *originalArray;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

static NSString *const cellIdentifier = @"ActivityCollectionCell";
static NSString *const sectionHeaderIdentifier = @"ActivityHeaderView";
static NSString *const sectionFooterIdentifier = @"ActivityFooterView";
static NSString *const collectionHeaderIdentifier = @"ActivityCollectionHeaderView";
static NSString *const collectionFooterIdentifier = @"ActivityCollectionFooterView";

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"活动模板";
    
    _originalArray = [NSMutableArray array];
    for (int i=0; i<64; i++) {
        [_originalArray addObject:@(i)];
    }
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"event_layout" ofType:@"json"];
    NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:kNilOptions error:NULL];
    
    _activityLayout.collectionHeaderHeight = 50;
    _activityLayout.collectionFooterHeight = 80;
    _activityLayout.randomLastShortSection = YES;
    [_activityLayout setLayoutTemplate:template];
    
    _dataSource = [_activityLayout dataSourceWithArray:_originalArray];
    
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    
    nib = [UINib nibWithNibName:sectionHeaderIdentifier bundle:nil];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader withReuseIdentifier:sectionHeaderIdentifier];
    
    nib = [UINib nibWithNibName:sectionFooterIdentifier bundle:nil];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter withReuseIdentifier:sectionFooterIdentifier];
    
    [_collectionView registerClass:[ActivityCollectionHeaderView class] forSupplementaryViewOfKind:MCCollectionActivityKindCollectionHeader
               withReuseIdentifier:collectionHeaderIdentifier];
    
    [_collectionView registerClass:[ActivityCollectionFooterView class] forSupplementaryViewOfKind:MCCollectionActivityKindCollectionFooter
               withReuseIdentifier:collectionFooterIdentifier];
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

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForFooterInSection:(NSInteger)section
{
    return 40;
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
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader
                                                          withReuseIdentifier:sectionHeaderIdentifier forIndexPath:indexPath];
    }
    else if([kind isEqual:MCCollectionActivityKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter
                                                          withReuseIdentifier:sectionFooterIdentifier forIndexPath:indexPath];
    }
    else if([kind isEqual:MCCollectionActivityKindCollectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindCollectionHeader
                                                          withReuseIdentifier:collectionHeaderIdentifier forIndexPath:indexPath];
    }
    else if([kind isEqual:MCCollectionActivityKindCollectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:MCCollectionActivityKindCollectionFooter
                                                          withReuseIdentifier:collectionFooterIdentifier forIndexPath:indexPath];
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
//    [_collectionView reloadData];
}

@end
