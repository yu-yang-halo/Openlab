//
//  ScoreTableViewCell.h
//  Openlab
//
//  Created by admin on 16/10/24.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *scoreNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreCommentLabel;

@end
