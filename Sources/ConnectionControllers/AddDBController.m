//
//  AddDBController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "AddDBController.h"
#import "DatabasesArrayController.h"
#import "MHDatabaseStore.h"
#import "NSString+Extras.h"

@implementation AddDBController

@synthesize dbname;
@synthesize user;
@synthesize password;
@synthesize dbInfo;
@synthesize conn;
@synthesize databasesArrayController = _databasesArrayController;

- (id)init {
    self = [super initWithWindowNibName:@"NewDB"];
    return self;
}

- (void)dealloc {
    [dbname release];
    [user release];
    [password release];
    [dbInfo release];
    [_databasesArrayController release];
    [conn release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDBWindowWillClose object:dbInfo];
    dbInfo = nil;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [conn managedObjectContext];
}

- (IBAction)cancel:(id)sender {
    dbInfo = nil;
    [self close];
}

- (IBAction)add:(id)sender {
    if ([ [dbname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Database name can not be empty", @"OK", nil, nil);
        return;
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"dbname", @"user", @"password", nil];
    NSString *dbstr = [[NSString alloc] initWithString:[dbname stringValue]];
    NSString *userStr = [[NSString alloc] initWithString:[user stringValue]];
    NSString *passStr = [[NSString alloc] initWithString:[password stringValue]];
    NSArray *objs = [[NSArray alloc] initWithObjects:dbstr, userStr, passStr, nil];
    [dbstr release];
    [userStr release];
    [passStr release];
    if (!dbInfo) {
        dbInfo = [[NSMutableDictionary alloc] initWithCapacity:3]; 
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjects:objs forKeys:keys];
    [objs release];
    [keys release];
    if (([[dbInfo objectForKey:@"user"] length] > 0) || ([[dbInfo objectForKey:@"password"] length] > 0)) {
        MHDatabaseStore *dbobj = [_databasesArrayController dbInfo:conn name:[dbname stringValue]];
        if (dbobj==nil) {
            //[dbobj release];
            dbobj = [_databasesArrayController newObjectWithConn:conn name:[dbname stringValue] user:[dbInfo objectForKey:@"user"] password:[dbInfo objectForKey:@"password"]];
            [_databasesArrayController addObject:dbobj];
            [dbobj release];
        }
        [self saveAction];
    }
    [self close];
}

- (void) saveAction {
    
    NSError *error = nil;
    
    if (![self.managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![self.managedObjectContext save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
