//
//  InspectorAnimation.m
//  SpriteBuilder
//
//  Created by John Twigg on 5/26/14.
//
//

#import "InspectorAnimation.h"
#import "CCBPCCBFile.h"
#import "CCBAnimationManager.h"

@implementation InspectorAnimation

-(void)refresh
{
    if([selection isKindOfClass:[CCBPCCBFile class]])
    {
        CCBPCCBFile * ccbFile = (CCBPCCBFile*)selection;
     
    
    }

    
    [self.animationsComboBox addItemsWithObjectValues:nil];
    
}

@end
