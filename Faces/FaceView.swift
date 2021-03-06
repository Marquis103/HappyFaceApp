//
//  FaceView.swift
//  Faces
//
//  Created by Marquis Dennis on 1/19/16.
//  Copyright © 2016 Marquis Dennis. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class { //can only be implemented by a class :class
  //when i ask someone else to provide my data to me i'm going to send myself
  func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {

  @IBInspectable
  var lineWidth:CGFloat = 3 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable
  var color: UIColor = UIColor.blueColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable
  var scale:CGFloat = 0.90 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var faceCenter:CGPoint {
    return convertPoint(center, fromView: superview)
  }
  
  var faceRadius:CGFloat {
    return min(bounds.size.width, bounds.size.height) / 2 * scale
  }
  
  //use faceview datasource as a type
  //someone who wants to be my data source just needs to set themselves as this variable
  //optional because it's possible i (faceview) will not have a data source
  weak var dataSource: FaceViewDataSource?
  
  private struct Scaling {
    static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
    static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
    static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
    static let FaceRadiusToMouthWidthRatio: CGFloat = 1
    static let FaceRadiusToMouthHeightRatio: CGFloat = 3
    static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
  }
  
  private enum Eye {case Left, Right }
  
  private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
    //the bigger the eye radius the bigger the eyes
    let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
    
    //
    let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
    let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
    
    var eyeCenter = faceCenter
    eyeCenter.y -= eyeVerticalOffset
    switch whichEye {
      case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
      case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
    }
    
    let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
    path.lineWidth = lineWidth
    return path
  }
  
  func scale(gesture: UIPinchGestureRecognizer) {
    if gesture.state == .Changed {
      scale *= gesture.scale
      gesture.scale = 1
    }
  }
  
  private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
    let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
    let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
    let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
    
    let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
    
    let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
    let end = CGPoint(x: start.x + mouthWidth, y: start.y)
    let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
    let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
    
    
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
    path.lineWidth = lineWidth
    return path
  }
  
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
    let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat( 2 * M_PI), clockwise: true)
    
    facePath.lineWidth = lineWidth
    color.set()
    facePath.stroke()
    
    bezierPathForEye(.Left).stroke()
    bezierPathForEye(.Right).stroke()
    
    let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
    let smilePath = bezierPathForSmile(smiliness)
    smilePath.stroke()
  }
}
