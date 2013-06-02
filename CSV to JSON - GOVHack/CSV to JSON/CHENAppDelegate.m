//
//  CHENAppDelegate.m
//  CSV to JSON
//
//  Created by Nicholas Wittison on 9/01/13.
//  Copyright (c) 2013 Nicholas Wittison. All rights reserved.
//

#import "CHENAppDelegate.h"
#import "NSArray+CHCSVAdditions.h"
#import "JSONKit.h"
#import "NSString+HTML.h"

@implementation CHENAppDelegate



- (void)processFlupCards
{
    // Insert code here to initialize your application
    
    
    NSString * file = @"/Users/nicholaswittison/Documents/Development/CSV to JSON - GOVHack/CardStats.csv";
	
	NSStringEncoding encoding = NSMacOSRomanStringEncoding;
	NSError * error = nil;
	NSArray * fields = [NSArray arrayWithContentsOfCSVFile:file usedEncoding:&encoding error:&error];
    NSLog(@"wut %@", fields);
    [self processNewEventsArray:fields];
    
        
    NSLog(@"wut %@", cardArray);
        [[cardArray JSONString] writeToFile:[NSString stringWithFormat:@"/Users/nicholaswittison/Documents/Development/CSV to JSON - GOVHack/CardArray.json"] atomically:YES encoding:NSUTF8StringEncoding error:&error];

}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self processFlupCards];
    

}

- (void)processNewEventsArray:(NSArray *)fields
{
    NSMutableArray * csvEventArray = [NSMutableArray array];
    
    for (NSArray *event in fields) {
        if ([fields indexOfObject:event]== 0) {
            
        }
        else {
            int counter = 0;
            NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
            for (NSString *informationField in event)
            {
                
                
                
                if ([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Star"])
                {
                    [eventDictionary setObject:informationField forKey:@"rating"];
                }
                else if([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Normalised cap"])
                {
                    [eventDictionary setObject:informationField forKey:@"capacity"];
                }
                else if([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Brand"])
                {
                    NSString *nameString = [NSString stringWithFormat:@"%@ %@", informationField, [event objectAtIndex:counter+1]];
                    [eventDictionary setObject:nameString forKey:@"name"];
                }
                else if([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Durability"])
                {
                    [eventDictionary setObject:informationField forKey:@"durability"];
                }
                else if([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Cost"])
                {
                    [eventDictionary setObject:informationField forKey:@"cost"];
                }
                else if([[[fields objectAtIndex:0] objectAtIndex:counter] isEqualToString:@"Appliance"])
                {
                    [eventDictionary setObject:informationField forKey:@"type"];
                }
                                
                
                counter = counter +1;
            }
            [csvEventArray addObject:eventDictionary];
        }
    }
    cardArray = csvEventArray;
    
}

@end


