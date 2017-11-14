//
//  MDView.swift
//  
//
//  Created by Cody Weaver on 11/9/17.
//

import UIKit

/// View to use for all subclasses of UIView
open class MDView: UIView {
  
  /// Override the layer class so we can have shadows
  open override class var layerClass: AnyClass {
    return MDShadowLayer.self
  }
  
  var shadowLayer: MDShadowLayer {
    return self.layer as! MDShadowLayer //swiftlint:disable:this force_cast
  }
  
  /// The elevation that the view will have
  public var elevation: Int {
    didSet {
      self.shadowLayer.elevation = elevation
    }
  }
  
  /// Deisgnated and only initializer
  ///
  /// Sets the elevation to zero and must be set after initialization
  ///
  /// - Parameter frame: The frame that the view will have
  public override init(frame: CGRect) {
    self.elevation = 0
    super.init(frame: frame)
  }
  
  /// Required by Apple **NEVER USE**
  public required init?(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
}

public extension MDView {
  public static func fab(in view: UIView) ->  MDView {
    let fab: MDView = MDView(frame: CGRect(x: view.frame.width - 72,
                                           y: view.frame.height - 72,
                                           width: 56,
                                           height: 56))
    fab.bounds = CGRect(origin: CGPoint.zero, size: fab.frame.size)
    fab.layer.cornerRadius = 28
    fab.backgroundColor = UIColor.red
    fab.elevation = 6
    return fab
  }
  
  public static func dialog(in view: UIView) -> MDView {
    let dialog: MDView = MDView(frame: CGRect(x: view.center.x - 100,
                                              y: view.center.y - 75,
                                              width: 200,
                                              height: 150))
    dialog.bounds = CGRect(origin: CGPoint.zero, size: dialog.frame.size)
    dialog.layer.cornerRadius = 2
    dialog.backgroundColor = UIColor.yellow
    dialog.elevation = 24
    return dialog
  }
}
