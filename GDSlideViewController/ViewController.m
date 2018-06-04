//
//  ViewController.m
//  GDSlideViewController
//
//  Created by 郭达 on 2018/5/28.
//  Copyright © 2018年 DouNiu. All rights reserved.
//

#import "ViewController.h"
#import "oneView.h"
#import "TwoView.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"|]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]");

    oneView *one = [[oneView alloc] init];
    oneView *oneS = [[oneView alloc] init];
    TwoView *two = [[TwoView alloc] init];
    TwoView *twos = [[TwoView alloc] init];
    ThreeViewController *three = [[ThreeViewController alloc] init];
    ThreeViewController *threes = [[ThreeViewController alloc] init];
    FourViewController *four = [[FourViewController alloc] init];
    FourViewController *fours = [[FourViewController alloc] init];
    
    GDScrollPageView *pageview = [[GDScrollPageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    pageview.superVC = self;
    pageview.titles = @[@"one",@"two",@"three",@"four",@"five",@"six",@"seven",@"eight"];
    pageview.controllers = @[one,two,three,four,oneS,twos,threes,fours];
    pageview.bottomLine_color = [UIColor blackColor];
//    pageview.currentIndex = 1;
//    pageview.topDisPlayCount = 9;
          NSLog(@"||||||||||||||||||||||||||||||||");

    [self.view addSubview:pageview];
    [pageview loadScrollView];
    NSLog(@"111111110000000000000");

    
    //跳转到第几个
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pageview jumpToWhatYouWant_AfterLoadScrollView_WithIndex:3];
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
