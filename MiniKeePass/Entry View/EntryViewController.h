/*
 * Copyright 2011-2013 Jason Rush and John Flanagan. All rights reserved.
 * Mdified by Frank Hausmann 2020-2021
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>

#import "TextFieldCell.h"
#import "TextViewCell.h"

#ifdef USE_KDB
#import "KdbLib.h"
#else
#import"KeePassKit.h"
#endif
#import "AppDelegate.h"


@interface EntryViewController : UITableViewController <UIGestureRecognizerDelegate, TextFieldCellDelegate>

@property (nonatomic, assign) NSUInteger selectedImageIndex;
@property (nonatomic, strong) KPKEntry *entry;
@property (nonatomic, strong) UIImage *favico;
@property (nonatomic) BOOL isNewEntry;


@end
