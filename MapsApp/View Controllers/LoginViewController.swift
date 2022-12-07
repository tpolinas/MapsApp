//
//  ViewController.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import UIKit
import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    // MARK: - Private properties
    
    private var userRealm: Results<UserRealm>?
    private var usersCollection: [UserRealm] = []
    private var repeatedUsersLogins: [String] = []
    
    // MARK: - UI
    
    private(set) lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "MapApp"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private(set) lazy var loginField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your login"
        textField.borderStyle = .roundedRect
        textField.textColor = .gray
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private(set) lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.textColor = .gray
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private(set) lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.signInAction),
            for: .touchUpInside)
        button.configuration = .filled()
        
        return button
    }()
    
    private(set) lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .gray()
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.signUpAction),
            for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        configureLoginBindings()
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.addSubviews()
        self.configureConstraints()
    }
    
    private func addSubviews() {
        self.view.addSubview(loginLabel)
        self.view.addSubview(loginField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        self.view.addSubview(signUpButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            self.loginLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
            self.loginLabel.widthAnchor.constraint(equalToConstant: 111),
            self.loginLabel.heightAnchor.constraint(equalToConstant: 36),
            self.loginLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.loginField.topAnchor.constraint(equalTo: self.loginLabel.bottomAnchor, constant: 20),
            self.loginField.widthAnchor.constraint(equalToConstant: 200),
            self.loginField.heightAnchor.constraint(equalToConstant: 30),
            self.loginField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.passwordField.topAnchor.constraint(equalTo: self.loginField.bottomAnchor, constant: 5),
            self.passwordField.widthAnchor.constraint(equalToConstant: 200),
            self.passwordField.heightAnchor.constraint(equalToConstant: 30),
            self.passwordField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.signInButton.topAnchor.constraint(equalTo: self.passwordField.bottomAnchor, constant: 15),
            self.signInButton.widthAnchor.constraint(equalToConstant: 100),
            self.signInButton.heightAnchor.constraint(equalToConstant: 30),
            self.signInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.signUpButton.topAnchor.constraint(equalTo: self.signInButton.bottomAnchor, constant: 5),
            self.signUpButton.widthAnchor.constraint(equalToConstant: 100),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 30),
            self.signUpButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // MARK: - Obj-C methods
    
    @objc func signInAction() {
        self.transitionToTheNextVC()
    }
    
    @objc func signUpAction() {
        guard
            let login = self.loginField.text,
            let password = self.passwordField.text
        else { return }
        if !login.isEmpty && !password.isEmpty {
            self.saveUserToRealm(
                User(
                    login: login,
                    password: password))
        }
    }
    
    // MARK: - Private methods
    
    private func transitionToTheNextVC() {
        let nextVC = MapViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func saveUserToRealm(_ user: User) {
        let userRealm = UserRealm(user)
        self.loadUserFromRealm(user.login)
        do {
            try RealmService.saveSingleObject(items: userRealm)
        } catch {
            print("Saving to Realm has failed")
        }
    }
    
    private func loadUserFromRealm(_ userLogin: String) {
        do {
            let predicate = NSPredicate(format: "login == %@", userLogin)
            userRealm = try RealmService.load(typeOf: UserRealm.self).filter(predicate)
            guard let user = userRealm else { return }
            if !user.isEmpty {
                self.notifyOfNewPassword(userLogin)
            }
        } catch {
            print("Loading from Realm has failed")
        }
    }
    
    private func updateUserFromRealm(_ user: UserRealm) {
        do {
            try RealmService.saveSingleObject(items: user)
        } catch {
            print("UserUpdate has failed")
        }
    }
    
    private func notifyOfNewPassword(_ userLogin: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: "Such a user is already exists. Please, create a new password.",
            preferredStyle: .alert)
        let anotherAlertController = UIAlertController(
            title: "Success!",
            message: "Your password for \(userLogin) login has been changed.",
            preferredStyle: .alert)
        alertController.addTextField { text in
            text.placeholder = "Enter a new password."
        }
        let action = UIAlertAction(
            title: "Confirm",
            style: .default) { [weak self] action in
                guard let self = self else { return }
                guard
                    let textField = alertController.textFields?[0],
                    let text = textField.text
                else { return }
                let newObject = UserRealm(
                    User(
                        login: userLogin,
                        password: text))
                self.updateUserFromRealm(newObject)
                self.present(anotherAlertController, animated: true)
            }
        let anotherAction = UIAlertAction(
            title: "Cancel",
            style: .default) { action in
                self.transitionToTheNextVC()
            }
        alertController.addAction(action)
        alertController.addAction(anotherAction)
        present(alertController, animated: true)
    }
}

// MARK: - Extensions

extension LoginViewController {
    func configureLoginBindings() {
             _ = Observable
                 .combineLatest(
                     loginField.rx.text,
                     passwordField.rx.text
                 )
                 .map { login, password in
                     return !(login ?? "").isEmpty && (password ?? "").count >= 1
                 }
                 .bind { [weak signInButton] inputFilled in
                     signInButton?.isEnabled = inputFilled
                 }
         }
}

