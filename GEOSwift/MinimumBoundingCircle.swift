//
//  MinimumBoundingCircle.swift
//  GEOSwift
//
//  Created by ZYP on 2019/5/17.
//  Copyright © 2019 andreacremaschi. All rights reserved.
//

import Foundation
import MapKit

public class MinimumBoundingCircle {
    private var input: Geometry?
    private var coordinates: [Coordinate] = [Coordinate]()
    private var extremalPts: [Coordinate]? = nil
    private var centre: Coordinate?
    private var radius: Double?
    
    public convenience init(input: Geometry, coordinates: [Coordinate]) {
        self.init()
        self.input = input
        self.coordinates = coordinates
    }
    
    public func getCentre() -> Coordinate? {
        compute()
        return centre
    }
    
    public func getRadius() -> Double? {
        if radius == 0 { return nil }
        return radius
    }
    
    private func compute() {
        if (extremalPts != nil) { return }
        
        computeCirclePoints()
        computeCentre()
        if (centre != nil) {
            let pt = extremalPts![0]
            radius = (centre?.distance(to: pt))!
        }
    }
    
    private func computeCirclePoints() {
        // handle degenerate or trivial cases
        if ((input?.isGeometryEmpty())!) {
            extremalPts = [Coordinate]()
            return;
        }
        if (input?.getNumCoordinates() == 1) {
            let pts: [Coordinate] = self.coordinates
            let pt = pts.first!
            extremalPts = [pt]
            return
        }
        
        let polygon = input?.convexHull()
        let ring = polygon?.exteriorRing
        let pointCollection = ring?.points
        var mapPoints = pointCollection?.map({ (coordinate) -> MKMapPoint in
             MKMapPoint(x: coordinate.x, y: coordinate.y)
        })
        mapPoints?.removeLast()

        if mapPoints!.count <= 2 {
            let coordinates = mapPoints?.compactMap({ (mapPoint) -> Coordinate in
                Coordinate(x: mapPoint.x, y: mapPoint.y)
            })
            extremalPts = coordinates
            return
        }
        
        let coordinates = mapPoints?.map({ (mapPoint) -> Coordinate in
            Coordinate(x: mapPoint.x, y: mapPoint.y)
        })
        
        // find a point P with minimum Y ordinate
        var P = lowestPoint(pts: coordinates!)
        
        // find a point Q such that the angle that PQ makes with the x-axis is minimal
        var Q = pointWitMinAngleWithX(pts: coordinates!, P: P)
        
        /**
         * Iterate over the remaining points to find
         * a pair or triplet of points which determine the minimal circle.
         * By the design of the algorithm,
         * at most <tt>pts.length</tt> iterations are required to terminate
         * with a correct result.
         */
        for _ in coordinates! {
            let R = pointWithMinAngleWithSegment(pts: coordinates!, P: P, Q: Q)
            // if PRQ is obtuse, then MBC is determined by P and Q
            if GEOSAngle.isObtuse(p0: P, p1: R, p2: Q) {
                extremalPts = [P, Q]
                return
            }
            // if RPQ is obtuse, update baseline and iterate
            if GEOSAngle.isObtuse(p0: R, p1: P, p2: Q) {
                P = R
                continue
            }
            // if RQP is obtuse, update baseline and iterate
            if GEOSAngle.isObtuse(p0: R, p1: Q, p2: P) {
                Q = R
                continue
            }
            extremalPts = [P,Q,R]
            return
        }
        
    }
    
    private func computeCentre() {
        switch extremalPts?.count {
        case 0:
            centre = nil
            break
        case 1:
            centre = extremalPts![0]
            break
        case 2:
            centre = Coordinate(x: (extremalPts![0].x + extremalPts![1].x) / 2.0, y: (extremalPts![0].y + extremalPts![1].y) / 2.0)
            break
        case 3:
            centre = CEOSTriangle(p0: extremalPts![0], p1: extremalPts![1], p2: extremalPts![2]).circumcentre()
            break
        default:
            break
        }
    }
    
    private func lowestPoint(pts: [Coordinate]) -> Coordinate {
        var min = pts[0]
        for pt in pts {
            if (pt.y < min.y) {
                min = pt
            }
        }
        return min
    }
    
    private func pointWitMinAngleWithX(pts: [Coordinate], P: Coordinate) -> Coordinate{
        var minSin = Double.greatestFiniteMagnitude
        var minAngPt: Coordinate?
        for i in (0...pts.count-1) {
            let p = pts[i]
            if p == P { continue }
            
            /**
             * The sin of the angle is a simpler proxy for the angle itself
             */
            let dx = p.x - P.x
            var dy = p.y - P.y
            if dy < 0 { dy = -dy }
            let len = sqrt(dx * dx + dy * dy)
            let sin = dy/len
            
            if sin < minSin {
                minSin = sin
                minAngPt = p
            }
        }
        return minAngPt!
    }
    
    private func pointWithMinAngleWithSegment(pts: [Coordinate], P: Coordinate, Q: Coordinate) -> Coordinate{
        var minAng = Double.greatestFiniteMagnitude
        var minAngPt: Coordinate?
        for i in (0...pts.count-1) {
            let p = pts[i]
            if p == P { continue }
            if p == Q { continue }
            
            let ang = GEOSAngle.angleBetween(tip1: P, tail: p, tip2: Q)
            if ang < minAng {
                minAng = ang
                minAngPt = p
            }
        }
        return minAngPt!
    }
    
    
}

let GEOS_PI = 3.14159265358979323846

internal class GEOSAngle {
    
    let pai = 3.14159265358979323846
    
    public static func angle(p0: Coordinate, p1: Coordinate) -> Double{
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        return atan2(dy, dx)
    }
   
    public static func diff(ang1: Double, ang2: Double) -> Double{
        var delAngle: Double?
        if ang1 < ang2 {
            delAngle = ang2 - ang1
        }
        else {
            delAngle = ang1 - ang2
        }
        
        if delAngle! > GEOS_PI {
            delAngle = (2 * GEOS_PI) - delAngle!
        }
        return delAngle!
    }
    
    public static func angleBetween(tip1: Coordinate, tail: Coordinate, tip2: Coordinate) -> Double {
        let a1 = angle(p0: tail, p1: tip1)
        let a2 = angle(p0: tail, p1: tip2)
        return diff(ang1: a1, ang2: a2)
    }
    
    public static func isObtuse(p0: Coordinate, p1: Coordinate, p2: Coordinate) -> Bool {
        let dx0 = p0.x - p1.x
        let dy0 = p0.y - p1.y
        let dx1 = p2.x - p1.x
        let dy1 = p2.y - p1.y
        let dotprod = dx0 * dx1 + dy0 * dy1
        return dotprod < 0
    }
    
}

internal class CEOSTriangle {
    
    var p0: Coordinate?, p1: Coordinate?, p2: Coordinate?
    convenience init(p0: Coordinate, p1: Coordinate, p2: Coordinate) {
        self.init()
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }
    
    public func circumcentre() -> Coordinate {
        let cx = p2!.x;
        let cy = p2!.y;
        let ax = p0!.x - cx;
        let ay = p0!.y - cy;
        let bx = p1!.x - cx;
        let by = p1!.y - cy;
        
        let denom = 2 * det(m00: ax, m01: ay, m10: bx, m11: by)
        let numx = det(m00: ay, m01: ax * ax + ay * ay, m10: bx, m11: bx * bx + by * by)
        let numy = det(m00: ax, m01: ax * ax + ay * ay, m10: bx, m11: bx * bx + by * by)
        
        let ccx = cx - numx / denom;
        let ccy = cy + numy / denom;
        return Coordinate(x: ccx, y: ccy)
    }
    
    public func det(m00: Double ,m01: Double ,m10: Double ,m11: Double) -> Double {
        return m00 * m11 - m01 * m10
    }
}
