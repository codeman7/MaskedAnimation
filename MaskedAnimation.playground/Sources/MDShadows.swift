import UIKit

public protocol ShadowProperties {
  var offset: CGFloat { get }
  var blur: CGFloat { get }
  var spread: CGFloat { get }
  var opacity: Float { get }
}

public enum ShadowType {
  case umbra(CGFloat)
  case penumbra(CGFloat)
  case ambient(CGFloat)
  
  public var metric: ShadowProperties {
    switch self {
    case .umbra(let value):
      return UmbraShadowProperties(elevation: value)
    case .ambient(let value):
      return AmbientShadowProperties(elevation: value)
    case .penumbra(let value):
      return PenumbraShadowProperties(elevation: value)
    }
  }
}


struct AmbientShadowProperties: ShadowProperties {
  let opacity: Float = 0.12
  
  var offset: CGFloat
  
  var blur: CGFloat
  
  var spread: CGFloat
  
  init(elevation: CGFloat) {
    assert(0...24 ~= elevation, "Elevation must be between 0 & 24")
    switch elevation {
    case 0: self.init(0,0,0)
    case 1: self.init(1, 3, 0)
    case 2: self.init(1, 5, 0)
    case 3: self.init(1, 8, 0)
    case 4: self.init(1, 10, 0)
    case 5: self.init(1, 14, 0)
    case 6: self.init(1, 18, 0)
    case 7: self.init(2, 16, 1)
    case 8: self.init(3, 14, 1)
    case 9: self.init(3, 16, 1)
    case 10: self.init(4, 18, 1)
    case 11: self.init(4, 20, 1)
    case 12: self.init(5, 22, 2)
    case 13: self.init(5, 24, 2)
    case 14: self.init(5, 26, 2)
    case 15: self.init(6, 28, 2)
    case 16: self.init(6, 30, 2)
    case 17: self.init(6, 32, 2)
    case 18: self.init(7, 34, 2)
    case 19: self.init(7, 36, 2)
    case 20: self.init(8, 38, 3)
    case 21: self.init(8, 40, 3)
    case 22: self.init(8, 42, 3)
    case 23: self.init(9, 44, 3)
    case 24: self.init(9, 46, 3)
    default:
      fatalError("Elevation should be between 0 & 24")
    }
  }
  
  private init(_ offset: CGFloat, _ blur: CGFloat, _ spread: CGFloat) {
    self.offset = offset
    self.blur = blur
    self.spread = spread
  }
}

struct UmbraShadowProperties: ShadowProperties {
  let opacity: Float = 0.2
  
  var offset: CGFloat
  
  var blur: CGFloat
  
  var spread: CGFloat
  
  init(elevation: CGFloat) {
    assert(0...24 ~= elevation, "Elevation must be between 0 & 24")
    switch elevation {
    case 0: self.init(0, 0, 0)
    case 1: self.init(2, 1, -1)
    case 2: self.init(3, 1, -2)
    case 3: self.init(3, 3, -2)
    case 4: self.init(2, 4, -1)
    case 5: self.init(3, 5, -1)
    case 6: self.init(3, 5, -1)
    case 7: self.init(4, 5, -2)
    case 8: self.init(5, 5, -3)
    case 9: self.init(5, 6, -3)
    case 10: self.init(6, 6, -3)
    case 11: self.init(6, 7, -4)
    case 12: self.init(7, 8, -4)
    case 13: self.init(7, 8, -4)
    case 14: self.init(7, 9, -4)
    case 15: self.init(8, 9, -5)
    case 16: self.init(8, 10, -5)
    case 17: self.init(8, 11, -5)
    case 18: self.init(9, 11, -5)
    case 19: self.init(9, 12, -6)
    case 20: self.init(10, 13, -6)
    case 21: self.init(10, 13, -6)
    case 22: self.init(10, 14, -6)
    case 23: self.init(11, 14, -7)
    case 24: self.init(11, 15, -7)
    default:
      fatalError("Elevation should be between 0 & 24")
    }
  }
  
  private init(_ offset: CGFloat, _ blur: CGFloat, _ spread: CGFloat) {
    self.offset = offset
    self.blur = blur
    self.spread = spread
  }
}

struct PenumbraShadowProperties: ShadowProperties {
  let opacity: Float = 0.14
  
  var offset: CGFloat
  
  var blur: CGFloat
  
  var spread: CGFloat
  
  init(elevation: CGFloat) {
    assert(0...24 ~= elevation, "Elevation must be between 0 & 24")
    switch elevation {
    case 0: self.init(0, 0, 0)
    case 1: self.init(1, 1, 0)
    case 2: self.init(2, 2, 0)
    case 3: self.init(3, 4, 0)
    case 4: self.init(4, 5, 0)
    case 5: self.init(5, 8, 0)
    case 6: self.init(6, 10, 0)
    case 7: self.init(7, 10, 1)
    case 8: self.init(8, 10, 1)
    case 9: self.init(9, 12, 1)
    case 10: self.init(10, 14, 1)
    case 11: self.init(11, 15, 1)
    case 12: self.init(12, 17, 2)
    case 13: self.init(13, 19, 2)
    case 14: self.init(14, 21, 2)
    case 15: self.init(15, 22, 2)
    case 16: self.init(16, 24, 2)
    case 17: self.init(17, 26, 2)
    case 18: self.init(18, 28, 2)
    case 19: self.init(19, 29, 2)
    case 20: self.init(20, 31, 3)
    case 21: self.init(21, 33, 3)
    case 22: self.init(22, 35, 3)
    case 23: self.init(23, 36, 3)
    case 24: self.init(24, 38, 3)
    default:
      fatalError("Elevation should be between 0 & 24")
    }
  }
  
  private init(_ offset: CGFloat, _ blur: CGFloat, _ spread: CGFloat) {
    self.offset = offset
    self.blur = blur
    self.spread = spread
  }
}

open class MDShadowLayer: CAShapeLayer {
  public var elevation: Int {
    didSet {
      shadowSetup()
    }
  }
  
  open override var cornerRadius: CGFloat {
    didSet {
      shadowSetup()
    }
  }
  
  public let umbra: CAShapeLayer = CAShapeLayer()
  public let penumbra: CAShapeLayer = CAShapeLayer()
  public let ambient: CAShapeLayer = CAShapeLayer()
  
  
  public override init() {
    self.elevation = 0
    super.init()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    self.elevation = 0
    super.init(coder: aDecoder)
  }
  
  public static func calculateSpread(metric: ShadowProperties) -> CGSize {
    var spread: CGSize = CGSize.zero
    spread.width = abs(metric.spread + metric.blur) * 4
    spread.height = abs(metric.spread + metric.blur + abs(metric.offset)) * 4
    return spread
  }
  
  func createMaskFor(_ layer: CAShapeLayer, metric: ShadowProperties) -> CAShapeLayer {
    let maskLayer: CAShapeLayer = CAShapeLayer()
    let spread = MDShadowLayer.calculateSpread(metric: metric)
    let bounds = layer.frame
    let maskRect = bounds.insetBy(dx: -spread.width, dy: -spread.height)
    let path: UIBezierPath = UIBezierPath(rect: maskRect)
    let innerPath: UIBezierPath
    if let p = layer.shadowPath {
      innerPath = UIBezierPath(cgPath: p)
    } else if (layer.cornerRadius > 0) {
      innerPath = UIBezierPath(roundedRect: layer.frame, cornerRadius: layer.cornerRadius)
    } else {
      innerPath = UIBezierPath(rect: layer.frame)
    }
    path.append(innerPath)
    path.usesEvenOddFillRule = true
    maskLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    maskLayer.bounds = maskRect
    maskLayer.path = path.cgPath
    maskLayer.fillRule = kCAFillRuleEvenOdd
    maskLayer.fillColor = UIColor.black.cgColor
    return maskLayer
  }
  
  private func shadowSetup() {
    //setup(layer: penumbra, shadowType: ShadowType.penumbra(CGFloat(elevation)))
    //setup(layer: umbra, shadowType: ShadowType.umbra(CGFloat(elevation)))
    //setup(layer: ambient, shadowType: ShadowType.ambient(CGFloat(elevation)))
  }
  
  private func defaultShadowPath() -> UIBezierPath {
    if self.cornerRadius != 0 {
      return UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius)
    }
    return UIBezierPath(rect: self.bounds)
  }
  
  func setup(layer: CAShapeLayer, shadowType: ShadowType) {
    layer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    layer.cornerRadius = self.cornerRadius
    self.insertSublayer(layer, below: self)
    layer.backgroundColor = UIColor.clear.cgColor
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowPath = self.shadowPath ?? self.defaultShadowPath().cgPath
    layer.mask = createMaskFor(layer, metric: shadowType.metric)
    layer.shadowRadius = CGFloat(shadowType.metric.blur)
    layer.shadowOffset = CGSize(width: 0, height: shadowType.metric.offset)
    layer.shadowOpacity = shadowType.metric.opacity
  }
  
}
