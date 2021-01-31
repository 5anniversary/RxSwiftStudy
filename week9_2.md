# Ch.16 Testing with RxTest
</br>


RxTest로 테스팅 해보기
</br>

오늘은 RxTest를 이용해서 test를 해보는 방법을 배울겁니다.

그런데 오늘 배울 내용은 기존에 iOS에서 XCTest를 사용해 봐야 이해하기가 쉽다네요 ㅠㅠ 

RxTest는 별도로 pod install을 해야 사용할 수 있어요.

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

* amb로 두 observable을 이어줄거에요. 마지막에는 ["1", "2", "3"] 으로 잘 결과가 나오는지 확인할겁니당

<img width="678" alt="스크린샷 2021-01-31 오전 11 58 30" src="https://user-images.githubusercontent.com/54928732/106373312-a4cf1100-63bb-11eb-91a7-d59f3c22a649.png">

* 위 부분에 나오는 다이아몬드를 클릭하면 테스팅을 해볼 수 있어요. 위에서 1,2,3 중에 아무거나 하나를 바꾸고 돌리면 Test Fail이 나는 것도 확인할 수 있습니다


# TestFilter

* 예전에 배운 Filter도 Testing을 통해 확인해볼거에요.

```swift
func testFilter() {
    // 1
    let observer = scheduler.createObserver(Int.self)

    // 2
    let observable = scheduler.createHotObservable([
      .next(100, 1),
      .next(200, 2),
      .next(300, 3),
      .next(400, 2),
      .next(500, 1)
    ])

    // 3
    let filterObservable = observable.filter {
      $0 < 3
    }

    // 4
    scheduler.scheduleAt(0) {
      self.subscription = filterObservable.subscribe(observer)
    }

    // 5
    scheduler.start()

    // 6
    let results = observer.events.compactMap {
      $0.value.element
    }

    // 7
    XCTAssertEqual(results, [1, 2, 2, 1])
  }

```

* 아까와 같은 방식인데, 이번에는 예전에 배운 filter를 이용해 테스팅을 해볼거에요. 
* 3보다 작은 것만 나오니 1,2,2,1 순서가 맞겠죠?


# RxBlocking

* RxBlocking 역시 별도의 pod 설치가 필요한 library 입니다
* 얘는 toBlocking(timeOut: ) 메소드를 통해 현재 스레드를 block 해서 observable이 terminate 되기를 기다리거나 특정 시간동안 멈출 수 있는 것이에요
* 만약에 observable이 terminate 되기 전에 timeOut이 다 돼서 불리면 error를 throw 해준다네요

```swift 

 func testToArray() throws {
    // 1
    let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

    // 2
    let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)

    // 3
    XCTAssertEqual(try toArrayObservable.toBlocking().toArray(), [1, 2])
  }

```

우리가 여기서 한 것은
	1. 비동기 스케줄러를 하나 생성
	2. 두 개의 integer를 가지는 observable 생성
	3. [1,2] 와 일치하는지 비교해주는 부분
	
위의 부분은 비동기 처리로 일어났어요. toArrayObservable이 toBlocking() 이 되는 순간 scheduler에 의해 생성된 스레드를 멈추고 테스팅합니다.

</br>

* RxBlocking은 materialize operator를 가지고 있어요. 얘는 blocking operation이 잘 수행되었는지를 확인해줍니다. 

```swift
public enum MaterializedSequenceResult<T> {
  case completed(elements: [T])
  case failed(elements: [T], error: Error)
}

```
* observable이 성공적으로 terminate되면 success, 그렇지 않으면 failed를 리턴하게 돼요.

```swift
  func testToArrayMaterialized() {
    // 1
    let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

    let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)

    // 2
    let result = toArrayObservable
      .toBlocking()
      .materialize()

    // 3
    switch result {
    case .completed(let elements):
      XCTAssertEqual(elements,  [1, 2])
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }


```

* 위의 코드에서는 앞선 테스트에 materialize를 추가한 코드입니다. 위와 같이 하면 modeling을 하는 과정을 추가하게 되고,
* 테스팅 과정이 안정적이고 뚜렷해진다하네요

</br>

---

# ViewModel

viewModel.swift 파일로 가주세요~

<img width="559" alt="스크린샷 2021-01-31 오후 12 27 54" src="https://user-images.githubusercontent.com/54928732/106373723-c0d4b180-63bf-11eb-976d-ca75562eade8.png">

이번에 사용될 앱은 위 그림과 같이 hex 숫자를 입력하면 r,g,b 10진수 값으로 바꿔주고 색 이름을 출력해주는 앱이에요

그러기 위해서 

```swift
  let hexString = BehaviorRelay(value: "")
  let color: Driver<UIColor>
  let rgb: Driver<(Int, Int, Int)>
  let colorName: Driver<String>


```

이렇게 각각을 나타낼 변수가 필요합니다


이제 다시 ViewController로 가줄게요

```swift
 override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    
    guard let textField = self.hexTextField else { return }
    
    textField.rx.text.orEmpty
      .bind(to: viewModel.hexString)
      .disposed(by: disposeBag)
    
    for button in buttons {
      button.rx.tap
        .bind {
          var shouldUpdate = false
          
          switch button.titleLabel!.text! {
          case "⊗":
            textField.text = "#"
            shouldUpdate = true
          case "←" where textField.text!.count > 1:
            textField.text = String(textField.text!.dropLast())
            shouldUpdate = true
          case "←":
            break
          case _ where textField.text!.count < 7:
            textField.text!.append(button.titleLabel!.text!)
            shouldUpdate = true
          default:
            break
          }
          
          if shouldUpdate {
            textField.sendActions(for: .valueChanged)
          }
        }
        .disposed(by: disposeBag)
    }
    
    viewModel.color
      .drive(onNext: { [unowned self] color in
        UIView.animate(withDuration: 0.2) {
          self.view.backgroundColor = color
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.rgb
      .map { "\($0.0), \($0.1), \($0.2)" }
      .drive(rgbTextField.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.colorName
      .drive(colorNameTextField.rx.text)
      .disposed(by: disposeBag)
  }

```


* ViewDidLoad에서 하는 일은 다음과 같아요
	1. textField의 text를 viewModel의 hexString과 binding
	2. 버튼 눌릴때마다 해당하는 기능들 수행
	3. view의 background color를 새로운 컬러로 변경
	4. rgb textField의 text를 수정
	5. colorName을 알맞게 띄우기
	
</br>

다시 ViewModel.swift로 돌아올게요

```swift
func testColorIsRedWhenHexStringIsFF0000_async() {
    let disposeBag = DisposeBag()

    // 1
    let expect = expectation(description: #function)

    // 2
    let expectedColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    // 3
    var result: UIColor!

    // 1
    viewModel.color.asObservable()
      .skip(1)
      .subscribe(onNext: {
        // 2
        result = $0
        expect.fulfill()
      })
      .disposed(by: disposeBag)

    // 3
    viewModel.hexString.accept("#ff0000")

    // 4
    waitForExpectations(timeout: 1.0) { error in
      guard error == nil else {
        XCTFail(error!.localizedDescription)
        return
      }

      // 5
      XCTAssertEqual(expectedColor, result)
    }
  }


```

위의 코드에서 해주는 일은
	1. model의 color driver를 subscribe해요. (1번째는 스킵하는데, 이는 기존의 color이기 때문)
	2. onNext로 fulfill() 함수를 호출
	3. view model의 hexString에 새로운 값을 대입
	4. 1.0초를 기다리고, error를 확인(1초 후에 fulfill이 되었는지)


이를 응용해서 다른 테스팅들을 해볼 수 있어요

```swift
 func testColorIsRedWhenHexStringIsFF0000() throws {
    // 1
    let colorObservable = viewModel.color.asObservable().subscribeOn(scheduler)

    // 2
    viewModel.hexString.accept("#ff0000")

    // 3
    XCTAssertEqual(try colorObservable.toBlocking(timeout: 1.0).first(),
                   .red)
  }
```

HexString == FF0000 일 때 red인지

```swift
 func testRgbIs010WhenHexStringIs00FF00() throws {
    // 1
    let rgbObservable = viewModel.rgb.asObservable().subscribeOn(scheduler)

    // 2
    viewModel.hexString.accept("#00ff00")

    // 3
    let result = try rgbObservable.toBlocking().first()!

    XCTAssertEqual(0 * 255, result.0)
    XCTAssertEqual(1 * 255, result.1)
    XCTAssertEqual(0 * 255, result.2)
  }

```
00FF00일 때 rgb값을 확인



```swift
func testColorNameIsRayWenderlichGreenWhenHexStringIs006636() throws {
    // 1
    let colorNameObservable = viewModel.colorName.asObservable().subscribeOn(scheduler)

    // 2
    viewModel.hexString.accept("#006636")

    // 3
    XCTAssertEqual("rayWenderlichGreen", try colorNameObservable.toBlocking().first()!)
  }

```

colorName도 잘 나오는지 
