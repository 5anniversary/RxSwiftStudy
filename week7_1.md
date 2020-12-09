# Chapter 11: Time Based Operators



## why?

반응형 프로그래밍의 핵심은 시간에 따른 비동기 데이터 흐름을 모델링 하는것!! (Reactive -> Rx!!)



## What?

이번시간에는 무엇을 할것이냐!!
시간 및 시간이 지남에 따라 시퀀스가 반응하고 변형되는 방식을 처리할 수 있는 다양한 연산자들을 사용할거에요!!



## How!

어떻게 하나요?? 이제 알아가보도록 합시다!

1. Bufferging operator

   - Buffering 연산자들은 과거의 요소들을 구독자에게 다시 재생하거나, 잠시 버퍼를 두고 줄 수 있어요.
   - 언제 어떻게 과거와 새로운 요소들을 전달할 것인지 컨트롤 할 수 있게 해줘요.

   

   ### Replaying past elements (과거 요소 리플레이)

   - sequence가 아이템을 방출했을때, 보통 미래의 구독자가 지나간 아이템을 받을 수 있는지 아닌지에 대한 여부는 항상 중요해요

   - 이들은 ` replay(_:)` 와 `replayAll()` 연산자를 통해 컨트롤이 가능해요

     ~~~swift
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
     let stack = UIStackView.makeVertical([
       UILabel.makeTitle("replay"),
       UILabel.make("Emit \(elementsPerSecond) per second"),
       sourceTimeline,
       UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
       replayedTimeline
     ])
     
     // 6
     _ = sourceObservable.subscribe(sourceTimeline)
     
     
     // 7
     DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
       _ = sourceObservable.subscribe(replayedTimeline)
     }
     
     // 8
     _ = sourceObservable.connect()
     
     
     // 9
     let hostView = setupHostView()
     hostView.addSubview(stack)
     
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
     ~~~

     1.  `elementsPerSecond`에서 요소들을 방출할 observable을 만들어야 해요. 그리고 방출된 요소의 개수와 몇개의 요소를 새로운 구독자에게 "다시 재생"할지 제어할 필요가 있어요.
        이러한 `observable`을 방출하기 위해서 `Observable<T>` 와 `create` 메소드를 사용!!해보면 되겠어요
        `DispatchSource.timer`함수는 playground내 Source 폴더에 정의된 `DispatchSource`의 extension이에요. 이 함수를 가지고 타이머 생성을 단순화 할수가 있어요
     2. 이 예제의 목적은, observable의 완료 completing에 대해 신경쓸 필요가 없다는 것!! 여기서는 단순히 방출이 가능할 때 까지 계속해서 요소들을 방출해 냄
     3. observable에 replay 기능을 추가!!
        이 연산자는 source observable에 의해 방출된 마지막 replayedElements에 대한 기록을 새로운 sequence로 생성!
        매번 새로운 observer가 구독될 때마다, 즉시 버퍼에 있는 요소들을 받고, 새로운 요소들이 있다면 마치 일반적인 구독처럼 계속해서 구독을 하게 됩니다.
     4. replay(:)의 실제 효과를 시각화하기 위해, 한쌍의 TimeLineView를 생성!
        TimeLineView 클래스는 playground 아래쪽 Source 그룹의 TimeLineViewBase 클래스에 정의되 있어요~ 이 클래스는 observable의 이벤트 방출을 실시간으로 시각화해줘요
     5. 편의를 위해 UIStackView를 사용해요, 이 역시 추후 새로운 구독자 뷰가 나타날 때까지 실시간 source observable를 구독하는 뷰가 될거에요.
     6. 상단 timeline을 받아 화면에 띄울 구독자를 준비~!
        TimelineView 클래스는 ObserverType RxSwift 프로토콜을 준수해요. 그렇게 때문에 , TimelineView 클래스는 sequence의 이벤트를 받아올수있고, observable sequence처럼 구독할 수 있어요
        매번 새로운 이벤트가 발생(요소방출, 완료, 에러)될 때마다 TimelineView는 이들을 타임라인에 표시!
        방출된 요소들은 초록색으로 완료는 검은색, 에러는 빨간색으로 표시되게 함!
        여기까지의 코드를 확인해보면 구독에 의해 Disposable의 리턴값이 무시되는 것을 알 수 있어요 왜냐면!! Playground 페이지가 새로고침 될때마다 작성한 예제 코드가 저장되지 않기 때문이에요. 오랫동안 사용하는 구독인 경우에 DisposeBag을 사용!!권장!!
     7. source observable을 다시 구독해보아요. 이번에는 약간의 딜레이를 줘서!!
        곧 두번째 타임라인에 두번째 구독을 통해 받은 요소들을 볼수가 있어요
        이제 replay(_:)가 connectable observable을 생성하기 때문에 아이템을 받기 시작하려면 이것을 기본 소스에 연결해야해요. 이 작업을 하지 않으면 구독자는 아무것도 받지 못해요
     8. `.connect()`한다
        `ConnectableObservable`은 observable의 계열의 특별한 클래스에요. 이것들은 `connect()` 메소드를 통해 불리기 전까지는 구독자 수와 관계없이, 아무 값도 방출하지 않아요. 이 장에서는 `ConnectableObservable<E>` (`Observable<E>`가 아님)를 리턴해주는 연산자에 대해 배우게 될거에요.
        연산자들은
        - `replay(_:)`
        - `replayAll()`
        - `multicast(_:)`
        - `publish()`
     9. 마지막으로 stack View가 표시될 hostView를 만들어주기~

   

   - 사용한 설정에서는 replayedElements는 1과 같구여, 이는 replay(_:)연산자가 source observable에서 마지막으로 방출하는 값만을 버퍼로 두기 때문이에요.
   - 타임라인을 보면, 두번째 구독자가 3,4 요소들을 동시에 받은 것을 알 수 가 있어요. 구독하는 시간에 따라, 마지막 버퍼값인 3과 두번째 구독을 함으로써 받는 4를 동시에 받은것!!
   - replayDelay와 replayElements값을 변경해가면서 플레이 해보아요~

   

   ### 무제한 리플레이

   여기서 알아볼 연산자는 `replayAll()` 이 연산자에요. 이 놈을 쓸때에는 주의해야할게 있는데요. 버퍼할 요소의 전체 개수를 정확히 알고있는 상황에서 사용해야한다는 것이에요.
   예를 들면 HTTP request에서 사용이 가능한데 이때 우리는 쿼리에서 반환하는 데이터를 유지할 경우 메모리에 줄 영향을 예측할 수 있어요. 반면에 `replayAll()`을 많은 양의 데이터를 생성하면서 종료도 되지 않는 sequence에 사용하면, 메모리는 금방 막히게 되요. Warning~!~!
    `replayAll()`을 확인하기 위해 상기 예제 코드의 `.replay(replayedElements)`를 `replayAll()` 로 바꿔보아요~~

   	- 두 번째 구독 즉시 모든 버퍼 요소들이 나타나게 되요

   

   ### Controlled buffering

   `buffer(timeSpan:cout:scheduler:)` 연산자에 대해 알아보아요

   ~~~swift
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
        bufferedTimeline
   ])
    
   // 4
   _ = sourceObservable.subscribe(sourceTimeline)
    
   
   //     - seealso: [buffer operator on reactivex.io]
   //    - parameter timeSpan: Maximum time length of a buffer.
   //    - parameter count: Maximum element count of a buffer.
   //    - parameter scheduler: Scheduler to run buffering timers on.
   //    - returns: An observable sequence of buffers.
   
    // 5
    sourceObservable
        .buffer(timeSpan: bufferTimeSpan, 
                count: bufferMaxCount,
                scheduler: MainScheduler.instance)
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
   
   ~~~

   1. 기본적으로 사용될 변수, 상수들을 정의해요
   2. 짧은 이모지를 입력하게 되는데, 이를 위해서 PublishSubject를 선언해요.
   3. 위쪽 타임라인에서 구독할 이벤트를 위해 코드를 작성해요.
   4. 버퍼된 타임라인은 각각의 버퍼어레이에 있는 요소들의 개수를 보여줘요
   5. source observable의 array에 있는 요소들을 받고 싶다. 또한 각각의 array들은 많아야 `bufferMaxCount` 만큼의 요소들을 가질 수 있어요. 만약 많은 요소들이 `bufferTimeSpan`이 만료되기 전에 받아졌다면, 연산자는 버퍼 요소들을 방출하고 타이머를 초기화 할 것이에요. 마지막 그룹 방출 이후 `bufferTimeSpan` 의 지연에서, buffer는 하나의 array를 방출할 것이고, 만약 이 지연시간동안 받은 요소가 없다면 array는 비게 될 것 이에요..
   6. 타임라인 뷰를 활성화 하기 위한 코드~
      source observable에 아무런 활동이 없을지라도, 버퍼 타임라인에 빈 버퍼가 있다는 것을 확신할 수 있어요.
      `buffer(_:scheduler:)` 연산자는 source observable에서 받을 것이 없다면 일정 간격으로 빈 array를 방출해요. 
      0은 source observable에서 0개의 요소가 방출되었음을 의미해요.
      이제 source observable에 데이터를 공급할 수 있어요. 버퍼링 된 observable에 어떤 영향이 나타나는지 확인해볼 수 있어요. 먼저 5초동안 3개의 요소를 집어 놓았어요.

   

   ‼️buffer1 을 실행 해봐요

   - 이 예제에서는 버퍼는 전체 용량이 채워지면 요소들의 array를 즉시 방출해요. 그리고 명시된 지연시간만큼 기다리거나 다시 전체용량이 채워질때까지 기다려요.

   

   ‼️buffer2 를 실행해봐요

   ​	또 다른 시나리오를 볼 수 가 있죠

   ​	1/0.7 sourceObservable에 이모지를 푸시합니다!!

   

   

   ### buffered observables `window`

   `window(timeSpan:count:scheduler:)` 는 `buffer(timeSpan:count:scheduler:)` 와 아주 밀접해요.
   다른 점은 array대신에 Observable을 방출한다는 것이에요

   

   ~~~swift
   // 1
   let elementsPerSecond = 3
   let windowTimeSpan: RxTimeInterval = .seconds(4)
   let windowMaxCount = 10
   let sourceObservable = PublishSubject<String>()
   
   // 2
   let sourceTimeline = TimelineView<String>.make()
   
   let stack = UIStackView.makeVertical([
     UILabel.makeTitle("window"),
     UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
     sourceTimeline,
     UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")])
   
   // 3
   let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
     sourceObservable.onNext("🐱")
   }
   
   // 4
   _ = sourceObservable.subscribe(sourceTimeline)
   
   //     - parameter timeSpan: Maximum time length of a window.
   //     - parameter count: Maximum element count of a window.
   //     - parameter scheduler: Scheduler to run windowing timers on.
   //     - returns: An observable sequence of windows (instances of `Observable`).
   
   // 5
   _ = sourceObservable
     .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
     .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
       let timeline = TimelineView<Int>.make()
       stack.insert(timeline, at: 4)
       stack.keep(atMost: 8)
       return windowedObservable
         .map { value in (timeline, value) }
         .concat(Observable.just((timeline, nil)))
     }// 6
     .subscribe(onNext: { tuple in
       let (timeline, value) = tuple
       if let value = value {
         timeline.add(.Next(value))
       } else {
         timeline.add(.Completed(true))
       }
     })
   //7
   let hostView = setupHostView()
   hostView.addSubview(stack)
   hostView
   
   ~~~

   1. String을 PublishSubject로 푸시해 출력된 observable 항목에서 시간별로 출력을 그룹화 하려고 했어요
   2. 요소들을 source observable에 푸시하기 위한 타이머를 추가해요
   3. Source timeline을 채워요
   4. 각각의 방출된 observable이 분리되어 볼 수 있게 해요. 매번 `window(timeSpan:count:scheduler:)` 가 새로운 observable을 방출할때마다 새로운 타입라인을 삽입해요. 이전 observable들은 아래로 내려가야 해요.
      이 코드는 windowed observable이에요- 여기서 하나 질문❓ 어떻게 방출될 observable을 관리할 수 있을까?
   5. `flatMap(_:)` 연산자를 사용할수있을거에요
      `flatMap(_:)` 이 새로운 observable을 받을 때 마다, 새로운 타임라인 뷰를 삽입해요.
      반환된 observable들을 `timeline` 과 `value` 를 조합한 튜플로 매핑해요. 이 목적은 두 값을 표시할 수 있는 곳으로 같이 옮기려는 것이에요.
      내부의 observable이 일단 완료되면, concat(_:)으로 하나의 튜플을 연결해요. 이를 통해 타임라인이 완료되었음을 표시할 수 있게 되요. 
      `flatMap(__:)` 으로 결과값 observable의 observable을 하나의 튜플 sequence로 변환할 수 있어요.
      결과 observable을 구독하고 타임라인을 받은 tuple로 채워요
   6. 이제 구독해 요소들을 각각의 타임라인에 표시해야 해요
      여기서 tuple속 values는 String? 타입이에요. 만약 값이 nil 이라면 sequence가 종료되었음을 의미해요.
   7. 화면에 표시!!

   

   ‼️ window를 실행해봐요!!

   

2. Time-shifting operators

   

   ### 구독 지연

   `delaySubscription(_:scheduler:)`에 대해서 알아보아요. 지금까지 타임라인 애니메이션 만드는 것은 많이 해봤으니 >.<, 이번에는 간단히 `delaySubscription` 에 해당하는 부분만 설명할게요.

   ~~~swift
   //     - parameter dueTime: Relative time shift of the subscription.
   //     - parameter scheduler: Scheduler to run the subscription delay timer on.
   //     - returns: Time-shifted sequence.
   
   _ = sourceObservable
    	.delaySubscription(.seconds(Int(delayInSeconds)), scheduler: MainScheduler.instance)
    	.subscribe(delayedTimeline)
   ~~~

   이름에서 유추할 수 있듯이, 구독을 시작한 후 요소를 받기 시작하는 시점을 지연하는 역할을 해요.
   ` delayInSeconds` 에 정의된 것에 따라 지연 이후 보여질 요소들을 선택하기 시작해요.

   Rx에서 observable에 대해 "cold"또는 "hot"이라 명명하는데, "cold" observable들은 요소를 등록할 때, 방출이 시작되요. "hot" observable들은 어떤 시점에서부터 영구적으로 작동하는 것이에요. (Notifications 같은) 구독을 지연시켰을 때, "cold" observable이라면 지연에 따른 차이가 없어요. "hot" observable이라면 예제에서와 같이 일정 요소를 건너뛰게 되요. 

   #### 정리를 하면 "cold" observable은 구독할 때만 이벤트를 방출하지만, "hot" observable은 구독과 관계없이 이벤트를 방출한다는 것이에요. (면접에서 가끔씩 나오는 질문!! 이라고 건너들었어요~)

   ### Delayed elements

   RxSwift에서 또 다른 종류의 delay는 전체 sequence를 뒤로 미루는 작용을 해요.

   구독을 지연시키는 대신, source observable을 즉시 구독한다. 다만 요소의 방출을 설정한 시간만큼 미룬다는 것이에요.

   상단의  `delaySubscription(_:scheduler:)` 대신에 아래의 코드를 추가 해보면 되겠어요

   ~~~swift
   //     - parameter dueTime: Relative time shift of the source by.
   //     - parameter scheduler: Scheduler to run the subscription delay timer on.
   //     - returns: the source Observable shifted in time by the specified delay.
   
   _ = sourceObservable
        .delay(RxTimeInterval(.seconds(Int(delayInSeconds)), scheduler: MainScheduler.instance)
        .subscribe(delayedTimeline)
   ~~~

   

3. Timer operators 

   

   어떤 어플리케이션이든 timer를 필요로 한다고 하네요~ iOS와 macOS에는 이에 대해 다양한 솔루션들이 있어요. 통상적으로, NSTimer가 해당 작업을 수행했지만, 혼란스러운 소유권 모델을 가지고 있어 적절한 사용이 어려웠다고 하네요~

   좀 더 최근에는 dispatch 프레임워크가 dispatch 소스를 통해 타이머를 제공했어요. 확실히 NSTimer보다는 나은 방법이지만, API는 여전히 랩핑없이는 복잡하다고 해요.

   이런‼️ 문제를 RxSwift는 간단하고 효과적인 솔루션을 제공한다고 하네요~ 이제 알아봐요~~

   

   ### Observable.interval(_:scheduler:)

   `DispatchSource`를 이용해서 일정간격의 타이머를 만들어볼 것이에요. 또한 이 것을 `Observable.interval(_:scheduler:)`인스턴스로 전환할 수도 있어요. 이들은 정의된 스케줄러에서 선택된 간격으로 일정하게 전송된 Int 값의 무한한 observable을 생성한다 

   `replay` 예제에서 `DispatchSource.timer(_:queue:)` 을 포함하는 Observable 부분을 모두 삭제하고 아래 코드를 삽입해보아요~

   ~~~swift
   /**
   Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.
   
   - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)
   
   - parameter period: Period for producing the values in the resulting sequence.
   - parameter scheduler: Scheduler to run the timer on.
   - returns: An observable sequence that produces a value after each period.
   */
   
   let sourceObservable = Observable<Int>
        .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
        .replay(replayedElements)
   ~~~

   RxSwift에서 interval timer들을 생성하는 것은 아주 쉬워요 생성 뿐만 아니라 취소하는것도 쉬워요

   - `Observable.interval(_:scheduler:)` 은 observable을 생성하므로 구독은 손쉽게 `dispose()` 로 취소할 수 있어요. 구독이 취소된다는 것은 즉 타이머가 멈춘다는 것을 의미 해요.

    observable에 대한 구독이 시작된 이후 정의된 간격동안 첫번째 값을 방출 시킬 수 있는 아주 명확한 방법이에요. 또한 타이머는 이 시점 이전에는 절대 시작하지 않아요. 구독은 시작을 위한 trigger 역할을 하게 되는것이에요!!

   ‼️ 우선 interval을 실행 해보구요!!

   타임라인에서 확인할 수 있듯이, `Observable.interval(_:scheduler:)` 를 통해 방출된 값을 0부터 시작해요. 다른 값이 필요하다면, `map(_:)` 을 이용할 수 있다.

   현업에서는 보통, 타이머를 통해 값을 방출하진 않는다구 그러네요?? 다만 아주 편리하게 index를 생성할 수 있는 방법이 된데요.

   


   ### Observable.timer(_:period:scheduler:)

   좀 더 강력한 타이머를 원한다면 `Observable.timer(_:period:scheduler:)` 연산자를 사용할 수 있어요. 이 연산자는 앞서 설명한 `Observable.interval(_:scheduler:)` 과 아주 유사하지만 몇가지 차이점이 있어요.

   - 구독과 첫번째 값 방출 사이에서 "마감일"을 설정할수 있어요.
   - 반복기간은 옵셔널이다. 만약 반복기간을 설정하지 않으면 타이머 observable은 한번만 방출된 뒤 완료될 것이에요!!

   ```swift
   /**
   Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.
   
   - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)
   
   - parameter dueTime: Relative time at which to produce the first value.
   - parameter period: Period to produce subsequent values.
   - parameter scheduler: Scheduler to run timers on.
   - returns: An observable sequence that produces a value after due time has elapsed and then each period.
   */
   
   _ = Observable<Int>
        .timer(3, scheduler: MainScheduler.instance)
        .flatMap { _ in
            sourceObservable.delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
        }
        .subscribe(delayedTimeline)
   ```

   ‼️ 우선 timer를 실행 해보구요!!

   다른 타이머를 트리거하는 타이머 이렇게 하면 어떤 이점이 있을까요??

   - 가독성이 좋아요
   - 구독이 disposable을 리턴하기 때문에, 첫번째 또는 두번째 타이머가 하나의 observable과 함께 트리거 되기 전, 언제든지 취소할 수 있어요.
   - `flatMap(_:)` 연산자를 사용함으로써, `Dispatch` 의 비동기 클로저를 사용하지 않고도 타이머 sequence들을 만들 수 있어요

   

   ### Timeout

   timeout연산자의 주된 목적은 타이머를 시간초과(오류) 조건에 대해 구별하는 것이에요. 따라서 timeout 연산자가 실행되면, RxError.TimeoutError라는 에러이벤트를 방출해요. 만약 에러가 잡히지 않으면 sequence를 완전히 종료해요.

   ~~~swift
   // 1
   let button = UIButton(type: .system)
   button.setTitle("Press me now!", for: .normal)
   button.sizeToFit()
   
   // 2
   let tapsTimeline = TimelineView<String>.make()
   
   let stack = UIStackView
       .makeVertical([
           button,
           UILabel.make("Taps on button above"),
           tapsTimeline
       ])
   
   /**
   Applies a timeout policy for each element in the observable sequence, using the specified scheduler to run timeout timers. If the next element isn't received within the specified timeout duration starting from its predecessor, the other observable sequence is used to produce future messages from that point on.
   
   - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)
   
   - parameter dueTime: Maximum duration between values before a timeout occurs.
   - parameter other: Sequence to return in case of a timeout.
   - parameter scheduler: Scheduler to run the timeout timer on.
   - returns: The source sequence switching to the other sequence in case of a timeout.
   */
   
   // 3
   let _ = button
       .rx.tap
       .map { _ in "•" }
       .timeout(.seconds(5), scheduler: MainScheduler.instance)
       .subscribe(tapsTimeline)
   
   // 4
   let hostView = setupHostView()
   hostView.addSubview(stack)
   hostView
   ~~~

   1. 간단한 버튼을 만들었어요. 이 버튼은  RxCocoa 라이브러리를 활용했어요.
      .버튼 탭을 캡쳐하는 메소드
      .만약 버튼이 5초 이내로 눌렸다면 뭔가 프린팅하고 5초 이내 다시 눌려지지 않으면 sequence를 완전히 종료해요.
      .만약 버튼이 눌려지지 않았다면 에로 메시지를 프린트 해요
   2. 버튼이 눌릴 때마다 쌓일 뷰를 만들어요
   3. observable을 구축하고 타임라인 뷰와 연결

   4. 뷰 띄우기

   `timeout(_:scheduler:)` 와 다른 버전은 observable을 취하고 타임아웃이 시작되었을 때, 에러대신 취한 Observable을 방출해요.
   위에 timeout부분을 아래의 코드로 변경해 보죠.

   ~~~swift
   .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
   ~~~

   위에서 정의된 코드에서는 빨간 에러 이벤트를 방출했지만, 이번에는 초록색의 일반적인 완료 이벤트가 "X"요소와 함께 방출 되네요~