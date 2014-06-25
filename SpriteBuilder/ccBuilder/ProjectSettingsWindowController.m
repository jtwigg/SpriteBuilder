/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ProjectSettingsWindowController.h"
#import "AppDelegate.h"
#import "ProjectSettings.h"
#import "NSString+RelativePath.h"
#import "CCBWarnings.h"

@implementation ProjectSettingsWindowController

- (instancetype)init
{
    self = [self initWithWindowNibName:@"ProjectSettingsWindow"];
    if (self)
    {

    }
    return self;
}

-(void) windowDidLoad
{
	[super windowDidLoad];
	
	if ([AppDelegate appDelegate].projectSettings.engine == CCBTargetEngineSpriteKit)
	{
		// in Sprite Kit projects exporting to non-Retina iPhones makes no sense
		_publishiPhoneCheckbox.enabled = NO;
	}
}

- (IBAction)selectPublishDirectoryIOS:(id)sender
{
    [self selectPublishDirForType:kCCBPublisherTargetTypeIPhone];
}

- (IBAction)selectPublishDirectoryAndroid:(id)sender
{
    [self selectPublishDirForType:kCCBPublisherTargetTypeAndroid];
}

- (void)selectPublishDirForType:(CCBPublisherTargetType)publishType
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];

    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [[[CCDirector sharedDirector] view] lockOpenGLContext];

            NSArray* files = [openDlg URLs];
            for (NSUInteger i = 0; i < [files count]; i++)
            {
                NSString* dirName = [[files objectAtIndex:i] path];
                NSString* projectDir = [_projectSettings.projectPath stringByDeletingLastPathComponent];
                NSString* relDirName = [dirName relativePathFromBaseDirPath:projectDir];
                
                if (publishType == kCCBPublisherTargetTypeIPhone)
                {
                    _projectSettings.publishDirectory = relDirName;
                }
                else if (publishType == kCCBPublisherTargetTypeAndroid)
                {
                    _projectSettings.publishDirectoryAndroid = relDirName;
                }
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
    }];
}

@end
