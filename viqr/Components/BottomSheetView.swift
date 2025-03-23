//
//  BottomSheetView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 23/3/25.
//

import SwiftUI

#if os(iOS)
    struct BottomSheetView<Content: View>: View {
        @Binding var isPresented: Bool
        let content: Content
        @State private var offset: CGFloat = UIScreen.main.bounds.height
        @State private var isDragging = false
        @State private var keyboardHeight: CGFloat = 0
        private let minHeight: CGFloat = 100
        private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.4

        init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
            self._isPresented = isPresented
            self.content = content()
        }

        var body: some View {
            ZStack {
                if isPresented {
                    // Background overlay
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            close()
                        }
                        .transition(.opacity)

                    // Actual sheet
                    VStack(spacing: 12) {
                        // Handle indicator
                        Capsule()
                            .fill(Color.appSurface2)
                            .frame(width: 40, height: 5)
                            .padding(.top, 12)

                        // Sheet content
                        content
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.appBackground)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
                    )
                    .offset(y: offset)
                    // Adjust the sheet position based on keyboard height
                    // When keyboard shows, move the sheet up
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 20 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Only allow dragging down
                                if value.translation.height > 0 {
                                    isDragging = true
                                    offset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                // If dragged more than 100 points, close the sheet
                                if value.translation.height > 100 {
                                    close()
                                } else {
                                    // Otherwise snap back to position
                                    withAnimation(.spring()) {
                                        offset = 0
                                    }
                                }
                            }
                    )
                    .transition(
                        .move(edge: .bottom)
                            .combined(with: .opacity)
                    )
                }
            }
            .ignoresSafeArea()
            .dismissKeyboardOnTap()
            .animation(.spring(), value: isPresented)
            .animation(.spring(), value: offset)
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Reset the offset when sheet is presented
                    withAnimation(.spring()) {
                        offset = 0
                    }

                    // Add keyboard observers when sheet is presented
                    setupKeyboardObservers()
                } else {
                    // Remove keyboard observers when sheet is dismissed
                    removeKeyboardObservers()
                }
            }
            .onAppear {
                if isPresented {
                    setupKeyboardObservers()
                }
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }

        private func close() {
            withAnimation(.spring()) {
                offset = UIScreen.main.bounds.height
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
            // Hide keyboard when closing
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        private func setupKeyboardObservers() {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[
                    UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                {
                    self.keyboardHeight = keyboardFrame.height
                }
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.keyboardHeight = 0
            }
        }

        private func removeKeyboardObservers() {
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        }
    }
#endif
