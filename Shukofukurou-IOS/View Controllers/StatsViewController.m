//
//  StatsViewController.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 2/4/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import "StatsViewController.h"
#import "Utility.h"
#import "listservice.h"
#import "AtarashiiListCoreData.h"
#import "EntryCellInfo.h"
#import "TitleInfoTableViewCell.h"
#import "RatingTwentyConvert.h"
#import "AniListScoreConvert.h"
#import "ThemeManager.h"

@interface StatsViewController ()
@property (strong) NSMutableArray *animestats;
@property (strong) NSMutableArray *mangastats;
@property (strong) NSArray *currentstats;
@property (strong) NSArray *animescoredistribution;
@property (strong) NSArray *mangascoredistribution;
@property (strong) NSArray *currentdistribution;
@property (strong) NSArray *ratinglabels;
@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View Loaded");
    self.graphView.animationDuration = 2.0;
    self.graphView.dataSource = self;
    [self setTheme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self populateValues];
    [self performLoadStats];
}

- (void)setTheme {
    bool darkmode = [NSUserDefaults.standardUserDefaults boolForKey:@"darkmode"];
    ThemeManagerTheme *current = [ThemeManager sharedCurrentTheme];
    self.view.backgroundColor = darkmode ? current.viewAltBackgroundColor : current.viewBackgroundColor;
    self.graphView.backgroundColor = darkmode ? current.viewAltBackgroundColor : current.viewBackgroundColor;
    _tableView.backgroundColor = darkmode ? current.viewAltBackgroundColor : current.viewBackgroundColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self loadandsizechart];
}

- (void)loadandsizechart {
    int width = self.view.bounds.size.width;
    if (width == 320) {
        self.graphView.marginBar = 10;
    }
    else {
        self.graphView.marginBar = 20;
    }
    [_graphView draw];
}

- (IBAction)dismissStats:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectstats:(id)sender {
    [self performLoadStats];
}

- (void)performLoadStats {
    if (_statsselector.selectedSegmentIndex == 0) {
        _currentstats = _animestats;
        _currentdistribution = _animescoredistribution;
    }
    else {
        _currentstats = _mangastats;
        _currentdistribution = _mangascoredistribution;
    }
    [_tableView reloadData];
    [self loadandsizechart];
}

#pragma List Stats Generation
-(void)populateValues {
    NSDictionary *anime;
    _animestats = [NSMutableArray new];
    _mangastats = [NSMutableArray new];
    _currentstats = @[];
    _currentdistribution = @[];
    _ratinglabels = @[@"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", @"1"];
    switch ([listservice getCurrentServiceID]) {
        case 1:
            anime = [AtarashiiListCoreData retrieveEntriesForUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:MALAnime];
            break;
        case 2:
        case 3:
            anime = [AtarashiiListCoreData retrieveEntriesForUserId:[listservice getCurrentUserID] withService:[listservice getCurrentServiceID] withType:MALAnime];
            break;
    }
    _animescoredistribution = [self populateScores:anime[@"anime"] withService:[listservice getCurrentServiceID] withType:0];
    [self populatestatuscounts:anime[@"anime"] type:0];
    [self populateTotalEps:anime[@"anime"]];
    [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Days Spent" withValue:[NSString stringWithFormat:@"%.02f", ((NSNumber *)anime[@"statistics"][@"days"]).floatValue] withCellType:cellTypeInfo]];
    NSDictionary *manga;
    switch ([listservice getCurrentServiceID]) {
        case 1:
            manga = [AtarashiiListCoreData retrieveEntriesForUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:MALManga];
            break;
        case 2:
        case 3:
            manga = [AtarashiiListCoreData retrieveEntriesForUserId:[listservice getCurrentUserID] withService:[listservice getCurrentServiceID] withType:MALManga];
            break;
    }
    _mangascoredistribution = [self populateScores:manga[@"manga"] withService:[listservice getCurrentServiceID] withType:1];
    [self populatestatuscounts:manga[@"manga"] type:1];
    [self populateTotalVolandChaps:manga[@"manga"]];
    [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Days Spent" withValue:[NSString stringWithFormat:@"%.02f", ((NSNumber *)manga[@"statistics"][@"days"]).floatValue] withCellType:cellTypeInfo]];
}

- (void)populatestatuscounts:(NSArray *)a type:(int)type{
    NSArray *filtered;
    if (type == 0) {
        NSNumber *watching;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantowatch;
        for (int i = 0; i < 5; i++) {
            switch(i) {
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"watching"]];
                    watching = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"plan to watch"]];
                    plantowatch = @(filtered.count);
                    break;
            }
        }
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Watching" withValue:watching.stringValue withCellType:cellTypeInfo]];
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Completed" withValue:completed.stringValue withCellType:cellTypeInfo]];
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"On-hold" withValue:onhold.stringValue withCellType:cellTypeInfo]];
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Dropped" withValue:dropped.stringValue withCellType:cellTypeInfo]];
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Planned" withValue:plantowatch.stringValue withCellType:cellTypeInfo]];
    }
    else {
        NSNumber *reading;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantoread;
        for (int i = 0; i < 5; i++) {
            switch(i) {
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"reading"]];
                    reading = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"plan to read"]];
                    plantoread = @(filtered.count);
                    break;
                default:
                    break;
            }
        }
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Reading" withValue:reading.stringValue withCellType:cellTypeInfo]];
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Completed" withValue:completed.stringValue withCellType:cellTypeInfo]];
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"On-hold" withValue:onhold.stringValue withCellType:cellTypeInfo]];
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Dropped" withValue:dropped.stringValue withCellType:cellTypeInfo]];
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Planned" withValue:plantoread.stringValue withCellType:cellTypeInfo]];
    }
}

- (void)populateTotalEps:(NSArray *)a {
    int totaleps = 0;
    for (NSDictionary *d in a) {
        totaleps = totaleps + ((NSNumber *)d[@"watched_episodes"]).intValue;
    }
    [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Total Episodes" withValue:@(totaleps).stringValue withCellType:cellTypeInfo]];
}

- (void)populateTotalVolandChaps:(NSArray *)a {
    int totalchap = 0;
    int totalvol = 0;
    for (NSDictionary *d in a) {
        totalchap = totalchap + ((NSNumber *)d[@"chapters_read"]).intValue;
        totalvol = totalvol + ((NSNumber *)d[@"volumes_read"]).intValue;
    }
    [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Total Chapters" withValue:@(totalchap).stringValue withCellType:cellTypeInfo]];
    [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Total Volumes" withValue:@(totalvol).stringValue withCellType:cellTypeInfo]];
}

#pragma mark score
- (NSArray *)populateScores:(NSArray *)list withService:(int)service withType:(int)type {
    if (type == 0) {
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Num of Entries" withValue:[NSString stringWithFormat:@"%li",list.count] withCellType:cellTypeInfo]];
    }
    else {
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Num of Entries" withValue:[NSString stringWithFormat:@"%li",list.count] withCellType:cellTypeInfo]];
    }
    NSMutableArray *scores = [NSMutableArray new];
    for (NSDictionary *d in list) {
        switch (service) {
            case 1: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:d[@"score"]];
                }
                break;
            }
            case 2: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:@([RatingTwentyConvert translateKitsuTwentyScoreToMAL:((NSNumber *)d[@"score"]).intValue])];
                }
                break;
            }
            case 3: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:[AniListScoreConvert convertScoreToRawActualScore:((NSNumber *)d[@"score"]).intValue withScoreType:@"POINT_10"]];
                }
                break;
            }
            default:
                break;
        }
    }
    NSString *standarddev;
    NSString *avgscore;
    if (scores.count > 0) {
        standarddev = [NSString stringWithFormat:@"%.02f", [self standardDeviationOf:scores].floatValue];
        avgscore = [NSString stringWithFormat:@"%.02f", [self meanOf:scores].floatValue];
    }
    else {
        standarddev = @"0";
        avgscore = @"0";
    }
    if (type == 0) {
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Std Dev" withValue:standarddev withCellType:cellTypeInfo]];
        [_animestats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Avg Score" withValue:avgscore withCellType:cellTypeInfo]];
    }
    else {
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Std Dev" withValue:standarddev withCellType:cellTypeInfo]];
        [_mangastats addObject:[[EntryCellInfo alloc] initCellWithTitle:@"Avg Score" withValue:avgscore withCellType:cellTypeInfo]];
    }
    return [self countscores:scores];
}

- (NSArray *)countscores:(NSArray *)scores {
    NSMutableArray *scoredistribution = [NSMutableArray new];
    for (int i = 10; i > 0; i--) {
        int scorecount = 0;
        for (NSNumber *score in scores) {
            if (score.intValue == i) {
                scorecount++;
            }
        }
        [scoredistribution addObject:@(scorecount)];
    }
    return scoredistribution;
}

#pragma mark Helpers

- (NSNumber *)meanOf:(NSArray *)array
{
    double runningTotal = 0.0;
    
    for(NSNumber *number in array) {
        runningTotal += number.doubleValue;
    }
    
    return @(runningTotal / array.count);
}

- (NSNumber *)standardDeviationOf:(NSArray *)array {
    if(!array.count) return nil;
    
    double mean = [self meanOf:array].doubleValue;
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array) {
        double valueOfNumber = number.doubleValue;
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return @(sqrt(sumOfSquaredDifferences / array.count));
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentstats.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntryCellInfo *cellEntry = _currentstats[indexPath.row];
    NSString *reusableIdentifier = @"titleinfocell";
    TitleInfoBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    if (!cell && tableView != self.tableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    }
    cell.textLabel.text = cellEntry.cellTitle;
    cell.detailTextLabel.text = cellEntry.cellValue;
    return cell;
}

- (NSInteger)numberOfBars {
    return _currentdistribution.count;
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return _currentdistribution[index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    return [UIColor colorWithRed:0.30 green:0.85 blue:0.39 alpha:1.0];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (self.graphView.animationDuration * percentage);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return _ratinglabels[index];
}

- (NSNumber *)maxValue {
    return [_currentdistribution valueForKeyPath:@"@max.intValue"];
}

@end