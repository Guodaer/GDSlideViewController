//
//  GDScrollPageView.m
//  GDSlideViewController
//
//  Created by 郭达 on 2018/5/28.
//  Copyright © 2018年 DouNiu. All rights reserved.
//

#import "GDScrollPageView.h"
#import <objc/runtime.h>

NSString * const gdscrollObjcID = @"gdscrollObjcID";

#define ViewWidth CGRectGetWidth(self.frame)
#define ViewHeight CGRectGetHeight(self.frame)
@interface GDScrollPageView () <UIScrollViewDelegate>

/**
 线
 */
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) UIView *topView;


@property (nonatomic,strong,readwrite)UIScrollView *menuScrollView;

@property (nonatomic,strong,readwrite)UIScrollView *contentScrollView;

@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, strong) UIView *lineSpaceView;

/** 用于字体动画 颜色缩放 */
@property (nonatomic, assign) NSInteger oldIndex;
@property (nonatomic, assign) NSInteger newIndex;
@property (nonatomic, assign) CGFloat oldOffSetx;//当前位置，判断左滑右滑

@property (nonatomic, strong) NSArray *normalColorRGBA;
@property (nonatomic, strong) NSArray *selectedColorRGBA;
@property (nonatomic, strong) NSArray *deltaRGBA;

/** menu最大scale */
@property (assign, nonatomic) CGFloat titleBigScale;

@end


@implementation GDScrollPageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //gd_默认配置，别改这里，去改.h中的属性
        _buttonArray = [NSMutableArray array];
        self.title_font = [UIFont systemFontOfSize:14];
        //        self.title_Color = [UIColor blackColor];
        self.title_Color = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1];
        //        self.titleSelect_Color = [UIColor redColor];
        self.titleSelect_Color = [UIColor colorWithRed:255/255.f green:0/255.f blue:0/255.f alpha:1];
        self.showBottomLine = YES;
        self.bottomLineHeight = 2;
        self.headerBarHeight = 50;
        self.bottomLine_color = [UIColor blackColor];
        self.lastIndex = 0;
        self.currentIndex = 0;
        self.lineWidth = 60;
        self.topDisPlayCount = 5;
        self.topBgColor = [UIColor whiteColor];
        self.topBottomSpaceInterval = 5;
        
        self.oldIndex = 0;
        self.newIndex = 0;
        self.oldOffSetx = 0;
        self.titleBigScale = 1.2;
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {}
    return self;
}
#pragma mark - 开始绘制
- (void)loadScrollView {
    NSAssert(self.titles.count == self.controllers.count, @"titles和控制器controllers的数量不一致");
    [self createBaseView];
    [self createTopView];
    [self createContentView];
    
    
    [self menuScrollToCenter:self.currentIndex];
    [self contentScrollToCenter:self.currentIndex];
    [self moveToPage:self.currentIndex];
    self.lastIndex = self.currentIndex;
    
}
#pragma mark - 在loadscrollview 之后调用
- (void)jumpToWhatYouWant_AfterLoadScrollView_WithIndex:(NSInteger)index {
    if (index < self.titles.count && index >=0 ) {
        [self menuButtonAnimationWithOldIndex:self.lastIndex newIndex:index];
        [self menuScrollToCenter:index];
        [self contentScrollToCenter:index];
        [self moveToPage:index];
        self.lastIndex = index;
    }
}
#pragma mark - 创建基本试图 top  content scrollview
- (void)createBaseView {
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = self.topBgColor;
    self.topView.frame = CGRectMake(0, 0, ViewWidth, self.headerBarHeight);
    [self addSubview:self.topView];
    
    self.lineSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame), ViewWidth, self.topBottomSpaceInterval)];
    self.lineSpaceView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    [self addSubview:self.lineSpaceView];
    
    self.menuScrollView = [[UIScrollView alloc] init];
    self.menuScrollView.showsHorizontalScrollIndicator = NO;
    self.menuScrollView.delegate = self;
    [self.topView addSubview:self.menuScrollView];
    self.menuScrollView.frame = CGRectMake(0, 0, ViewWidth, self.headerBarHeight);
    
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = self.bottomLine_color;
    self.bottomLine.frame = CGRectMake(0, CGRectGetHeight(self.topView.frame)-self.bottomLineHeight, self.lineWidth, self.bottomLineHeight);
    [self.menuScrollView addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    
    
    self.contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
    [self addSubview:self.contentScrollView];
    self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame)+self.topBottomSpaceInterval, ViewWidth, ViewHeight-self.headerBarHeight-self.topBottomSpaceInterval);
    
}
#pragma mark - 上部的titles
- (void)createTopView {
    CGFloat itemWidth = [self getTopItemWidth];
    for (int i=0; i<self.titles.count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.frame = CGRectMake(itemWidth * i, 0, itemWidth, CGRectGetHeight(self.menuScrollView.frame)-self.bottomLineHeight);
        [titleButton setTitle:self.titles[i] forState:UIControlStateNormal];
        [titleButton setTitleColor:self.title_Color forState:UIControlStateNormal];
        //        [titleButton setTitleColor:self.titleSelect_Color forState:UIControlStateSelected];
        titleButton.tag = 10000 + i;
        [titleButton addTarget:self action:@selector(titleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuScrollView addSubview:titleButton];
        titleButton.titleLabel.font = self.title_font;
        if (i==self.currentIndex) {
            [titleButton setTitleColor:self.titleSelect_Color forState:UIControlStateNormal];
            titleButton.transform = CGAffineTransformMakeScale(self.titleBigScale, self.titleBigScale);
        }
        [_buttonArray addObject:titleButton];
    }
    self.menuScrollView.contentSize = CGSizeMake(itemWidth * self.titles.count, self.headerBarHeight);
    
    if (self.showBottomLine) {
        self.bottomLine.frame = CGRectMake((self.currentIndex * itemWidth) + (itemWidth-self.lineWidth)/2, self.headerBarHeight-self.bottomLineHeight, self.lineWidth, self.bottomLineHeight);
        self.bottomLine.hidden = NO;
        
    }else{
        self.bottomLine.hidden = YES;
    }
}
#pragma mark - 下面内容
- (void)createContentView {
    for (int i=0; i<self.controllers.count; i++) {
        id vc = self.controllers[i];
        if ([vc isKindOfClass:[UIView class]]) {
            UIView *eachView = vc;
            eachView.frame = CGRectMake(ViewWidth * i, 0, ViewWidth, CGRectGetHeight(self.contentScrollView.frame));
            [self.contentScrollView addSubview:vc];
            
        }else if ([vc isKindOfClass:[UIViewController class]]){
            UIViewController *eachVC = vc;
            eachVC.view.frame = CGRectMake(ViewWidth * i, 0, ViewWidth, CGRectGetHeight(self.contentScrollView.frame));
            [self.contentScrollView addSubview:eachVC.view];
            [self.superVC addChildViewController:vc];
        }
        
        objc_setAssociatedObject(vc, (__bridge const void * _Nonnull)(gdscrollObjcID), @(NO), OBJC_ASSOCIATION_ASSIGN);
    }
    self.contentScrollView.contentSize = CGSizeMake(ViewWidth * self.controllers.count, CGRectGetHeight(self.contentScrollView.frame));
}
#pragma mark - scrollview 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        NSInteger index = scrollView.contentOffset.x / ViewWidth;
        if (index != self.lastIndex) {
            [self menuScrollToCenter:index];
            [self moveToPage:index];
            self.lastIndex = index;
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        CGFloat itemWidth = [self getTopItemWidth];
        CGFloat offSetx = scrollView.contentOffset.x;
        CGFloat x = offSetx/CGRectGetWidth(self.menuScrollView.frame) * itemWidth + (itemWidth-self.lineWidth)/2;
        self.bottomLine.frame = CGRectMake(x, self.headerBarHeight-self.bottomLineHeight, self.lineWidth, self.bottomLineHeight);
        
        /** 以下是动态改变字体颜色 */
        CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
        NSInteger tempIndex = tempProgress;
        CGFloat progress = tempProgress - floor(tempProgress);
        CGFloat deltaX = scrollView.contentOffset.x - _oldOffSetx;
        
        if (deltaX > 0) {//向左
            if (progress == 0.0) {
                return;
            }
            self.newIndex = tempIndex + 1;//右边的将显示
            self.oldIndex = tempIndex;
        }else if(deltaX < 0){
            progress = 1.0 - progress;
            self.oldIndex = tempIndex + 1;
            self.newIndex = tempIndex;
        }else {return;}
        
        [self contentViewDidMoveFromIndex:_oldIndex toIndex:_newIndex progress:progress];
        
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _oldOffSetx = scrollView.contentOffset.x;
}
#pragma mark - 动态改变字体颜色
- (void)contentViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (fromIndex < 0 ||
        fromIndex >= self.titles.count ||
        toIndex < 0 ||
        toIndex >= self.titles.count) {
        NSLog(@"------------------------ 参数有问题 ----------------------");
        return;
    }
    UIButton *oldBtn = self.buttonArray[fromIndex];
    UIButton *currentBtn = self.buttonArray[toIndex];
    
    
    [oldBtn setTitleColor:[UIColor colorWithRed:[self.selectedColorRGBA[0] floatValue]+[self.deltaRGBA[0] floatValue] * progress
                                          green:[self.selectedColorRGBA[1] floatValue]+[self.deltaRGBA[1] floatValue] * progress
                                           blue:[self.selectedColorRGBA[2] floatValue]+[self.deltaRGBA[2] floatValue] * progress
                                          alpha:[self.selectedColorRGBA[3] floatValue]+[self.deltaRGBA[3] floatValue] * progress]
                 forState:UIControlStateNormal];
    
    [currentBtn setTitleColor:[UIColor colorWithRed:[self.normalColorRGBA[0] floatValue]-[self.deltaRGBA[0] floatValue] * progress
                                              green:[self.normalColorRGBA[1] floatValue]-[self.deltaRGBA[1] floatValue] * progress
                                               blue:[self.normalColorRGBA[2] floatValue]-[self.deltaRGBA[2] floatValue] * progress
                                              alpha:[self.normalColorRGBA[3] floatValue]-[self.deltaRGBA[3] floatValue] * progress]
                     forState:UIControlStateNormal];
    
    
    
    //放大缩小效果
    CGFloat menuScale = self.titleBigScale - 1;
    oldBtn.transform = CGAffineTransformMakeScale(self.titleBigScale-progress*menuScale,self.titleBigScale-progress*menuScale);
    currentBtn.transform = CGAffineTransformMakeScale(1+menuScale*progress, 1+menuScale*progress);
    
}
- (NSArray *)getColorRGBA:(UIColor *)color {
    CGFloat numOfComponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbaComponents = [[NSArray alloc] init];
    if (numOfComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbaComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), @(components[3]), nil];
    }
    return rgbaComponents;
}
- (NSArray *)normalColorRGBA {
    if (!_normalColorRGBA) {
        NSArray *normalColorRGBA = [self getColorRGBA:self.title_Color];
        NSAssert(normalColorRGBA, @"设置普通状态的文字颜色时 请使用RGBA空间的颜色值");
        _normalColorRGBA = normalColorRGBA;
        
    }
    return  _normalColorRGBA;
}
- (NSArray *)selectedColorRGBA {
    if (!_selectedColorRGBA) {
        NSArray *selectedColorRGBA = [self getColorRGBA:self.titleSelect_Color];
        NSAssert(selectedColorRGBA, @"设置选中状态的文字颜色时 请使用RGBA空间的颜色值");
        _selectedColorRGBA = selectedColorRGBA;
        
    }
    return  _selectedColorRGBA;
}
- (NSArray *)deltaRGBA {
    if (_deltaRGBA == nil) {
        NSArray *normalColorRgb = self.normalColorRGBA;
        NSArray *selectedColorRgb = self.selectedColorRGBA;
        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            CGFloat deltaA = [normalColorRgb[3] floatValue] - [selectedColorRgb[3] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), @(deltaA), nil];
            _deltaRGBA = delta;
        }
    }
    return _deltaRGBA;
}
#pragma mark - 获取top 的 itemWidth
- (CGFloat)getTopItemWidth {
    CGFloat itemWidth = 0;
    if (self.titles.count > self.topDisPlayCount) {
        itemWidth = ViewWidth / self.topDisPlayCount;
    }else {
        itemWidth = ViewWidth / self.titles.count;
    }
    return itemWidth;
}
#pragma 点击按钮 切换
- (void)titleButtonClickAction:(UIButton *)sender {
    NSInteger index = sender.tag - 10000;
    if (self.lastIndex != index) {
        _oldOffSetx = self.lastIndex * ViewWidth;
        [self menuButtonAnimationWithOldIndex:self.lastIndex newIndex:index];
        [self menuScrollToCenter:index];
        [self contentScrollToCenter:index];
        [self moveToPage:index];
        self.lastIndex = index;
    }
}
#pragma mark - 按钮改变状态
- (void)menuButtonAnimationWithOldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex {
    UIButton *oldBtn = self.buttonArray[oldIndex];
    UIButton *currentBtn = self.buttonArray[newIndex];
    [oldBtn setTitleColor:self.title_Color forState:UIControlStateNormal];
    [currentBtn setTitleColor:self.titleSelect_Color forState:UIControlStateNormal];
    
    CGFloat menuScale = self.titleBigScale - 1;
    [UIView animateWithDuration:0.2 animations:^{
        oldBtn.transform = CGAffineTransformMakeScale(self.titleBigScale-menuScale,self.titleBigScale-menuScale);
        currentBtn.transform = CGAffineTransformMakeScale(1+menuScale, 1+menuScale);
    }];
}
//content滚动到中间
- (void)contentScrollToCenter:(NSInteger)index {
    CGFloat x = ViewWidth * index;
    [self.contentScrollView setContentOffset:CGPointMake(x, 0) animated:NO];
}
//top 滚动到中间
- (void)menuScrollToCenter:(NSInteger)index {
    if (index >= self.titles.count) {
        NSLog(@"------------------------------\n超了\n------------------------------");
        return;
    }
    CGFloat itemWidth = [self getTopItemWidth];
    UIButton *currentButton = self.buttonArray[index];
    CGFloat left = currentButton.center.x - ViewWidth/2;
    left = left <= 0 ? 0 : left;
    CGFloat maxLeft = itemWidth * self.titles.count - ViewWidth;
    left = left >= maxLeft ? maxLeft : left;
    [self.menuScrollView setContentOffset:CGPointMake(left, 0) animated:YES];
    
    
}

- (void)moveToPage:(NSInteger)index {
    if (self.lastIndex != index) {
        id<GDScrollPageViewDelegate> lastVC = self.controllers[self.lastIndex];
        id<GDScrollPageViewDelegate> currentVC = self.controllers[index];
        NSNumber *value = objc_getAssociatedObject(currentVC, (__bridge const void * _Nonnull)(gdscrollObjcID));
        if (![value boolValue]) {
            if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidLoad:)]) {
                [currentVC gd_scrollPageView:self viewDidLoad:index];
            }
            objc_setAssociatedObject(currentVC, (__bridge const void * _Nonnull)(gdscrollObjcID), @(YES), OBJC_ASSOCIATION_ASSIGN);
        }
        
        if ([lastVC respondsToSelector:@selector(gd_scrollPageView:viewDidDisAppear:)]) {
            [lastVC gd_scrollPageView:self viewDidDisAppear:self.lastIndex];
        }
        if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidAppear:)]) {
            [currentVC gd_scrollPageView:self viewDidAppear:index];
        }
        
    }else{
        //第一次进来
        id<GDScrollPageViewDelegate> currentVC = self.controllers[index];
        
        NSNumber *value = objc_getAssociatedObject(currentVC, (__bridge const void * _Nonnull)(gdscrollObjcID));
        if (![value boolValue]) {
            if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidLoad:)]) {
                [currentVC gd_scrollPageView:self viewDidLoad:index];
            }
            objc_setAssociatedObject(currentVC, (__bridge const void * _Nonnull)(gdscrollObjcID), @(YES), OBJC_ASSOCIATION_ASSIGN);
        }
        if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidAppear:)]) {
            [currentVC gd_scrollPageView:self viewDidAppear:index];
        }
    }
}
@end
