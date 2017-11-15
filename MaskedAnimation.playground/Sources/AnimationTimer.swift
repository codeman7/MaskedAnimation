import Foundation

public struct AnimationTimer {
  
  /// The total time that the animation will take
  public let totalTime: Double
  
  /// The time that the animation will take to complete the first animation
  public var firstAnimationDuration: Double {
    return totalTime * Double(dimensions.smallest)
  }
  
  /// The time that the animation will take to complete the second animation
  public var secondAnimationDuration: Double {
    return totalTime * Double(dimensions.largest)
  }
  
  /// The time that the animation will take to complete the third animation
  public var thirdAnimationDuration: Double {
    return totalTime * Double(dimensions.diameter)
  }
  
  /// The property to hold how ratios for smallest, largest, and diameter
  let dimensions: AnimationDimensions
  public init(totalTime: Double, dimensions: AnimationDimensions) {
    self.totalTime = totalTime
    self.dimensions = dimensions
  }
}
