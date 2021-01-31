# Intro to Schedulers



- 지금까지 scheduler에 대해 제대로 된 설명도 없이 사용하면서 동시성과 Threading 처리를 해왔을 것이라고 합니다.
  - `buffer` `delaySubscription` `interval` 의 오퍼레이터를 사용하면서..
- 오늘은 schedulers의 개념에 대해서 알아보장
- 그 전에 `observeOn` 오퍼레이터가 뭔지에 대해서 알아봐야한다!!

🚨 Custom Scheduler는 책 너머의 개념이다. scheduler와 initializer는 RxSwift에서 제공한다는 것을 기억하자!! RxCocoa, RxBlocking은 일반적으로 99%의 케이스들을 커버할 수 있다구해요.



## What is scheduler?

- 스케줄러를 이해하기 위해선 그들이 무엇을 하고 무엇을 하지 않는지 아는 것이 중요합니다.
-  a scheduler is a context where a process takes place. 라고 하는데 이 뜻을 직독직해 해보자면 프로세스가 이루어지는 문맥이다! 라고 해석이 돼요. 그럼 문맥이 무엇일까요?
- 이 context는 Thread, dispatch queue, similar entities, OperationQueueScheduler안에 있는 Operation 등이 될 수가 있다고 하네영

![img](https://assets.alexandria.raywenderlich.com/books/rxs/images/d1c8d5de71749da4bd368a6219dde9811259b64d8bfb60ab8d5d88c5dfc2d065/original.png)

위 그림이 스케줄러가 어떻게 동작되는지 알려주는 그림이라고 합니다. 네트워크 요청을 받을 때의 작동방식이네요.

네트워크 리퀘스트를 받으면 cache라는 커스텀 오퍼레이터에 의해서 데이터가 전달되어지고, 그 후, 구독자들에게 데이터를 전달되고 있습니다.이 때 구독자들은 다른 스케줄러, (MainScheduler)에 전달되고 있습니다.



## Demystifying the scheduler

- 한 가지 잘못 알고 있는 상식: scheduler는 thread와 동일한 것이다.
  - 이게 처음에 오해할 수 있을만한게 schedular는 GCD의 dispatch queue와 비슷하게 작동하니까 그렇다고 합니다.

![img](https://assets.alexandria.raywenderlich.com/books/rxs/images/a6a62a82070d23e72f740cc14ea2bd9d2adb2c8c568dae1ca90205dfa179bc10/original.png)

- 위 그림을 보면 Custom Scheduler를 만든 경우인데 하나의 Thread안에 여러개의 scheduler를 만들 수 있어요.
- 그래서 여기서 기억할 것은 scheduler != thread . one-to-one 관계는 가질 수 없습니다. 그래서 scheduler가 operation을 실행하고 있는 context가 무엇인지 체크해야합니다!!(Thread가 아니라요!!) 이따 이것을 이해할 만한 좋은 예제가 나온다구 하네요.



## Setting up the project

- 우린 앱이 아닌 command-line tool을 이용해서 실습을 해볼 예정인데 분명 shedular는 앱 작동에 관한 것인데 왜 command-line을 이용해서 실습하나요??라는 질문이 나올 수 있습니다.

- 이 이유는 thread와 동기처리를 다룰 때는 시각적으로 보여지는 것보다 command-line tool이 이해하기 훨씬 쉽기 때문이다.라고 설명하네영

- 모두 starter파일에서 pod install을 해주고 build를 해주시면 아래와 같은 코드가 나올겁니다!

  ```bash
  ===== Schedulers =====
  
  00s | [E] [dog] emitted on Main Thread
  00s | [S] [dog] received on Main Thread
  ```

- 이 코드는 기본 코드이니 먼저 이해하고 지나갈게요!

- `Utils.swift` 파일에 들어가면 `dump()` 와 `dumpingSubscription()` 메소드가 있습니다.

- 첫번째 메소드에 대한 설명은 말로하겠습니다.



## Switching schedulers

- RxSwift에서 중요한 것중 하나는 언제든 schedular를 swifch 할 수 있다는 것입니다.
  - background Scheduler에서 expensive work를 할 때
  - expensive work가 병렬이나 직력적으로 일어나는 것을 컨트롤하고 싶을 때
  - UI update를 할 때
- main.swift에 아래 코드를 적으면!

```swift
let fruit = Observable<String>.create { observer in
  observer.onNext("[apple]")
  sleep(2)
  observer.onNext("[pineapple]")
  sleep(2)
  observer.onNext("[strawberry]")
  return Disposables.create()
}


fruit
    .dump()
    .dumpingSubscription()
    .disposed(by: bag)

```

- 아래와 같이 작동해요

```bash
===== Schedulers =====

00s | [E] [dog] emitted on Main Thread
00s | [S] [dog] received on Main Thread
00s | [E] [apple] emitted on Main Thread
00s | [S] [apple] received on Main Thread
02s | [E] [pineapple] emitted on Main Thread
02s | [S] [pineapple] received on Main Thread
04s | [E] [strawberry] emitted on Main Thread
04s | [S] [strawberry] received on Main Thread
Program ended with exit code: 0
```

- 이것이 2초간격으로 과일을 방출하는 일반적인 subject입니다. 
- fruit는 main thread에서 발생하고 이것을 background thread로 이동시켜 보겠습니다. 
- fruit을 background thread에서 발생시키기 위해선 `subscribeOn` 이라는 메소드를 사용해야 해요.

## Using subscribeOn

- 왜 subscribeOn을 사용해야 할까요?
- 이건 잘 이해 못했지만 최대한 직독직해로 설명해보겠습니다..
- 우린 Observable을 만들때 `Observable.create {}` 을 통해서 만들고 어떤 것을 무조건 subscribe를 합니다. 이 때, 자동적으로 이 프로세스가 어디서 일어날지 결정하죠. 여기서 subscribeOn을 부르지 않으면 RxSwift는 MainScheduler로 자동으로 배치한다고 하네요. (그리고 MainScheduler는 Main Thread의 가장 위에 위치해있어요.)
- 이제 사용해보겠습니다.
- 맨 위에 globalSchedular가 있고 이것을 적용시켜보자

```swift
fruit
    .subscribeOn(globalScheduler) // 추가
    .dump()
    .dumpingSubscription()
    .disposed(by: bag)
```

이 한줄만 추가해주면 다음과 같이 나옵니당

```bash
===== Schedulers =====

00s | [E] [dog] emitted on Main Thread
00s | [S] [dog] received on Main Thread
00s | [E] [apple] emitted on Anonymous Thread
00s | [S] [apple] received on Anonymous Thread
02s | [E] [pineapple] emitted on Anonymous Thread
02s | [S] [pineapple] received on Anonymous Thread
04s | [E] [strawberry] emitted on Anonymous Thread
04s | [S] [strawberry] received on Anonymous Thread
Program ended with exit code: 0
```

- global queue는 이름 없는 thread를 가지고 있기 때문에 Anoymous Thread라고 나옵니다 ㅎㅎ
- Anonymous Thread는 gloabl thread중 하나이고, concurrent dispatch queue입니다.라고하는데 정확히 무슨 말인지..

![img](https://assets.alexandria.raywenderlich.com/books/rxs/images/3868c713a71c420457ad0f633c8ed54395d0adae1da31955f4e696721447e59a/original.png)

- 멋있죠? ㅎㅎ 근데 여기서 observer가 실행되는 thread를 바꾸고 싶을 땐 어떻게 해야하나요?!?!
- `observeOn` 을 사용하면 됩니다!

## Using observeOn

- Observing은 Rx의 세가지 기본적인 개념중 하나입니다. 라고 하고.. 음.. 
- 위의 subscribeOn과 완전 반대로 observeOn은 관찰하는 것의 스케줄러를 switch해줄 수 있습니다.
- 이건 바로 예시로 들어볼게요!
- 현재 global schedular에서 main으로 바꾸려면 `observeOn`을 구독하기 전에 넣어주어야합니다. 따라서 위치는 아래와 같아요.

```swift
fruit
    .subscribeOn(globalScheduler)
    .dump()
    .observeOn(MainScheduler.instance) // 요기
    .dumpingSubscription()
    .disposed(by: bag)
```

그럼 다음과 같이 나오는 것을 볼 수 있습니다!!!

```

===== Schedulers =====

00s | [E] [dog] emitted on Main Thread
00s | [S] [dog] received on Main Thread
00s | [E] [apple] emitted on Anonymous Thread
00s | [S] [apple] received on Main Thread
02s | [E] [pineapple] emitted on Anonymous Thread
02s | [S] [pineapple] received on Main Thread
04s | [E] [strawberry] emitted on Anonymous Thread
04s | [S] [strawberry] received on Main Thread
```

그림으로 보면 더 이해하기 쉬워요!

![img](https://assets.alexandria.raywenderlich.com/books/rxs/images/6b1362dbbfcb75eb24605d02562238d9ca1144e484d9136722698f3a441d09b0/original.png)

- 여기까지 정말 흔히 볼 수 있는 일반적인 패턴입니다. 서버에서 데이터를 받고 가공할 때는 background scheduler를 사용하고 마지막 데이터 처리와 데이터를 이용해 UI를 건드릴 경우엔 main으로 switch하는 방식이요! 

## Pitfalls

- 여기까진 좋았지만, 몇가지 함정들이 숨어있습니다!!
- 그 함정을 보기위해서 OS Thread를 사용해보도록 할게요.

```swift
let animalsThread = Thread() {
  sleep(3)
  animal.onNext("[cat]")
  sleep(3)
  animal.onNext("[tiger]")
  sleep(3)
  animal.onNext("[fox]")
  sleep(3)
  animal.onNext("[leopard]")
}

animalsThread.name = "Animals Thread"
animalsThread.start()
```

- animal Thread를 fruit밑에 만들고 Thread이름도 지어주고 실행시켜보도록 하겠슴다.
- 실행되는것을 확인 할 수 있습니당

```
03s | [E] [cat] emitted on Animals Thread
03s | [S] [cat] received on Animals Thread
04s | [E] [strawberry] emitted on Anonymous Thread
04s | [S] [strawberry] received on Main Thread
06s | [E] [tiger] emitted on Animals Thread
06s | [S] [tiger] received on Animals Thread
09s | [E] [fox] emitted on Animals Thread
09s | [S] [fox] received on Animals Thread
12s | [E] [leopard] emitted on Animals Thread
12s | [S] [leopard] received on Animals Thread
Program ended with exit code: 0
```

- 그럼 여기서 먼저 observeOn을 시켜볼게영

```swift
animal
  .dump()
  .observeOn(globalScheduler) // 요거
  .dumpingSubscription()
  .disposed(by: bag)
```

- 그럼 아래와 같이 나오고 네!! 정상이네요! 

```swift
...
03s | [E] [cat] emitted on Animals Thread
03s | [S] [cat] received on Anonymous Thread
04s | [E] [strawberry] emitted on Anonymous Thread
04s | [S] [strawberry] received on Main Thread
06s | [E] [tiger] emitted on Animals Thread
06s | [S] [tiger] received on Anonymous Thread
09s | [E] [fox] emitted on Animals Thread
09s | [S] [fox] received on Anonymous Thread
12s | [E] [leopard] emitted on Animals Thread
12s | [S] [leopard] received on Anonymous Thread
```

- 그럼 이제 subscribeOn을 해볼까요? 저흰 Main에 할거예요!

```
03s | [E] [cat] emitted on Animals Thread
03s | [S] [cat] received on Anonymous Thread
04s | [E] [strawberry] emitted on Anonymous Thread
04s | [S] [strawberry] received on Main Thread
06s | [E] [tiger] emitted on Animals Thread
06s | [S] [tiger] received on Anonymous Thread
09s | [E] [fox] emitted on Animals Thread
09s | [S] [fox] received on Anonymous Thread
12s | [E] [leopard] emitted on Animals Thread
12s | [S] [leopard] received on Anonymous Thread
```

- WHAT????!!?!?
- 적용이 안되고 Animal Thread에 적용이 된 것을 볼 수가 있습니다!
- 왜냐고요???
- 이것이 가장 많이 하는 기본적인 실수인데! Thinking RxSwift does some thread handling by default 라고 생각하는 것이 흔한게 함정에 빠질 수 있는 길이라고 하네요! Thread 처리는 저희가 직접 해주어야 한다고 합니다.
- 여기서 문제가 됐던 점은 animals는 Subject이기 때문입니다. Subject를 `Thread {}`를 이용해서 Thread에 event들을 직접 넣어주었지만, Subject의 특징 상,  RxSwift는 이미 계산된 원래의 scheduler를 다른 thread로 집어넣어줄 능력이 없다고 합니다.(이 부분 이해 못했어요 ㅠ) 

> What’s happening above is a misuse of the `Subject`. The original computation is happening on a specific thread, and those events are pushed in that thread using `Thread() { ... }`. Due to the nature of `Subject`, RxSwift has no ability to switch the original computation scheduler and move to another thread, since there’s no direct control over where the subject is pushed.

- 위에가 이유에 대한 원문이니까 혹시 이해되시면..... 알려주세욤
- 이러한 문제점은 흔히들 Hot and Cold observable 문제라고 합니다!!!
- 위 Subject의 misuse문제점은 hot observable문제점이라고 하는데 이건 바로 `observeOn`은 사용이 가능한데 `subscribeOn`은 사용이 불가능하다라고 간단하게 말할 수 있어요. 책에서는 뭐라구 설명하냐면 구독에 대해서는 다 할 수 있는데 그것은 오직 자신만의 context를 가지고 있고 그 context는 RxSwift가 컨트롤할 수 없다고 하네요!!
- Cold Observable문제점은 완전 반대로 `subcribeOn`은 되는데 `obserOn`은 사용 불가능하다는 문제점입니당. 이 의미는 구독하기 전엔 자신의 context를 가질 수 없다는 것을 의미하고 구독후에는 자신의 context를 가지고 실행된다고 하네요!

## Hot vs Cold

조금 더 자세히 알아볼까요? 이 그림을 보면 이해가 더 쉬울까 해서 가져와봅니다.

![img](https://assets.alexandria.raywenderlich.com/books/rxs/images/acd052787729f558ed4330b66473a5bb4925734c5aa27a124cf19382673ad847/original.png)

전 잘 모르겠어요....ㅠㅠ

위 그림에 나와 있는 side effect는 아래의 예시 경우가 있는데요

- 서버에 요청을 보낼때
- local 디비를 편집할 때
- 파일 시스템에 접근해서 글을 쓸 때
- Launch a rocket(????)



## Best practices and built-in schedulers

여기선 빠르게 동기/비동기 처리 scheduler에 대한 소개를 해줍니다.



### Serial vs Concurrent schedulers

동기 vs 비동기 스케줄러!!

음.. 그냥 전반적으로 동기가 무엇인지 비동기가 무엇인지에 대해서 설명하고 있어서 넘어가겠습니다.

알아야할 건 딱 하나인데 비동기처리를 위해 스케줄러를 사용할 때는 `observeOn` `subscribeOn`을 이용해서 구독과 관찰을 컨트롤한다고 합니다.



### MainScheduler

- Main Thread의 가장 상단에 존재
- UI 컨트롤에 사용, 가장 높은 우선순위 일 때 사용.
- Long-running task들은 여기 있으면 절대로 안된다. ***server requests or other heavy tasks X***
- RxCocoa를 사용할 땐 거의 모든 observation이 MainScheduler로 되어있음 그래서 data binding에 용이하게 되어있음



### SerialDispatchQueueScheduler

- 일련의 작업들을 추상화(?)
- 동기처리할 때 사용
- 이 scheduler는 여러개의 최적화를 하는데 적합하다(?)
- background jobs들을 동기적으로 처리하고 싶을 때 사용.
- 더 정확히 어떨 때 사용하냐면 서버 통신을 할 때 오직 하나의 end point를 사용하고 있을 때, 그래서 동시적으로 많은 요청을 보내서 한꺼번에 receiving end에 도착하게 만드는 것을 피하고 싶을 때 이 스케줄러를 사용.

### ConcurrentDispatchQueueScheduler

- 위와 같이 추상화(?)하는 건 같음
- 비동기처리할 때 사용
- 이것은 위랑 달리 모여있는 결과들을 최적화하는데 적합하다(?)
- `observeOn` 을 사용할 때는 최적화가 안되기 때문에 같이 사용 X
- 동시적으로 끝나야하는 multiple, long-running tasks를 해야할 때 사용.



### OperationQueueScheduler

- `ConcurrentDispatchQueueScheduler` 와 비슷하게 작동하지만, `DispatchQueue`에서 동작하지 않고, `OperationQueue` 위에서 동작합니다. 

> If you need to fine-tune the maximum number of concurrent jobs, this is the scheduler for the job. You can set `maxConcurrentOperationCount` to cap the number of concurrent operations to suit your application’s needs.

- 이럴 때 사용한다는데 .... OperationQueue는 사용해본적이 없어서 일단 넘어가겠습니다 ㅠ_ㅠ



### TestScheduler

- 이건 Test code를 작성할 때 사용하는 scheduler로 절대로 production code에는 쓰면 안됩니다.
- RxTest Library안에 들어있는데 이것도 아직은 절대 사용 안 할 거 같아서 임의로 넘어가겠습니다.. 괜찮나영..?!?!? 나중에 사용할 때 알아봅시닷



## Where to go from here?

Scheduler를 사용할 때 가장 중요한 규칙은 이것은 정말 무엇이든 될 수 있다!!!! 라고 합니다. 또한 Scheduler는 `DispatchQueue`, `OperationQueue`, `Thread` 등 여러가지에 위에 있을 수 있습니다. 여기엔 정말 아무 규칙도 없지만 알아둬야할 점은 어떤 스케쥴러가 어느 상황에 적합한 지 알고 사용해야 한다는 점입니다. 잘못된 스케줄러 사용은 오히려 역효과를 불러일으킬 수 있다.라고 하네영 

>  제가 생각하기로는 어디에든 사용할 수 있고 어떤 용도로도 사용할 수 있다이지만, 사용할 때 적합하게 사용하는 것은 개발자마음이라는 뜻으로 해석했어요..

