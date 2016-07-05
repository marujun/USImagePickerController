//
//  USAssetsPreviewViewController.m
//  CollectionView
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

//想要使用代码隐藏状态栏需要在 info.plist 文件里设置 "View controller-based status bar appearance" 为 NO

#import "USAssetsPreviewViewController.h"
#import "USAssetsPageViewController.h"

@interface USAssetsPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;

@property (nonatomic, assign) BOOL pageSelected;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation USAssetsPreviewViewController


- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super initWithNibName:@"USAssetsPreviewViewController" bundle:nil];
    if (self) {
        self.dataSource      = [NSMutableArray arrayWithArray:assets];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];//隐藏导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];  // 隐藏状态栏
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];//显示导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];  // 显示状态栏
}

- (USImagePickerController *)picker {
    return (USImagePickerController *)self.navigationController;
}

- (void)updateTitle:(NSInteger)index
{
    _pageIndex = index;
    
    self.title = [NSString stringWithFormat:@"%@ / %@", @(index+1), @(_dataSource.count)];
    
    _pageSelected = [_selectedAssets containsObject:_dataSource[index]];
    [self reloadCheckButtonBgColor];
    
    NSInteger count = self.selectedAssets.count;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
    self.countLabel.hidden = count?NO:YES;
    self.sendButton.alpha = count?1:0.7;
    self.bottomBar.userInteractionEnabled = count?YES:NO;
}

- (void)handleSingleTap
{
    BOOL hidden = !(self.topBar.hidden && self.bottomBar.hidden);
    
    self.topBar.hidden = hidden;
    self.bottomBar.hidden = hidden;
}

- (IBAction)checkButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewViewController:canSelect:)]) {
        if (![self.delegate previewViewController:self canSelect:!_pageSelected]) return;
    }
    
    id asset = _dataSource[_pageIndex];
    
    _pageSelected = !_pageSelected;
    [self reloadCheckButtonBgColor];
    
    if (_pageSelected) [self.selectedAssets addObject:asset];
    else [self.selectedAssets removeObject:asset];
    
    [self updateTitle:_pageIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewViewController:didSelect:)]) {
        [self.delegate previewViewController:self didSelect:_pageSelected];
    }
}

- (IBAction)leftNavButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonClickedInPreviewViewController:)]) {
        [self.delegate sendButtonClickedInPreviewViewController:self];
    }
}

#pragma mark - Setup

- (void)setupViews
{
    USAssetsPageViewController *_pageViewController = [[USAssetsPageViewController alloc] initWithAssets:_dataSource];
    _pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    __weak typeof(self) weak_self = self;
    [_pageViewController setIndexChangedHandler:^(NSInteger index) {
        [weak_self updateTitle:index];
    }];
    [_pageViewController setSingleTapHandler:^(NSInteger index) {
        [weak_self handleSingleTap];
    }];
    _pageViewController.pageIndex = _pageIndex;
    
    [self.view insertSubview:_pageViewController.view atIndex:0];
    [self addChildViewController:_pageViewController];
    
    NSDictionary *views = @{@"view":_pageViewController.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    
    self.countLabel.backgroundColor = USPickerTintColor;
    self.countLabel.layer.cornerRadius = CGRectGetHeight(self.countLabel.frame)/2.f;
    self.countLabel.layer.masksToBounds = YES;
    [self.sendButton setTitleColor:USPickerTintColor forState:UIControlStateNormal];
    
    self.checkImageView.tintColor = [UIColor whiteColor];
    self.checkImageView.layer.cornerRadius = CGRectGetHeight(self.checkImageView.frame) / 2.0;
    UIImage *selectedImage = [[UIImage imageNamed:@"USPicker-Checkmark-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.checkImageView setImage:selectedImage];
    [self reloadCheckButtonBgColor];
}

- (void)reloadCheckButtonBgColor
{
    self.checkImageView.backgroundColor = _pageSelected ? USPickerTintColor : [UIColor clearColor];
}

#pragma mark - 监控横竖屏切换

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            _topHeightConstraint.constant = 44;
        } else {
            _topHeightConstraint.constant = 64;
        }
        [self.topBar layoutIfNeeded];
    }];
}

- (void)dealloc
{
    NSLog(@"dealloc 释放类 %@",  NSStringFromClass([self class]));
}

@end
