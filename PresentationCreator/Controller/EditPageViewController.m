//
//  EditPageViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 15/12/7.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "EditPageViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <AVFoundation/AVFoundation.h>
#import "KxMenu.h"
#import "AddPageViewController.h"
#import "PECropViewController.h"
#import "AudioListViewController.h"

@interface EditPageViewController ()<UIWebViewDelegate,UIScrollViewDelegate,UITextViewDelegate>
@property (nonatomic, strong) NSMutableArray *detailsArray;//获取details表对象
@property (nonatomic, strong) NSMutableArray *htmlCodeArray;//html代码数组

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSString *oldText;
@property (nonatomic) NSString *getText;
@property (nonatomic, strong) NSString *txtIndex;
@property (nonatomic, strong) UIButton *buttonMark;
@property (nonatomic, strong) UITextView *txtView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *htmlSource;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;

// image use
@property (nonatomic, strong) NSString *imgIndex;
@property (nonatomic ,strong) NSString *fullPath;


@property (nonatomic, strong) UIControl *editTextViewControl;
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

@end

@implementation EditPageViewController


-(void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAudioNameFromList:) name:@"SelectedAudioName" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTemplateNotification:) name:@"SelectedTemplate" object:nil];
    [self loadDetailsToArray];
    
     [self addObserverWithKeyboard];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _fullPath = [[NSString alloc]init];
    _audioPath = [[NSString alloc]init];
   
   
    
    self.parentViewController.tabBarController.tabBar.hidden = YES;
    //    self.navigationItem.hidesBackButton =YES;//隐藏系统自带导航栏按钮
    self.navigationItem.title=self.showSummaryNameStr;
    self.htmlCodeArray = [[NSMutableArray alloc]init];
    
    _detailsArray = [[NSMutableArray alloc]init];
    [self loadDetailsToArray];
    _currentPage = _detailsArray.count-1;
    _totalPage = _detailsArray.count;
    
    [self addNavigation];
    [self initPageControl];
    [self initScrollView];
   
    [self setAudioSession];
    
    //音量图片数组
    _volumImages = [[NSMutableArray alloc]initWithObjects:@"RecordingSignal001.png",@"RecordingSignal002.png",
                    @"RecordingSignal003.png", @"RecordingSignal004.png",
                    @"RecordingSignal005.png",@"RecordingSignal006.png",
                    @"RecordingSignal007.png",@"RecordingSignal008.png",   nil];
    
    self.view.backgroundColor = [UIColor grayColor];
}

-(void)loadDetailsToArray{
    
   _detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:_showSummaryIdStr]; 
    NSLog(@"loadDetailsToArray count:::%ld",(long)_detailsArray.count);
    
}



#pragma -------------- init scroll view ----------------
-(void)initScrollView{
    // 设定 ScrollView 的   Frame，逐页滚动时，如果横向滚动，按宽度为一个单位滚动，纵向时，按高度为一个单位滚动
    _scrollView = nil;
    CGRect bound = [[UIScreen mainScreen]bounds];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, bound.size.width, bound.size.height-4)];
    
    int boundWidth = bound.size.width - 20;
    NSInteger uiViewHeight = bound.size.height -60 -35 ;
    //    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled =  YES;
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    // ScrollView 背景色，即 View 间的填充色
    //向 ScrollView 中加入第一个 View，View 的宽度 200 加上两边的空隙 5 等于 ScrollView 的宽度
    
    for (int i = 0; i < _detailsArray.count; i++) {
        int numX = 10 + (boundWidth + 20) * i;
        UIWebView *webView = [[UIWebView  alloc] initWithFrame:CGRectMake(numX,8,boundWidth,uiViewHeight)];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        DetailsModel *detail = [[DetailsModel alloc]init];
        detail = _detailsArray[i];
        //        webView.tag = (long)detail.detailsIdStr;
        [webView loadHTMLString:detail.htmlCodeStr baseURL:baseURL];
        
        webView.delegate = self;
        
        
        [self loadHtmlToWebView:webView];
        
        webView.backgroundColor = [UIColor purpleColor];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        deleteBtn.frame = CGRectMake(numX-10, 0, 25, 25);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deletePage) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:webView];
        [_scrollView addSubview:deleteBtn];
        [_scrollView bringSubviewToFront:deleteBtn];
        webView = nil;
    }
    
    [self.view addSubview:_scrollView];
    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
    //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
    _scrollView.contentSize = CGSizeMake(10 + (boundWidth  + 20 ) * _totalPage, 100);
    
    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    _scrollView.contentOffset = CGPointMake((boundWidth + 20) * (_detailsArray.count-2),0);
    //按页滚动，总是一次一个宽度，或一个高度单位的滚动
    
    _scrollView.showsHorizontalScrollIndicator = NO;
}

-(void)deletePage{
    NSString *title = NSLocalizedString(@"Please confirm", nil);
    NSString *message = NSLocalizedString(@"Do you want to delete?", nil);
    NSString *cancelTitle = NSLocalizedString(@"Delete", nil);
    NSString *deleteTitle = NSLocalizedString(@"Cancel", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        DetailsModel *dModel = [_detailsArray objectAtIndex:_currentPage];
        [DBDaoHelper deleteDetailsWithsql:dModel.detailsIdStr];
        [self loadDetailsToArray];
        
        UIWebView *currentWebView = _scrollView.subviews[_currentPage];
        [currentWebView removeFromSuperview];
        currentWebView = nil;
        
        _totalPage --;
        _currentPage--;
        
        [self initScrollView];
        
        _pageControl.currentPage = _currentPage;
        _pageControl.numberOfPages = _totalPage;
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma --------------------- uiscrollview -------------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    offsetX = offsetX +(scrollView.frame.size.width * 0.5);
    int pageNumber = offsetX / scrollView.frame.size.width;
    _currentPage = pageNumber;
    _pageControl.currentPage = pageNumber;
    NSLog(@"current page is---%ld",(long)pageNumber);
}

#pragma ------------------- init page control -------------------

-(void)initPageControl{
    //    if(!_pageControl){
    [_pageControl removeFromSuperview];
    _pageControl = nil;
    _pageControl = [[UIPageControl alloc]init];
    _pageControl.center = CGPointMake(self.view.frame.size.width/2, 73);
    _pageControl.numberOfPages = _totalPage;
    _pageControl.currentPage = _totalPage;
    [self.view addSubview:_pageControl];
    //    }
    
}

#pragma ------------------- load navigation ------------------------
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

#pragma edit text


-(void)loadHtmlToWebView:(UIWebView *)myWebView{
    
    JSContext *context = [myWebView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
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
       // [self editImageComponent:_fullPath :_imgIndex];
        //加载本地图片到webview,把图片的索引传给方法
        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
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
        self.mTextView.delegate = self;
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
    UIWebView *currentWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
    currentWebView.delegate = self;
    
    [currentWebView stringByEvaluatingJavaScriptFromString:str];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You added new line sucessfully, do you want to stay here or exit?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Stay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        self.navigationController.navigationBarHidden = NO;
        //        [self getHtmlCodeClick];//获取webview中section里的heml代码
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
        
        UIWebView *currentWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
        currentWebView.delegate = self;
        [currentWebView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        self.navigationController.navigationBarHidden = NO;
        //
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
        
        UIWebView *currentWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
        currentWebView.delegate = self;
        
        [currentWebView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        [self getHtmlCodeClick];//获取webview中section里的heml代码
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


#pragma -------------------  show right top menu -----------------------
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Save"
                     image:nil
                    target:self
                    action:@selector(saveClick)],
      
      [KxMenuItem menuItem:@"Add Page"
                     image:nil
                    target:self
                    action:@selector(addPageClick)],
      
      [KxMenuItem menuItem:@"Audio List"
                     image:nil
                    target:self
                    action:@selector(openAudioList)],
      
      [KxMenuItem menuItem:@"Recording"
                     image:nil
                    target:self
                    action:@selector(talkClick)],
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
}



-(void)backClick
{
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)talkClick
{
    //    if (_audioButton.hidden == YES) {
    //        _audioButton.hidden = NO;
    //    }else{
    //        _audioButton.hidden = YES;
    //    }
    [self addAudioBtn];
}

-(void)addPageClick
{
    //模态跳转
    AddPageViewController *loginVC = [[AddPageViewController alloc]init];
    loginVC.showSummaryIdStr = self.showSummaryIdStr;
    
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    [self presentViewController:navigation animated:YES completion:nil];
    
}


#pragma -保存生成的html代码写入到summary表中
-(void)saveClick
{
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
    NSString *title = NSLocalizedString(@"Successfully", nil);
    //    NSString *message = NSLocalizedString(@"Upload successfully.", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController removeFromParentViewController];
        
    }];
    
    [alertController addAction:otherAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
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
    NSString *htmlC = final_html_befor_section;
    htmlC = [htmlC stringByAppendingString:_stringSections];
    htmlC = [htmlC stringByAppendingString:final_html_after_section];
    
    BOOL sts = [DBDaoHelper updateSummaryContentById : htmlC : self.showSummaryIdStr];
    _finalHtmlCode = htmlC;
    
    if (sts) {
        NSString *statusPro = [DBDaoHelper queryProductStatusBySummaryId:_showSummaryIdStr];
        if ([statusPro isEqualToString:@"Published"]) {
            [DBDaoHelper updateSummaryStatsDateTimeBySummaryId:_showSummaryIdStr SummaryStatus:@"Updated"];
        }
    }
}




#pragma edit image function ----------------

//更改图片
-(void)editImageComponent:(NSString *)imgName : (NSString *)index{

    //拼接js字符串，用于替换图片
    NSString *str = @"var field = document.getElementsByClassName('img_element')[";
    str = [str stringByAppendingString:index];
    str = [str stringByAppendingString:@"];"];
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:imgName];
    str = [str stringByAppendingString:@"';"];

//    UIWebView *imgWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
//    imgWebView.delegate = self;

    UIWebView *currentWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
    currentWebView.delegate = self;
    [currentWebView stringByEvaluatingJavaScriptFromString:str];//js字符串通过这个方法传递到webview中的html并执行此js
    [self getHtmlCodeClick];
}


//获取webview中section里的heml代码
- (void)getHtmlCodeClick {
    //native  call js 代码
    UIWebView *aWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
    aWebView.delegate = self;

    NSString *jsToGetHtmlSource =  @"document.getElementsByTagName('html')[0].innerHTML";
    //    NSString *htmlSource = @"<section class='swiper-slide swiper-slide2'>";//slide2需要拼接获取正确的索引值
    _htmlSource = @"<!DOCTYPE html><html>";
    _htmlSource = [_htmlSource stringByAppendingString: [aWebView stringByEvaluatingJavaScriptFromString:jsToGetHtmlSource]];
    _htmlSource = [_htmlSource stringByAppendingString:@"</html>"];
    //根据summaryid 和templateid查询数据库更换html_code
    //在details表中 根据detailsid 修改html代码

    DetailsModel *dModel = [[DetailsModel alloc]init];
    dModel = [_detailsArray objectAtIndex:_currentPage];
    [DBDaoHelper updateDetailsIdWith:dModel.detailsIdStr htmlCode:_htmlSource];

}

//选择图片
-(void)backgroundClick
{
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
    dModel = [_detailsArray objectAtIndex:_currentPage];

    [DBDaoHelper insertFilePathToDetails_idWith:dModel.detailsIdStr summary_id:_showSummaryIdStr file_type:@"image" file_path:_fullPath ];
    [self editImageComponent : imageFullName : _imgIndex];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark --------------------------- addAudio ----------------------
//点击录音按钮，弹出录音画面
-(void)addAudioBtn{
    
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
    //模态跳转
    AudioListViewController *audioListVC = [[AudioListViewController alloc]init];
    //loginVC.showSummaryIdStr = self.showSummaryIdStr;
    DetailsModel *dom = [[DetailsModel alloc]init];
    dom = [_detailsArray objectAtIndex:_currentPage];
    
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
    NSString *str = @"var imgAudio = document.getElementsByClassName('audioCtrl')[0]; imgAudio.className='';imgAudio.className='audioCtrl'; var field = document.getElementsByTagName('audio')[0];";
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:_audioPath];
    str = [str stringByAppendingString:@"'; "];
    
    
    UIWebView *audioWebView = [[_scrollView subviews] objectAtIndex:_currentPage*2];
    
    audioWebView.delegate = self;
    
    [audioWebView stringByEvaluatingJavaScriptFromString:str];
    
    [self getHtmlCodeClick];
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
        [self.audioPlayer play];
        //将detailsid summaryid filetype filepath插入数据库
        DetailsModel *dmm = [[DetailsModel alloc]init];
        dmm = [_detailsArray objectAtIndex:_currentPage];
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

-(void)getTemplateNotification:(NSNotification *)sender{
    if ([sender.name isEqual:@"SelectedTemplate"])
    {
        
        [self loadDetailsToArray];
        _currentPage = _detailsArray.count-1;
        _totalPage = _detailsArray.count;
        [self initPageControl];
        [self initScrollView];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
}



#pragma mark- 自定义键盘
#pragma mark - 给键盘添加观察者
-(void)addObserverWithKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
#pragma mark - 键盘的通知响应事件
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
