//
//  TwoView.m
//  GDSlideViewController
//
//  Created by 郭达 on 2018/5/28.
//  Copyright © 2018年 DouNiu. All rights reserved.
//

#import "TwoView.h"

@implementation TwoView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidLoad:(NSInteger)index {
    
//    NSLog(@"did load %ld",index);
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidAppear:(NSInteger)index {
//    NSLog(@"did appear %ld",index);
}
- (void)gd_scrollPageView:(GDScrollPageView *)scrollpageView viewDidDisAppear:(NSInteger)index {
//    NSLog(@"did disAppear %ld",index);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
