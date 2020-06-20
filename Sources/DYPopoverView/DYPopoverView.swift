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

 struct PopoverViewModifier: ViewModifier {
    
    var contentView: AnyView
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
                         
                            return self.popoverView(geometry, preferences, popoverType: self.popoverType, content: AnyView(self.contentView), isPresented: self.$show, frame: self.$frame, position: self.position, viewId: self.viewId, settings: self.settings)

                         }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                 }
         }
    }
    
     internal func popoverView(_ geometry: GeometryProxy, _ preferences: [DYPopoverViewOriginPreference], popoverType: PopoverType, content: AnyView, isPresented: Binding<Bool>, frame: Binding<CGRect>, position: ViewPosition, viewId: String?, settings: DYPopoverViewSettings = DYPopoverViewSettings()) -> some View {

          let originPreference = preferences.first(where: { $0.viewId == viewId })
          let originBounds = originPreference != nil ? geometry[originPreference!.bounds] : .zero

         return  content
             .modifier(PopoverFrame(isPresented: isPresented, viewFrame: frame.wrappedValue, originBounds: originBounds, popoverType: popoverType))
             .background(RoundedArrowRectangle(arrowPosition: self.arrowPosition(viewPosition: position, settings: settings), arrowLength: settings.arrowLength, cornerRadius: settings.cornerRadius).fill(settings.backgroundColor))
             .opacity(viewId != nil && isPresented.wrappedValue ? 1 : 0)
             .clipShape(RoundedArrowRectangle(arrowPosition: self.arrowPosition(viewPosition: position, settings: settings), arrowLength: settings.arrowLength, cornerRadius: settings.cornerRadius)).shadow(radius: settings.shadowRadius)
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
     - Parameter isPresented: pass in the state binding which determines if the popover should be displayed.
     - Parameter  frame: the frame of the popover view. As a Binding var, it can be changed during presentation is necessary.
     - Parameter popoverType: the type of the popover - popout or popover
     - Parameter position: one of eight different view positions of the popover.
    - Parameter viewId: Pass in a custom id for the origin view anchor from which the popover originates.
    - Parameter settings: a DYPopoverViewSettings struct. You can create a settings struct and override each property. If you don't pass in a settings struct, the default values will be used instead.
     - Returns: the popover view
    */
    func popoverView(content: AnyView, isPresented: Binding<Bool>, frame: Binding<CGRect>, popoverType: PopoverType, position: ViewPosition, viewId: String, settings:DYPopoverViewSettings = DYPopoverViewSettings())->some View  {
        self.modifier(PopoverViewModifier(contentView: content, show: isPresented,  frame: frame, popoverType: popoverType, position: position, viewId: viewId, settings: settings))
    }
}




// DYPopoverViewSettings struct
public struct DYPopoverViewSettings {
    /// DYPopoverViewSettings initializer
    public init(){}
    /// shadow radius of the popover view.
    public var shadowRadius: CGFloat = 10
    /// background of the popover view
    public var backgroundColor: Color = Color(.secondarySystemBackground)
  /// animation which determines how the popover shall appear.
    public var animation: Animation = .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 1)
    /// allows to change the position of the popover in presented state. default: no offset
    public var offset: CGSize = CGSize.zero
    ///change the position of the arrow to a different position than the opposite of the view position. default is none - the position will be opposite to the position of the view relative to its anchor view.
    public var differentArrowPosition: ViewPosition = .none
    // the length of the arrow. if you set it to 0, the popover will be without arrow.
    public var arrowLength: CGFloat = 20
    ///corner radius tuple for top left, top right, bottom left, bottom right values.
    public  var cornerRadius: (tl:CGFloat, tr:CGFloat, bl: CGFloat, br: CGFloat) = (tl:10, tr:10, bl:10, br:10)
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

