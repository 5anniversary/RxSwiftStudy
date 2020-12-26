/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class RxCLLocationManagerDelegateProxy : DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {

  public init(locationManager: CLLocationManager) {
    super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
  }

  static func registerKnownImplementations() {
    self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
  }

  static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
    let locationManager: CLLocationManager = object
    return locationManager.delegate
  }

  static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
    let locationManager: CLLocationManager = object
    locationManager.delegate = delegate
  }
}

extension Reactive where Base: CLLocationManager {

  public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base)
  }

  var didUpdateLocations: Observable<[CLLocation]> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
      .map { a in
        return a[1] as! [CLLocation]
    }
  }

}
