//
//  RegexUtils.h
//  Openlab
//
//  Created by admin on 16/4/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyStringUtils : NSObject
//正则表达式判断
+(BOOL)isMobileNumber:(NSString *)mobileNum;
+(BOOL)isEmpty:(NSString *)str;

//中文字符编码
+(NSString *)encodeToPercentEscapeString:(NSString *)input;


@end
