//
//  HRPGItemViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGItemViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
