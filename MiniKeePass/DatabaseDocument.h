/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
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

#ifdef USE_KDB
#import "KdbLib.h"
#else
#import "KeePassKit.h"
#endif

@interface DatabaseDocument : NSObject

//@property (nonatomic, strong) KdbTree *kdbTree;
@property (nonatomic, strong) KPKTree *kdbTree;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString* md5Base64;

/// Create a KeePass Database
/// @param filename Database filename
/// @param password Database password
/// @param keyFile Path to KeyFile
/// @return A KeePass DatabaseDocument
- (id)initWithFilename:(NSString *)filename password:(NSString *)password keyFile:(NSString *)keyFile;

///Save with a new Masterkey
- (void)saveWithNewkey:(NSString *)password keyFile:(NSString *)keyFile;

/// Save the current KeePass DatabaseDocument
- (void)save;

/// Get Fileformat from Metatdata
- (NSString *)getFileFormat;

/// Search a KeePass group for the supplied text
/// @param searchText The text for which you're searching
/// @param results A Dictionary to store the matching results
+ (void)searchGroup:(KPKGroup *)group searchText:(NSString *)searchText results:(NSMutableArray *)results;

@end
