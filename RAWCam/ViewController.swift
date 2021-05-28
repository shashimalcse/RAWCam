//
//  ViewController.swift
//  RAWCam
//
//  Created by thilina shashimal senarath on 5/28/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession:AVCaptureSession!
    var captureOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice =  AVCaptureDevice.default(for: .video)
    
    private var isoValues = [50,100,200,300,400,600,800,1600]
    private let isoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let shutterButton:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        return button
    }()
    
    private let isoButton:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.yellow.cgColor
        button.layer.masksToBounds = true
        button.setTitle("ISO", for: UIControl.State.normal)
        button.titleLabel!.font =  UIFont(name: "Helvetica-Bold", size: 10)
        button.setTitleColor(UIColor.yellow, for: UIControl.State.normal)
        return button
    }()
    
    private let imagePreviewView:UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
        
    private let bottomView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.3
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(bottomView)
        view.addSubview(shutterButton)
        view.addSubview(isoButton)
        view.addSubview(imagePreviewView)
 
        checkPermission()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        isoCollectionView.register(ISOCollectionViewCell.self, forCellWithReuseIdentifier: ISOCollectionViewCell.identifier)
        isoCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        isoCollectionView.showsHorizontalScrollIndicator = false
        isoCollectionView.showsVerticalScrollIndicator = false
        isoCollectionView.dataSource = self
        isoCollectionView.delegate = self
        isoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(isoCollectionView)
        setISOGridView()

        
    }
    func setISOGridView(){
        let flow = isoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.scrollDirection = .horizontal
        let space = CGFloat(10)
        flow.minimumLineSpacing = space
        flow.sectionInset.bottom = space
        flow.sectionInset.top = space
        flow.sectionInset.left = space
        flow.sectionInset.right = space
    }
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        
        captureDevice!.setExposureModeCustom(duration: CMTime(seconds: 1/30, preferredTimescale: 30), iso: sender.value, completionHandler: nil)
        
    }
    @objc private func didTapTakePhoto(){
        captureOutput.capturePhoto(with: AVCapturePhotoSettings() ,delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        bottomView.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        bottomView.center = CGPoint(x: view.frame.width/2, y: view.frame.height-50)
        shutterButton.center = CGPoint(x: view.frame.width/2, y: view.frame.height-50)
        isoButton.center = CGPoint(x: view.frame.width-50, y: view.frame.height-50)
        imagePreviewView.translatesAutoresizingMaskIntoConstraints = false
        imagePreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: CGFloat(-10)).isActive = true
        imagePreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(10)).isActive = true
        imagePreviewView.widthAnchor.constraint(equalToConstant: CGFloat(70)).isActive = true
        imagePreviewView.heightAnchor.constraint(equalToConstant: CGFloat(70)).isActive = true
        NSLayoutConstraint.activate([
            isoCollectionView.bottomAnchor.constraint(equalTo: self.bottomView.topAnchor),
            isoCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            isoCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            isoCollectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            isoCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])

        
    }
    
    func checkPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {granted in
                guard granted else{
                    return
                }
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    func setupCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(captureOutput){
                    session.addOutput(captureOutput )
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                try device.lockForConfiguration()
                print(device.exposureDuration)
                print(device.activeFormat.maxExposureDuration)
                print(device.activeFormat.minISO)
                print(device.activeFormat.maxISO)
                let minIS0 = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                updateISOValues(min: minIS0, max: maxISO)
                self.captureDevice = device
                session.startRunning()
                self.captureSession = session
            }
            catch{
                print(error)
            }
        }
        
        
        
    }
    
    func updateISOValues(min:Float,max:Float){
        isoValues = isoValues.filter{ value in
            if(value>=Int(min) && value<=Int(max)){
                return true
            }
            return false
        }
        isoCollectionView.reloadData()
    }


}

extension ViewController : AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        self.imagePreviewView.image = image
    }
}
extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isoValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = isoCollectionView.dequeueReusableCell(withReuseIdentifier: ISOCollectionViewCell.identifier, for: indexPath) as! ISOCollectionViewCell
        cell.setValue(value: isoValues[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50,height: 30)
    }
    

}

