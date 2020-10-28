import UIKit
import RxSwift

var str = "Hello, playground"

example(of: "just, of, from") {
  
  // 1
  let one = 1
  let two = 2
  let three = 3
  
  // 2
  let observable: Observable<Int> = Observable<Int>.just(one)
  let observable2 = Observable.of(one, two, three)
  //observable2 의 inferred type은 integer, array 값을 넣고 싶다면 observable3에서 처럼 array 로 선언하면 됨
    let observable3 = Observable.of([one, two, three])
    
    //observable을 만드는 또다른 operator 는 from !
    let observable4 = Observable.from([one, two, three])
    
    
}

example(of: "subscribe") {
  
  let one = 1
  let two = 2
  let three = 3
  
  let observable = Observable.of(one, two, three)
    
    //type 1
//    observable.subscribe { event in
//      print(event)
//    }
    
    //type2
    observable.subscribe { event in
      
      if let element = event.element {
        print(element)
      }
    }
}


public func example(of description: String,
                        action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }


//empty observable

example(of: "empty") {

  let observable = Observable<Void>.empty()
    
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
    
}

//never observable
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

// generate range of values

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

// disposable
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

//에러 발생시켜보기

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

//let sequence = 0..<3
//
//var iterator = sequence.makeIterator()
//
//while let n = iterator.next() {
//  print(n)
//}

/* Prints:
 0
 1
 2
 */
