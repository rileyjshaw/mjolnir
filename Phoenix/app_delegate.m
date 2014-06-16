#import <Cocoa/Cocoa.h>

#import "lua/lauxlib.h"
#import "lua/lualib.h"

int hotkey_setup(lua_State *L);
int hotkey_register(lua_State *L);
int hotkey_unregister(lua_State *L);

int app_running_apps(lua_State* L);
int app_get_windows(lua_State* L);
int app_title(lua_State* L);
int app_show(lua_State* L);
int app_hide(lua_State* L);
int app_kill(lua_State* L);
int app_kill9(lua_State* L);
int app_is_hidden(lua_State* L);

int mouse_get(lua_State* L);
int mouse_set(lua_State* L);

int autolaunch_get(lua_State* L);
int autolaunch_set(lua_State* L);

int alert_show(lua_State* L);

int menu_icon_show(lua_State* L);
int menu_icon_hide(lua_State* L);

int pathwatcher_stop(lua_State* L);
int pathwatcher_start(lua_State* L);

int window_get_focused_window(lua_State* L);
int window_title(lua_State* L);
int window_is_standard(lua_State* L);
int window_topleft(lua_State* L);
int window_size(lua_State* L);
int window_settopleft(lua_State* L);
int window_setsize(lua_State* L);
int window_minimize(lua_State* L);
int window_unminimize(lua_State* L);
int window_isminimized(lua_State* L);
int window_pid(lua_State* L);
int window_focus(lua_State* L);
int window_subrole(lua_State* L);
int window_role(lua_State* L);

int screen_get_screens(lua_State* L);
int screen_get_main_screen(lua_State* L);
int screen_frame(lua_State* L);
int screen_visible_frame(lua_State* L);

static const luaL_Reg phoenix_lib[] = {
    {"hotkey_setup", hotkey_setup},
    {"hotkey_register", hotkey_register},
    {"hotkey_unregister", hotkey_unregister},
    
    {"app_running_apps", app_running_apps},
    {"app_get_windows", app_get_windows},
    {"app_title", app_title},
    {"app_show", app_show},
    {"app_hide", app_hide},
    {"app_kill", app_kill},
    {"app_kill9", app_kill9},
    {"app_is_hidden", app_is_hidden},
    
    {"mouse_get", mouse_get},
    {"mouse_set", mouse_set},
    
    {"autolaunch_get", autolaunch_get},
    {"autolaunch_set", autolaunch_set},
    
    {"alert_show", alert_show},
    
    {"menu_icon_show", menu_icon_show},
    {"menu_icon_hide", menu_icon_hide},
    
    {"pathwatcher_stop", pathwatcher_stop},
    {"pathwatcher_start", pathwatcher_start},
    
    {"window_get_focused_window", window_get_focused_window},
    {"window_title", window_title},
    {"window_is_standard", window_is_standard},
    {"window_topleft", window_topleft},
    {"window_size", window_size},
    {"window_settopleft", window_settopleft},
    {"window_setsize", window_setsize},
    {"window_minimize", window_minimize},
    {"window_unminimize", window_unminimize},
    {"window_isminimized", window_isminimized},
    {"window_pid", window_pid},
    {"window_focus", window_focus},
    {"window_subrole", window_subrole},
    {"window_role", window_role},
    
    {"screen_get_screens", screen_get_screens},
    {"screen_get_main_screen", screen_get_main_screen},
    {"screen_frame", screen_frame},
    {"screen_visible_frame", screen_visible_frame},
    
    {NULL, NULL}
};


@interface PHAppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation PHAppDelegate

- (void) complainIfNeeded {
    BOOL enabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @(YES)});
    
    if (!enabled) {
        NSRunAlertPanel(@"Enable Accessibility First",
                        @"Find the little popup right behind this one, click \"Open System Preferences\" and enable Phoenix. Then launch Phoenix again.",
                        @"Quit",
                        nil,
                        nil);
        [NSApp terminate:self];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self complainIfNeeded];
    
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    luaL_newlib(L, phoenix_lib);
    lua_setglobal(L, "__api");
    
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* initFile = [bundlePath stringByAppendingPathComponent:@"phoenix_init.lua"];
    
    luaL_loadfile(L, [initFile fileSystemRepresentation]);
    lua_pushstring(L, [bundlePath fileSystemRepresentation]);
    lua_pcall(L, 1, LUA_MULTRET, 0);
}

@end