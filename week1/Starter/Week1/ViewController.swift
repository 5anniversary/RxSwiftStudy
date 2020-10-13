//
//  ViewController.swift
//  Week1
//
//  Created by 오준현 on 2020/10/11.
//

import UIKit

import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "채워주세요"
        
        return textField
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
}
