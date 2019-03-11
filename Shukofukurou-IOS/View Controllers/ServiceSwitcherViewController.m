//
//  ServiceSwitcherViewController.m
//  Hiyoko
//
//  Created by 天々座理世 on 2018/09/03.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "ServiceSwitcherViewController.h"
#import "ViewControllerManager.h"
#import "ListService.h"
#import "AppDelegate.h"
#import "ThemeManager.h"

@interface ServiceSwitcherViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *myanimelistservicecell;
@property (strong, nonatomic) IBOutlet UITableViewCell *kitsuservicecell;
@property (strong, nonatomic) IBOutlet UITableViewCell *anilistservicecell;

@end

@implementation ServiceSwitcherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTheme];
    ViewControllerManager *vcm = [ViewControllerManager getAppDelegateViewControllerManager];
    ServiceSwitcherRootViewController *serviceswitcherrootvc = [vcm getServiceSwitcherRootViewController];
    serviceswitcherrootvc.serviceswitchervc = self;
    
    // Set Service Switcher Delegate to AppDelegate
    self.delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    
    // Set current service state
    [self setcurrentservicestate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTheme];
}

- (void)setTheme {
    if (self.navigationController.popoverPresentationController) {
        self.navigationController.popoverPresentationController.backgroundColor =  [ThemeManager sharedCurrentTheme].viewBackgroundColor;
    }
}

- (void)viewDidLayoutSubviews {
    self.preferredContentSize = CGSizeMake(320, self.tableView.contentSize.height);
}

- (void)setcurrentservicestate {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
            _myanimelistservicecell.accessoryType = UITableViewCellAccessoryCheckmark;
            _kitsuservicecell.accessoryType = UITableViewCellAccessoryNone;
            _anilistservicecell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 2:
            _myanimelistservicecell.accessoryType = UITableViewCellAccessoryNone;
            _kitsuservicecell.accessoryType = UITableViewCellAccessoryCheckmark;
            _anilistservicecell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 3:
            _myanimelistservicecell.accessoryType = UITableViewCellAccessoryNone;
            _kitsuservicecell.accessoryType = UITableViewCellAccessoryNone;
            _anilistservicecell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int newindex = (int)indexPath.row+1;
    int oldservice = [listservice.sharedInstance getCurrentServiceID];
    [NSUserDefaults.standardUserDefaults setInteger:newindex forKey:@"currentservice"];
    [_delegate listserviceDidChange:oldservice newService:newindex];
    [self setcurrentservicestate];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
