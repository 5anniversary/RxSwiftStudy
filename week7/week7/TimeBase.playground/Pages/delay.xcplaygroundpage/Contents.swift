//: Please build the scheme 'RxSwiftPlayground' first
import UIKit
import RxSwift
import RxCocoa

let elementsPerSecond = 1
let delayInSeconds = 1.5

let sourceObservable = PublishSubject<Int>()

let sourceTimeline = TimelineView<Int>.make()
let delayedTimeline = TimelineView<Int>.make()

let stack = UIStackView
    .makeVertical([
        UILabel.makeTitle("delay"),
        UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
        sourceTimeline,
        UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
        delayedTimeline
    ])

var current = 1
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext(current)
    current = current + 1
}

_ = sourceObservable.subscribe(sourceTimeline)


// Setup the delayed subscription
// ADD CODE HERE

_ = Observable<Int>
    .timer(.seconds(3), scheduler: MainScheduler.instance)
    .flatMap { _ in
        sourceObservable.delay(.seconds(Int(delayInSeconds)) , scheduler: MainScheduler.instance)
    }
    .subscribe(delayedTimeline)


let hostView = setupHostView()
hostView.addSubview(stack)
hostView


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
