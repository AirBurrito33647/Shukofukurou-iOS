//
//  SearchRootViewController.m
//  Hiyoko
//
//  Created by 天々座理世 on 2018/08/30.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "SearchRootViewController.h"

@interface SearchRootViewController ()

@end

@implementation SearchRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Register with Search Tab View
    _searchvc = (SearchViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    self.viewControllers = @[_searchvc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end