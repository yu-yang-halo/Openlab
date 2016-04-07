//
//  MyObjectDataBean.h
//  Openlab
//
//  Created by admin on 16/4/7.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyObjectDataBean : NSObject

@end

@interface UserType : NSObject
@property(nonatomic,assign) int userId;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *realName;
@property(nonatomic,strong) NSString *phone;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *lastSecToken;
@property(nonatomic,strong) NSString *lastLoginTime;
@property(nonatomic,strong) NSString *cardId;
@property(nonatomic,strong) NSString *userRole;

@end

@interface LabInfoType : NSObject
@property(nonatomic,assign) int labId;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,assign) int numOfDesk;
@property(nonatomic,strong) NSString *building;
@property(nonatomic,assign) int floor;
@property(nonatomic,assign) int room;
@property(nonatomic,strong) NSArray *deskInfos;
@end

@interface DeskInfo : NSObject
@property(nonatomic,assign) int deskNum;
@property(nonatomic,assign) int labId;
@property(nonatomic,assign) int type;
@property(nonatomic,strong) NSString* desc;
@end

@interface ReservationType :NSObject
@property(nonatomic,assign) int resvId;
@property(nonatomic,strong) NSString* userName;
@property(nonatomic,strong) NSString* startTime;
@property(nonatomic,strong) NSString* endTime;
@property(nonatomic,strong) NSString* cancelTime;

@property(nonatomic,assign) int deskNum;
@property(nonatomic,assign) int labId;
@property(nonatomic,assign) int status;
@end

@interface AssignmentType : NSObject
@property(nonatomic,assign) int asId;
@property(nonatomic,assign) int createdBy;
@property(nonatomic,strong) NSString *courseCode;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *dueDate;
@property(nonatomic,strong) NSString *createdTime;
@end


