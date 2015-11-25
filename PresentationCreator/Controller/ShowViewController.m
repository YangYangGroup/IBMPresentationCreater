//
//  ShowViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "ShowViewController.h"
#import "EditViewController.h"
#import "DetailsModel.h"
#import "Global.h"
#import "DBDaoHelper.h"
#import "LoadingHelper.h"
#import "SBJson.h"
#import "AFNetworking.h"
#import "KxMenu.h"
#import "SummaryModel.h"
#import "EditPresentationNameViewController.h"

@interface ShowViewController ()<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *getHtmlFromSummaryStr;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;
@property (nonatomic, strong) NSMutableArray *returnFileArray;
@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) NSString *finalProductUrlStr;
@end

@implementation ShowViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = [DBDaoHelper querySummaryNameBySummaryId:_showSummaryIdStr];
    
    //从summary 表中根据summary id获取html代码，并加载到webView中
    _finalHtmlCode = [DBDaoHelper queryHtmlCodeFromSummary:_showSummaryIdStr];
    _finalProductUrlStr = [DBDaoHelper queryProductUrlFromSummary:_showSummaryIdStr];
    [self addWebView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    
    
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
}
//查询summaryhtmlcode 加载到webview 进行总的预览
-(void)loadDetailsDataToArray{
    NSString *sections = [[NSString alloc] init];
    _detailsListMuArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];//播放的details表的summaryid
    for (int i =0; i<_detailsListMuArray.count; i++) {
        DetailsModel *dm = [_detailsListMuArray objectAtIndex:i];
        
        NSString *tmp = [self processStringWithSection:dm.htmlCodeStr :i+1];
        sections = [sections stringByAppendingString:tmp];
    }
    _stringSections = sections;
    NSLog(@"my html code is:::%@", _stringSections);
    
}
//处理section 拼接字符串
-(NSString *)processStringWithSection:(NSString *)htmlCode :(NSInteger) currentRowIndex{
    
    NSRange rangeStartSection = [htmlCode rangeOfString:@"<section"];
    NSInteger startLocation = rangeStartSection.location;
    
    
    //-substringFromIndex: 以指定位置开始（包括指定位置的字符），并包括之后的全部字符
    NSString *stringStart = [htmlCode substringFromIndex:startLocation];
    
    
    NSRange rangeEndSection = [stringStart rangeOfString:@"</section>"];
    NSInteger endLocation = rangeEndSection.location;
    
    //-substringToIndex: 从字符串的开头一直截取到指定的位置，但不包括该位置的字符 +10表示包括</section>
    NSString *stringEnd = [stringStart substringToIndex:endLocation+10];
    
    NSMutableString *finalString = [[NSMutableString alloc] initWithString:stringEnd];
    
    NSString *className = @"<section class='swiper-slide swiper-slide" ;
    
    className =  [className stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)currentRowIndex]];
    className = [className stringByAppendingFormat:@"'"];
    
    [finalString replaceCharactersInRange:NSMakeRange(0,9) withString:className];
    
    return  finalString;
}
//生成最终的html代码保存到summary表中
-(void)generationFinalHtmlCode{
    NSString *htmlCodes = final_html_befor_section;
    htmlCodes = [htmlCodes stringByAppendingString:_stringSections];
    htmlCodes = [htmlCodes stringByAppendingString:final_html_after_section];
    [DBDaoHelper updateSummaryContentById : htmlCodes : self.showSummaryIdStr];
    _finalHtmlCode = htmlCodes;
}
-(void)addNavigation
{
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    backbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backbtn.frame = CGRectMake(0, 0, 40, 30);
    backbtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backbtn setTitle:@"Back" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SearchItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    //    [rightbtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = SearchItem;
    
    
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame=CGRectMake(40, 0, 20, 20);
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
//    [uploadButton setTitle:@"+" forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    uploadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [uploadButton addTarget:self action:@selector(showMenu:)forControlEvents:UIControlEventTouchDown];
    [rightBarView addSubview:uploadButton];
    
//    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [editButton setFrame:CGRectMake(0, 0, 30, 20)];
//    [editButton setTitleColor:[UIColor colorWithRed:63/255.0 green:140/255.0 blue:246/255.0 alpha:1]forState:UIControlStateNormal];
//    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
//    editButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [editButton addTarget:self action:@selector(editClick)forControlEvents:UIControlEventTouchDown];
//   
//    [rightBarView addSubview:editButton];
//    rightBarView.backgroundColor=[UIColor greenColor];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editClick
{
    EditViewController *vc = [[EditViewController alloc]init];
    NSLog(@"%@",self.showSummaryNameStr);
    NSLog(@"%@",self.showTemplateIdStr);
    vc.showSummaryNameStr = self.showSummaryNameStr;
    vc.showTemplateIdStr = self.showTemplateIdStr;
    vc.showSummaryIdStr = self.showSummaryIdStr;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)addWebView
{
    UIView *aView = [[UIView alloc]init];
    aView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aView];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor redColor];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
    [self.view addSubview: _webView];
    
    //添加分享框
    _shareView = [[UIView alloc]init];
    _shareView.frame = CGRectMake(KScreenWidth - 105, 5, 100, 80);
    _shareView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    _shareView.hidden = YES;
    [_webView addSubview:_shareView];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.frame = CGRectMake(10, 40, 80, 1);
    lineView.backgroundColor = [UIColor blackColor];
    [_shareView addSubview:lineView];
    
    //上传按钮
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadBtn.frame = CGRectMake(10,5,80,30);
    [uploadBtn setTitle:@"Upload" forState:UIControlStateNormal];
    [uploadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(uploadClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareView addSubview:uploadBtn];
    
    //分享给微信好友
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(10,45,80,30);
    [shareBtn setTitle:@"Share" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareView addSubview:shareBtn];
}
-(void)addClick
{
    if (_shareView.hidden == YES) {
        _shareView.hidden = NO;
    }else {
        _shareView.hidden = YES;
    }
    
}
-(void)uploadClick
{
    self.returnFileArray = [DBDaoHelper selectFromFileToSummary_idWith:self.showSummaryIdStr];
    
    [LoadingHelper showLoadingWithView:self.view];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"0" forKey:@"operationType"];
    [dic setObject:self.showSummaryNameStr forKey:@"productName"];
    [dic setObject:_finalHtmlCode forKey:@"productContent"];
    NSLog(@"%@",_finalHtmlCode);
    [dic setObject:self.showSummaryNameStr forKey:@"productTitle"];
    [dic setObject:@"111.111" forKey:@"productUrl"];
    [dic setObject:@"1" forKey:@"userId"];
    [dic setObject:@"productid" forKey:@"productId"];
    [dic setObject:@"111.111" forKey:@"productUrl"];
    
    NSMutableArray *postArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < _returnFileArray.count; i++){
        FilesModel *model = [self.returnFileArray objectAtIndex:i];
        //        if ([model.filetypeStr isEqual:@"image"]) {
        
        [postArray addObject:model.filePathStr];
        //        }
    }
    NSString *str1 = [postArray JSONRepresentation];
    [dic setObject:str1 forKey:@"filelist"];
    
    //    NSLog(@"%@",str1);
    NSString *uploadUrl = @"http://9.115.26.143/PPT/service/UploadServlet";
    
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    requestManager.requestSerializer.timeoutInterval=15.f;//请求超时45S
    
    
    NSMutableURLRequest *request = [requestManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:uploadUrl parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < _returnFileArray.count; i++){
            FilesModel *model = [self.returnFileArray objectAtIndex:i];
            if ([model.filetypeStr isEqual:@"image"]) {
                NSLog(@"filePathStr%@",model.filePathStr);
                NSString *fileStr = [NSString stringWithFormat:@"%@",model.filePathStr];
                UIImage *image = [UIImage imageWithContentsOfFile:fileStr];
                
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                // 设置时间格式
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
                //        NSLog(@"%@",imageData);
                // 上传图片，以文件流的格式
                [formData appendPartWithFileData:imageData name:@"Documents" fileName:fileName mimeType:@"image/png"];
                //                    [postArray addObject:model.filePathStr];
            }else if ([model.filetypeStr isEqual:@"audio"]){
                
                NSRange rangeStartSection = [model.filePathStr rangeOfString:@"Documents/"];
                NSInteger startLocation = rangeStartSection.location;
                
                
                //-substringFromIndex: 以指定位置开始（包括指定位置的字符），并包括之后的全部字符
                NSString *stringStart = [model.filePathStr substringFromIndex:startLocation+10];
                
                NSString *fileNameStr = [NSString stringWithFormat:@"%@",stringStart];
                
                
                NSData *data = [NSData dataWithContentsOfFile:model.filePathStr];
                [formData appendPartWithFileData:data name:@"Documents" fileName:fileNameStr mimeType:@"audio/wav"];
                //        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
                
            }
        }
        //        [dic setObject:postArray forKey:@"filelist"];
        
    }error:nil];
    
    NSLog(@"%@",request);
    AFHTTPRequestOperation *operation = [requestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        //系统自带JSON解析
        NSDictionary *resultJsonDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"上传成功--%@",resultJsonDic);
        NSString *str = [resultJsonDic objectForKey:@"productUrl"];
        //根据summaryid向summary表中插入productUrl
        [DBDaoHelper insertSummaryWithSummaryId:self.showSummaryIdStr productUrl:str];
        _finalProductUrlStr = [DBDaoHelper queryProductUrlFromSummary:_showSummaryIdStr];
        
        //        [LoadingHelper showLoadingWithView:self.view];
        [LoadingHelper hiddonLoadingWithView:self.view];
        NSString *title = NSLocalizedString(@"Successfully", nil);
//        NSString *message = NSLocalizedString(@"Upload successfully.", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败--%@",error);
        [LoadingHelper hiddonLoadingWithView:self.view];
        NSString *title = NSLocalizedString(@"Faild", nil);
        //        NSString *message = NSLocalizedString(@"Upload successfully.", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    [operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float  progress=(float)totalBytesWritten / totalBytesExpectedToWrite;
        //        NSLog(@"上传进度 = %f",progress);
        NSLog(@"totalBytesWritten == %lld totalBytesExpectedToWrite == %lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [request setTimeoutInterval:30.0f];
    [requestManager.operationQueue addOperation:operation];
    
    [operation start];
}
-(void)shareClick
{
    if (_finalProductUrlStr == nil) {
        NSLog(@"失败");
        NSString *title = NSLocalizedString(@"message", nil);
        NSString *message = NSLocalizedString(@"You must upload before share.", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        if ([WXApi isWXAppInstalled]) {
            //判断是否有微信
            //        [_delegate changeScene:WXSceneSession];
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"Share";
            message.description = @"A Wonderful PPT";
            [message setThumbImage:[UIImage imageNamed:@"sharewechat@2x.png"]];
            
            WXWebpageObject *ext = [WXWebpageObject object];
            //        ext.webpageUrl = @"http://www.baidu.com";
            ext.webpageUrl = _finalProductUrlStr;
            message.mediaObject = ext;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            //  根据scene来判断是分享朋友圈还是聊天对话
            req.scene = _scene;
            
            [WXApi sendReq:req];
        }else{
            
            NSString *weiXinLink = [WXApi getWXAppInstallUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
        }
    }
    
}

#pragma show menu list function
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Edit"
                     image:nil
                    target:self
                    action:@selector(editClick)],
      
      [KxMenuItem menuItem:@"Rename"
                     image:nil
                    target:self
                    action:@selector(editPresentationName)],
      
      [KxMenuItem menuItem:@"Copy"
                     image:nil
                    target:self
                    action:@selector(copyCurrentPresentation)],
      
      [KxMenuItem menuItem:@"Submit"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Share"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
}
// edit presentation name
-(void)editPresentationName{
    EditPresentationNameViewController *editPName = [[EditPresentationNameViewController alloc]init];
    editPName.summaryId = _showSummaryIdStr;
    editPName.summaryName = _showSummaryNameStr;
    [self.navigationController pushViewController:editPName animated:YES];
}

// copy a presentation
-(void)copyCurrentPresentation{
    NSString *title = NSLocalizedString(@"", nil);
    NSString *message = NSLocalizedString(@"Are you sure to copy this presentation?", nil);
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    NSString *deleteTitle = NSLocalizedString(@"Copy", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableArray *summaryNameArray = [DBDaoHelper queryAllSummaryNameByOldName:_showSummaryNameStr];
        
        NSString *newName = [[NSString alloc]initWithString:_showSummaryNameStr];
        newName = [newName stringByAppendingString:@"_copy"];
        
        if(summaryNameArray.count == 0){
            
        }else{
            int tmp = 0;
            for (int i = 0; i<summaryNameArray.count; i ++) {
                tmp ++;
            }
            
            newName = [newName stringByAppendingString:@"_"];
            newName = [newName stringByAppendingString:[NSString stringWithFormat:@"%d", tmp]];
        }
        
        //newName should be save.
        NSString *smID = [DBDaoHelper copySummaryData:newName ContentHtml:_finalHtmlCode];
        NSMutableArray *detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:_showSummaryIdStr];
        for (int i = 0; i<detailsArray.count; i ++) {
            DetailsModel *dm = [[DetailsModel alloc]init];
            dm = [detailsArray objectAtIndex:i];
            [DBDaoHelper copyDetailsData:smID TemplateId:dm.templateIdStr HtmlCode:dm.htmlCodeStr PageNumber:dm.pageNumberStr fileId:dm.fileIdStr];
        }
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
