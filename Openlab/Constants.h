//
//  Constants.h
//  Openlab
//
//  Created by admin on 16/4/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


static const NSString* KEY_USERNAME=@"key_username";
static const NSString* KEY_PASSWORD=@"key_password";


#define ICON_BG_COLOR_NORMAL [UIColor colorWithRed:59/255.0 green:127/255.0 blue:229/255.0 alpha:1.0]
#define ICON_BG_COLOR_HIGHLIGHTED [UIColor colorWithRed:59/255.0 green:127/255.0 blue:229/255.0 alpha:180/255.0]

#define BUTTON_BG_COLOR_NORMAL [UIColor colorWithRed:0.0/255.0 green:64/255.0 blue:152/255.0 alpha:1.0]
#define BUTTON_BG_COLOR_HIGHLIGHTED [UIColor colorWithRed:0.0/255.0 green:64/255.0 blue:152/255.0 alpha:180/255.0]

static const int STATUS_NORMAL=0;
static const int STATUS_ACTIVE=1;
static const int STATUS_CARD_REMOVED=2;
static const int STATUS_CANCEL=3;
static const int STATUS_EXPIRED=4;
static const int STATUS_USED=5;


#endif /* Constants_h */
