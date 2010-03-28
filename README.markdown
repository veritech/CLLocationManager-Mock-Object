****
CLLocationManager-Mock
======================

What is it for?
===============

It allows you to send pre-defined locations to any object that is a delegate of CLLocationManager, including MapView!
These locations are supplied from a file.

With a slight tweak this code can be made to work on a device, however at the moment it only works on the simulator

How do i use it?
================

1. Enter your locations in the "locations.plist" file (You can use any other file, but it needs to adhere to the Serialized NSArray format) A sample file has been supplied. Coordinates should be comma seperated in the format latitude,longitude
2. Change the *LOCATIONS_FILE_PATH* compiler constant to the absolute location of the locations.plist file
3. Add the CLLocationManger-Mock *.h & *.m files to your project. I'm still unclear as to whether you need to import them or not but i believe as long as they are part of your development target it should work.

Problems & and things you could improve
=======================================

This is hacked together implementation. You can't share state in Objective-C categories, so the class uses an internal singleton, and a lot of ugly code to enable it to serve multiple instances.
Cleaning it up would be much appreciated :)

Please go forth and fork and make this actually look nice!

Author
======

[Jonathan Dalrymple](mailto:jonathan@float-right.co.uk)
