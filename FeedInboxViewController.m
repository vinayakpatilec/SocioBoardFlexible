//
//  FeedInboxViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 26/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "FeedInboxViewController.h"
#import "SingletonClass.h"

@interface FeedInboxViewController ()

@end

@implementation FeedInboxViewController

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
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"Height==%f",height);
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width1, height);
    //self.view.backgroundColor=[UIColor whiteColor];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    
    
     self.feedAccountArray = [[NSMutableArray alloc] init];
    NSArray *tempArray =[SingletonClass sharedSingleton].feedPageAccountArray;
    //Sort All account on the basis of Account Type
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"ProfileType" ascending:YES];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
   
   
    //Add all Twitter and Linkedin Account
    self.feedAccountArray = (NSMutableArray *)[tempArray sortedArrayUsingDescriptors:descriptors];
    NSLog(@"All Feed Account = %@", self.feedAccountArray);
    selFeedAcc=[SingletonClass sharedSingleton].feedSelAcc;
    
    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(20*width1/320, 20*height1/480,280*width1/320, 50*width1/320)];
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];
    
    NSLog(@"%d",height1);
    self.accountTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,75*height1/480,width1,390*height1/480) style:UITableViewStyleGrouped];
    //self.accountTableView .autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.accountTableView  registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SimpleTableIdentifier"];
    self.accountTableView .opaque=NO;
    self.accountTableView .backgroundColor=[UIColor clearColor];
    self.accountTableView .backgroundView=nil;
    [self.accountTableView  setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.accountTableView  setSeparatorColor:[UIColor whiteColor]];
    self.accountTableView .delegate = self;
    self.accountTableView .dataSource = self;
    //self.accountTableView .scrollEnabled=YES;
    
    [self.view addSubview:self.accountTableView ];
    
    
    UIButton *doneBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBtn.frame =  CGRectMake(1, height-(46*height1/480), width1-2, 45.5*height1/480);
    
    [doneBtn setTitle:@"DONE" forState:UIControlStateNormal];
    doneBtn.titleLabel.font=[UIFont systemFontOfSize:width1/15];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"title_bar@3x.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    
}

/*------------------------
 Pass a messsage to Delegate Method defined in Feeds.m
 --------------------*/
-(void)doneAction{
    int preSel = [SingletonClass sharedSingleton].feedSelAcc;
    
    if (preSel == selFeedAcc) {
        
    }
    else{
        [SingletonClass sharedSingleton].feedSelAcc = selFeedAcc;
        if (selFeedAcc>=0) {
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(selectedAccountInfo:)]) {
                [self.delegate selectedAccountInfo:[self.feedAccountArray objectAtIndex:selFeedAcc]];
            }
        }
    }
    
    
   [self dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark UITableView Delegate and DataSource
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor whiteColor];
    //cell.textLabel.backgroundColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:0.3];
    cell.backgroundColor = [UIColor clearColor];
   // cell.imageView.frame=CGRectMake(10, 10,10, 10);
    
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%ld",self.feedAccountArray.count);
    return self.feedAccountArray.count;
    
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
    
    for(UIImageView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }

    UIImageView *accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.frame = CGRectMake(width1-50, 8*height1/480, 24*height1/480, 24*height1/480);
    //cell.accessoryView = accessoryImageView;
    
    if (indexPath.row==selFeedAcc) {
        accessoryImageView.image = [UIImage imageNamed:@"radiobtn_clicked@3x.png"];
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        accessoryImageView.image = [UIImage imageNamed:@"radiobtn@3x.png"];
      // cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.contentView addSubview:accessoryImageView];
    UIImageView *Img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5*height1/480,30*height1/480,30*height1/480)];
    [cell addSubview:Img];
    
    NSDictionary *dict = [self.feedAccountArray objectAtIndex:indexPath.row];
    NSString *proType = [dict objectForKey:@"ProfileType"];
    if ([proType isEqualToString:@"facebook"]){
        
        Img.image=[UIImage imageNamed:@"facebook_icon.png"];
    }
   if ([proType isEqualToString:@"twitter"]){
       
        Img.image=[UIImage imageNamed:@"twitter_icon.png"];
    }
    else if ([proType isEqualToString:@"instagram"]){
        Img.image=[UIImage imageNamed:@"instagram_icon.png"];
    }
    else if ([proType isEqualToString:@"linkedin"]){
        Img.image=[UIImage imageNamed:@"linkedin_icon.png"];
    }
    
    else if ([proType isEqualToString:@"tumblr"]){
        Img.image=[UIImage imageNamed:@"tumblr_icon.png"];
    }
    else if ([proType isEqualToString:@"youtube"]){
        Img.image=[UIImage imageNamed:@"youtube_icon.png"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"         %@",[dict objectForKey:@"ProfileName"]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40*height1/480;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Update Selected Account Row
    selFeedAcc = (int)indexPath.row;
    [tableView reloadData];
    
}

@end
