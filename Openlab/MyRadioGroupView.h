//
//  MyRadioGroupView.h
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RadioButtonSelectedBlock)(NSInteger tag);

@interface MyRadioGroupView : UIView

-(void)setButtonImages:(NSArray *)normals selecteds:(NSArray *)selecteds;
-(void)setRadioButtonClickBlock:(RadioButtonSelectedBlock)block;


@end
