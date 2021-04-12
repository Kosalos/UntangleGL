#import "AppDelegate.h"
#import "EAGLView.h"

@implementation AppDelegate

@synthesize window;
@synthesize glView;
//@synthesize viewController = _viewController;

- (BOOL)application :(UIApplication *)application didFinishLaunchingWithOptions :(NSDictionary *)launchOptions
{
    self.glView = (EAGLView *)self.window.rootViewController.view;
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive :(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive :(UIApplication *)application
{
    [glView startAnimation];
}

- (void)applicationWillTerminate :(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
