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

@interface AppDelegate ()<UITabBarControllerDelegate,UITabBarDelegate>
{
    UITabBarController *_tabVc;
    UINavigationController *_firstNav;
    UINavigationController *_secondNav;
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
        [DBDaoHelper insetIntoTemplateHtml:template_1];
        [DBDaoHelper insetIntoTemplateHtml:template_2];
        [DBDaoHelper insetIntoTemplateHtml:template_3];
        [DBDaoHelper insetIntoTemplateHtml:template_4];
        [DBDaoHelper insetIntoTemplateHtml:template_5];
        [DBDaoHelper insetIntoTemplateHtml:template_6];
        [DBDaoHelper insetIntoTemplateHtml:template_7];
        [DBDaoHelper insetIntoTemplateHtml:template_8];
        [DBDaoHelper insetIntoTemplateHtml:template_9];
    }
    
    ViewController *viewVC = [[ViewController alloc]init];
    _firstNav = [[UINavigationController alloc]initWithRootViewController:viewVC];
    //设置第一个tabbar的文字
    UITabBarItem *firstItem = [[UITabBarItem alloc]initWithTitle:@"My ppt" image:[UIImage imageNamed:@"my_ppt"] selectedImage:[UIImage imageNamed:@"my_ppt"]];
    viewVC.tabBarItem = firstItem;
    
    SelectTemplateViewController *CreationVc = [[SelectTemplateViewController alloc]init];
    UITabBarItem *secondItem = [[UITabBarItem alloc]initWithTitle:@"New ppt" image:[UIImage imageNamed:@"new_ppt"] selectedImage:[UIImage imageNamed:@"new_ppt"]];
    CreationVc.tabBarItem = secondItem;
    _secondNav = [[UINavigationController alloc]initWithRootViewController:CreationVc];
    _tabVc.delegate = self;
    //创建一个UITabBarController
    _tabVc = [[UITabBarController alloc]init];
    //设置显示一个ViewController数组
    _tabVc.viewControllers = [NSArray arrayWithObjects:_firstNav,_secondNav, nil];
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

@end
