# PNGSquaredExamples
PNGSquared Framework examples

This repo contains examples that demonstrate the PNGSquared Framework for iOS for improved compression vs PNG.

The UIImageLoad shows how a single image can be loaded into a UIImageView. The first target makes use of a storyboard with a named PNG in the compiled xib. The second target loads the same image data via an async PNGSquared API. There appears to be no way to seamlessly load a custom image when unarchiving from a storyboard, so this implementation shows how to work around that issue. The PNG compressed version of the image data is 1200 kB while the .png2 compressed version is just 382 kB.

The PNGSquaredCarousel would be 5.6 Megs using PNGs while it is just 2.2 Megs with PNGSquared.

The example TheElements is the classic Apple demo of table views and images, the default target loads PNGs while the second target overloads the UIImage imageNamed method to support automatically loading PNGSSquared compressed images in place of normal PNG images.

The example SwiftScale shows how the image loading logic on top of UIImage can be enabled in a Swift app. The example will load a 1x, 2x, or 3x image depending on the hardware type the app is being run on using standard resource naming rules.

