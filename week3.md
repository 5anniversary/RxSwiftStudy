Week3 Subjects 
=========

지난주에 이어서 Subject에 대해 공부해 봅시당!! 전반적으로 훑어보니 Observable에 대한 이해가 Subject를 이해하는 데에 큰 도움이 될 것 같군요

# What is Subject?


Subject 는 지난 주에 같이 공부했던 Observable과 연관지어서 생각할 수 있어요. Subject의 속성을 간단하게 정리해보자면, Subject는 Observable이 될 수도 있고 Observer가 될 수도 있어요. 
즉, Subject는 observable과 observer의 역할을 모두 할 수 있는 bridge/proxy Observable이라 생각하면 됩니다. 그렇기 때문에 Observable이나 Subject 모두 Subscribe를 할 수 있어요. 

그렇지만 Subscribe 하는 방식의 차이가 있는데요, Subject는 여러개의 Observer를 subscribe할 수 있는 multicast 방식 , 단순한 observable은 observer 하나만을 subscribe할 수 있는 unicast 방식입니다. 

사진으로 간략하게 살펴보면

// 사진 //


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

이렇게 4가지 타입의 subject가 있어요!! 간단히 살펴보았고 지금부터는 타입별로 하나씩 코드와 함께 이해해 봅시당


### Publish Subject




