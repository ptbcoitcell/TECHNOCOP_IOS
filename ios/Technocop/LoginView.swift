import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var store: AppStore
    @State private var mobile: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: max(20, geometry.size.height * 0.06))

                    // Tamil Nadu Police Logo Emblem
                    Image("TamilNaduPoliceLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .padding(.bottom, 12)

                    // Title & Tagline
                    Text("TECHNOCOP")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(Color.white)
                        .tracking(2.5)

                    Text("PTB in your fingertips")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(TechTheme.textLightHeader)
                        .padding(.top, 4)

                    Spacer(minLength: 28)

                    // Input Fields Card
                    VStack(alignment: .leading, spacing: 14) {
                        // Username (Mobile Number)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("User Name (registered mobile number)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.white)

                            TextField("Enter 10 digit mobile number", text: $mobile)
                                .keyboardType(.numberPad)
                                .textContentType(.telephoneNumber)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(TechTheme.navy)
                                .onChange(of: mobile) { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    mobile = String(filtered.prefix(10))
                                }
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.white)

                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(.password)
                                        .foregroundStyle(TechTheme.navy)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.password)
                                        .foregroundStyle(TechTheme.navy)
                                }

                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(TechTheme.navy.opacity(0.7))
                                        .padding(.trailing, 4)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Error Message
                        if !store.errorMessage.isEmpty {
                            Text(store.errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(TechTheme.loginError)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 4)
                        }

                        // Login Button
                        Button {
                            hideKeyboard()
                            Task {
                                await store.signIn(mobile: mobile, password: password)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if store.isLoading {
                                    ProgressView()
                                        .tint(Color.white)
                                }
                                Text("LOGIN")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(TechTheme.saffron)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(store.isLoading || mobile.count != 10 || password.isEmpty)
                        .opacity((mobile.count == 10 && !password.isEmpty) ? 1.0 : 0.6)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 30)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(TechTheme.navy.ignoresSafeArea())
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
