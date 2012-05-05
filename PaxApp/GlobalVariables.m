//
//  GlobalVariablePositions.m
//  PaxApp
//
//  Created by Junyuan Lau on 20/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlobalVariables.h"



@implementation GlobalVariables

@synthesize gDriverList, gUserCoordinate, gPickupString, gDestinationString, gDriver_id, gJob_id, gUserAddress;

static GlobalVariables* myGlobalVariables;

+ (GlobalVariables*)myGlobalVariables
{
    if (!myGlobalVariables) {
        myGlobalVariables = [[GlobalVariables alloc] init];
    }
    return myGlobalVariables;
}


- (void) clearGlobalData
{
    gDriverList = nil;
    gDriver_id = nil;
    gJob_id = nil;
    gUserAddress = nil;
    
}
//[[GlobalVariablePositions myGlobalVariablePositions] setSavedString:@"HELLO"]; - eg setting gvs
@end