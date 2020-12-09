import UIKit
import RxSwift
import RxCocoa

let elementsPerSecond = 1
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3

// 1
let sourceObservable = Observable<Int>.create { observer in
    var value = 1
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond),
                                   queue: .main,
                                   handler: {
        // 2
    if value <= maxElements {
      observer.onNext(value)
      value += 1
    }
  })
    return Disposables.create {
    timer.suspend()
  } // 3
}.replay(replayedElements)

// 4
let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

// 5
let stack = UIStackView.makeVerical([
  UILabel.makeTitle("replay"),
  UILabel.make("Emit \(elementsPerSecond) per second"),
  sourceTimeline,
  UILabel.make("Replay \(replayElements) after \(replayDelay) sec:"),
  replayedTimeline
])

// 6
_ = sourceObservable.subscribe(sourceTimeline)

// 7
DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
  _ = sourceObservable.subscribe(replayTimeline)
}

// 8
_ = sourceObservable.connect()

// 9
let hostView = setupHostView()
hostView.addSubview(stack)
hostView
