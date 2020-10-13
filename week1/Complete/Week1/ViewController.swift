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
    
    lazy var tableView: UITableView = {
       let tableView = UITableView()
        
        
        return tableView
    }()
    
    lazy var button: UIButton = {
       let button = UIButton()
        
        
        
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
    
        textField.rx.text
            .filter { text in
                if text == "123" {
                    return true
                } else {
                    return false
                }
            }.subscribe(onNext: { text in
                print(text ?? "")
            }).disposed(by: disposeBag)
            
        
        button.rx.tap.subscribe { event in
            self.textField.text = ""
        } onError: { (error) in
            print(error)
        } onCompleted: {
            print("")
        } onDisposed: {
            print("")
        }.disposed(by: disposeBag)
    }
    
    func layout() {
        view.addSubview(textField)
        view.addSubview(button)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textField.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        textField.layer.cornerRadius = 5
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }

}
