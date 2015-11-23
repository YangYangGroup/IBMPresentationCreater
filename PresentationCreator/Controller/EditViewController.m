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

-(void)collectionCellAdd:(NSNotification*)sender
{
    if ([sender.name isEqual:@"CreationEditNotification"])
    {
        NSLog(@"%@",sender.object);
        [self.htmeArray addObject:sender.object];
        NSString *returnStr = [NSString stringWithFormat:@"%@",sender.object];
        
        //        NSInteger strInteger = indexPath.row +1;
        //        NSString *str = [NSString stringWithFormat:@"%ld",(long)strInteger];
        NSString *htmlStr = [[NSString alloc]init];
        htmlStr = [DBDaoHelper selectCreationPageString:returnStr];

        // 根据 summary id 查询最大的 page number
        NSString *maxPageNumber = [DBDaoHelper getMaxPageNumber:self.showSummaryIdStr];
        
        // 根据summary id 修改最后一页的page number 为最大的page number
        [DBDaoHelper updatePageNumberToMaxNumber:self.showSummaryIdStr pageNumber:maxPageNumber];
        
        //等待修改 插入
        [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.showSummaryIdStr TemplateId:returnStr HtmlCode:htmlStr PageNumber:maxPageNumber];
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
    
    
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];
    NSLog(@"%@",self.detailsArray);
    [self.collectionView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
    //    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionCellAdd:) name:@"CreationEditNotification" object:nil];
//    self.view.backgroundColor = [UIColor blackColor];
    [self addNavigation];
    //    [self addFooter];
    [self addCollectionView];
    _fullPath = [[NSString alloc]init];
    self.navigationItem.title= self.showSummaryNameStr;
    NSLog(@"%@",self.showSummaryNameStr);
}

-(void)addNavigation
{
    self.htmlCodeArray = [[NSMutableArray alloc]init];
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    backbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backbtn.frame = CGRectMake(0, 0, 40, 30);
    [backbtn setTitle:@"Back" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SearchItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    //    [rightbtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = SearchItem;
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    //    btnLeft.backgroundColor = [UIColor redColor];
    btnRight.frame = CGRectMake(0, 0, 60, 30);
    [btnRight setTitle:@"Save" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = doneItem;
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
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
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
    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth, KScreenHeight-64-40);//头部.尾部设置
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
    
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(20, 30, KScreenWidth-40, KScreenHeight-64-30)];
//    _footerView.layer.borderWidth = 2;
//    _footerView.layer.cornerRadius = 0;
//    _footerView.layer.borderColor = [UIColor whiteColor].CGColor;
    _footerView.backgroundColor = [UIColor blackColor];
    
    //添加界面
    UIButton *addPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPageBtn.frame = CGRectMake((KScreenWidth-40-120)/2, 185, 120, 60);
    addPageBtn.tintColor = [UIColor whiteColor];
    addPageBtn.layer.borderWidth = 1;
    addPageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [addPageBtn setTitle:@"Add Page" forState:UIControlStateNormal];
    [addPageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [addPageBtn addTarget:self action:@selector(addPageClick) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:addPageBtn];
    
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

//头部显示的内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    UIView *aview = [[UIView alloc]init];
    aview.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aview];
    self.webView = [[UIWebView alloc]init];
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
//    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:model.htmlCodeStr baseURL:baseUrl];
    self.webView.tag = indexPath.row;
    NSLog(@"%ld",(long)indexPath.row);
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
    NSLog(@"%ld",(long)viewT.tag);
    //从detailsArray中获取detailsid
    DetailsModel *model = [self.detailsArray objectAtIndex:viewT.tag];
    NSLog(@"%@",model.detailsIdStr);
    
    EditNowViewController *vc = [[EditNowViewController alloc]init];
    vc.editNowDetailsIdStr = model.detailsIdStr;
    vc.editNowSummaryNameStr = self.summaryNameStr;
    vc.editNowHtmlCodeStr = model.htmlCodeStr;
    vc.editNowSummaryIdStr = model.summaryIdStr;
    vc.editNowAudioIdStr = model.fileIdStr;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)deleteClick:(UIButton *)button
{
    UIButton *deleteBtn = [[UIButton alloc]init];
    deleteBtn.tag = button.tag;
    NSLog(@"%ld",(long)deleteBtn.tag);
    DetailsModel *model = [self.detailsArray objectAtIndex:deleteBtn.tag];
    
    [DBDaoHelper deleteDetailsWithsql:model.detailsIdStr];
    
    //查询details表
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];
    [self.collectionView reloadData];
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
    NSLog(@"self.webView.tag%ld",(long)self.webView.tag);
    NSLog(@"%@",model.detailsIdStr);
   NSString *str = model.detailsIdStr;
    NSString *finalHtmlCodeStr = [_htmlSource stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
//    NSString *str = [NSString stringWithFormat:@"%ld",(long)self.webView.tag];
    [DBDaoHelper updateDetailsIdWith:str htmlCode:finalHtmlCodeStr];
    NSLog(@"you got html is:::%@", _htmlSource);
}
-(void)loadHtmlToWebView{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        NSLog(@"%ld",(long)self.webView.tag);
        webViewInteger = self.webView.tag;
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
        
        NSLog(@"final javascript:%@",str);
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
