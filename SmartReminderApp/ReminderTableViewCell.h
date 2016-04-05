//
//  ReminderTableViewCell.h
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 3/2/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mainTask;
@property (weak, nonatomic) IBOutlet UILabel *taskStatus;

@end
