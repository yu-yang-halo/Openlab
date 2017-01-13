//
//  SettingsViewController.m
//  Openlab
//
//  Created by admin on 2016/12/13.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "SettingsViewController.h"
#import "CacheManager.h"
#import "MyStringUtils.h"
#import <UIView+Toast.h>
@interface SettingsViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.title=@"服务配置";
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"保存" style:(UIBarButtonItemStylePlain) target:self action:@selector(save:)];
    
    NSArray *arr=[CacheManager fetchServerIpAndPort];
    
    [_addressTF setText:arr[0]];
    
    [_portTF setText:arr[1]];

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
      [self resignAllResponder];
}
-(void)save:(id)sender{
    
    [self resignAllResponder];
    
    NSString *ipaddr=_addressTF.text;
    NSString *port=_portTF.text;
    
    
    if(![MyStringUtils isVaildIpAddr:ipaddr]&&![MyStringUtils isVaildDomainAddr:ipaddr]){
        [self.view.window makeToast:@"不是有效的ip或域名"];
        return;
    }
    
    if(![MyStringUtils isNumber:port]){
        [self.view.window makeToast:@"无效的端口地址"];
        return;
    }
    
    
    [CacheManager cacheServerIp:ipaddr AndPort:port];
    
    [self.view.window makeToast:@"保存成功"];
    [self.navigationController popViewControllerAnimated:YES];
    
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
-(void)resignAllResponder{
    [_addressTF resignFirstResponder];
    [_portTF resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField==_addressTF){
        [_portTF becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}


@end
