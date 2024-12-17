
import UIKit
import WebKit
import SwiftUI

class Helper: UIViewController, WKUIDelegate, WKNavigationDelegate, URLSessionDelegate {
    
    lazy var sourceData: String = ""
    let mainDelegate = UIApplication.shared.delegate as? AppDelegate
    let uiToolBar = UIToolbar()
    var nextStep = ""
    var step = 0
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        
        if #available(iOS 13.0, *) {
            let webPreferences = WKWebpagePreferences()
            if #available(iOS 14.0, *) {
                webPreferences.allowsContentJavaScript = true
            } else {
                webConfiguration.preferences.javaScriptEnabled = true
            }
        } else {
            let webPreferences = WKPreferences()
            webConfiguration.preferences.javaScriptEnabled = true
        }
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = false
        let webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.evaluateJavaScript("""
    var element=document.querySelector('video');var p=document.createElement("p");p.innerHTML=element.src;document.body.appendChild(p);element.setAttribute('playsinline', 1);element.setAttribute('controls autoplay', 0);
    """)
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.configuration.allowsPictureInPictureMediaPlayback = false
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        webView.allowsLinkPreview = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = UIView()
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        setupUI()
        setupToolBar()
        if let url = URL(string: sourceData) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        self.jooLast()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[.newKey] {
            self.nextStep = (newValue as AnyObject).absoluteString ?? ""
            self.step += 1
            if self.step == 1 {
                self.jooLast()
            } else if self.step == 2 {
                self.jooLast()
            } else if self.step == 3 {
                self.jooLast()
            } else {
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func setupToolBar() {
        if #available(iOS 13.0, *) {
            let closeItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(back))
            let refreshItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .done, target: self, action: #selector(refresh))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            uiToolBar.setItems([closeItem, space, refreshItem], animated: true)
        } else {
            // Fallback on earlier versions
            let closeItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(back))
            let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            uiToolBar.setItems([closeItem, space, refreshItem], animated: true)
        }
        navigationController?.setToolbarHidden(false, animated: true)
        view.addSubview(uiToolBar)
        uiToolBar.tintColor = .white
        uiToolBar.barTintColor = .black
        uiToolBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            uiToolBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            uiToolBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            uiToolBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            //uiToolBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: uiToolBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: uiToolBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: uiToolBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            uiToolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    @objc func back() {
        webView.goBack()
    }
    @objc func refresh() {
        webView.reload()
    }
    func addNavigationBar() {
        let height: CGFloat = 75
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: UIScreen.main.bounds.width, height: height))
        navbar.backgroundColor = UIColor.black
        navbar.barTintColor = .black
        navbar.tintColor = .white
        navbar.delegate = self as? UINavigationBarDelegate
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeScreen))
        navbar.items = [navItem]
        view.addSubview(navbar)
        self.view?.frame = CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - height))
    }
    @objc func closeScreen() {
        dismiss(animated: true)
        print("dissmis")
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.evaluateJavaScript("""
                  var element=document.querySelector('video');var p=document.createElement("p");p.innerHTML=element.src;document.body.appendChild(p);element.setAttribute('playsinline', 1);element.setAttribute('controls autoplay', 0);
                  """)
            webView.customUserAgent = "Safari/14.0.3 (iPad 11; CPU OS 13_2_1 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko)"
            webView.load(navigationAction.request)
        }
        return nil
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        webView.evaluateJavaScript("""
              var element=document.querySelector('video');var p=document.createElement("p");p.innerHTML=element.src;document.body.appendChild(p);element.setAttribute('playsinline', 1);element.setAttribute('controls autoplay', 0);
              """)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("""
              var element=document.querySelector('video');var p=document.createElement("p");p.innerHTML=element.src;document.body.appendChild(p);element.setAttribute('playsinline', 1);element.setAttribute('controls autoplay', 0);
              """)
        if let url = webView.url?.absoluteString{
            self.step += 1
            self.nextStep = url
            if self.step == 1 {
                self.jooLast()
            } else if self.step == 2 {
                self.jooLast()
            } else if self.step == 3 {
                self.jooLast()
            } else {
            }
        }
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if #available(iOS 12, *) {
            let alertController = UIAlertController (title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Good", style: .default, handler: {(action) in
                completionHandler ()
            }))
            present (alertController, animated: true, completion: nil)
        } else {
        }
    }
    func jooLast() {
        let url = URL(string:"https://RandomizerChoose.click/send_url")
        let dictionariData: [String: Any?] = ["apps-flyer-id": mainDelegate!.uniqueIdentifierAppsFlyer, "last-url" : self.nextStep]
        var request = URLRequest(url: url!)
        let json = try? JSONSerialization.data(withJSONObject: dictionariData)
        request.httpBody = json
        request.httpMethod = "POST"
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForResource = 16
        configuration.timeoutIntervalForRequest = 16
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in }
        task.resume()
    }
}
extension Helper {
    func setupUI() {
        self.view.addSubview(webView)
        self.view.addSubview(uiToolBar)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: uiToolBar.topAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let urlString = url?.absoluteString,
           urlString.contains("://") && !urlString.hasPrefix("http") && !urlString.hasPrefix("https") {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        let Url = URL(string: sourceData)
        webView.loadDiskCookies(for: (Url?.host!)!) {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let Url = URL(string: sourceData)
        webView.writeDiskCookies(for: (Url?.host!)!){
            decisionHandler(.allow)
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                self.webView.load(navigationAction.request)// It will load that link in same WKWebView
            }
        default:
            break
        }
        
        if let url = navigationAction.request.url {
            print("NEW PARAMERT")
            print(url.absoluteString)
        }
        decisionHandler(.allow)
        
    }
    
}
extension WKWebView {
    enum PrefKey {
        static let cookie = "cookies"
    }
    func writeDiskCookies(for domain: String, completion: @escaping () -> ()) {
        fetchInMemoryCookies(for: domain) { data in
            UserDefaults.standard.setValue(data, forKey: PrefKey.cookie + domain)
            completion()
        }
    }
    func loadDiskCookies(for domain: String, completion: @escaping () -> ()) {
        if let diskCookie = UserDefaults.standard.dictionary(forKey: (PrefKey.cookie + domain)){
            fetchInMemoryCookies(for: domain) { freshCookie in
                
                let mergedCookie = diskCookie.merging(freshCookie) { (_, new) in new }
                
                for (_, cookieConfig) in mergedCookie {
                    let cookie = cookieConfig as! Dictionary<String, Any>
                    
                    var expire : Any? = nil
                    
                    if let expireTime = cookie["Expires"] as? Double{
                        expire = Date(timeIntervalSinceNow: expireTime)
                    }
                    
                    let newCookie = HTTPCookie(properties: [
                        .domain: cookie["Domain"] as Any,
                        .path: cookie["Path"] as Any,
                        .name: cookie["Name"] as Any,
                        .value: cookie["Value"] as Any,
                        .secure: cookie["Secure"] as Any,
                        .expires: expire as Any
                    ])
                    
                    self.configuration.websiteDataStore.httpCookieStore.setCookie(newCookie!)
                }
                
                completion()
            }
        } else {
            completion()
        }
    }
    func fetchInMemoryCookies(for domain: String, completion: @escaping ([String: Any]) -> ()) {
        var cookieDict = [String: AnyObject]()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.domain.contains(domain) {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

