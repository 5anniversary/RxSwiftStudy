Week3  What is Subject?
=========

지난주에 이어서 Subject에 대해 공부해 봅시당!! 전반적으로 훑어보니 Observable에 대한 이해가 Subject를 이해하는 데에 큰 도움이 될 것 같군요


Subject 는 지난 주에 같이 공부했던 Observable과 연관지어서 생각할 수 있어요. Subject의 속성을 간단하게 정리해보자면, Subject는 Observable이 될 수도 있고 Observer가 될 수도 있어요. 
즉, Subject는 observable과 observer의 역할을 모두 할 수 있는 bridge/proxy Observable이라 생각하면 됩니다. 그렇기 때문에 Observable이나 Subject 모두 Subscribe를 할 수 있어요. 


그렇지만 Subscribe 하는 방식의 차이가 있는데요, Subject는 여러개의 Observer를 subscribe할 수 있는 multicast 방식 , 단순한 observable은 observer 하나만을 subscribe할 수 있는 unicast 방식입니다. 

사진으로 간략하게 살펴보면

![626152392 38](https://user-images.githubusercontent.com/41604678/98065129-3ac7ce00-1e97-11eb-9e54-84c417bf9e09.png)



차이가 확연히 보이시나요? 

Subject에는 종류가 4가지가 있습니다. 

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


### Publish Subject

RxSwift를 설치한 파일에 Playgrond 파일을 추가해서 열어주세요~


###  Behavior Subject


### Replay Subject
저는 공부하면서 이 Replay Subject가 가장 인상깊었어요. 특히 그림이랑 같이 이해하려고 하는게 중요했던 것 같아요 

바로 코드에 대해 이해가 가시나요 ?????

여기서 책은 한줄 더 추가해보라고 시킵니다 ㅎㅎ



### Variable

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





