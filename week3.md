Week3  What is Subject?
=========

지난주에 이어서 Subject에 대해 공부해 봅시당!! 전반적으로 훑어보니 Observable에 대한 이해가 Subject를 이해하는 데에 큰 도움이 될 것 같군요


Subject 는 지난 주에 같이 공부했던 Observable과 연관지어서 생각할 수 있어요. Subject의 속성을 간단하게 정리해보자면, Subject는 Observable이 될 수도 있고 Observer가 될 수도 있어요. 
즉, Subject는 observable과 observer의 역할을 모두 할 수 있는 bridge/proxy Observable이라 생각하면 됩니다. 그렇기 때문에 Observable이나 Subject 모두 Subscribe를 할 수 있어요. 


그렇지만 Subscribe 하는 방식의 차이가 있는데요, Subject는 여러개의 Observer를 subscribe할 수 있는 multicast 방식 , 단순한 observable은 observer 하나만을 subscribe할 수 있는 unicast 방식입니다. 

사진으로 간략하게 살펴보면

![626152392 38](https://user-images.githubusercontent.com/41604678/98065129-3ac7ce00-1e97-11eb-9e54-84c417bf9e09.png)



차이가 확연히 보이시나요? subject는 multicast 방식을 취하는것을 확인할 수 있습니다. 

# Types of Subjects
Subject에는 종류가 4가지가 있습니다. 원서에 나온 간단한 정의를 살펴보자면,

* Publish Subject   
: 아무것도 없는 빈 상태로 subscribe를 시작하고, 오직 새로운 elements 만 subscriber에게 emit 시킨다. 

* Behavior Subject   
: 초기화 값을 가진 상태로 시작하는 것이 Publish Subject와의 차이점. 초기값을 방출하거나, 가장 최신의 (가장 늦은) element들을 새 subscribers에게 
방출한다. 

* Replay Subject   
: 초기화 된 buffer size로 시작한다. 그 사이즈까지 buffer의 원소들을 유지하며 새로운 subscriber들에게 방출한다. 

* Variable   
: Variable은 Behavior Subject를 래핑하고, 현재의 값을 상태로 저장한다 . 그리고 초기값 또는 가장 최신의 값만 새로운 subscribers에게 방출시킨다. 
   
이렇게 4가지 타입의 subject가 있어요!! 간단히 책에 나온 정의들을 살펴보았고 지금부터는 타입별로 하나씩 코드와 함께 이해해 봅시당~~


## Getting started

먼저 Publish Subject를 생성하는 것을 해보면서 subject에 대해 알아봅시당!! 
신문 publisher 처럼 subject는 정보를 받고 이걸 subscribers에게 발행하는 역할을 합니다. 

```swift
example(of: "PublishSubject"){
    let subject = PublishSubject<String>()
    }
```

<String> 타입을 받고 publish 하는 subject 를 생성해 주었습니다. 그다음으로 아래의 코드를 작성해주세요. 
 
 ```swift
 subject.onNext("Is anyone listening?")
 
 ```
 새로운 element 를 subject에 추가해주었습니다. 그렇지만 여기까지 코드를 써주었을 때 console창에는 아무것도 찍히지가 않죠 !
 observers가 없기 떄문입니다. 그렇다면 subject에 대한 subscription을 생성해 봅시다. 
 
 ```swift
    let subscriptionOne = subject.subscribe(onNext: { string in print(string)})
    
 ```

여기까지 코드를 써주어도 Xcode에는 아무것도 출력되지 않아요 ㅠㅠ    

 ```PublishSubject ``` 는 현재의 subscribers에게만 emit하기 때문입니다. 우리가 써준 코드에는 아직 subscriber가 없어요.
 
 ```swift
    subject.on(.next("1"))
 ```
   
   
이렇게 한줄 추가해주면 이제 드디어 subject는 subscriber가 생긴거에요.   
그리고 당연히 <String> 타입으로 subject를 publish 했으니까 <String>타입만 값을 넣어줄 수 있겠죠.

아래의 전체코드에는 새로운 subscriber를 또 추가시켜주었습니다.

   
```swift
example(of: "PublishSubject"){
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    
    let subscriptionOne = subject.subscribe(onNext: { string in print(string)})
    
    subject.on(.next("1"))
    subject.on(.next("2")) //new subscriber
}
```

```swift
subscriptionOne.dispose()
subject.onNext("4")

```

다음 두 줄을 추가해주면 ?? subscriptionOne 이 dispose 됩니다.. 그래서 결과는

```

2) 4

```

4 하나만 출력이 되는 것이죠!


## Publish Subject

   
* Publish Subject   
: 아무것도 없는 빈 상태로 subscribe를 시작하고, 오직 새로운 elements 만 subscriber에게 emit 시킨다.    


![스크린샷 2020-11-04 오후 12 32 43](https://user-images.githubusercontent.com/41604678/98066269-e40fc380-1e99-11eb-88c8-f00a652189cc.png)


그림을 이해하면 어떻게 동작하는지 이해가 잘 되는것 같아요. 첫번째 줄이 subject이고 두번째 줄이 first subscriber, 세번째 줄이 second subscriber입니다.   
두번째 줄에서, 첫번째 subscriber가 1) 다음에 subscribe 하는걸 볼수 있습니다. 그래서 1) 에 해당하는 event는 받을 수 없어요. 구독한 이후로 받은 2) 와 3)을 받게 됩니다. 
두번째 subscriber도 이와 같은 원리로, 2) 이후로 subscribe 했기 때문에 3) 만 가져갑니다 ~

다음의 코드를 이어서 추가해 주세요.


```swift

let subscriptionTwo = subject.subscribe { event in print("2)", event.element ?? event)}

```

```subscriptionTwo```는 아직 아무것도 print하지 않게됩니다. 왜냐하면 앞에서 1 과 2 가 이미 방출된 이후에 subscribe 했기 때문 !! 

다음의 코드를 추가해서 subscription을 추가해줍니다.

```swift
subject.onNext("3")
```

결과는 다음과 같습니다. 3 은 두 번 출력되는데 왜그런걸까요 ?? 3은 이는 subscriptionOne ,subscriptionTwo 각각의 구독에 의한 출력입니다. 

```
3
2) 3
```

publish subject 도 .completed 또는 .error 이벤트를 받습니다 !! (후에 variable은 이 두가지 이벤트를 받지 않음)   
stop event 를 새로운 subscribers에게 emit 한다 라고 책에는 복잡하게 쓰여져 있는데 말그대로, 더이상 emit 하지 않도록 정지시켜주는 이벤트들입니다.
신기했던건 한번 이렇게 stop event를 emit 시켜주면, 그 다음에도 stop event 가 re-emit되어서 future subscribers에게도 영향을 미칩니다. 
코드를 실행시켜보면 이해가 쉽게 될거에요


```swift

    //1
    subject.onCompleted()
    //2
    subject.onNext("5")
    //3
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    
    //4
    subject.subscribe {
        print("3)", $0.element ?? $0)
    }.disposed(by: disposeBag)
    
    subject.onNext("?")
    
```
    
   결과는 다음과 같습니다. 정말로 future subscribers이 emit을 하지않았죠!!
   
   
```
      2) completed
      3) completed
```




##  Behavior Subject

* Behavior Subject   
: 초기화 값을 가진 상태로 시작하는 것이 Publish Subject와의 차이점. 초기값을 방출하거나, 가장 최신의 (가장 늦은) element들을 새 subscribers에게 
방출한다. 

![스크린샷 2020-11-04 오후 12 32 48](https://user-images.githubusercontent.com/41604678/98066292-f558d000-1e99-11eb-879d-99bbc99f9966.png)


첫번째 라인은 subject
두번쨰 라인은 첫번째 subscriber로, 살펴보면 1) 이후 2) 직전에 1) subscription 을 갖게 됩니다. 그리고 2) 와 3) 은 subject에 의해 emit 되어요
세번째 라인은 두번째 subscriber로, 2) 이후 3) 이전에 subscribes 하므로, 2) subscription을 즉시 갖게 되고 그 후에 3) 이 emit 됩니다.

새로운 코드입니다 짠 확인해봅시당

```
enum MyError:Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>)
{
    print(label, event.element ?? event.error
     ?? event)
}

example(of: "Behavior Subject")
{
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
}
```

먼저 error type을 정의해주었고, print function을 만들어 주었습니다.   그 다음에 example을 시작했고 example 안에 Behavior Subject를 초기화해주었어요.   

그다음에 이 코드를 써주세요
```swift 
   subject.subcribe {
        print(label: "1)", event: $0)
    }.disposed(by: disposeBag)
```
 
 위의 코드는 subject에 대해 subscription을 만들어 주지만 subscription은 subject 이후에 생성됩니다. 이게 무슨말인가 하면.. ??
 아직 subject에 아무런 요소들이 더해지지 않았기 때문에 여전히 subscriber에 초기화된 값을 replay (다시 방출한다. 책에서는 replay 라는 용어로 사용했음)할 것입니다.
 
 
 ```
 
 --- Example of: BehaviorSunject ---
 1) Initial value
 
 ```
 
이해가 되시나요??? 말이 되게 어렵게 쓰여져 있는데, subscription이 아직 생성되지 않아서 초기화된 값(initialized value)가 출력되었어요.

* Behavior Subject   
: 초기화 값을 가진 상태로 시작하는 것이 Publish Subject와의 차이점. 초기값을 방출하거나, 가장 최신의 (가장 늦은) element들을 새 subscribers에게 
방출한다. 

다시 정의를 끌어와 보면 저 위의 예시에서는 초기값을 방출했다!!는 것을 확인한


여기서 조금만 더 실험을 해봅시당

   
```swift
       subject.onNext("X")
    
```

console에는 X값이 출력되는 것을 확인할 수 있어요. 왜냐하면 이 상태에서는 "X"가 subscribtion 상태가 만들어질 때 가장 늦게(최신의) 만들어진 요소이기 때문에 "X"가 출력이 됩니다.

```swift
 subject.onError(MyError.anError)
    //error 이벤틀를 subject에 추가해 주었습니다.
    
    subject.subscribe {
        print(label: "2)", event: $0)
    }.disposed(by: disposeBag)
    
```

결과 값을 보면 이해가 되네요. subscribe 1 가장 최신의 element가 error 이벤트인데 label "1)", "2)" 과 같이 출력되어 찍히는걸 보면 새로운 subscriber들(라벨 표시한 코드블럭 두 개)에게 error 이벤트 값을 emit 시키는걸 확인할 수 있어요!!


```
1) anError
2) anError

```



<BehaviorSubject 는 항상 최신의 element를 방출한다.> 라는 정의가 여기서 확인되네요.

그렇지만 초기화값이 없는 경우에는 Publish Subject를 대신 사용하는 것이 옳다. 초기화 값이 없으면 emit할 element가 없겠죠 ?


## Replay Subject

* Replay Subject   
: 초기화 된 buffer size로 시작한다. 그 사이즈까지 buffer의 원소들을 유지하며 새로운 subscriber들에게 방출한다. 
이름 그대로 buffer size 에 도달할 때까지 계속 방출해준다(replay한다)는 의미라고 이해하면 쉬울 것 같아요. replay subject는 일시적인 캐시 (혹은 buffer) 에서 가장 최신의 elements를 반복하여 방출합니다.


저는 공부하면서 이 Replay Subject가 가장 인상깊었어요. 

![스크린샷 2020-11-04 오후 12 32 54](https://user-images.githubusercontent.com/41604678/98066300-f984ed80-1e99-11eb-99ee-34f87edca10c.png)




여기에 나오는 다이어그램은 buffer size가 얼마일까요 ?? 



.
.
.
.
.
.
buffer size가 바로 2라고 짐작이 가시나요? replay되는 elements 들이 1) 2) 두개니까 buffer size 는 2 가 됩니다 ~~

두번 째 라인에 있는 첫번째 subscriber는 이미 맨 첫번째 줄에 있는 replay subject에 구독된 상태입니다. 그래서 그들이 방출될때 요소들을 갖게 됩니다. 두번째 subscriber는 1번, 2번을 또 다시 방출하게 되는 것이지요 (책에서는 반복해서 값을 방출하는걸 replay라고 표현함)

주의할 점!!
이 replay subject를 사용할 때는 buffer가 메모리 안에서 보존되는 것이므로 이미지파일처럼 용량을 왕창 잡아먹는 인스턴스들을 replay시키는 size가 큰 buffer를 설정해두면..?
각각의 방출되는 elements들은 array가 될것이고 buffer size는 그 많은 array들을 가지고 있어야만 해요 그러니까 메모리에 부담을 줄 수 있으니 사용시에 이런 경우는 주의하는 것이 좋습니다


```swift
example(of : "ReplaySubject") {
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    // created new replay subject with a buffer size of 2. Replay subjects are initialized using the type method create(bufferSize: )
    
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    //add three elements onto the subjects
    
    subject.subscrib{
        print(label: "1)", event: $0)
    }.disposed(by: disposeBag)
```



바로 코드에 대해 이해가 가시나요 ?????

여기서 책은 한줄 더 추가해보라고 시킵니다 ㅎㅎ




* 전체코드

```
example(of : "ReplaySubject") {
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    // created new replay subject with a buffer size of 2. Replay subjects are initialized using the type method create(bufferSize: )
    
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    //add three elements onto the subjects
    
    subject.subscrib{
        print(label: "1)", event: $0)
    }.disposed(by: disposeBag)
    
    subject.subscribe{
        print(label: "2)", event: $0)
    }.disposed(by: disposeBag)
    
    subject.onNext("4")
    
    subject.onError(MyError.anError)
    
    subject.dispose()
    
    // This may surprise you
    // And if so, that's OK Life's full surprises
    
    subject.subscribe{
        print(label: "3)", event: $0)
    }.disposed(by: disposeBag)
    
    //create two subscriptions to the subject
    
    // 최신의 두 elements 만 subscribers에 replay 된다. 1은 방출되지 않는다. 왜냐하면 2 와 3은 replay subject에 buffer size 2 로 더해진다.
    
    // 그동안 방출된 이벤트 중 최근의 것들을 특정 사이즈만큼 캐시(버퍼)시켜 놓는다.
    //이것을 새로운 구독자들에게 재방출한다.
}
```

## Variable

앞서 언급했듯 Variable 은 
* BehaviorSubject를 래핑한다 !!! 
* 그리고 그것의 현재 값을 상태로 저장한다.
* value 프로퍼티를 통해서 현재 값에 접근할 수 있다. 

라는게 책에서 나오는 간단한 정의인데요 여기까지 들어만 봐도 앞에서 나온 다른 subjects들과는 좀 달라 보이지요 ?

Variable을 사용시에 method와 관련해서, 주의해야할 것들이 몇 가지 있어요.

* onNext(_:) 매소드를 사용하지 않는다!
: 
value property를 variable에 새로운 요소를 정해주기 위해서 사용합니다. 

* asObservable() 
: 
Variable은 Behavior subject를 래핑하므로 variable은 초기값과 함께 생성됩니다.  
(Behavoir subject는 초기값을 가지니까요~) 그리고 Variable은 가장 최신의 값 또는 초기값을 새 subscribers에게 replay 합니다.
variable에 밑에 있는 behavior subject 에 접근하기 위한 메소드가 asObservable() 입니다.

* error event 를 방출하지 않음
:
그리고 또 Variable의 독특한 점은, 다른 subjects들과 달리 error 를 방출하지 않도록 설정되어있답니다. _: 대체 왜 ?
다시 말해서 .error event 가 subscription에 있다고 해도 .error event를 variable에 추가시킬수 없다는 것!! 

* complete event를 추가히지 않아도 됨
: variable은 deallocated되려고 하는 순간에 스스로 일을 완료시켜버립니다. 그래서 직접 .completed event를 추가해주지 않아도 됩니다. 사실상 추가할 수 없어요.


여기까지 variable에 대한 특징 설명은 복잡해보이지만 이러한 특징덕분에 코드를 쓸 때 조금 더 간편하게 느껴졌습니다.





