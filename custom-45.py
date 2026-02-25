"""
This isn't a very advertised feature since it's still a work-in-progress,
but Godot actually has a built-in feature to let you include/exclude things you want to compile.
This includes general features like Vulkan and physics engines, but more notably,
it lets you disable nodes and resources one-by-one!

You can access it inside Godot itself by going to Project>Tools>Engine Compilation Configuration Editor.
From here, you can toggle options then save your settings as a .build file.

By exporting the custom.build file and putting it next to the custom.py file,
we can compile only the nodes and resources used in our project with this command:
scons platform=windows profile=custom.py build_profile=custom.build.

The good news is that there's an autodetect feature to quickly disable everything you don't use.
The bad news is that it's pretty unreliable and disables classes that Godot needs to run.
In my case, it disabled MainLoop, StyleBox, KinematicCollision2D, TextServer, and TextServerManager.

All of those are needed to run the game. The other good news is that the build file is human-readable,
so I just opened it up and removed their names from the list of disabled classes.

How did I know those classes were needed, you say? The answer is the game will crash on launch if you don't have them,
printing errors in the console shouting that a specific class is missing.

Yup, you'll need a bit of trial and error if you're using the autodetect feature...
But it's better than manually disabling ~400 classes yourself.
"""
# scons platform=windows profile=custom.py build_profile=build_config.gdbuild
target = "template_release"
debug_symbols = "no"
optimize = "size_extra"  # Godot >4.5 only. Otherwise, use optimize="size"
lto = "full"  # Much slower build times, smaller export size

disable_3d = "yes"
disable_advanced_gui = "yes"

deprecated = "no"  # Disables deprecated features
vulkan = "no"      # Disables the Vulkan driver (used in Forward+/Mobile Renderers)
use_volk = "no"    # Disables more Vulkan stuff
openxr = "no"      # Disables Virtual Reality/Augmented Reality stuff
minizip = "no"     # Disables ZIP archive support
graphite = "no"    # Disables SIL Graphite smart fonts support

modules_enabled_by_default = "no"     # Disables all modules so you can only enable what you need
module_gdscript_enabled = "yes"
# Fallback text server; less features but works fine for English.
module_text_server_fb_enabled = "yes"
module_freetype_enabled = "yes"       # Needed alongside a text server for text to render correctly
module_svg_enabled = "yes"
module_webp_enabled = "yes"
module_godot_physics_2d_enabled = "yes"

# These next few options were introduced in Godot 4.5!
disable_navigation_2d = "yes"
disable_navigation_3d = "yes"
disable_xr = "yes"
accesskit = "no"  # Disables the new accessibility features
