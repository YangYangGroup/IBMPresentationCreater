//
//  CreationEditViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/12.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "CreationEditViewController.h"
#import "CollectionViewCell.h"
#import "AddEditViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PreviewViewController.h"
#import "EditNowViewController.h"
#import "KxMenu.h"

@interface CreationEditViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (nonatomic, retain) UIView *backgorundView;
@property (nonatomic, strong) UICollectionView*collectionView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *htmeArray;
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic ,strong) NSString *fullPath;
@property (nonatomic, strong) NSString *imgIndex;

@property (nonatomic, strong) NSMutableArray *htmlCodeArray;//html代码数组
@property (nonatomic, strong) NSString *templateHtmlCode;
@property (nonatomic, strong) NSMutableArray *detailsArray;//获取details表对象

@property (nonatomic, strong) NSString *maxSummaryIdStr;//取summary表中最大的主键值
@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic, strong) NSString *returnTempleIdStr;
@property (nonatomic, strong) UIControl *titleViewControl;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UIButton *okButton;
@end

@implementation CreationEditViewController
//这个是判断没有输入的时候按钮为不可用状态
-(void)textViewDidChange:(UITextView *)textView{
    if (_titleTextView.text.length > 0) {
        _okButton.enabled = YES;
    }else{
        _okButton.enabled = NO;
    }
}
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    NSMutableString * changedString=[[NSMutableString alloc]initWithString:textView.text];
//    [changedString replaceCharactersInRange:range withString:text];
//    
//    if (changedString.length!=0) {
//        _okButton.enabled = YES;
//    }else{
//        _okButton.enabled = NO;
//    }
//    
//    return YES;
//    
//}
-(void)collectionCellAdd:(NSNotification*)sender
{
    if ([sender.name isEqual:@"EditNotification"])
    {
        NSLog(@"%@",sender.object);
        [self.htmeArray addObject:sender.object];
        self.returnTempleIdStr = [NSString stringWithFormat:@"%@",sender.object];
        
        NSString *htmlStr = [[NSString alloc]init];
        htmlStr = [DBDaoHelper selectCreationPageString:self.returnTempleIdStr];
        // 根据 summary id 查询最大的 page number
        NSString *maxPageNumber = [DBDaoHelper getMaxPageNumber:self.maxSummaryIdStr];
        
        // 根据summary id 修改最后一页的page number 为最大的page number
        [DBDaoHelper updatePageNumberToMaxNumber:self.maxSummaryIdStr pageNumber:maxPageNumber];
        
        //等待修改 插入
        [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:self.returnTempleIdStr HtmlCode:htmlStr PageNumber:maxPageNumber];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.tabBarController.tabBar.hidden = YES;
//    self.navigationItem.hidesBackButton =YES;//隐藏系统自带导航栏按钮
    self.navigationItem.title=self.summaryNameStr;
   
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.maxSummaryIdStr];
    
    [self.collectionView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
//    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionCellAdd:) name:@"EditNotification" object:nil];
//    self.view.backgroundColor = [UIColor blackColor];
    [self addNavigation];
    [self addCollectionView];
    [self addClick];
    _fullPath = [[NSString alloc]init];
}
-(void)addClick
{
    self.navigationController.navigationBarHidden =YES;//隐藏系统自带导航栏按钮
    _titleViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, KScreenHeight+5)];
    _titleViewControl.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(20, 20, KScreenWidth, 30);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"Presentation name:";
    [_titleViewControl addSubview:titleLabel];
    
    _titleTextView = [[UITextView alloc]init];
    _titleTextView.frame = CGRectMake(20, 50, KScreenWidth-40, KScreenHeight*0.25);
    _titleTextView.delegate = self;
    _titleTextView.layer.borderColor = [UIColor blackColor].CGColor;
    _titleTextView.layer.borderWidth = 1;
    _titleTextView.layer.cornerRadius = 6;
    _titleTextView.layer.masksToBounds = YES;
    _titleTextView.backgroundColor = [UIColor whiteColor];
    [_titleTextView becomeFirstResponder];
    [_titleViewControl addSubview:_titleTextView];
    
    
    //back按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(60 , 30 + KScreenHeight*0.25 + 40, 60, 40);
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor grayColor];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//    [backBtn.layer setBorderWidth:1.0];
    [backBtn.layer setCornerRadius:7.0];
    backBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backBtn addTarget:self action:@selector(backShowViewClick) forControlEvents:UIControlEventTouchUpInside];
    [_titleViewControl addSubview:backBtn];
    
    // 点击OK按钮，保存到summary表中，并返回最大的主键。
    _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _okButton.frame = CGRectMake(KScreenWidth-60-60 , 30 + KScreenHeight*0.25 + 40, 60, 40);
    [_okButton setTitle:@"Save" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    _okButton.backgroundColor = [UIColor grayColor];
    _okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_okButton.layer setMasksToBounds:YES];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//    [_okButton.layer setBorderWidth:1.0];
    [_okButton.layer setCornerRadius:7.0];
    _okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_okButton addTarget:self action:@selector(saveSummaryTile) forControlEvents:UIControlEventTouchUpInside];
    _okButton.enabled = NO;
    [_titleViewControl addSubview:_okButton];

    [self.view addSubview:_titleViewControl];
    [self.view bringSubviewToFront:_titleViewControl];
}
-(void)backShowViewClick
{
    self.navigationController.navigationBarHidden =NO;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveSummaryTile{
    
    NSString *temp = [_titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //看剩下的字符串的长度是否为零
    if ([temp length]!=0) {
        self.summaryNameStr = _titleTextView.text;
        self.navigationItem.title=self.summaryNameStr;
        self.maxSummaryIdStr = [DBDaoHelper insertSummaryWithName:_titleTextView.text];
        [_titleViewControl removeFromSuperview];
        _titleViewControl = nil;
        self.navigationController.navigationBarHidden =NO;
        
        if (self.selectTemplateIndex == 0) {
            
            //像details表添加2条数据 首页 尾页
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"2" HtmlCode:template_2 PageNumber:@"2"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"3" HtmlCode:template_3 PageNumber:@"3"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"4" HtmlCode:template_4 PageNumber:@"4"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"5"];
        }else if (self.selectTemplateIndex == 1){
            //像details表添加2条数据 首页 尾页
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"6" HtmlCode:template_6 PageNumber:@"2"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"7" HtmlCode:template_7 PageNumber:@"3"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"8" HtmlCode:template_8 PageNumber:@"4"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"9" HtmlCode:template_9 PageNumber:@"5"];
//            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"6"];
            //        [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"7"];
        }
        
        //    //像details表添加2条数据 首页 尾页
        //    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
        //    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"2"];
        //查询details表
        self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.maxSummaryIdStr];
        [self.collectionView reloadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Please type your presentation name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show ];
    }
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
    
    self.htmlCodeArray = [[NSMutableArray alloc]init];
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Save"
                     image:nil
                    target:self
                    action:@selector(saveClick)],
      
      [KxMenuItem menuItem:@"AddPage"
                     image:nil
                    target:self
                    action:@selector(addPageClick)],
      [KxMenuItem menuItem:@"Home"
                     image:nil
                    target:self
                    action:@selector(backHome)],
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(KScreenWidth - 100, 0, KScreenWidth, 60)
                 menuItems:menuItems];
}
-(void)backHome{
    
    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
    [self.navigationController popToRootViewControllerAnimated:YES];

}
-(void)saveClick
{
    PreviewViewController *vc = [[PreviewViewController alloc]init];
    vc.showSummaryIdStr = self.maxSummaryIdStr;
    vc.showSummaryNameStr = self.summaryNameStr;
    vc.showTemplateIdStr = self.returnTempleIdStr;
    [self.navigationController pushViewController:vc animated:YES];
    
//    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar

}

-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64-20) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;//是否分页
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
}
-(void)addPageClick
{
    //    //    [self presentViewController:loginVC animated:YES completion:^{
    //    //        NSLog(@"call back!");
    //    //    }];
    
    //模态跳转
    AddEditViewController *loginVC = [[AddEditViewController alloc]init];
    

    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loginVC];
    loginVC.selectTemplateIndex = self.selectTemplateIndex;
    [self presentViewController:navigation animated:YES completion:nil];
    
}
-(void)addTableClick
{
    
}
//头部显示的内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    UIView *aview = [[UIView alloc]init];
    aview.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aview];
    [footerView addSubview:_footerView];//头部广告栏
    
    return footerView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.detailsArray.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    //取出对象在 arrTemp中取出
    DetailsModel *model = [self.detailsArray objectAtIndex:indexPath.row];
    UIView *aview = [[UIView alloc]init];
    aview.frame = CGRectMake(0, 0, 0, 0);
    [cell addSubview:aview];
    self.webView = [[UIWebView alloc]init];
    self.webView.frame = CGRectMake(20, 20, KScreenWidth-40, KScreenHeight-64-20);
    self.webView.tag = indexPath.row;
    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:model.htmlCodeStr baseURL:baseUrl];
    [cell addSubview:self.webView];
    [self loadHtmlToWebView];
//    cell.backgroundColor = [UIColor blackColor];
    
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.frame = CGRectMake(20, 20, KScreenWidth-40, KScreenHeight-64-20);
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
    backgroundView.tag=indexPath.row;
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [cell addSubview:backgroundView];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    deleteBtn.frame = CGRectMake(5, 5, 30, 30);
//    deleteBtn.backgroundColor = [UIColor redColor];
    deleteBtn.tag = indexPath.row;
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    //    [deleteBtn setTitle:@"delete" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:deleteBtn];
    return cell;
}

-(void)viewClick:(UITapGestureRecognizer *)recognizer
{
    UIView *viewT = [recognizer view];
    NSLog(@"%ld",(long)viewT.tag);
    //从detailsArray中获取detailsid
    DetailsModel *model = [self.detailsArray objectAtIndex:viewT.tag];
    NSLog(@"%@",model.detailsIdStr);
    
    EditNowViewController *vc = [[EditNowViewController alloc]init];
    vc.editNowDetailsIdStr = model.detailsIdStr;
    vc.editNowSummaryNameStr = self.summaryNameStr;
    vc.editNowHtmlCodeStr = model.htmlCodeStr;
    vc.editNowSummaryIdStr = model.summaryIdStr;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)deleteClick:(UIButton *)button
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [alert show];
    UIButton *deleteBtn = [[UIButton alloc]init];
    deleteBtn.tag = button.tag;
    NSLog(@"%ld",(long)deleteBtn.tag);
    DetailsModel *model = [self.detailsArray objectAtIndex:deleteBtn.tag];
    
    [DBDaoHelper deleteDetailsWithsql:model.detailsIdStr];
    
    //查询details表
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.maxSummaryIdStr];
    [self.collectionView reloadData];
}
////根据被点击按钮的索引处理点击事件
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"clickButtonAtIndex");
//}
////AlertView的取消按钮的事件
//-(void)alertViewCancel:(UIAlertView *)alertView
//{
//    NSLog(@"alertViewCancel");
//}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(KScreenWidth, KScreenHeight-64-40);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1,1, 1, 1);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
//设置每个collectionview的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell * cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
}

#pragma mark - webview JSContext
-(void)loadHtmlToWebView{
    
    JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSLog(@"input mySt:%@", args[0]);
        NSLog(@"input mySt:%@", args[1]);
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        [self editTextComponent:htmlVal :htmlIndex];
        
        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        
        NSLog(@"input mySt:%@", args[0]);
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        [self editImageComponent:_fullPath :_imgIndex];
        //        [self editImageComponent: @"/Users/linlecui/Desktop/10c58PIC2CK_1024.jpg" : imgIndex];//加载本地图片到webview,把图片的索引传给方法
//        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
}

-(void)editTextComponent:(NSString *)param1 : (NSString *)param2{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message Alert" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
        textField.placeholder = @"please type your message";
        
        textField.text = param1;
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // NSString *getTextMessage = textField.text;
        UITextField *login = alertController.textFields.firstObject;
        NSString *newMessage = login.text;
        NSString *str = @"var field = document.getElementsByClassName('text_element')[";
        str = [str stringByAppendingString:param2];
        str = [str stringByAppendingString:@"];"];
        str = [str stringByAppendingString:@" field.innerHTML='"];
        str = [str stringByAppendingString:newMessage];
        str = [str stringByAppendingString:@"';"];
        
        NSLog(@"final javascript:%@",str);
        [_webView stringByEvaluatingJavaScriptFromString:str];
        
        NSLog(@"get message:%@",login.text);
        
    }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
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
