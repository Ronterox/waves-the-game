# Wasm is just an array of text so can use brotli for it besides the zip -9
# (Same as the PCK)

"""
Same as UPX there is a WASM-OPT (binaryen) for optimization

wasm-opt <original.wasm> -o <optimized.wasm> -all --post-emscripten -Oz

                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2025
UPX 5.0.2       Markus Oberhumer, Laszlo Molnar & John Reiser   Jul 20th 2025

"""
# ref: https://popcar.bearblog.dev/how-to-minify-godots-build-size/
# scons --help shows flags
# scons platform=web target=template_release profile=custom.py
# web requires emscript wasm compiler
# 4.4 have a way to disable all and specify only what you need
# 4.5 have a new size-full optimization

# Basic stuff
debug_symbols = "no"
optimize = "size"
lto = "none"  # full for binary, none for web

# disable_3d="yes" # If not needed

module_text_server_adv_enabled = "no"  # Right To Left, and open type fonts
module_text_server_fb_enabled = "yes"
module_navigation_enabled = "no"
module_mobile_vr_enabled = "no"

disable_advanced_gui = "yes"  # Either this or specify any node

deprecated = "no"  # Disables deprecated features
vulkan = "no"      # Disables the Vulkan driver (used in Forward+/Mobile Renderers)
use_volk = "no"    # Disables more Vulkan stuff
openxr = "no"      # Disables Virtual Reality/Augmented Reality stuff
minizip = "no"     # Disables ZIP archive support
