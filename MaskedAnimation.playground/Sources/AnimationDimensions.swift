import Foundation
import UIKit

public struct AnimationDimensions {
  public var smallest: CGFloat {
    return min(endSize.width, endSize.height)
  }
  public var largest: CGFloat {
    return max(endSize.width, endSize.height)
  }
  public var diameter: CGFloat {
    let w: CGFloat = endSize.width * endSize.width
    let h: CGFloat = endSize.height * endSize.height
    return sqrt(w + h)
  }
  
  public var smallestCornerRadius: CGFloat { return smallest / 2 }
  private let start: CGFloat
  private let endSize: CGSize
  public init(endSize: CGSize, start: CGFloat) {
    self.endSize = endSize
    self.start = start
  }
}
