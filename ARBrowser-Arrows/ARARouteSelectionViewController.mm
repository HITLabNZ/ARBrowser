//
//  ARARouteSelectionViewController.m
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import "ARARouteSelectionViewController.h"

@interface ARARouteSelectionViewController ()

@end

@implementation ARARouteSelectionViewController

@synthesize routes = _routes, routesTable = _routesTable, delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self) {
        // Custom initialization
		
		self.routes = [[NSBundle mainBundle] pathsForResourcesOfType:@"route" inDirectory:nil];
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.routesTable setDataSource:self];
	[self.routesTable setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NSString * path = [self.routes objectAtIndex:indexPath.row];
		[self.delegate selectedRouteWithPath:path];
	} else {
		[self.delegate selectedCustomRoute];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return self.routes.count;
	else
		return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// See if there's an existing cell we can reuse
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
	
    if (cell == nil) {
        // No cell to reuse => create a new one
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RouteCell"] autorelease];
		
        // Initialize cell
        //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
	if (indexPath.section == 0) {
		// Customize cell
		NSString * routePath = [self.routes objectAtIndex:indexPath.row];
		cell.textLabel.text = [[routePath lastPathComponent] stringByDeletingPathExtension];
		
        cell.textLabel.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	} else {
		cell.textLabel.text = @"Custom Route";
		
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	return cell;
}

@end
