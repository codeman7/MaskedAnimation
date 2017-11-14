//: Playground - noun: a place where people can play
import UIKit
import PlaygroundSupport

let home: UIViewController = UIViewController()
home.view.frame = CGRect(x: 0, y: 0, width: 250, height: 541)
home.view.backgroundColor = .white

let fab: MDView = MDView.fab(in: home.view)
home.view.addSubview(fab)

let dialog: MDView = MDView.dialog(in: home.view)
//home.view.addSubview(dialog)

let animator: MaskedAnimation = MaskedAnimation(superView: home.view)

animator.animate(from: fab, to: dialog)


PlaygroundPage.current.liveView = home.view
