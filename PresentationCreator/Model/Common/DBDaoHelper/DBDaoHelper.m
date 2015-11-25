//
//  DBDaoHelper.m
//  PresentationCreator
//
//  Created by songyang on 15/10/11.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "DBDaoHelper.h"
#import "Global.h"
#import "SummaryModel.h"

@implementation DBDaoHelper
//创建所有的数据库表
+(BOOL)createAllTable{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_TEMPLATE'('template_id'INTEGER PRIMARY KEY AUTOINCREMENT,'template_html'varchar)"];
    //summary_name tableview创建ppt的名称 content_html最终生成的总的用于演示的html代码
    BOOL result2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_SUMMARY'('summary_id'INTEGER PRIMARY KEY AUTOINCREMENT,'summary_name'varchar,'content_html'varchar,'product_url',varchar)"];
    //details_id主键 summary_id 外键关联到PPT_PRODUCT_SUMMARY表的主键 template_id关联到PPT_PRODUCT_template表的主键
    BOOL result3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_DETAILS'('details_id'INTEGER PRIMARY KEY AUTOINCREMENT,'summary_id'integer,'template_id'integer,'html_code'varchar,'page_number'integer,'file_id'INTEGER )"];
    
    BOOL result4 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_FILES'('file_id'INTEGER PRIMARY KEY AUTOINCREMENT,'details_id'integer,'summary_id'integer,'file_path'varchar,'file_type'varchar)"];
    [db close];
    if (result1&&result2&&result3&&result4) {
        return YES;
    }else{
        return NO;
    }
}

//查询是否存在数据 加载html代码
+(NSString *)selectTable
{
    FMDatabase *db = [DBHelper openDatabase];
    FMResultSet *result = [db executeQuery:@"select * from 'PPT_PRODUCT_TEMPLATE'"];
    
    while (result.next)
    {
        NSString *str = [result stringForColumn:@"template_id"];
        return str;
    }
    [db close];
    return nil;
}
//插入html代码
+(BOOL )insetIntoTemplateHtml:(NSString *)templateHtml
{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_TEMPLATE'('template_html') values(?)",templateHtml];
    [db close];
    return result;
}
//向summary表中插入我的名字，返回最大的主键值
+(NSString *)insertSummaryWithName:(NSString *)name{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_SUMMARY'('summary_name') values(?)",name];
    if (result) {
        FMResultSet *result1 = [db executeQuery:@"SELECT  MAX(SUMMARY_ID) FROM PPT_PRODUCT_SUMMARY"];
        
        while (result1.next)
        {
            
            NSString *str = [result1 stringForColumnIndex:0];
            [db close];
            return str;
        }
    }
    [db close];
    return nil;
}

//查询table数组内容
+(NSMutableArray *)selectTableArray
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from PPT_PRODUCT_SUMMARY "];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        ProjectModel *model = [[ProjectModel alloc]init];
        model.tableNameStr = [result stringForColumn:@"summary_name"];
        model.tableId = [result intForColumn:@"summary_id"];
        [array addObject:model];
    }
    [db close];
    return array;
}
//查询创作页面数组内容
+(NSString *)selectCreationPageString:(NSString *)templateId
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    NSString *sql = [NSString stringWithFormat:@"select * from 'PPT_PRODUCT_TEMPLATE' where template_id =%@",templateId];
    FMResultSet *result = [db executeQuery:sql];
    //当下边还有分类的时候执行
    while (result.next)
    {
        
        NSString *str = [result stringForColumn:@"template_html"];
        [db close];
        return str;
    }
    [db close];
    return nil;
}

//插入TABLE_TEMPLATE的html代码
+(BOOL)insertHtmlToDetailsSummaryIdWith:(NSString *)summaryid TemplateId:(NSString *)templateid HtmlCode:(NSString *)htmlcode PageNumber:(NSString *)pagenumber{
    
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_DETAILS'('summary_id','template_id','html_code','page_number') values (?,?,?,?)", summaryid, templateid, htmlcode, pagenumber];
    [db close];
    return result;
}
// 根据summary id 查询 PPT_PRODUCT_DETAILS 表中对应的结果集
+(NSMutableArray *)selectDetailsDataBySummaryId:(NSString *)summaryId{
    FMDatabase *db = [DBHelper openDatabase];
    //order by 排序 从小到大
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PPT_PRODUCT_DETAILS WHERE SUMMARY_ID = %@ order by PAGE_NUMBER", summaryId];
    NSMutableArray *detailsArray = [[NSMutableArray alloc]init];
    FMResultSet *result = [db executeQuery:sql];
    while (result.next) {
        DetailsModel *detailsModel = [[DetailsModel alloc]init];
        detailsModel.detailsIdStr = [result stringForColumn:@"details_id"];
        detailsModel.summaryIdStr = [result stringForColumn:@"summary_id"];
        detailsModel.templateIdStr = [result stringForColumn:@"template_id"];
        detailsModel.htmlCodeStr = [result stringForColumn:@"html_code"];
        detailsModel.pageNumberStr = [result stringForColumn:@"PAGE_NUMBER"];
        detailsModel.fileIdStr = [result stringForColumn:@"file_id"];
        [detailsArray addObject:detailsModel];
    }
    [db close];
    return  detailsArray;
}
// 点预览时生成html代码，更新到对应的PPT_PRODUCT_SUMMARY表中的记录
+(BOOL)updateSummaryContentById:(NSString *)htmlCode :(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE PPT_PRODUCT_SUMMARY SET content_html=? WHERE summary_id =?",htmlCode, summaryId];
    [db close];
    return result;
    
}
//根据传过来的details表的detailsid修改html_code
+(BOOL)updateDetailsIdWith:(NSString *)detailsid htmlCode:(NSString *)htmlcode
{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE 'PPT_PRODUCT_DETAIlS' set html_code=? WHERE details_id =?",htmlcode,detailsid];
    [db close];
    return result;
}

// 根据summary id 查询 summary表中html code
+(NSString *)queryHtmlCodeFromSummary:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT  content_html FROM PPT_PRODUCT_SUMMARY WHERE SUMMARY_ID =?",summaryId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
    
}
// 根据summary id 查询 summary表中productUrl
+(NSString *)queryProductUrlFromSummary:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT  product_url FROM PPT_PRODUCT_SUMMARY WHERE SUMMARY_ID =?",summaryId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
    
}
//删除
+(void)deleteDetailsWithsql:(NSString *)detailsId
{
    FMDatabase *db = [DBHelper openDatabase];
    [db executeUpdate:@"DELETE FROM PPT_PRODUCT_DETAIlS WHERE details_id= ?",detailsId];
    [db close];
}
// 根据 summary id 查询最大的 page number
+(NSString *)getMaxPageNumber:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result = [db executeQuery:@"SELECT  MAX(PAGE_NUMBER) FROM PPT_PRODUCT_DETAIlS WHERE SUMMARY_ID = ?", summaryId];
    
    while (result.next)
    {
        NSString *str = [result stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
}

// 根据summary id 修改最后一页的page number 为最大的page number
+(BOOL)updatePageNumberToMaxNumber:(NSString *)summaryId pageNumber:(NSString *)pagenumber{
    FMDatabase *db =[DBHelper openDatabase];
    NSInteger maxNum = [pagenumber integerValue];
    maxNum ++;
    NSString *num = [NSString stringWithFormat:@"%ld", (long)maxNum];
    BOOL result = [db executeUpdate:@"UPDATE 'PPT_PRODUCT_DETAIlS' set PAGE_NUMBER = ? WHERE SUMMARY_ID =? and PAGE_NUMBER = ?", num, summaryId,pagenumber];
    [db close];
    return result;
}
// 根据summary id 删除 summary 表的记录
+(BOOL)deleteSummaryById:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result1 = [db executeUpdate:@"DELETE FROM PPT_PRODUCT_DETAILS WHERE SUMMARY_ID =?",summaryId];
    if(result1){
        BOOL result2 = [db executeUpdate:@"DELETE FROM PPT_PRODUCT_SUMMARY WHERE SUMMARY_ID =?",summaryId];
        if (result2) {
            [db close];
            return TRUE;
        }
    }
    [db close];
    return FALSE;
}

//插入filepath
+(BOOL)insertFilePathToDetails_idWith:(NSString *)detailsId summary_id:(NSString *)summaryId file_type:(NSString *)fileType file_path:(NSString *)filePath{
    
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_FILES'('details_id','summary_id','file_type','file_path') values (?,?,?,?)", detailsId, summaryId, fileType, filePath];
    if (result) {
        if([fileType isEqualToString:@"audio"]){
            FMResultSet *result = [db executeQuery:@"SELECT  MAX(file_id) FROM PPT_PRODUCT_FILES"];
            NSString *str = [[NSString alloc]init];
            while (result.next)
            {
                str = [result stringForColumnIndex:0];
            }
            
            BOOL result1 = [db executeUpdate:@"UPDATE PPT_PRODUCT_DETAILS set file_id=? WHERE  summary_id =? and details_id =?", str, summaryId, detailsId];
           [db close];
            return result1;
        }
        [db close];
        return result;
    }
    return result;
    
}
//查询table数组内容
+(NSMutableArray *)selectFromFileToSummary_idWith:(NSString *)summaryId
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    NSString *sql = [NSString stringWithFormat:@"select * from PPT_PRODUCT_FILES where summary_id =%@",summaryId];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        FilesModel *model = [[FilesModel alloc]init];
        model.fileDetailsIdStr = [result stringForColumn:@"details_id"];
        model.filesummaryIdStr = [result stringForColumn:@"summary_id"];
        model.filePathStr = [NSString stringWithFormat:@"%@",[result stringForColumn:@"file_path"]];
        model.filetypeStr = [result stringForColumn:@"file_type"];

        [array addObject:model];
    }
    [db close];
    return array;
}
//根据summaryid向summary表中插入productUrl
+(BOOL)insertSummaryWithSummaryId:(NSString *)summaryId productUrl:(NSString *)producturl{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE PPT_PRODUCT_SUMMARY set product_url=? WHERE summary_id =?",producturl,summaryId];
    [db close];
    return result;
}
//根据 summary id 更新 summary name
+(BOOL)updateSummaryNameById:(NSString *)summaryId SummaryName:(NSString *)summaryName{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE PPT_PRODUCT_SUMMARY SET summary_name=? WHERE summary_id =?",summaryName, summaryId];
    [db close];
    
    return result;
    
}
// 查询 PPT_PRODUCT_FILES 表中所有的声音文件
+(NSMutableArray *)queryAllAudioFiles{
    FMDatabase *db = [DBHelper openDatabase];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PPT_PRODUCT_FILES WHERE file_type='audio' ORDER BY FILE_ID desc"];
    
    NSMutableArray *detailsArray = [[NSMutableArray alloc]init];
    FMResultSet *result = [db executeQuery:sql];
    while (result.next) {
        FilesModel *fileModel = [[FilesModel alloc]init];
        fileModel.fileIdStr =[result stringForColumn:@"file_id"];
        fileModel.fileDetailsIdStr = [result stringForColumn:@"details_id"];
        fileModel.filesummaryIdStr = [result stringForColumn:@"summary_id"];
        fileModel.filePathStr = [result stringForColumn:@"file_path"];
        
        [detailsArray addObject:fileModel];
    }
    [db close];
    return  detailsArray;
    
}

//查询是否带 _copy 的 summary name.
+(NSMutableArray *)queryAllSummaryNameByOldName :(NSString *)oldName{
    FMDatabase *db = [DBHelper openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select summary_id,summary_name from PPT_PRODUCT_SUMMARY where summary_name like '%%@_copy%'", oldName];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    FMResultSet *result = [db executeQuery:sql];
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        SummaryModel *model = [[SummaryModel alloc]init];
        model.summaryName = [result stringForColumn:@"summary_name"];
        model.summaryId = [result stringForColumn:@"summary_id"];
        [array addObject:model];
    }
    [db close];
    return array;
}

//copy data to details table
+(BOOL)copyDetailsData:(NSString *)summaryId TemplateId:(NSString *)templateId HtmlCode:(NSString *)htmlCode PageNumber:(NSString *)pageNumber fileId:(NSString *)fileId{
    
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_DETAILS'('summary_id','template_id','html_code','page_number','file_id') values (?,?,?,?,?)", summaryId, templateId, htmlCode, pageNumber, fileId];
    [db close];
    return result;
}
//copy summary data，返回最大的主键值
+(NSString *)copySummaryData:(NSString *)newName ContentHtml:(NSString *)contentHtml{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_SUMMARY'('summary_name','content_html') values(?,?)",newName, contentHtml];
    if (result) {
        FMResultSet *result1 = [db executeQuery:@"SELECT  MAX(SUMMARY_ID) FROM PPT_PRODUCT_SUMMARY"];
        while (result1.next)
        {
            NSString *str = [result1 stringForColumnIndex:0];
            [db close];
            return str;
        }
    }
    [db close];
    return nil;
}

//查询summary表中所有数据，放入数组中
+(NSMutableArray *)qeuryAllSummaryData
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select summary_id, summary_name,content_html, product_url from PPT_PRODUCT_SUMMARY "];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        SummaryModel *model = [[SummaryModel alloc]init];
        model.summaryId = [result stringForColumn:@"summary_id"];
        model.summaryName = [result stringForColumn:@"summary_name"];
        model.contentHtml = [result stringForColumn:@"content_html"];
        model.product_url = [result stringForColumn:@"product_url"];
        [array addObject:model];
    }
    [db close];
    return array;
}
@end
