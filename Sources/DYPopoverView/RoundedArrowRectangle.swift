//
//  File.swift
//  
//
//  Created by Dominik Butz on 26/4/2020.
//

import Foundation
import SwiftUI

public enum ViewPosition:String, CaseIterable {
    
    case top = "Top", topRight = "Top Right", right = "Right", bottomRight = "Bottom Right", bottom = "Bottom", bottomLeft = "Bottom Left", left = "Left", topLeft = "Top Left", none = "None"
    
    var opposite: ViewPosition {
        switch self {
        case .top:
            return .bottom
        case .topRight:
            return .bottomLeft
        case .right:
            return .left
        case .bottomRight:
            return .topLeft
        case .bottom:
            return .top
        case .bottomLeft:
            return .topRight
        case .left:
            return .right
        case .topLeft :
            return .bottomRight
        default:
            return .none
        }
    }
}


struct RoundedArrowRectangle: Shape {
    // arrow position, not the position of the popover!
    let arrowPosition: ViewPosition
    let arrowLength: CGFloat
    let cornerRadius: (tl:CGFloat, tr:CGFloat, bl: CGFloat, br: CGFloat)

    func path(in rect: CGRect) -> Path {
      
        let w = rect.size.width
        let h = rect.size.height
        let tr = min(min(self.cornerRadius.tr, h/2), w/2)
        let tl = min(min(self.cornerRadius.tl, h/2), w/2)
        let bl = min(min(self.cornerRadius.bl, h/2), w/2)
        let br = min(min(self.cornerRadius.br, h/2), w/2)
        
        let maxX = rect.maxX
        let minX = rect.minX
        let maxY = rect.maxY
        let minY = rect.minY


        let triangleSideLength : CGFloat = arrowLength / CGFloat(sqrt(0.75))
        
        let actualArrowPosition: ViewPosition = self.arrowLength > 0  ? self.arrowPosition : .none

        var path = Path()
 
        path.move(to: CGPoint(x: minX , y: minY))

        if actualArrowPosition == .top {
            path = self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)
        }
        // top right arrow
        if actualArrowPosition == .topRight {
          path = self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else {
            // top right corner
            path.addLine(to: CGPoint(x: w - tr, y: minY))
            path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                        startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            
        }

        // right arrow if needed
        if actualArrowPosition == .right {
           path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

         }

        // bottom right arrow if needed
        if actualArrowPosition == .bottomRight {
          path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else {
            // bottom right corner
            path.addLine(to: CGPoint(x: maxX, y: h - br))
            path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                        startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        }
       
        // bottom arrow
        if actualArrowPosition == .bottom {
            path = self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)
            path.addLine(to: CGPoint(x: bl, y: maxY))
            path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                               startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            // or bottom left arrow
        } else if actualArrowPosition == .bottomLeft {
            path = self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else { // or straight line + bottom left corner
            path.addLine(to: CGPoint(x: bl, y: maxY))
            path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                               startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        }
      
       // line + left arrow
        if actualArrowPosition == .left {
           path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)
       
            // and top left corner:
             path.addLine(to: CGPoint(x: minX, y: tl))
             path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                                   startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            
        } else if actualArrowPosition == .topLeft {
            // top left arrow
           path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else {
            // line + top left corner
            path.addLine(to: CGPoint(x: minX, y: tl))
            path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                        startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        }

        
        return path
    }

    
    // triangle points for the arrow position, not the position of the popover view!
    func trianglePointsFor(arrowPosition: ViewPosition, rect: CGRect, triangleSideLength: CGFloat)->(CGPoint, CGPoint, CGPoint) {
        
        switch arrowPosition {
        case .left:
            return (CGPoint(x: rect.minX, y: rect.midY + (triangleSideLength / 2)), CGPoint(x: rect.minX - arrowLength, y: rect.midY), CGPoint(x: rect.minX , y: rect.midY - (triangleSideLength/2)))
        case .topLeft:
             return (CGPoint(x: rect.minX, y: rect.minY + (triangleSideLength / 2)), CGPoint(x: rect.minX - triangleSideLength / 4, y: rect.minY - (triangleSideLength / 4)), CGPoint(x: rect.minX + triangleSideLength / 2, y: rect.minY))
        case .top:
            return (CGPoint(x: rect.midX - triangleSideLength / 2 , y: rect.minY), CGPoint(x: rect.midX, y: rect.minY - arrowLength), CGPoint(x: rect.midX + triangleSideLength / 2, y: rect.minY) )
        case .topRight:
            return (CGPoint(x: rect.maxX - triangleSideLength / 2, y: rect.minY),CGPoint(x: rect.maxX + triangleSideLength / 4, y: rect.minY - (triangleSideLength / 4)), CGPoint(x: rect.maxX, y: rect.minY + triangleSideLength / 2))
        case .right:
            return (CGPoint(x: rect.maxX, y: rect.midY - (triangleSideLength / 2)), CGPoint(x: rect.maxX + arrowLength, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY + (triangleSideLength/2)))
        case .bottomRight:
            return (CGPoint(x: rect.maxX, y: rect.maxY - triangleSideLength / 2),CGPoint(x: rect.maxX + triangleSideLength / 4, y: rect.maxY + (triangleSideLength / 4)), CGPoint(x: rect.maxX  - triangleSideLength / 2, y: rect.maxY))
        case .bottom:
            return (CGPoint(x: rect.midX + triangleSideLength / 2 , y: rect.maxY), CGPoint(x: rect.midX, y: rect.maxY + arrowLength),  CGPoint(x: rect.midX - triangleSideLength / 2, y: rect.maxY))
        case .bottomLeft:
            return (CGPoint(x: rect.minX + triangleSideLength / 2, y: rect.maxY), CGPoint(x: rect.minX - triangleSideLength / 4, y: rect.maxY + (triangleSideLength / 4)), CGPoint(x: rect.minX, y: rect.maxY - triangleSideLength / 2))
        default:
            return (CGPoint.zero, CGPoint.zero, CGPoint.zero)
        }
        
    }
    
    func makeArrow(path: inout Path, rect: CGRect, triangleSideLength: CGFloat, position: ViewPosition)->Path {
        let points =
        self.trianglePointsFor(arrowPosition: position, rect: rect, triangleSideLength: triangleSideLength)
        
        path.addLine(to: points.0)
        path.addLine(to: points.1)
        path.addLine(to: points.2)
        return path
        
    }

}

struct RoundedArrowRectangle_Preview: PreviewProvider {
    
    static var previews: some View {
        
        return RoundedArrowRectangle(arrowPosition: .bottom, arrowLength: 20, cornerRadius: (tl:10, tr:10, bl:10, br:10)).frame(width: 200, height: 150)
    }
}


