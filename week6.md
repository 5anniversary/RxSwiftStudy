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

![스크린샷 2020-11-25 오후 12 33 29](https://user-images.githubusercontent.com/54928732/100179951-71cf5380-2f1a-11eb-8d36-fced69cfe24c.png)


* 1의 startWith는 concat에서 파생되어 나온 것.
* 두 sequence를 이어주는 역할을 해요
* 아래의 코드를 작성해주세요


```swift
example(of: "Observable.concat") {
    let first = Observable.of(1,2,3)
    let second = Observable.of(4,5,6)
    
    let observable = Observable.concat([first,second])
    
    observable.subscribe(onNext : {value in
        print(value)
    })
}
```

<img width="311" alt="스크린샷 2020-11-25 오후 12 37 08" src="https://user-images.githubusercontent.com/54928732/100180158-ef935f00-2f1a-11eb-81bf-d23570d53110.png">

EZ.


```swift
example(of: "concat") {
    let germanCities = Observable.of("Berlin","Munich","FrankFrut")
    let spanishCities = Observable.of("Madrid","Barcelona","Valencia")
    
    let observable = germanCities.concat(spanishCities)
    
    observable.subscribe(onNext : {value in
        print(value)
    })
    
    
}
``` 

* 위와 같이, Observable.concat이 아닌 기존의 observable 원소에 concat을 사용하여 하는 방식도 가능해요.
* concat을 하기 위해서는 두 sequence의 타입이 같아야 한다는 점!



### 3. concatMap







