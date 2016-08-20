//
//  ViewController.m
//  Openlab
//
//  Created by admin on 16/4/7.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "LoginViewController.h"
#import "UIButton+BackgroundColor.h"
#import "Constants.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ElApiService.h"
#import <UIView+Toast.h>
#import "JPUSHService.h"
@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *loginNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)registerUser:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.loginNameTF.delegate=self;
    self.passwordTF.delegate=self;
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.loginBtn.layer setCornerRadius:2.0];
    
    [self.loginBtn setBackgroundColor:BUTTON_BG_COLOR_NORMAL forState:UIControlStateNormal];
    
    [self.loginBtn setBackgroundColor:BUTTON_BG_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    
    self.title=@"科大开放实验室";
    
    NSString *cacheName=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME];
    NSString *cachePass=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
    
    if(cacheName!=nil){
        [self.loginNameTF setText:cacheName];
    }
    if(cachePass!=nil){
        [self.passwordTF setText:cachePass];
    }
    
    
    
    
    
    [self.loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)login:(id)sender{
    
    NSString *loginName=self.loginNameTF.text;
    NSString *pass=self.passwordTF.text;
    if([loginName isEqualToString:@""]||[pass isEqualToString:@""]){
        [self.view makeToast:@"用户名和密码不能为空"];
    }else{
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"登录中...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL loginSuccessYN=[[ElApiService shareElApiService] login:loginName password:pass];
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [hud hide:YES];
                if (loginSuccessYN) {
                    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
                    
                    [JPUSHService setTags:[NSSet setWithObject:userId] alias:nil
                    fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
                        NSLog(@"iTags : %@ finished ",iTags);
                    }];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:KEY_USERNAME];
                    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:KEY_PASSWORD];
                    
                    [self toMainPage];
                }
            });
        });
    }
    
    
}

-(void)toMainPage{
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UITabBarController *tabVC=[storyBoard instantiateViewControllerWithIdentifier:@"tabVC"];
    [tabVC.tabBar setTintColor:BUTTON_BG_COLOR_NORMAL];
    [tabVC.tabBar setOpaque:0.6];
    
    self.navigationItem.backBarButtonItem=nil;
    
    [self.navigationController pushViewController:tabVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerUser:(id)sender {
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField==_loginNameTF){
        [_passwordTF becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
@end
