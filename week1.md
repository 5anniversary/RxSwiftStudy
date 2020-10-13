# Week1



## What is ReactiveX? 🧐

> 💡 _ReactiveX is a library for composing asynchronous and event-based code by using observable sequences and functional style operators, allowing for parameterized execution via schedulers._

ReactiveX는 Reactive eXtension의 줄임말입니다. 정말 말 그대로 생각해보면 반응을 확장시켜주는 역할을 한다고 생각할수있죠!

어떤 방식으로 Swift를 확장시켜주는지 알아볼까요?

## Why RxSwift? 🤔

우리의 뽀짝한 🍎Apple에서도 Cocoa Framework안에 비동기식으로 코드를 작성할 수 있도록 해주는 API를 제공하고 있어요!

그런데! 왜 ReactiveX를 Swift에서 사용할까요??

우선 무슨 API로 비동기식 코드를 작성하는지 알아볼까요??

1. Notification Center
2. The delegate pattern
3. Grand Central Dispatch(GCD)
4. Closures

이렇게 4가지의 API가 있는데요!!

<img width="421" alt="스크린샷 2020-10-11 오후 3 52 58" src="https://user-images.githubusercontent.com/22820675/95672207-d7b98300-0bd9-11eb-9366-111619e8fda6.png">

기본적으로 제공되는 API에서는 한계점이 있어요... 기본 API 대다수가 비동기적으로 작동하는 방식인데요! 이 API들이 비동기적으로 작동하면서 여러 외부 요인들(예를 들어서 사용자 입력, 네트워크 활동 혹은 OS event등...)이 작동할 때마다 코드를 작성할때 생각하던 방식과 정반대로 실행이 될수도 있어요.

> _결국에는 기본 제공되는 API로는 복잡한 코드를 작성하는데 한계가 크다는 것! 때문에 RxSwift를 사용합니다!_
>
> 자 이제 Rx는 어떻게 사용되는지 알아볼까요?



## How to RxSwift? 🖌

우선 비동기 관련 용어를 알아봐야겠죠?

1. State, and specifically, shared mutable state

   💡 상태! 특별히, 변하기 쉬운 상태

   상태는 뭐라 정의하기 힘든데요, 상태를 이해하기 위해서는 예를 들어봐야 할 것 같아요.

   1. 처음 시동한 Laptop은 ~~불량이 아닌 이상~~ 잘 작동함
   2. 하지만 시간이 지날 수록 반응이 느려지거나 반응을 멈추는 상황이 발생함. 왜 그럴까?
   3. Hardware와 Software는 그대로이지만 변한 것은 State
   4. Laptop을 재시동하거나 사용할 수록 메모리상의 데이터, 디스크에 저장된 내용을 포함한 온갖 찌꺼기?파일들은 laptop에 남게 됨. 이 것이 laptop의 state(상태)라고 할 수 있음.
   5. 쉽게 얘기하면 사용하면 사용할 수록 데이터의 교환 등등이 이루어지고 또 남는 것들이 생기면서 상태가 변화한다는 뜻

   비동기적 요소들을 관리하는데 있어 이 상태라는 용어를 기억해둬야겠어요!

   그리고, Swift에서 비슷한 개념으로 사용되는 State 구조체 [SwiftUI Document](https://developer.apple.com/documentation/swiftui/state)도 가져왔습니다. 
   스유와 함께 나온 Combine을 Apple에서 만들때 새롭게 만든 구조체인것 같은데요!!
   한번씩 읽어보면 이해하는데 도움이 될거에요!

   

2. 명령형 프로그래밍 (Imprective Programming)

   명령형 프로그래밍(Imperative programming)은 선언형 프로그래밍과 반대되는 개념으로, 프로그래밍의 상태와 상태를 변경시키는 구문의 관점에서 연산을 설명하는 프로그래밍 패러다임의 일종이에요.

   명령형 코드는 우리들이 컴퓨터를 이해하는 방식과 비슷합니다. 예를 들면 모든 CPU는 간단한 명령어로 이루어진 긴 sequence를 따릅니다~

   여기서 생기는 문제점은 사람들이 공유된 가변적인 상태들이 연관되어있는 복잡하고 비동기적인 코드를 작성하는데 애로사항이 있다는 점입니다!

   

3. Side effect

   - 부수작용이란 현재 scope 외 상태에서 일어나는 모든 변화를 뜻해요
   - 예를 들어 상기 코드에서 `connectUIControls` 라는 method는 아마 어떤 UI 구성요소를 제어하기 위한 `event handler` 일 것이에요. 이 것이 view의 state(상태)를 변경하게 된다면 부수작용을 만들게 되요.
   - 스크린 상 `label`의 `text`를 추가하거나 변경한다는 것 > 디스크에 저장된 데이터를 수정한다는 것 > 부수작용 발생한다는 것
   - 부수작용은 그 자체로 나쁜 것이 아니...에요. 컨트롤이 가능하냐는 게 중요해요
   - 각각의 코드에 대해서, 해당 코드가 어떤 부수작용을 발생시킬 수 있는 코드인지, 단순 과정을 나열한 것인지, 명확한 결과값만을 발생시키는 것인지 정확히 인지하고 있는 것이 중요해요.

   <img width="243" alt="스크린샷 2020-10-11 오후 6 45 26" src="https://user-images.githubusercontent.com/22820675/95675391-ef9d0100-0bf1-11eb-89b5-0f841ed2ff25.png">

   RxSwift는 이러한 이슈를 추적가능하게 해줘요.

   

4. 선언형 코드 (Declarative Code)

   - 명령형 프로그래밍에서의 상태 변화는 자유자재로 가능해요.
   - 함수형 코드에서는 부수작용을 일으킬 수 없어요.
   - RxSwift는 이 두 가지를 아주 잘 결합하여 동작하게 해요.
     - 명령형 프로그래밍 + 함수형 프로그래밍
     - **자유로운 상태변화 + 추적/예측가능한 결과값** 
   - 선언형 코드(명령형과 반대)를 통해 동작을 정의할 수 있으며, RxSwift는 관련 이벤트가 있을 때 마다 이러한 동작을 실행하고 작업할 수 있는 불변의 고유한 데이터 입력을 제공해요.
   - 이렇게 하면 변경 불가능한 데이터로 작업하고, 순차적이고 결과론적인 방식으로 코드를 실행할 수 있어요.

   

5. 반응형 시스템 (Reactive System)

   `반응형 시스템` 이란 의미는 상당히 추상적이며, 다음과 같은 특성의 대부분 또는 전부를 나타내는 iOS 앱을 다루게 되요.

   - 반응 (Responsive): 항상 UI를 최신 상태로 유지하며, 가장 최근의 앱 상태를 표시
   - 복원력 (Resilient): 각각의 행동들은 독립적으로 정의되며, 에러 복구를 위해 유연하게 제공
   - 탄력성 (Elastic): 코드는 다양한 작업 부하를 처리하며, 종종 lazy full 기반 데이터 수집, 이벤트 제한 및 리소스 공유와 같은 기능을 구현
   - 메시지 전달(Message driven): 구성요소는 메시지 기반 통신을 사용하여 재사용 및 고유한 기능을 개선하고, 라이프 사이클과 클래스 구현을 분리
     

#### Foundation of RxSwift

- Reactive의 역사는 스킵...🥺
- Rx code의 세 가지 building block(구성요소)인 observables(생산자), operators(연산자), schedulers(스케쥴러)가 있어요... 하나씩 알아봐요~!

1. Observables

   - `Observable<T>` 클래스는 Rx 코드의 기반

   - `T` 형태의 데이터 snapshot을 '전달' 할 수 있는 일련의 이벤트를 비동기적으로 생성하는 기능

   - 다시 말하면, 다른 클래스에서 만든 값을 시간에 따라 읽을 수 있어요

   - 하나 이상의 observers(관찰자)가 실시간으로 **어떤 이벤트**에 반응하고 **앱 UI**를 업데이트 하거나 생성하는지를 처리하고 활용할 수 있게 한다.

   - ObservableType 프로토콜(`Observable<T>`가 준수함)은 매우 간단해요. 다음 세 가지 유형의 이벤트만 `Observable`은 방출하며 따라서 observers(관찰자)는 이들 유형만 수신할 수 있어요.

     - `next`: 최신/다음 데이터를 '전달'하는 이벤트
     - `error`: `Observable`이 에러를 발생하였으며, 추가적으로 이벤트를 생성하지 않을 것임을 의미 (에러와 함께 완전종료)
     - `completed`: 성공적으로 일련의 이벤트들을 종료시키는 이벤트. 즉, `Observable`(생산자)가 성공적으로 자신의 생명주기를 완료했으며, 추가적으로 이벤트를 생성하지 않을 것임을 의미
     - 아래 그림과 같이 시간에 걸쳐서 발생하는 비동기 이벤트를 생각해봐요.

     <img width="731" alt="스크린샷 2020-10-13 오후 5 34 31" src="https://user-images.githubusercontent.com/22820675/95836410-5c430780-0d7a-11eb-8c09-0a0970ba68fb.png">

     <img width="724" alt="스크린샷 2020-10-13 오후 5 34 43" src="https://user-images.githubusercontent.com/22820675/95836430-62d17f00-0d7a-11eb-943e-1fdfe76079d2.png">

     - 상기 세 가지 유형의 Observable 이벤트는, `Observable` 또는 `Observer`의 본질에 대한 어떤 가정도 하지 않아요.
     - 따라서 델리게이트 프로토콜을 사용하거나, 클래스 통신을 위해 클로저를 삽입할 필요가 없어요.
       

     - 실상황에서 아이디어를 얻으려면 다음과 같은 두 가지의 Observable sequence(유한/무한)를 이해해야 해요.

       
       

   #### Finite observable sequences (서버 통신과 같이 한정되어 있는 경우)

   - 어떤 Observable sequence는 0, 1 또는 다른 값을 방출한 뒤, 성공적으로 또는 에러를 통해 종료돼요.

   - iOS 앱에서, 인터넷을 통해 파일을 다운로드 하는 코드를 생각해봐요.

     - i) 다운로드를 시작하고, 들어오는 데이터를 관찰
     - ii) 계속해서 파일 데이터를 받음
     - iii) 네트워크 연결이 끊어진다면, 다운로드는 멈출 것이고 연결은 에러와 함께 일시정지 될 것
     - iv) 또는, 성공적으로 모든 파일 데이터를 다운로드 할 수 있을 것
     - 이러한 흐름은 앞에서 서술한 Observable의 생명 주기와 정확히 일치한다. RxSwift 코드로 표현하면 다음과 같아요.

     ```swift
      API.download(file: "http://www...")
      	.subscribe(onNext: { data in
      		... append data to temporary file
      	},
      	onError: { error in 
      		... display error to user
      	},
      	onCompleted: {
      		... use downloaded file
      	})
     ```

     - `API.download(file:)`은 네트워크를 통해 들어오는 `Data`값을 방출하는 `Observable<Data>` 인스턴스를 리턴할 거에요.
     - `onNext` 클로저를 통해 `next` 이벤트를 받을 수 있다. 예제에서는 받은 데이터를 디스크의 `temporary file`에 저장하게 될 거에요.
     - `onError` 클로저를 통해 `error` 이벤트를 받을 수 있다. alert 메시지 같은 action을 취할 수 있을 거에요.
     - 최종적으로 `onCompleted` 클로저를 통해 `completed` 이벤트를 받을 수 있으며, 이를 통해 새로운 viewController를 push하여 다운로드 받은 파일을 표시하는 등의 엑션을 취할 수 있을 거에요.
       

   #### Infinite observable sequences (UIcomponent와 같이 끝이 없이 이어지는 경우) 

   - 자연적으로 또는 강제적으로 종료되어야 하는 파일 다운로드 같은 활동과 달리, 단순히 무한한 sequence가 있죠, 보통 UI 이벤트는 무한하게 관찰가능한 sequence에요.

   - 예를 들어, 기기의 가로/세로 모드에 따라 반응해야하는 코드를 생각해봐요.

     - i) `textField` observer를 추가.
     - ii) textField text input을 관리할 수 있는 callback method를 제공해야 한다. `textField`의 현재 text를 확인 한 뒤, 이 값에 따라 버튼이 표시되게 해주세요.
     - text input이 가능한 textField가 존재하는 한, 이러한 연속적인 text input은 자연스럽게 끝날 수 없어요.
     - 결국 이러한 시퀀스는 사실상 무한하기 때문에, 항상 최초값을 가지고 있어야 해요.
     - 사용자가 textField에 입력을 하지 않는다고 해서 이벤트가 종료된 것도 아니에요. 단지 이벤트가 발생한 적이 없을 뿐.
     - RxSwift 코드로 표현하면 다음과 같아요.

     ```swift
      textField.rx.text
      	.subscribe(onNext: { text in
      		print(text)
      		... code ...
      	})
     ```

     - ```
       textField.rx.text
       ```

       은

        

       ```
       Observable<String>
       ```

       을 통해 만든 가상의 코드.

       - 아주 쉬운 코드로, 어떻게 만들 수 있는지는 다음 Chapter에서 배울 수 있어요.

     - 이를 통해 현재 `text`(사용자의 입력)을 받을 수 있고, 받은 값을 앱의 UI에 업데이트 할 수 있어요.

     - 해당 Observable에서는 절대 발생하지 않을 이벤트이기 때문에 `onError`나 `onCompleted` parameter는 건너뛸 수 있어요.

   

2. Operators

   

   - `observableType`과 `Observable` 클래스의 구현은 보다 복잡한 논리를 구현하기 위해 함께 구성되는 비동기 작업을 추상화하는 많은 메소드가 포함되어 있어요. 이러한 메소드는 매우 독립적이고 구성가능하므로 보편적으로 Operators(연산자) 라고 불려요.

   - 이러한 Operator(연산자) 들은 주로 비동기 입력을 받아 부수작용 없이 출력만 생성하므로 퍼즐 조각과 같이 쉽게 결합할 수 있어요.

   - 예를 들어 `(5 + 6) * 10 - 2` 라는 수식을 생각해봐요

     - `*`, `()`, `+`, `-` 같은 연산자를 통해 데이터에 적용하고 결과를 가져와서 해결될 때까지 표현식을 계속 처리하게 되요.
     - 비슷한 방식으로 표현식이 최종값으로 도출 될 때까지, `Observable`이 방출한 값에 Rx 연산자를 적용하여 부수작용을 만들 수 있어요.

   - 다음은 앞서 textField에 대한 예제에 Rx 연산자를 적용시킨 코드이에요.

     ```swift
     textField.rx.text
         .filter { text in
             if text == "버튼 나와랏!" {
                 self.button.isHidden = false
                 return false
             } else if text == "버튼 없어져랏!" {
                 self.button.isHidden = true
                 return false
             } else {
                 return true
             }
         }.subscribe(onNext: { text in
             print(text ?? "")
         }).disposed(by: disposeBag)
     ```


   - 값을 생성할 때 마다, Rx는 각각의 연산자를 데이터의 형태로 방출해요.
     - 먼저 `filter` 는 `버튼나와랏!, 버튼 없어져랏!` 이 아닌 값만을 내놓을거에요. 만약 textField가 해당 텍스트와 다른 상태라면 나머지 코드는 진행되지 않을 거에요. 왜냐하면 `filter`가 해당 이벤트의 실행을 막을 것이기 때문에 말이죠.
     - 만약 이외의 값이 들어온다면, `map` 연산자는 해당 방향값을 택할 것이며 이것을 `String` 출력으로 변환할 거에요. 
     - 마지막으로, `subscribe`를 통해 결과로 `next` 이벤트를 구현하게 되는데요, 이번에는 `String` 값을 전달하고, 해당 텍스트로 print하는 method를 호출해요.
   - 연산자들은 언제나 입력된 데이터를 통해 결과값을 출력하므로, 단일 연산자가 독자적으로 할 수 있는 것보다 쉽게 연결 가능하며 훨씬 많은 것을 달성할 수 있어요.

   

   

3. Schedulers

   - 스케줄러는 Rx에서 dispatch queue와 동일한 것. 다만 훨씬 강력하고 쓰기 쉽다는데...😥
   - RxSwift에는 여러가지의 스케줄러가 이미 정의되어 있으며, 99%의 상황에서 사용가능하므로 아마 개발자가 자신만의 스케줄러를 생성할 일은 없을 것이라네요?
   - 이 책의 초기 반 정도에서 다룰 대부분의 예제는 아주 간단하고 일반적인 상황으로, 보통 데이터를 관찰하고 UI를 업데이트 하는 것이 대부분이다. 따라서 기초를 완전히 닦기 전까지 스케줄러를 공부할 필요는 없다고 하네요!!
   - (다만, 맛보기로..) 기존까지 GCD를 통해서 일련의 코드를 작성했다면 스케줄러를 통한 RxSwift는 다음과 같이 돌아간다고 하네요...

   <img width="835" alt="스크린샷 2020-10-13 오후 5 35 33" src="https://user-images.githubusercontent.com/22820675/95836531-81d01100-0d7a-11eb-9b27-272de2f6e881.png">

   - 각 색깔로 표시된 일들은 다음과 같이 각각 스케줄(1, 2, 3...)된다.
     - `network subscription`(파랑)은 (1)로 표시된 `Custom NSOperation Scheduler`에서 구동된다.
     - 여기서 출력된 데이터는 다음 블록인 `Background Concurrent Scheduler`의 (2)로 가게 된다.
     - 최종적으로, 네트워크 코드의 마지막 (3)은 `Main Thread Serial Scheduler`로 가서 UI를 새로운 데이터로 업데이트 하게 된다.

- 지금 스케줄러가 편리하고 흥미로워 보이더라도 너무 많은 스케줄러를 사용할 필요는 없어요. 일단 기초부터 닦고 후반부에 깊이 들어가보죠.

## 

### App Architecture

- RxSwift는 기존의 앱 아키텍처에 영향을 주지 않아요. 주로 이벤트나 비동기 데이터 시퀀스 등을 주로 처리하기 때문이에요.
- 따라서 Apple 문서에서 언급된 MVC 아키텍처에 Rx를 도입할 수 있어요. 물론 MVP, MVVM 같은 아키텍처를 선호한다면 역시 가능해요.
- Reactive 앱을 만들기 위해 처음부터 프로젝트를 시작할 필요도 없어요. 기존 프로젝트를 부분적으로 리팩토링하거나 단순히 앱에 새로운 기능을 추가할 때도 사용가능해요.
- Microsoft의 MVVM 아키텍쳐는 데이터 바인딩을 제공하는 플랫폼에서 이벤트 기반 소프트웨어용으로 개발되었기 때문에, 당연히 RxSwift와 MVVM는 같이 쓸 때 아주 멋지게 작동해요.
  - ViewModel을 사용하면 `Observable<T>` 속성을 노출할 수 있으며 ViewController의 UIKit에 직접 바인딩이 가능해요.
  - 이렇게 하면 모델 데이터를 UI에 바인딩하고 표현하고 코드를 작성하는 것이 매우 간단해져요.
- 이 책에서는 MVC 패턴을 사용한다...😑
- 다음은 MVVM 아키텍처

<img width="700" alt="스크린샷 2020-10-13 오후 5 35 53" src="https://user-images.githubusercontent.com/22820675/95836562-8d233c80-0d7a-11eb-9cbf-c2e4075fd1e5.png">



### RxCocoa

- RxCocoa는 RxSwift의 동반 라이브러리로, UIKit과 Cocoa 프레임워크 기반 개발을 지원하는 모든 클래스를 보유하고 있어요

  - RxSwift는 일반적인 Rx API라서, Cocoa나 특정 UIKit 클래스에 대한 아무런 정보가 없어요~

- 예를들어, RxCocoa를 이용하여 `UISwitch`의 상태를 확인하는 것은 다음과 같이 매우 쉬워요~

  ```swift
   toggleSwitch.rx.isOn
   	.subscribe(onNext: { enabled in
   		print( enabled ? "It's ON" : "it's OFF")
   	})
  ```

  - RxCocoa는 `rx.isOn`과 같은 프로퍼티를 `UISwitch` 클래스에 추가해주며, 이를 통해 이벤트 시퀀스를 확인할 수 있어요~

- RxCocoa는 `UITextField`, `URLSession`, `UIViewController` 등에 `rx`를 추가하여 사용해요~

<img width="806" alt="스크린샷 2020-10-13 오후 5 37 00" src="https://user-images.githubusercontent.com/22820675/95836685-b512a000-0d7a-11eb-9fff-146f4e47206b.png">

