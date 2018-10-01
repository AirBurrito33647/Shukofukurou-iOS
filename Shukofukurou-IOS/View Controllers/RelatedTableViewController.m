//
//  RelatedTableViewController.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 10/1/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "RelatedTableViewController.h"
#import "TitleInfoViewController.h"
#import "Utility.h"

@interface RelatedTableViewController ()
@property int type;
@property (strong) NSMutableDictionary *items;
@property (strong) NSArray *sections;
@property (strong) NSString *japanesetitle;
@property (strong) NSString *ctitle;
@end

@implementation RelatedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_items[_sections[section]]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sections[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellType = _sections[indexPath.section];
    NSDictionary *cellEntry = _items[cellType][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericcell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = cellEntry[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellType = _sections[indexPath.section];
    NSDictionary *cellEntry = _items[cellType][indexPath.row];
    if (cellEntry[@"tag"]) {
        [self openSiteWithTag:((NSNumber *)cellEntry[@"tag"]).intValue];
    }
    else {
        int relatedtype = cellEntry[@"anime_id"] ? 0 : cellEntry[@"manga_id"] ? 1 : -1;
        int titleid = 0;
        TitleInfoViewController *titleinfovc = (TitleInfoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TitleInfo"];
        switch (relatedtype) {
            case 0:
                titleid = ((NSNumber *)cellEntry[@"anime_id"]).intValue;
                break;
            case 1:
                titleid = ((NSNumber *)cellEntry[@"manga_id"]).intValue;
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:titleinfovc animated:YES];
        [titleinfovc loadTitleInfo:titleid withType:relatedtype];
    }
}

- (void)generateRelated:(NSDictionary *)titleinfo withType:(int)type {
    _items = [NSMutableDictionary new];
    _ctitle = titleinfo[@"title"];
    if (((NSArray *)titleinfo[@"other_titles"][@"japanese"]).count > 0) {
        _japanesetitle = titleinfo[@"other_titles"][@"japanese"][0];
    }
    if (titleinfo[@"manga_adaptations"]) {
         if (((NSArray *)titleinfo[@"manga_adaptations"]).count > 0){
             _items[@"Manga Adaptations"] = titleinfo[@"manga_adaptations"];
         }
    }
    if (titleinfo[@"anime_adaptations"]) {
        if (((NSArray *)titleinfo[@"anime_adaptations"]).count > 0){
            _items[@"Anime Adaptations"] = titleinfo[@"anime_adaptations"];
        }
    }
    if (titleinfo[@"recommendations"]) {
        if (((NSArray *)titleinfo[@"recommendations"]).count > 0) {
            _items[@"Recommendations"] = titleinfo[@"recommendations"];
        }
    }
    _items[@"Web"] = [self generateWebArray];
    _sections = [_items allKeys];
    _type = type;
    [self.tableView reloadData];
}

- (NSArray *)generateWebArray {
    NSMutableArray *websites = [NSMutableArray new];
    if (_type == 0) {
        [websites addObject:@{@"title" : @"AniDB", @"tag" : @(1)}];
    }
    [websites addObject:@{@"title" : @"AnimeNewsNetwork", @"tag" : @(2)}];
    if (_type == 1) {
        [websites addObject:@{@"title" : @"MangaUpdates", @"tag" : @(3)}];
    }
    [websites addObject:@{@"title" : @"Reddit", @"tag" : @(4)}];
    [websites addObject:@{@"title" : @"TVTropes", @"tag" : @(5)}];
    [websites addObject:@{@"title" : @"Wikipedia", @"tag" : @(6)}];
    [websites addObject:@{@"title" : @"Pixiv Encyclopedia (Japanese)", @"tag" : @(7)}];
    [websites addObject:@{@"title" : @"Pixiv Encyclopedia (English)", @"tag" : @(8)}];
    return websites.copy;
}

#pragma mark otheractions
- (void)openSiteWithTag:(int)tag {
    NSURL *openurl;
    switch (tag) {
        case 1: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://anidb.net/perl-bin/animedb.pl?show=animelist&amp;adb.search=%@&amp;noalias=1&amp;do.update=update",[Utility urlEncodeString:_ctitle]]];
            break;
        }
        case 2: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.animenewsnetwork.com/search?q=%@",[Utility urlEncodeString:_ctitle]]];
        }
            break;
        case 3: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.mangaupdates.com/search.html?search=%@",[Utility urlEncodeString:_ctitle]]];
        }
            break;
        case 4: {
            if (_type == 0) {
                openurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", @"https://www.reddit.com/search?sort=new&amp;q=subreddit%3Aanime%20title%3A", [Utility urlEncodeString:_ctitle], @"%20episode%20discussion"]];
            }
            else {
                openurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", @"https://www.reddit.com/search?sort=new&amp;q=subreddit%3Amanga%20title%3A", [Utility urlEncodeString:_ctitle], @"%20ch"]];
            }
            break;
        }
        case 5: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://tvtropes.org/pmwiki/search_result.php?q=%@",[Utility urlEncodeString:_ctitle]]];
            break;
        }
        case 6: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://en.wikipedia.org/wiki/Special:Search?search=%@",[Utility urlEncodeString:_ctitle]]];
            break;
        }
        case 7: {
            NSString *tmptitle;
            if (_japanesetitle) {
                tmptitle = _japanesetitle;
            }
            else {
                tmptitle = _ctitle;
            }
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://dic.pixiv.net/search?query=%@",[Utility urlEncodeString:tmptitle]]];
            break;
        }
        case 8: {
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://en-dic.pixiv.net/search?query=%@",[Utility urlEncodeString:_ctitle]]];
            break;
        }
        default: {
            return;
        }
    }
    [UIApplication.sharedApplication openURL:openurl options:@{} completionHandler:^(BOOL success) {}];
}
@end