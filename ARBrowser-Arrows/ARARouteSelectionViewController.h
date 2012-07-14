//
//  ARARouteSelectionViewController.h
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARARouteSelectionDelegate <NSObject>

- (void) selectedRouteWithPath:(NSString *)path;
- (void) selectedCustomRoute;

@end

@interface ARARouteSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,retain) NSArray * routes;
@property(nonatomic,retain) IBOutlet UITableView * routesTable;
@property(nonatomic,assign) id<ARARouteSelectionDelegate> delegate;

@end
