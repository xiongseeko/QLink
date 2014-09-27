//
//  RemoteViewController.m
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "RemoteViewController.h"
#import "ILBarButtonItem.h"
#import "DataUtil.h"
#import "SwView.h"
#import "DtView.h"
#import "McView.h"
#import "PlView.h"
#import "SdView.h"
#import "OtView.h"
#import "HsView.h"
#import "NmView.h"
#import "BsTcView.h"

#define JG 15

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
    
    [self initNavigation];
    
    [self initControl];
}

//设置导航
-(void)initNavigation
{
    ILBarButtonItem *back =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_返回.png"]
                        selectedImage:[UIImage imageNamed:@"首页_返回.png"]
                               target:self
                               action:@selector(btnBackPressed)];
    
    self.navigationItem.leftBarButtonItem = back;
    
    UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTitle.frame = CGRectMake(0, 0, 100, 20);
    [btnTitle setTitle:_deviceName forState:UIControlStateNormal];
    btnTitle.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    btnTitle.backgroundColor = [UIColor clearColor];
    
    [btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.navigationItem.titleView = btnTitle;
}

-(void)initControl
{
    //设置背景图
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"首页_bg.png"]];
    
    UIScrollView *svBg = [[UIScrollView alloc] init];
    svBg.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    svBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:svBg];
    
    int height = 0;
    BOOL isDtTopAddHeight = NO;//音量，频道，方向盘时有判断
    BOOL isDtBottomAddHeight = NO;//音量，频道，方向盘时有判断
    int dtTop = 0;//循环至Dt记录控件 top 距离
    
    BOOL isBsTcTopAddHeight = NO;// 低音，高音，方向盘时有判断
    BOOL isBsTcBottomAddHeight = NO;//低音，高音，方向盘时有判断
    int bsTcTop = 0;//循环至BsTc记录控件 top 距离
    
    NSArray *typeArr = [SQLiteUtil getOrderTypeGroupOrder:_deviceId];
    for (Order *obj in typeArr) {
        
        NSArray *orderArr = [SQLiteUtil getOrderListByDeviceId:obj.DeviceId andType:obj.Type];
        
        if ([obj.Type isEqualToString:@"sw"]) {//sw开关
            
            height += JG;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"SwView" owner:self options:nil];
            SwView *swView = [controlArr objectAtIndex:0];
            swView.frame = CGRectMake(0, height, 320, 33);
            [svBg addSubview:swView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"on"]) {
                    swView.btnOn.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"off"]){
                    swView.btnOff.orderObj = obj;
                }
            }
            
            height += 33;
            
        }else if ([obj.Type isEqualToString:@"ar"])//音量+-
        {
            if (!isDtTopAddHeight){
                height += JG;
                dtTop = height;
                isDtTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:0];
            dtView.frame = CGRectMake(0, dtTop, 58, 177);
            [svBg addSubview:dtView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    dtView.btnAr_ad.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"rd"]){
                    dtView.btnAr_rd.orderObj = obj;
                }
            }
            
            if (!isDtBottomAddHeight){
                height += 177;
                isDtBottomAddHeight = YES;
            }
        }else if ([obj.Type isEqualToString:@"dt"])//方向盘
        {
            if (!isDtTopAddHeight){
                height += JG;
                dtTop = height;
                isDtTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:1];
            dtView.frame = CGRectMake(58, dtTop, 204, 177);
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
            
            if (!isDtBottomAddHeight){
                height += 177;
                isDtBottomAddHeight = YES;
            }
            
        }else if ([obj.Type isEqualToString:@"pd"])//频道+-
        {
            if (!isDtTopAddHeight){
                height += JG;
                dtTop = height;
                isDtTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"DtView" owner:self options:nil];
            DtView *dtView = [controlArr objectAtIndex:2];
            dtView.frame = CGRectMake(262, dtTop, 58, 177);
            [svBg addSubview:dtView];
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    dtView.btnPd_ad.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"rd"]){
                    dtView.btnPd_rd.orderObj = obj;
                }
            }
            
            if (!isDtBottomAddHeight){
                height += 177;
                isDtBottomAddHeight = YES;
            }
            
        }else if ([obj.Type isEqualToString:@"mc"] || [obj.Type isEqualToString:@"mo"])//圆形按钮
        {
            height += JG;
            
            int iCount = [orderArr count];
            int iRowCount = iCount%4 == 0 ? iCount/4 : (iCount/4 + 1);
            
            for (int row = 0; row < iRowCount; row ++)
            {
                NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"McView" owner:self options:nil];
                McView *mcView = [controlArr objectAtIndex:0];
                mcView.frame = CGRectMake(0, height, 320, 54);
                [svBg addSubview:mcView];
                for (int cell = 0; cell < 4; cell ++) {
                    int index = 4 * row + cell;
                    if (index >= iCount) {
                        break;
                    }
                    
                    Order *obj = [orderArr objectAtIndex:index];
                    
                    OrderButton *btn = (OrderButton *)[mcView viewWithTag:(100 + cell)];
                    btn.orderObj = obj;
                    [btn setTitle:obj.OrderName forState:UIControlStateNormal];
                }
                
                height += 54 + 5;
            }
        }else if ([obj.Type isEqualToString:@"pl"])//播放器
        {
            height += JG;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"PlView" owner:self options:nil];
            PlView *plView = [controlArr objectAtIndex:0];
            plView.frame = CGRectMake(0, height, 320, 141);
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
            
            height += 141;
            
        }else if ([obj.Type isEqualToString:@"sd"])//播放器
        {
            height += JG;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"SdView" owner:self options:nil];
            SdView *sdView = [controlArr objectAtIndex:0];
            sdView.frame = CGRectMake(0, height, 320, 84);
            [svBg addSubview:sdView];
            
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"slow"]) {
                    sdView.btnTopLeft.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"mi"]){
                    sdView.btnTopMiddle.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"fast"]){
                    sdView.btnTopRight.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"auto"]){
                    sdView.btnBottomLeft.orderObj = obj;
                }else if ([obj.SubType isEqualToString:@"chang"]){
                    sdView.btnBottomRight.orderObj = obj;
                }
            }
            
            height += 84;
            
        }else if ([obj.Type isEqualToString:@"ot"])//一排两个按钮
        {
            height += JG;
            
            int iCount = [orderArr count];
            int iRowCount = iCount%2 == 0 ? iCount/2 : (iCount/2 + 1);
            
            for (int row = 0; row < iRowCount; row ++)
            {
                NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"OtView" owner:self options:nil];
                OtView *otView = [controlArr objectAtIndex:0];
                otView.frame = CGRectMake(0, height, 320, 39);
                [svBg addSubview:otView];
                
                for (int cell = 0; cell < 2; cell ++) {
                    int index = 2 * row + cell;
                    if (index >= iCount) {
                        break;
                    }
                    
                    Order *obj = [orderArr objectAtIndex:index];
                    
                    OrderButton *btn = (OrderButton *)[otView viewWithTag:(100 + cell)];
                    btn.orderObj = [orderArr objectAtIndex:index];
                    [btn setTitle:obj.OrderName forState:UIControlStateNormal];
                }
                
                height += 39 + 5;
            }
        }
        else if ([obj.Type isEqualToString:@"st"] || [obj.Type isEqualToString:@"gn"] || [obj.Type isEqualToString:@"hs"])//一排三个按钮
        {
            height += JG;
            
            int iCount = [orderArr count];
            int iRowCount = iCount%3 == 0 ? iCount/3 : (iCount/3 + 1);
            
            for (int row = 0; row < iRowCount; row++)
            {
                NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"HsView" owner:self options:nil];
                HsView *hsView = [controlArr objectAtIndex:0];
                hsView.frame = CGRectMake(0, height, 320, 39);
                [svBg addSubview:hsView];
                for (int cell = 0; cell < 3; cell ++) {
                    int index = 3 * row + cell;
                    if (index >= iCount) {
                        break;
                    }
                    
                    Order *obj = [orderArr objectAtIndex:index];
                    
                    OrderButton *btn = (OrderButton *)[hsView viewWithTag:(100 + cell)];
                    btn.orderObj = [orderArr objectAtIndex:index];
                    [btn setTitle:obj.OrderName forState:UIControlStateNormal];
                }
                
                height += 39 + 5;
            }
        }
        else if ([obj.Type isEqualToString:@"nm"]){//1-9数字键盘
            height += JG;
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"NmView" owner:self options:nil];
            NmView *nmView = [controlArr objectAtIndex:0];
            nmView.frame = CGRectMake(0, height, 320, 168);
            [svBg addSubview:nmView];
            
            for (int i = 0; i < [orderArr count]; i ++) {
                Order *obj = [orderArr objectAtIndex:i];
                
                OrderButton *btnOrder = (OrderButton *)[nmView viewWithTag:(100+i)];
                btnOrder.orderObj = obj;
                [btnOrder setTitle:obj.OrderName forState:UIControlStateNormal];
            }
            
            height += 168;
            
        }else if ([obj.Type isEqualToString:@"bs"]){// 低音
            
            if (!isBsTcTopAddHeight){
                height += JG;
                bsTcTop = height;
                isBsTcTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"BsTcView" owner:self options:nil];
            BsTcView *bstcView = [controlArr objectAtIndex:0];
            bstcView.frame = CGRectMake(0, bsTcTop, 160, 65);
            [svBg addSubview:bstcView];
            
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    bstcView.btnAd.orderObj = obj;
                }else if([obj.SubType isEqualToString:@"rd"]){
                    bstcView.btnRd.orderObj = obj;
                }
            }
            
            [bstcView.btnTitle setTitle:@"低音" forState:UIControlStateNormal];
            
            if (!isBsTcBottomAddHeight){
                height += 65;
                isBsTcBottomAddHeight = YES;
            }
            
        }else if ([obj.Type isEqualToString:@"tc"]){// 高音
            if (!isBsTcTopAddHeight){
                height += JG;
                bsTcTop = height;
                isBsTcTopAddHeight = YES;
            }
            
            NSArray *controlArr = [[NSBundle mainBundle] loadNibNamed:@"BsTcView" owner:self options:nil];
            BsTcView *bstcView = [controlArr objectAtIndex:0];
            bstcView.frame = CGRectMake(160, bsTcTop, 160, 65);
            [svBg addSubview:bstcView];
            
            for (Order *obj in orderArr) {
                if ([obj.SubType isEqualToString:@"ad"]) {
                    bstcView.btnAd.orderObj = obj;
                }else if([obj.SubType isEqualToString:@"rd"]){
                    bstcView.btnRd.orderObj = obj;
                }
            }
            
            [bstcView.btnTitle setTitle:@"高音" forState:UIControlStateNormal];
            
            if (!isBsTcBottomAddHeight){
                height += 65;
                isBsTcBottomAddHeight = YES;
            }
        }
    }
    
    [svBg setContentSize:CGSizeMake(320, height + 80)];
}

#pragma mark -
#pragma mark Custom Methods

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
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
