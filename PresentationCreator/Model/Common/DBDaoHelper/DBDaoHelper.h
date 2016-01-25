//
//  DBDaoHelper.h
//  PresentationCreator
//
//  Created by songyang on 15/10/11.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHelper.h"
#import "ProjectModel.h"
#import "DetailsModel.h"
#import "FilesModel.h"
#import "SummaryModel.h"
#import "TemplateDetailsModel.h"

@interface DBDaoHelper : NSObject
//创建数据库表
+(BOOL)createAllTable;
+(NSString *)selectTable;
//插入html代码
+(BOOL )insertIntoTemplateDetailsHtml:(NSString *)templateHtml TemplateId:(NSString *)templateId;
//向summary表中插入我的名字，返回最大的主键值
+(NSString *)insertSummaryWithName:(NSString *)name;
//查询table数组内容
+(NSMutableArray *)selectTableArray;
//查询创作页面数组内容
+(NSString *)selectCreationPageString:(NSString *)templateId;
//插入TABLE_TEMPLATE_DETAILS的html代码
+(BOOL)insertHtmlToDetailsSummaryIdWith:(NSString *)summaryId TemplateId:(NSString *)templateId TemplateDetailsId:(NSString *)templateDetailsId HtmlCode:(NSString *)htmlCode PageNumber:(NSString *)pageNumber;

//插入template 的代码
+(NSString *)insertIntoTemplateWithTemplateName:(NSString *)templateName TemplateThumbnail:(NSString *)image UpdateFlag:(NSString *)updateFlag;

// 根据summary id 查询 PPT_PRODUCT_DETAILS 表中对应的结果集
+(NSMutableArray *)selectDetailsDataBySummaryId:(NSString *)summaryId;

// 点预览时生成html代码，更新到对应的PPT_PRODUCT_SUMMARY表中的记录
+(BOOL)updateSummaryContentById:(NSString *)summaryId HtmlCode:(NSString *)htmlCode;
//向details表中插入我的summaryid和templateid，返回最大的主键值
+(NSString *)insertDetailsWithSummaryId:(NSString *)summaryid templateId:(NSString *)templateid;
//根据传过来的details表的detailsid修改html_code
+(BOOL)updateDetailsIdWith:(NSString *)detailsid htmlCode:(NSString *)htmlcode;
// 根据summary id 查询 summary表中html code
+(NSString *)queryHtmlCodeFromSummary:(NSString *)summaryId;
// 根据summary id 查询 summary表中productUrl
+(NSString *)queryProductUrlFromSummary:(NSString *)summaryId;
//删除
+(void)deleteDetailsWithsql:(NSString *)detailsId;
// 根据 summary id 查询最大的 page number
+(NSString *)getMaxPageNumber:(NSString *)summaryId;
// 根据summary id 修改最后一页的page number 为最大的page number
+(BOOL)updatePageNumberToMaxNumber:(NSString *)summaryId pageNumber:(NSString *)pagenumber;
// 根据summary id 删除 summary 表的记录
+(BOOL)deleteSummaryById:(NSString *)summaryId;
+(BOOL)insertFilePathToDetails_idWith:(NSString *)detailsId summary_id:(NSString *)summaryId file_type:(NSString *)fileType file_path:(NSString *)filePath;
+(NSMutableArray *)selectFromFileToSummary_idWith:(NSString *)summaryId;
//根据summaryid向summary表中插入productUrl
+(BOOL)insertSummaryWithSummaryId:(NSString *)summaryId productUrl:(NSString *)producturl;
//根据 summary id 更新 summary name
+(BOOL)updateSummaryNameById:(NSString *)summaryId SummaryName:(NSString *)summaryName;
// 查询 PPT_PRODUCT_FILES 表中所有的声音文件
+(NSMutableArray *)queryAllAudioFiles;
//查询是否带 _copy 的 summary name.
+(NSMutableArray *)queryAllSummaryNameByOldName :(NSString *)oldName;

//copy data to details table
+(BOOL)copyDetailsData:(NSString *)summaryId TemplateId:(NSString *)templateId HtmlCode:(NSString *)htmlCode PageNumber:(NSString *)pageNumber fileId:(NSString *)fileId;
//copy summary data，返回最大的主键值
+(NSString *)copySummaryData:(NSString *)newName ContentHtml:(NSString *)contentHtml Status:(NSString *)status;
//查询summary表中所有数据，放入数组中
+(NSMutableArray *)qeuryAllSummaryData;
// 根据summary id 查询 summary表中summary name
+(NSString *)querySummaryNameBySummaryId:(NSString *)summaryId;
// 根据summary id 更新 summary status and datetime
+(BOOL)updateSummaryStatsDateTimeBySummaryId:(NSString *)summaryId SummaryStatus:(NSString *)status;
//查询summary表中所有数据，放入数组中
+(SummaryModel *)qeuryOneSummaryDataById:(NSString *)summaryID;

//查询file id 查询声音路径
+(NSString *)queryAudioPathByFileId:(NSString *)fileId;
//根据details id 查询声音路径
+(NSString *)queryAudioPathByDetailsId:(NSString *)detailsId;
// 更新 details 表中的数据file_id
+(BOOL)updateDetailByFileId:(NSString *)fileId DetailsId : (NSString *)detailsID;
// check 文件是否被使用
+(BOOL)checkFileIsUseByFileId:(NSString *)fileId;
// 删除文件根据文件id
+(BOOL)deleteFileByFileId:(NSString *)filedId;
// 根据summary id 查询 product status
+(NSString *)queryProductStatusBySummaryId:(NSString *)summaryId;

//查询template details 表的数据 根据template id
+(NSMutableArray *)queryTemplateDetailsWithTemplateId:(NSString *)templateId;
//查询 所有 的 template
+(NSMutableArray *)queryAllTemplate;
//查询首页的template detail
+(TemplateDetailsModel *)queryOneTemplateWithTemplateId:(NSString *)templateId;

//delete current page
+(BOOL)deleteCurrentPageByPageNumber:(NSString *)pageNumber SummaryId:(NSString *)summaryId;

// add new page
+(BOOL)updateOldPageNumberByNewPageNumber:(NSString *)pageNumber SummaryId:(NSString *)summaryId;
//查询template表中所有数据，放入数组中
+(NSMutableArray *)selectTemplateIdAndUpdateFlag;
@end
