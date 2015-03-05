//
//  SchedulerSettingViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 02/01/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "SchedulerSettingViewController.h"
#import "TweetAccountCell.h"
#import "SingletonClass.h"

@interface SchedulerSettingViewController ()

@end

@implementation SchedulerSettingViewController

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
    // Do any additional setup after loading the view from its nib.
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"Height==%f",height);
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    
    
    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(20*width1/320,20*height1/480,280*width1/320, 40*height1/480)];
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];

    
    
   // self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, height);
    
    //Fetch previous selected row if selected
    selectedRow = [SingletonClass sharedSingleton].schedulePreSelected;
    self.allLisrArray = [[NSArray alloc] initWithObjects:@" All Messages",@" Not send Messages",@" SocioQueue Messages",@" Draft Messages", nil];
    
    //Creating UI
    self.settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,75*height1/480, width1, height1-110) style:UITableViewStyleGrouped];
    self.settingTableView .autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
   [self.settingTableView  registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SimpleTableIdentifier"];
    self.settingTableView .opaque=NO;
    self.settingTableView .backgroundColor=[UIColor clearColor];
    self.settingTableView .backgroundView=nil;
    [self.settingTableView  setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.settingTableView  setSeparatorColor:[UIColor colorWithRed:(CGFloat)53/255 green:(CGFloat)53/255 blue:(CGFloat)53/255 alpha:1]];
    self.settingTableView .delegate = self;
    self.settingTableView .dataSource = self;
    self.settingTableView .scrollEnabled=YES;
    
    [self.view addSubview:self.settingTableView ];
    
    
    
    
    
    
    
    
    UIButton *doneBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"title_bar@3x.png"] forState:UIControlStateNormal];

    doneBtn.frame =  CGRectMake(1,height1-(47*height1/480), width1-2, 45*height1/480);
    
    [doneBtn setTitle:@"DONE" forState:UIControlStateNormal];
    doneBtn.titleLabel.font=[UIFont boldSystemFontOfSize:width1/15];
    [doneBtn setTintColor:[UIColor whiteColor]];
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       [doneBtn addTarget:self action:@selector(doneButtonClickedAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.allLisrArray.count;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.frame = CGRectMake(290*width1/320, 10, 20*width1/320, 20*width1/320);
        if (indexPath.row==selectedRow) {
        accessoryImageView.image = [UIImage imageNamed:@"radiobtn_clicked@3x.png"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        accessoryImageView.image = [UIImage imageNamed:@"radiobtn@3x.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    //cell.accessoryView = accessoryImageView;
    [cell addSubview:accessoryImageView];
     cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [self.allLisrArray objectAtIndex:indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedRow = indexPath.row;
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    //cell.textLabel.backgroundColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:0.3];
    
    //cell.backgroundColor = [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
/*------------------------
 Pass a messsage to Delegate Method defined in ScheduleVC
 --------------------*/
-(void) doneButtonClickedAction{
    int preSel = [SingletonClass sharedSingleton].schedulePreSelected;
    
    if (selectedRow>=0 && preSel != selectedRow) {
        [SingletonClass sharedSingleton].schedulePreSelected = (int)selectedRow;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(selectedMessageRow:)]) {
            [self.delegate selectedMessageRow:selectedRow];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
