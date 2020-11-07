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

* 홀수인 요소가 나올 때까지 skip합니다. 홀수인 요소가 나오면 그 후에는 계속 방출합니다.
* 보험금 청구 앱을 개발한다고 가정해보면, 공제액이 충족될 때까지 보험금 지급을 거부하기 위해 `skipWhile`을 사용할 수 있습니다.


```swift
— Example of: skipWhile —
3
4
4
```


```swift
```
```swift
```




