import UIKit

public struct AnimationProperties {
  public let from: Any
  //swiftlint:disable:next identifier_name
  public let to: Any
  public let duration: Double
  public let keyPath: String
  
  public init(from: Any, to: Any, duration: Double, keyPath: String) {
    self.from = from
    self.to = to
    self.duration = duration
    self.keyPath = keyPath
  }
  
  //swiftlint:disable:next identifier_name
  public static func cornerAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: #keyPath(CAShapeLayer.cornerRadius))
  }
  
  //swiftlint:disable:next identifier_name
  public static func boundsAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: "bounds.size")
  }
  
  //swiftlint:disable:next identifier_name
  public static func pathAnim(from: Any, to: Any, duration: Double) -> AnimationProperties {
    return AnimationProperties(from: from,
                               to: to,
                               duration: duration,
                               keyPath: #keyPath(CAShapeLayer.path))
  }
}
