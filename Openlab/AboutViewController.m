//
//  AboutViewController.m
//  Openlab
//
//  Created by admin on 16/10/25.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSDictionary *infoDictionary=[[NSBundle mainBundle] infoDictionary];
    
    NSString *appVersion= [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.versionLabel.text=[NSString stringWithFormat:@"版本号 %@",appVersion];
    
    self.contentLabel.text=@"开放实验室(iOS)版本\n\n此版本适用于iOS7.0以上的操作系统手机，如使用低于iOS7.0以下版本，出现任何问题，公司不承担责任.本软件免费下载，下载过程中产生的数据流量费用由运营商收取。\n客服电话:\n0551-67122346（合肥）\n0592-5952609 （厦门）";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
