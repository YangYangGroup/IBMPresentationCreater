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
#import "TemplateDetailsModel.h"
#import "TemplateModel.h"

@implementation DBDaoHelper
//创建所有的数据库表
+(BOOL)createAllTable{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_TEMPLATE_DETAILS'('template_details_id'INTEGER PRIMARY KEY AUTOINCREMENT,'template_id'INTEGER,'template_html'varchar)"];
    //summary_name tableview创建ppt的名称 content_html最终生成的总的用于演示的html代码
    BOOL result2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_SUMMARY'('summary_id'INTEGER PRIMARY KEY AUTOINCREMENT,'summary_name'varchar,'content_html'varchar,'product_url'varchar,'product_status'varchar,'created_ts'datetime)"];
    //details_id主键 summary_id 外键关联到PPT_PRODUCT_SUMMARY表的主键 template_id关联到PPT_PRODUCT_template表的主键
    BOOL result3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_DETAILS'('details_id'INTEGER PRIMARY KEY AUTOINCREMENT,'page_number'integer,'file_id'INTEGER,'summary_id'integer,'template_id'integer,'template_details_id'integer,'html_code'varchar)"];
    
    BOOL result4 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_FILES'('file_id'INTEGER PRIMARY KEY AUTOINCREMENT,'details_id'integer,'summary_id'integer,'file_path'varchar,'file_type'varchar)"];
    BOOL result5 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_TEMPLATE'('template_id'INTEGER PRIMARY KEY AUTOINCREMENT,'template_name'varchar,'template_thumbnail'varchar,'update_flag'varchar,'created_ts'datetime)"];
    
    [db close];
    if (result1&&result2&&result3&&result4&&result5) {
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
//插入template details 的 html 代码
+(BOOL )insertIntoTemplateDetailsHtml:(NSString *)templateHtml TemplateId:(NSString *)templateId
{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_TEMPLATE_DETAILS'('template_html','template_id') values(?,?)",templateHtml,templateId];
    [db close];
    return result;
}
//插入template 的代码
+(NSString *)insertIntoTemplateWithTemplateName:(NSString *)templateName TemplateThumbnail:(NSString *)image UpdateFlag:(NSString *)updateFlag
{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_TEMPLATE'('template_name','template_thumbnail','update_flag','created_ts') values(?,?,?,datetime('now','localtime'))",templateName,image,updateFlag];
    if (result) {
        FMResultSet *result1 = [db executeQuery:@"SELECT  MAX(TEMPLATE_ID) FROM PPT_PRODUCT_TEMPLATE"];
        
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

//向summary表中插入我的名字，返回最大的主键值
+(NSString *)insertSummaryWithName:(NSString *)name{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_SUMMARY'('summary_name','product_status','created_ts') values(?,'Draft',datetime('now','localtime'))",name];
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
    NSString *sql = [NSString stringWithFormat:@"select * from 'PPT_PRODUCT_TEMPLATE_DETAILS' where template_details_id =%@",templateId];
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
+(BOOL)insertHtmlToDetailsSummaryIdWith:(NSString *)summaryId TemplateId:(NSString *)templateId TemplateDetailsId:(NSString *)templateDetailsId HtmlCode:(NSString *)htmlCode PageNumber:(NSString *)pageNumber{
    
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_DETAILS'('summary_id','template_id','template_details_id','html_code','page_number') values (?,?,?,?,?)", summaryId, templateId,templateDetailsId, htmlCode, pageNumber];
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
    
    NSString *sql = [NSString stringWithFormat:@"select summary_id,summary_name from PPT_PRODUCT_SUMMARY where summary_name like '%"];
    sql = [sql stringByAppendingString:oldName];
    sql = [sql stringByAppendingString:@"_copy%'"];
   
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSLog(@"sql:%@",sql);
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
+(NSString *)copySummaryData:(NSString *)newName ContentHtml:(NSString *)contentHtml Status:(NSString *)status{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_SUMMARY'('summary_name','content_html','product_status','created_ts') values(?,?,?,datetime('now','localtime'))",newName, contentHtml, status];
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
    FMResultSet *result = [db executeQuery:@"select summary_id, summary_name,content_html,  product_url, product_status, created_ts from PPT_PRODUCT_SUMMARY order by created_ts desc"];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        SummaryModel *model = [[SummaryModel alloc]init];
        model.summaryId     = [result stringForColumn:@"summary_id"];
        model.summaryName   = [result stringForColumn:@"summary_name"];
        model.contentHtml   = [result stringForColumn:@"content_html"];
        model.product_url   = [result stringForColumn:@"product_url"];
        model.status        = [result stringForColumn:@"product_status"];
        model.dateTime      = [result stringForColumn:@"created_ts"];
        
        [array addObject:model];
    }
    [db close];
    return array;
}

// 根据summary id 查询 summary表中summary name
+(NSString *)querySummaryNameBySummaryId:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT summary_name FROM PPT_PRODUCT_SUMMARY WHERE SUMMARY_ID =?",summaryId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
    
}

// 根据summary id 更新 summary status and datetime
+(BOOL)updateSummaryStatsDateTimeBySummaryId:(NSString *)summaryId SummaryStatus:(NSString *)status{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"update 'PPT_PRODUCT_SUMMARY' set product_status=? where summary_id=?",status, summaryId];
    
    [db close];
    return result;
}

//查询summary表中所有数据，放入数组中
+(SummaryModel *)qeuryOneSummaryDataById:(NSString *)summaryID
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select summary_id, summary_name,content_html,  product_url, product_status, created_ts from PPT_PRODUCT_SUMMARY where summary_id = ?",summaryID];
    SummaryModel *model = [[SummaryModel alloc]init];
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
       
        model.summaryId     = [result stringForColumn:@"summary_id"];
        model.summaryName   = [result stringForColumn:@"summary_name"];
        model.contentHtml   = [result stringForColumn:@"content_html"];
        model.product_url   = [result stringForColumn:@"product_url"];
        model.status        = [result stringForColumn:@"product_status"];
        model.dateTime      = [result stringForColumn:@"created_ts"];
    }
    [db close];
    return model;
}

//查询file id 查询声音路径
+(NSString *)queryAudioPathByFileId:(NSString *)fileId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT file_path FROM PPT_PRODUCT_FILES WHERE file_id = ?",fileId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
}

//根据details id 查询声音路径
+(NSString *)queryAudioPathByDetailsId:(NSString *)detailsId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT file_path FROM PPT_PRODUCT_FILES WHERE file_id =(SELECT file_id FROM PPT_PRODUCT_DETAILS WHERE details_id = ?)",detailsId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
}
// 更新 details 表中的数据file_id
+(BOOL)updateDetailByFileId:(NSString *)fileId DetailsId : (NSString *)detailsID{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"update 'PPT_PRODUCT_DETAILS' set file_id=? where details_id=?",fileId,detailsID];
    
    [db close];
    return result;
}
// check 文件是否被使用
+(BOOL)checkFileIsUseByFileId:(NSString *)fileId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result = [db executeQuery:@"SELECT count(file_id) FROM PPT_PRODUCT_DETAILS WHERE file_id = ?",fileId];
    BOOL flag = NO;
    while (result.next)
    {
        int cun = [result intForColumnIndex:0];
        if (cun==0) {
            flag = YES;
        }
    }
    [db close];
    return flag;
}
// 删除文件根据文件id
+(BOOL)deleteFileByFileId:(NSString *)filedId{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"DELETE FROM PPT_PRODUCT_FILES WHERE file_id= ?",filedId];
    [db close];
    return result;
}

// 根据summary id 查询 product status
+(NSString *)queryProductStatusBySummaryId:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT product_status FROM PPT_PRODUCT_SUMMARY WHERE summary_id = ?",summaryId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
}

//查询template details 表的数据 根据template id
+(NSMutableArray *)queryTemplateDetailsWithTemplateId:(NSString *)templateId
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from PPT_PRODUCT_TEMPLATE_DETAILS where template_id = ?",templateId];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        TemplateDetailsModel *model = [[TemplateDetailsModel alloc]init];
        model.templateId = templateId;
        model.templateDetailsId = [result stringForColumn:@"template_details_id"];
        model.templateHtml = [result stringForColumn:@"template_html"];
        
        [array addObject:model];
    }
    [db close];
    return array;
}


//查询 所有 的 template
+(NSMutableArray *)queryAllTemplate
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from PPT_PRODUCT_TEMPLATE order by created_ts desc"];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        TemplateModel *model = [[TemplateModel alloc]init];
        model.templateId = [result stringForColumn:@"template_id"];
        model.templateName = [result stringForColumn:@"template_name"];
        model.templateThumbNail = [result stringForColumn:@"template_thumbnail"];
        model.updateFlag = [result stringForColumn:@"update_flag"];
        model.createdTS = [result stringForColumn:@"created_ts"];
        
        [array addObject:model];
    }
    [db close];
    return array;
}
//查询首页的template detail
+(NSMutableArray *)queryTemplateWithTemplateId:(NSString *)templateId
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from PPT_PRODUCT_TEMPLATE_details where template_id = ? order by template_details_id",templateId];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        TemplateDetailsModel *model = [[TemplateDetailsModel alloc]init];
        model.templateId = templateId;
        model.templateHtml = [result stringForColumn:@"template_html"];
        model.templateDetailsId = [result stringForColumn:@"template_details_id"];
        
        [array addObject:model];
    }
    [db close];
    return array;
}

//delete current page
+(BOOL)deleteCurrentPageByPageNumber:(NSString *)pageNumber SummaryId:(NSString *)summaryId{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"DELETE FROM PPT_PRODUCT_DETAILS WHERE summary_id= ? and page_number=?",summaryId, pageNumber];
    BOOL resultUpdate;
    if (result) {
        resultUpdate = [db executeUpdate:@"UPDATE PPT_PRODUCT_DETAILS SET page_number= page_number - 1   WHERE summary_id =? and page_number > ?",summaryId ,pageNumber];
    }
    [db close];
    return resultUpdate;
}

// add new page
+(BOOL)updateOldPageNumberByNewPageNumber:(NSString *)pageNumber SummaryId:(NSString *)summaryId{
    FMDatabase *db = [DBHelper openDatabase];
    
    BOOL resultUpdate = [db executeUpdate:@"UPDATE PPT_PRODUCT_DETAILS SET page_number= page_number + 1   WHERE summary_id =? and page_number >= ?",summaryId ,pageNumber];
    
    [db close];
    return resultUpdate;
}
//查询template表中所有数据，放入数组中
+(NSMutableArray *)selectTemplateIdAndUpdateFlag
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from 'PPT_PRODUCT_TEMPLATE'"];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        TemplateModel *model = [[TemplateModel alloc]init];
        model.templateId = [result stringForColumn:@"template_id"];
        model.updateFlag = [result stringForColumn:@"update_flag"];
        [array addObject:model];
    }
    [db close];
    return array;
}
@end
