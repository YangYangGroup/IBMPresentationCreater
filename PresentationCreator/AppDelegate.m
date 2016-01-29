//
//  AppDelegate.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//  Sam test 1 

#import "AppDelegate.h"
#import "ViewController.h"
#import "DBDaoHelper.h"
#import "Global.h"
#import "CreationEditViewController.h"
#import "SelectTemplateViewController.h"
#import "SettingsViewController.h"
#import "SDWebImageManager.h"

@interface AppDelegate ()<UITabBarControllerDelegate,UITabBarDelegate>
{
    UITabBarController *_tabVc;
    UINavigationController *_firstNav;
    UINavigationController *_secondNav;
    UINavigationController *_thirdNav;
}
@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //创建所有的类型表
    [DBDaoHelper createAllTable];
    NSString *firstStr = [DBDaoHelper selectTable];
    if (firstStr == NULL) {
//        NSString *templateId = [DBDaoHelper insertIntoTemplateWithTemplateId:@"1001" TemplateName:@"IBM_TEM_1" TemplateThumbnail:@"IMG_1.png" UpdateFlag:@"0" HtmlCode:@""];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2001" TemplateId:templateId HtmlCode:template_1];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2002" TemplateId:templateId HtmlCode:template_2];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2003" TemplateId:templateId HtmlCode:template_3];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2004" TemplateId:templateId HtmlCode:template_4];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2005" TemplateId:templateId HtmlCode:template_5];
//        
//        NSString *templateId2 = [DBDaoHelper insertIntoTemplateWithTemplateId:@"1002" TemplateName:@"IBM_TEM_2" TemplateThumbnail:@"IMG_6.png" UpdateFlag:@"0" HtmlCode:@""];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2006" TemplateId:templateId2 HtmlCode:template_6];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2007" TemplateId:templateId2 HtmlCode:template_7];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2008" TemplateId:templateId2 HtmlCode:template_8];
//        [DBDaoHelper insertIntoTemplateDetailsWithDetailsId:@"2009" TemplateId:templateId2 HtmlCode:template_9];
//
//        NSString *templateId3 = [DBDaoHelper insertIntoTemplateWithTemplateName:@"IBM_TEM_1" TemplateThumbnail:@"IMG_1.png" UpdateFlag:@"0"];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_1 TemplateId:templateId3];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_2 TemplateId:templateId3];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_3 TemplateId:templateId3];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_4 TemplateId:templateId3];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_5 TemplateId:templateId3];
//        
//        NSString *templateId4 = [DBDaoHelper insertIntoTemplateWithTemplateName:@"IBM_TEM_2" TemplateThumbnail:@"IMG_6.png" UpdateFlag:@"0"];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_6 TemplateId:templateId4];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_7 TemplateId:templateId4];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_8 TemplateId:templateId4];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_9 TemplateId:templateId4];
//        
//        NSString *templateId5 = [DBDaoHelper insertIntoTemplateWithTemplateName:@"IBM_TEM_1" TemplateThumbnail:@"IMG_1.png" UpdateFlag:@"0"];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_1 TemplateId:templateId5];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_2 TemplateId:templateId5];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_3 TemplateId:templateId5];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_4 TemplateId:templateId5];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_5 TemplateId:templateId5];
//        
//        NSString *templateId6 = [DBDaoHelper insertIntoTemplateWithTemplateName:@"IBM_TEM_2" TemplateThumbnail:@"IMG_6.png" UpdateFlag:@"0"];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_6 TemplateId:templateId6];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_7 TemplateId:templateId6];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_8 TemplateId:templateId6];
//        [DBDaoHelper insertIntoTemplateDetailsHtml:template_9 TemplateId:templateId6];
//       
    }
    
    ViewController *viewVC = [[ViewController alloc]init];
    _firstNav = [[UINavigationController alloc]initWithRootViewController:viewVC];
    //设置第一个tabbar的文字
    UITabBarItem *firstItem = [[UITabBarItem alloc]initWithTitle:@"My PPT" image:[UIImage imageNamed:@"my_ppt"] selectedImage:[UIImage imageNamed:@"my_ppt"]];
    viewVC.tabBarItem = firstItem;
    
    SelectTemplateViewController *CreationVc = [[SelectTemplateViewController alloc]init];
    UITabBarItem *secondItem = [[UITabBarItem alloc]initWithTitle:@"New PPT" image:[UIImage imageNamed:@"new_ppt"] selectedImage:[UIImage imageNamed:@"new_ppt"]];
    CreationVc.tabBarItem = secondItem;
    _secondNav = [[UINavigationController alloc]initWithRootViewController:CreationVc];
    _tabVc.delegate = self;
    
    // init sync tab
    SettingsViewController *snycVC = [[SettingsViewController alloc]init];
    _thirdNav = [[UINavigationController alloc]initWithRootViewController:snycVC];
    // set word and image for third tab item
    UITabBarItem *thirdItem = [[UITabBarItem alloc]initWithTitle:@"Settings" image:[UIImage imageNamed:@"set"] selectedImage:[UIImage imageNamed:@"set"]];
    snycVC.tabBarItem = thirdItem;
    
    
    //创建一个UITabBarController
    _tabVc = [[UITabBarController alloc]init];
    //设置显示一个ViewController数组
    _tabVc.viewControllers = [NSArray arrayWithObjects:_firstNav,_secondNav,_thirdNav, nil];
    self.window.rootViewController = _tabVc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newNotification:) name:@"newJianting" object:nil];
    //向微信注册（wxd930ea5d5a258f4f）
    [WXApi registerApp:@"wx401b1d91dc36e9ef" withDescription:nil];
    
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
//处理微信通过URL启动App时传递的数据
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL isSuc = [WXApi handleOpenURL:url delegate:self];
    return  isSuc;
}
-(void)newNotification:(NSNotification *)sender
{
    if([[sender object]isEqual:@"0"]){
        _tabVc.selectedIndex = 0;
    }else if ([[sender object]isEqual:@"1"]){
        
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    
    // cancal all download
    [mgr cancelAll];
    
    // clear cache
    [mgr.imageCache clearMemory];
//    mgr.imageCache.maxCacheAge = 100 * 24 * 60 * 60;
}
@end
