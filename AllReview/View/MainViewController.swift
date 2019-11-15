//
//  MainViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/29.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxWebKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: MainViewModel!
    private var router: MainRouter!
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    private var webViewList: Array<WKWebView>!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIStackView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var mainViewButton: UIButton!
    @IBOutlet var rankViewButton: UIButton!
    @IBOutlet var tempViewButton: UIButton!
    @IBOutlet var myViewButton: UIButton!
    
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            viewModel = MainViewModel()
            router = MainRouter(navigation: navigationController)
            
            if(UIDevice.modelName == "Simulator iPhone 8") {
                print("HERE")
                bottomViewHeightConstraint.constant = 70
                bottomView.updateConstraints()
                //            print(bottomView.constraints)
            }
            
            if(UIDevice.modelName == "iPhone 11 Pro") {
                print("HERE")
                headerViewHeightConstraint.constant = 90
                bottomView.updateConstraints()
                //            print(bottomView.constraints)
            }
            
            webViewAddWebContainer()
            buttonTapBind();
            initWebView();
            
            //            navigationController.setNavigationBarHidden(true, animated: false)
        }
        else {
            print("View Load Fail")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        let webRankViewWebConfigure = WKWebViewConfiguration()
        let webMyViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.bottomView.bounds.height-self.headerView.bounds.height)
        webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        webRankView = WKWebView(frame: cgRect, configuration: webRankViewWebConfigure)
        webMyView = WKWebView(frame: cgRect, configuration: webMyViewWebConfigure)
        
        webViewList = [webMyView,webRankView,webMainView]
        
        self.webMainView.uiDelegate = self.viewModel
        self.webMainView.navigationDelegate = self.viewModel
        self.webRankView.uiDelegate = self.viewModel
        self.webMyView.uiDelegate = self.viewModel
        
        for item in self.webViewList {
            self.webContainer.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = true
            item.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
            item.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
            item.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
            item.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        }
    }
    
    private func buttonTapBind() {
        
        mainViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMainView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMainView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        rankViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webRankView)
        }.subscribe(onNext: { [weak self] item in
            self?.webRankView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webMainView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        myViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMyView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMyView.isHidden = item[0];
            self?.webMainView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
    }
    
    private func buttonflatMap(webView: WKWebView) -> Observable<[Bool]> {
        return Observable.create { (obs) -> Disposable in
            if (!webView.isHidden) {
                obs.on(.next([webView.isHidden, !webView.isHidden]))
            } else {
                obs.on(.next([!webView.isHidden, webView.isHidden]))
            }
            return Disposables.create()
        }
    }
    
    private func initWebView() {
        
        self.viewModel.loginDataBindFirstPage(.mainMainView, self.viewModel.mainViewButtonTapped)
        self.viewModel.loginDataBindFirstPage(.mainRankView, self.viewModel.rankViewButtonTapped)
        self.viewModel.loginDataBindFirstPage(.mainMyView, self.viewModel.myViewButtonTapped)
        
        viewModel.mainViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webMainView.load(request)
        }).disposed(by: disposeBag)
        viewModel.rankViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webRankView.load(request)
        }).disposed(by: disposeBag)
        viewModel.myViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webMyView.load(request)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func addNewReviewButtonTapped(_ sender: Any) {
        self.router.viewPresent("", ["":""])
    }
    
    @IBAction func openSearchViewButtonTapped(_ sender: Any) {
        self.router.viewPresent("add", ["":""])
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if(self.webMainView.canGoBack) {
            self.webMainView.goBack()
            self.webMainView.reload()
        } else {
            print("뒤로갈거 없는디?ㅎㅎ")
        }
    }
}