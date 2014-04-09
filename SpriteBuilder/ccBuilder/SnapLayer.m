//
//  SnapLayer.m
//  SpriteBuilder
//
//  Created by Michael Daniels on 4/8/14.
//
//

#import "SnapLayer.h"
#import "AppDelegate.h"
#import "CocosScene.h"
#import "CCNode+PositionExtentions.h"
#import "PositionPropertySetter.h"

#define kOptionKey 58

@interface SnapLayer() {
    BOOL optionKeyDown;
    float sensitivity;
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) CCDrawNode *drawLayer;
@property (nonatomic, strong) NSMutableArray *verticalSnapLines;
@property (nonatomic, strong) NSMutableArray *horizontalSnapLines;

@end

@implementation SnapLayer

@synthesize appDelegate;
@synthesize drawLayer;
@synthesize verticalSnapLines;
@synthesize horizontalSnapLines;

#pragma mark - Setup

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    appDelegate = [AppDelegate appDelegate];
    sensitivity = 4;
    drawLayer = [CCDrawNode node];
    verticalSnapLines = [NSMutableArray new];
    horizontalSnapLines = [NSMutableArray new];
    [self addChild:drawLayer];
    [self setupOptionKeyListener];
}

- (void)setupOptionKeyListener {
    [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^NSEvent *(NSEvent *incomingEvent) {
        if(incomingEvent.keyCode == kOptionKey) {
            if(incomingEvent.modifierFlags & NSAlternateKeyMask) {
                optionKeyDown = YES;
            } else {
                optionKeyDown = NO;
            }
        }
        return incomingEvent;
    }];
}

#pragma mark - Memory Management

- (void)dealloc {
    [NSEvent removeMonitor:self];
}

#pragma mark - Drawing

- (void)drawLines {
    [drawLayer clear];
    
    CocosScene* cs = [CocosScene cocosScene];
    for(NSNumber *x in verticalSnapLines) {
        CGPoint start = [cs convertToViewSpace:ccp([x floatValue], 0)];
        CGPoint end = [cs convertToViewSpace:ccp([x floatValue], cs.stageSize.height)];
        [drawLayer drawSegmentFrom:start to:end radius:1 color:[CCColor whiteColor]];
    }
    for(NSNumber *y in horizontalSnapLines) {
        CGPoint start = [cs convertToViewSpace:ccp(0, [y floatValue])];
        CGPoint end = [cs convertToViewSpace:ccp(cs.stageSize.width, [y floatValue])];
        [drawLayer drawSegmentFrom:start to:end radius:1 color:[CCColor whiteColor]];
    }
}

#pragma mark - Snap Lines Methods

- (void)updateLines {
    [self findSnappedLines];
    [self drawLines];
}

- (void)findSnappedLines {
    [verticalSnapLines removeAllObjects];
    [horizontalSnapLines removeAllObjects];
    CCNode *sNode = appDelegate.selectedNode;
    for(CCNode *node in sNode.parent.children) { // Get all the nodes in the same node as the selected node
        if(node != appDelegate.selectedNode) { // Ignore the selected node
            // Snap lines from center
            NSPoint point = [sNode convertPositionToPoints:sNode.position type:sNode.positionType];
            NSPoint nPoint = [sNode convertPositionToPoints:node.position type:node.positionType];
            if(point.x == nPoint.x) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:point.x]];
            }
            if(point.y == nPoint.y) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:point.y]];
            }
            
            // Snap lines for opposite sides
            if(abs(sNode.leftInPoints - node.rightInPoints) < 1) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.leftInPoints]];
            }
            if(abs(sNode.rightInPoints - node.leftInPoints) < 1) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.rightInPoints]];
            }
            if(abs(sNode.topInPoints - node.bottomInPoints) < 1) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.topInPoints]];
            }
            if(abs(sNode.bottomInPoints - node.topInPoints) < 1) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.bottomInPoints]];
            }
            
            // Snap lines for same sides
            if(abs(sNode.leftInPoints - node.leftInPoints) < 1) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.leftInPoints]];
            }
            if(abs(sNode.rightInPoints - node.rightInPoints) < 1) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.rightInPoints]];
            }
            if(abs(sNode.topInPoints - node.topInPoints) < 1) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.topInPoints]];
            }
            if(abs(sNode.bottomInPoints - node.bottomInPoints) < 1) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.bottomInPoints]];
            }
            
        }
    }
}

#pragma mark - Snapping Methods

- (void)snapIfNeeded {
    if(!optionKeyDown) { // Don't snap if the user is holding the option key
        CCNode *sNode = appDelegate.selectedNode;
        if(appDelegate.selectedNode.parent) {
            for(CCNode *node in appDelegate.selectedNode.parent.children) {
                if(node != appDelegate.selectedNode) {
                    NSPoint point = [sNode convertPositionToPoints:sNode.position type:sNode.positionType];
                    NSPoint nPoint = [sNode convertPositionToPoints:node.position type:node.positionType];
                    float newX = point.x;
                    float newY = point.y;
                    
                    // Snap from center
                    if(abs(point.x - nPoint.x) < sensitivity) {
                        newX = nPoint.x;
                    } if(abs(point.y - nPoint.y) < sensitivity) {
                        newY = nPoint.y;
                    }
                    point = [sNode convertPositionFromPoints:NSMakePoint(newX, newY) type:sNode.positionType];
                    appDelegate.selectedNode.position = point;
                    
                    // Snap to opposite sides
                    if(abs(sNode.leftInPoints - node.rightInPoints) < sensitivity) {
                        sNode.leftInPoints = node.rightInPoints;
                    } else if(abs(sNode.rightInPoints - node.leftInPoints) < sensitivity) {
                        sNode.rightInPoints = node.leftInPoints;
                    }
                    if(abs(sNode.topInPoints - node.bottomInPoints) < sensitivity) {
                        sNode.topInPoints = node.bottomInPoints;
                    } else if(abs(sNode.bottomInPoints - node.topInPoints) < sensitivity) {
                        sNode.bottomInPoints = node.topInPoints;
                        newY = sNode.position.y;
                    }
                    
                    // Snap to same sides
                    if(abs(sNode.leftInPoints - node.leftInPoints) < sensitivity) {
                        sNode.leftInPoints = node.leftInPoints;
                    } else if(abs(sNode.rightInPoints - node.rightInPoints) < sensitivity) {
                        sNode.rightInPoints = node.rightInPoints;
                        newX = sNode.position.x;
                    }
                    if(abs(sNode.topInPoints - node.topInPoints) < sensitivity) {
                        sNode.topInPoints = node.topInPoints;
                    } else if(abs(sNode.bottomInPoints - node.bottomInPoints) < sensitivity) {
                        sNode.bottomInPoints = node.bottomInPoints;
                        newY = sNode.position.y;
                    }
                    
                }
            }
        }
    }
    [self findSnappedLines];
}

#pragma mark - Mouse Events

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    if ([appDelegate.selectedNode hitTestWithWorldPos:pt]) {
        [self updateLines];
    } else {
        [drawLayer clear];
    }
    
    return success;
}

- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    [self snapIfNeeded];
    [self drawLines];
    
    return success;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    if ([appDelegate.selectedNode hitTestWithWorldPos:pt]) {
        [self updateLines];
    } else {
        [drawLayer clear];
    }
    
    return success;
}

@end
