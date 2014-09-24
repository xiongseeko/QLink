//
//  MainViewController.m
//  QLink
//
//  Created by 尤日华 on 14-9-17.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "MainViewController.h"
#import "ILBarButtonItem.h"
#import "REMenuItem.h"
#import "KxMenu.h"
#import "DataUtil.h"
#import "MyAlertView.h"
#import "NetworkUtil.h"

#define kImageWidth  106 //UITableViewCell里面图片的宽度
#define kImageHeight  106 //UITableViewCell里面图片的高度

@interface MainViewController ()
{
    NSArray *senceArr_;
    NSArray *deviceArr_;
    NSArray *roomArr_;
    
    int senceCount_;
    int deviceCount_;
    
    int senceRowCount_;
    int deviceRowCount_;
    
    RenameView *renameView_;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    
    [self initNavigation];
    
    [self initControl];
}

#pragma mark -
#pragma mark 初始化方法

//设置导航
-(void)initNavigation
{
    [self.navigationController.navigationBar setHidden:NO];
    
    UIButton *btnDDL = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDDL.frame = CGRectMake(0, 0, 135, 38);
    btnDDL.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [btnDDL setBackgroundImage:[UIImage imageNamed:@"首页_ddl.png"] forState:UIControlStateNormal];
    NSString *roomName = @"none";
    if ([roomArr_ count] > 0) {
        Room *obj = [roomArr_ objectAtIndex:0];
        roomName = obj.RoomName;
    }
    [btnDDL setTitle:roomName forState:UIControlStateNormal];
    [btnDDL addTarget:self action:@selector(showCenterMenu) forControlEvents:UIControlEventTouchUpInside];
    
    //将横向列表添加到导航栏
    self.navigationItem.titleView = btnDDL;
    
    self.navigationItem.hidesBackButton = YES;
    
    ILBarButtonItem *rightBtn =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_三横.png"]
                        selectedImage:[UIImage imageNamed:@"首页_三横.png"]
                               target:self
                               action:@selector(showRightMenu)];
    
    
    self.navigationItem.rightBarButtonItem = rightBtn;
}

//设置控件
-(void)initControl
{
    self.navigationItem.titleView.hidden = YES;
    
    _svBig.contentSize = CGSizeMake(640, _svBig.frame.size.height);
    _svBig.delegate = self;
    
    _tvScene.delegate = self;
    _tvScene.dataSource = self;
    _tvDevice.delegate = self;
    _tvDevice.dataSource = self;
    
//    //房间下拉
//    NSMutableArray *items = [NSMutableArray array];
//    for (int i = 0; i < [roomArr_ count]; i ++) {
//        Room *obj = [roomArr_ objectAtIndex:i];
//        REMenuItem *item = [[REMenuItem alloc] initWithTitle:obj.RoomName
//                                                    subtitle:@""
//                                                       image:nil
//                                            highlightedImage:nil
//                                                      action:^(REMenuItem *item) {
//                                                          [self pushRoomItem:item];
//                                                      }];
//        
//        item.tag = i;
//        [items addObject:item];
//    }
//    
//    _menu = [[REMenu alloc] initWithItems:items];
//    _menu.cornerRadius = 4;
//    _menu.shadowColor = [UIColor blackColor];
//    _menu.shadowOffset = CGSizeMake(0, 1);
//    _menu.shadowOpacity = 1;
//    _menu.imageOffset = CGSizeMake(5, -1);
}

-(void)initSence
{
    GlobalAttr *obj = [GlobalAttr shareInstance];
    senceArr_ = [SQLiteUtil getSenceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId];
    
    senceCount_ = [senceArr_ count];
    senceRowCount_ = senceCount_%3 == 0 ? senceCount_/3 : (senceCount_/3 + 1);
    
    [_tvScene reloadData];
}

-(void)initDevice
{
    GlobalAttr *obj = [GlobalAttr shareInstance];
    deviceArr_ = [SQLiteUtil getDeviceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId];
    
    deviceCount_ = [deviceArr_ count];
    deviceRowCount_ = deviceCount_%3 == 0 ? deviceCount_/3 : (deviceCount_/3 + 1);
    
    [_tvDevice reloadData];
}

-(void)initData
{
    GlobalAttr *obj = [GlobalAttr shareInstance];
    
    senceArr_ = [SQLiteUtil getSenceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId];
    senceCount_ = [senceArr_ count];
    senceRowCount_ = senceCount_%3 == 0 ? senceCount_/3 : (senceCount_/3 + 1);
    
    deviceArr_ = [SQLiteUtil getDeviceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId];
    deviceCount_ = [deviceArr_ count];
    deviceRowCount_ = deviceCount_%3 == 0 ? deviceCount_/3 : (deviceCount_/3 + 1);
    
    roomArr_ = [SQLiteUtil getRoomList:obj.HouseId andLayerId:obj.LayerId];
}

#pragma mark -
#pragma mark IBAction Methods

-(IBAction)btnScenePressed:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    _btnDeviceControl.selected = NO;
    self.navigationItem.titleView.hidden = YES;
    
    CGRect rect = CGRectMake(0, 0,
                             320, _svBig.frame.size.height);
    [_svBig scrollRectToVisible:rect animated:NO];
}
-(IBAction)btnDevicePressed:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    _btnSceneControl.selected = NO;
    self.navigationItem.titleView.hidden = NO;
    
    CGRect rect = CGRectMake(320, 0,
                             320, _svBig.frame.size.height);
    [_svBig scrollRectToVisible:rect animated:NO];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((scrollView.contentOffset.x - 320 / 2) / 320) + 1;
    if (currentPage == 0) {
        _btnSceneControl.selected = YES;
        _btnDeviceControl.selected = NO;
        self.navigationItem.titleView.hidden = YES;
    }else{
        _btnSceneControl.selected = NO;
        _btnDeviceControl.selected = YES;
        self.navigationItem.titleView.hidden = NO;
    }
}

#pragma mark -
#pragma mark UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 101) {//场景
        return senceRowCount_;
    }else{
        return deviceRowCount_;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    if (tableView.tag == 101) {//场景
        //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] init];
        }
        
        for (UIView *views in cell.contentView.subviews)
        {
            [views removeFromSuperview];
        }
        
        for (int i=0; i<3; i++) {
            int index = 3*indexPath.row+i;
            if (index >= senceCount_) {
                break;
            }
            Sence *obj = [senceArr_ objectAtIndex:index];
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            iConView *iconView = [[iConView alloc] init];
            iconView.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            iconView.center = CGPointMake(kImageWidth *(0.5 + i), kImageHeight * 0.5);
            iconView.delegate = self;
            
            if (obj.IconType) {
                [iconView setIcon:obj.IconType andTitle:obj.SenceName];
            }else{
                [iconView setIcon:obj.Type andTitle:obj.SenceName];
            }
            [iconView setValue:[NSNumber numberWithInt:index] forKey:@"index"];
            [iconView setValue:obj.Type forKey:@"pType"];
            
            [cell.contentView addSubview:iconView];
        }
        return cell;
    }else{
        //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] init];
        }
        
        for (UIView *views in cell.contentView.subviews)
        {
            [views removeFromSuperview];
        }
        
        for (int i=0; i<3; i++) {
            int index = 3*indexPath.row+i;
            if (index >= deviceCount_) {
                break;
            }
            Device *obj = [deviceArr_ objectAtIndex:index];
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            iConView *iconView = [[iConView alloc] init];
            iconView.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            iconView.center = CGPointMake(kImageWidth *(0.5 + i), kImageHeight * 0.5);
            iconView.delegate = self;
            if (obj.IconType) {
                [iconView setIcon:obj.IconType andTitle:obj.DeviceName];
            }else{
                [iconView setIcon:obj.Type andTitle:obj.DeviceName];
            }
            [iconView setValue:[NSNumber numberWithInt:index] forKey:@"index"];
            [iconView setValue:obj.Type forKey:@"pType"];
            
            [cell.contentView addSubview:iconView];
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 106;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //不让tableviewcell有选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark iConViewDelegate

-(void)handleLongPressed:(int)index andType:(NSString *)pType
{
    if ([pType isEqualToString:MACRO]) {//场景
        MyAlertView *alert = [[MyAlertView alloc] initWithTitle:nil
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"重命名",@"图标重置",@"删除",@"编辑", nil];
        alert.tag = index;
        alert.pType = pType;
        [alert show];
    } else{
        MyAlertView *alert = [[MyAlertView alloc] initWithTitle:nil
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"重命名",@"图标重置",@"删除", nil];
        alert.tag = index;
        alert.pType = pType;
        [alert show];
    }
}

-(void)handleSingleTapPressed:(int)index andType:(NSString *)pType
{
    NSLog(@"单击====%d",index);
}

#pragma mark -
#pragma mark IconViewDelegate

-(void)refreshTable:(NSString *)pType
{
    if ([pType isEqualToString:MACRO]) {
        [self initSence];
    }else{
        [self initDevice];
    }
}

#pragma mark -
#pragma mark RenameViewDelegate

-(void)handleCanclePressed
{
    [renameView_ removeFromSuperview];
}

-(void)handleConfirmPressed:(NSString *)deviceId
                 andNewName:(NSString *)newName
                    andType:(NSString *)pType
{
    if ([pType isEqualToString:MACRO]) {
        NSString *sUrl = [NetworkUtil getChangeSenceName:newName andSenceId:deviceId];
        NSURL *url = [NSURL URLWithString:sUrl];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"更新成功." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        NSString *sUrl = [NetworkUtil getChangeDeviceName:newName andDeviceId:deviceId];
        NSURL *url = [NSURL URLWithString:sUrl];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"更新成功." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    NSLog(@"===%@\n",deviceId);
    NSLog(@"===%@\n",newName);
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(MyAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *deviceId = @"";
    NSString *deviceType = @"";
    NSString *deviceName = @"";
    
    if ([alertView.pType isEqualToString:MACRO]) {
        Sence *obj = [senceArr_ objectAtIndex:alertView.tag];
        deviceId = obj.SenceId;
        deviceType = obj.Type;
        deviceName = obj.SenceName;
    }else{
        Device *obj = [deviceArr_ objectAtIndex:alertView.tag];
        deviceId = obj.DeviceId;
        deviceType = obj.Type;
        deviceName = obj.DeviceName;
    }
    
    switch (buttonIndex) {
        case 1://重命名
        {
            NSArray *array1 = [[NSBundle mainBundle] loadNibNamed:@"RenameView" owner:self options:nil];
            renameView_ = [array1 objectAtIndex:0];
            [renameView_.tfContent setValue:[NSNumber numberWithInt:10] forKey:PADDINGLEFT];
            renameView_.frame = CGRectMake(0, 0, 320, 320);
            renameView_.tfContent.text = deviceName;
            renameView_.pDeviceId = deviceId;
            renameView_.pType = deviceType;
            renameView_.delegate = self;
            [self.view addSubview:renameView_];
            
           break;
        }
        case 2://重置图标
        {
            IconViewController *iconVC = [[IconViewController alloc] init];
            iconVC.pDeviceId = deviceId;
            iconVC.pType = deviceType;
            iconVC.delegate = self;
            [self.navigationController pushViewController:iconVC animated:YES];
            
            break;
        }
        case 3://编辑
        {
            break;
        }
        case 4://删除
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Custom Methods

//楼层菜单
- (void)showCenterMenu
{
    if (_menu.isOpen)
        return [_menu close];
    
    //房间下拉
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < [roomArr_ count]; i ++) {
        Room *obj = [roomArr_ objectAtIndex:i];
        REMenuItem *item = [[REMenuItem alloc] initWithTitle:obj.RoomName
                                                    subtitle:@""
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          [self pushRoomItem:item];
                                                      }];
        
        item.tag = i;
        [items addObject:item];
    }
    
    _menu = [[REMenu alloc] initWithItems:items];
    _menu.cornerRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);
    
    [_menu showFromNavigationController:self.navigationController];
}

//配置菜单
-(void)showRightMenu
{
    [_menu close];
    
    if ([KxMenu isOpen]) {
        return [KxMenu dismissMenu];
    }
    
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"正常模式"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"紧急模式"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"写入中控"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"初始化"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"关于"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    CGRect rect = CGRectMake(215, -50, 100, 50);
    
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:menuItems];
}

-(void)pushRoomItem:(REMenuItem *)item
{
    Room *obj = [roomArr_ objectAtIndex:item.tag];
    
    //设置导航标题
    UIButton *btnTitle = (UIButton *)[self.navigationItem titleView];
    
    if ([btnTitle.titleLabel.text isEqualToString:obj.RoomName]) {
        return;
    }
    
    [btnTitle setTitle:obj.RoomName forState:UIControlStateNormal];
    
    [GlobalAttr setGlobalAttr:obj.RoomId];
    
    [self initSence];
    
    [self initDevice];
}

//点击下拉事件
- (void)pushMenuItem:(id)sender
{
    NSLog(@"*****%@", sender);
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
