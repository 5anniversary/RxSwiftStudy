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

TestScheduler는 테스트에 사용도리 스케줄러이고, 내장되어있는 클래스에요.
subscription은 각 테스트의 구독 정보를 저장하는 변수입니다.

```swift
override func setUp() {
  super.setUp()
    
  scheduler = TestScheduler(initialClock: 0)
}

```
그리고 위 부분에서 TestScheduler를 init 해주는데, initClock : 0 이라는 뜻은 시작할 때 스케줄러를 활성화하는 것을 의미해요



```swift
override func tearDown() {
  scheduler.scheduleAt(1000) {
    self.subscription.dispose()
  }

  scheduler = nil
  super.tearDown()
}

```

  
  
  
 RxSwift에서의 에러관리 이렇게 두 가지 방법으로 해결을 할 수 있습니다 !


* **Catch**: *기본값defaultValue*으로 error 복구하기

<img src = "https://user-images.githubusercontent.com/68267763/103155262-52f60280-47e1-11eb-92a6-f904167056a1.png" height = 150>


   * **Retry**: 제한적 또는 무제한으로 *재시도Retry* 하기


<img src = "https://user-images.githubusercontent.com/68267763/103155272-6b661d00-47e1-11eb-8dfa-3a4386097c11.png" height = 150>


</br>




<img src = "https://user-images.githubusercontent.com/68267763/103155284-a405f680-47e1-11eb-8e9f-7c60fce77327.png" height = 250>

* 저번 예제에는 이렇게 dummy버전의 데이터를 리턴하는 catchErrorJustReturn을 사용해주었지만, Rxswift에는 이보다 더 나은 에러관리방법들이 있답니다!

</br>

---

</br>

	
### 에러 던지기

나 에러났다 !!! 에러 났어!!! 에러가 났음을 알리기위해 에러를 던지는 코드를 적어야합니다.

**Pods/RxCocoa/URLSession+Rx.swift** 에서 아래의 친구를 찾아봅시다


```swift
public func data(request: URLRequest) -> Ovservable<Data> { ... }
```
</br>
  
이 메소드는 `NSURLRequest`를 받아 `Data` 타입의 Observable을 반환하네요
자 여기서 확인해볼부분은 에러를 반환하는 부분입니다 ! 

```swift
if 200 ..< 300 ~= pair.0.statusCode {
  return pair.1
}
else {
	throw RxCocoaURLError.httpRequestFailed(response: pair.0, data: pair.1)
}
```
  
* 이 코드가 observable이 에러를 방출하는 방법을 보여주는 아주 좋은 예제라고 합니다. 
* `flatMap` 연산자 내에서 발생한 에러를 내보내고 싶을 때, Swift 코드에서는 `throw`를 사용해야 합니다. (return 뇨뇨)

</br>

</br>

---
  
  ## C. catch를 사용한 에러 관리

자 이제 에러를 던졌습니다! 우리는 이 에러를 어떻게 처리해야할지 생각해보아야 합니다.

</br>

* 기본적인 방법은 `catch`를 이용하는 것입니다.
* `catch` 연산자는 기본 Swift에서 `do-try-catch` 구문을 통해 쓰였던 것과 비슷하다고 하네요! 
* observable이 실행되고 혹시 거기서 잘못된 점이 있으면 에러를 감싼 이벤트가 반환됩니다.

</br>

* RxSwift에는 `catch`계열에 두가지의 주요 연산자가 있습니다.

</br>

### 첫번째 빠밤

```swift
func catchError(_ handler:) -> RxSwift.Observable<Self.E>
```
	
* 이 연산자는 클로저를 매개변수로 받아서 완전히 다른 형태의 observable로 반환합니다.

	<img src = "https://user-images.githubusercontent.com/68267763/103155772-0a8d1380-47e6-11eb-9eac-c65e180d0710.png" height = 200>

* 여기서 `catchError`는 이전에 에러가 발생하지 않았던 값을 반환한다. 

</br>

### 두번째 빠밤

```swift
func catchErrorJustReturn(_ element:) -> RxSwift.Observable<Self.E>
```
	
* 이 연산자는 우리가 아까 위에서 사용한 연산자이죠 ?! 
* 이 연산자는 `catchError`에 비해 제한적입니다.
`catchErrorJustReturn`은 주어진 유형의 에러에 대한 값을 반환할 수 없습니다. 에러가 무엇이든 관계없이 모든 에러에 대해 동일한 값이 반환됩니다. 

</br>
</br>

### 일반적인 문제


* 에러는 observable 체인을 통과하는 과정에서 발생합니다.
* 따라서 observable chain의 시작부분에서 에러가 발생했을 때 별도의 관리를 하지 않은 경우 그대로 구독으로 전달되게 됩니다. -> 이게 도대체 무슨 뜻? 
* observable이 에러를 냈을 때, 에러 구독이 확인되고 이로 인해 모든 구독이 dispose 된다는 뜻 ...  
* 따라서 observable이 에러를 냈을 때, observable은 반드시 완전종료되고 에러 다음의 이벤트는 모두 무시됩니다.

	<img src = "https://user-images.githubusercontent.com/68267763/103155816-5344cc80-47e6-11eb-9486-6a8768fc064d.png" height = 300>
	
	* 네트워크가 에러를 만들어내고 observable sequence도 에러를 냈다.
	* 구독은 추후 업데이트를 방지하기 위해 UI 업데이트를 중단한다. 
  
  </br>
  
* 이를 실제 앱에 적용시켜봅시다~ `textSearch` observable 내의 `catchErrorJustReturn(ApiController.Weather.empty)`를 삭제하고 앱을 실행해보면 API는 404 에러를 낼 것입니다. 
* 여기서 404 에러의 의미는 사용자가 찾고자 하는 도시명을 API내에서 찾을 수 없다는 의미입니다 -> 아무것도 안 적혀 있으니 ... 
* 다음과 같은 에러가 콘솔창에 뜰 것 입니다.

	```swift
	"http://api.openweathermap.org/data/2.5/weather?q=goierjgioerjgioej&appid=[API-KEY]&units=metric" -i -v
	Failure (207ms): Status 404
	```

  
  </br>
  </br>
  

## D. 에러 잡아내기

* 작업이 끝나면 빈 형식의 `Weather`를 반환하여 앱의 에러가 복구되도록하여 앱이 중단되지 않도록 하는 방식을 사용합니다.
* 이러한 방식의 에러관리는 다음과 같은 workflow로 표현할 수 있습니다.

	<img src = "https://user-images.githubusercontent.com/68267763/103156154-3bbb1300-47e9-11eb-9111-76a382ee1939.png" height = 300 >

* 이런 방식도 좋지만, 캐시 데이터를 쌓아놓고 그 정보를 내보내는 방법도 좋은 방법일 것 같습니다 !! 

-> 뭔말이냐구여? 팔로팔로미

</br>
</br>

* **ViewController.swift**를 열고 다음과 같이 간단한 dictionary 프로퍼티를 추가해봅시다 ! 

```swift
var cache = [String: Weather]()
```
* 이녀석은 일시적으로 캐시 데이터를 저장할 것 입니다.

* `viewDidLoad()` 메소드로 가서 지난번에 만든 `textSearch` observable을 확인하자. `do(onNext:)`를 체인에 추가하는 것으로 `textSearch` observable을 변경하여 캐시를 채울 수 있습니다. 

</br>


```swift
let textSearch = searchInput.flatMap { text in
  return ApiController.shared.currentWeather(city: text ?? "Error")
    .do(onNext: { data in
      if let text = text {
        self.cache[text] = data
      }
    })
  .catchErrorJustReturn(ApiController.Weather.empty)
}
```
</br>
	
* 이렇게 하면 제대로된 날씨 데이터들은 `cache` dictionary에 쌓일 것입니다. 
* 그렇다면 이렇게 캐시된 결과는 어떻게 재사용할 수 있을까요? 
* 에러이벤트에 캐시된 값들을 반환하려면 `.catchErrorJustReturn(ApiController.Weather.empty)`를 아래 코드로 변경해주세요!

</br>

```swift
.catchError { error in
	if let text = text, let cachedData = self.cache[text] {
		return Observable.just(cachedData)
	} else {
		return Observable.just(ApiController.Weather.empty)
	}
}
```

</br>


* 이렇게 해두고 여러 도시들을 검색해봅시다! 런던 뉴욕 서울 등등 ...
* 그리고 와이파이를 끊어봅니다 !!! 
* 아까 검색하지 않았던 아이들을 검색해봅니다 ,,, (ex. 바르셀로나)
* 에러가 나옵니다
* 아까 검색해본 애들을 검색해봅니다.
* 쌓여있는 캐시 데이터가 return 됩니다 !!! (신기방구)


</br>


---

</br>


## E. 에러 상황에서 재시도하기

* 두번째 방법 `retry` 
* `retry` 연산자가 observable 에러에서 사용될 때, observable은 스스로를 계속 반복합니다. 즉, `retry`는 observable 내의 *전체* 작업을 반복한다는 것을 의미합니다
* 이는 에러 발생시 사용자가 직접 (부적절한 타이밍에) 재시도 함으로써 사용자 인터페이스가 변경되는 부작용을 막기 위해 권장되는 방법입니다.

</br>


<img src = "https://user-images.githubusercontent.com/68267763/103156358-3c54a900-47eb-11eb-83ae-1aecf7b11eae.png" height = 400>


### 1. Retry

* retry를 실험해보기위해 `catchError` 아래 부분을 전체 주석처리 해주세요 ! 

	```swift
	// .catchError { error in
	//  	if let text = text, let cachedData = self.cache[text] {
	//  	 return Observable.just(cachedData)
	//	 } else {
	//		 return Observable.just(ApiController.Weather.empty)
	//	 }
	// }
	```
  </br>
  
  요로코롬
  
  </br>
	
* 이 자리에 `retry()`를 추가하고 앱을 샐행봅시다. 인터넷 연결을 끊고 검색을 시도하면 콘솔에 많은 메시지가 찍힐 것 입니다!! 이는 앱이 계속 요청을 시도하고 있다는 것을 보여주는 것 입니다.
* 몇 초뒤 인터넷을 다시 연결해보면 앱이 성공적으로 결과값을 보여주는 것을 확인할 수 있을 것입니다 ! 


* 2번째
</br>


```swift
func retry(_ maxAttemptCount:) -> Observable<E>
```			

* 이 연산자를 통해 몇번에 걸쳐서 재시도를 할 것인지 지정할 수 있습니다.
* 실험을 위해 다음과 같이 코드를 변경해봅시다 ( 실험 조아 ~ )
* `retry()`를 삭제합니다.
* 아까 주석처리한 코드를 다시 활성화 합니다.
* `catchError` 전에 `retry(3)`을 삽입합니다.
  
그럼 아래와 같이 수정 되겠죠?


```swift
return ApiController.shared.currentWeather(city: text ?? "Error")
	.do(onNext: { data in
		if let text = text {
			self.cache[text] = data
		}
	})
		.retry(3)
		.catchError { error in
			if let text = text, let cachedData = self.cache[text] {
				return Observable.just(cachedData)
			} else {
				return Observable.just(ApiController.Weather.empty)
			}
		}
```
	
* 만약 Observable이 에러를 발생하면, 성공할 때까지 3번 반복할 것입니다. 4번째 에러를 발생시킨 순간, 에러 관리를 멈추고 `catchError` 연산자로 이동될 것입니다.
  
 </br>
 </br>

### 2. 고급 retry 사용

* 조금 더 므찐 `retryWhen`을 살펴보겠습니다

</br>

```swift
func retryWhen(_ notificationHandler:) -> Observable<E>
```
* 여기서 주목해야할 점은 `notificationHandler`가 `TriggerObservable` 타입이라는 것입니다.
* trigger observable은 `Observable` 또는 `Subject` 모두가 될 수 있습니다. 또한 임의적으로 retry를 trigger 하는데 사용됩니다. ( 어렵다 .. )
* 이 방법은 이번 예제에서 인터넷 연결이 끊겼을 때 또는 API로 부터 에러를 받았을 때 사용되도록 이용할 수 있습니다. 만약 제대로 구현한다면 결과는 다음과 같이 나타날 것입니다.

	```swift
	subscription -> error
	delay and retry after 1 second
	
	subscription -> error
	delay and retry after 3 seconds
	
	subscription -> error
	delay and retry after 5 seconds
	
	subscription -> error
	delay and retry after 10 seconds
	```
  
  </br>
// (소영 왜 1,3,5,10인지 이해못함 ... 이해시켜줄사람?)
  
  </br>
	
* 기존 Swift에서 이러한 결과를 나타내려면 GCD등을 이용한 복잡한 코드가 필요합니다만 rxswift를 활용하면 간단!하게 코드를 작성할 수 있습니다.
* **유의사항** 내부 observable 항목이 어떤 값을 반환해야하는지 확인해야하고, trigger가 어떤 유형이 될 수 있는지 고려해보아야 합니다.
* 어떤 결과를 원하는가 ? -> delay sequence와 함께 4번의 재시도
* 먼저 `ViewController.swift` 내부에 `ApiController.shared.currentWeather` sequence 전에 `retryWhen` 연산자에서 사용할 최대 재시도 횟수를 정의합시다.

```swift
let maxAttempts = 4
```
	
* 여기서 정의한 횟수만큼 재시도가 된 이후에 에러가 전달될 것입니다.
* `.retry(3)`부분도 아래와 같이 수정합니다.

	```swift
	// 1
	.retryWhen{ e in
		// 2. flatMap source errors
		return e.enumerated().flatMap { (attempt, error) -> Observable<Int> in
			// 3. attemp few times
			if attempt >= self.maxAttempts - 1 {
				return Observable.error(error)
			}
		return Observable<Int>.timer(Double(attempt + 1), scheduler: MainScheduler.instance).take(1)
		}
	}
	```
	
	* 1. 이 observable은 원래 에러를 반환하는 observable과 병합되어야 합니다. 따라서 에러가 이벤트로 도착했을 때, 이 observable들의 병합은 현재 index를 포함하는 이벤트로 받아져야합니다.
	* 2. 이 작업은 `enumerated()`를 호출하고 `flatMap`을 이용하여 해결할 수 있습니다. `enumerated()` 메소드는 기존의 observable의 값과 index를 가지는 tuple의 observable을 새로운 observable로 반환합니다.
	* 3. 이제 원래의 에러 observable과 재시도 이전에 얼마나 지연되야하는지를 정의한 observable이 결합되었습니다. 이제 이 코드를 `timer`와 결합합니다. 
  
 </br>
 

 * 코드가 잘 작동하는지 확인하려면 다음 코드를 `flatMap`내부 두 번째 `return` 이전에 입력하면 콘솔창에서 결과를 확인할 수 있습니다.


 
	```swift
	print("== retrying after \(attempt + 1) seconds ==")
	```

* 작동 원리

	<img src = "https://user-images.githubusercontent.com/68267763/103156609-9c4c4f00-47ed-11eb-82a0-4953532de535.png" height = 300>

  
  
  </br>
  
  ---
  </br>
  

## F. 에러 사용자화

### 1. Custom 에러 만들기

* RxCocoa로부터 반환되는 에러는 상당히 일반적인 내용들입니다. 
* 따라서 HTTP 404 에러(page not found)는 502 에러(bad gateway)처럼 취급됩니다. 이 두가지는 완전히 다른 내용의 에러이기 때문에 다르게 처리해주는 것이 좋겠죠 ?
* **ApiController.swift**를 자세히 봤다면, ApiError안에 두가지 에러 케이스가 포함되어 있는 것을 확인하셨을겁니당. 이렇게하면 다른 HTTP 반응에 따라 다른 에러 처리를 해줄 수 있슴다.

	```swift
	enum ApiError: Error {
		case cityNotFound
	   	case serverFailure
	}
	```
  
  </br>
  
* 이 에러 타입을 `buildRequest(...)` 내부에 사용하게 될 것입니다. 
* 이 메소드의 마지막 라인은 data의 observable을 반환하는 내용입니다. 이 observable은 JSON 객체 structure에 매핑됩니다. 이 곳이 바로 커스텀 에러를 만들고 반환해야할 곳입니다.
* `buildRequest(...)` 내의 마지막 `flatMap` 블록을 다음의 코드로 바꿔주세요!!

	```swift
	return session.rx.response(request: request).map() { response, data in
		if 200 ..< 300 ~= response.statusCode {
			return try JSON(data: data)
		} else if 400 ..< 500 ~= response.statusCode {
			throw ApiError.cityNotFound
		} else {
			throw ApiError.serverFailure
		}
	}
	```
	
	* 이 메소드를 사용하면, 커스텀 에러를 만들 수 있고 API가 JSON을 통해 주는 메시지를 가지고 추가적인 로직을 구성하는 것도 가능합니다.
	* `JSON` 데이터를 받아서 `message` 영역의 내용을 통해 에러를 캡슐화 할 수 있습니다. 에러는 Swift의 강력한 기능중 하나이며, RxSwift에서는 더더욱 강력한 기능이 될 수 있습니다.
  
  </br>

### 2. Custom 에러 사용하기

* **ViewController.swift**로 돌아가서 `retryWhen {...}` 부분을 확인해봅시다. 여기서 우리가 하고 싶은 것은 에러가 observable 체인을 통과하면서 observable처럼 취급되는 것입니다.
* `InfoView`라는 이름의 작은 뷰가 있습니다. 이 뷰는 발생된 에러메시지를 앱 하단에 표시해주는 역할을 합니다. 

* 에러는 보통 retry나 catch 연산자로 처리하지만, 부수작용을 발생시키고 싶거나 사용자 인터페이스에서 메시지를 띄우고 싶다면 `do` 연산자를 사용할 수 있었습니다. 
* `retryWhen`을 사용할 때도 마찬가지로 `do`를 사용할 수 있습니다.
	
	```swift
	.do(onNext: { data in
		if let text = text {
			self.cache[text] = data
		}
	}, onError: { [weak self] e in 
		guard let strongSelf = self else { return }
		DispatchQueue.main.async {
			InfoView.showIn(viewController: strongSelf, message: "An error occurred")
		}
	})
	```
* 여기서 dispatch가 필요한 이유는 sequence가 background 쓰레드에서 관찰되고 있기 때문입니다.. 
* 그렇지 않으면 UIKit은 UI가 background 쓰레드에서 수정되고 있는 것에 대해서 경고를 보낼 것입니다.

* 여러가지 경우에 대한 다른 에러메시지가 뜨게하고 싶으시다면 아래처럼 수정해주시면 됩니다 :) 

	```swift
	func showError(error e: Error) {
		if let e = e as? ApiController.ApiError {
			switch (e) {
			case .cityNotFound:
				InfoView.showIn(viewController: self, message: "City Name is invalid")
			case .serverFailure:
				InfoView.showIn(viewController: self, message: "Server error")
			}
		} else {
			InfoView.showIn(viewController: self, message: "An error occurred")
		}
	}
	``` 
  
  </br>
  </br>
  
  ---
  
  이 외에도 Advanced error handling 이라는 파트가 있습니다만 ,,,
  여러분들이 Advanced를 원하실 때 각자 해보시면 좋을듯 합니다 !!! :) 
  어렵지만 중요하고 재밌는(?) 에러처리 ~ 끝 !
