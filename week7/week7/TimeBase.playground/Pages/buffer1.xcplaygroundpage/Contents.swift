import UIKit
import RxSwift
import RxCocoa

let bufferTimeSpan:RxTimeInterval = .seconds(4)
let bufferMaxCount = 2

// 2
let sourceObservable = PublishSubject<String>()

// 3
let sourceTimeline = TimelineView<String>.make()
let bufferedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("buffer"),
    UILabel.make("Emitted elements:"),
    sourceTimeline,
    UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds:"),
    bufferedTimeline])

// 4
_ = sourceObservable.subscribe(sourceTimeline)

// 5
sourceObservable
    .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    .map { $0.count }
    .subscribe(bufferedTimeline)

// 6
let hostView = setupHostView()
hostView.addSubview(stack)
hostView

// 7
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    sourceObservable.onNext("🐱")
    sourceObservable.onNext("🐱")
    sourceObservable.onNext("🐱")
}

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    view.setup()
    return view
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}
