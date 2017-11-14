import UIKit

struct AnimationProperties {
  let from: Any
  //swiftlint:disable:next identifier_name
  let to: Any
  let duration: Double
  let keyPath: String
  
  //swiftlint:disable:next identifier_name
  static func cornerAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: #keyPath(CAShapeLayer.cornerRadius))
  }
  
  //swiftlint:disable:next identifier_name
  static func boundsAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: "bounds.size")
  }
  
  //swiftlint:disable:next identifier_name
  static func pathAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: #keyPath(CAShapeLayer.path))
  }
}

open class MaskedAnimation: CALayer {
  /// The view that is the initial starting point
  var startView: MDView = MDView()
  
  /// The view that the animation transforms into
  var endView: MDView = MDView()
  
  /// The smaller of the two dimensions for the end
  /// view
  private lazy var smaller: CGFloat = {
    return (endView.frame.width > endView.frame.height)
      ? endView.frame.height : endView.frame.width
  }()
  
  /// The larger of the two dimensions for the end
  /// view
  private lazy var larger: CGFloat = {
    return (endView.frame.width > endView.frame.height)
      ? endView.frame.width : endView.frame.height
  }()
  
  /// The diameter of a circle that would cover the entire
  /// view, this is used to calculate animation times
  private lazy var diameter: CGFloat = {
    let w: CGFloat = endView.frame.width * endView.frame.width
    let h: CGFloat = endView.frame.height * endView.frame.height
    return CGFloat(sqrt(w + h))
  }()
  
  /// The animation timing function used for all functions
  ///
  /// **TODO** Add Bezier class for the 3 animations, small,
  /// large, and corner radius
  let animationTimingFunction: CAMediaTimingFunction =
    CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
  
  /// The layer that performs the animation
  private lazy var animationLayer: MDShadowLayer = {
    let layer: MDShadowLayer = MDShadowLayer()
    layer.frame = startView.frame
    layer.bounds = CGRect(origin: CGPoint.zero,
                          size: startView.frame.size)
    layer.backgroundColor = startView.backgroundColor?.cgColor
    layer.elevation = startView.elevation
    layer.cornerRadius = startView.layer.cornerRadius
    return layer
  }()
  
  /// Total time for the animation
  private var totalTime: Double = 10.0
  
  /// Time to get to the smaller of the two dimensions
  private var firstAnimationDuration: Double {
    return totalTime * Double(smaller / diameter)
  }
  
  /// Time to animate to the larger dimension
  private var secondAnimationDuration: Double {
    return totalTime * Double((larger - smaller) / diameter)
  }
  
  /// Time to animate to the final size `cornerRadius` animation
  private var thirdAnimationDuration: Double {
    return totalTime * Double((diameter - larger) / diameter)
  }
  
  /// The ambient layer of the animation layer
  private var ambient: CAShapeLayer { return animationLayer.ambient }
  
  /// The umbra layer of the animation layer
  private var umbra: CAShapeLayer { return animationLayer.umbra }
  
  /// The penumbra layer of the animation layer
  private var penumbra: CAShapeLayer { return animationLayer.penumbra }
  
  /// The current path for the sublayer's masks
  private var currentPath: CGPath = UIBezierPath().cgPath
  
  /// The view that holds both the start view, end view,
  /// and the animation layer
  private var superView: UIView
  
  /// Designated and only initializer
  public init(superView: UIView) {
    self.superView = superView
    super.init()
    self.frame = superView.frame
    self.bounds = superView.bounds
  }
  
  /// Required by Apple shouldn't be used
  /// - Note: If used then you must set the *superView* property
  ///         also, you must set the frame and bounds of the layer
  public required init?(coder aDecoder: NSCoder) {
    self.superView = UIView()
    super.init(coder: aDecoder)
  }
  
  /// Used the perform the animations
  ///
  /// - Parameters:
  ///   - start: The original view that the animation begins as
  ///   - end: The final view that the animation ends as
  public func animate(from start: MDView, to end: MDView) {
    startView = start
    endView = end
    superView.layer.addSublayer(animationLayer)
    startView.removeFromSuperview()
    if let startColor = startView.backgroundColor, let endColor = endView.backgroundColor {
      let animProperties: AnimationProperties =
        AnimationProperties(from: startColor.cgColor,
                            to: endColor.cgColor,
                            duration: totalTime,
                            keyPath: #keyPath(CAShapeLayer.backgroundColor))
      let colorAnim: CABasicAnimation = createAnim(withProperties: animProperties)
      animationLayer.add(colorAnim, forKey: #keyPath(CAShapeLayer.backgroundColor))
    }
    animateShadows()
    animatePosition()
    animateToSmallest()
  }
  
  /// Animate the view to the smaller of the two dimensions
  //swiftlint:disable:next function_body_length
  private func animateToSmallest() {
    let size: CGSize = CGSize(width: smaller, height: smaller)
    let radius: CGFloat = smaller / 2
    CATransaction.begin()
    CATransaction.setAnimationDuration(firstAnimationDuration)
    CATransaction.setCompletionBlock {
      self.animateToLarger()
    }
    let boundsProp: AnimationProperties =
      AnimationProperties.boundsAnim(from: startView.frame.size,
                                     to: size,
                                     duration: firstAnimationDuration)
    let boundsAnim: CABasicAnimation = createAnim(withProperties: boundsProp)
    animationLayer.add(boundsAnim, forKey: "bounds.size")
    let colorProp: AnimationProperties =
      AnimationProperties.cornerAnim(from: startView.layer.cornerRadius,
                                     to: smaller / 2,
                                     duration: firstAnimationDuration)
    let cornerAnim: CABasicAnimation = createAnim(withProperties: colorProp)
    animationLayer.add(cornerAnim, forKey: #keyPath(CAShapeLayer.cornerRadius))
    let elevation: CGFloat = CGFloat(endView.elevation)
    animateMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: penumbra, size: size, duration: firstAnimationDuration, radius: radius)
    animateMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: umbra, size: size, duration: firstAnimationDuration, radius: radius)
    animateMask(for: ambient, shadowType: ShadowType.ambient(elevation))
    animateShadowPath(for: ambient, size: size, duration: firstAnimationDuration, radius: radius)
    CATransaction.commit()
  }
  
  //swiftlint:disable:next function_body_length
  private func animateToLarger() {
    let elevation: CGFloat = CGFloat(endView.elevation)
    let size: CGSize = CGSize(width: smaller, height: smaller)
    CATransaction.begin()
    CATransaction.setAnimationDuration(secondAnimationDuration)
    CATransaction.setCompletionBlock {
      self.animateToDiameter()
    }
    let boundsProp: AnimationProperties =
      AnimationProperties.boundsAnim(from: size,
                                     to: endView.frame.size,
                                     duration: secondAnimationDuration)
    let boundsAnim: CABasicAnimation = createAnim(withProperties: boundsProp)
    animationLayer.add(boundsAnim, forKey: "bounds.size")
    animateShadowPath(for: penumbra,
                      size: endView.bounds.size,
                      duration: secondAnimationDuration,
                      radius: smaller / 2)
    animateLargeMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: umbra,
                      size: endView.bounds.size,
                      duration: secondAnimationDuration,
                      radius: smaller / 2)
    animateLargeMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: ambient,
                      size: endView.bounds.size,
                      duration: secondAnimationDuration,
                      radius: smaller / 2)
    animateLargeMask(for: ambient, shadowType: ShadowType.ambient(elevation))
    CATransaction.commit()
  }
  
  private func animateToDiameter() {
    let radius: CGFloat = endView.layer.cornerRadius
    let elevation: CGFloat = CGFloat(endView.elevation)
    let size: CGSize = endView.bounds.size
    CATransaction.begin()
    CATransaction.setAnimationDuration(thirdAnimationDuration)
    CATransaction.setCompletionBlock {
      self.finish()
    }
    let cornerProp: AnimationProperties =
      AnimationProperties.cornerAnim(from: smaller / 2,
                                     to: endView.layer.cornerRadius,
                                     duration: thirdAnimationDuration)
    let cornerAnim: CABasicAnimation = createAnim(withProperties: cornerProp)
    animationLayer.add(cornerAnim, forKey: #keyPath(CAShapeLayer.cornerRadius))
    animateShadowPath(for: penumbra, size: size, duration: thirdAnimationDuration, radius: radius)
    animateDiameterMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: umbra, size: size, duration: thirdAnimationDuration, radius: radius)
    animateDiameterMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: ambient, size: size, duration: thirdAnimationDuration, radius: radius)
    animateDiameterMask(for: ambient, shadowType: ShadowType.ambient(elevation))
    CATransaction.commit()
  }
  
  private func finish() {
    print("We are done animating")
  }
  
  private func animatePosition() {
    let path: UIBezierPath = UIBezierPath()
    path.move(to: animationLayer.position)
    path.addQuadCurve(to: endView.center,
                      controlPoint: CGPoint(x: endView.center.x, y: startView.center.y))
    let anim: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.position))
    anim.path = path.cgPath
    animationStandard(for: anim, duration: totalTime)
    animationLayer.add(anim, forKey: #keyPath(CAShapeLayer.position))
  }
  
  private func animateShadows() {
    let start: CGFloat = CGFloat(startView.elevation)
    let end: CGFloat = CGFloat(endView.elevation)
    let startUmbra: ShadowProperties = ShadowType.umbra(start).metric
    let endUmbra: ShadowProperties = ShadowType.umbra(end).metric
    animateShadows(for: umbra, from: startUmbra, to: endUmbra)
    let startPenumbra: ShadowProperties = ShadowType.penumbra(start).metric
    let endPenumbra: ShadowProperties = ShadowType.umbra(end).metric
    animateShadows(for: penumbra, from: startPenumbra, to: endPenumbra)
    let startAmbient: ShadowProperties = ShadowType.ambient(start).metric
    let endAmbient: ShadowProperties = ShadowType.ambient(end).metric
    animateShadows(for: ambient, from: startAmbient, to: endAmbient)
  }
  
  private func animateShadows(for layer: CAShapeLayer,
                              from: ShadowProperties,
                              to: ShadowProperties) {   //swiftlint:disable:this identifier_name
    let radiusProp: AnimationProperties =
      AnimationProperties(from: from.blur,
                          to: to.blur,
                          duration: totalTime,
                          keyPath: #keyPath(CAShapeLayer.shadowRadius))
    let radiusAnimation: CABasicAnimation = createAnim(withProperties: radiusProp)
    layer.add(radiusAnimation, forKey: #keyPath(CAShapeLayer.shadowRadius))
    let fromSize = CGSize(width: 0, height: from.offset)
    let toSize = CGSize(width: 0, height: to.offset)
    let animProp: AnimationProperties =
      AnimationProperties(from: fromSize,
                          to: toSize,
                          duration: totalTime,
                          keyPath: #keyPath(CAShapeLayer.shadowOffset))
    let offsetAnimation: CABasicAnimation = createAnim(withProperties: animProp)
    layer.add(offsetAnimation, forKey: #keyPath(CAShapeLayer.shadowOffset))
  }
  
  private func animateShadowPath(for layer: CAShapeLayer,
                                 size: CGSize,
                                 duration: Double,
                                 radius: CGFloat) {
    let path: UIBezierPath
    let rect: CGRect = CGRect(origin: CGPoint.zero, size: size)
    if layer.cornerRadius > 0 {
      path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
    } else {
      path = UIBezierPath(rect: rect)
    }
    guard let shadowPath = layer.shadowPath else { return }
    let animProp: AnimationProperties = AnimationProperties(from: shadowPath,
                                                            to: path.cgPath,
                                                            duration: duration,
                                                            keyPath: "shadowPath")
    let anim: CABasicAnimation = createAnim(withProperties: animProp)
    layer.add(anim, forKey: "shadowPath")
  }
  
  private func animateMask(for layer: CAShapeLayer, shadowType: ShadowType) {
    let difference: CGFloat = smaller - startView.frame.width
    let bounds: CGRect = CGRect(x: 0,
                                y: 0,
                                width: startView.bounds.width + difference,
                                height: startView.bounds.height + difference)
    let outerPath: UIBezierPath = createOuterPath(for: layer,
                                                  bounds: bounds,
                                                  radius: smaller / 2)
    let innerRect: CGRect = createRect(from: startView.bounds.size,
                                       for: shadowType.metric,
                                       withDifference: difference)
    let innerPath: UIBezierPath
    if startView.layer.cornerRadius > 0 {
      innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: smaller / 2)
    } else {
      innerPath = UIBezierPath(rect: innerRect)
    }
    maskAnim(for: layer,
             withDuration: firstAnimationDuration,
             outerPath: outerPath,
             innerPath: innerPath)
  }
  
  private func animateLargeMask(for layer: CAShapeLayer, shadowType: ShadowType) {
    let outerPath: UIBezierPath = createOuterPath(for: layer,
                                                  bounds: CGRect(origin: .zero,
                                                                 size: endView.bounds.size),
                                                  radius: smaller / 2)
    let innerRect: CGRect = createRect(from: endView.frame.size, for: shadowType.metric)
    let innerPath: UIBezierPath
    if startView.layer.cornerRadius > 0 {
      innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: smaller / 2)
    } else {
      innerPath = UIBezierPath(rect: innerRect)
    }
    maskAnim(for: layer,
             withDuration: secondAnimationDuration,
             outerPath: outerPath,
             innerPath: innerPath)
  }
  
  private func animateDiameterMask(for layer: CAShapeLayer, shadowType: ShadowType) {
    let outerPath: UIBezierPath = createOuterPath(for: layer,
                                                  bounds: CGRect(origin: .zero,
                                                                 size: endView.bounds.size),
                                                  radius: endView.layer.cornerRadius)
    let innerRect: CGRect = createRect(from: endView.frame.size, for: shadowType.metric)
    let innerPath: UIBezierPath
    if endView.layer.cornerRadius > 0 {
      innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: endView.layer.cornerRadius)
    } else {
      innerPath = UIBezierPath(rect: innerRect)
    }
    maskAnim(for: layer,
             withDuration: thirdAnimationDuration,
             outerPath: outerPath,
             innerPath: innerPath)
  }
  
  private func createOuterPath(for layer: CAShapeLayer,
                               bounds: CGRect,
                               radius: CGFloat) -> UIBezierPath {
    let outerPath: UIBezierPath
    let outerRect: CGRect = CGRect(origin: CGPoint.zero, size: bounds.size)
    if layer.cornerRadius > 0 {
      outerPath = UIBezierPath(roundedRect: outerRect, cornerRadius: radius)
    } else {
      outerPath = UIBezierPath(rect: outerRect)
    }
    return outerPath
  }
  
  private func createRect(from: CGSize,
                          for spread: ShadowProperties,
                          withDifference difference: CGFloat = 0) -> CGRect {
    let innerSize: CGSize = MDShadowLayer.calculateSpread(metric: spread)
    let width: CGFloat = from.width + difference + (innerSize.width * 2)
    let height: CGFloat = from.height + difference + (innerSize.height * 2)
    return CGRect(x: -innerSize.width, y: -innerSize.height, width: width, height: height)
  }
  
  private func maskAnim(for layer: CAShapeLayer,
                        withDuration duration: Double,
                        outerPath: UIBezierPath,
                        innerPath: UIBezierPath) {
    guard let mask = layer.mask as? CAShapeLayer else { return }
    mask.path = currentPath
    outerPath.append(innerPath)
    outerPath.usesEvenOddFillRule = true
    currentPath = outerPath.cgPath
    guard let path = mask.path else { return }
    let prop: AnimationProperties = AnimationProperties.pathAnim(from: path,
                                                                 to: outerPath.cgPath,
                                                                 duration: duration)
    let anim: CABasicAnimation = createAnim(withProperties: prop)
    mask.add(anim, forKey: #keyPath(CAShapeLayer.path))
  }
  
  private func animationStandard(for animation: CAAnimation, duration: Double) {
    animation.duration = duration
    animation.timingFunction = animationTimingFunction
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
  }
  
  private func createAnim(withProperties properties: AnimationProperties) -> CABasicAnimation {
    let anim: CABasicAnimation = CABasicAnimation(keyPath: properties.keyPath)
    anim.fromValue = properties.from
    anim.toValue = properties.to
    animationStandard(for: anim, duration: properties.duration)
    return anim
  }
}
