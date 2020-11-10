# Ch.5 Filtering Operators

## A. Getting Started

* 오늘의 주제는 filtering operator입니다. 
* 다들 Swift에서 `filter(_:)`를 사용해보신 적이 있으시죠?
* 말그대로 Subject에 필터를 껴주는 작업입니다.
* 우리가 원하는 event 값만 쏙쏙 골라서 emit 해줄 수 있습니다. (개꿀~)

### 실습에 들어가기 전에 추가하는 것 잊지마세요
```swift
public func example(of description: String,
                    action: () -> Void) {
    print("\n— Example of:", description, "—")
    action()
}
```


### 버전 6.0.0 에 대해서
* 지난 10월에 버전 6.0.0이 릴리즈 되었습니다.
* 오늘 공부하는 부분 중에 변경된 부분이 있습니다. 6.0.0 버전이 아니신 분들은 제 코드에서 오류가 뜰 수 있습니다.
* 아래의 릴리즈 노트를 참고해주세요!
* [릴리즈 노트 보러가기](https://github.com/ReactiveX/RxSwift/releases) 


 </br>
 </br>
 
## B. Ignoring operators

### 1. .ignoreElements()

![1 ignoreElements](https://user-images.githubusercontent.com/68267763/98246042-18c46d80-1fb5-11eb-985f-0433ec082ccb.png) 

* `ignoreElements`는 `.next` 이벤트는 무시합니다. `completed`나 `.error` 같은 정지 이벤트는 허용합니다.

```swift
example(of: "ignoreElements") {
    
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .ignoreElements()
        .subscribe(
            onNext: { event in
                print(event)
            },
            onCompleted: {
                print("Complete")
            }
        )
        .disposed(by: disposeBag)
    
    strikes.onNext("1")
    strikes.onNext("2")
    strikes.onNext("3")
    strikes.onCompleted()
}

```

출력을 해보셨나요?

```swift
— Example of: ignoreElements —
Complete
```

이렇게 1,2,3 모두 무시되고 complete만 출력되는 것을 확인할 수 있습니다.

 </br>
 </br>


### 2. .elementAt

![2  elementAt](https://user-images.githubusercontent.com/68267763/98246805-24646400-1fb6-11eb-962f-d04730f621c3.png)

* 우리는 방출된 특정 n번째의 이벤트만 처리하고 싶을 때가 있을 수 있습니다.
* 이럴 때 사용하는 것이 `elementAt()` 입니다
* 문법이 바뀌었습니다.  `elementAt()` -> `element(at: )` 이렇게 써줘야 합니다.
* 당연하게 우리에게 index 0은 1번째 방출되는 이벤트 ^-^...


```swift
example(of: "elementAt") {
    
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    //  2
    strikes
        .element(at: 2)
        .subscribe(
            onNext: { event in
                print(event)
            },
            onCompleted: {
                print("Complete")
            }
        )
        .disposed(by: disposeBag)
    
    strikes.onNext("a")
    strikes.onNext("b")
    strikes.onNext("c")
    
}

```
우선 어떻게 나올지 생각해보고,
출력을 해봅시다 

```swift
— Example of: elementAt —
c
Complete

```

생각했던대로 나오셨나요?

 </br>
 </br>

### 3. .filter



![3 filter](https://user-images.githubusercontent.com/68267763/98434801-4543cb00-2116-11eb-8a0e-afe9d670df79.png)

* `ignoreElements`와 `element(at: )`은 observable의 요소들을 필터링하여 방출합니다. 
* `filter`는 필터링 요구사항이 한 가지 이상일 때 사용할 수 있습니다.


```swift
	example(of: "filter") {
	    
	    let disposeBag = DisposeBag()
	    
	    // 1
	    Observable.of(1,2,3,4,5,6)
	        // 2
	        .filter({ (int) -> Bool in
	            int % 2 == 0
	        })
	        // 3
	        .subscribe(onNext: {
	            print($0)
	        })
	        .disposed(by: disposeBag)
	}
  
  ```
  </br>
  </br>
  
  
  * Int 값을 받는 observable 생성
  * filter를 생성하여 true 값을 반환하는 요소만 내보낸다!
  * subscribe를 사용하여 방출되는 값을 확인한다
  
  
  ```swift
  
  — Example of: filter —
2
4
6
End
  
```
  </br>
  </br>
  
  ## C. Skipping operators

### 1. .skip


![4  skip](https://user-images.githubusercontent.com/68267763/98435648-07e03d00-2118-11eb-80b8-21924fe20503.png)

*  몇개의 요소를 skip 하고 싶을 때가 있을 수 있다고 하네요 .. ( 왜? 언제? 모름 암튼 )
* `skip` 연산자는 첫 번째 요소부터 n개의 요소를 skip하게 해줍니다


```swift
example(of: "skip") {
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
        // 2
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}


```
 </br>
 </br>


앞의 3개 A,B,C 를 제외하고 D,E,F 만 출력되는 것을 확인하실 수 있습니다


```swift

— Example of: skip —
D
E
F

```
 </br>
 </br>

### 2. skipWhile

![5 skipWhile](https://user-images.githubusercontent.com/68267763/98440774-0164bc00-213e-11eb-853e-90637558cd1a.png)


* `skipwWhile`은 skip할 로직을 구성하고 해당 로직이 `false` 되었을 때 방출합니다. 
* 문법이 바뀌었습니다.  `skipWhile(_:)` -> `skip(while:)` 이렇게 써줘야 합니다. 


```swift
example(of: "skipWhile") {
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 3, 4, 4)
        // 2
        .skip(while: {$0 % 2 == 0})
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}
```
 </br>
 </br>

* 홀수인 요소가 나올 때까지 skip합니다. 홀수인 요소가 나오면 그 후에는 계속 방출합니다.
* 보험금 청구 앱을 개발한다고 가정해보면, 공제액이 충족될 때까지 보험금 지급을 거부하기 위해 `skipWhile`을 사용할 수 있습니다.


```swift
— Example of: skipWhile —
3
4
4
```
 </br>
 </br>

### 3. skipUntil

![6 skipUntil](https://user-images.githubusercontent.com/68267763/98682819-b0f09700-23a7-11eb-8046-1a22eef6fe4f.png)

* `skipUnitl`은 다른 observable이 시동할 때까지 현재 observable에서 방출하는 이벤트를 skip 합니다
* `skipUnitl`은 다른 observable이 `.next`이벤트를 방출하기 전까지는 기존 observable에서 방출하는 이벤트들을 무시하는 것 !!
 </br>
 </br>

```swift
	example(of: "skipUntil") {
	    let disposeBag = DisposeBag()
	    
	    // 1
	    let subject = PublishSubject<String>()
	    let trigger = PublishSubject<String>()
	    
	    // 2
	    subject
	        .skipUntil(trigger)
	        .subscribe(onNext: {
	            print($0)
	        })
	        .disposed(by: disposeBag)
	    
	    // 3
	    subject.onNext("A")
	    subject.onNext("B")
	    
	    // 4
	    trigger.onNext("X")
	    
	    // 5
	    subject.onNext("C")
	}
```


코드를 실행해봅시다 !
 </br>
 </br>
 
* 주석을 따라 확인해보면, 
* a) `subject`와 `trigger`라는 PublishSubject를 만든다. 
* b) `subject`를 구독하는데 그 전에 `.skipUnitl`을 통해 `trigger`를 추가한다.
* c) `subject`에 `.onNext()`로 `A`, `B` 추가한다.
* d) `trigger`에 `.onNext()`로 `X`를 추가한다.
* e) `subject`에 새로운 이벤트`C`를 추가한다. 그제서야 `C`가 방출되는 것을 콘솔에서 확인할 수 있다. 왜냐하면 그 전까지는 `.skipUnitl`이 막고 있었기 때문이다.


```swift
— Example of: skipUntil —
C
```
 </br>
 </br>
 </br>
 </br>
 
## D. Taking operators

### 1. take

* Taking은 skipping의 반대 개념입니다.
* RxSwift에서 어떤 요소를 취하고 싶을 때 사용할 수 있는 연산자는 `take`

![7 take](https://user-images.githubusercontent.com/68267763/98683670-a7b3fa00-23a8-11eb-9bc5-8e358741e8e6.png)

* 그림을 보면 `take()`를 통해, 처음 2개의 값을 취한 것을 알 수 있습니다~~~

 </br>
 </br>
 
 	```swift
	example(of: "take") {
	    let disposeBag = DisposeBag()
	    
	    // 1
	    Observable.of(1,2,3,4,5,6)
	        // 2
	        .take(3)
	        .subscribe(onNext: {
	            print($0)
	        })
	        .disposed(by: disposeBag)
	}
	``` 
	
	

```swift
— Example of: take —
1
2
3

```

느낌이 오시죠 ? 

 </br>
 </br>
 
 ### 2. takeWhile
 
 ![8 takeWhile](https://user-images.githubusercontent.com/68267763/98683972-fa8db180-23a8-11eb-80d6-5b71ee1c914d.png)
 
* `takeWhile`은 `skipWhile`처럼 작동합니다.
* 그림과 같이 `takeWhile` 구문 내에 설정한 로직에서 `true`에 해당하는 값을 방출하게 됩니다. (skip과 반대)
* 문법이 바뀌었습니다.  `takeWhile(_:)` -> `take(while:)` 이렇게 써줘야 합니다. 


 </br>
 </br>
 
 ### 3. enumerated

* 방출된 요소의 index를 참고하고 싶은 경우가 있을 것입니다. 이럴 때는 `enumerated` 연산자를 확인할 수 있습니다!
* 기존 Swift의 `enumerated` 메소드와 유사하게, Observable에서 나오는 각 요소의 index와 값을 포함하는 튜플을 생성하게 됩니다.

 </br>
 
```swift
example(of: "takeWhile") {
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 4, 7, 8, 2, 5, 4, 4, 6, 6)
        // 2
        .enumerated()
        // 3
        .take(while: { index, value in
            // 4
            value % 2 == 0 && index < 3
        })
        // 4
        .map { $0.element }
        // 5
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

```


```swift
— Example of: takeWhile —
2
4

```
 </br>
 </br>

* 2, 4 까지는 설정한 로직이 true이지만 7은 false 입니다.
* 그 이후의 값들은 방출하지 않습니다.


 </br>
 </br>
 
### 4. takeUntil


![9 takeUntil](https://user-images.githubusercontent.com/68267763/98687341-f8c5ed00-23ac-11eb-94b9-a9a3b202388c.png)


* `skipUntil` 이 있으니 `takeUntil`도 있겠죠 ?
* 문법이 바뀌었습니다.  `takeUntil(_:)` -> `take(until:)` 이렇게 써줘야 합니다. 
* 그림과 같이, trigger가 되는 Observable이 구독되기 전까지의 이벤트값만 받는 것입니다. (skip과 반대라고 생각하면 됨)

 </br>
 </br>
 
 ```swift
	example(of: "takeUntil") {
    
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .take(until:trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X")
    
    subject.onNext("3")
}

```  

 </br>
 skip과 유사하니 빠르게 지나가겠습니다 - 슝
 
 </br>
 
  ```swift
— Example of: takeUntil —
1
2
```  

 </br>
 
### takeUntil의 활용
 
* ~이 책 마지막에서 배울~ RxCocoa 라이브러리의 API를 사용하면 dispose bag에 dispose를 추가하는 방식 대신 `takeUntil`을 통해 구독을 dispose 할 수 있다. 아래의 코드를 살펴보자.

	```swift
	someObservable
		.take(until:self.rx.deallocated)
		.subscribe(onNext: {
			print($0)
		})
	```
	
* 이전의 코드에서는 `takeUntil`의 `trigger`로 인해서 `subject`의 값을 취하는 것을 멈췄었다. 
* 여기서는 그 trigger 역할을 `self의 할당해제`가 맡게 된다. 보통 `self`는 아마 뷰컨트롤러나 뷰모델이 될것이다. 


</br>
</br>


## E. Distinct operators

* 여기서 배울 것은 중복해서 이어지는 값을 막아주는 연산자입니다.
</br>

### 1. distinctUntilChanged

![10 distincUntilChanged](https://user-images.githubusercontent.com/68267763/98688238-f9ab4e80-23ad-11eb-929f-7e986ccdd264.png)
</br>

* 그림에서처럼 `distinctUntilChanged`는 연달아 같은 값이 이어질 때 중복된 값을 막아주는 역할을 합니다.
* `2`는 연달아 두 번 반복되었으므로 뒤에 나온 `2`가 배출되지 않음!
* `1`은 중복이긴 하지만 연달아 반복된 것이 아니므로 그대로 배출됩니다.
</br>
</br>

```swift
	example(of: "distincUntilChanged") {
	    let disposeBag = DisposeBag()
	    
	    // 1
	    Observable.of("A", "A", "B", "B", "A")
	        //2
	        .distinctUntilChanged()
	        .subscribe(onNext: {
	            print($0)
	        })
	        .disposed(by: disposeBag)
	}
```
</br>

  ```swift
— Example of: distinctUntilChanged —
A
B
A
```

너무 쉽죠? ㅎ-ㅎ

</br>
</br>

### 2. distinctUntilChanged(_:)

![11 distincUntilChanged()](https://user-images.githubusercontent.com/68267763/98688615-64f52080-23ae-11eb-88ec-15995fa6b2fd.png)

</br>

* `distinctUntilChanged`는 기본적으로 구현된 로직에 따라 같음을 확인합니다. 그러나 커스텀한 비교로직을 구현하고 싶다면 `distinctUntilChanged(_:)`를 사용할 수 있습니다.
* 개인적으로 이게 좀 멋드러진다는 생각이 드네요 ㅎ-ㅎ ( 역시 커스텀이 멋지다 )
 </br>
 </br>


```swift
example(of: "distinctUntilChanged(_:)") {
    
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 이 부분은 제가 아래 코드를 이해하기 위해서 실험해본 부분입니다... rx와는 상관 없음
    let exampleNum :NSNumber = 110
    print("example : \(formatter.string(from: exampleNum)!.components(separatedBy: " "))")
    
    // 2
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        // 3
        .distinctUntilChanged { a, b in
            // 4
            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                  let bWords = formatter.string(from: b)?.components(separatedBy: " ")
            else {
                return false
            }
            
            var containsMatch = false
            
            // 5
            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containsMatch = true
                        break
                    }
                }
            }
            
            return containsMatch
        }
        // 4
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

```

 </br>
 </br>


  ```swift
— Example of: distinctUntilChanged(_:) —
10
20
200
```
why ?!?! 

 </br>
 </br>
 
 

  ```swift
10 : ten
110 : one, hundred, ten -> ten 겹침
20 : twenty
200 : two , hundred
210 : two, hundred, ten -> two, hundred 겹침
310 : three, hundred, ten -> hundred, ten 겹침

```

* 10 : ten
* 110 : one, hundred, ten -> ten 겹침
* 20 : twenty
* 200 : two , hundred
* 210 : two, hundred, ten -> two, hundred 겹침
* 310 : three, hundred, ten -> hundred, ten 겹침


 </br>
 </br>
 

* 주석을 따라 확인해보자.
	* 1) 각각의 번호를 배출해내는 `NumberFormatter()`를 만들어낸다.
	* 2) `NSNumbers` Observable을 만든다. 이렇게 하면 `formatter`를 사용할 때 Int를 변환할 필요가 없다.
	* 3) `distinctUntilChanged(_:)`는 각각의 seuquence 쌍을 받는 클로저다.
	* 4) `guard`문을 통해 값들의 구성요소를 빈 칸 구분하여 조건부로 바인딩하고 그렇지 않으면 `false`를 반환한다. 
	* 5) 중첩 `for-in` 반복문을 통해서 각 쌍의 단어를 반복하고, 검사결과를 반환하여, 두 요소가 동일한 단어를 포함하는지 확인한다.
	* 6) 구독하고 출력한다.
	* 결과는, 다른 요소를 포함하는 요소는 제외된 결과만 출력된다. `10 20 200`
	* a, b, c를 비교해가면서 만약 b가 a와 중첩되는 부분이 있어 prevent 되면, 다음엔 b와 c를 비교하는 것이 아니라 a와 b를 비교하게 됩니다. << 이해가 안감 토론 요망


 </br>
 </br>





끝! 
