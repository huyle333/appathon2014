//
//  MyTableController.m
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import "MyTableController.h"
#import "Parse/Parse.h"

const NSInteger objsPerPage = 2;  //global const, using for 'normal' tableView and searchResultTableView
static NSString* const paginationCellId=@"PaginationCellId";

@interface MyTableController() <UISearchDisplayDelegate, UISearchBarDelegate>
{
    
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation MyTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = @"Contact";
        
        self.textKey = @"contact";
        
        self.title = @"Contact";
        
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = YES;
        
        self.objectsPerPage = 10;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                              contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
    
    self.searchResults = [NSMutableArray array];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

//detect if we are searching something
//maybe there can be a better way to detect this
-(BOOL)weAreInSearchResults
{
    return [self.searchBar.text length];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
    
}

- (void)filterResults:(NSString *)searchTerm {
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName: self.parseClassName];
    
    [query whereKey:@"contact" containsString:searchTerm];
    
    //searchStartPos = 0;                                         //reset pagination on new search
    //[query setLimit:[NSNumber numberWithInt:searchLimit]];      //set max elements count
    //searchObjectsCount = [query countObjects];                  //get all elements count that matches our search criteria
    
    NSArray *results  = [query findObjects];
    
    [self.searchResults addObjectsFromArray:results];
}

//this method searches next page elements
//actually it does the same as filterResults but in interval [searchStartPos,  searchStartPos + searchLimit] and
//appends the result to self.searchResults
-(void)loadNextPageForSearchResults
{
    //do not clear self.searchResults - it will be appended
    PFQuery *query = [PFQuery queryWithClassName: self.parseClassName];
    
    [query whereKey:@"contact" containsString:self.searchBar.text];
    //[query setLimit:[NSNumber numberWithInt:searchLimit]];
    //searchStartPos += searchLimit;
    //[query setSkip:[NSNumber numberWithInt:searchStartPos]];
    
    NSArray *results  = [query findObjects];
    
    [self.searchResults addObjectsFromArray:results];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    //[self filterResults:searchString];
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button clicked");
    
    [self filterResults:searchBar.text];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //add extra row for pagination cell if not all objects are shown
    //NSInteger result = 0;
    /*if ([self weAreInSearchResults])
    {
        result = searchObjectsCount > self.searchResults.count ? self.searchResults.count + 1 : self.searchResults.count;
    }
    else
    {
        result = totalObjectsCount > self.objects.count ? self.objects.count + 1 : self.objects.count;
    }
    return result;*/
    if (tableView == self.tableView) {
        //if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return self.objects.count;
        
    } else {
        
        return self.searchResults.count;
        
    }
}


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
}


- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"priority"];
    
    //totalObjectsCount = [query countObjects];      //remember total objects count
    
    return query;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [object objectForKey:@"contact"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Priority: %@", [object objectForKey:@"priority"]];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //find PFObject for our cell
    PFObject *object = nil;
    if ([self weAreInSearchResults])
    {
        if (indexPath.row < [self.searchResults count])
            object = [self.searchResults objectAtIndex:indexPath.row];
        
    }
    else
    {
        if (indexPath.row < [self.objects count])
            object = [self.objects objectAtIndex:indexPath.row];
        
    }
    
    UITableViewCell *cell = nil;
    if (object)
    {
        //object is found - process it as usual
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    }
    else
    {
        //object is NOT found - we are in Pagination cell. So create it
        cell = [tableView dequeueReusableCellWithIdentifier:paginationCellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:paginationCellId];
        }
        cell.textLabel.text = @"Load more...";
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //process Pagination cell selection
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.reuseIdentifier == paginationCellId)
    {
        if ([self weAreInSearchResults])
            [self loadNextPageForSearchResults];
        else
            [self loadNextPage];
    }
}


@end