//
//  SearchVC.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SearchVC : UIViewController < UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSArray *array;
    UIView *searchView;
    int typeOfSearch;
}



@property (nonatomic, strong)IBOutlet UISearchBar *tweetSearchBar;
@property (strong, nonatomic) IBOutlet UILabel *titlelab;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) UITableView *searchContactTableView;

-(void)cancelSearchView:(id)sender;
- (IBAction) goToComposerMessage:(id)sender;
@end
