//
//  ThreeViewController.m
//  GDSlideViewController
//
//  Created by 郭达 on 2018/5/28.
//  Copyright © 2018年 DouNiu. All rights reserved.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidLoad:(NSInteger)index {
    
    NSLog(@"did load %ld",index);
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidAppear:(NSInteger)index {
    NSLog(@"did appear %ld",index);
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidDisAppear:(NSInteger)index {
    NSLog(@"did disAppear %ld",index);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
