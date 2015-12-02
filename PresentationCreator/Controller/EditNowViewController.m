//
//  EditNowViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/19.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "EditNowViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "PECropViewController.h"

#import "KxMenu.h"
#import "AudioListViewController.h"

@interface EditNowViewController ()<UIWebViewDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic, strong) NSString *htmlSource;
@property (nonatomic, strong) NSString *imgIndex;
@property (nonatomic, retain) UIImageView *imageView;
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

@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, strong) NSString *imageNameStr;
@property (nonatomic, strong) UIButton *audioButton;

@property (nonatomic, strong) NSString *textIndex;
@property (nonatomic, strong) UITextField *txtField;
@property (nonatomic, strong) NSString *oldTextHtml;
@property (nonatomic) UIPopoverController *popover;

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIView *audioView;
@property (nonatomic, strong) NSString *selectedAudioName;


//图片组
@property (nonatomic, strong) NSMutableArray *volumImages;
@property (nonatomic, assign) double lowPassResults;


@property (nonatomic, strong) UITextView *myTextView;
@property (nonatomic, strong) UIView *textBackgroundView;
@property (nonatomic, strong) UIButton *addLineBtn;
@property (nonatomic, strong) UIButton *deleteLineBtn;

@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation EditNowViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.tabBarController.tabBar.hidden = YES;
    _audioPath = [DBDaoHelper queryAudioPathByDetailsId:_editNowDetailsIdStr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAudioNameFromList:) name:@"SelectedAudioName" object:nil];
   

}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setAudioSession];
    self.navigationItem.title= _editNowSummaryNameStr;
    _fullPath = [[NSString alloc]init];
    _audioPath = [[NSString alloc]init];
    
    [self addNewWebView];
//    [self addAudioBtn];
   
    _buttonFlag = FALSE;
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
    
    //音量图片数组
    _volumImages = [[NSMutableArray alloc]initWithObjects:@"RecordingSignal001.png",@"RecordingSignal002.png",@"RecordingSignal003.png",
                    @"RecordingSignal004.png", @"RecordingSignal005.png",@"RecordingSignal006.png",@"RecordingSignal007.png",@"RecordingSignal008.png",   nil];
    self.myTextView = [[UITextView alloc]init];
    
    
    
}
-(void)getAudioNameFromList : (NSNotification*)sender{
    if ([sender.name isEqual:@"SelectedAudioName"])
    {
        NSLog(@"%@",sender.object);
        if(sender.object != nil){
            NSLog(@"details id:%@ audio is:%@",_editNowDetailsIdStr,sender.object);
            
            _audioPath = sender.object;
            [self editAudioComponent];
           
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    
}

-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Audio list"
                     image:nil
                    target:self
                    action:@selector(openAudioList)],
      
      [KxMenuItem menuItem:@"Recording"
                     image:nil
                    target:self
                    action:@selector(talkClick)],
      
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
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
-(void)addNewWebView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    self.webView = [[UIWebView alloc]init];
    self.webView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64);
    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:self.editNowHtmlCodeStr baseURL:baseUrl];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self loadHtmlToWebView];
}
#pragma mark - webview JSContext
//获取webview中section里的heml代码
- (void)getHtmlCodeClick {
    //native  call js 代码
    NSString *jsToGetHtmlSource =  @"document.getElementsByTagName('html')[0].innerHTML";
    //    NSString *htmlSource = @"<section class='swiper-slide swiper-slide2'>";//slide2需要拼接获取正确的索引值
    _htmlSource = @"<!DOCTYPE html><html>";
    _htmlSource = [_htmlSource stringByAppendingString: [_webView stringByEvaluatingJavaScriptFromString:jsToGetHtmlSource]];
    _htmlSource = [_htmlSource stringByAppendingString:@"</html>"];
    //根据summaryid 和templateid查询数据库更换html_code
    //在details表中 根据detailsid 修改html代码
    
    [DBDaoHelper updateDetailsIdWith:self.editNowDetailsIdStr htmlCode:_htmlSource];
    
}
-(void)loadHtmlToWebView{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
       
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSLog(@"input mySt:%@", args[0]);
        NSLog(@"input mySt:%@", args[1]);
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        NSString *editFlag =[[NSString alloc]initWithFormat:@"%@",args[2]];
        NSLog(@"editFlag:%@", editFlag);
        _oldTextHtml = htmlVal;
        [self editTextComponent:htmlVal htmlIndex:htmlIndex editFlag:editFlag];
        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        
        NSLog(@"input mySt:%@", args[0]);
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        //[self editImageComponent:_fullPath :_imgIndex];
        //        [self editImageComponent: @"/Users/linlecui/Desktop/10c58PIC2CK_1024.jpg" : imgIndex];//加载本地图片到webview,把图片的索引传给方法
        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
}
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
    
    _textBackgroundView =[[UIView alloc]initWithFrame:CGRectMake(0, KScreenHeight-216-120, KScreenWidth, 65)];
    _textBackgroundView.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:_textBackgroundView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.myTextView.frame=CGRectMake(2, KScreenHeight-216-110, KScreenWidth-80, 30);
        self.myTextView.backgroundColor = [UIColor whiteColor];
        self.myTextView.delegate = self;
        [self.myTextView becomeFirstResponder];
        self.myTextView.layer.borderWidth = 1;
        self.myTextView.layer.cornerRadius = 5;
        NSString *textStr = [htmlVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // NSString *mytt= [[NSString alloc]initWithFormat:textStr];
        self.myTextView.text = textStr;
        self.myTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [backgroundView addSubview:self.myTextView];
    });
    
        _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _okButton.frame = CGRectMake(KScreenWidth-60 , 10, 40, 20);
        [_okButton setTitle:@"OK" forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _textIndex = htmlIndex;
        [_okButton addTarget:self action:@selector(saveTextData) forControlEvents:UIControlEventTouchUpInside];
        [_textBackgroundView addSubview:_okButton];
    
    _addLineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _addLineBtn.frame = CGRectMake(20, KScreenHeight-216-75, 100, 20);
    [_addLineBtn setTitle:@"New line" forState:UIControlStateNormal];
    [_addLineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addLineBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    _addLineBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_addLineBtn addTarget:self action:@selector(newLineFunction) forControlEvents:UIControlEventTouchUpInside];
    _addLineBtn.backgroundColor = [UIColor darkGrayColor];
    [backgroundView addSubview:_addLineBtn];
    
    
    _deleteLineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _deleteLineBtn.frame = CGRectMake(130, KScreenHeight-216-75, 100, 20);
    [_deleteLineBtn setTitle:@"Delete line" forState:UIControlStateNormal];
    [_deleteLineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_deleteLineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    _deleteLineBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_deleteLineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteLineBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    _deleteLineBtn.backgroundColor = [UIColor darkGrayColor];
    [_deleteLineBtn addTarget:self action:@selector(deleteFunction) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_deleteLineBtn];
    
    if([editFlag isEqualToString:@"false"]){
        
        _addLineBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _deleteLineBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _deleteLineBtn.backgroundColor = [UIColor lightGrayColor] ;
        _addLineBtn.backgroundColor = [UIColor lightGrayColor] ;
        [_addLineBtn setEnabled:NO];
        [_deleteLineBtn setEnabled:NO];
    }else{
        _addLineBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _deleteLineBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _deleteLineBtn.backgroundColor = [UIColor darkGrayColor] ;
        _addLineBtn.backgroundColor = [UIColor darkGrayColor] ;
        [_addLineBtn setEnabled:YES];
        [_deleteLineBtn setEnabled:YES];
    }
    
    
    
    
    
//    _editTextViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
//    _editTextViewControl.backgroundColor = [UIColor grayColor];
//    
//    
//    UILabel *titleLabel = [[UILabel alloc]init];
//    titleLabel.frame = CGRectMake(20, 20, KScreenWidth, 30);
//    titleLabel.text = @"Please type your word:";
//    [_editTextViewControl addSubview:titleLabel];
//    
//    _txtField = [[UITextField alloc]initWithFrame:CGRectMake(20, 60, KScreenWidth-40, KScreenHeight *0.1)];
//    _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _txtField.selected = YES;
//    //    txtView.delegate = self;
//    //  txtView.adjustsFontSizeToFitWidth = YES;
//    _txtField.backgroundColor = [UIColor whiteColor];
//    NSString *textStr = [htmlVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    // NSString *mytt= [[NSString alloc]initWithFormat:textStr];
//    _txtField.text = textStr;
//    _txtField.delegate = self;
//    //[txtView becomeFirstResponder];
//    [_txtField.layer setMasksToBounds:YES];
//    [_txtField.layer setCornerRadius:6.0];
//    [_editTextViewControl addSubview:_txtField];
//    
//    _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    _okButton.frame = CGRectMake(20 , 30 + KScreenHeight*0.1 + 40, KScreenWidth * 0.5 - 25, 35);
//    [_okButton setTitle:@"OK" forState:UIControlStateNormal];
//    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_okButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//    _okButton.backgroundColor = [UIColor darkGrayColor];
//    _okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
//    [_okButton.layer setMasksToBounds:YES];
//    
//    [_okButton.layer setBorderWidth:1.0];
//    [_okButton.layer setCornerRadius:7.0];
//    _okButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    
//    _textIndex = htmlIndex;
//    [_okButton addTarget:self action:@selector(saveTextData) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_editTextViewControl addSubview:_okButton];
//    
//    
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    cancelButton.frame = CGRectMake(KScreenWidth * 0.5 + 5, 30 + KScreenHeight * 0.1 + 40, KScreenWidth * 0.5 - 25, 35);
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    cancelButton.backgroundColor = [UIColor darkGrayColor];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
//    [cancelButton.layer setMasksToBounds:YES];
//    
//    [cancelButton.layer setBorderWidth:1.0];
//    [cancelButton.layer setCornerRadius:7.0];
//    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    _textIndex = htmlIndex;
//    [cancelButton addTarget:self action:@selector(cancelFunction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *newLineButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    newLineButton.frame = CGRectMake(20, 30 + KScreenHeight * 0.25, KScreenWidth * 0.5 - 25, 35);
//    [newLineButton setTitle:@"New Line" forState:UIControlStateNormal];
//    [newLineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [newLineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
//    newLineButton.backgroundColor = [UIColor darkGrayColor] ;
//    
//    newLineButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [newLineButton.layer setMasksToBounds:YES];
//    [newLineButton.layer setBorderWidth:1.0];
//    [newLineButton.layer setCornerRadius:7.0];
//    newLineButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    [newLineButton addTarget:self action:@selector(newLineFunction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    deleteButton.frame = CGRectMake(KScreenWidth*0.5 +5, 30 + KScreenHeight*0.25, KScreenWidth*0.5 - 25, 35);
//    [deleteButton setTitle:@"Delete Current line" forState:UIControlStateNormal];
//    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [deleteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
//    deleteButton.backgroundColor = [UIColor darkGrayColor];
//    deleteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [deleteButton.layer setMasksToBounds:YES];
//    [deleteButton.layer setBorderWidth:1.0];
//    [deleteButton.layer setCornerRadius:7.0];
//    deleteButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    [deleteButton addTarget:self action:@selector(deleteFunction) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_editTextViewControl addSubview:newLineButton];
//    [_editTextViewControl addSubview:deleteButton];
//    [_editTextViewControl addSubview:_okButton];
//    [_editTextViewControl addSubview:cancelButton];
//    if([editFlag isEqualToString:@"false"]){
//        
//        newLineButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        deleteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        deleteButton.backgroundColor = [UIColor lightGrayColor] ;
//        newLineButton.backgroundColor = [UIColor lightGrayColor] ;
//        [newLineButton setEnabled:NO];
//        [deleteButton setEnabled:NO];
//    }else{
//        newLineButton.layer.borderColor = [UIColor whiteColor].CGColor;
//        deleteButton.layer.borderColor = [UIColor whiteColor].CGColor;
//        deleteButton.backgroundColor = [UIColor darkGrayColor] ;
//        newLineButton.backgroundColor = [UIColor darkGrayColor] ;
//        [newLineButton setEnabled:YES];
//        [deleteButton setEnabled:YES];
//    }
//    [self.view addSubview:_editTextViewControl];
}
- (void)textViewDidChange:(UITextView *)textView
{
    // 获取原来的 frame
    CGRect tmpRect = _myTextView.frame;
    
    CGSize size = [_myTextView.text sizeWithFont:[UIFont systemFontOfSize:18]
                              constrainedToSize:CGSizeMake(KScreenWidth, 100)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    tmpRect.size.height = size.height; // 20 points for padding
    tmpRect.origin.y = 216+55-tmpRect.size.height;
    _textBackgroundView.frame = CGRectMake(0, tmpRect.origin.y-5, KScreenWidth, tmpRect.size.height +35);
    _myTextView.frame = tmpRect;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.myTextView resignFirstResponder];
    return YES;
}

-(void)newLineFunction{
    NSString *str = @"addListItem('";
    str = [str stringByAppendingString:_textIndex];
    str = [str stringByAppendingString:@"');"];
    NSLog(@"add new line javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You added new line sucessfully, do you want to stay here or exit?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
}
-(void)deleteFunction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delele current line" message:@"This action can not undo. do you want to delete this line? " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *str = @"deleteCurrentLine('";
        str = [str stringByAppendingString:_textIndex];
        str = [str stringByAppendingString:@"');"];
        NSLog(@"delete line javascript:%@",str);
        [_webView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        self.navigationController.navigationBarHidden = NO;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)cancelFunction{
    self.navigationController.navigationBarHidden = NO;
    [_editTextViewControl removeFromSuperview];
    _editTextViewControl = nil;
}
-(void)saveTextData{
    self.navigationController.navigationBarHidden = NO;
    
    NSString *temp = [_myTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //看剩下的字符串的长度是否为零
    if ([temp length]!=0) {
        _currentText = _myTextView.text;
        NSString *str = @"var field = document.getElementsByClassName('text_element')[";
        str = [str stringByAppendingString:_textIndex];
        str = [str stringByAppendingString:@"];"];
        str = [str stringByAppendingString:@" field.innerHTML='"];
        str = [str stringByAppendingString:_myTextView.text];
        str = [str stringByAppendingString:@"';"];
        
        NSLog(@"final javascript:%@",str);
        [_webView stringByEvaluatingJavaScriptFromString:str];
        [_editTextViewControl removeFromSuperview];
        _editTextViewControl = nil;
        [self getHtmlCodeClick];//获取webview中section里的heml代码
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Content is not null." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show ];
        
    }
    
}

//更改图片
-(void)editImageComponent:(NSString *)imgName : (NSString *)index{
    
    //拼接js字符串，用于替换图片
    NSString *str = @"var field = document.getElementsByClassName('img_element')[";
    str = [str stringByAppendingString:index];
    str = [str stringByAppendingString:@"];"];
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:imgName];
    str = [str stringByAppendingString:@"';"];
    
    NSLog(@"final javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];//js字符串通过这个方法传递到webview中的html并执行此js
    [self getHtmlCodeClick];
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
    [DBDaoHelper insertFilePathToDetails_idWith:self.editNowDetailsIdStr summary_id:self.editNowSummaryIdStr file_type:@"image" file_path:_fullPath ];
    [self editImageComponent : imageFullName : _imgIndex];
    // NSLog(@"imageFullName:%@",imageFullName);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - addAudio
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
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:audioListVC];
    audioListVC.audName = _audioPath;
    audioListVC.detailsId = _editNowDetailsIdStr;
    
    [self presentViewController:navigation animated:YES completion:nil];
//     self.navigationController.navigationBar.hidden = YES;
//    
//    _audioView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, KScreenHeight-20)];
//    _audioView.backgroundColor = [UIColor lightGrayColor];
//    
//    _audioTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 44-20)];
//    _audioTableView.dataSource = self;
//    _audioTableView.delegate = self;
//    _audioTableView.backgroundColor = [UIColor  colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:0.5];
//    [_audioView addSubview:_audioTableView];
//    
//    
//    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    selectButton.frame = CGRectMake(2, KScreenHeight - 42 -20, KScreenWidth - 4, 40);
//    [selectButton setTitle:@"SELECT" forState:UIControlStateNormal];
//    [selectButton setBackgroundColor:[UIColor darkGrayColor]];
//    [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [selectButton addTarget:self action:@selector(closeAudioList) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_audioView addSubview:selectButton];
//    [self.view addSubview:_audioView];
//    _audioArray = [[NSMutableArray alloc]init];
//    _audioArray = [DBDaoHelper queryAllAudioFiles];
//    
//    for (int i = 0 ; i<_audioArray.count; i++) {
//        FilesModel *fModel = [FilesModel new];
//        fModel = [_audioArray objectAtIndex:i];
//        fModel.isChecked = @"0";
//        if ([fModel.fileIdStr isEqualToString:_editNowAudioIdStr]) {
//            fModel.isChecked = @"1";
//            
//            [_audioArray replaceObjectAtIndex:i  withObject:fModel];
//        }
//        fModel = nil;
//    }
    
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


#pragma start record

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
    NSLog(@"final javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];
    
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
        [DBDaoHelper insertFilePathToDetails_idWith:self.editNowDetailsIdStr summary_id:self.editNowSummaryIdStr file_type:@"audio" file_path:_audioPath];
    }
    NSLog(@"录音完成!");
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
