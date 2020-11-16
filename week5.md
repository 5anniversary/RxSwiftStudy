# Chapter 7: Transforming Operators



## Getting Started

- 이번 챕터에선 RxSwift에서 연산자에서 제일 중요한 연산자라고 할 수 있는 **변환 연산자(Transroming Operators)**에 대해 알아보겠습니다. 
- 이 변환 연산자는 subcriber를 통해 observable에서 데이터를 준비하는 것 같은 모든 상황에서 쓰일 수 있습니다. 
- Playground 생성하기
- 시작하기 전, 아래 코드 삽입해주세요~!

```swift
public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
```

## Transforming elements

이제부터 transforming operator에 대해서 하나씩 알아봅시다.

### 1. toArray()

<img src="https://user-images.githubusercontent.com/56102421/99221951-efada380-2824-11eb-9020-25492c34c4ff.png" width="80%"/>

- 여러개의 독립적 요소들을 하나의 배열로 묶어서 emit하고 싶을 때 사용하는 연산자입니다.
- CollectionView, TableView 에서 observable을 묶을 때 사용합니다.
- Rxswift 3.3.0버전부터 문법이 변해서 책 예제와 다릅니다.

```swift
example(of: "toArray") {
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C")
        // 2
        .toArray()
        .subscribe(onSuccess: {
            print($0)
        }, onFailure: { (error) in
            print(error)
        })
        .disposed(by: disposeBag)
}
```

위의 코드로 실습해봅시다! 

1. "A", "B", "C"의 observable을 생성
2. toArray를 이용하여 배열로 변형

> **위 코드에서 subScribe 할 때 onNext, onError를 쓰면 에러가 나는 이유**
>
> toArray를 적용하면 Single Observable 타입으로 변하기 떄문입니다. onSuccess, onFailure는 Single Observable의 이벤트 타입입니다. 즉, 1~n의 무한한 이벤트 스트림 처리가 필요하지 않고, 하나의 결과값이나 에러를 처리하고자 하는 모델에서 사용합니다. 일반 Observable에서 처리하는 onNext, onError, onComplete 세가지 처리가 필요없고 Success, Error 처리만 하면 됩니다. 이 Single Observable은 HTTP request 응답을 처리할 때, 하나의 응답 혹은 에러를 처리하려 할 때 사용하면 유용합니다!
>
> 참고 자료 👉 [RxSwift Traits(특성)](https://brunch.co.kr/@tilltue/33)

```swift
--- Example of: toArray ---
["A", "B", "C"]
```

코드를 돌려보면 위와 같이 배열로 묶여서 나오는 것을 확인할 수 있습니다.

### 2. map() 

<img src="https://user-images.githubusercontent.com/56102421/99226121-947faf00-282c-11eb-802c-19c2d7e51180.png" width="80%" />

- RxSwift의 map operator는 Swift의 map과 동일하게 작동합니다. 다른 점 하나는, RxSwift의 map은 observables에서만 작동합니다.

```swift
example(of: "map") {
    
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    // 저번 부분에 나왔던 문법
    
    // 2
    Observable<NSNumber>.of(123, 4, 56)
        // 3
        .map {
            formatter.string(from: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}
```

위의 코드를 통해 실습해봅시다!!! 위 코드의 내용을 번호대로 해석해보면 아래와 같습니다.

1. NumberFormatter를 생성 (지난번에 나왔던 문법!!) - 숫자값과 문자적 표현 사이를 변환해주는 formatter
2.  NSNumber타입의 Observable 생성
3. map 연산자를 사용하여 Number -> String으로 transform 시킴

결과는 아래처럼 나오겠죠?!

```swift
--- Example of: map ---
one hundred twenty-three
four
fifty-six
```

여기서, 지난번 Filtering 챕터에서 나왔던 `enumerated`와 `map`을 같이 써볼 수도 있습니다. `enumerated` 요소의 index와 값을 함께 방출시켜주는 연산자였습니다. 아래 코드를 복붙해서 실습해봅시다!

```swift
example(of: "enumerated and map") {
  
  let disposeBag = DisposeBag()
  
  // 1
  Observable.of(1, 2, 3, 4, 5, 6)
    // 2
    .enumerated()
    // 3
    .map { index, integer in
      index > 2 ? integer * 2 : integer
    }
    // 4
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}
```

위 실습내용은 index값이 3이상이면 값에 2를 곱하고, 3미만이면 값을 그대로 방출시키는 코드입니다. 

map은 Swift에서도 자주 사용하는 연산자이니 코드설명은 생략하도록 할게요!!! 혹시 모르시겠다면 질문해주세요!

결과코드는 아래와 같아요.

```swift
--- Example of: enumerated and map ---
1
2
3
8
10
12
```

## Transforming inner observables

이제부터 알아볼 연산자는 `flatMap`에 대한 연산자입니다!  `flatMap`도 Transforming 연산자 중 하나인데, 왜 소제목이 나뉘었을까요? 바로 `flatMap`은 inner Observable을 다루기 때문입니다. inner Observable이란 Observable안에 있는 Observable을 말합니다. 잘 이해가 안 될 거 같은데 먼저 `flapMap`이 무엇인지 알아보도록 할게요! 

### 3. FlatMap()

<img src="https://user-images.githubusercontent.com/56102421/99241920-d49d5c80-2841-11eb-98f1-6aac73bb3fe2.png" width="80%" />

`flatMap`에 대해서 책에 나온 정의는 아래와 같습니다.

> Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence

위 문장을 해석해보자면 Obervable 시퀸스의 element 당 한 개의 Observeable 시퀸스를 생성하고 이렇게 생성된 여러개의 새로운 시퀸스를 하나의 시퀀스로 합쳐준다는 뜻입니다. 우와!! 위 그림과 해석만 보면 정말 어려워 보이죠?!?!(책에 그대로 써있는 문장..) ㅠㅠ 위 그림을 하나씩 해석해보겠습니다.

우선 초기에 1, 2, 3의 element가 있습니다. 이 element가 flatMap을 만나게 되면 value에 10을 곱하는 작업을 합니다.

그리고 flatMap은 element가 flatMap을 통해 값을 변경함과 동시에, **element에 해당하는 새로운 sequence**를 반환하게 됩니다. 마찬기지로 1,2,3은 flatMap을 통해 각각의 valuedp 10을 곱한 채로 새롭게 이벤트를 방출하는 시퀸스가 됩니다. 그게 바로 2,3,4번째 줄을 의미합니다.

 그리고 값이 변경이 되면 새롭게 추가된 시퀸스에 변경된 값의 element에 추가가 됩니다. 이게 바로 마지막 줄입니다. 

위 그림에선, element 1이 4로 value값이 변경이 되면 element 1의 sequence에 40이 추가가 되어 값을 방출하게 됩니다. 마찬가지로 element 2의 값이 5로 변경이 되어 2의 sequence에 50이 추가가 되어 최종 Observable에 50이 추가된 것을 볼 수 있습니다. 

조금은 이해가 되나요..?!?

그럼 위 실습을 통해 더 이해해 보도록 하겠습니다.

```swift
struct Student {
    
    var score: BehaviorSubject<Int>
}

example(of: "flatMap") {
    
    let disposeBag = DisposeBag()
    
    // 1
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2
    let student = PublishSubject<Student>()
    
    // 3
    student
        .flatMap {
            $0.score
        }
        // 4
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)   
}
```

위 코드를 번호를 통해 해석해보겠습니다.

1. Student 타입의 변수 2개 생성 (score는 ryan은 80점, charlotte은 90점으로 초기화)
2. Student 타입의 Subject를 생성 (나중에 ryan과 charlotte이 Element로 들어가게 됨)
3. `flatMap`을 통해 Student타입의 시퀸스인 student를 Student 내에 있는 score로 tranform함
4. student시퀸스에서 transform된 score시퀸스를 subscribe함. (`next` 이벤트 발생 시 print됨)

>  여기서 그림과 비교해보면, `student`는 첫번째 줄, source sequence를 의미하고, `ryan`, `charlotte`은 01, 02와 같은 source sequence의 element들을 의미하는 거 같군요..

아직까진 콘솔에  아무 것도 안 찍힙니다. 여기서 아래의 코드를 넣어 봅시다.

```swift
student.onNext(ryan)
ryan.score.onNext(85)

student.onNext(charlotte)
ryan.score.onNext(95)
    
charlotte.score.onNext(100)
 
```

결과는 아래와 같이 나옵니다.

```swift
--- Example of: flatMap ---
80
85
90
95
100
```

student시퀸스에 ryan을 집어넣으면 ryan의 score로 transform되어 80이 출력됩니다. 그 후, score을 85로 바꾸면 85가 출력됩니다. 여기서 ryan의 score에 대한 시퀸스가 하나 더 생성되었다는 것을 알 수 있습니다. 그 뒤의 코드인 charlotte의 경우도 마찬가지로 작동합니다.

정리를 해보자면, `flatMap`연산자의 특징은 생성된 모든 observable의 Element들의 변화를 관찰할 수 있다는 점입니다.

어쩔 때는 이 연산자가 유용한 때가 있을 것입니다. 또 어쩔 때는 마지막 요소만 관찰이 필요한 때도 있을 것입니다. 이 떄를 위해서 `flatMapLatest` 연산자가 있습니다.

### 4. FlatMapLatest()

<img src="https://user-images.githubusercontent.com/56102421/99249667-cfdea580-284d-11eb-8660-491044f7f0bb.png" width="80%" />

- 이 연산자는 `map`과 `switchLatest`연산자를 합친 것.

  `switchLatest`에 대해선 다음 챕터에서 더 자세하게 배울 것입니다. 여기서 맛보기만 하자면, `switchLatest`는 가장 최근 observable의 값만 제공하고, 그 이전의 observable에 대해선 구독하지 않는 연산자입니다.

- `flatMap`과는 달리 Observable의 마지막 요소의 변화만 관찰해주는 연산자

위의 그림을 해석해보겠습니다.

가장 윗줄, source Sequence에 Element가  01, 02, 03이 있습니다. 이 요소들이 차례대로 들어오고 `flatMapLatest`를 만나 10을 곱하는 작업을 하는 것은 위 `flatMap`과 동일합니다. 

하지만, Element 2가 추가가 된 이후에 Element 1의 value값을 3으로 변경시켰지만 무시가 되어 Final Sequence에 전달이 되지 않습니다. 그 이유는 현재 Element 2가 flatMapLatest에 의해 Final Sequence에 추가된 상황으로, 현재 Latest Sequence는 Element 2이기 떄문에 그 이외의 모든 값들은 무시가 되어 Final Sequence에 전달이 되지 않습니다. 

그 이후의 상황도 마찬가지입니다.

아래 실습의 결과를 통해 다른 점을 확실히 알 수 있습니다.

```swift
example(of: "flatMapLatest") {
  
  let disposeBag = DisposeBag()
  
  let ryan = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  
  let student = PublishSubject<Student>()
  
  student
    .flatMapLatest {
      $0.score
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  student.onNext(ryan)
  
  ryan.score.onNext(85)
  
  student.onNext(charlotte)
  
  // 1
  ryan.score.onNext(95)
  
  charlotte.score.onNext(100)
}
```

1번 밑의 코드에서 ryan의 score을 바꿔도 출력되지 않을 것입니다. 그 이유는 flatMaptLatest는 이미 charlotte observable으로 바뀌었기 떄문입니다. 

따라서, 결과는 아래와 같습니다~!

```swift
--- Example of: flatMapLatest ---
80
85
90
100
```



> 자, 그럼 여기서 소제목이 왜 Transforming inner observables인 이유를 생각해보자면, 
>
> 단지 observable내의 element만을 변형시키는 `map`과는 달리, observable내의 element를 변형시키고 또 변화가 일어나면 감지 할 수 있도록 새로운 observable(sequence)을 생성해서 관찰시키기 때문인 것 같습니다. 즉, observable내의 observable이란 말이 이제 이해가 가겠죠..?!
>
> 조금 더 나아가서 코드를 뜯어보면, 
>
> `map`은 Element 타입을 Result 타입으로 바꾸는 반면, `flatMap`은 Element 타입을 다른 Obervable로 바꾸는 것을 볼 수 있습니다.

```swift
// map
public func map<Result>(_ transform: @escaping (Self.Element) throws -> Result) -> RxSwift.Observable<Result>

// flatMap
public func flatMap<Source>(_ selector: @escaping (Self.Element) throws -> Source) -> RxSwift.Observable<Source.Element> where Source : RxSwift.ObservableConvertibleType
```

## Observing events

### materialize()와 dematerialize()

<img src="https://raw.githubusercontent.com/fimuxd/RxSwift/master/Lectures/07_Transforming%20Operators/5.%20materialize.png" width="80%" />

- 이벤트를 관찰하기 위해서 이벤트를 observable로 만들어주고, 다시 원상복귀 시켜주는 연산자입니다.
- **언제 사용하나요?** observable 속성을 가진 observable 항목을 제어할 수 없고, 외부적으로 observable이 종료되는 것을 방지하기 위해 error 이벤트를 처리하고 싶을 때 사용할 수 있습니다. 

아래 코드를 통해 어떤 상황에 쓰는지 확인할 수 있습니다.

```swift
example(of: "materialize and dematerialize") {
     
     // 1
     enum MyError: Error {
         case anError
     }
     
     let disposeBag = DisposeBag()
     
     // 2
     let ryan = Student(score: BehaviorSubject(value: 80))
     let charlotte = Student(score: BehaviorSubject(value: 100))
     
     let student = BehaviorSubject(value: ryan)
     
     // 3
     let studentScore = student
         .flatMapLatest{
             $0.score
     }
     
     // 4
     studentScore
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
     
     // 5
     ryan.score.onNext(85)
     ryan.score.onError(MyError.anError)
     ryan.score.onNext(90)
     
     // 6
     student.onNext(charlotte)
 }
```

주석을 따라 확인해보면 아래와 같습니다.

1. 에러타입을 하나 생성한다
2. .`ryan`과 `charlotte`라는 두개의 `Student` 인스턴스를 생성하고, `ryan`을 초기값으로 갖는 `student` 라는 BehaviorSubject를 생성한다
3. .`flatMapLatest`를 사용하여 `student`의 `score` 값을 observable로 만든 `studentScore`를 만들어준다. (studentScore는 `Observable<Int>`타입)
4. `studentScore`를 구독한 뒤, 방출하는 `score`값을 프린트한다. 
5. `ryan`에 새 점수`85`를 추가하고, 에러를 추가한다. 그리고 다시 새 점수`90`을 추가한다.
6. `student`에 새 Student 값인 `charlotte`를 추가한다.

결과는 아래와 같이 error코드로 인해서 Final Sequence가 죽습니다.

```swift
--- Example of: materialize and dematerialize ---
80
85
Unhandled error happened: anError
```

여기서 `materialize`연산자를 사용하여, 각각의 방출되는 이벤트를 이벤트의 observable로 만들 수 있습니다. 

아래와같이 추가해주면 `studentScore`의 타입이 `Observable<Event<Int>>`로 변한 것을 확인할 수 있습니다!! 신기하네요 ㅎㅎ

```swift
// 3
let studentScore = student
    .flatMapLatest {
        $0.score.materialize()
    }
```

Error는 여전히 `studentScore`를 종료시키지만 바깥 `student` observable은 그대로 살려놓습니다. 따라서 charlotte을 추가했을 때, 콘솔에 100이 찍힙니다!! 

```swift
--- Example of: materialize and dematerialize ---
next(80)
next(85)
error(anError)
next(100)
```

하지만, 이럴 경우, event는 받을 수 있지만, 요소들은 받을 수 없기 때문에, `dematerialize`를 사용합니다.

<img src="https://raw.githubusercontent.com/fimuxd/RxSwift/master/Lectures/07_Transforming%20Operators/6.%20dematerialize.png" width="80%" />

위의 그림과 같이 작동합니다!! `materialize`와 반대모양이죠?

`dematerialize`는 아래와 같이 적용시킬 수 있습니다.

```swift
studentScore
    // 1
    .filter {
      guard $0.error == nil else {
        print($0.error!)
        return false
      }
      
      return true
    }
    // 2
    .dematerialize()
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
```

주석을 따라 확인해보면,

1. 에러가 방출되면 프린트 할 수 있도록 `guard`문을 작성합니다.
2. `dematerialize`를 이용하여 `studentScore` observable을 원래의 모양으로 return하고, 점수와 정지 이벤트를 방출할 수 있도록 합니다.

```swift
--- Example of: materialize and dematerialize ---
80
85
anError
100
```

