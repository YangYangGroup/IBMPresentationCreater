//
//  AddEditViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/14.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "AddEditViewController.h"
#import "CreationEditViewController.h"
#import "AddPageCollectionViewCell.h"

@interface AddEditViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIWebViewDelegate,UITabBarDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong) UICollectionView*collectionView;
@property (nonatomic, strong) NSArray *htmlArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *maxSummaryIdStr;//取summary表中最大的主键值
//@property (nonatomic, strong) NSArray *firstImageArray;
//@property (nonatomic, strong) NSArray *secondImageArray;
//@property (nonatomic, strong) NSArray *firstHtmlArray;
//@property (nonatomic, strong) NSArray *secondHtmlArray;

@end

@implementation AddEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    [self addCollectionView];
 
    if (self.selectTemplateIndex == 0) {
        self.htmlArray = [NSArray arrayWithObjects:@"template_1.html",@"template_2.html",@"template_3.html",@"template_4.html",@"template_5.html",nil];
        self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_1"],[UIImage imageNamed:@"IMG_2"],[UIImage imageNamed:@"IMG_3"],[UIImage imageNamed:@"IMG_4"],[UIImage imageNamed:@"IMG_5"],nil];
        
    }else if (self.selectTemplateIndex == 1){
        self.htmlArray = [NSArray arrayWithObjects:@"template_6.html",@"template_7.html",@"template_8.html",@"template_9.html",nil];
        self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_6"],[UIImage imageNamed:@"IMG_7"],[UIImage imageNamed:@"IMG_8"],[UIImage imageNamed:@"IMG_9"],nil];
    }
}
-(void)addNavigation
{
    self.navigationItem.title=@"Select a page";
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
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64+5, KScreenWidth-10, KScreenHeight-64-10-50) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[AddPageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];

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
    
//    CreationEditViewController *vc = [[CreationEditViewController alloc]init];
//    
//    NSInteger strInteger = indexPath.row +1;
//    NSString *str = [NSString stringWithFormat:@"%ld",(long)strInteger];
//    NSString *htmlStr = [[NSString alloc]init];
//    htmlStr = [DBDaoHelper selectCreationPageString:str];
//    
//    //    NSLog(@"%ld",(long)strInteger);
//    //    NSLog(@"%@",htmlStr);
//    //    NSLog(@"%ld",(long)maxtsummary);
//    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:[NSString stringWithFormat:@"%ld",strInteger] HtmlCode:htmlStr];
    
    if (self.selectTemplateIndex == 0) {
        self.htmlArray = [NSArray arrayWithObjects:@"template_1.html",@"template_2.html",@"template_3.html",@"template_4.html",@"template_5.html",nil];
        NSInteger aa = indexPath.item + 1;
        NSString *str = [NSString stringWithFormat:@"%ld",(long)aa];
        
        //    发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditNotification" object:str];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
        
    }else if (self.selectTemplateIndex == 1){
        self.htmlArray = [NSArray arrayWithObjects:@"template_6.html",@"template_7.html",@"template_8.html",@"template_9.html",nil];
        NSInteger aa = indexPath.item + 6;
        NSString *str = [NSString stringWithFormat:@"%ld",(long)aa];
        
        //    发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditNotification" object:str];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
    
    
//    vc.detailsIdStr = [NSString stringWithFormat:@"%ld",(long)strInteger];
//    vc.summaryIdStr = self.maxSummaryIdStr;//summaryId PPT的项目名
//    vc.summaryNameStr = self.summaryNameStr;
    
//    [self.navigationController pushViewController:vc animated:YES];
    

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
