# Ch.16 Testing with RxTest
</br>


RxTest로 테스팅 해보기
</br>

오늘은 RxTest를 이용해서 test를 해보는 방법을 배울겁니다.

그런데 오늘 배울 내용은 기존에 iOS에서 XCTest를 사용해 봐야 이해하기가 쉽다네요 ㅠㅠ 


</br>
  
---


## Hot과 Cold observable

* Hot과 Cold observable 개념은 testing에서 주로 언급되는 개념이라고 해요.

* Hot Observable 특징
	1. Subscriber가 없어도 자원을 사용
	2. Subscriber가 없어도 element를 생성
	3. Variable과 같은 stateful type과 같이 사용됨
	
	
* Cold Observable 특징
	1. Subscriber가 있어야 자원을 사용
	2. Subscriber가 있어야 element 생성
	3. 주로 networking과 같은 async operation에 사용됨

오늘 프로젝트에서는 Hot Observable을 사용하게 될건데요, 차이를 아는 것은 중요하다고 하네용

	
  </br>

먼저 TestingOperators.swift 파일을 열어줍니다.

```swift

var scheduler: TestScheduler!
var subscription: Disposable!

```

* TestScheduler는 테스트에 사용도리 스케줄러이고, 내장되어있는 클래스에요.
* subscription은 각 테스트의 구독 정보를 저장하는 변수입니다.

```swift
override func setUp() {
  super.setUp()
    
  scheduler = TestScheduler(initialClock: 0)
}

```
* 그리고 위 부분에서 TestScheduler를 init 해주는데, initClock : 0 이라는 뜻은 시작할 때 스케줄러를 활성화하는 것을 의미해요



```swift
override func tearDown() {
  scheduler.scheduleAt(1000) {
    self.subscription.dispose()
  }

  scheduler = nil
  super.tearDown()
}

```

* TearDown은 각 테스트가 끝날 때 불리는 함수입니다. 위에서 scheduleAt(1000)은 test의 구독 1000ms 후에 dispose된다는 것을 의미해요.
(1초동안 테스팅을 한다는 뜻)


</br>

# TestAmb Func


```swift
 // 1
  func testAmb() {
    // 2
    let observer = scheduler.createObserver(String.self)

    // 1
    let observableA = scheduler.createHotObservable([
      // 2
      .next(100, "a"),
      .next(200, "b"),
      .next(300, "c")
    ])

    // 3
    let observableB = scheduler.createHotObservable([
      // 4
      .next(90, "1"),
      .next(200, "2"),
      .next(300, "3")
    ])

    let ambObservable = observableA.amb(observableB)

    self.subscription = ambObservable.subscribe(observer)

    scheduler.start()

    let results = observer.events.compactMap {
      $0.value.element
    }

    XCTAssertEqual(results, ["1", "2", "3"])
  }

```

* 처음에 createObserver 함수로 test observer를 만들어줍니다.

* 이후 HotObservable 두개를 만들어주는데(observableA,observableB) .next로 시간과 String을 매칭해줍니다.

* 그리고 이 두 observable을 amb로 이어주는데요, Combining Operator에서 배운 Ambiguous 기억나시나요??

* amb로 두 observable을 이어줄거에요. 












  
  
