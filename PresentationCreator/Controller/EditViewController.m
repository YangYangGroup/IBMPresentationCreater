//
//  EditViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "EditViewController.h"
#import "CollectionViewCell.h"
#import "AddPageViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "EditNowViewController.h"
#import "KxMenu.h"

@interface EditViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate>
{
    //把webview的tag值传到这个intger使用
    NSInteger webViewInteger;
}
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

@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic, strong) NSString *htmlSource;

@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;

@end

@implementation EditViewController


-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.tabBarController.tabBar.hidden = YES;
    //    self.navigationItem.hidesBackButton =YES;//隐藏系统自带导航栏按钮
    self.navigationItem.title=self.showSummaryNameStr;
    
    
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];
    [self.collectionView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
    //    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.view.backgroundColor = [UIColor blackColor];
    [self addNavigation];
    //    [self addFooter];
    [self addCollectionView];
    _fullPath = [[NSString alloc]init];
    self.navigationItem.title= self.showSummaryNameStr;
   
}

-(void)addNavigation
{
    self.htmlCodeArray = [[NSMutableArray alloc]init];
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
#pragma - back to list page
-(void)backHome{
    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    NSString *htmlCodes = final_html_befor_section;
    htmlCodes = [htmlCodes stringByAppendingString:_stringSections];
    htmlCodes = [htmlCodes stringByAppendingString:final_html_after_section];
    
    BOOL sts = [DBDaoHelper updateSummaryContentById : htmlCodes : self.showSummaryIdStr];
    _finalHtmlCode = htmlCodes;
   
    if (sts) {
         NSString *statusPro = [DBDaoHelper queryProductStatusBySummaryId:_showSummaryIdStr];
        if ([statusPro isEqualToString:@"Published"]) {
             [DBDaoHelper updateSummaryStatsDateTimeBySummaryId:_showSummaryIdStr SummaryStatus:@"Updated"];
        }
    }
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64-20) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled  =YES;//是否分页
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
    AddPageViewController *loginVC = [[AddPageViewController alloc]init];
    loginVC.showSummaryIdStr = self.showSummaryIdStr;
    
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    [self presentViewController:navigation animated:YES completion:nil];
    
    
    //    AddEditViewController *vc = [[AddEditViewController alloc]init];
    //
    //    [self.navigationController pushViewController:vc animated:YES];
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
//    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:model.htmlCodeStr baseURL:baseUrl];
    self.webView.tag = indexPath.row;
    self.webView.delegate = self;
    [cell addSubview:self.webView];
    [self loadHtmlToWebView];
    
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.frame = CGRectMake(20, 20, KScreenWidth-40, KScreenHeight-64-40);
//    backgroundView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
    backgroundView.tag=indexPath.row;
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [cell addSubview:backgroundView];
//        cell.backgroundColor = [UIColor greenColor];
    
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
    //从detailsArray中获取detailsid
    DetailsModel *model = [self.detailsArray objectAtIndex:viewT.tag];
    
    EditNowViewController *vc = [[EditNowViewController alloc]init];
    vc.editNowDetailsIdStr = model.detailsIdStr;
    vc.editNowSummaryNameStr = self.showSummaryNameStr;
    vc.editNowHtmlCodeStr = model.htmlCodeStr;
    vc.editNowSummaryIdStr = model.summaryIdStr;
    vc.editNowAudioIdStr = model.fileIdStr;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)deleteClick:(UIButton *)button
{
    
    NSString *title = NSLocalizedString(@"Do you want to delete?", nil);
    //        NSString *message = NSLocalizedString(@"Upload successfully.", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Delete", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        UIButton *deleteBtn = [[UIButton alloc]init];
        deleteBtn.tag = button.tag;
        DetailsModel *model = [self.detailsArray objectAtIndex:deleteBtn.tag];
        
        [DBDaoHelper deleteDetailsWithsql:model.detailsIdStr];
        
        //查询details表
        self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];
        [self.collectionView reloadData];
    }];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
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
//设置每个collectionview的行间距   每个cell的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CollectionViewCell * cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    DetailsModel *model = [self.detailsArray objectAtIndex:webViewInteger];
   NSString *str = model.detailsIdStr;
    NSString *finalHtmlCodeStr = [_htmlSource stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
//    NSString *str = [NSString stringWithFormat:@"%ld",(long)self.webView.tag];
    [DBDaoHelper updateDetailsIdWith:str htmlCode:finalHtmlCodeStr];
}
-(void)loadHtmlToWebView{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        
        webViewInteger = self.webView.tag;
       
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        [self editTextComponent:htmlVal :htmlIndex];
        
        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        
       
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        [self editImageComponent:_fullPath :_imgIndex];
        //        [self editImageComponent: @"/Users/linlecui/Desktop/10c58PIC2CK_1024.jpg" : imgIndex];//加载本地图片到webview,把图片的索引传给方法
//        [self backgroundClick];
//        [self getHtmlCodeClick];
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
 
        [_webView stringByEvaluatingJavaScriptFromString:str];
        [self getHtmlCodeClick];//获取webview中section里的heml代码
        
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
