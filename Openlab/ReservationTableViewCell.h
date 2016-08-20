//
//  ReservationTableViewCell.h
//  Openlab
//
//  Created by admin on 16/5/4.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReservationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labnameText;

@property (weak, nonatomic) IBOutlet UILabel *deskNumText;

@property (weak, nonatomic) IBOutlet UILabel *startTimeText;

@property (weak, nonatomic) IBOutlet UILabel *endTimeText;
@property (weak, nonatomic) IBOutlet UILabel *usernameText;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end
