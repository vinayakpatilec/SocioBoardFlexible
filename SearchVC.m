//
//  SearchVC.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "SearchVC.h"
#import "GroupViewController.h"
#import "MenuViewController.h"
#import "ComposeMessageViewController.h"
#import "FHSTwitterEngine.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "SingletonClass.h"
#import "CustomSearchCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "SearchDisplayViewController.h"

@interface SearchVC (){
    int width1;
    int height1;
    CGRect screenRect;
}
@end

@implementation SearchVC
@synthesize searchDisplayController;

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
    typeOfSearch=0;
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;

     array=[NSArray arrayWithObjects:@"Twitter Posts",@"Facebook posts",@"Facebook Contacts",@"Twitter Contacts", nil];
    [super viewDidLoad];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame=CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    
    UIButton  *composeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    composeMsg.frame = CGRectMake(width1-50, 15*height1/480,35*width1/320, 30*height1/480);
    [composeMsg addTarget:self action:@selector(goToComposerMessage:) forControlEvents:UIControlEventTouchUpInside];
    [composeMsg setBackgroundImage:[UIImage imageNamed:@"edit_btn@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:composeMsg];
    
    
    UIButton  *logoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBut.frame = CGRectMake(10*width1/320, 15*height1/480, 40*width1/320,30*height1/480);
        //[composeMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        // composeMsg.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    [logoBut addTarget:self action:@selector(webserviceConnectedAccount) forControlEvents:UIControlEventTouchUpInside];
    [logoBut setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
        //[composeMsg setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:logoBut];
    
    
    
    
    self.tweetSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,57*height1/480, width1,30*height1/480)];
    //self.tweetSearchBar.frame = CGRectMake(0, 0, 320, 44);
    self.tweetSearchBar.barStyle = UIBarStyleDefault;
    self.tweetSearchBar.showsCancelButton=NO;
    self.tweetSearchBar.placeholder = [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
    self.tweetSearchBar.autocorrectionType= UITextAutocorrectionTypeNo;
    self.tweetSearchBar.tintColor = [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)235/255 blue:(CGFloat)235/255 alpha:1.0];
    for (UIView *subView in self.tweetSearchBar.subviews){
        
        if([subView isKindOfClass:[UITextField class]]){
            subView.layer.borderWidth = 1.0f;
            subView.layer.borderColor =[UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)176/255 blue:(CGFloat)176/255 alpha:1.0].CGColor;
            subView.layer.cornerRadius =15.0f;
            subView.clipsToBounds = YES;
            
        }
    }
    self.tweetSearchBar.delegate=self;
    
    [self.view addSubview:self.tweetSearchBar];
    [self.tweetSearchBar becomeFirstResponder];
    
   _titlelab=[[UILabel alloc]initWithFrame:CGRectMake(60*width1/320, 15*height1/480, 200*width1/320, 30*height1/480)];
    _titlelab.backgroundColor=[UIColor whiteColor];
    _titlelab.clipsToBounds=YES;
    _titlelab.layer.cornerRadius=5.0f;
    _titlelab.textColor=[UIColor blackColor];
    _titlelab.layer.borderColor=[UIColor redColor].CGColor;
    _titlelab.layer.borderWidth=1.0;
    _titlelab.font=[UIFont systemFontOfSize:width1/18];
    _titlelab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titlelab];

    
    _titlelab.text=[array objectAtIndex:typeOfSearch];
    _titlelab.textAlignment=NSTextAlignmentCenter;
    
}

-(void)createUI{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    if (self.tweetSearchBar) {
        self.tweetSearchBar.text = @"" ;
    }
    [self.tweetSearchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

//Display all connected account count with logout option
-(IBAction)webserviceConnectedAccount{
    [_tweetSearchBar resignFirstResponder];
     _tweetSearchBar.showsCancelButton=NO;
    if(!searchView){
        searchView.frame=CGRectMake(0, 0, 0, height1);
        searchView=[[UIView alloc]init];
    searchView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:searchView];
        searchView.layer.shadowColor=[UIColor blackColor].CGColor;
        

    self.searchContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 57*height1/480,0,height1) style:UITableViewStylePlain];
   // self.searchContactTableView=[[UITableView alloc]init];
    
    self.searchContactTableView.backgroundColor=[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1];
    self.searchContactTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.searchContactTableView.delegate = self;
    self.searchContactTableView.dataSource = self;
    self.searchContactTableView.scrollEnabled=YES;
    [searchView addSubview:self.searchContactTableView];
    
    
    UIButton  *cancelVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelVw.frame = CGRectMake(120*width1/320, 15*height1/480, 40*width1/320,30*height1/480);
    [cancelVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancelVw addTarget:self action:@selector(cancelSearchView:) forControlEvents:UIControlEventTouchUpInside];
    [cancelVw setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
    //[cancelVw setTitle:@"Back" forState:UIControlStateNormal];
    [searchView addSubview:cancelVw];
    
    }
        //self.tabBarController.tabBar.hidden =YES;
    [UIView animateWithDuration:.4 animations:^{
        //self.view.layer.shadowColor=[UIColor whiteColor].CGColor;
        //self.view.layer.shadowOpacity=.6f;
        //[self.view.layer setShadowOffset:CGSizeMake(0.,2.)];
        searchView.frame=CGRectMake(0, 0, 160*width1/320, height1);
        self.searchContactTableView.frame=CGRectMake(0,60*height1/480, 160*width1/320, self.view.bounds.size.height);
           }];

    
    
    
    //MenuViewController *obj = [[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    
    //obj.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    //[self presentViewController:obj animated:YES completion:nil]
    //;
}
//Display message Composer View
-(void)cancelSearchView:(id)sender{
    

    [UIView animateWithDuration:.4 animations:^{
        searchView.frame=CGRectMake(-160*width1/320, 0, 0, height1);
            }];
    self.searchContactTableView.frame=CGRectMake(0, 60*height1/480, 0, height1);

    }



- (IBAction) goToComposerMessage:(id)sender{
    ComposeMessageViewController *compose = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
    compose.isDraftMessages = NO;
    [self presentViewController:compose animated:YES completion:nil];
}
#pragma mark -
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if(searchView){
        [UIView animateWithDuration:.4 animations:^{
            self.tabBarController.tabBar.hidden=NO;
            searchView.frame=CGRectMake(-160*width1/320, 0, 0, height1);
            self.searchContactTableView.frame=CGRectMake(0,60*height1/480, 0, height1);
            //self.view.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
            //self.searchContactTableView.frame=CGRectMake(0, 60, 0, self.view.bounds.size.height);
        }];
    }

    searchBar.showsCancelButton=YES;
    for (UIView *subView in searchBar.subviews) {
        //Find the button
        if([subView isKindOfClass:[UIButton class]])
        {
            //Change its properties
            UIButton *cancelButton = (UIButton *)[searchBar.subviews lastObject];
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    return YES;
}
-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchDisplayController.searchResultsTableView.hidden=YES;
    return YES;
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Search Button Pressed==%@",searchBar.text);
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    //Check twitter Account is available ot not
    [searchBar resignFirstResponder];
    SearchDisplayViewController *search  = [[SearchDisplayViewController alloc] initWithNibName:@"SearchDisplayViewController" bundle:nil];
    search.searchedString = searchBar.text;

    if(typeOfSearch==0){
        search.typeOfSearch=0;
    BOOL haveTwitter = [SingletonClass sharedSingleton].haveTwitterAccount;
    //if available than pass entered keyword to SearchDisplay View 
    if (haveTwitter==YES) {
                [self presentViewController:search animated:YES completion:nil];
        
    }
    else{
        NSLog(@"No Twitter Account Added");
        [[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:@"Add a Twitter account first" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
    }
    }
    else if(typeOfSearch==1){
        search.typeOfSearch=1;
        [self presentViewController:search animated:YES completion:nil];
    }
    else if(typeOfSearch==2){
        search.typeOfSearch=2;
         [self presentViewController:search animated:YES completion:nil];
    }
    else if(typeOfSearch==3){
        search.typeOfSearch=3;
         [self presentViewController:search animated:YES completion:nil];
    }
    else if(typeOfSearch==4){
        search.typeOfSearch=4;
        [self presentViewController:search animated:YES completion:nil];
    }

    else{
        return;
    }
    [self.searchDisplayController setActive:NO animated:YES];
    
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
    }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    // return [self.sortedKeys count];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/22];
    //cell.textLabel.backgroundColor =[UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)220/255 blue:(CGFloat)250/255 alpha:1.0];
    cell.textLabel.backgroundColor=[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1];
    cell.backgroundColor =[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1];
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
       if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor blackColor];
    cell.textLabel.text=[array objectAtIndex:indexPath.row];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    typeOfSearch=(int)indexPath.row;
    
    _titlelab.text=[array objectAtIndex:typeOfSearch];
   
    
    [UIView animateWithDuration:.4 animations:^{
        searchView.frame=CGRectMake(-160*width1/320, 0, 0, height1);
        self.searchContactTableView.frame=CGRectMake(0,60*height1/480, 0, height1);
        //self.view.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
        //self.searchContactTableView.frame=CGRectMake(0, 60, 0, self.view.bounds.size.height);
    }];
    
  
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
     [_tweetSearchBar resignFirstResponder];
    _tweetSearchBar.showsCancelButton=NO;
    if(searchView){
        
        [UIView animateWithDuration:.4 animations:^{
            searchView.frame=CGRectMake(-160*width1/320, 0, 0, height1);
            self.searchContactTableView.frame=CGRectMake(0, 60*width1/320, 0, height1);
            //self.view.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
            //self.searchContactTableView.frame=CGRectMake(0, 60, 0, self.view.bounds.size.height);
           
        }];

    }
}



@end
