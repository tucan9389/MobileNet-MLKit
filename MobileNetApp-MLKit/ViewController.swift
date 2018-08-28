//
//  ViewController.swift
//  MobileNetApp-MLKit
//
//  Created by GwakDoyoung on 01/06/2018.
//  Copyright © 2018 GwakDoyoung. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    // MARK: - UI 프로퍼티
    
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    
    
    var interpreter: ModelInterpreter?
    var ioOptions: ModelInputOutputOptions?
    
    // MARK: - MLKit 프로퍼티
    
    // 모델을 불러오고 물체를 인지할 수 있게 도와주는 Detector입니다.
    let detectorService = DetectorService()
    
    // MARK: - AV 프로퍼티
    
    var videoCapture: VideoCapture!
    
    
    // MARK: - 라이프사이클 메소드

    override func viewDidLoad() {
        super.viewDidLoad()

        // 모델 로드
        self.labelLabel.text = "로컬에 있는 모델을 불러오고 있습니다...\n"
        loadLocalModel()
        
        // 카메라 세팅
        setUpCamera()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - 초기 세팅
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // UI에 비디오 미리보기 뷰 넣기
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?/*, timestamp: CMTime*/) {
        
        // 카메라에서 캡쳐된 화면은 pixelBuffer에 담김.
        // Vision 프레임워크에서는 이미지 대신 pixelBuffer를 바로 사용 가능
        guard let pixelBuffer = pixelBuffer else { return }
        
        // 추론!
        self.predictUsingVision(pixelBuffer: pixelBuffer) { }
    }
}

// MARK: - 추론하기
extension ViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer, completion: @escaping (() -> ())) {
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = self.detectorService.scaledImageData(for: ciImage)
            self.detectorService.detectObjects(imageData: imageData) { (results, error) in
                guard error == nil, let results = results, !results.isEmpty else {
                    let errorString = error?.localizedDescription ?? Constants.failedToDetectObjectsMessage
                    self.labelLabel.text = "Inference error: \(errorString)"
                    print("Inference error: \n\(errorString)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.show(for: results)
                    completion()
                }
            }
        }
        
    }
    
    func show(for results: [(label: String, confidence: Float)]) {
        
        if let result = results.first {
            self.labelLabel.text = result.label
            self.confidenceLabel.text = "\(round(result.confidence * 100)) %"
        } else {
            self.labelLabel.text = "Something Wrong"
            self.confidenceLabel.text = "- %"
            
        }
    }
}

extension ViewController {
    
    /// 모델을 불러옵니다
    func loadLocalModel() {
        
        // 로컬 모델의 경로
        guard let localModelFilePath = Bundle.main.path(forResource: Constants.quantizedModelFilename,
                                                        ofType: DetectorConstants.modelExtension),
              let labelsFilePath = Bundle.main.path(forResource: Constants.labelsFilename,
                                                    ofType: DetectorConstants.labelsExtension)
        else {
            self.labelLabel.text = "로컬 모델과 레이블 파일로부터 경로를 얻어내는데 실패했습니다."
            return
        }
        let kr_labelsFilePath = Bundle.main.path(forResource: Constants.labelsFilename_kr,
                                                 ofType: DetectorConstants.labelsExtension)
        
        // 로컬 모델소스
        let localModelSource = LocalModelSource(
            modelName: Constants.quantizedModelFilename,
            path: localModelFilePath
        )
        
        // 모델 매니저 생성
        let modelManager = ModelManager.modelManager()
        // 모델 매니저에 모델소스 등록
        if !modelManager.register(localModelSource) {
            print("Model source was already registered with name: \(localModelSource.modelName).")
        }
        // 클라우드 모델을 사용X, 로컬모델 이름 설정
        let options = ModelOptions(cloudModelName: nil, localModelName: Constants.quantizedModelFilename)
        
        // 모델 불러오기!
        detectorService.loadModel(options: options,
                                  labelsPath: labelsFilePath,
                                  kr_labelsPath: kr_labelsFilePath)
    }
}

// MARK: - Fileprivate

fileprivate enum Constants {
    static let labelsFilename = "labels"
    static let labelsFilename_kr = "labels_kr"
    static let quantizedModelFilename = "mobilenet_quant_v1_224"
    
    
    static let detectionNoResultsMessage = "감지된 결과가 없습니다."
    static let failedToDetectObjectsMessage = "이미지에서 물체를 찾는데 실패했습니다."
    
    static let labelConfidenceThreshold: Float = 0.75
    static let lineWidth: CGFloat = 3.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
}
