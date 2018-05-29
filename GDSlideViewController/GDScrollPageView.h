//
//  GDScrollPageView.h
//  GDSlideViewController
//
//  Created by 郭达 on 2018/5/28.
//  Copyright © 2018年 DouNiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDScrollPageView;

@protocol GDScrollPageViewDataSource <NSObject>

//- (NSArray *)gd_getViewsScrollPageView:(GDScrollPageView *)scrollPageView;
//
//- (NSArray<NSString *> *)gd_getTitlesScrollPage:(GDScrollPageView *)scrollPageView;

@end


@protocol GDScrollPageViewDelegate <NSObject>


/**
 滑动到当前vc的时候执行这个函数，所以子view的绘制都在这里，相当于view的init||vc的viewDidLoad

 @param scrollpageView scrollpageView
 @param index index
 */
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidLoad:(NSInteger)index;

@optional

- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidDisAppear:(NSInteger)index;

- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidAppear:(NSInteger)index;

/*
 viewWillAppear
 viewDidAppear
 viewWillDisappear
 viewDidDisappear
 */


@end


@interface GDScrollPageView : UIView

@property (nonatomic, assign) NSInteger currentIndex;//进来的时候选中哪个 默认第0个

/**
 view的父试图  **********  如果controllers中有 controller  一定要传superVC
 */
@property (nonatomic, strong) UIViewController *superVC;

/**
 顶部menu     **********
 */
@property (nonatomic, strong)NSArray<NSString *> *titles;

/**
 内容，可以是view 可以使controller  **********
 */
@property (nonatomic, strong) NSArray *controllers;

/**
 标题大小  默认font=14
 */
@property (nonatomic, strong) UIFont *title_font;

/**
 标题normal状态的颜色  默认黑色
 */
@property (nonatomic, strong) UIColor *title_Color;

/**
 标题选中的颜色  默认红色
 */
@property (nonatomic, strong) UIColor *titleSelect_Color;

/**
 头部scrollview高度  默认50高度
 */
@property (nonatomic, assign) CGFloat headerBarHeight;

/**
 底线宽度   默认2
 */
@property (nonatomic, assign) CGFloat bottomLineHeight;


/**
 线的颜色  默认黑色
 */
@property (nonatomic, strong) UIColor *bottomLine_color;


/**
 是否显示底线 默认显示
 */
@property (nonatomic, assign) BOOL showBottomLine;

/**
 线宽度  默认60   最大别超过 screenWidth / topDisPlayCount  留点空隙好做人
 */
@property (nonatomic, assign) CGFloat lineWidth;


/**
 上部导航每页最多显示几个导航按钮  默认最多显示5个
 */
@property (nonatomic, assign) NSInteger topDisPlayCount;




/**
 配置完成后加载
 */
- (void)loadScrollView;


/**
 跳转到相对应的地方  index加了越界判断，此方法在loadScrollview之后调用
 创建的时候不知道跳到哪个index，所以就load之后再跳
 如果创建的时候就跳，那就应上面的方法 ‘currentIndex’

 @param index index 
 */
- (void)jumpToWhatYouWant_AfterLoadScrollView_WithIndex:(NSInteger)index;


@end
