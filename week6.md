# Chapter 9 Combining Operators

## Prefixing and Concatenating

* 그동안 배웠던 Observable들을 사용할 때 유용한 operator들에 대해서 배워보는 시간입니다.





### 먼저 example 추가해주시구..
```swift
public func example(of description: String,
                    action: () -> Void) {
    print("\n— Example of:", description, "—")
    action()
}
```

### 1. startWith


![스크린샷 2020-11-25 오후 12 22 52](https://user-images.githubusercontent.com/54928732/100179258-f28d5000-2f18-11eb-9fbe-1dd1a1459840.png)

* 여러 Observable을 사용할 때 가장 중요한 것이 초기 상태를 결정하는 것이라 해요.

```swift
example(of : "startWith") {
    let numbers = Observable.of(2,3,4)
    
    let observable = numbers.startWith(1)
    
    observable.subscribe(onNext : { value in
        print(value)
    })
}
```

* 위의 그림에서 봤듯이 initial value를 지정해주는 역할을 해요.
* 다른 observable의 type과 같은 원소를 줘야 합니다.


### 2. concat


