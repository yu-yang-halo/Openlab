//
//  main.m
//  commandLineTest
//
//  Created by admin on 16/4/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        
        NSString *outputStr = @"张三";
         NSLog(@"outputStr %@",outputStr);
        outputStr= [outputStr stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet whitespaceCharacterSet]];
        NSMutableString *t=[NSMutableString new];
        [t appendFormat:[NSString stringWithFormat:@"%@",outputStr]];
        NSLog(@"outputStr %@",t);
    }
    return 0;
}
