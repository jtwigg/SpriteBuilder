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

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e
{
	NSAssert([s conformsToProtocol:@protocol(SBAnimatableNode) ], @"Should conform to this protocol");
	
	return [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
}

-(void)refresh
{
    [self.animationsComboBox addItemsWithObjectValues:self.animatableNode.animations];
    
}

-(id<SBAnimatableNode>)animatableNode
{
	return (id<SBAnimatableNode>)selection;
}

@end
