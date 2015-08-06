//
//  MCActivityCollectionLayout.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "MCActivityCollectionLayout.h"

NSString *const MCCollectionActivityKindSectionHeader = @"MCCollectionActivityKindSectionHeader";
NSString *const MCCollectionActivityKindSectionFooter = @"MCCollectionActivityKindSectionFooter";

@interface MCItemLayout : DBObject

@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat rotate;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation MCItemLayout
@end

@interface MCSectionLayout : DBObject

@property (nonatomic, assign) UIEdgeInsets inset;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation MCSectionLayout
@end

@interface MCActivityCollectionLayout ()
{
    float _scale;
}

/** 活动模板数组 */
@property (nonatomic, strong) NSArray *templateArray;

/** 通过模板生成的最终布局数组 */
@property (nonatomic, strong) NSMutableArray *layoutArray;

/** 通过模板生成的最终布局分类 */
@property (nonatomic, strong) NSMutableDictionary *layoutClassify;

@property (nonatomic, weak) id <MCActivityLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
@property (nonatomic, strong) NSMutableArray *unionRects;

@end


@implementation MCActivityCollectionLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

#pragma mark - Init
- (void)commonInit {
    _randomFirstShortSection = YES;
    _scale = [UIScreen mainScreen].bounds.size.width/320;
    _sectionInset = UIEdgeInsetsZero;
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id <MCActivityLayoutDelegate> )delegate {
    return (id <MCActivityLayoutDelegate> )self.collectionView.delegate;
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    if (_footerHeight != footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_headerInset, headerInset)) {
        _headerInset = headerInset;
        [self invalidateLayout];
    }
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_footerInset, footerInset)) {
        _footerInset = footerInset;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

- (void)setRandomFirstShortSection:(BOOL)randomFirstShortSection {
    if(_randomFirstShortSection != randomFirstShortSection){
        _randomFirstShortSection = randomFirstShortSection;
        [self invalidateLayout];
    }
}

- (void)setRandomLastShortSection:(BOOL)randomLastShortSection {
    if(_randomLastShortSection != randomLastShortSection){
        _randomLastShortSection = randomLastShortSection;
        [self invalidateLayout];
    }
}

- (void)setLoopitemSpace:(float)loopitemSpace
{
    if(_loopitemSpace != loopitemSpace){
        _loopitemSpace = loopitemSpace;
        [self invalidateLayout];
    }
}

/**
 *  设置活动模板
 */
- (void)setLayoutTemplate:(NSArray *)array
{
    _templateArray = array;
    if (!_templateArray) {
        return;
    }
    
    _layoutArray = [NSMutableArray array];
    _layoutClassify = [NSMutableDictionary dictionary];
    
    for (NSDictionary *sectionItem in _templateArray) {
        
        MCSectionLayout *sectionLayout = [[MCSectionLayout alloc] init];
        sectionLayout.inset = UIEdgeInsetsFromString(sectionItem[@"inset"]);
        sectionLayout.inset = UIEdgeInsetsMake(sectionLayout.inset.top*_scale,
                                               sectionLayout.inset.left*_scale,
                                               sectionLayout.inset.bottom*_scale,
                                               sectionLayout.inset.right*_scale);
        
        NSMutableArray *scaleItems = [NSMutableArray array];
        for (NSString *rectStr in sectionItem[@"items"]) {
            NSArray *components = [rectStr componentsSeparatedByString:@"&"];
            if (!components.count) {
                continue;
            }
            
            MCItemLayout *itemLayout = [[MCItemLayout alloc] init];
            
            CGRect rect = CGRectFromString(components[0]);
            itemLayout.xOffset = rect.origin.x*_scale;
            itemLayout.yOffset = rect.origin.y*_scale;
            itemLayout.width = rect.size.width*_scale;
            itemLayout.height = rect.size.height*_scale;
            
            //缩放比例
            if (components.count>1) {
                itemLayout.scale = [components[1] floatValue];
            }else{
                itemLayout.scale = 1.0f;
            }
            
            //旋转的角度
            if (components.count>2) {
                float angle = [components[2] floatValue];
                itemLayout.rotate = M_PI*(angle/180.f);
            }
            
            [scaleItems addObject:itemLayout];
        }
        sectionLayout.items = scaleItems;
        sectionLayout.itemCount = scaleItems.count;
        
        NSNumber *key = @(sectionLayout.itemCount);
        NSMutableArray *itemArray = _layoutClassify[key];
        if (!itemArray) {
            itemArray = [NSMutableArray array];
            [_layoutClassify setObject:itemArray forKey:key];
        }
        [itemArray addObject:sectionLayout];
        
        [_layoutArray addObject:sectionLayout];
    }
    
    [self invalidateLayout];
}

/**
 *  把源数据(一维数组) 转换成 和模板对应的二维数组
 *
 *  @param array 源数据(一维数组)
 */
- (NSMutableArray *)dataSourceWithArray:(NSArray *)array
{
    if ([self needRandomFirstSection:array.count]) {
        return [@[array] mutableCopy];
    }
    
    NSMutableArray *sourceArray = [NSMutableArray array];
    NSMutableArray *sectionArray = nil;
    
    NSInteger secIdx = 0;
    NSInteger secCount = 0;
    NSInteger itemIdx = 0;
    for (NSInteger i=0; i < array.count; i++) {
        id obj = array[i];
        
        if(i==0){
            sectionArray = [NSMutableArray array];
            [sourceArray addObject:sectionArray];
            secCount = ((MCSectionLayout *)_layoutArray[secIdx]).itemCount;
        }
        
        if (itemIdx >= secCount) {
            secIdx ++;
            if (secIdx >= _layoutArray.count) {
                secIdx = 0;
            }
            itemIdx = 0;
            sectionArray = [NSMutableArray array];
            [sourceArray addObject:sectionArray];
            secCount = ((MCSectionLayout *)_layoutArray[secIdx]).itemCount;
        }
        
        [sectionArray addObject:obj];
        itemIdx ++;
    }
    
    if (![sourceArray.lastObject count]) {
        [sourceArray removeLastObject];
    }
    
    return sourceArray;
}

- (BOOL)needRandomFirstSection:(NSInteger)count
{
    return _randomFirstShortSection && _layoutClassify && [_layoutClassify.allKeys containsObject:@(count)];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    _contentHeight = 0;
    NSLog(@"prepareLayout");
    _unionRects = [NSMutableArray array];
    _sectionItemAttributes = [NSMutableArray array];
    _allItemAttributes = [NSMutableArray array];
    
    _headersAttribute = [NSMutableDictionary dictionary];
    _footersAttribute = [NSMutableDictionary dictionary];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    NSInteger allItemCount = 0;
    for (NSInteger i=0; i<numberOfSections; i++) {
        allItemCount += [self.collectionView numberOfItemsInSection:i];
    }
    
    /**
     *  第一组数据相对较少时随机选择样式
     */
    MCSectionLayout *randomLayout = nil;
    if([self needRandomFirstSection:allItemCount]){
        NSArray *lyArray = [_layoutClassify objectForKey:@(allItemCount)];
        randomLayout = [lyArray objectAtIndex:0]; //为了保持每次都一样，暂时选每组的第一个
        //randomLayout = [lyArray objectAtIndex:(int)(arc4random() % lyArray.count)];
    }
    
    NSInteger secTmpIdx = 0;
    UICollectionViewLayoutAttributes *attributes;
    for (NSInteger section = 0; section < numberOfSections; ++section){
        /*
         * 1. get section layout
         */
        UIEdgeInsets sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView insetForSectionAtIndex:section];
        } else {
            sectionInset = self.sectionInset;
        }
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        /**
         *  最后一组数据不足时随机选择样式
         */
        MCSectionLayout *sectionLayout = randomLayout?:_layoutArray[secTmpIdx];
        if (section!=0 && section==numberOfSections-1 && _randomLastShortSection && itemCount<sectionLayout.itemCount) {
            NSArray *lyArray = [_layoutClassify objectForKey:@(itemCount)];
            sectionLayout = [lyArray objectAtIndex:0]; //为了保持每次都一样，暂时选每组的第一个
            //sectionLayout = [lyArray objectAtIndex:(int)(arc4random() % lyArray.count)];
        }
        
        if (!UIEdgeInsetsEqualToEdgeInsets(sectionLayout.inset, UIEdgeInsetsZero)) {
            sectionInset = sectionLayout.inset;
        }
        secTmpIdx ++;
        if (secTmpIdx >= _layoutArray.count) {
            secTmpIdx = 0;
        }
        
        /*
         * 2. set section header
         */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView heightForHeaderInSection:section];
        } else {
            headerHeight = self.headerHeight;
        }
        
        UIEdgeInsets headerInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:insetForHeaderInSection:)]) {
            headerInset = [self.delegate collectionView:self.collectionView insetForHeaderInSection:section];
        } else {
            headerInset = self.headerInset;
        }
        
        _contentHeight += headerInset.top;
        
        if (headerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader
                                                                                        withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left,
                                          _contentHeight,
                                          self.collectionView.bounds.size.width-(headerInset.left+headerInset.right),
                                          headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            _contentHeight = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }
        
        
        /*
         * 3. set section items
         */
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        NSInteger itemIdx = 0;
        CGFloat maxHeight = 0;
        
        //如果section里 给定元素数量大于模板元素数量 循环模板往下布局
        CGFloat lineTop = 0;
        
        for (NSInteger idx = 0; idx < itemCount; idx++) {
            
            if (itemIdx >= sectionLayout.itemCount) {
                itemIdx = 0;
                lineTop = maxHeight+_loopitemSpace;
            }
            
            MCItemLayout *itemLayout = sectionLayout.items[itemIdx];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(sectionInset.left+itemLayout.xOffset,
                                          _contentHeight+itemLayout.yOffset+sectionInset.top+lineTop,
                                          itemLayout.width,
                                          itemLayout.height);
            attributes.transform = CGAffineTransformMakeRotation(itemLayout.rotate);
            attributes.transform = CGAffineTransformScale(attributes.transform, itemLayout.scale, itemLayout.scale);
            
            if (maxHeight < itemLayout.yOffset+itemLayout.height+lineTop) {
                maxHeight = itemLayout.yOffset+itemLayout.height+lineTop;
            }
            
            itemIdx ++;
            
            [_allItemAttributes addObject:attributes];
            [itemAttributes addObject:attributes];
        }
        _contentHeight += maxHeight+sectionInset.top+sectionInset.bottom;
        
        [_sectionItemAttributes addObject:itemAttributes];
        
        /*
         * 4. set section footer
         */
        CGFloat footerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView heightForFooterInSection:section];
        } else {
            footerHeight = self.footerHeight;
        }
        
        UIEdgeInsets footerInset;
        if ([self.delegate respondsToSelector:@selector( collectionView:insetForFooterInSection:)]) {
            footerInset = [self.delegate collectionView:self.collectionView insetForFooterInSection:section];
        } else {
            footerInset = self.footerInset;
        }
        
        _contentHeight += footerInset.top;
        
        if (footerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter
                                                                                        withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left,
                                          _contentHeight,
                                          self.collectionView.bounds.size.width-(footerInset.left+footerInset.right),
                                          footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            _contentHeight = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }
    }
    
    // Build union rects
    NSInteger idx = 0;
    NSInteger itemCounts = [_allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)_allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)_allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [_unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = _contentHeight;
    if (contentSize.height < _minContentHeight) {
        contentSize.height = _minContentHeight;
    }
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _sectionItemAttributes[indexPath.section][indexPath.row];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:MCCollectionActivityKindSectionHeader]) {
        attribute = _headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:MCCollectionActivityKindSectionFooter]) {
        attribute = _footersAttribute[@(indexPath.section)];
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"layoutAttributesForElementsInRect %@",NSStringFromCGRect(rect));
    
    NSInteger i;
    NSInteger begin = 0, end = _unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < _unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [_unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = _unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [_unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, _allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = _allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    CGRect frame = attributes.frame;
    frame.origin.x = -frame.size.width;
    attributes.frame = frame;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    CGRect frame = attributes.frame;
    frame.origin.x = self.collectionView.bounds.size.width;
    attributes.frame = frame;
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //响应设备旋转
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc!",NSStringFromClass([self class]));
}

@end


