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


@end


@implementation GDScrollPageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //gd_默认配置，别改这里，去改.h中的属性
        _buttonArray = [NSMutableArray array];
        self.title_font = [UIFont systemFontOfSize:14];
        self.title_Color = [UIColor blackColor];
        self.titleSelect_Color = [UIColor redColor];
        self.showBottomLine = YES;
        self.bottomLineHeight = 2;
        self.headerBarHeight = 50;
        self.bottomLine_color = [UIColor blackColor];
        self.lastIndex = 0;
        self.currentIndex = 0;
        self.lineWidth = 60;
        self.topDisPlayCount = 5;
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
    

    [self menuUpdate:self.currentIndex];
    [self menuScrollToCenter:self.currentIndex];
    [self contentScrollToCenter:self.currentIndex];
    [self moveToPage:self.currentIndex];
    self.lastIndex = self.currentIndex;

}
#pragma mark - 在loadscrollview 之后调用
- (void)jumpToWhatYouWant_AfterLoadScrollView_WithIndex:(NSInteger)index {
    if (index < self.titles.count && index >=0 ) {
        [self menuUpdate:index];
        [self menuScrollToCenter:index];
        [self contentScrollToCenter:index];
        [self moveToPage:index];
        self.lastIndex = index;
    }
}
#pragma mark - 创建基本试图 top  content scrollview
- (void)createBaseView {
    
    self.topView = [[UIView alloc] init];
    self.topView.frame = CGRectMake(0, 0, ViewWidth, self.headerBarHeight);
    [self addSubview:self.topView];
    
    
    self.menuScrollView = [[UIScrollView alloc] init];
    self.menuScrollView.showsHorizontalScrollIndicator = NO;
    self.menuScrollView.delegate = self;
    [self.topView addSubview:self.menuScrollView];
    self.menuScrollView.frame = CGRectMake(0, 0, ViewWidth, self.headerBarHeight);
    
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = self.bottomLine_color;
    self.bottomLine.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.lineWidth, self.bottomLineHeight);
    [self.menuScrollView addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    
    
    self.contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
    [self addSubview:self.contentScrollView];
    self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), ViewWidth, ViewHeight-self.headerBarHeight);
    
}
#pragma mark - 上部的titles
- (void)createTopView {
    CGFloat itemWidth = [self getTopItemWidth];
    for (int i=0; i<self.titles.count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.frame = CGRectMake(itemWidth * i, 0, itemWidth, CGRectGetHeight(self.menuScrollView.frame)-self.bottomLineHeight);
        [titleButton setTitle:self.titles[i] forState:UIControlStateNormal];
        [titleButton setTitleColor:self.title_Color forState:UIControlStateNormal];
        [titleButton setTitleColor:self.titleSelect_Color forState:UIControlStateSelected];
        titleButton.tag = 10000 + i;
        [titleButton addTarget:self action:@selector(titleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuScrollView addSubview:titleButton];
        if (i==self.currentIndex) {
            titleButton.selected = YES;
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
            [self menuUpdate:index];
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
    }
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
        [self menuUpdate:index];
        [self menuScrollToCenter:index];
        [self contentScrollToCenter:index];
        [self moveToPage:index];
        self.lastIndex = index;
    }
}
//按钮修改
- (void)menuUpdate:(NSInteger)index {
    UIButton *lastButton = self.buttonArray[self.lastIndex];
    lastButton.selected = NO;
    UIButton *currentButton = self.buttonArray[index];
    currentButton.selected = YES;
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
//    [self.menuScrollView scrollRectToVisible:CGRectMake(itemWidth * index, 0, itemWidth, self.headerBarHeight) animated:YES];
//    [self.menuScrollView scrollRectToVisible:CGRectMake(left, 0, itemWidth, self.headerBarHeight) animated:YES];
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
        if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidLoad:)]) {
            [currentVC gd_scrollPageView:self viewDidLoad:index];
        }
        objc_setAssociatedObject(currentVC, (__bridge const void * _Nonnull)(gdscrollObjcID), @(YES), OBJC_ASSOCIATION_ASSIGN);
        
        if ([currentVC respondsToSelector:@selector(gd_scrollPageView:viewDidAppear:)]) {
            [currentVC gd_scrollPageView:self viewDidAppear:index];
        }
    }
}
@end
