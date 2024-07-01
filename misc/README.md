# README

## HOWTO build missionControlFullDesktopBar

How to build with Xcode and find the built artifact:

Clone the missionControlFullDesktopBar repository

git clone https://github.com/briankendall/missionControlFullDeskopBar
Open missionControlFullDeskopBar.xcodeproj in Xcode.

Build the project (⌘B).

Find out where it went by checking File -> Project Settings.... On my machine it's ~/Library/Developer/Xcode/DerivedData/.

And there will be a folder in there that starts with the project name (e.g., missionControlFullDeskopBar-cjhllkdjkhncuzglpiezmyqmdufu).

Copy the app to /Applications, using Finder to trigger any macOS permissions needed:

* open ~/Library/Developer/Xcode/DerivedData/missionControlFullDesktopBar-cecfmmntuhizngavuwnoabrsqvib/Build/Products/Debug
* Drag and drop missionControlFullDesktopBar.app to Applications
