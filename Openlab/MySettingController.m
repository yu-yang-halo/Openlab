//
//  MySettingController.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MySettingController.h"
#import <Masonry/Masonry.h>
#import "ElApiService.h"
@interface MySettingController()
{
    
}
@property (weak, nonatomic) IBOutlet UIView *headerViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lb_username;
@property (weak, nonatomic) IBOutlet UILabel *lb_telephone;
@property (weak, nonatomic) IBOutlet UIButton *btn_realname;

- (IBAction)exitToLoginPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@end
@implementation MySettingController
-(void)viewDidLoad{
    [super viewDidLoad];
     self.title=@"设置";
    
    self.btn_realname.layer.cornerRadius=self.btn_realname.bounds.size.height/2;
    self.exitBtn.layer.cornerRadius=5;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserType *user=[[ElApiService shareElApiService] getUser];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            _lb_username.text=user.name;
            _lb_telephone.text=user.phone;
            [_btn_realname setTitle:user.realName forState:UIControlStateNormal];
        });
        
    });
    
    
       
}
- (IBAction)exitToLoginPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
