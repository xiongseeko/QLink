//
//  MainViewController.h
//  QLink
//
//  Created by 尤日华 on 14-9-17.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "iConView.h"
#import "IconViewController.h"
#import "RenameView.h"

@interface MainViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,iConViewDelegate,UIAlertViewDelegate,IconViewControllerDelegate,RenameViewDelegate>

@property (strong, nonatomic) REMenu *menu;

@property (strong,nonatomic) IBOutlet UIButton *btnSceneControl;
@property (strong,nonatomic) IBOutlet UIButton *btnDeviceControl;
@property (strong,nonatomic) IBOutlet UIScrollView *svBig;
@property (strong,nonatomic) IBOutlet UITableView *tvScene;
@property (strong,nonatomic) IBOutlet UITableView *tvDevice;

-(IBAction)btnScenePressed:(UIButton *)sender;
-(IBAction)btnDevicePressed:(UIButton *)sender;

@end
