# welcome to RxCocoa!  
> 시작한지 정말 오래되었는데..!  
> 아직 뭔가 개념만 본 느낌이죠 여러분...  
> 하지만! 이번 RxCocoa 세션에서는 정말로 뭔가를.. 적용해보는 느낌으루다가~~ 할 예정입니다! 
> 다들 buckle up!  

# RxCocoa?  
책에서는 단순히, `part of the original RxSwift repository` 라고 소개한다.  

RxCocoa는 모든 플랫폼에서 작동을 하는데, 심지어! Apple Tv,에서도... 작동한다구 한당 ( 물론 기본적으로 iOS, macOS 에서도 작동함. )  


# 오늘의 프로젝트!   
`Wundercast` 라는 앱을 구현해 볼 것인뎅..!!  
OpenWeatherMap http://openweathermap.org 에서 제공하는 정보를 가져와주는! 어플이다.  
따라서 `SwiftyJSON`을 Rxcocoa 와 함께 import 해서 OpenWeatherMap API와 통신을 하는 앱이다.  

# 먼저 Starter.  
starter 파일에 있는 것을 일단 시작해보자!!  
다들 눈치를 챘겠지만! `RxCocoa` 를 pod install 하여 사용하여야한다~~  
( 벗어날 수 없눈 pod 의 세계... )  

```swift
 `pod 'RxCocoa', '~> 3.0'`. 
``` 

** RxCocoa는 Rxswift 와 함께 응애하고 태어났기 때문에 둘다 `같은 release scehdule`을 가지고 있게 되고, 따라서 가장 최근 버전의 RxSwift release는 RxCocoa와 같은 버전을 가지게 된다!  

이 프로젝트에서는 `UITextField`, 그리고 `UILabel` 에 대한 두개의 `wrappers` 를 사용하기 때문에 이 두 파일이 어떻게 돌아가는지 이해하는게 중요하다!  

여기서 잠깐.. what the fuck  is `wrapper`..  

# wrapper  
> 나눈 초보.. 난 잘몰라성 찾아보아따..!!!  

wrapper는 말그대로 `감싼다`는 것인데,  
예를들어 `PropertyWrapper` 같은 경우는 `Annotation` 을 활용해 wrap 을 하여 사용하는 것이다.  

그리고! 감싼 그 Annotation으로 감싸고 있는 데이터들을 해당 Annotation class 에서 따로 처리하게 된다.  

더 자세한 내용은~ 
https://medium.com/harrythegreat/swift-properywrapper%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EA%B0%92%EC%B2%98%EB%A6%AC-a8ef0d87e8e


# 다시 돌아와서.. UITextField!  

![image](https://user-images.githubusercontent.com/37579661/102689409-371eb980-4241-11eb-8973-10f515e91f3b.png)

UITextField 를 잘 보면, `ControlProperty` 라는 것이 있다.  
나중에 더 배우게 될 것이지만,  
이것은 특별한? 종류의 `Subject` 이고, `subscribe` 되어질 수 있는!! 것이며 새로운 값들이 주입될 수 있는 것이다!!  

그리고 `name of the property`는, `무엇`이 observe 될 수 있는지에 대해 알려준다!  


따라서 사진과 같이  
![image](https://user-images.githubusercontent.com/37579661/102689493-e196dc80-4241-11eb-9e94-dce54f5d30e1.png)

 `text` 라고 되어있다면 이 proprety는 직접적으로 UITextField 안에 있는 text에 연관이 되어있음을 알 수 있다.  


# UILabel + Rx  

UILabel파일을 보게되면,  
두개의 새로운 property를 볼 수 있다~~  
1. text  
2. attributedText  

이전에도 설명했듯이! (책에서 이전에 설명했다 하는데 대체 어디서 한지 모르겟음 ㄹㅇ 머야 ㅎ^^)  
두 name(text, attributedText)는 모두 original `UILabel` 에 연관이 되어지고,  
그리고 이 두 이름 사이에 name conflict 는 없을것이며!  
또한 이 두개의 `목적` 은 명백하다!  

그리고 둘다 `UIBindingObserver` 을 통해 사용된다.  
`ControlProperty` 와 비슷하게 굉장히 특별한.. 것이고 그리고 UI 와 티키타카를 하는데 기여한다!  
결국 `UIBindingObserver` 는 UI 를 그 속의 logic 과 묶어주기 위해 사용한다. 그리고 더 나아가 error는 같이 묶어주지 못한다 ㅠㅠ  

그래서 만약에 error 가 `UIBindingObserver` 으로 들어가게 되면??? 그냥 `fatalError()` 가 호출된다~~ 물론 error log에 추가 된댱.  


# binder  
binder 에 대해서 제대로 같이 이해해보고자 한다.  
근데 일단 rxcocoa책 을 다 읽고 시간이 된다면 설명을 추가해보겠당...  
시간이 안되면.....  
구냥 아라서 이거 봐방...ㅎ  
https://iospanda.tistory.com/entry/RxSwift-10-RxCocoa-1

</br>

# Let's BEGIN BUILDING THIS THANG!  

일단 짜증나지만 ( 분명 이 책에서 이 사이트에서 돈을 받은게 분명해! )  

https://home.openweathermap.org/users/sign_up.

여기서 회원가입을 한 후에  

 https://home.openweathermap.org/api_keys
 
여기서 API Key 를 받는당!!  

![image](https://user-images.githubusercontent.com/37579661/102690042-13aa3d80-4246-11eb-8a60-110105f53360.png)

여기서 자기 아무거나 하고 싶은 이름으로 key를 새로 만든당  

밍똥이는 MinseungKey > <   


![image](https://user-images.githubusercontent.com/37579661/102690104-6d126c80-4246-11eb-99c3-af645025c5bc.png)

그 다음에 cmd+shift+o 를 통해 전체에서 검색을 해봐가지궁  
`APIController.swift`  찾아서 거기에 이렇게 자기 key 주소를 넣어준당  

![image](https://user-images.githubusercontent.com/37579661/102690126-90d5b280-4246-11eb-9c10-e4329ab2285f.png)


그리고 `APIController.swift` 에서 

```swift
  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  private let apiKey = "d858bf0c732a0d4340d7f0c840840149"

``` 
이 부분에 자기 key 를 넣어준다~  
저렇게 넣어주는게 맞나 싶당...  
맞는지는 한번 해보면서 확인을 해보쟝,,,  

그리고 여기에는 JSON data structure  에 매핑이 될 data model struct 인!! `Weather` 도 있다는 것에 유의하자~  

![image](https://user-images.githubusercontent.com/37579661/102690377-54a35180-4248-11eb-91d5-537d70044758.png)


그리고 그 아래에 `currentWeather` 에는 아무런 값이 안들어갔을 때 기본으로 보여줄 dummy data 가 설정되어있다!  

![image](https://user-images.githubusercontent.com/37579661/102690498-26724180-4249-11eb-9de7-f292b56bc7c7.png)


위의 코드를 통해 "RxCity" 라는 가짜 도시 이름이 보여지게 되는데.. city 라고 넣었는데 왜 갑자기 Rx 가 자동으로 붙는걸까..?  
그거는 위에 binder 에 나와있던 블로그를 보면 'name spacing' 이 자동으로 추가되는 거에 대해서 알려주는데,  
아마.. 그것 때문에 자동으로 붙는 것 같다...????  

아는 사람은 풋쳐핸즈업..  


아무튼~  
이런 dummy data 가 있으면 우리 앱의 개발 과정을 간단히 만들어주는데 도와주고, 그리고!!  
직접 actual data 구조로 개발을 하는데 문제가 없이 돌아가게 해준당 (인터넷이 연결안되어 있어도 개발할 수 있게 도와줌. )  


# 이 프로젝트는 one single view!  

그냥 간단히 `ApiController` 를 `viewController` 에 추가해주는 **uni-directional data flow** 구조이다!!  

observable 은  
1. data 를 받을 수 있는 entity  
2. 모든 subscriber가 어떤 데이터가 들어왔음을 알도록 해준다  
3. value들이 실행되도록 push 해준다  

라는 것을 앞서 공부를 했고, 이 이유 때문에 observable 을 subscribe 하기에 **올바른 장소** 는...??!?!?!?   
</br>
<h3 align="center"> 여러분 어디일까요!!!</h3>
</br>  


# Subscribe 를 해야하는 장소  
바로.. ViewController 에서 `viewDidLoad` 입니당...!!  

그 이유는,  
최대한! subscribe 는 최대한 빨리 필요하고,  
근데 view 는 로드가 된 이후에 필요하기 때문에 viewDidLoad에서 subscribe 를 해야하는 것이당~~  

**그러면 subscribe 를 이후에 늦게 해버리게 되면... 오또케 될까용?**  

이런 경우에는 
- event 를 놓치게 되거나  
- UI의 일부분을 놓치게 되거나 
- 그 event, UI에 `bind` 되기 전에 뷰에 떠오르게 된당...  

그러니까!!  
**앱이 만들어지기 전, 그리고 데이터를 요청하기 전에!**  
모든 subscriptions 를 생성해야하는 것이다~~~ 

실전에서는 그래서 ViewController 의 ViewDidLoad 에 아래의 코드를 추가해준다!  

![image](https://user-images.githubusercontent.com/37579661/102690867-be712a80-424b-11eb-9be6-a88b603807f6.png)


근뎅.. 에러가 뚠당..  

# compiler error  
```swift
Result of call to 'subscribe(onNext:onError:onCompleted:onDisposed:)' is unused 
```

흠냐  
먼 개소링  

이라고 생각하지말고 책을 보자 ^^  

본래 subscription 이라는 것은 `disposable object` 를 반환해야하는데, 이 객체는 필요할 때 subscription을 취소해준다.  

그리고 이 앱의 경우에는!! view controller가 dismiss 되면 바로 구독(subscription)이 취소되어야 한다!!  
그렇게 하기 위해서는~~  
view controller class 에 아래 코드를 추가해줘야 한다.  

```swift 
let bag = DisposeBag()
```

그리고 위에서 추가한 ApiController.shared.currentWeather 에서 `.disposed(by:bag)` 를 마지막에 추가해주어야한당~~  

이렇게 해주면 다들 이제 좀 알다시피?!  
view controller 가 release 될 때 마다 자동으로 구독이 취소/dispose 될 것이고  
따라서 resource 낭비를 줄여주고 구독이 dispose 되지 않았을 때 생길 수 있는 갑작스러운 event나 또 다른 부작용들을 막아준다! 



------------
여기까지 했으면 이제 원래 생겼던 노랑색 에러는 뜨지 않는다!  
에러 해결 띠~  

# Textfield 연결  
rxCocoa 는 **protocol extensions** 을 활용하고, 그리고 `rx` space(naming space) 를 UIKit 컴포넌트에 추가하여 사용하게 된다!!  
즉, 이제 우리는~~  
```swift
searchCityName.rx. 
``` 

이런식으로 타이핑을 해서 이 속에서 쓸 수 있는 property 와 method 들을 보고, 사용 할 수 있는 것이다!!  


![image](https://user-images.githubusercontent.com/37579661/102691355-312fd500-424f-11eb-8995-a63a9353bdb6.png)

다들... 이제 보이시나요??  
저희가 앞에서 이해하고 보았떤! `text: ControlProperty<String?>` 을 이렇게 name spacing 을 통해 view controller 에서 textfield 에 지정해줄 수 있답니당~~  
이게 바로!!! rxCocoa.  

다시 정리하자면,  
`ControlProperty<String?>` 요 녀석은 `ObservableType` 과 `ObserverType`  둘 다에게 순응 하기 때문에!!  
우리는 요녀석을 구독! 할 수 있고, 또 새로운 값을 emit(방출) 할 수도 있습니당  
물론 이 field text 셋팅도 해줄 수 있쬬  

그럼 이제 text field 셋팅을 해주자면~  

```swift
// viewcontroller 에서 currentWeather 아래에 추가해준다 

searchCityName.rx.text
      .filter { !($0 ?? "").isEmpty}
      .flatMap { text in
        return ApiController.shared.currentWeather(city: text ?? "Error")
          .catchErrorJustReturn(ApiController.Weather.empty)
      }
```

이 부분은 단순히 새로운 observable을 데이타와 함께 뷰에 띄워주는 부분이다.  
`currentWeather` 를 띄워줄건데, **필터링** 을 거치게 해주는 것이다!  
nil 이거나 빈 값이면 필터해주고, 그리고 weather data 의 경우에는 `APIController class` 를 통해 가져와준다.  

그리고 거기에 덧붙여서!  

이 `searchCityName.rx.text` 자체에 대해 MainScheduler 에서 관찰할 것이며, 구독하겠다 라는 것을 아래의 코드를 붙여줌으로써 알려준다.  

```swift
.observeOn(MainScheduler.instance)
        .subscribe(onNext: { data in
          self.tempLabel.text = "\(data.temperature)° C"
          self.iconLabel.text = data.icon
          self.humidityLabel.text = "\(data.humidity)%"
          self.cityNameLabel.text = data.cityName
        })
        .disposed(by:bag)
```
그래서~~   
이렇게 되면 결과적으로 이런 플로우가 그려진다!  

![image](https://user-images.githubusercontent.com/37579661/102691606-08104400-4251-11eb-93e1-e8d79e725591.png)


요로케!  

그래서 이제는 인풋값에 변화가 생기면, 
라벨이 그 해당 도시의 이름에 따라 데이터를 자동으로 업데이트 시켜줄 것이고,  
근데 아직은 APIcontroller 를 제대로 연결하지 않아서 아직 dummy data 를 보여주게 된당.   

**최종 viewDidLoad() 의 모습**  

![image](https://user-images.githubusercontent.com/37579661/102693152-d5b81400-425b-11eb-9185-da6c2a902f7c.png)


## catchErroJustReturn operator 는 또 머야  
이것은!! 바로 API 에서 에러가 들어왔을 때 observable 이 dispose 되어버리는 현상을 막기 위해서 보조장치로 설치해놓는 것이당.  

예를 들어 내가 도시 이름에 "앙밍승이가사는도시" 이런식으로 졸라 이상한 데이터를 넣게되면?  
당연히 API 측에서는 응 너 존나 이상해  
라고 말하면서 404 에러를 뱉어내게 된당...  
이렇게 되었을 때 앱이 다운되어버리면 에바띠....  
따라서 404 에러가 왔을 때에는 그냥 **empty value** 가 리턴되도록 처리해놓는 것이 바로 이것이당.  


# OpenWeather API 에서 데이터 받긔  
일단 인터넷 연결 확인하긔 ㅋ  

그리고 들어오는 JSON 데이터 형식은 다음과 같당  

1. current weather 관련 데이터  

```json
{
  "weather": [
    {
      "id": 741,
      "main": "Fog",
      "description": "fog",
      "icon": "50d"
    }
  ],
}
```

2. teamperature, humidity data 관련 데이터

```json
 "main": {
    "temp": 271.55,
    "pressure": 1043,
    "humidity": 96,
    "temp_min": 268.15,
    "temp_max": 273.15
  }
}
```

이제 이렇게 들어오는 JSON 데이터를 직접 우리 ViewController 에서 처리해줘야한다.  

현재 우리의 VC 에서는 어떻게 처리하고 있는가?  

바로 위에서 그냥 테스트 겸으로 넣었던 dummy code 로 이루어져있다.  

이제는 직접 API 에서 들어오는 JSON 데이터를 처리해주는 식으로 코드를 바꿔보자!  

```swift
func currentWeather(city: String) -> Observable<Weather> {
  return buildRequest(pathComponent: "weather", params: [("q", city)])
  .map { json in
    return Weather(
      cityName: json["name"].string ?? "Unknown",
      temperature: json["main"]["temp"].int ?? -1000,
      humidity: json["main"]["humidity"].int  ?? 0,
      icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e")
    )
  }
}
```

이렇게 되면 JSON 객체를 요청으로 반환해주고, 그리고 `Weather` 데이터 구조로 fallback value 와 함께 변환되게 된다.  

이제! 모든 준비가 되었다. 

# result 

![simulator_screenshot_96F13A54-20B0-4F91-B835-55A927F4E3CD](https://user-images.githubusercontent.com/37579661/102692983-a81e9b00-425a-11eb-9064-c526f006118d.png)
!
reenshot_A0A2A570-8B86-48E4-B7CE-8518D540C853](https://user-images.githubusercontent.com/37579661/102692990-aead1280-425a-11eb-8591-4dbd27e4aa31.png)

