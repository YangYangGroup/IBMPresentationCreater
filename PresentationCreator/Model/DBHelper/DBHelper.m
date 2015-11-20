//
//  DBHelper.m
//  oilManage
//
//  Created by 智享 on 14-8-25.
//  Copyright (c) 2014年 智享. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper
+(FMDatabase *)openDatabase{
    //paths： ios下Document路径，Document为ios中可读写的文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentDirectory);
    //dbPath： 数据库路径，在Document中。
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"Test.sqlite"];
    //创建数据库实例 db  这里说明下:如果路径中不存在"Test.db"的文件,sqlite会自动创建"Test.db"
    FMDatabase *db= [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    }else{
        return db;
    }
}
@end
