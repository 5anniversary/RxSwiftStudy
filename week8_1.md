# Ch.13 Intermediate RxCocoa

활용도가 많은 RxCocoa 두번째 시간이 돌아왔습니당~~ 지난시간의 예제 Wundercast를 활용합니다. 사실 오늘 발표내용보다 더 많은 내용이 있으니 책을 참고하여 더 공부하면 좋겠습니다.

## 1. Intro - Intermediate RxCocoa


RxCocoa의 활용을 지난시간에서 UI 컴포넌트들을 활용하며 제작했지만, RxCocoa는 UI를 위한 것 만이 아니다. 기본적으로 Apple의 공식 프레임 워크들을 '래핑'하여 사용자화하는 것이 목적이다.
핫한 MVVM 패턴은 챕터 23을 참고하면 좋을 것 같습니다.

## 2. 예제(1)

 * activity indicator 검색할동안 표시하는 기능을 추가로 구현하기

 
 참고로 지난주에 했던, 기존의  OpenWeatehrMap의 API를 사용합니다
 
 
 도시를 입력하면 다음과 같은 로직이 이루어져야 합니다.
 

 <img width="601" alt="스크린샷 2020-12-27 오전 10 22 00" src="https://user-images.githubusercontent.com/41604678/103163110-fb858000-483c-11eb-8f72-a7697dccfa13.png">

 원서에서는 검색 버튼을 따로 만들어서 search pressed라고 한 것 같아요
 
 
 
 ViewController.swift의 viewDidLoad() 의 style() 호출 아래에 추가
 
 ```Swift
  let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
         .map { self.searchCityName.text }
         .filter { ($0 ?? "").count > 0 }
 
```

viewDidLoad()의 기존의 코드를 다음과 같이 수정함.
```Swift
   searchCityName.rx.text
         .filter { !($0 ?? "").isEmpty}
         .flatMap { text in
            return ApiController.shared.currentWeather(city: "RxSwift")
             .catchErrorJustReturn(ApiController.Weather.empty) // empty value 처리
         }.observeOn(MainScheduler.instance)
       .subscribe(onNext: { data in
         self.tempLabel.text = "\(data.temperature)° C"
         self.iconLabel.text = data.icon
         self.humidityLabel.text = "\(data.humidity)%"
         self.cityNameLabel.text = data.cityName
       }).disposed(by:bag)


 style()
 ```
 
 앱이 API 리퀘스트를 만드는 중일때 그 상태를 표시하기 위한 observable 을 만들었어요. 
 
 
 * 당연한거지만.. ViewControllerdp UIIndicatorView를 indicatorView라는 이름으로 추가해주어야 합니다
 보통 원서에서는 이런걸 다 생략하더라구요 
 
 다음으로, 이 들을 통해 UIIndicatorView 의 isAnimating 객체에 바인딩을 하는 작업을 합니다.
 
 ```Swift
 let running = Observable.from([
         searchInput.map { _ in true },
         search.map { _ in false }.asObservable()
         ])
         .merge()
         .startWith(true)
         .asDriver(onErrorJustReturn: false)
  ```
 
 .asObservable() 호출은 타입추론을 위해 필요하고 이것 이후에 두 개의 observable을 합칠 수 있다.
 .startWith(ture)는 앱이 시작할 때 모든 label을 수동적으로 숨길 필요가 없게 해주는 아주아주 편리한 기능을 한다!!
 
 <img width="625" alt="스크린샷 2020-12-27 오전 11 54 18" src="https://user-images.githubusercontent.com/41604678/103163113-0c35f600-483d-11eb-94fe-ee8aa7015a1f.png">

 
 
 ```Swift
 
 running
 	.skip(1)
 	.drive(activityIndicator.rx.isAnimating)
 	.disposed(by.bag)
 
 ```
 
 
  ```Swift
  
  running
         .drive(tempLabel.rx.isHidden)
         .disposed(by: bag)

     running
         .drive(humidityLabel.rx.isHidden)
         .disposed(by: bag)

     running
         .drive(iconLabel.rx.isHidden)
         .disposed(by: bag)

     running
         .drive(cityNameLabel.rx.isHidden)
         .disposed(by: bag)
   
 ```
 
 
 ## 예제 (2) CLLocationManager 확장을 통해 현재 위치 확인하기
 
 
 1. extension 
 
예제 2를 구현하기 위해서는 우선 CoreLocation 프레임워크를 래핑해야합니다!!

이걸 확인하기 이전에, RxCocoa의 내부를 들여다 볼겁니다

1) Pod project에서 Reactive.swift 에서 Reactive<Base> 라는 구조체가 있고, 여기서

```Swift

extension NSObject: ReactiveCompatible { }

```
이런게 있죠!! 
이건 ```NSObject``` 를 상속하는 클래스가 rx를 받는 방법인데요 따라서 우리는 rx를 이용해서 다른 클래스가 우리가 확장한 LocationManager 를 이용할 수 있게 사용할 수 있습니다.
신기신기


2) RxCocoa 폴더에서 ```_RxDelegateProxy.h```  ```_RxDelegateProxy.m```가 있는데, 이들은 swift에서 각각 ```DelegateProxy.swift``` ```DelegateProxyType.swift``` 에 해당한다고 할수 있어요. delegate 를 사용하는 모든 프레임워크와 RxSwift를 연결해주는 기능을 구현해 둔 파일들입니다.

```Swift
 // 1
 extension CLLocationManager: HasDelegate {
     public typealias Delegate = CLLocationManagerDelegate
 }

 class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {

     // 2
     public weak private(set) var locationManager: CLLocationManager?

     public init(locationManager: ParentObject) {
         self.locationManager = locationManager
         super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
     }

     static func registerKnowImplementations() {
         self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
     }
 }

 // 3
 extension Reactive where Base: CLLocationManager {
     public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
         return RxCLLocationManagerDelegateProxy.proxy(for: base)
     }

     // 4
     var didUpdateLocations: Observable<[CLLocation]> {
         return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))).map { parameters in
                 return parameters[1] as! [CLLocation]
         }
     }
 }
 ```
 
 
 
 APIController.swft에 다음 함수를 추가해주세요 
 
 
  ```Swift
     func currentWeather(lat: Double, lon: Double) -> Observable<Weather> {
        return buildRequest(pathComponent: "weather", params: [("lat", "\(lat)"), ("lon", "\(lon)")]).map() { json in
            return Weather(
                cityName: json["name"].string ?? "Unknown",
                temperature: json["main"]["temp"].int ?? -1000,
                humidity: json["main"]["humidity"].int  ?? 0,
                icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
                lat: json["coord"]["lat"].double ?? 0,
                lon: json["coord"]["lon"].double ?? 0
            )
        }
    ```
