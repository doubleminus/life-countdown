/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 DateCalculationUtil.m
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of Nathan Wisman nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FileHandler.h"

@implementation FileHandler

- (NSDictionary*)readPlist {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *retDict;
    
    if ([self verifyPlist]) {
        if (path != nil && path.length > 1 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
            fileDict = (NSDictionary *)[NSPropertyListSerialization
                                        propertyListFromData:plistXML
                                        mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                        format:&format
                                        errorDescription:&errorDesc];
            
            // Return dictionary with user config data
            if (fileDict && [fileDict objectForKey:@"infoDict"] != nil) {
                retDict = [fileDict objectForKey:@"infoDict"];
            }
        }
    }
    return retDict;
}

- (BOOL)verifyPlist {
    NSError *error;
    
    // Get path to your documents directory from the list.
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.
    //NSLog(@"path in createplistpath: %@", path);
    
    // Our plist exists, just read it.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //NSLog(@"Plist file exists");
        return YES;
    }
    // There is no plist. Have the user provide info then write it to plist.
    else {
        //NSLog(@"no plist!!");
        bundle = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]; // Get a path to your plist created manually in Xcode
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath:path error:&error]; // Copy this plist to your documents directory.
        return NO;
    }
}


- (void)writePlist:(NSDictionary*)infoDict {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: infoDict, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"infoDict", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        //NSLog(@"file written to path: %@", path);
    }
    /*else {
     NSLog(@"Error in writing to file: %@", error);
     }*/
}

- (void)deletePlist {
    // For error information
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"Data.plist"];
    
    // Attempt to delete the file at filePath2
    if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    // Show contents of Documents directory for debugging purposes
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

- (NSString*)getPath {
    return self->path;
}

@end