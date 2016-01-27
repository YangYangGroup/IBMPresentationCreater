//
//  ShowViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//
#import "PECropViewController.h"
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
#import "EditPageViewController.h"
#import "SelectTemplateForEditViewController.h"

#import "EditCurrentPageViewController.h"


@interface ShowViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *getHtmlFromSummaryStr;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;
@property (nonatomic, strong) NSMutableArray *returnFileArray;
@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) NSString *finalProductUrlStr;
@property (nonatomic, strong) UIView *shareAllView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) SummaryModel *sumyModel;
@property (nonatomic, strong) UIControl *backgroundViewControl;
@property (nonatomic, strong) NSString *currentPageNumber;
@property (nonatomic, strong) NSString *maxPageNumber;


@end

@implementation ShowViewController
-(void)viewWillAppear:(BOOL)animated{
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
    
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = [DBDaoHelper querySummaryNameBySummaryId:_showSummaryIdStr];
    [self initDataForAction];
    [self addWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTemplateNotification:) name:@"SelectedTemplate" object:nil];
    
    
}
-(void)initDataForAction{
    self.maxPageNumber = [DBDaoHelper getMaxPageNumber:self.showSummaryIdStr];

    _sumyModel = [DBDaoHelper qeuryOneSummaryDataById:_showSummaryIdStr];
    //从summary 表中根据summary id获取html代码，并加载到webView中
    _finalHtmlCode = _sumyModel.contentHtml;
    _finalProductUrlStr = _sumyModel.product_url;
    _showSummaryNameStr = _sumyModel.summaryName;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _sumyModel = [[SummaryModel alloc]init];
    
    [self addNavigation];
    
}
//查询summaryhtmlcode 加载到webview 进行总的预览
-(void)loadDetailsDataToArray{
    NSString *sections = [[NSString alloc] init];
    _detailsListMuArray = [[NSMutableArray alloc]init];
    _detailsListMuArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];//播放的details表的summaryid
    for (int i =0; i<_detailsListMuArray.count; i++) {
        DetailsModel *dm = [_detailsListMuArray objectAtIndex:i];
        
        NSString *tmp = [self processStringWithSection:dm.htmlCodeStr :i+1];
        sections = [sections stringByAppendingString:tmp];
    }
    _stringSections = sections;
    
    
}
//处理section 拼接字符串
-(NSString *)processStringWithSection:(NSString *)htmlCode :(NSInteger) currentRowIndex{
    
    NSString *setIndexString = @"swiper-slide swiper-slide";
    NSString *tmpString = [NSString stringWithFormat:@"%ld",(long)currentRowIndex];
    setIndexString = [setIndexString stringByAppendingString:tmpString];
    NSString *newHtmlCode = [htmlCode
                             stringByReplacingOccurrencesOfString:
                             @"swiper-slide swiper-slide" withString:setIndexString];
    
    NSRange rangeStartSection = [newHtmlCode rangeOfString:@"<section"];
    NSInteger startLocation = rangeStartSection.location;
    
    //-substringFromIndex: 以指定位置开始（包括指定位置的字符），并包括之后的全部字符
    NSString *stringStart = [newHtmlCode substringFromIndex:startLocation];
    NSRange rangeEndSection = [stringStart rangeOfString:@"</section>"];
    NSInteger endLocation = rangeEndSection.location;
    
    //-substringToIndex: 从字符串的开头一直截取到指定的位置，但不包括该位置的字符 +10表示包括</section>
    NSString *stringEnd = [stringStart substringToIndex:endLocation+10];
    return  stringEnd;
}
//生成最终的html代码保存到summary表中
-(void)generationFinalHtmlCode{
    _finalHtmlCode = @"";
    NSString *htmlCodes = final_html_befor_section;
    htmlCodes = [htmlCodes stringByAppendingString:_stringSections];
    htmlCodes = [htmlCodes stringByAppendingString:final_html_after_section];
    [DBDaoHelper updateSummaryContentById:self.showSummaryIdStr HtmlCode:htmlCodes];
    _finalHtmlCode = htmlCodes;
}
-(void)addNavigation
{
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame=CGRectMake(0, 0, 30, 30);
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    uploadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [uploadButton addTarget:self action:@selector(showMenu:)forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc]initWithCustomView:uploadButton];
    self.navigationItem.rightBarButtonItem = uploadItem;
    
}
-(void)backClick
{
    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)editClick
{
//    EditViewController *vc = [[EditViewController alloc]init];
//    NSLog(@"%@",self.showSummaryNameStr);
//    NSLog(@"%@",self.showTemplateIdStr);
//    vc.showSummaryNameStr = self.showSummaryNameStr;
//    vc.showTemplateIdStr = self.showTemplateIdStr;
//    vc.showSummaryIdStr = self.showSummaryIdStr;
//    [self.navigationController pushViewController:vc animated:YES];
    
    EditPageViewController *eAllPageVC = [[EditPageViewController alloc] init];
    eAllPageVC.showSummaryIdStr = _showSummaryIdStr;
    eAllPageVC.showSummaryNameStr = _showSummaryNameStr;
    eAllPageVC.showTemplateIdStr = self.showTemplateIdStr;
    [self.navigationController pushViewController:eAllPageVC animated:YES];
}


-(void)addWebView
{
    UIView *aView = [[UIView alloc]init];
    aView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aView];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor whiteColor];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
    [self.view addSubview: _webView];
    
    
//    
//    self.numberlabel = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth-25, 64, 25, 17)];
//    self.numberlabel.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:0.5];
//    NSString *totalPage = [NSString stringWithFormat:@"%ld",self.detailsListMuArray.count];
//    NSString *pageNum = @"1/";
//    pageNum = [pageNum stringByAppendingString:totalPage];
//    self.numberlabel.text = pageNum;
//    self.numberlabel.textAlignment = NSTextAlignmentCenter;
//    self.numberlabel.font = [UIFont fontWithName:@"Arial" size:11];
//    
//    [self.view addSubview:self.numberlabel];
}


-(void)loadHtmlToWebView{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"getPageNumber"] = ^() {
        
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        NSString *totalPage = [NSString stringWithFormat:@"%ld",self.detailsListMuArray.count];
        
        NSString *num = [[NSString alloc]initWithFormat:@"%@",args[0]];
        int number = [num intValue];
        number ++;
        
        NSString *tempNum = [NSString stringWithFormat:@"%ld",(long)number];
       
        NSString *cPageNumber = tempNum;
        cPageNumber = [cPageNumber stringByAppendingString:@"/"];
        cPageNumber = [cPageNumber stringByAppendingString:totalPage];
//        self.numberlabel.text = cPageNumber;
        
        NSLog(@"-------End Text-------");
        
    };
    
}

-(void)uploadClick
{
    self.returnFileArray =
                [DBDaoHelper selectFromFileToSummary_idWith:self.showSummaryIdStr];
    
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
    NSString *uploadUrl = @"http://9.115.24.148/PPT/service/UploadServlet";
    
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
        BOOL publishStatus = [DBDaoHelper updateSummaryStatsDateTimeBySummaryId:self.showSummaryIdStr SummaryStatus:@"Published"];
        if (publishStatus) {
            _productStatus = @"Published";
        }
        _productStatus = @"Published";
        //        [LoadingHelper showLoadingWithView:self.view];
        [LoadingHelper hiddonLoadingWithView:self.view];
        NSString *title = NSLocalizedString(@"Successfully", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
           
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
            
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    [operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        float  progress=(float)totalBytesWritten / totalBytesExpectedToWrite;
        //        NSLog(@"上传进度 = %f",progress);
        NSLog(@"totalBytesWritten == %lld totalBytesExpectedToWrite == %lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [request setTimeoutInterval:30.0f];
    [requestManager.operationQueue addOperation:operation];
    
    [operation start];
}
-(void)shareClick
{
    [self addShare];
    [UIView animateWithDuration:.25 animations:^{
        
        _shareAllView.frame = CGRectMake(0, KScreenHeight-170, KScreenWidth, 150);
        
        
    } completion:^(BOOL finished) {
        NSLog(@"动画完事调用的BLOCK");
    }];
    
}

#pragma show menu list function
- (void)showMenu:(UIButton *)sender
{
  
    NSArray *menuItems = [[NSArray alloc]init];
   
    if ([_productStatus isEqualToString:@"Published"]) {
        menuItems = @[
                      [KxMenuItem menuItem:@"Add Page"
                                     image:nil
                                    target:self
                                    action:@selector(addPageClick)],
                      
                      [KxMenuItem menuItem:@"Delete Page"
                                     image:nil
                                    target:self
                                    action:@selector(deleteClick)],
                      
                      [KxMenuItem menuItem:@"Edit"
                                     image:nil
                                    target:self
                                    action:@selector(editCurrentPage)],
                      
//                      [KxMenuItem menuItem:@"Recording"
//                                     image:nil
//                                    target:self
//                                    action:@selector(talkClick)],
                      
                      [KxMenuItem menuItem:@"Rename"
                                     image:nil
                                    target:self
                                    action:@selector(editPresentationName)],
                      
                      [KxMenuItem menuItem:@"Copy"
                                     image:nil
                                    target:self
                                    action:@selector(copyCurrentPresentation)],
                      
                      [KxMenuItem menuItem:@"Publish"
                                     image:nil
                                    target:self
                                    action:@selector(uploadClick)],
                      [KxMenuItem menuItem:@"Share"
                                     image:nil
                                    target:self
                                    action:@selector(shareClick)],
                      
                      ];
        
       
    }else{
        menuItems = @[
                      
                      [KxMenuItem menuItem:@"Add Page"
                                     image:nil
                                    target:self
                                    action:@selector(addPageClick)],
                      
                      [KxMenuItem menuItem:@"Delete Page"
                                     image:nil
                                    target:self
                                    action:@selector(deleteClick)],
                      
                      [KxMenuItem menuItem:@"Edit"
                                     image:nil
                                    target:self
                                    action:@selector(editCurrentPage)],

//                      [KxMenuItem menuItem:@"Audio List"
//                                     image:nil
//                                    target:self
//                                    action:@selector(openAudioList)],
//                      
//                      [KxMenuItem menuItem:@"Recording"
//                                     image:nil
//                                    target:self
//                                    action:@selector(talkClick)],
                      
                      [KxMenuItem menuItem:@"Rename"
                                     image:nil
                                    target:self
                                    action:@selector(editPresentationName)],
                      
                      [KxMenuItem menuItem:@"Copy"
                                     image:nil
                                    target:self
                                    action:@selector(copyCurrentPresentation)],
                      
                      [KxMenuItem menuItem:@"Publish"
                                     image:nil
                                    target:self
                                    action:@selector(uploadClick)],
                      
                      
                      ];
    }
    
    
//        KxMenuItem *first = menuItems[0];
//    first.a
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
}
// edit presentation name
-(void)editPresentationName{
    [self getUIWebViewPageNumber];
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
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
        
        SummaryModel *sModel = [DBDaoHelper qeuryOneSummaryDataById:self.showSummaryIdStr];
        //newName should be save.
        NSString *smID = [DBDaoHelper copySummaryData:newName ProductUrl:sModel.product_url ContentHtml:_finalHtmlCode Status:sModel.status Icon:sModel.icon];
        
        NSMutableArray *detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:_showSummaryIdStr];
        BOOL copyStatus = false;
        for (int i = 0; i<detailsArray.count; i ++) {
            DetailsModel *dm = [[DetailsModel alloc]init];
            dm = [detailsArray objectAtIndex:i];
            copyStatus =[DBDaoHelper copyDetailsData:smID TemplateId:dm.templateIdStr HtmlCode:dm.htmlCodeStr PageNumber:dm.pageNumberStr fileId:dm.fileIdStr];
        }
        [self copyStatus:copyStatus];
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
-(void)addShare
{
    _backgroundViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, KScreenHeight)];
    _backgroundViewControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundViewControl];
    
    
    UIView *backgroundView = [[UIView alloc]init];
    //    backgroundView.hidden = YES;
    backgroundView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    //        backgroundView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editShareClick)];
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [_backgroundViewControl addSubview:backgroundView];
    
    _shareAllView = [[UIView alloc]init];
    _shareAllView.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    _shareAllView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 150);
    [_backgroundViewControl addSubview:_shareAllView];
    
    _cancelBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame=CGRectMake(0, 110, KScreenWidth, 40);
    _cancelBtn.backgroundColor = [UIColor whiteColor];
    [_cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_cancelBtn addTarget:self action:@selector(cancelClick)forControlEvents:UIControlEventTouchUpInside];
    [_shareAllView addSubview:_cancelBtn];
    
    UIButton *friendBtn = [[UIButton alloc]init];
    friendBtn.frame = CGRectMake(KScreenWidth/4-60, 10, 60, 80);
    [friendBtn setImage:[UIImage imageNamed:@"friend"] forState:UIControlStateNormal];
    friendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    friendBtn.titleLabel.font = [UIFont systemFontOfSize:14];//title字体大小
    [friendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    [friendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
    friendBtn.titleEdgeInsets = UIEdgeInsetsMake(71, friendBtn.titleLabel.bounds.size.width-60, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
    [friendBtn setTitle:@"we chat" forState:UIControlStateNormal];
    [friendBtn addTarget:self action:@selector(friendClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareAllView addSubview:friendBtn];
    
    UIButton *momentsBtn = [[UIButton alloc]init];
    momentsBtn.frame = CGRectMake(KScreenWidth/2-60, 10, 60, 80);
    [momentsBtn setImage:[UIImage imageNamed:@"moments"] forState:UIControlStateNormal];
    momentsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    momentsBtn.titleLabel.font = [UIFont systemFontOfSize:14];//title字体大小
    [momentsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    [momentsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
    momentsBtn.titleEdgeInsets = UIEdgeInsetsMake(71, momentsBtn.titleLabel.bounds.size.width-60, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
    [momentsBtn setTitle:@"moments" forState:UIControlStateNormal];
    [momentsBtn addTarget:self action:@selector(momentsClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareAllView addSubview:momentsBtn];
    
    UIButton *smsBtn = [[UIButton alloc]init];
    smsBtn.frame = CGRectMake(KScreenWidth/2+KScreenWidth/4-60, 10, 60, 80);
    [smsBtn setImage:[UIImage imageNamed:@"SMS"] forState:UIControlStateNormal];
    smsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    smsBtn.titleLabel.font = [UIFont systemFontOfSize:14];//title字体大小
    [smsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    [smsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
    smsBtn.titleEdgeInsets = UIEdgeInsetsMake(71, smsBtn.titleLabel.bounds.size.width-60, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
    [smsBtn setTitle:@"sms" forState:UIControlStateNormal];
    [smsBtn addTarget:self action:@selector(smsClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareAllView addSubview:smsBtn];
    
    UIButton *safariBtn = [[UIButton alloc]init];
    safariBtn.frame = CGRectMake(KScreenWidth-60, 10, 60, 80);
    [safariBtn setImage:[UIImage imageNamed:@"safari"] forState:UIControlStateNormal];
    safariBtn.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    safariBtn.titleLabel.font = [UIFont systemFontOfSize:14];//title字体大小
    [safariBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    [safariBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
    safariBtn.titleEdgeInsets = UIEdgeInsetsMake(71, safariBtn.titleLabel.bounds.size.width-60, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
    [safariBtn setTitle:@"safari" forState:UIControlStateNormal];
    [safariBtn addTarget:self action:@selector(safariClick) forControlEvents:UIControlEventTouchUpInside];
    [_shareAllView addSubview:safariBtn];
}
-(void)editShareClick
{
    [_backgroundViewControl removeFromSuperview];
    _backgroundViewControl = nil;
}
-(void)cancelClick
{
    [UIView animateWithDuration:.25 animations:^{
        
        _shareAllView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 150);
        
    } completion:^(BOOL finished) {
        NSLog(@"动画完事调用的BLOCK");
    }];
}
-(void)friendClick
{
        if (_finalProductUrlStr == nil) {
            NSLog(@"失败");
            NSString *title = NSLocalizedString(@"message", nil);
            NSString *message = NSLocalizedString(@"You must submit before share.", nil);
            NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }];
    
            [alertController addAction:otherAction];
    
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            if ([WXApi isWXAppInstalled]) {
                //判断是否有微信
                //        [_delegate changeScene:WXSceneSession];
    
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = @"Share";
                message.description = _showSummaryNameStr;
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
            [self editShareClick];
            [UIView animateWithDuration:.25 animations:^{
                
                _shareAllView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 150);
                
            } completion:^(BOOL finished) {
                NSLog(@"动画完事调用的BLOCK");
            }];
        }
}
-(void)momentsClick
{
    if (_finalProductUrlStr == nil) {
        NSString *title = NSLocalizedString(@"message", nil);
        NSString *message = NSLocalizedString(@"You must submit before share.", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        if ([WXApi isWXAppInstalled]) {
            //分享文本到朋友圈
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"Share";
            message.description = _showSummaryNameStr;
            [message setThumbImage:[UIImage imageNamed:@"sharewechat@2x.png"]];
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = _finalProductUrlStr;
            
            message.mediaObject = ext;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            //  根据scene来判断是分享朋友圈还是聊天对话
            req.scene = 1;
            
            [WXApi sendReq:req];
        }else{
            
            NSString *weiXinLink = [WXApi getWXAppInstallUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
            
        }
        [self editShareClick];
        [UIView animateWithDuration:.25 animations:^{
            
            _shareAllView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 150);
            
        } completion:^(BOOL finished) {
            NSLog(@"动画完事调用的BLOCK");
        }];
    }
}
-(void)smsClick
{
    if (_finalProductUrlStr == nil) {
        
    }
}
-(void)safariClick
{
    if (_finalProductUrlStr == nil) {
        NSString *title = NSLocalizedString(@"message", nil);
        NSString *message = NSLocalizedString(@"You must submit before share.", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        }];
        
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        NSURL *url = [[NSURL alloc]initWithString:_finalProductUrlStr];
        [[UIApplication sharedApplication]openURL:url];
        [self editShareClick];
        [UIView animateWithDuration:.25 animations:^{
            
            _shareAllView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 150);
            
        } completion:^(BOOL finished) {
            NSLog(@"动画完事调用的BLOCK");
        }];
    }
    
}
 -(void)copyStatus:(BOOL)flag{
     if (flag) {
         NSString *title = NSLocalizedString(@"", nil);
         NSString *successMessage = NSLocalizedString(@"Copied successfully. Do you want to back home page or stay here?", nil);
         NSString *stayTitle = NSLocalizedString(@"Stay", nil);
         NSString *backTitle = NSLocalizedString(@"Back", nil);
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:successMessage preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:backTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
             self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
             [self.navigationController popToRootViewControllerAnimated:YES];
         }];
         UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:stayTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                     }];
         [alertController addAction:cancelAction];
         [alertController addAction:deleteAction];
         [self presentViewController:alertController animated:YES completion:nil];
         
     }else{
         NSString *title = NSLocalizedString(@"", nil);
         NSString *unsuccessMessage = NSLocalizedString(@"Copied successfully. Do you want to back home page or stay here?", nil);
         NSString *stayTitle = NSLocalizedString(@"Stay", nil);
         NSString *backTitle = NSLocalizedString(@"Back", nil);
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:unsuccessMessage preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:backTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
             self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
             [self.navigationController popToRootViewControllerAnimated:YES];
             
         }];
         UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:stayTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             
             
         }];
         [alertController addAction:cancelAction];
         [alertController addAction:deleteAction];
         [self presentViewController:alertController animated:YES completion:nil];
     }
 }


#pragma delete current page from UIWebView
-(void)deleteClick{
    
    if (self.detailsListMuArray.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""    message:@"There are no page to delete." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        NSString *title = NSLocalizedString(@"Please confirm", nil);
        NSString *message = NSLocalizedString(@"Do you want to delete?", nil);
        NSString *deleteTitle = NSLocalizedString(@"Delete", nil);
        NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self deleteCurrentPageFromUIWebView];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    
}
#pragma delete page function
-(void)deleteCurrentPageFromUIWebView{
    
        int iPageNumber = [self getUIWebViewPageNumber];
        NSString *pageNumber = [NSString stringWithFormat:@"%ld", (long)iPageNumber];
        
        [DBDaoHelper deleteCurrentPageByPageNumber:pageNumber
                                         SummaryId:self.showSummaryIdStr];
        
        self.maxPageNumber = [DBDaoHelper getMaxPageNumber:self.showSummaryIdStr];
       
        NSLog(@"Current page number is:%@",pageNumber);
        NSLog(@"Max page number is:%@",self.maxPageNumber);
        
        if([self.currentPageNumber isEqualToString:self.maxPageNumber]){
             iPageNumber --;
            self.currentPageNumber = [NSString stringWithFormat:@"%ld",(long)iPageNumber];
            
            // change page number --
            [self changePageNumberOfWebView:false];
        }
        [self loadDetailsDataToArray];
        [self generationFinalHtmlCode];
        [self initDataForAction];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [self.webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
    
        //[self.webView reload];
//        [self setWebViewPosition:self.currentPageNumber];
    
}

#pragma get html code from webview
-(NSString *)getHtmlFromUIWebView{
    //native  call js 代码
    NSString *jsToGetHtmlSource =  @"document.getElementsByTagName('html')[0].innerHTML";
    NSString *htmlSource = @"<!DOCTYPE html><html>";
    htmlSource = [htmlSource stringByAppendingString: [self.webView stringByEvaluatingJavaScriptFromString:jsToGetHtmlSource]];
    htmlSource = [htmlSource stringByAppendingString:@"</html>"];
    [self getUIWebViewPageNumber];
    return htmlSource;
}

#pragma get current page number from UIWebView
-(int)getUIWebViewPageNumber{
    NSString *pageNumberJS = @"document.getElementById('numOfPage').value";
    NSString *pageNumberString =
            [self.webView stringByEvaluatingJavaScriptFromString:pageNumberJS];
    self.currentPageNumber = pageNumberString;
    int pageNumber = [pageNumberString intValue];
    return pageNumber;
}

#pragma reset the page number of UIWebView, pageNumber ++ OR --
-(void)changePageNumberOfWebView:(BOOL)isAddOrSub{
    int pageNumber = [self getUIWebViewPageNumber];
    if (isAddOrSub) {
        pageNumber ++;
    }else{
        pageNumber --;
    }
    
    NSString *pageNumberStr = [NSString stringWithFormat:@"%ld",(long)pageNumber];

    NSString *jsCode = @"document.getElementById('numOfPage').value = ";
    jsCode = [jsCode stringByAppendingString:pageNumberStr];
    jsCode = [jsCode stringByAppendingString:@";"];
 
    [self.webView stringByEvaluatingJavaScriptFromString:jsCode];
}

#pragma set position of webview section
-(void)setWebViewPosition:(NSString *)pageNumber{
    NSString *jsCode = @"initSwiper(";
    jsCode = [jsCode stringByAppendingString:pageNumber];
    jsCode = [jsCode stringByAppendingString:@");"];
    jsCode = [jsCode stringByAppendingString:@"document.getElementById('numOfPage').value ="];
    jsCode = [jsCode stringByAppendingString:pageNumber];
    
    [self.webView stringByEvaluatingJavaScriptFromString:jsCode];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self setWebViewPosition:self.currentPageNumber];
     NSLog(@"webview did finish load current page is: %@",self.currentPageNumber);
}

-(void)addPageClick{
    [self getUIWebViewPageNumber];
    
    SelectTemplateForEditViewController *selectVC = [[SelectTemplateForEditViewController alloc]init];
    selectVC.showSummaryIdStr = self.showSummaryIdStr;
    selectVC.currentPageNumber = self.currentPageNumber;
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:selectVC];
    
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma get current section html code 
-(NSString *)getSectionFromWebView{
    NSString *allHtml = [self getHtmlFromUIWebView];
    
    //-substringFromIndex: 以指定位置开始（包括指定位置的字符），并包括之后的全部字符
    NSRange rangeStartSection = [allHtml rangeOfString:@"swiper-slide-active"];
    NSInteger startLocation = rangeStartSection.location;
    NSString *stringStart = [allHtml substringFromIndex:startLocation+19];
   
    //-substringToIndex: 从字符串的开头一直截取到指定的位置，但不包括该位置的字符 +10表示包括</section>
    NSRange rangeEndSection = [stringStart rangeOfString:@"</section>"];
    NSInteger endLocation = rangeEndSection.location;
    NSString *stringEnd = [stringStart substringToIndex:endLocation+10];
    
    NSString *tmpHtmlCode = @"<section class='swiper-slide swiper-slide";
    tmpHtmlCode = [tmpHtmlCode stringByAppendingString:stringEnd];
    NSString *finalHtmlCode = [tmpHtmlCode stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    return finalHtmlCode;
}

// generation one details html code
-(NSString *)generationOneDetailsCode:(NSString *)detailsCode{
    // get html code from start location, until this location
    NSRange rangeStartSection = [detailsCode rangeOfString:@"<section "];
    NSInteger startLocation = rangeStartSection.location;
    NSString *beforeString = [detailsCode substringWithRange:NSMakeRange(0, startLocation)];
    
    // get html code from set location until end.
    NSRange rangeEndSection = [detailsCode rangeOfString:@"</section>"];
    NSInteger endLocation = rangeEndSection.location;
    NSString *afterString = [detailsCode substringFromIndex:endLocation+10];
    
    NSString *detailHtmlCode = beforeString;
    detailHtmlCode = [detailHtmlCode stringByAppendingString:[self getSectionFromWebView]];
    detailHtmlCode = [detailHtmlCode stringByAppendingString:afterString];
    
    return detailHtmlCode;
}





// select template notification
-(void)getTemplateNotification:(NSNotification *)sender{
    if ([sender.name isEqual:@"SelectedTemplate"])
    {
        [self loadDetailsDataToArray];
        [self generationFinalHtmlCode];
        [self initDataForAction];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [self.webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
        
        self.maxPageNumber = [DBDaoHelper getMaxPageNumber:self.showSummaryIdStr];
        self.currentPageNumber = sender.object;
        
        [self setWebViewPosition:self.currentPageNumber];
        NSLog(@"current page is: %@",self.currentPageNumber);
        
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)editCurrentPage{
    [self getUIWebViewPageNumber];
    EditCurrentPageViewController *editCPVC = [[EditCurrentPageViewController alloc]init];
    editCPVC.currentPageNumber = self.currentPageNumber;
    editCPVC.summaryId = self.showSummaryIdStr;
    editCPVC.navigationTitle = self.showSummaryNameStr;
    
    DetailsModel *dm = [[DetailsModel alloc]init];
    dm = [self.detailsListMuArray objectAtIndex:[self getUIWebViewPageNumber]];
    editCPVC.pptDetailsID = dm.detailsIdStr;
    
    [self.navigationController pushViewController:editCPVC animated:YES];
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
