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
