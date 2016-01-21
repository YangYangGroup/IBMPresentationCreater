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
#import "AudioListViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ShowViewController ()<UIWebViewDelegate>
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

//edit text
@property (nonatomic, strong) UIControl *editTextViewControl;
@property (nonatomic) NSString *oldText;
@property (nonatomic) NSString *getText;
@property (nonatomic, strong) NSString *txtIndex;
@property (nonatomic, strong) UIButton *buttonMark;
@property (nonatomic, strong) UITextView *txtView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSString *htmlSource;
@property (nonatomic, strong) UILabel *titleLabel;

// 自定义键盘
@property (nonatomic, strong) UITextView *myTextView;
@property (nonatomic, strong) UIView *textBackgroundView;
@property (nonatomic, strong) UIButton *addLineBtn;
@property (nonatomic, strong) UIButton *deleteLineBtn;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic,strong)UITextView * mTextView;
@property (nonatomic,strong)UIView *mBackView;
@property (nonatomic, strong) NSString *oldTextHtml;
@property (nonatomic, strong) NSString *textIndex;
@property (nonatomic, strong) NSString *currentText;

// image use
@property (nonatomic, strong) NSString *imgIndex;
@property (nonatomic ,strong) NSString *fullPath;

// audio use

@property (nonatomic, strong) UIControl *aduioViewControl;
@property (nonatomic) BOOL buttonFlag;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, copy)   NSString *audioPath;
@property (nonatomic, strong) NSString *audioName;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic, strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic, strong) UIProgressView *audioPower;//音频波动
@property (nonatomic, strong) UIImageView *soundLodingImageView;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, strong) UIView *audioView;
@property (nonatomic, strong) NSString *selectedAudioName;
@property (nonatomic, strong) NSMutableArray *volumImages;
@property (nonatomic, assign) double lowPassResults;


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAudioNameFromList:) name:@"SelectedAudioName" object:nil];
    
    [self addObserverWithKeyboard];
    
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
    _fullPath = [[NSString alloc]init];
    _audioPath = [[NSString alloc]init];
   
    [self setAudioSession];
    //音量图片数组
    _volumImages = [[NSMutableArray alloc]initWithObjects:@"RecordingSignal001.png",@"RecordingSignal002.png",
                    @"RecordingSignal003.png", @"RecordingSignal004.png",
                    @"RecordingSignal005.png",@"RecordingSignal006.png",
                    @"RecordingSignal007.png",@"RecordingSignal008.png",   nil];
    
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
    _webView.backgroundColor = [UIColor redColor];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
    [self.view addSubview: _webView];
    
    [self loadHtmlToWebView];
    
 
}

-(void)loadHtmlToWebView{
   
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        
//        [self setWebViewPosition:self.currentPageNumber];
        
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSLog(@"input myStr:%@", args[0]);
        NSLog(@"input myStr index:%@", args[1]);
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        NSString *editFlag =[[NSString alloc]initWithFormat:@"%@",args[2]];
        NSLog(@"editFlag:%@", editFlag);
        _oldTextHtml = htmlVal;
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        [self editTextComponent:htmlVal htmlIndex:htmlIndex editFlag:editFlag];
        
        //        });

        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
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
                      
                      [KxMenuItem menuItem:@"Audio List"
                                     image:nil
                                    target:self
                                    action:@selector(openAudioList)],
                      
                      [KxMenuItem menuItem:@"Recording"
                                     image:nil
                                    target:self
                                    action:@selector(talkClick)],
                      
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
                      
                      [KxMenuItem menuItem:@"Audio List"
                                     image:nil
                                    target:self
                                    action:@selector(openAudioList)],
                      
                      [KxMenuItem menuItem:@"Recording"
                                     image:nil
                                    target:self
                                    action:@selector(talkClick)],
                      
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
        
        //newName should be save.
        NSString *smID = [DBDaoHelper copySummaryData:newName ContentHtml:_finalHtmlCode Status:_sumyModel.status];
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
        [self loadHtmlToWebView];
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
        [self loadHtmlToWebView];
        
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


#pragma mark- 自定义键盘
#pragma mark - 给键盘添加观察者
-(void)addObserverWithKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

//系统键盘将要出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
}
//系统键盘将要消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.mBackView.frame = CGRectMake(0, KScreenHeight+100, KScreenWidth, 100);
    }];
}
#pragma mark - 移动view
-(void)moveInputBarWithKeyboardHeight:(float)_CGRectHeight withDuration:(NSTimeInterval)_NSTimeInterval
{
    [UIView animateWithDuration:(_NSTimeInterval) animations:^{
        self.mBackView.frame = CGRectMake(0, KScreenHeight-_CGRectHeight-120, KScreenWidth, 100);
        
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}




#pragma ------------------- edit text function ------------------------

-(void)editTextClick
{
    [_editTextViewControl removeFromSuperview];
    _editTextViewControl = nil;
}

//修改文字的时候
-(void)editTextComponent:(NSString *)htmlVal  htmlIndex:(NSString *)htmlIndex editFlag:(NSString *)editFlag{
    //    self.navigationController.navigationBarHidden=YES;
    
    _editTextViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, KScreenHeight+5)];
    _editTextViewControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_editTextViewControl];
    
    UIView *backgroundView = [[UIView alloc]init];
    //    backgroundView.hidden = YES;
    backgroundView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    //        backgroundView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editTextClick)];
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [_editTextViewControl addSubview:backgroundView];
    
    self.mBackView =[[UIView alloc]initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 100)];
    self.mBackView.backgroundColor =[UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    [backgroundView addSubview:self.mBackView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTextView =[[UITextView alloc]initWithFrame:CGRectMake(1, 5, KScreenWidth-75, 90)];
        self.mTextView.backgroundColor =[UIColor whiteColor];
        [self.mTextView becomeFirstResponder];
        NSString *textStr = [htmlVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.mTextView.text = textStr;
        self.mTextView.layer.borderWidth = 1;
        self.mTextView.layer.cornerRadius = 5;
        self.mTextView.layer.borderColor = [UIColor grayColor].CGColor;
        [self.mBackView addSubview:self.mTextView];
    });
    
    UIButton *mTalkBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mTalkBtn setTitle:@"OK" forState:UIControlStateNormal];
    [mTalkBtn addTarget:self action:@selector(saveTextData) forControlEvents:UIControlEventTouchUpInside];
    [mTalkBtn setTintColor:[UIColor blackColor]];
    _textIndex = htmlIndex;
    mTalkBtn.backgroundColor = [UIColor whiteColor];
    mTalkBtn.layer.borderWidth = 1;
    mTalkBtn.layer.cornerRadius = 5;
    mTalkBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [self.mBackView addSubview:mTalkBtn];
    
    _addLineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _addLineBtn.frame = CGRectMake(KScreenWidth-60, 38, 50, 28);
    [_addLineBtn setTitle:@"New" forState:UIControlStateNormal];
    [_addLineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _addLineBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_addLineBtn addTarget:self action:@selector(newLineFunction) forControlEvents:UIControlEventTouchUpInside];
    _addLineBtn.backgroundColor = [UIColor whiteColor];
    _addLineBtn.layer.borderWidth = 1;
    _addLineBtn.layer.cornerRadius = 5;
    _addLineBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [self.mBackView addSubview:_addLineBtn];
    
    _deleteLineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _deleteLineBtn.frame = CGRectMake(KScreenWidth-60, 70, 50, 28);
    [_deleteLineBtn setTitle:@"Del" forState:UIControlStateNormal];
    [_deleteLineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _deleteLineBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _deleteLineBtn.backgroundColor = [UIColor whiteColor];
    _deleteLineBtn.layer.borderWidth = 1;
    _deleteLineBtn.layer.cornerRadius = 5;
    _deleteLineBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [_deleteLineBtn addTarget:self action:@selector(deleteFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.mBackView addSubview:_deleteLineBtn];
    
    //如果不可以加行
    if([editFlag isEqualToString:@"false"]){
        _deleteLineBtn.hidden = YES;
        _addLineBtn.hidden = YES;
        mTalkBtn.frame =CGRectMake(KScreenWidth-60, 30, 50, 28);
        [_addLineBtn setEnabled:NO];
        [_deleteLineBtn setEnabled:NO];
    }else{
        mTalkBtn.frame =CGRectMake(KScreenWidth-60, 5, 50, 28);
        _deleteLineBtn.backgroundColor = [UIColor whiteColor] ;
        _addLineBtn.backgroundColor = [UIColor whiteColor] ;
        [_addLineBtn setEnabled:YES];
        [_deleteLineBtn setEnabled:YES];
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.mTextView resignFirstResponder];
    return YES;
}
-(void)newLineFunction{
    NSString *str = @"addListItem('";
    str = [str stringByAppendingString:_textIndex];
    str = [str stringByAppendingString:@"');"];
    NSLog(@"add new line javascript:%@",str);
    
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    //get html code from webview and update ppt summary table
    [self getHTMLAndUpdateSummary];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You added new line sucessfully, do you want to stay here or exit?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Stay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        self.navigationController.navigationBarHidden = NO;
        
        
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    [self cancelFunction];
}
-(void)deleteFunction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delele current line" message:@"This action can not undo. do you want to delete this line? " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *str = @"deleteCurrentLine('";
        str = [str stringByAppendingString:_textIndex];
        str = [str stringByAppendingString:@"');"];
        
        [self.webView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        self.navigationController.navigationBarHidden = NO;
        
        //get html code from webview and update ppt summary table
        [self getHTMLAndUpdateSummary];
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
    [self cancelFunction];
}
-(void)cancelFunction{
    self.navigationController.navigationBarHidden = NO;
    [_editTextViewControl removeFromSuperview];
    _editTextViewControl = nil;
}

-(void)saveTextData{
    self.navigationController.navigationBarHidden = NO;
    
    NSString *temp = [_mTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //看剩下的字符串的长度是否为零
    if ([temp length]!=0) {
        _currentText = _mTextView.text;
        NSString *str = @"var field = document.getElementsByClassName('text_element')[";
        str = [str stringByAppendingString:_textIndex];
        str = [str stringByAppendingString:@"];"];
        str = [str stringByAppendingString:@" field.innerHTML='"];
        str = [str stringByAppendingString:_mTextView.text];
        str = [str stringByAppendingString:@"';"];
        
        [self.webView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        
        //get html code from webview and update ppt summary table
        [self getHTMLAndUpdateSummary];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Content is not null." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show ];
        
    }
}
-(void)removeTextEditComponent{
    [_buttonMark removeFromSuperview];
    _buttonMark = nil;
    [_txtView removeFromSuperview];
    _txtView = nil;
    [_okButton removeFromSuperview];
    _okButton = nil;
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    [_cancelButton removeFromSuperview];
    _cancelButton = nil;
    self.navigationController.navigationBar.hidden = NO;
}

-(void)updatePPTSummaryHtmlWithHtmlCode:(NSString *)htmlCode{
    [DBDaoHelper updateSummaryContentById:self.showSummaryIdStr HtmlCode:htmlCode];
}
-(void)updateSummaryDetailsWithHtmlCode:(NSString *)htmlCode{
    [DBDaoHelper updateSummaryDetailsBySummaryId:self.showSummaryIdStr PageNumber:self.currentPageNumber HtmlCode:[self generationOneDetailsCode:htmlCode]];
}

-(void)getHTMLAndUpdateSummary{
    [self updatePPTSummaryHtmlWithHtmlCode:[self getHtmlFromUIWebView]];
    
    DetailsModel *dm = [[DetailsModel alloc]init];
    dm = [self.detailsListMuArray objectAtIndex:[self getUIWebViewPageNumber]];
    [self updateSummaryDetailsWithHtmlCode:
    [self generationOneDetailsCode:dm.htmlCodeStr]];
}

#pragma edit image
//更改图片
-(void)editImageComponent:(NSString *)imgName : (NSString *)index{
    
    //拼接js字符串，用于替换图片
    NSString *str = @"var field = document.getElementsByClassName('img_element')[";
    str = [str stringByAppendingString:index];
    str = [str stringByAppendingString:@"];"];
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:imgName];
    str = [str stringByAppendingString:@"';"];
    
   //js字符串通过这个方法传递到webview中的html并执行此js
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    
    [self getHTMLAndUpdateSummary];
 
    [self setWebViewPosition:self.currentPageNumber];
    NSLog(@"current page is: %@",self.currentPageNumber);
}


//选择图片
-(void)backgroundClick
{
    [self getUIWebViewPageNumber];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Photo Album", nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:@"Camera"];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:controller animated:YES completion:^{}];
    
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:controller animated:YES completion:^{}];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Photo Album"]) {
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:@"Camera"]) {
        [self showCamera];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        PECropViewController *controller = [[PECropViewController alloc] init];
        controller.delegate = self;
        controller.image = image;
        
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:navigationController animated:YES completion:NULL];
    }];
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(NSString *)imageFullName
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    _fullPath = imageFullName;
    //将detailsid summaryid filetype filepath插入数据库
    DetailsModel *dModel = [[DetailsModel alloc]init];
    dModel = [self.detailsListMuArray objectAtIndex:[self getUIWebViewPageNumber]];
    
    [DBDaoHelper insertFilePathToDetails_idWith:dModel.detailsIdStr summary_id:_showSummaryIdStr file_type:@"image" file_path:_fullPath ];
    [self editImageComponent : imageFullName : _imgIndex];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark --------------------------- addAudio ----------------------
-(void)talkClick
{
    [self addAudioBtn];
}
//点击录音按钮，弹出录音画面
-(void)addAudioBtn{
    [self getUIWebViewPageNumber];
    _editTextViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _editTextViewControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_editTextViewControl];
    
    UIView *backgroundView = [[UIView alloc]init];
    //    backgroundView.hidden = YES;
    backgroundView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    //        backgroundView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recordClick)];
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [_editTextViewControl addSubview:backgroundView];
    
    
    _audioButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //    _audioButton.hidden = YES;
    _audioButton.frame = CGRectMake( KScreenWidth/2-50, KScreenHeight -150, 100, 100);
    //    [_audioButton setTitle:@"Hold to talk" forState:UIControlStateNormal];
    [_audioButton setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
    _audioButton.layer.masksToBounds = YES;
    _audioButton.layer.borderWidth = 0;
    _audioButton.layer.cornerRadius = 50;
    [_audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_audioButton setBackgroundColor:[UIColor lightGrayColor]];
    
    [_audioButton addTarget:self action:@selector(showAudioView) forControlEvents:UIControlEventTouchDown];
    [_audioButton addTarget:self action:@selector(hideAudioView) forControlEvents:UIControlEventTouchUpInside];
    
    [backgroundView addSubview:_audioButton];
}
-(void)recordClick
{
    [_editTextViewControl removeFromSuperview];
    _editTextViewControl = nil;
}

-(void)openAudioList{
     [self getUIWebViewPageNumber];
    //模态跳转
    AudioListViewController *audioListVC = [[AudioListViewController alloc]init];
    //loginVC.showSummaryIdStr = self.showSummaryIdStr;
    DetailsModel *dom = [[DetailsModel alloc]init];
    dom = [self.detailsListMuArray objectAtIndex:[self getUIWebViewPageNumber]];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:audioListVC];
    audioListVC.audName = _audioPath;
    audioListVC.detailsId = dom.detailsIdStr;
    
    [self presentViewController:navigation animated:YES completion:nil];
    
}

-(void)closeAudioList{
    [_audioView removeFromSuperview];
    _audioView = nil;
    self.navigationController.navigationBar.hidden = NO;
    
    
    [self editAudioComponent];
}

-(void)showAudioView{
    // self.navigationController.navigationBarHidden = YES;
    _aduioViewControl = [[UIControl alloc]initWithFrame:CGRectMake(75, KScreenHeight * 0.5 - 100, self.view.bounds.size.width -150, 150)];
    [_aduioViewControl.layer setMasksToBounds:YES];
    [_aduioViewControl.layer setCornerRadius:8.0];
    _aduioViewControl.backgroundColor = [UIColor lightGrayColor];
    _aduioViewControl.alpha = 0.97;
    _soundLodingImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width -150) * 0.5 -9 , 43, 18, 64)];
    _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:0]];
    
    [_aduioViewControl addSubview:_soundLodingImageView];
    [self.view addSubview:_aduioViewControl];
    [self startRecord];
    // [self.view bringSubviewToFront:_aduioViewControl];
    
    
}
#pragma ------------------- start record ---------------------
-(void)startRecord{
    NSError *error = nil;
    NSDate *date = [NSDate date];
    
    NSTimeInterval sec = [date timeIntervalSince1970];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:sec];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *na =[dateFormatter stringFromDate:epochNSDate];
    
    _audioName = [[NSString alloc]init];
    _audioName =  [NSString stringWithFormat:@"%@.wav",na];
    //按下录音
    _audioRecorder = [self audioRecorder];
    _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:0]];
    
    //必须真机上测试,模拟器上可能会崩溃
    if (![self.audioRecorder isRecording]) {
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        
        //启动定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
    } else
    {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    
}
-(void)hideAudioView{
    
    [_audioRecorder stop];
    [self editAudioComponent];
    _audioRecorder = nil;
    //结束定时器
    [_timer invalidate];
    _timer = nil;
    //图片重置
    
    [_aduioViewControl removeFromSuperview];
    _aduioViewControl = nil;
    
    
    
}
// 把录好的音频，通过native 代码调用js文件，替换当前的
-(void)editAudioComponent{
    NSString *str = @"var imgAudio = document.getElementsByClassName('audioCtrl')[";
    str = [str stringByAppendingString:self.currentPageNumber];
    str = [str stringByAppendingString:@"];imgAudio.className='';imgAudio.className='audioCtrl'; var field = document.getElementsByTagName('audio')["];
    str = [str stringByAppendingString:self.currentPageNumber];
    str = [str stringByAppendingString:@"]; field.src='"];
    str = [str stringByAppendingString:_audioPath];
    str = [str stringByAppendingString:@"'; "];
    
    [self.webView stringByEvaluatingJavaScriptFromString:str];
    
    [self getHTMLAndUpdateSummary];
    
    [self setWebViewPosition:self.currentPageNumber];
    NSLog(@"current page is: %@",self.currentPageNumber);
}

#pragma mark - 私有方法 - 录音相关方法 -----------------------------
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    
    //    NSString *audioName = [NSString stringWithFormat:@"%d.wav",arc4random() % 1000000];
    //    NSString *audioName1 = @"myAudio.wav";
    _audioPath = [[NSString alloc] init];
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    urlStr=[urlStr stringByAppendingPathComponent:_audioName];
    
    _audioPath = urlStr;
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    //创建录音文件保存路径
    NSURL *url=[self getSavePath];
    if (!_audioRecorder) {
        
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    NSURL *url = [self getSavePath];
    if (!_audioPlayer) {
        
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}


-(void)levelTimer:(NSTimer*)timer_
{
    //call to refresh meter values刷新平均和峰值功率,此计数是以对数刻度计量的,-160表示完全安静，0表示最大输入值
    [_audioRecorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [_audioRecorder peakPowerForChannel:0]));
    _lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * _lowPassResults;
    
    NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [_audioRecorder averagePowerForChannel:0], [_audioRecorder peakPowerForChannel:0], _lowPassResults);
    
    if (_lowPassResults>=0.8) {
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:7]];
    }else if(_lowPassResults>=0.7){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:6]];
    }else if(_lowPassResults>=0.6){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:5]];
    }else if(_lowPassResults>=0.5){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:4]];
    }else if(_lowPassResults>=0.4){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:3]];
    }else if(_lowPassResults>=0.3){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:2]];
    }else if(_lowPassResults>=0.2){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:1]];
    }else if(_lowPassResults>=0.1){
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:0]];
    }else{
        _soundLodingImageView.image = [UIImage imageNamed:[_volumImages objectAtIndex:0]];
    }
    
}


/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    //    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    //    CGFloat progress=(1.0/160.0)*(power+160.0);
    //    [self.audioPower setProgress:progress];
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    _audioPlayer = nil;
    if (![self.audioPlayer isPlaying]) {
        //[self.audioPlayer play];
        //将detailsid summaryid filetype filepath插入数据库
        DetailsModel *dmm = [[DetailsModel alloc]init];
        dmm = [self.detailsListMuArray objectAtIndex:[self getUIWebViewPageNumber]];
        [DBDaoHelper insertFilePathToDetails_idWith:dmm.detailsIdStr summary_id:_showSummaryIdStr file_type:@"audio" file_path:_audioPath];
        dmm =nil;
    }
    NSLog(@"录音完成!");
}

#pragma ----------------- 根据接收的通知更新数据 -----------

-(void)getAudioNameFromList : (NSNotification*)sender{
    if ([sender.name isEqual:@"SelectedAudioName"])
    {
        NSLog(@"%@",sender.object);
        if(sender.object != nil){
            _audioPath = sender.object;
            [self editAudioComponent];
            
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    
    
    
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
