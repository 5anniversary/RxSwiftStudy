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

## Concatenation 

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

* 저번 시간에 배운 flatMap과 유사합니다.
* closure 함수를 실행하면서 sequence 하나의 subscribe가 완료되어야 다음 sequence로 넘어간다고 하네요


```swift
example(of: "concatMap") {
    let sequences = [
        "Germany" : Observable.of("Berlin","Munich","FrankFrut"),
        "Spain" : Observable.of("Madrid","Barcelona","Valencia")
    ]
    
    let observable = Observable.of("Germany","Spain").concatMap { country in
        sequences[country] ?? .empty()
        
    }
    
    _ = observable.subscribe(onNext : { string in
        print(string)
        
    })
    
}
``` 

<img width="258" alt="스크린샷 2020-11-25 오후 12 52 01" src="https://user-images.githubusercontent.com/54928732/100181165-063ab580-2f1d-11eb-8d1d-27a5ba668856.png">




## Merging

![스크린샷 2020-11-25 오후 12 53 18](https://user-images.githubusercontent.com/54928732/100181258-32563680-2f1d-11eb-90bc-2491569a52c4.png)


* 순서대로 합쳐준다 라고 생각하면 편해요.
* 먼저 example 코드를 작성해볼게요. 



```swift
example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(),right.asObservable())
    let observable = source.merge()
    let disposable = observable.subscribe(onNext : {value in
        print(value)
    })
    
    var leftValues = ["Berlin","Munich","FrankFrut"]
    var rightValues = ["Madrid","Barcelona","Valencia"]
    
    repeat{
        if arc4random_uniform(2) == 0{
            if !leftValues.isEmpty {
                left.onNext("Left : " + leftValues.removeFirst())
            }
            
            
        }
        else if !rightValues.isEmpty {
            right.onNext("Right : " + rightValues.removeFirst())
        }

        
    }while !leftValues.isEmpty || !rightValues.isEmpty
   
    disposable.dispose()
    
}

``` 

* 위의 코드에서 left와 right 배열을 놓고, 랜덤하게 하나씩 onNext를 수행해요.
* source에 속한 sequence가 onNext를 수행할때마다 받아서 곧바로 방출해요.
* 내부에 속한 모든 sequence가 complete 되어야 merge()도 complete 됩니다.



## Combining Elements

### 1. Combine Latest
![스크린샷 2020-11-25 오후 1 09 49](https://user-images.githubusercontent.com/54928732/100182257-8530ed80-2f1f-11eb-97e8-991e0c4e7c91.png)


* 가장 최신의 원소와 결합해주는 combine 입니다. 아래 코드를 작성해볼게요.


```swift
example(of: "combineLatest"){
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left,right,resultSelector:  { lastLeft, lastRight in
        
        "\(lastLeft)\(lastRight)"
    })
    
    let disposable = observable.subscribe(onNext : {value in
        
        print(value)
        
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello,")
    
    print("> Sending a value to Right")
    right.onNext("world")
    
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    
    print("> Sending another value to Left")
    left.onNext("Have a good day")
    
    
    
    disposable.dispose()
}

``` 

* left와 right의 가장 최근 원소가 결합되어서 나타나는 것을 볼 수 있어요~

<img width="242" alt="스크린샷 2020-11-25 오후 1 23 06" src="https://user-images.githubusercontent.com/54928732/100183047-5c115c80-2f21-11eb-8a27-da9c4813aa4e.png">


```swift 
example(of : "combine user choice and value") {
    let choice : Observable<DateFormatter.Style> = Observable.of(.short,.long)
    
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice,dates) { (format,when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    observable.subscribe(onNext : { value in
        print(value)
    })
    
    
}
```
* 위의 코드를 보면, 다른 형식의 원소들도 합쳐질 수 있다는 것을 알 수 있어요~


### 2. zip
![스크린샷 2020-11-25 오후 1 44 41](https://user-images.githubusercontent.com/54928732/100184225-5ff2ae00-2f24-11eb-8efd-8c239db769a2.png)

* sequence를 하나로 묶어주는 역할을 해요.
* 하나의 원소를 받으면, 짝이 맞을때까지 기다렸다가 짝으로 묶고 방출해줍니다.
* 이 때, 하나의 sequence가 끝나버리면 나머지 sequence에 원소가 남아있어도 종료됩니다.

``` swift
example(of: "zip"){
    
    enum Weather {
        case cloudy
        case sunny
        
    }
    
    let left : Observable<Weather> = Observable.of(.sunny,.cloudy,.cloudy,.sunny)
    let right = Observable.of("Lisbon","Copenhagen","London","Madrid","Vienna")
    
    let observable = Observable.zip(left,right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    
    observable.subscribe(onNext : {value in
        print(value)
        
    })
    
    
}

```


## Triggers

### 1. withLatestFrom
![스크린샷 2020-11-25 오후 1 50 22](https://user-images.githubusercontent.com/54928732/100184580-2b332680-2f25-11eb-9175-5d2442af40f8.png)














