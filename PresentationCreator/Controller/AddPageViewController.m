//
//  AddPageViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/7.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "AddPageViewController.h"
#import "AddPageCollectionViewCell.h"
#import "DBDaoHelper.h"

@interface AddPageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIWebViewDelegate>
@property (nonatomic, strong) UICollectionView*collectionView;
@property (nonatomic, strong) NSArray *htmlArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic ,strong) UIWebView *webView;
@end

@implementation AddPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    [self addCollectionView];
}
-(void)addNavigation
{
    self.navigationItem.title=@"Select page";
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
}
-(void)backClick
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)addCollectionView
{
    self.view.backgroundColor = [UIColor blackColor];
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//横竖滚动样式
    //    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth-80, 400);//头部.尾部设置
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64+5, KScreenWidth-10, KScreenHeight-64-10) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    
    
    
    //    self.collectionView.pagingEnabled =  YES;
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[AddPageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
    
    self.htmlArray = [NSArray arrayWithObjects:@"template_1.html",@"template_2.html",@"template_3.html",@"template_4.html",@"template_5.html",@"template_6.html",@"template_7.html",@"template_8.html",@"template_9.html",nil];
    self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_1"],[UIImage imageNamed:@"IMG_2"],[UIImage imageNamed:@"IMG_3"],[UIImage imageNamed:@"IMG_4"],[UIImage imageNamed:@"IMG_5"],[UIImage imageNamed:@"IMG_6"],[UIImage imageNamed:@"IMG_7"],[UIImage imageNamed:@"IMG_8"],[UIImage imageNamed:@"IMG_9"],nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.htmlArray.count;
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
    AddPageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.imgView.image = [self.imageArray objectAtIndex:indexPath.item];
    
    //    self.webView = [[UIWebView alloc]init];
    //    self.webView.frame = CGRectMake(0, 0, (KScreenWidth-10-5)/2, (KScreenHeight-64-10)/2);
    //    self.webView.backgroundColor = [UIColor redColor];
    //    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    //    NSString *filePath = [resourcePath stringByAppendingPathComponent:[self.htmlArr objectAtIndex:indexPath.row]];
    //    NSLog(@"%@",[self.htmlArr objectAtIndex:indexPath.row]);
    //    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    //    [cell addSubview:self.webView];
    //    cell.backgroundColor = [UIColor redColor];
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake((KScreenWidth-10-5)/2, (KScreenHeight-64-10-5)/2);
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
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    AddPageCollectionViewCell * cell = (AddPageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger aa = indexPath.item + 1;
    NSString *str = [NSString stringWithFormat:@"%ld",(long)aa];
    
    
    
    NSString *htmlStr = [[NSString alloc]init];
    htmlStr = [DBDaoHelper selectCreationPageString:str];
    
    // 根据 summary id 查询最大的 page number
    NSString *maxPageNumber = [DBDaoHelper getMaxPageNumber:self.showSummaryIdStr];
    
    // 根据summary id 修改最后一页的page number 为最大的page number
    [DBDaoHelper updatePageNumberToMaxNumber:self.showSummaryIdStr pageNumber:maxPageNumber];
    
    //等待修改 插入
   // [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.showSummaryIdStr TemplateId:str HtmlCode:htmlStr PageNumber:maxPageNumber];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedTemplate" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
