Ch.13 Intermediate RxCocoa

1. Intro - Intermediate RxCocoa
RxCocoa의 활용을 지난시간에서 UI 컴포넌트들을 활용하며 제작했지만, RxCocoa는 UI를 위한 것 만이 아니다. 기본적으로 Apple의 공식 프레임 워크들을 '래핑'하여 사용자화하는 것이 목적이다.

2. 예제
 activity indicator 검색할동안 표시하는 기능을 추가로 구현하기
 가 오늘의 목표입니다. 
 
 참고로 지난주에 했던, 기존의  OpenWeatehrMap의 API를 사용합니다
 
 
 도시를 입력하면 우리 앱에서는 다음과 같은 로직이 이루어져야 한다. 
 원서에서는 검색 버튼을 따로 만들어서 search pressed라고 한 것 같아요
 
 (사진 참조)
 
 ViewController.swift의 viewDidLoad() 의 style() 호출 아래에 추가
 
  let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
         .map { self.searchCityName.text }
         .filter { ($0 ?? "").count > 0 }
 

viewDidLoad()의 기존의 코드를 다음과 같이 수정함.

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
 
 앱이 API 리퀘스트를 만드는 중일때 그 상태를 표시하기 위한 observable 을 만들었다. 
 
 
 * ViewControllerdp UIIndicatorView를 indicatorView라는 이름으로 추가해주어야 한다. 
 
 다음으로, 이 들을 통해 UIIndicatorView 의 isAnimating 객체에 바인딩을 하는 작업을 합니다.
 
 
 
