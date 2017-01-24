//
//  ReservationTableViewCell.m
//  Openlab
//
//  Created by admin on 16/5/4.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "ReservationTableViewCell.h"

@implementation ReservationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.cancelBtn.layer.cornerRadius=5.0;
    self.cancelBtn.layer.borderColor=[[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7] CGColor];
    self.cancelBtn.layer.borderWidth=1;
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7] forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
