# MobileNetApp-MLKit

본 프로젝트는 [MoTLabs/mot-ios-tensorflow](https://github.com/motlabs/mot-ios-tensorflow)에서 연재하는 iOS용 머신러닝 모델 사용법에대한 예제프로젝트입니다.<br>

![DEMO-MLKit](https://github.com/tucan9389/MobileNetApp-MLKit/raw/master/resource/MobileNet-MLKit-DEMO.gif?raw=true)

>  [Core ML 사용했던 예제](https://github.com/tucan9389/MobileNetApp-CoreML)와 동일한 UI를 사용했습니다.

## 요구환경

- Xcode 9.0+
- iOS 8+
- Swift 3.0+
- CocoaPods 1.2.0+

## 준비물

- Tensorflow Lite 모델(`mobilenet_quant_v1_224.tflite`)과 레이블 파일(`labels.txt`)<br>
  ☞ [Tensorflow Lite 홈페이지에서 다운](https://www.tensorflow.org/versions/r1.5/mobile/tflite/demo_android)

## 빌드 준비

### Firebase 설정

1. [애플 개발자 인증센터](https://developer.apple.com/account/ios/certificate/)에서 `App ID` 생성
2. [Firebase 콘솔](https://console.firebase.google.com/u/0/)에 프로젝트를 추가(`App ID` 필요)<br>
   ☞ 프로젝트 추가할때  `GoogleService-Info.plist` 내려받기
3. [iOS 프로젝트에 Firebase 추가](https://firebase.google.com/docs/ios/setup) 
   - Bundle Identifier에 `App ID` 입력
   - Xcode 프로젝트에 `GoogleService-Info.plist` 추가