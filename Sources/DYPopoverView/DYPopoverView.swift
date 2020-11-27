//
//  ExpandingViewProvider.swift
//  ExpandingViewExample
//
//  Created by Dominik Butz on 30/11/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//

import Foundation
import SwiftUI

public enum PopoverType {
    case popover, popout
}

struct PopoverViewModifier<ContentView: View, BackgroundView: View>: ViewModifier {
    
    var contentView: ()->ContentView
    var backgroundView: ()->BackgroundView
    @Binding var show: Bool
    @Binding var frame: CGRect
    var popoverType: PopoverType
    var position: ViewPosition
    var viewId: String
    var settings: DYPopoverViewSettings
    
     func body(content: Content) -> some View {
        content
        .overlayPreferenceValue(DYPopoverViewOriginPreferenceKey.self) { preferences in

                 return GeometryReader { geometry in
                         ZStack {
                         
                            return self.popoverView(geometry, preferences, popoverType: self.popoverType, content: self.contentView, isPresented: self.$show, frame: self.$frame, background: self.backgroundView, position: self.position, viewId: self.viewId, settings: self.settings)

                         }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                 }
         }
    }
    
    internal func popoverView<ContentView: View, BackgroundView: View>(_ geometry: GeometryProxy, _ preferences: [DYPopoverViewOriginPreference], popoverType: PopoverType, @ViewBuilder content:  @escaping ()->ContentView, isPresented: Binding<Bool>, frame: Binding<CGRect>, background: @escaping ()->BackgroundView,  position: ViewPosition, viewId: String?, settings: DYPopoverViewSettings = DYPopoverViewSettings()) -> some View {

          let originPreference = preferences.first(where: { $0.viewId == viewId })
          let originBounds = originPreference != nil ? geometry[originPreference!.bounds] : .zero

         return  content()
             .modifier(PopoverFrame(isPresented: isPresented, viewFrame: frame.wrappedValue, originBounds: originBounds, popoverType: popoverType))
            .background(background().frame(width:frame.wrappedValue.width + settings.arrowLength * 2, height: frame.wrappedValue.height + settings.arrowLength * 2))
//             .background(RoundedArrowRectangle(arrowPosition: self.arrowPosition(viewPosition: position, settings: settings), arrowLength: settings.arrowLength, cornerRadius: settings.cornerRadius).fill(settings.backgroundColor))
             .opacity(viewId != nil && isPresented.wrappedValue ? 1 : 0)
            .clipShape(RoundedArrowRectangle(arrowPosition: self.arrowPosition(viewPosition: position, settings: settings), arrowLength: settings.arrowLength, cornerRadius: settings.cornerRadius))
            .shadow(color: settings.shadowColor, radius: settings.shadowRadius)
             .modifier(PopoverOffset(isPresented: isPresented, viewFrame: frame.wrappedValue, originBounds: originBounds, popoverType: popoverType, position: position, addOffset: settings.offset, arrowLength: settings.arrowLength))
             .animation(settings.animation)
          
      }
     
    internal func arrowPosition(viewPosition: ViewPosition, settings: DYPopoverViewSettings)->ViewPosition {
         
         return settings.differentArrowPosition == .none ? viewPosition.opposite : settings.differentArrowPosition

     }
}


internal struct PopoverFrame: ViewModifier {
    
    @Binding var isPresented:Bool
    
    var viewFrame: CGRect
    
    var originBounds: CGRect
    
    var popoverType: PopoverType
    
    func body(content: Content) -> some View {
        
        if popoverType == .popover {
            
            return content.frame(width:  viewFrame.width , height: viewFrame.height)
            
        } else {
            // popout
             return  content.frame(width: isPresented ? viewFrame.width : originBounds.width, height: isPresented ? viewFrame.height: originBounds.height)
        }
        
    }
    
}

internal struct PopoverOffset: ViewModifier {
    
    @Binding var isPresented:Bool
    
    var viewFrame: CGRect
    
    var originBounds: CGRect
    
    var popoverType: PopoverType
    
    var position: ViewPosition
    
    var addOffset: CGSize
    
    var arrowLength: CGFloat
    
    func body(content: Content) -> some View {
        
        if popoverType == .popover {
            return content.offset(x: self.offsetXFor(position: position, frame: viewFrame, originBounds: originBounds, arrowLength: arrowLength, addX: addOffset.width), y: self.offsetYFor(position: position, frame: viewFrame, originBounds: originBounds, arrowLength: arrowLength, addY: addOffset.height))
        } else {
            // popout
            return content.offset(x: isPresented ? self.offsetXFor(position: position, frame: viewFrame, originBounds: originBounds, arrowLength: arrowLength, addX: addOffset.width) : originBounds.minX, y: isPresented ?  self.offsetYFor(position: position, frame: viewFrame, originBounds: originBounds, arrowLength: arrowLength, addY: addOffset.height) : originBounds.minY)
        }
        
    }
    
    
    func offsetXFor(position: ViewPosition, frame: CGRect, originBounds: CGRect, arrowLength: CGFloat, addX: CGFloat)->CGFloat {
           
             let midX = originBounds.minX + (originBounds.size.width  - frame.size.width) / 2
         
           var offsetX: CGFloat = 0
        
           switch position {
               case .top, .bottom:
                   offsetX = midX
           case .left:
               offsetX = originBounds.minX - frame.size.width - arrowLength
           case .topLeft, .bottomLeft:
                   offsetX = originBounds.minX - frame.size.width
           case .right:
             offsetX = originBounds.minX  + originBounds.size.width + arrowLength
           case .topRight, .bottomRight:
                offsetX = originBounds.minX  + originBounds.size.width
            case .none:
                offsetX = 0
           }
        
           return offsetX + addX
       }
       
    func offsetYFor(position: ViewPosition, frame: CGRect, originBounds: CGRect, arrowLength: CGFloat, addY: CGFloat)->CGFloat {
           
           let midY = originBounds.minY + (originBounds.size.height -  frame.size.height) / 2
       
           var offsetY:CGFloat = 0
               
               switch position {
                   case .left, .right:
                       offsetY =  midY
                    case .top:
                        offsetY =  originBounds.minY - frame.size.height - arrowLength
                    case .topLeft, .topRight:
                       offsetY =  originBounds.minY - frame.size.height
                    case .bottom:
                        offsetY = originBounds.minY  + originBounds.size.height + arrowLength
                    case .bottomLeft, .bottomRight:
                       offsetY = originBounds.minY  + originBounds.size.height
                   case .none:
                       offsetY = 0
               }
           
           return offsetY + addY
       }
}


public struct AnchorView: ViewModifier {
    let viewId: String
     /**
     - Parameter content: content that the anchor is attached to.
     - Returns: the view with the anchor modifier.
  */
    public func body(content: Content) -> some View {
        content.anchorPreference(key: DYPopoverViewOriginPreferenceKey.self, value: .bounds) {  [DYPopoverViewOriginPreference(viewId: self.viewId, bounds: $0)]}
    }
}

public extension View {
    
    func anchorView(viewId: String)-> some View {
        self.modifier(AnchorView(viewId: viewId))
    }
}

public extension View {
    /**
    popoverView function.
     - Parameter content: the content that shall appear inside the popover view.
     - Parameter background: Background view of the DYPopover. Don't set a frame or decorations like shadow etc.
     - Parameter isPresented: pass in the state binding which determines if the popover should be displayed.
     - Parameter  frame: the frame of the popover view. As a Binding var, it can be changed during presentation is necessary.
     - Parameter popoverType: the type of the popover - popout or popover
     - Parameter position: one of eight different view positions of the popover.
    - Parameter viewId: Pass in a custom id for the origin view anchor from which the popover originates.
    - Parameter settings: a DYPopoverViewSettings struct. You can create a settings struct and override each property. If you don't pass in a settings struct, the default values will be used instead.
     - Returns: the popover view
    */
    func popoverView<ContentView: View, BackgroundView: View>(content: @escaping ()->ContentView, background: @escaping ()->BackgroundView, isPresented: Binding<Bool>, frame: Binding<CGRect>, popoverType: PopoverType, position: ViewPosition, viewId: String, settings:DYPopoverViewSettings = DYPopoverViewSettings())->some View  {
        self.modifier(PopoverViewModifier(contentView: content, backgroundView: background, show: isPresented,  frame: frame, popoverType: popoverType, position: position, viewId: viewId, settings: settings))
    }
}




// DYPopoverViewSettings struct
public struct DYPopoverViewSettings {
    /// DYPopoverViewSettings initializer
    
    /**
    DYPopoverSettings initializer.
      - Parameter arrowLength : the length of the arrow. if you set it to 0, the popover will be without arrow.
     - Parameter differentArrowPosition: change the position of the arrow to a different position than the opposite of the view position. default is none - the position will be opposite to the position of the view relative to its anchor view.
     - Parameter  cornerRadius: corner radius tuple for top left, top right, bottom left, bottom right values.
     - Parameter shadowRadius: shadow radius of the popover view background
     - Parameter shadowColor: the background shadow color
    - Parameter offset: allows to change the position of the popover in presented state. default: no offset
    - Parameter animation: animation which determines how the popover shall appear.
    */
    public init(arrowLength: CGFloat = 20, differentArrowPosition: ViewPosition = .none, cornerRadius:(tl:CGFloat, tr:CGFloat, bl: CGFloat, br: CGFloat) = (tl:10, tr:10, bl:10, br:10), shadowRadius: CGFloat = 10, shadowColor: Color = Color(.systemGray3), offset: CGSize = CGSize.zero, animation: Animation = .spring() ){
        
        self.arrowLength = arrowLength
        self.differentArrowPosition = differentArrowPosition
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor
        self.offset = offset
        self.animation = animation
        
    }
    /// shadow radius of the popover view.
    var shadowRadius: CGFloat
    ///the background shadow color
    var shadowColor: Color
  /// animation which determines how the popover shall appear.
    var animation: Animation
    /// allows to change the position of the popover in presented state. default: no offset
    var offset: CGSize
    ///change the position of the arrow to a different position than the opposite of the view position. default is none - the position will be opposite to the position of the view relative to its anchor view.
    var differentArrowPosition: ViewPosition
    // the length of the arrow. if you set it to 0, the popover will be without arrow.
    var arrowLength: CGFloat
    ///corner radius tuple for top left, top right, bottom left, bottom right values.
   var cornerRadius: (tl:CGFloat, tr:CGFloat, bl: CGFloat, br: CGFloat)
}

///DYPopoverViewOriginBoundsPreferenceKey
 struct DYPopoverViewOriginPreferenceKey: PreferenceKey {
    ///DYPopoverViewOriginPreferenceKey initializer.
     init() {}
    ///DYPopoverViewOriginPreferenceKey value array
     typealias Value = [DYPopoverViewOriginPreference]
    ///DYPopoverViewOriginPreferenceKey default value array
     static var defaultValue: [DYPopoverViewOriginPreference] = []
    ///DYPopoverViewOriginPreferenceKey reduce function. modifies the sequence by adding a new value if needed.
     static func reduce(value: inout [DYPopoverViewOriginPreference], nextValue: () -> [DYPopoverViewOriginPreference]) {
        //value[0] = nextValue().first!
        value.append(contentsOf: nextValue())
        
    }
}

///DYPopoverViewOriginPreference: holds an identifier for the origin view  of the popover and its bounds anchor.
 struct DYPopoverViewOriginPreference  {
    ///DYPopoverViewOriginPreference initializer
     init(viewId: String, bounds: Anchor<CGRect>) {
        self.viewId  = viewId
        self.bounds = bounds
    }
    ///popover origin view identifier.
     var viewId: String
    /// popover origin view bounds Anchor.
     var bounds: Anchor<CGRect>
}

