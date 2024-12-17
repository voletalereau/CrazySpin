//
//  SettingsView.swift
//  Crazy
//
//  Created by D K on 15.12.2024.
//

import SwiftUI
import MessageUI
import StoreKit
import AVFoundation


struct SettingsView: View {
    
    @StateObject private var soundPlayer = SoundPlayer.shared
    
    @State private var showMail = false
    @State private var isAlertShown = false
    
    var body: some View {
        ZStack {
            Image("bgBlur")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    
                    HStack {
                        Text("USAGE")
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    Rectangle()
                        .frame(width: size().width - 40, height: 60)
                        .foregroundColor(.black.opacity(0.5))
                        .cornerRadius(24)
                        .overlay {
                            HStack {
                                Text("Sounds")
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Toggle("", isOn: $soundPlayer.isSoundOn)
                            }
                            .padding(.horizontal)
                        }
                    
                    HStack {
                        Text("SUPPORT")
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.top)
                    
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showMail.toggle()
                        } else {
                            isAlertShown.toggle()
                        }
                    } label: {
                        Rectangle()
                            .frame(width: size().width - 40, height: 60)
                            .foregroundColor(.black.opacity(0.5))
                            .cornerRadius(24)
                            .overlay {
                                HStack {
                                    Text("Feedback")
                                        .foregroundStyle(.white)
                                    
                                    
                                }
                                .padding(.horizontal)
                            }
                    }
                    .sheet(isPresented: $showMail) {
                        MailComposeView(isShowing: $showMail, subject: "Feedback", recipientEmail: "voletalereau@gmail.com", textBody: "")
                    }
                    .alert("Unable to send email", isPresented: $isAlertShown) {
                        Button {
                            isAlertShown.toggle()
                        } label: {
                            Text("Ok")
                        }
                    } message: {
                        Text("Your device does not have a mail client configured. Please configure your mail or contact support on our website.")
                    }
                    
                    Button {
                        requestAppReview()
                    } label: {
                        Rectangle()
                            .frame(width: size().width - 40, height: 60)
                            .foregroundColor(.black.opacity(0.5))
                            .cornerRadius(24)
                            .overlay {
                                HStack {
                                    Text("Rate the App")
                                        .foregroundStyle(.white)
                                    
                                    
                                }
                                .padding(.horizontal)
                            }
                    }
                    
                    
                    Button {
                        openPrivacyPolicy()
                    } label: {
                        Rectangle()
                            .frame(width: size().width - 40, height: 60)
                            .foregroundColor(.black.opacity(0.5))
                            .cornerRadius(24)
                            .overlay {
                                HStack {
                                    Text("Privacy Policy")
                                        .foregroundStyle(.white)
                                    
                                    
                                }
                                .padding(.horizontal)
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 100)
           
            
            
            VStack {
                Text("Settings")
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .black))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
        }
    }
    
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://RandomizerChoose.click/com.RandomizerChoose/Voleta_Lereau/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    SettingsView()
}


struct MailComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let subject: String
    let recipientEmail: String
    let textBody: String
    var onComplete: ((MFMailComposeResult, Error?) -> Void)?
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.setSubject(subject)
        mailComposer.setToRecipients([recipientEmail])
        mailComposer.setMessageBody(textBody, isHTML: false)
        mailComposer.mailComposeDelegate = context.coordinator
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
            parent.onComplete?(result, error)
        }
    }
}


class SoundPlayer: ObservableObject {
    static let shared = SoundPlayer()
    private var audioPlayer: AVAudioPlayer?

    @Published var isSoundOn: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
        }
    }

    init() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(true, forKey: "isSoundOn")
        }

        self.isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
    }

    func playPopSound() {
        if isSoundOn {
            guard let url = Bundle.main.url(forResource: "spin", withExtension: "mp3") else {
                print("Sound file not found!")
                return
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 0.2
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
}
