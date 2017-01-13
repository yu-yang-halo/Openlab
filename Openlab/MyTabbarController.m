//
//  MyTabbarController.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyTabbarController.h"
#import "Constants.h"
@interface MyTabbarController()
{
    NSArray *titles;
}
@end
@implementation MyTabbarController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    titles=@[@"首页",@"我的预约",@"我的作业",@"设置"];
    
    [self setSelectedIndex:0];
    
    self.title=titles[0];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tabBar setTintColor:ICON_BG_COLOR_NORMAL];
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    self.title=item.title;
}
@end
