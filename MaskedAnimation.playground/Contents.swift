//: Playground - noun: a place where people can play
import UIKit
import PlaygroundSupport

let home: UIViewController = UIViewController()
home.view.frame = CGRect(x: 0, y: 0, width: 250, height: 541)
home.view.backgroundColor = .white

open class MaskedAnimation: CALayer {
  /// The view that is the initial starting point
  var startView: MDView = MDView()
  
  /// The view that the animation transforms into
  var endView: MDView = MDView()
  
  private lazy var dimensions: AnimationDimensions = {
    return AnimationDimensions(endSize: endView.bounds.size,
                               start: startView.bounds.width)
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
  
  private lazy var timer: AnimationTimer = {
    return AnimationTimer(totalTime: 10.0, dimensions: dimensions)
  }()
  
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
                            duration: timer.totalTime,
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
    let size: CGSize = CGSize(width: dimensions.smallest, height: dimensions.smallest)
    CATransaction.begin()
    CATransaction.setAnimationDuration(timer.firstAnimationDuration)
    CATransaction.setCompletionBlock {
      self.animateToLarger()
    }
    let boundsProp: AnimationProperties =
      AnimationProperties.boundsAnim(from: startView.frame.size,
                                     to: size,
                                     duration: timer.firstAnimationDuration)
    let boundsAnim: CABasicAnimation = createAnim(withProperties: boundsProp)
    animationLayer.add(boundsAnim, forKey: "bounds.size")
    let colorProp: AnimationProperties =
      AnimationProperties.cornerAnim(from: startView.layer.cornerRadius,
                                     to: dimensions.smallestCornerRadius,
                                     duration: timer.firstAnimationDuration)
    let cornerAnim: CABasicAnimation = createAnim(withProperties: colorProp)
    animationLayer.add(cornerAnim, forKey: #keyPath(CAShapeLayer.cornerRadius))
    let elevation: CGFloat = CGFloat(endView.elevation)
    animateMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: penumbra, size: size, duration: timer.firstAnimationDuration, radius: dimensions.smallestCornerRadius)
    animateMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: umbra, size: size, duration: timer.firstAnimationDuration, radius: dimensions.smallestCornerRadius)
    animateMask(for: ambient, shadowType: ShadowType.ambient(elevation))
    animateShadowPath(for: ambient, size: size, duration: timer.firstAnimationDuration, radius: dimensions.smallestCornerRadius)
    CATransaction.commit()
  }
  
  //swiftlint:disable:next function_body_length
  private func animateToLarger() {
    let elevation: CGFloat = CGFloat(endView.elevation)
    let size: CGSize = CGSize(width: dimensions.smallest, height: dimensions.smallest)
    CATransaction.begin()
    CATransaction.setAnimationDuration(timer.secondAnimationDuration)
    CATransaction.setCompletionBlock {
      self.animateToDiameter()
    }
    let boundsProp: AnimationProperties =
      AnimationProperties.boundsAnim(from: size,
                                     to: endView.frame.size,
                                     duration: timer.secondAnimationDuration)
    let boundsAnim: CABasicAnimation = createAnim(withProperties: boundsProp)
    animationLayer.add(boundsAnim, forKey: "bounds.size")
    animateShadowPath(for: penumbra,
                      size: endView.bounds.size,
                      duration: timer.secondAnimationDuration,
                      radius: dimensions.smallestCornerRadius)
    animateLargeMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: umbra,
                      size: endView.bounds.size,
                      duration: timer.secondAnimationDuration,
                      radius: dimensions.smallestCornerRadius)
    animateLargeMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: ambient,
                      size: endView.bounds.size,
                      duration: timer.secondAnimationDuration,
                      radius: dimensions.smallestCornerRadius)
    animateLargeMask(for: ambient, shadowType: ShadowType.ambient(elevation))
    CATransaction.commit()
  }
  
  private func animateToDiameter() {
    let radius: CGFloat = endView.layer.cornerRadius
    let elevation: CGFloat = CGFloat(endView.elevation)
    let size: CGSize = endView.bounds.size
    CATransaction.begin()
    CATransaction.setAnimationDuration(timer.thirdAnimationDuration)
    CATransaction.setCompletionBlock {
      self.finish()
    }
    let cornerProp: AnimationProperties =
      AnimationProperties.cornerAnim(from: dimensions.smallestCornerRadius,
                                     to: endView.layer.cornerRadius,
                                     duration: timer.thirdAnimationDuration)
    let cornerAnim: CABasicAnimation = createAnim(withProperties: cornerProp)
    animationLayer.add(cornerAnim, forKey: #keyPath(CAShapeLayer.cornerRadius))
    animateShadowPath(for: penumbra, size: size, duration: timer.thirdAnimationDuration, radius: radius)
    animateDiameterMask(for: penumbra, shadowType: ShadowType.penumbra(elevation))
    animateShadowPath(for: umbra, size: size, duration: timer.thirdAnimationDuration, radius: radius)
    animateDiameterMask(for: umbra, shadowType: ShadowType.umbra(elevation))
    animateShadowPath(for: ambient, size: size, duration: timer.thirdAnimationDuration, radius: radius)
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
    animationStandard(for: anim, duration: timer.totalTime)
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
                          duration: timer.totalTime,
                          keyPath: #keyPath(CAShapeLayer.shadowRadius))
    let radiusAnimation: CABasicAnimation = createAnim(withProperties: radiusProp)
    layer.add(radiusAnimation, forKey: #keyPath(CAShapeLayer.shadowRadius))
    let fromSize = CGSize(width: 0, height: from.offset)
    let toSize = CGSize(width: 0, height: to.offset)
    let animProp: AnimationProperties =
      AnimationProperties(from: fromSize,
                          to: toSize,
                          duration: timer.totalTime,
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
    let difference: CGFloat = dimensions.smallest - startView.frame.width
    let bounds: CGRect = CGRect(x: 0,
                                y: 0,
                                width: startView.bounds.width + difference,
                                height: startView.bounds.height + difference)
    let outerPath: UIBezierPath = createOuterPath(for: layer,
                                                  bounds: bounds,
                                                  radius: dimensions.smallestCornerRadius)
    let innerRect: CGRect = createRect(from: startView.bounds.size,
                                       for: shadowType.metric,
                                       withDifference: difference)
    let innerPath: UIBezierPath
    if startView.layer.cornerRadius > 0 {
      innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: dimensions.smallest / 2)
    } else {
      innerPath = UIBezierPath(rect: innerRect)
    }
    maskAnim(for: layer,
             withDuration: timer.firstAnimationDuration,
             outerPath: outerPath,
             innerPath: innerPath)
  }
  
  private func animateLargeMask(for layer: CAShapeLayer, shadowType: ShadowType) {
    let outerPath: UIBezierPath = createOuterPath(for: layer,
                                                  bounds: CGRect(origin: .zero,
                                                                 size: endView.bounds.size),
                                                  radius: dimensions.smallestCornerRadius)
    let innerRect: CGRect = createRect(from: endView.frame.size, for: shadowType.metric)
    let innerPath: UIBezierPath
    if startView.layer.cornerRadius > 0 {
      innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: dimensions.smallest / 2)
    } else {
      innerPath = UIBezierPath(rect: innerRect)
    }
    maskAnim(for: layer,
             withDuration: timer.secondAnimationDuration,
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
             withDuration: timer.thirdAnimationDuration,
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

let fab: MDView = MDView.fab(in: home.view)
home.view.addSubview(fab)


let dialog: MDView = MDView.dialog(in: home.view)
//home.view.addSubview(dialog)

let animator: MaskedAnimation = MaskedAnimation(superView: home.view)

animator.animate(from: fab, to: dialog)


PlaygroundPage.current.liveView = home.view
