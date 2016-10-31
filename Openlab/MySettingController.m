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
#import "ScoreViewController.h"
@interface MySettingController()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *items;
}
@property (weak, nonatomic) IBOutlet UIView *headerViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lb_username;
@property (weak, nonatomic) IBOutlet UILabel *lb_telephone;
@property (weak, nonatomic) IBOutlet UIButton *btn_realname;

- (IBAction)exitToLoginPage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *exitBtn;



@end
@implementation MySettingController
-(void)viewDidLoad{
    [super viewDidLoad];
    
     self.title=@"个人中心";
   
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.btn_realname.layer.cornerRadius=self.btn_realname.bounds.size.height/2;
    self.exitBtn.layer.cornerRadius=5;
    
    
    items=@[@"我的成绩",@"关于"];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    _tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserType *user=[[ElApiService shareElApiService] getUser];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            _lb_username.text=user.name;
            _lb_telephone.text=user.phone;
            [_btn_realname setTitle:user.realName forState:UIControlStateNormal];
        });
        
    });
    UITapGestureRecognizer *tapGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToFixPass:)];
    [_headerViewContainer addGestureRecognizer:tapGR];
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil];
    
}
-(void)clickToFixPass:(UIGestureRecognizer *)gr{
    [self performSegueWithIdentifier:@"fixpass" sender:gr];
}
- (IBAction)exitToLoginPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"];
    }
    
    cell.textLabel.text=items[indexPath.row];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0){
        [self performSegueWithIdentifier:@"scoreVC" sender:@(indexPath.row)];
    }else{
        [self performSegueWithIdentifier:@"aboutVC" sender:@(indexPath.row)];
    }
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([sender isKindOfClass:[NSNumber class]]){
        
        UIViewController *vc=segue.destinationViewController;
        
        vc.title=items[[sender intValue]];
    }
    
    
}

@end
