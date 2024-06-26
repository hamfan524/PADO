//
//  BirthView.swift
//  PADO
//
//  Created by 강치우 on 1/15/24.
//

import SwiftUI

struct BirthView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @ObservedObject var loginVM: LoginViewModel
    
    @State var showBirthAlert: Bool = false
    @State var buttonActive: Bool = false
    
    @Binding var isShowStartView: Bool
    
    let termsLink = "[이용약관](https://notch-galaxy-ab8.notion.site/6ff60c61aa104cd6b1471d3ea5102ce3?pvs=4)"
    let personalInfoLink = "[개인정보 정책](https://notch-galaxy-ab8.notion.site/3147fcead0ed41cdad6e2078893807b7?pvs=4)"
    
    var body: some View {
        ZStack {     
            VStack(alignment: .leading) {
                // id값 불러오는 로직 추가 해야함
                Text("\(loginVM.nameID)님 환영합니다\n생일을 입력해주세요")
                    .font(.system(.title2))
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 8, content: {
                        VStack(alignment: .leading, spacing: 8, content: {
                            TextField("생년월일", text: $loginVM.year)
                                .disabled(true)
                                .tint(.white)
                                .multilineTextAlignment(.leading)
                                .onChange(of: loginVM.year) { _, newValue in
                                    buttonActive = newValue.count > 0
                                }
                            
                            Divider()
                            
                            Text("만 14세 미만의 이용자는 가입할 수 없습니다.")
                                .foregroundStyle(.gray)
                                .font(.system(.subheadline))
                                .fontWeight(.semibold)
                            
                            Group {
                                Text("가입과 동시에 파도의 ")
                                    .foregroundStyle(.gray)
                                +
                                Text(.init(termsLink))
                                    .foregroundStyle(.blue)
                                +
                                Text("과 ")
                                    .foregroundStyle(.gray)
                                +
                                Text(.init(personalInfoLink))
                                    .foregroundStyle(.blue)
                                +
                                Text("에 동의하는 것으로 간주함니다.")
                                    .foregroundStyle(.gray)
                            }
                            .font(.system(.subheadline))
                            .fontWeight(.semibold)
                       
                        })
                    })

                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    DatePicker("", selection: $loginVM.birthDate,
                               displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .environment(\.locale, Locale.init(identifier: "ko"))
                    .labelsHidden()
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                
                Button {
                    if buttonActive {
                        if loginVM.isFourteenOrOlder() {
                            Task{
                                await loginVM.signUpUser()
                                await viewModel.fetchUIDByPhoneNumber(phoneNumber: "+82\(loginVM.phoneNumber)")
                                await viewModel.fetchUser()
                                needsDataFetch.toggle()
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                    isShowStartView = false
                                }
                            }
                        } else {
                            showBirthAlert = true
                        }
                    }
                } label: {
                    WhiteButtonView(buttonActive: $buttonActive, text: "가입하기")
                    // true 일 때 버튼 변하게 하는 onChange 로직 추가해야함
                }
                .padding(.bottom)
            }
            .padding(.top, 150)
        }
        .sheet(isPresented: $showBirthAlert) {
            BirthAlertModal()
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
        }
    }
   
}

