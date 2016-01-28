//
//  ShowTemplateDetailsViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/11.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "ShowTemplateDetailsViewController.h"
#import "DBDaoHelper.h"
#import "TemplateDetailsCollectionViewCell.h"

@interface ShowTemplateDetailsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *templateDetailsArray;

@end

@implementation ShowTemplateDetailsViewController

-(void)viewWillAppear:(BOOL)animated{
    [self initCollectionView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.templateDetailsArray = [NSMutableArray array];
    self.templateDetailsArray = [DBDaoHelper queryTemplateDetailsWithTemplateId:self.templateId];
    
    NSLog(@"selected template id--%@",self.templateId);
    
    [self addNavigation];
    
}

-(void)addNavigation
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.parentViewController.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title=@"Select Page";
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
}
-(void)initCollectionView{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];

    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//横竖滚动样式
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1.0];
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
     //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[TemplateDetailsCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.templateDetailsArray.count;
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
    TemplateDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    TemplateDetailsModel *tdModel = [[TemplateDetailsModel alloc]init];
    tdModel = [self.templateDetailsArray objectAtIndex:indexPath.row];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [cell.webView loadHTMLString:tdModel.templateHtml baseURL:baseURL];
    [cell.webView setScalesPageToFit:YES];
//    cell.maskView.tag = (NSInteger)tdModel.templateDetailsId;
    
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   return CGSizeMake((KScreenWidth-10)/2, (KScreenHeight-64-10)/2);
}

//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5,5, 5, 5);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
//设置每个collectionview的行间距   每个cell的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    TemplateDetailsModel *tdm = [[TemplateDetailsModel alloc]init];
    tdm = [self.templateDetailsArray objectAtIndex:indexPath.row];
    NSLog(@"you selected template is:%@", tdm.templateDetailsId);
   
        int pageNum = [self.currentPageNumber intValue];
        pageNum ++;
        NSString *pStr = [NSString stringWithFormat:@"%ld",(long)pageNum];
    
    [DBDaoHelper updateOldPageNumberByNewPageNumber:pStr SummaryId:self.showSummaryIdStr];
    
    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.showSummaryIdStr TemplateId:tdm.templateId TemplateDetailsId:tdm.templateDetailsId HtmlCode:tdm.templateHtml PageNumber:pStr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedTemplate" object:pStr];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];

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
