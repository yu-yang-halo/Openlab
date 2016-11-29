//
//  TimeUtils.m
//  fillPaintMaster
//
//  Created by apple on 15/9/29.
//  Copyright © 2015年 LZTech. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils
+(NSString *)createTimeString:(int)row column:(int)col{
    /*
        7:00 7:30 8:00 8:30 9:00 9:30
     
     
     */
    NSString *minuteStr;
    if(col%2==0){
        minuteStr=@"00";
    }else{
        minuteStr=@"30";
    }
    int hourINT=row*3+7+col/2;
    
    return [NSString stringWithFormat:@"%d:%@",hourINT,minuteStr];
}
+(NSString *)normalShowTime:(NSString *)serverTime{
   
    NSDate *date =[self normalDate:serverTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    return [dateFormatter2 stringFromDate:date];
}

+(NSDate *)dateFromString:(NSString *)dateStr format:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    
    return date;
}
+(NSString *)formatData:(NSString *)date from:(NSString *)formatFrom to:(NSString *)formatTo{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatFrom];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDate *time = [dateFormatter dateFromString:date];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:formatTo];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    return [dateFormatter2 stringFromDate:time];
}
+(NSDate *)normalDate:(NSString *)serverTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //2016-04-09T16:30:53.000+08:00
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000+08:00"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    NSDate *date = [dateFormatter dateFromString:serverTime];
    return date;
}

+(NSString *)normalShowTime:(NSString *)serverTime format:(NSString *)format{
    NSDate *date =[self normalDate:serverTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:format];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    return [dateFormatter2 stringFromDate:date];
}

+(BOOL)isOverTime:(NSString *)time format:(NSString *)format{
    
    NSDate *currentTime=[NSDate new];
    //三分钟内都可
    currentTime=[currentTime dateByAddingTimeInterval:(8*60*60-3*60)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //2016-04-09T16:30:53.000+08:00
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSDate *formatTime = [dateFormatter dateFromString:time];
   
    NSComparisonResult result=[currentTime compare:formatTime];
    
    if(result==NSOrderedAscending||result==NSOrderedSame){
        return NO;
    }
    
    return YES;
}
+(NSString *)newDate:(int)incre{
    NSDate *date=[NSDate new];
    
    date=[date dateByAddingTimeInterval:24*60*60*incre];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd+HH+mm+ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *)createTimeHHMM:(NSString *)hhmm incre:(int)incre{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
    
  
    [dateComponentsForDate setDay:(dateComponentsForDate.day+incre)];
    
    NSArray *hhmmArr=[hhmm componentsSeparatedByString:@":"];
    
    [dateComponentsForDate setHour:[hhmmArr[0] intValue]];
    [dateComponentsForDate setMinute:[hhmmArr[1] intValue]];
    [dateComponentsForDate setSecond:0];
    
    //  根据设置的dateComponentsForDate获取历法中与之对应的时间点
    //  这里的时分秒会使用NSDateComponents中规定的默认数值，一般为0或1。
    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd+HH+mm+ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    return [dateFormatter stringFromDate:dateFromDateComponentsForDate];
}
+(NSString *)createTimeHHMM2:(NSString *)hhmm incre:(int)incre{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
    
    
    [dateComponentsForDate setDay:(dateComponentsForDate.day+incre)];
    
    NSArray *hhmmArr=[hhmm componentsSeparatedByString:@":"];
    
    [dateComponentsForDate setHour:[hhmmArr[0] intValue]];
    [dateComponentsForDate setMinute:[hhmmArr[1] intValue]];
    [dateComponentsForDate setSecond:0];
    
    //  根据设置的dateComponentsForDate获取历法中与之对应的时间点
    //  这里的时分秒会使用NSDateComponents中规定的默认数值，一般为0或1。
    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000+08:00"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    

    return [dateFormatter stringFromDate:dateFromDateComponentsForDate];
}

+(NSDate *)addHoursAndMin:(NSUInteger)hours minutes:(NSUInteger)mins toDate:(NSDate*)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
     NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:date];
    [comps setHour:comps.hour+hours];
    [comps setMinute:comps.minute+mins];
    
    return [gregorian dateFromComponents:comps];
}


+(NSInteger)toYear{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
    
    return dateComponentsForDate.year;
}


+(NSArray *)weekHourMinArrs:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:date];
    
  
    return @[@(dateComponentsForDate.weekday),@(dateComponentsForDate.hour),@(dateComponentsForDate.minute)];
    
}

@end

