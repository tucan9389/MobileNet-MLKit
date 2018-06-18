# MobileNetApp-MLKit
![MobileNetApp-MLKit DEMO](resource/MobileNetApp-MLKit-example.gif?raw=true)

## 요구환경

- Xcode 9.0+
- iOS 8+
- Swift 3.0+
- CocoaPods 1.2.0+

## 준비물

- Tensorflow Lite용 모델(`mobilenet_quant_v1_224.tflite`)과 레이블 파일(`labels.txt`)
  ☞ [Tensorflow Lite 홈페이지에서 다운](https://www.tensorflow.org/versions/r1.5/mobile/tflite/demo_android)

## 빌드 준비

### Firebase 설정

1. [애플 개발자 인증센터](https://developer.apple.com/account/ios/certificate/)에서 `App ID` 생성
2. [Firebase 콘솔](https://console.firebase.google.com/u/0/)에 프로젝트를 추가(`App ID` 필요)<br>
   ☞ 프로젝트 추가할때  `GoogleService-Info.plist` 내려받기
3. [iOS 프로젝트에 Firebase 추가](https://firebase.google.com/docs/ios/setup) 
   - Bundle Identifier에 `App ID` 입력
   - Xcode 프로젝트에 `GoogleService-Info.plist` 추가