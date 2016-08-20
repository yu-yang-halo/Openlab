//
//  MyObjectDataBean.h
//  Openlab
//
//  Created by admin on 16/4/7.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,Semester){
    Semester_NONE=0,
    Semester_LAST=1,
    Semester_NEXT=2
};


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

@interface ReportInfo : NSObject
@property(nonatomic,assign) int reportId;
@property(nonatomic,assign) int userId;
@property(nonatomic,assign) int assignmentId;
@property(nonatomic,strong) NSString *courseCode;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *fileName;
@property(nonatomic,strong) NSString *submitTime;
@end



@interface CourseType : NSObject
@property(nonatomic,strong) NSString *courseCode;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,assign) int year;
@property(nonatomic,assign) Semester semester;
@property(nonatomic,strong) NSArray *assignmentTypes;
@property(nonatomic,assign) BOOL isExpandYN;

@property(nonatomic,strong) NSArray *reportInfos;
@end

@interface Turple : NSObject

@property(nonatomic,strong) NSArray<AssignmentType *> *assignmentTypes;
@property(nonatomic,strong) NSArray<ReportInfo *> *reportInfos;

@end
