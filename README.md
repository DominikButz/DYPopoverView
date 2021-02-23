# DYPopoverView

[![Version](https://img.shields.io/cocoapods/v/DYPopoverView.svg?style=flat)](https://cocoapods.org/pods/DYPopoverView)
[![License](https://img.shields.io/cocoapods/l/DYPopoverView.svg?style=flat)](https://cocoapods.org/pods/DYPopoverView)
[![Platform](https://img.shields.io/cocoapods/p/DYPopoverView.svg?style=flat)](https://cocoapods.org/pods/DYPopoverView)


DYPopoverView is a simple SwiftUI accessory popover view for iOS and iPadOS. Works on iOS / iPadOS 13 or later. 

## Example project

This repo only contains the Swift package, no example code. Please download the example project [here](https://github.com/DominikButz/DYPopoverViewExample.git).
You need to add the DYPopoverView package either through cocoapods or the Swift Package Manager (see below - Installation). 

## Features

* 8 positions with automatically adapting arrow position
* set as popout or popover
* Customize the following settings:
	- animation
	- offset
	- differentArrowPosition
	- arrowLength
	- cornerRadius

	Check out the examples for details. 


## Installation


Installation through the Swift Package Manager (SPM) or cocoapods is recommended. 

SPM:
Select your project (not the target) and then select the Swift Packages tab. Click + and type DYPopoverView - SPM should find the package on github. 

Cocoapods:

platform :ios, '13.0'

target '[project name]' do
 	pod 'DYPopoverView'
end


Check out the version history below for the current version.


Make sure to import DYPopoverView in every file where you use DYPopoverView. 

```Swift
    import DYPopoverView
```

## Usage

Check out the following example. This repo only contains the Swift package, no example code. Please download the example project [here](https://github.com/DominikButz/DYPopoverViewExample.git).


![DYPopoverView example](gitResources/example01.gif) 


### Code example: Content View (your main view)


DYPopoverView needs to be attached to another view by adding the anchorView modifier to it including a view id. Alternatively, it can be initialized with an anchorFrame - make sure to attach the anchorFrame modifier to your anchor view instead of the anchorView id. The anchor view can be several levels below in the view hierarchy relative to the view that you apply the popoverView-modifier to. 
See the following example for details.

```Swift

import DYPopoverView

struct PopoverPlayground: View {
    
    @State private var showSecondPopover = false
    @State private var showFirstPopover  = false
    @State private var showNavPopover = false
    
    @State private var navBarPopoverOriginFrame: CGRect = .zero
    @State private var secondPopoverFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.75, height:150 )

    @State private  var popoverPosition: ViewPosition = .top
    
    var body: some View {
        GeometryReader {  proxy in
            NavigationView {
                
                    VStack(alignment: .center) {
               
                    Spacer()
                  
                    Button(action: {

                        self.showFirstPopover.toggle()
                           
                       }) {
                           TranslucentTextButtonView(title: "Popout", foregroundColor: .red, backgroundColor: .red, frameWidth: 100)
                    }.anchorView(viewId: "firstPopover").padding()
                           
                        Button(action: {
                           // self.viewId = "1"
                            self.showSecondPopover.toggle()
                          }) {
                            TranslucentTextButtonView(title: "Popover", foregroundColor: .accentColor, backgroundColor: .accentColor, frameWidth: 100).anchorView(viewId: "secondPopover")
                        }

                        Spacer()
                    
                        Picker("", selection: self.$popoverPosition) {
                            ForEach(0 ..< ViewPosition.allCases.count) {
                                Text(ViewPosition.allCases[$0].rawValue).tag(ViewPosition.allCases[$0])
                            }
                        }
                         
                    }
                    .frame(width: proxy.size.width).background(Color(.systemBackground))

                    .navigationBarItems(trailing: self.navBarButton )
                    .navigationTitle(Text("Test"))
              }
            .popoverView(content: { Text("Content")}, background: { Color(.secondarySystemBackground).onTapGesture {
                self.showNavPopover = false
            } }, isPresented: self.$showNavPopover, frame: .constant(CGRect(x:0, y:0, width: 200, height: 200)), anchorFrame: self.navBarPopoverOriginFrame, popoverType: .popout, position: .bottomLeft, viewId: "")
            .popoverView(content: {Text("Some content")}, background: {BlurView(style: .systemChromeMaterial)}, isPresented: self.$showFirstPopover, frame: .constant(CGRect(x: 0, y: 0, width: 150, height: 150)),  anchorFrame: nil, popoverType: .popout, position: self.popoverPosition, viewId: "firstPopover", settings: DYPopoverViewSettings(shadowRadius: 20))
            .popoverView(content: {ContentExample(frame: self.$secondPopoverFrame, show:self.$showSecondPopover)}, background: {Color(.secondarySystemBackground)}, isPresented: self.$showSecondPopover, frame: self.$secondPopoverFrame, anchorFrame: nil, popoverType: .popover, position: self.popoverPosition, viewId: "secondPopover", settings: DYPopoverViewSettings(cornerRadius: (30, 30, 30, 30)))
            
        }
    }
    
    var navBarButton: some View {
        Button(action: {
            self.showNavPopover.toggle()
        }, label: {
            Text("Pop")
        })
        .anchorFrame(rect: self.$navBarPopoverOriginFrame)
    }
}
   

```


## Change log

#### [Version1.1.1](https://github.com/DominikButz/DYPopoverView/releases/tag/1.1.1)
Minor changes.

#### [Version 1.1](https://github.com/DominikButz/DYPopoverView/releases/tag/1.1)
 Added alternative way to initialize popover - with an anchorFrame instead of a view id. 
 If the anchor view is a NavigationBar item, the popover does not always appear properly if initialized with a view id.

 #### [Version 1.0.1](https://github.com/DominikButz/DYPopoverView/releases/tag/1.0.1)
 slight improvment for navigation item as anchor view.
 
 #### [Version 1.0](https://github.com/DominikButz/DYPopoverView/releases/tag/1.0)
  Initializer changed - added background. Removed backgroundColor from settings. 
  

#### [Version 0.2](https://github.com/DominikButz/DYPopoverView/releases/tag/0.2)
 Initializer changed - the content view needs to be put in a closure instead of casting it to AnyView.
 
#### [Version 0.1](https://github.com/DominikButz/DYPopoverView/releases/tag/0.1)

Initial public release. 


## Author

dominikbutz@gmail.com

## License

DYPopoverView is available under the MIT license. See the LICENSE file for more info.

