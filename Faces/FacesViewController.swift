//
//  FacesViewController.swift
//  Faces
//
//  Created by Marquis Dennis on 1/19/16.
//  Copyright © 2016 Marquis Dennis. All rights reserved.
//

import UIKit

class FacesViewController: UIViewController, FaceViewDataSource {
  
  
  @IBOutlet weak var faceView: FaceView! {
    didSet {
      faceView.dataSource = self
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
    }
  }
  
  //model
  var happiness: Int = 100 { //0 = very sad, 100 = ecstatic
    didSet {
      //a way to validate the model for values of only 0 to 100
      happiness = min(max(happiness, 0), 100)
      print("happiness = \(happiness)")
      updateUI()
    }
  }
  
  private struct Constants {
    static let HappinessGestureScale: CGFloat = 4
  }
  
  @IBAction func changeHappiness(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Ended: fallthrough
    case .Changed:
      let translation = sender.translationInView(faceView)
      let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
      if happiness != 0 {
        happiness += happinessChange
        sender.setTranslation(CGPointZero, inView: faceView)
      }
    default: break
    }
    
  }
  
  func updateUI() {
    faceView.setNeedsDisplay()
  }
  
  func smilinessForFaceView(sender: FaceView) -> Double? {
    return Double(happiness - 50) / 50
  }
}
