//
//  ListRootViewController.m
//  Hiyoko
//
//  Created by 天々座理世 on 2018/08/29.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "ListRootViewController.h"
#import "ListViewController.h"

@interface ListRootViewController ()

@end

@implementation ListRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setListType:(int)type {
    ListViewController *lvc = (ListViewController *)self.topViewController;
    lvc.listtype = type;
    _lvc = lvc;
}

@end
