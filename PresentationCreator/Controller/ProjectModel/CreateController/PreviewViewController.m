//
//  PreviewViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/15.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "PreviewViewController.h"
#import "DetailsModel.h"
#import "Global.h"
#import "CreationEditViewController.h"
#import "AFNetworking.h"
#import "FilesModel.h"
#import "LoadingHelper.h"
#import "SBJson.h"
#import "KxMenu.h"

@interface PreviewViewController ()<UIWebViewDelegate>
{
    BOOL returnProductUrl;
}
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;
@property (nonatomic, strong) NSMutableArray *returnFileArray;
@property (nonatomic, strong) NSString *finalProductUrlStr;

@end

@implementation PreviewViewController

-(void)viewWillAppear:(BOOL)animated
{
//    self.tabBarController.viewControllers
    self.parentViewController.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
    //    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
    [self addWebView];
    self.navigationItem.title= self.showSummaryNameStr;
//    self.tabBarController.delegate = self;
}
-(void)addNavigation
{
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushButton.frame=CGRectMake(0, 0, 30, 30);
    [pushButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    pushButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [pushButton addTarget:self action:@selector(showMenu:)forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *pushItem = [[UIBarButtonItem alloc]initWithCustomView:pushButton];
    self.navigationItem.rightBarButtonItem = pushItem;
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Upload"
                     image:nil
                    target:self
                    action:@selector(uploadClick)],
      
      [KxMenuItem menuItem:@"Share"
                     image:nil
                    target:self
                    action:@selector(shareClick)],
      
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
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
    NSString *uploadUrl = @"http://9.115.26.148/PPT/service/UploadServlet";
    
    
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
        returnProductUrl = [DBDaoHelper insertSummaryWithSummaryId:self.showSummaryIdStr productUrl:str];
        _finalProductUrlStr = str;
        //        [LoadingHelper showLoadingWithView:self.view];
        [LoadingHelper hiddonLoadingWithView:self.view];
        NSString *title = NSLocalizedString(@"Upload Successfully", nil);
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
