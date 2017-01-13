//
//  CacheManager.h
//  Openlab
//
//  Created by admin on 2016/12/14.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject


+(NSArray *)fetchServerIpAndPort;
+(void)cacheServerIp:(NSString *)ipAddr AndPort:(NSString *)port;



@end
