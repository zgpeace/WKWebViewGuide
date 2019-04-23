//
//  ViewController.swift
//  WKWebViewGuide
//
//  Created by zgpeace on 2019/4/20.
//  Copyright © 2019 zgpeace. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
//        detectingData()
        self.view = webView
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
//        loadRemoteUrl("https://www.apple.com")
        loadLocalFile()
//        loadHtmlFragments()
        
//        loadRemoteUrl("https://www.apple.com")
//        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

//        loadRemoteUrl("https://www.apple.com")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
////            self.manageCookies()
////            self.customUserAgent()
////            self.showingAlertUI()
//            self.snapshotPartOfThePage()
//        }
    }
    
    
    func loadRemoteUrl(_ urlString: String) {
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        webView.load(urlString)
    }
    
    func loadLocalFile() {
        if let url = Bundle.main.url(forResource: "help", withExtension: "html") {
            let path = url.deletingLastPathComponent()
            print("url: \(url)")
            print("path: \(path)")
            webView.loadFileURL(url, allowingReadAccessTo: path)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.injectJavaScriptIntoAPage()
            }
        }
    }
    
    func loadHtmlFragments() {
        let html = """
        <html>
            <head>
                <link href="help.css" rel="stylesheet" />
            </head>
            <body>
                <h1>Hello, Swift!</h1>
            </body>
        </html>
        """
        
//        webView.loadHTMLString(html, baseURL: nil)
        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Reading pages the user has visited
        printHistoryBackList()
        
        // Controlling which sites can be visited
        if let host = navigationAction.request.url?.host {
            if host == "www.apple.com" {
                decisionHandler(.allow)
                return
            }
        }

        decisionHandler(.allow)
//        decisionHandler(.cancel)
        
        // Opening a link in the external browser
//        if let url = navigationAction.request.url {
//            if url.host == "www.apple.com" {
//               UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                decisionHandler(.cancel)
//                return
//            }
//        }
//
//        decisionHandler(.allow)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
    }
    
    func printHistoryBackList() {
        for page in webView.backForwardList.backList {
            print("User visited \(page.url.absoluteString)")
        }
    }

    func injectJavaScriptIntoAPage() {
        webView.evaluateJavaScript("document.getElementById('username').innerText") { (result, error) in
            if let result = result {
                print(result)
            }
        }
    }
    
    func manageCookies() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.name == "authentication" {
                    self.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie, completionHandler: nil)
                } else {
                    print("\(cookie.name) is set to \(cookie.value)")
                }
            }
        }
    }
    
    func customUserAgent() {
        print("old agent: \(String(describing: webView.customUserAgent))")
        webView.customUserAgent = "My Awesome App"
        print("new agent: \(String(describing: webView.customUserAgent))")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default
            , handler: nil))
        present(ac, animated: true)
        completionHandler()
    }
    
    func showingAlertUI() {
        webView.evaluateJavaScript("alert('boom');", completionHandler: nil)
    }
    
    func snapshotPartOfThePage() {
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 200, width: 150, height: 50)
        
        webView.takeSnapshot(with: config) { (image, error) in
            if let image = image {
                print(image.size)
                let imageView = UIImageView(image: image)
                self.view.addSubview(imageView)
            }
        }
        
    }
    
    func detectingData() {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = [.all]
        webView = WKWebView(frame: .zero, configuration: config)
    }
}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

