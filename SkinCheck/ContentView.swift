import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignInSwift
import GoogleSignIn
import PhotosUI
import MessageUI

struct ContentView: View {
    @State private var isSignedIn = false
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOffset: CGFloat = 0.0

    var body: some View {
        NavigationView {
            ZStack {
                // Arkaplan Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    if isSignedIn {
                        // Giriş Yapıldıktan Sonra Görünen Ekran
                        VStack(spacing: 20) {
                            NavigationLink(destination: SkinAnalysisView()) {
                                Text("Skin Analysis")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gradient)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 20)

                            NavigationLink(destination: PromoteProductsView()) { // Burada PromoteProductsView'e yönlendirme yapıldı
                                Text("Promote Your Products")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gradient)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 20)
                        }
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: Button(action: {
                            isSignedIn = false
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.blue)
                        })
                    } else {
                        // Giriş Yapılmadan Önce Görünen Ekran
                        VStack(spacing: 20) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .scaleEffect(logoScale)
                                .offset(y: logoOffset)
                                .shadow(radius: 5)
                                .onAppear {
                                    animateLogo()
                                }

                            Text("Every Skin is Unique; The Best For You is Here.")
                                .font(.custom("Snell Roundhand", size: 20))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)

                            NavigationLink(destination: RegisterScreen(isSignedIn: $isSignedIn)) {
                                Text("Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gradient)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)

                            Button(action: signInWithGoogle) {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)

                                    Text("Sign in with Google")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gradient)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)

                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.white)

                                NavigationLink(destination: SignInScreen()) {
                                    Text("Sign in")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    private func animateLogo() {
        withAnimation(
            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        ) {
            logoScale = 1.05
            logoOffset = -5
        }
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase Client ID not found.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Root view controller not found.")
            return
        }

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google ID token not found.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth error: \(error.localizedDescription)")
                } else {
                    print("User successfully signed in.")
                    isSignedIn = true
                }
            }
        }
    }
}

// Sign In Screen
struct SignInScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var navigateToMainOptions = false // Ana ekrana yönlendirme kontrolü

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)

                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                            } else {
                                SecureField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()

                    // Güncellenen Sign In Tuşu
                    Button(action: {
                        signInUser()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    Button(action: {
                        resetPassword()
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.top, 10)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $navigateToMainOptions) {
                    MainOptionsScreen() // Ana ekran buraya tanımlandı
                }
            }
        }
    }

    private func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = nil
                self.navigateToMainOptions = true // Yönlendirme tetikleniyor
                print("User successfully signed in.")
            }
        }
    }

    private func resetPassword() {
        guard !email.isEmpty else {
            self.errorMessage = "Please enter your email address."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "Password reset email sent!"
            }
        }
    }
}

struct MainOptionsScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    NavigationLink(destination: SkinAnalysisView()) {
                        Text("Skin Analysis")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    Button(action: {
                        print("Promote Your Products tapped!")
                    }) {
                        Text("Promote Your Products")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}


// Register Screen
struct RegisterScreen: View {
    @Binding var isSignedIn: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var gender = "Male"
    @State private var birthDate = Date()
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var showVerificationScreen = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 32/255, green: 0, blue: 96/255),
                    Color(red: 24/255, green: 0, blue: 72/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Register")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                VStack(spacing: 15) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)

                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                        } else {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()

                HStack(spacing: 15) {
                    Button(action: {
                        registerUser()
                    }) {
                        Text("Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        cancelRegistration()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showVerificationScreen) {
                VerificationScreen(email: $email, isSignedIn: $isSignedIn)
            }
        }
    }

    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = nil
                sendVerificationEmail()
            }
        }
    }

    private func sendVerificationEmail() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.sendEmailVerification { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.showVerificationScreen = true
                print("Verification email sent!")
            }
        }
    }

    private func cancelRegistration() {
        firstName = ""
        lastName = ""
        gender = "Male"
        birthDate = Date()
        email = ""
        password = ""
        errorMessage = nil
    }
}

struct VerificationScreen: View {
    @Binding var email: String
    @Binding var isSignedIn: Bool
    @State private var showMessage: Bool = false
    @State private var navigateToSignIn: Bool = false
    @State private var errorMessage: String? = nil // Hata mesajını tutan state

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Email Verification")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    Text("Please check your email for the verification link.")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()

                    if showMessage {
                        Text("Email verified successfully!")
                            .foregroundColor(.green)
                            .font(.headline)
                            .padding(.top, 10)

                        Button(action: {
                            navigateToSignIn = true
                        }) {
                            Text("You can sign in")
                                .foregroundColor(.blue)
                                .underline()
                                .font(.headline)
                        }
                    }

                    Button(action: checkEmailVerification) {
                        Text("I Verified My Email")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(8)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $navigateToSignIn) {
                    SignInScreen()
                }
            }
        }
    }

    private func checkEmailVerification() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not found. Please try signing in again."
            return
        }

        user.reload { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if user.isEmailVerified {
                self.showMessage = true
                self.errorMessage = nil // Hata mesajını temizle
            } else {
                self.errorMessage = "Email not verified yet. Please try again."
            }
        }
    }
}

// SkinAnalysisView - Fotoğraf yükleme ve analiz sayfası
struct SkinAnalysisView: View {
    @State private var selectedImage: UIImage? = nil // Seçilen fotoğraf
    @State private var isPickerPresented = false    // Galeri açma durumu
    @State private var showCamera = false           // Kamera açma durumu
    @State private var navigateToLoading = false    // LoadingView'e geçiş durumu
    @State private var errorMessage: String? = nil  // Hata mesajını tutar

    var body: some View {
        NavigationStack {
            ZStack {
                // Arkaplan Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Başlık
                    Text("Skin Analysis")
                        .font(.title)
                        .foregroundColor(.white)

                    // Fotoğraf gösterme alanı
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                    } else {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("No Image Selected")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Fotoğraf yükleme ve kamera butonları
                    HStack(spacing: 15) {
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            Text("Upload Photo")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gradient)
                                .cornerRadius(12)
                        }
                        .fullScreenCover(isPresented: $isPickerPresented) {
                            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                        }

                        Button(action: {
                            showCamera = true
                        }) {
                            Text("Camera")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gradient)
                                .cornerRadius(12)
                        }
                        .fullScreenCover(isPresented: $showCamera) {
                            ImagePicker(image: $selectedImage, sourceType: .camera)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Analyze butonu
                    Button(action: {
                        if selectedImage == nil {
                            errorMessage = "Please upload a photo first to analyze."
                        } else {
                            errorMessage = nil
                            navigateToLoading = true
                        }
                    }) {
                        Text("Analyze")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gradient)
                            .cornerRadius(12)
                    }
                    .fullScreenCover(isPresented: $navigateToLoading) {
                        LoadingView(image: selectedImage)
                    }

                    // Hata mesajı
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }
}

// LoadingView - 4 saniyelik analiz sayfası
struct LoadingView: View {
    var image: UIImage?
    @State private var navigateToResult = false
    @State private var randomResult: SkinResult = SkinResult.allCases.randomElement() ?? .acnePimples

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            }

            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                Text("Analyzing your picture...")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                navigateToResult = true
            }
        }
        .fullScreenCover(isPresented: $navigateToResult) {
            ResultView(randomResult: randomResult)
        }
    }
}

// Ürün modeli
struct Product: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let link: String
}

// ResultView - Analiz sonucu sayfası
struct ResultView: View {
    var randomResult: SkinResult
    @State private var path = NavigationPath()
    @State private var isInProductsView = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Arkaplan Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    // Back Butonu
                    Button(action: {
                        if isInProductsView {
                            isInProductsView = false
                            if !path.isEmpty { // Path kontrolü ekledik
                                path.removeLast()
                            }
                        } else {
                            if !path.isEmpty { // Path kontrolü ekledik
                                path.removeLast()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Başlık
                    Text("Analysis Results")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Analiz sonucu detayları
                    VStack(alignment: .leading, spacing: 10) {
                        Text(randomResult.title)
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Text("**Symptoms:** \(randomResult.symptoms)")
                            .foregroundColor(.white)

                        Text("**Recommended Products:**")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        ForEach(randomResult.products.map { $0.name }, id: \.self) { product in
                            Text("- \(product)")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)

                    // Ürünler sayfasına geçiş butonu
                    Button(action: {
                        isInProductsView = true
                        path.append("products")
                    }) {
                        Text("Click here to browse recommended products")
                            .font(.headline)
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            // ProductsView'a geçiş
            .navigationDestination(for: String.self) { value in
                if value == "products" {
                    ProductsView(products: randomResult.products)
                }
            }
        }
    }
}


// ProductsView - Ürünler sayfası
struct ProductsView: View {
    let products: [Product] // Ürün listesi
    var body: some View {
        ZStack {
            // Arkaplan Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 32/255, green: 0, blue: 96/255),
                    Color(red: 24/255, green: 0, blue: 72/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Sayfa Başlığı
                    Text("Recommended Products")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Ürün Kartları
                    ForEach(products) { product in
                        VStack {
                            Link(destination: URL(string: product.link)!) {
                                VStack {
                                    Image(product.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                                    
                                    Text(product.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                                .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// Enum: Analiz sonuçları
enum SkinResult: CaseIterable {
    case acnePimples, dryness, darkSpots, sensitivity, oilySkin, linesWrinkles, pore

    var title: String {
        switch self {
        case .acnePimples: return "Acne and Pimples"
        case .dryness: return "Dryness and Dehydration"
        case .darkSpots: return "Dark Spots and Hyperpigmentation"
        case .sensitivity: return "Sensitivity and Redness"
        case .oilySkin: return "Oily Skin and Shine"
        case .linesWrinkles: return "Fine Lines and Wrinkles"
        case .pore: return "Pore Issues"
        }
    }

    var symptoms: String {
        switch self {
        case .acnePimples: return "Blackheads, whiteheads, inflamed pimples."
        case .dryness: return "Flaky skin, tightness."
        case .darkSpots: return "Dark spots, uneven skin tone."
        case .sensitivity: return "Redness, irritation, and burning."
        case .oilySkin: return "Excess sebum, enlarged pores."
        case .linesWrinkles: return "Loss of elasticity, signs of aging."
        case .pore: return "Enlarged or clogged pores."
        }
    }

    var products: [Product] {
        switch self {
        case .acnePimples:
            return [
                Product(name: "Salicylic Acid Cleanser", imageName: "Cleanser", link: "https://www.korendy.com.tr/products/cosrx-salicylic-acid-daily-gentle-cleanser"),
                Product(name: "Spot Treatment", imageName: "SpotTreatment", link: "https://www.trendyol.com/la-roche-posay/effaclar-duo-m-cilt-bakim-kremi-40ml"),
                Product(name: "Tea Tree Oil Serum", imageName: "TeaTreeOilSerum", link: "https://www.korendy.com.tr/products/dr-ceuracle-tea-tree-purifine-95-essence"),
                Product(name: "Moisturizer",imageName: "moisturizers", link: "https://www.dermoeczanem.com/cerave-yaglanma-karsiti-nemlendirici-yuz-kremi-52-ml")
            ]
        case .dryness:
            return [
                Product(name: "Hyaluronic Acid Serum", imageName: "Hyaluronic acid serum", link: "https://www.trendyol.com/la-roche-posay/hyalu-b5-dolgunlastirici-serum-hassas-ciltiler-icin-30-ml-p-35814733"),
                Product(name: "Moisturizers With Ceramides", imageName: "Moisturizers with ceramides", link: "https://www.dermoeczanem.com/cerave-nemlendirici"),
                Product(name: "Intensive Hydration Masks", imageName: "Intensive hydration masks",link: "https://www.sephora.com.tr/p/drink-up-intensive-overnight---avokadolu-nemlendirici-maske-P10050390.html"),
                Product(name: "Gentle Cleansers (sulfate-free)", imageName:"Gentle cleansers (sulfate-free)", link: "https://www.trendyol.com/la-roche-posay/toleriane-caring-wash-400ml-p-2543665?boutiqueId=61&merchantId=149326")
            ]
        case .darkSpots:
            return [
                Product(name: "Vitamin C Serum", imageName: "Vitamin C serum", link: "https://www.trendyol.com/la-roche-posay/pure-vitamin-c10-c-vitamin-icerikli-isilti-veren-serum-30ml-p-82732248"),
                Product(name: "Product With Niacinamide", imageName: "Product with niacinamide", link: "https://www.dermoeczanem.com/cosrx-galactomyces-maya-mantari-ozlu-cilt-tonu-esitlemeye-yardimci-serum-100-ml"),
                Product(name: "Spot Correctors With Alpha Arbutin", imageName: "Spot correctors with alpha arbutin", link:  "https://www.trendyol.com/the-ordinary/alpha-arbutin-2-ha-p-28309809"),
                Product(name: "Sunscreen (SPF 30 or higher)",imageName: "Sunscreens (SPF 30 or higher)", link: "https://www.trendyol.com/la-roche-posay/anthelios-xl-spf-50-dry-touch-yagli-ciltler-icin-matlastirici-parfumsuz-yuz-gunes-kremi-50-ml-p-737514859")
            ]
        case .sensitivity:
            return [
                Product(name: "Azelaic Acid", imageName: " Azelaic acid product", link: "https://www.trendyol.com/the-ordinary/azelaic-acid-suspension-10-30ml-p-6707048?utm_source=chatgpt.com"),
                Product(name: "Soothing Toner", imageName: "Soothing toner", link: "https://www.sephora.com.tr/p/aloe-vera-toner-P3607080.html"),
                Product(name: "Mineral-based Sunscreen", imageName: "Mineral-based sunscreen", link: "https://www.dermoeczanem.com/avene-mineral-sivi-gunes-kremi-spf-50-40-ml?gad_source=4&gclid=CjwKCAiAgoq7BhBxEiwAVcW0LCyKX-E_BsVycJNlq6DNe-zyjcrWc8YVxNC5foj6srmepIEZGbNvUBoCyUYQAvD_BwE"),
                Product(name: "Moisturizer With Probiotics", imageName: "Moisturizer with probiotics",link: "https://miseca.com/products/prebiyotik-nemlendirici-krem?utm_source=chatgpt.com")
            ]
        case .oilySkin:
            return[
                Product(name: "Clay Mask(kaolin-based)", imageName: "Clay mask(kaolin-based)", link: "https://www.origins.com.tr/product/15346/62429/cilt-bakimi/bakim/maskeler/original-skintm/arndrc-puruzsuzlestirici-hassas-kil-maskesi#/sku/190723"),
                Product(name: "Cleanser With Salicylic Acid", imageName: "Cleanser with salicylic acid", link: "https://www.korendy.com.tr/products/cosrx-salicylic-acid-daily-gentle-cleanser"),
                Product(name: "Lightweight Gel Moisturizer", imageName: "Lightweight gel moisturizer", link: "https://www.trendyol.com/clinique/dramt-diff-hydrating-jelly-125-ml-p-4827049"),
                Product(name: "Oily-Controlling Toner(witch hazel)", imageName: "Oil-controlling toners(witch hazel)", link: "https://www.trendyol.com/sirenol/natural-cadi-findigi-cilt-sikilastirici-gozenek-temizleyici-tonik-300-ml-p-33993054?utm_source=chatgpt.com")
            ]
        case .linesWrinkles:
            return[
                Product(name: "Antioxidant-rich Product", imageName: "Antioxidant-rich product", link: "https://www.kiehls.com.tr/midnight-recovery-concentrate-p-11148?gad_source=1&gclid=CjwKCAiAgoq7BhBxEiwAVcW0LJnIkIbxAa-9qboHoBYZoDs8WugbpgR1A9B7mGe6yE8dYs3OAWsquxoCKkcQAvD_BwE&gclsrc=aw.ds"),
                Product(name: "Collagen-booting Mask", imageName: "Collagen-boosting mask", link: "https://www.kikomilano.com.tr/new-bright-lift-mask/"),
                Product(name: "Moisturizer With Peptides", imageName: "Moisturizer with peptides", link: "https://www.origins.com.tr/product/15917/128043/tum-urunler/youthtopatm-elma-ozu-ve-peptit-iceren-dolgunlastrc-krem/antioksidan-acsndan-zengin-peptit-iceren-nemlendirici?utm_source=chatgpt.com#/sku/186594"),
                Product(name: "Retinol Serum", imageName: "Retinol serum", link: "https://www.dermoeczanem.com/la-roche-posay-retinol-b3-yaslanma-ve-kirisiklik-karsiti-serum-30-ml?gad_source=1&gclid=CjwKCAiAgoq7BhBxEiwAVcW0LLLwWCoE3FTPy1v60d1mBP_n3A0N4pyLSiIHcH6ZjkY2WJCZ4tugthoCERgQAvD_BwE")
            ]
        case .pore:
            return[
                Product(name: "Clay Mask", imageName: "Clay mask", link: "https://www.dermoeczanem.com/caudalie-instant-detox-mask-75-ml?gad_source=4&gclid=CjwKCAiAgoq7BhBxEiwAVcW0LBs0ym2lx00dtsPTHHqkjlTToUKvk9bCVoc3-XVQFgxILuB5YdFs3hoCOO8QAvD_BwE"),
                Product(name: "Lightweight Moisturizer", imageName: "lightweight moisturizer", link: "https://www.clinique.com.tr/product/1687/5047/cilt-bakimi/yuz-nemlendirici/dramatically-different-nemlendirici-jel-krem"),
                Product(name: "Pore-refining Serum", imageName: "Pore-refining serum",link: "https://www.dermoeczanem.com/bioderma-sebium-pore-refiner-krem-30ml?gad_source=1&gclid=CjwKCAiAgoq7BhBxEiwAVcW0LPGI10dJjFPYGTsYNI9d5oBq28i1swtWhg-hTQtSyM4G9z1emJkAABoCRVMQAvD_BwE"),
                Product(name:"Toner With BHA", imageName: "Toner with BHA", link: "https://www.trendyol.com/cosrx/aha-bha-clarifying-treatment-toner-aha-bha-iceren-arindirici-tonik-p-2870701")
            ]
        }
    }
}

struct PromoteProductsView: View {
    @State private var senderEmail = ""
    @State private var selectedImage: UIImage? = nil
    @State private var productName = ""
    @State private var productContent = ""
    @State private var productFunctionality = ""
    @State private var isPickerPresented = false
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Arkaplan Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 32/255, green: 0, blue: 96/255),
                        Color(red: 24/255, green: 0, blue: 72/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Sayfa Başlığı
                        Text("Promote Your Products")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 2)
                            .padding(.top, 20)

                        // Fotoğraf Yükleme Alanı
                        VStack(spacing: 15) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 200)
                                    Text("No Image Selected")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.headline)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                )
                            }

                            Button(action: {
                                isPickerPresented = true
                            }) {
                                Label("Upload Photo", systemImage: "photo")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gradient)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $isPickerPresented) {
                                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Input Fields
                        VStack(spacing: 15) {
                            CustomTextField(placeholder: "Sender Email*", text: $senderEmail, keyboardType: .emailAddress)

                            CustomTextField(placeholder: "Product Name*", text: $productName)

                            CustomTextField(placeholder: "Product Content*", text: $productContent)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Product Functionality*")
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.headline)

                                TextEditor(text: $productFunctionality)
                                    .frame(height: 150)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                                    .foregroundColor(.black)
                                    .font(.body)
                                    .environment(\.colorScheme, .light)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Submit Button
                        Button(action: {
                            if validateInputs() {
                                showMailView = true
                            } else {
                                showAlert = true
                            }
                        }) {
                            Text("📩 Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gradient)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 20)
                        .sheet(isPresented: $showMailView) {
                            MailView(
                                result: $mailResult,
                                recipients: ["melisaozgr11@gmail.com"],
                                subject: "New Product Submission",
                                body: """
                                Sender Email: \(senderEmail)
                                Product Name: \(productName)
                                Product Content: \(productContent)
                                Product Functionality: \(productFunctionality)
                                """,
                                imageAttachment: selectedImage // Kullanıcı tarafından yüklenen görsel
                            )
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Validation Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // Validation Method
    private func validateInputs() -> Bool {
        if senderEmail.isEmpty {
            errorMessage = "Sender Email is required."
            return false
        }
        if !isValidEmail(senderEmail) {
            errorMessage = "Invalid email format."
            return false
        }
        if productName.isEmpty {
            errorMessage = "Product Name is required."
            return false
        }
        if productContent.isEmpty {
            errorMessage = "Product Content is required."
            return false
        }
        if productFunctionality.isEmpty {
            errorMessage = "Product Functionality is required."
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}

// Custom TextField Component
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.white.opacity(0.5)) // Placeholder için silik renk
                    .padding(.horizontal, 15)
            }
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .foregroundColor(.white)
                .font(.body)
        }
    }
}



// ImagePicker Struct
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


// Mail View
struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients: [String]
    var subject: String
    var body: String
    var imageAttachment: UIImage?

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator

        // Eğer bir görsel seçilmişse, bunu eklenti olarak ekle
        if let image = imageAttachment,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            vc.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "product_image.jpg")
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
}


// Gradient için extension
extension Color {
    static var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
