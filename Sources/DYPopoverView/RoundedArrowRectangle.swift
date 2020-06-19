//
//  File.swift
//  
//
//  Created by Dominik Butz on 26/4/2020.
//

import Foundation
import SwiftUI

public enum ViewPosition {
    
    case top, topRight, right, bottomRight, bottom, bottomLeft, left, topLeft, none
    
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

    
    var margin: CGFloat {
        switch self.arrowPosition {
        case .bottomLeft, .bottomRight, .topRight, .topLeft :
            return arrowLength / 3
        default:
            return arrowLength
        }
    }
    
    func edgePointsFor(rect: CGRect)-> (maxX: CGFloat,  minX: CGFloat, maxY: CGFloat, minY: CGFloat) {
        
        var maxX:CGFloat = rect.maxX
        var minX: CGFloat = rect.minX
        var maxY: CGFloat = rect.maxY
        var minY: CGFloat = rect.minY
//        var actualMargin = 0
        
        switch arrowPosition {
        case  .topLeft:
              minX = rect.minX + margin
              minY  = rect.minY + margin
        case .top:
            minY = rect.minY + margin
        case .topRight:
            maxX = rect.maxX - margin
            minY = rect.minY + margin
        case .right:
            maxX = rect.maxX - margin
        case .bottomRight:
          maxX = rect.maxX - margin
         maxY = rect.maxY - margin
        case .bottom:
            maxY = rect.maxY - margin
        case .bottomLeft:
            maxY = rect.maxY - margin
            minX = rect.minX + margin
        case .left:
            minX = rect.minX + margin
        case .none:
            print("no change required")
        }
        
        return (maxX: maxX, minX: minX, maxY:maxY, minY: minY)
        
    }
    
    
    func path(in rect: CGRect) -> Path {
      
        let w = rect.size.width - margin
        let h = rect.size.height  - margin
        let tr = min(min(self.cornerRadius.tr, h/2), w/2)
        let tl = min(min(self.cornerRadius.tl, h/2), w/2)
        let bl = min(min(self.cornerRadius.bl, h/2), w/2)
        let br = min(min(self.cornerRadius.br, h/2), w/2)
        
//        let edgePoints = self.edgePointsFor(rect: rect)
//        let maxX = edgePoints.maxX
//        let minX = edgePoints.minX
//        let maxY  = edgePoints.maxY
//        let minY = edgePoints.minY
        let maxX = rect.maxX - margin
        let minX = rect.minX + margin
        let maxY = rect.maxY - margin
        let minY = rect.minY + margin


        let triangleSideLength : CGFloat = arrowLength / CGFloat(sqrt(0.75))
        
        let actualArrowPosition: ViewPosition = self.arrowLength > 0  ? self.arrowPosition : .none

        var path = Path()
 //+ triangleSideLength / 2
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
            path.addArc(center: CGPoint(x: w - tr, y: tr + margin), radius: tr,
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
            path.addLine(to: CGPoint(x: bl + margin, y: maxY))
            path.addArc(center: CGPoint(x: bl + margin, y: h - bl), radius: bl,
                               startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            // or bottom left arrow
        } else if actualArrowPosition == .bottomLeft {
            path = self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else { // or straight line + bottom left corner
            path.addLine(to: CGPoint(x: bl + margin, y: maxY))
            path.addArc(center: CGPoint(x: bl + margin, y: h - bl), radius: bl,
                               startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        }
      
       // line + left arrow
        if actualArrowPosition == .left {
           path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)
       
            // and top left corner:
             path.addLine(to: CGPoint(x: minX, y: tl + margin))
                       path.addArc(center: CGPoint(x: tl + margin, y: tl + margin), radius: tl,
                                   startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            
        } else if actualArrowPosition == .topLeft {
            // top left arrow
           path =  self.makeArrow(path: &path, rect:rect, triangleSideLength: triangleSideLength, position: actualArrowPosition)

        } else {
            // line + top left corner
            path.addLine(to: CGPoint(x: minX, y: tl + margin))
            path.addArc(center: CGPoint(x: tl + margin, y: tl + margin), radius: tl,
                        startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        }

        
        return path
    }

    
    // triangle points for the arrow position, not the position of the popover view!
    func trianglePointsFor(arrowPosition: ViewPosition, rect: CGRect, triangleSideLength: CGFloat)->(CGPoint, CGPoint, CGPoint) {
        
        switch arrowPosition {
        case .left:
            return (CGPoint(x: rect.minX + margin, y: rect.midY + (triangleSideLength / 2)), CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.minX + margin, y: rect.midY - (triangleSideLength/2)))
        case .topLeft:
             return (CGPoint(x: rect.minX + margin, y: rect.minY + margin + (triangleSideLength / 2)), CGPoint(x: rect.minX + margin - triangleSideLength / 4, y: rect.minY + margin - (triangleSideLength / 4)), CGPoint(x: rect.minX + margin + triangleSideLength / 2, y: rect.minY + margin) )
        case .top:
            return (CGPoint(x: rect.midX - triangleSideLength / 2 , y: rect.minY + margin), CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX + triangleSideLength / 2, y: rect.minY + margin) )
        case .topRight:
            return (CGPoint(x: rect.maxX - margin - triangleSideLength / 2, y: rect.minY + margin),CGPoint(x: rect.maxX - margin + triangleSideLength / 4, y: rect.minY + margin - (triangleSideLength / 4)), CGPoint(x: rect.maxX - margin, y: rect.minY + margin + triangleSideLength / 2))
        case .right:
            return (CGPoint(x: rect.maxX - margin, y: rect.midY - (triangleSideLength / 2)), CGPoint(x: rect.maxX, y: rect.midY), CGPoint(x: rect.maxX - margin, y: rect.midY + (triangleSideLength/2)))
        case .bottomRight:
            return (CGPoint(x: rect.maxX - margin, y: rect.maxY - margin - triangleSideLength / 2),CGPoint(x: rect.maxX - margin + triangleSideLength / 4, y: rect.maxY - margin + (triangleSideLength / 4)), CGPoint(x: rect.maxX - margin  - triangleSideLength / 2, y: rect.maxY - margin))
        case .bottom:
            return (CGPoint(x: rect.midX + triangleSideLength / 2 , y: rect.maxY - margin), CGPoint(x: rect.midX, y: rect.maxY),  CGPoint(x: rect.midX - triangleSideLength / 2, y: rect.maxY - margin))
        case .bottomLeft:
            return (CGPoint(x: rect.minX + margin + triangleSideLength / 2, y: rect.maxY - margin), CGPoint(x: rect.minX + margin - triangleSideLength / 4, y: rect.maxY - margin + (triangleSideLength / 4)), CGPoint(x: rect.minX + margin, y: rect.maxY -  margin - triangleSideLength / 2))
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
        
        return RoundedArrowRectangle(arrowPosition: .bottomLeft, arrowLength: 20, cornerRadius: (tl:10, tr:10, bl:10, br:10)).background(Color.yellow).frame(width: 200, height: 150)
    }
}


