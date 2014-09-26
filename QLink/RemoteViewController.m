//
//  RemoteViewController.m
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "RemoteViewController.h"
#import "DataUtil.h"
#import "SwView.h"
#import "DtView.h"
#import "McView.h"
#import "PlView.h"
#import "SdView.h"

@interface RemoteViewController ()

@end

@implementation RemoteViewController

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
    
}

-(void)initControl
{
    //设置背景图
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"首页_bg.png"]];
    
    UIScrollView *svBg = [[UIScrollView alloc] init];
    svBg.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:svBg];
    
    int height = 0;
    BOOL isTopAddHeight = NO;//音量，频道，方向盘时有判断
    BOOL isBottomAddHeight = NO;//音量，频道，方向盘时有判断
    
    NSArray *typeArr = [SQLiteUtil getOrderTypeGroupOrder:_deviceId];
    for (Order *obj in typeArr) {
        NSArray *orderArr = [SQLiteUtil getOrderListByDeviceId:obj.DeviceId andType:obj.Type];
        //sw开关
        if ([obj.Type isEqualToString:@"sw"]) {
            
            height += 10;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"SwView" owner:self options:nil];
            SwView *swView = [controlArr objectAtIndex:0];
            swView.frame = CGRectMake(0, height, 320, 33);
            [svBg addSubview:swView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"on"]) {
                    swView.btnOn.orderObj = obj;
                }else if ([obj.Type isEqualToString:@"off"]){
                    swView.btnOff.orderObj = obj;
                }
            }
            
            height += 33;
        }else if ([obj.Type isEqualToString:@"ar"])//音量
        {
            if (!isTopAddHeight){
                height += 10;
                isTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:0];
            dtView.frame = CGRectMake(0, height, 58, 177);
            [svBg addSubview:dtView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    dtView.btnAr_ad.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"rd"]){
                    dtView.btnAr_rd.orderObj = obj;
                }
            }
            
            if (!isBottomAddHeight){
                height += 177;
                isBottomAddHeight = YES;
            }
        }else if ([obj.Type isEqualToString:@"dt"])//方向盘
        {
            if (!isTopAddHeight){
                height += 10;
                isTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:1];
            dtView.frame = CGRectMake(177, height, 204, 177);
            [svBg addSubview:dtView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"up"]) {
                    dtView.btnDt_up.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"down"]){
                    dtView.btnDt_down.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"left"]){
                    dtView.btnDt_left.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"right"]){
                    dtView.btnDt_right.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"ok"]){
                    dtView.btnDt_ok.orderObj = obj;
                }
            }
            
            if (!isBottomAddHeight){
                height += 177;
                isBottomAddHeight = YES;
            }
        }else if ([obj.Type isEqualToString:@"pd"])//频道
        {
            if (!isTopAddHeight){
                height += 10;
                isTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:2];
            dtView.frame = CGRectMake(381, height, 58, 177);
            [svBg addSubview:dtView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    dtView.btnPd_ad.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"rd"]){
                    dtView.btnPd_rd.orderObj = obj;
                }
            }
            
            if (!isBottomAddHeight){
                height += 177;
                isBottomAddHeight = YES;
            }
        }else if ([obj.Type isEqualToString:@"mc"] || [obj.Type isEqualToString:@"mo"])//圆形按钮
        {
            height += 10;
            
            int iCount = [orderArr count];
            int iRowCount = iCount%4 == 0 ? iCount/4 : (iCount/4 + 1);
            
            for (int i = 0; i < iRowCount; i++)
            {
                NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"McView" owner:self options:nil];
                McView *mcView = [controlArr objectAtIndex:0];
                mcView.frame = CGRectMake(0, height, 320, 54);
                [svBg addSubview:mcView];
                for (int i=0; i<4; i++) {
                    int index = 4*iRowCount + i;
                    if (index >= iCount) {
                        break;
                    }
                    
                    OrderButton *btn = (OrderButton *)[mcView viewWithTag:(100+i)];
                    btn.orderObj = [orderArr objectAtIndex:index];
                }
                
                height += 54 + 5;
            }
        }else if ([obj.Type isEqualToString:@"pl"])//播放器
        {
            height += 10;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"PlView" owner:self options:nil];
            PlView *plView = [controlArr objectAtIndex:2];
            plView.frame = CGRectMake(381, height, 58, 177);
            [svBg addSubview:plView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"backgo"]) {
                    plView.btnLeftBottom.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"fastgo"]){
                    plView.btnRightTop.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"pash"]){
                    plView.btnLeftMiddle.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"play"]){
                    plView.btnMiddle.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"stop"]){
                    plView.btnRightMiddle.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"first"]){
                    plView.btnLeftBottom.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"next"]){
                    plView.btnLeftBottom.orderObj = obj;
                }
            }
            
            height += 177;
        }else if ([obj.Type isEqualToString:@"sd"])//播放器
        {
            height += 10;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"SdView" owner:self options:nil];
            SdView *sdView = [controlArr objectAtIndex:0];
            sdView.frame = CGRectMake(0, height, 320, 84);
            [svBg addSubview:sdView];
        }
    }
}

-(void)initData
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
