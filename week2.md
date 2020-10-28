#  what is OBSERVABLE?  
observable이 무엇일지에 대해서..!  
원서책을 정독을 하니 아주 조금 이해가 되더군요... 이제 직접 쓰면서 복습을 하며 제대로 제 것으로 만들고 여러분과도 공유하도록 하겠습니다 ㅎㅎ.  

## more than one name  
observable은 다양하게 불려질 수 있습니다!  
1. observable  
2. observable sequence  
3. sequence  

..모두! observable 입니다.  
이런 이름에서 느낄 수 있지만 '순서'(sequence)가 뭔가 observable 에서 중요한 것 같죠..?  
이러한 **sequence**는 다른 개발러들이 부르는 **stream** 입니다.  
그리고 책에서는 'RxSwift안에서 노는 인싸'들은 stream 같은 단어를 쓰지 않고 **sequence**를 쓴다고 말하며 강조합니다 (LOL).  

그리고 한 문장으로 observable을 정리합니다.   
" an Observable is just a sequence, with some speical powers."  


## emitting  
observable 은 순서에 따라 'emit' 되는 구조를 가집니다.  
emit은 분출하다, 라는 뜻을 가진 단어죠!  
말 그대로 observable 에서 요소 1, 2, 3 **Event**가 순서대로 생성되는 것을 emitting 이라고 칭합니다.  
**event**개념에 대해서는 계속 다루게 될 것이니 따라오시면 됩니다!  
다만, event는 **숫자나 커스텀한 인스턴스 등**과 같은 값을 가질 수 있습니다. 또한 탭과 같은 제스처 등 또한 인식할 수도 있습니다.  


## Life Cycle of Observables (terminating)  
observable의 이벤트들은 그럼 언제 terminate 되는 걸까요?  
위에서 예를 들었듯이 요소 1, 2, 3 이벤트가 생성되고, 이 때 observable이 각각 하나씩 요소를 emit 할 때 **next** event 에서 하라는 대로 실행이 되어지게 됩니다. 

그리고 실행이 모두 되어진 후에는, 이제 모든 이벤트가 실행되었으니 '종료'를 하게 되는데, 이렇게 종료되게 되면 **completed** event 라고 부르게 됩니다!  

![image](https://user-images.githubusercontent.com/37579661/97113414-7e029e00-172d-11eb-8c8e-f1398fefcf90.png)

그래서 위의 사진에서 보이는 'vertical bar' 가 observable의 끝을 알려주게 됩니다.  

![image](https://user-images.githubusercontent.com/37579661/97395155-9d651b00-1927-11eb-8c84-b8469c823019.png)

하지만 깔끔하게 complete event 가 되지 못하고 terminate 되는, error 가 일어나는 경우가 있습니다.  

그래서 정리하자면!  
1. 하나의 observable은 특정 요소를 지니고 있는 **next** events를 emit 한다.  
2. 이러한 Observable 은 error event가 방출되거나 / completed event 가 방출되면 죽는다. 
3. 한번 observable이 죽으면 더이상 event 를 방출하지 못한다.  


## Creating observables 

### operators  

Rx swift 에서는 **methods**가 **operators**를 의미합니다!  

함께 observable을 만들어보기 시작합시다. 먼저 이 부분을 복붙을 하고 시작하죠 ~    
```swift
example(of: "just, of, from") {
  
  // 첫번째 부분
  let one = 1
  let two = 2
  let three = 3
  
  // 두번째 부분
  let observable: Observable<Int> = Observable<Int>.just(one)
}

```

위에서는 두가지를 한 것입니당  
**첫번째 부분** :  integer constant, 즉 정수 상수 세가지 ( one, two three) 를 정의함 
**두번째 부분** : Int 타입의 observable sequence 를 만들어주었습니다! 근데 **just** method 를 *one* integer 를 사용하여 만들어준 것을 알 수 있죠!  

그럼 just 메소드...? 이런것들이 뭔지 알아봅시당~~  

0. just  
말그대로 just one method. 한가지만, 오직 하나의 요소를 포함하는 "Sequence"를 생성합니다.  
- [one, two, three]처럼 **하나의 배열** 도 삽입 가능합니다!  

그래서 아마 
`  let observable: Observable<Int> = Observable<Int>.just(one) `
이 줄은 '1' 을 내보내는 줄이 될 것 같습니다!!  



1. of  
**of** operator:
![image](https://user-images.githubusercontent.com/37579661/97396516-97bd0480-192a-11eb-9a2f-613014cabef4.png)
  
 of연산자는 주어진 값들의 **타입추론**을 통해 Observable sequence를 생성합니다!  
 *저는 사실 타입추론이 저어엉확히 무슨 의미인지 모르겠습니다... ( 같이 얘기해봐여..ㅎ)*  
 
 따라서, 어떤 array를 **observable array**로 만들고 싶다면, array를 `.of 연산자`에 집어 넣으면 됩니다!  
 
 ```swift 
//그냥 int 로!  
 
let observable2 = Observable.of(one, two, three)


//observable2 의 inferred type은 integer, array 값을 넣고 싶다면 observable3에서 처럼 array 로 선언하면 됨

let observable3 = Observable.of([one, two, three])
   
 ```
    

2. from  

**from** operator:
![image](https://user-images.githubusercontent.com/37579661/97396575-b3280f80-192a-11eb-8baf-5a3055b945d4.png)  

from operator 는 **array 배열만 취급** 한다.  

```swift
//observable을 만드는 또다른 operator 는 from !
let observable4 = Observable.from([one, two, three])`

```

## Subscribing to observables  
위에는 '만들기'만 하는것이지, 한번도 그것을 print 하거나 사용하지 못했다~~ 
왜냐하면! subscribe 를 하지 않으면 아무것도 프린팅 되지 않기 때문이다~~!!~!~  

- 그냥 Notification Center 와 비슷한 개념이라고 합니당 (저는 정말 이런 개념이 부족해서 정확하게 먼소리인지 모르게뜸)  
예를 들어..  
```swift
let observer = NotificationCenter.default.addObserver(
  forName: .UIKeyboardDidChangeFrame,
  object: nil,
  queue: nil
) { notification in
  // Handle receiving notification
}
```
이런 코드에서 `addObserver()`를 하는 것이 아니라~~ RxSwift에서는 `subscribe()`를 사용한다고 하네요!  

- 차이점이 있다면, 보통 only its `.default` singleton을 사용하는데, RxSwift 에서는 each observable 이 모두 다르다고 합니당.  
*원문: ‘Unlike NotificationCenter, where developers typically use only its .default singleton instance, each observable in Rx is different.’*

- **가장 중요한 포인트**는, observable은 **subscriber**를 가질 때 까지는 자신의 event를 절대 보내지 않습니다!!  
항상 observable이 **sequence definition**이라는 점을 잊지 말아야한다는 것~~  

- 즉, subscribe 를 한다는 것은 Iterator 에 `next()`를 호출하는 느낌적인 느낌인 것이쥬  

```swift
let sequence = 0..<3

var iterator = sequence.makeIterator()

while let n = iterator.next() {
  print(n)
}

/* Prints:
 0
 1
 2
 */
```
![image](https://user-images.githubusercontent.com/37579661/97400297-3bf67980-1932-11eb-93ab-e11a6abf143d.png)

물론 위와 비슷하긴 하지만, subscribing 은 조금더 **간소화된** 느낌입니당.  

- 각각의 observable이 방출할 수 있는 event type에는 **handler**도 추가할 수 있습니다.  
    - e.g. `.next`는 `handler`를 통해 방출된 요소를 패스할 것이고,
    - `.error`는 error 인스턴스를 가지게 됩니다.  


이제 한번 subscribe 를 해봅시당!  

```swift

example(of: "subscribe") {
  
  let one = 1
  let two = 2
  let three = 3
  
  let observable = Observable.of(one, two, three)

}

```

기억나시나요... 저희가 만들었던 observable ~~  

여기에 어떻게 하면 subscribe 를 하게 할 수 있을까요 !!!  

바로바로 아래 코드를 삽입하면 됩니당.  

```swift
observable.subscribe { event in
  print(event)
}
```

어디에 넣으면 될지 생각해봅시당.  

여튼 넣어서 돌려보면! 정말 신기하게도!!!!!!  

![image](https://user-images.githubusercontent.com/37579661/97401501-46197780-1934-11eb-9b14-0aca9a0a8bd8.png)


이렇게 뜹니당..  

말그대로 one, two, three 1, 2, 3 을 차례로 emit 하고, 마지막으로 complete 되는 것이죠!  

1. the observable emits `.next`event for each element
2. emit a `.completed` event 
3. terminated. 


이렇게만 넘어가면 SubSub하니 조금더 자세히 subscribe 함수를 들여다 볼까요..? (제가 제일 싫어하는 거)  

![image](https://user-images.githubusercontent.com/37579661/97401643-84169b80-1934-11eb-95d4-6e47178655d4.png)


신기하게도!  
subscribe 를 하게되면 `escaping closure`를 취하여 Int 타입의 이벤트를 실행하고, 아무것도 리턴하지 않고, 그리고 `Disposable`을 리턴하는 것을 볼 수 있습니다!!  


- Unwrap the element when subscribing  
위의 subscribe 프린트 값은!! Event(1)  이런 값이었죠..  
근데 사실 저희가 프린팅을 할 때 Event 안에 1 이 있다~ 이정도까지 원하지 않고 처음에 넣은 int type 값을 프린트 하고 싶을 수 있습니다. 아니 그냥 맨날 그러고 싶겠죠 ㅋ  

그런 경우에는!!  
- `Event` 안에 `element` 속성이 있다는 것을 사용합니다!  
따라서, 
1. `optional binding` 사용
2. unwrap the elemnt if it is NOT nil !  

요로코롬 할 수 있죠.  
이렇게 하기 위해서는 어떻게 subscribe 함수 부분을 수정할 수 있을까요????????  

```swift
observable.subscribe { event in
  
  if let element = event.element {
    print(element)
  }
}
```
![image](https://user-images.githubusercontent.com/37579661/97402302-b07ee780-1935-11eb-8d21-c0fd91feca43.png)

이렇게 할 수 있습니당~. 

저는 정말 이런 언뤠핑 이런 막 그런 개념이 헷갈렸는데 이걸 보니 조큼 이해가 되긴 하네요...ㅎ.  


## subscribe operator

위에서 다음과 같은 코드를 짰었습니다.  

```swift
observable.subscribe { event in
  
  if let element = event.element {
    print(element)
  }
}
```

하지만 이것을 줄일 수 있을까용?  

줄일 수 있습니다!! 이에 대한 해결방안은 바로 **subscribe operator**의 사용입니다!  

1. `onNext `
다른건 다 무시하고 `.next` 이벤트의 element만 다루게 됩니다!  
`onNext` 클로져는 **`.next`의 이벤트 element를 하나의 argument 로서 받아드려서**  
줄이기 전의 코드에서 처럼 막 이벤트에서 요소를 따로 막 가져오고 등등을 할 필요가 없게 됩니다!  

줄인 버전:  
```swift
observable.subscribe(onNext: { element in
  print(element)
}) 
```


## empty observable!  
말 그대로 비어있는~~ observable 을 만들 수도 있따는 것입니둥...  
정말 쓸데없어 보이지 않나여..?  
저도 그렇게 생각하고 원서를 쭉 읽으니까 이유를 알려주더라구영.  
이유 : "바로 그냥 죽어버리는 observable을 리턴하고 싶거나 의도적으로!! 0 값을 가지는 observable 을 리턴하고 싶을 때 아주 유용하답니당" - 원서 저자  

...  
저는 이해하지 못하겠어여 근데 훗날... rxswift 로 개발하다가 뭐.. 위와 같은 상황이 오나봐여...ㅎ  


여튼! 어떻게 empty observable을 만드느냐!  
아래와 같습니다.  

```swift
example(of: "empty") {

  let observable = Observable<Void>.empty()
}
```

이것을 subscribe 하게 될 때 유의할 점은, 애초부터 아무것도 없는 observable 이기 때문에  
observable의 타입을! 아주 정확히 지정해줘야 한다는 것입니당~~~. 
그래서 위에 코드를 다시 살피면 `Void` 로 지정이 되어있죠!  

Subscribe code:  
```swift 
observable
  .subscribe(
    
    // 1
    onNext: { element in
      print(element)
  },
    
    // 2
    onCompleted: {
      print("Completed")
  }
)
```

![image](https://user-images.githubusercontent.com/37579661/97404871-1f5e3f80-193a-11eb-9ab7-c59e980f9f84.png)


이렇게 정말루다가 아무것도 안나오쥬?  

## never operator  
never.... naver....  
말그대로 아무것도 emit 하지도 않고 절대 죽지도 않는 (never terminates) observable 을 만들어주는 것입니당.  
대체 이건 또 웨 있는걸까요 알수가 없죠~.  

그냥 infinite duration 을 나타내기 위해 사용된다고 하네요.   

코드:  
```swift 
example(of: "never") {
  
  let observable = Observable<Any>.never()
  
  observable
    .subscribe(
      onNext: { element in
        print(element)
    },
      onCompleted: {
        print("Completed")
    }
  )
}

```

![image](https://user-images.githubusercontent.com/37579661/97405403-f0949900-193a-11eb-9148-2df5293e070c.png)

정말로!  
complete 도 안뜹니다! emit도 없고~ 죽지도 않는~ never observable 이었습니당.  


## explicit variable 말고 range of values 를 생성해보깅  

이때쯤되면 구냥 잘 코드 이해가 될거라고 믿습니둥.  

```swift
example(of: "range") {
  
  // 1
  let observable = Observable<Int>.range(start: 1, count: 10)
  
  observable
    .subscribe(onNext: { i in
      
      // 2
      let n = Double(i)
      let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
      print(fibonacci)
  })
} 
```

![image](https://user-images.githubusercontent.com/37579661/97405758-803a4780-193b-11eb-948d-9f842f463f79.png)



## Disposing and terminating  
자 이제 잘 생각해봅시당..  
일단 observable 을 만들어도 subscription이 없다면 아무것도 emit 되지 않는 다는 것을 알았습니다!  
즉, 생각해보면 **subscription 은 observable의 emit을 손아귀에 쥐고 있다**는 것이죠!  
그리고, 한번 subscription 을 통해 emit 이 시작되면! `.error`, 또는 `.completed`가 나올 때 까지는 계속 emit이 되고 장렬히 전사(terminated)합니다.  
그렇다면, subscription 을 이용하여 **observable 의 emit을 중단** 시킬 수도 있습니다!   
어떻게 하면 될까요?  
그냥 subscription 을 **취소** 해버리는거죠!!!!!!!!!  (마치 제 아이디어 같지만 원서에 나와있습니다ㅋ).  



### dispose()  
```swift
example(of: "dispose") {
    
    // 1
    let observable = Observable.of("A", "B", "C")
    
    // 2
    let subscription = observable.subscribe({ (event) in
        
        // 3
        print(event)
    })
    
    subscription.dispose()
}
```

근데ㅔㅔ 여기에서는 element가 딱 세개잖아여... 그래서 그냥 아라서 원래 terminate 가 됩니다!  
근데 이제 그냥 포인트는 `.dispose()` 저렇게 쓰면 바로 terminate 시킬 수 잇따! 라는 것!  
그래서 **요소가 무한히 있는** observable 에서는 `.dispose()` 가 쓰여야지만!! `complete` 됩니다.  


## dispose bag  
쓰레기 봉투...죠 ㅋ.  
위에서 처럼 each observable 마다 `.dispose()` 해서 관리하는 것은 갱장히 비효율적이다..  
그래서 사용하는 것이 ! `DisposeBag` 타입이다.  

DisposeBag에는 (보통은 `.disposed(by:)` method를 통해 추가된) disposables 가 존재한다.  

그리고 그렇게 DisposeBag 안의 disposable들은 dispose bag이 **할당 해제** 하려고 할 때마다 `dispose()`를 호출한다.


코드: 
```swift
example(of: "DisposeBag") {
     
     // 1
     let disposeBag = DisposeBag()
     
     // 2
     Observable.of("A", "B", "C")
         .subscribe{ // 3
             print($0)
         }
         .disposed(by: disposeBag) // 4
 }
```
정말 말 그대로  
1. observable 만들고.  
2. 바로 쓰레기 통에 넣어버리기.  

이 과정의 반복이고, 놀랍게도 계에에에에에에ㅔㅔㅔ속 반복적으로 보게되는 형태!!! 라고 한다.  

그 이유는 바로 **메모리 누수**를 막기 위해서이다~~~.   


## .create(:)  
observable을 지금까지는 `.next`이벤트를 활용하여 만들어왔다!  
하지만 `.create(:)` 로도 만들 수 잇다!  

```swift
example(of: "create") {
    let disposeBag = DisposeBag()
    
    Observable<String>.create({ (observer) -> Disposable in
        // 1
        observer.onNext("1")
        
        // 2
        observer.onCompleted()
        
        // 3
        observer.onNext("?")
        
        // 4
        return Disposables.create()
    })
}
```

create 는 `escaping` 클로저입니다! 
그리고 이 escaping에서 `AnyObserver`를 취한 뒤 Disposable을 리턴합니다! (위에 코드에서 알 수 있죵).  

AnyObserver는 또 뭘까여...하...  
이것은!! 해당 Observable을 구독하게 될 Observer라고 생각하면..된다고 합니다...  
`generic` 타입으로, Observable sequence에 값을 쉽게 추가할 수 있게 해준다고 하네용. 그냥 그 아래서부터 `observer.onNext("1")` 이런식으로 `.onNext()` 만 계속 붙여서 추가가능하다는 말같습니다!  

그리하여 이렇게 추가한 값은 subscriber에 방출되게 됩니다!!   

위의 코드에서는.  

1. `.next` 이벤트를 Observer에 추가 ( onNext(_:)는 on(.next(_:))를 편리하게 쓰는 용도 ).  
2. `.completed` 이벤트를 Observer에 추가 (onCompleted 역시 on(.completed)를 간소화한 것).  
3. 다시 한번 `.next` 이벤트를 추가.  
4. 마지막으로 disposable을 리턴!   

근데 여기서 눈치를 채셔야합니다... 무엇일까유?  

아래 코드를 같이 돌려봐서 뭐가 문제인지 확인해봅시다!  
```swift
example(of: "create") {
     let disposeBag = DisposeBag()
     
     Observable<String>.create({ (observer) -> Disposable in
         // 1
         observer.onNext("1")
         
         // 2
         observer.onCompleted()
         
         // 3
         observer.onNext("?")
         
         // 4
         return Disposables.create()
     })
         .subscribe(
             onNext: { print($0) },
             onError: { print($0) },
             onCompleted: { print("Completed") },
             onDisposed: { print("Disposed") }
     ).disposed(by: disposeBag)
 }
 
```

답은 바로!   
?  가 방출되기 전에 observable이 죽어버린다는 거죠!  
그래서 ? 는 print 가 되지 않게 됩니다~~~~.  

그럼 한번 일부러 **에러** 도 삽입해봐서 정확히 어떤 영향을 미치는지 확인해봅시다!  

```swift
enum MyError: Error {
     case anError
 }
 
 example(of: "create") {
     let disposeBag = DisposeBag()
     
     Observable<String>.create({ (observer) -> Disposable in
         // 1
         observer.onNext("1")
         
         // 5
         observer.onError(MyError.anError)
         
         // 2
         observer.onCompleted()
         
         // 3
         observer.onNext("?")
         
         // 4
         return Disposables.create()
     })
         .subscribe(
             onNext: { print($0) },
             onError: { print($0) },
             onCompleted: { print("Completed") },
             onDisposed: { print("Disposed") }
     ).disposed(by: disposeBag)
 }
```

![image](https://user-images.githubusercontent.com/37579661/97411669-ec20ae00-1943-11eb-9692-0a4a2f0f01fa.png)

이렇게 출력이 되게 됩니다!!  
신기한 life cycle!  

한번 `.compelete`, `.onError`모두 지워보고도 한번 출력해봅시다~~~~  


