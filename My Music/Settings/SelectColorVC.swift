//
//  SelectColorVC.swift
//  My Music
//
//  Created by ICON on 07/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

protocol SelectColorVCDelegate {
    func setSelectedColor(isComeFrom:String)
}

class SelectColorVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection_Color: UICollectionView!
    
    var delegate : SelectColorVCDelegate!
    
    var colorArr : [String] = ["#F23A2FFF","#E61B58FF","#9123A6FF","#5C33AEFF","#3748ACFF","#1D8DF1FF","#00A9F2FF","#00B3CEFF","#008B7DFF","#43A547FF","#80BB41FF","#C6D732FF","#FFE734FF","#FFB80BFF","#FF8D02FF","#FF4C1FFF","#6E4B3FFF","#939393FF","#557280FF"]
    
    @IBOutlet weak var view_mainContainer: UIView!
    @IBOutlet weak var view_calculateColor: UIView!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var lblAlpha_value: UILabel!
    @IBOutlet weak var lblRed_value: UILabel!
    @IBOutlet weak var lblGreen_value: UILabel!
    @IBOutlet weak var lblBlue_value: UILabel!
    @IBOutlet weak var lblColorSelected: UILabel!
    @IBOutlet weak var btnChangeType: UIButton!
    @IBOutlet weak var lblTitle_type: UILabel!
    @IBOutlet weak var view_customColor: UIView!
    @IBOutlet weak var view_presetColor: UIView!
    
    var isComeFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view_mainContainer.layer.cornerRadius = 10.0
        self.collection_Color.delegate = self
        self.collection_Color.dataSource = self
        
        if self.isComeFrom == "Primary" {
            self.lblColorSelected.text = "#FF0000FF"
            self.alphaSlider.value = 255.0
            self.redSlider.value = 255.0
            self.greenSlider.value = 0.0
            self.blueSlider.value = 0.0
        }
        else if self.isComeFrom == "Accent" {
            self.lblColorSelected.text = "#000000FF"
            self.alphaSlider.value = 255.0
            self.redSlider.value = 0.0
            self.greenSlider.value = 0.0
            self.blueSlider.value = 0.0
            self.lblRed_value.text = "0"
            self.view_calculateColor.backgroundColor = UIColor.black
            self.alphaSlider.minimumTrackTintColor = UIColor.black
            self.alphaSlider.thumbTintColor = UIColor.black
            self.redSlider.thumbTintColor = UIColor.black
            self.greenSlider.thumbTintColor = UIColor.black
            self.blueSlider.thumbTintColor = UIColor.black
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnChangeType_Clicked(_ sender: UIButton) {
        if self.btnChangeType.titleLabel?.text == "CUSTOM" {
            self.view_customColor.isHidden = false
            self.view_presetColor.isHidden = true
            self.lblTitle_type.text = "Custom"
            self.btnChangeType.setTitle("PRESETS", for: .normal)
        }
        else if self.btnChangeType.titleLabel?.text == "PRESETS" {
            self.view_customColor.isHidden = true
            self.view_presetColor.isHidden = false
            self.lblTitle_type.text = "Presets"
            self.btnChangeType.setTitle("CUSTOM", for: .normal)
        }
    }
    
    @IBAction func btnDone_Clicked(_ sender: UIButton) {
        if self.isComeFrom == "Primary" {
            if self.lblTitle_type.text == "Presets" {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.setSelectedColor(isComeFrom: self.isComeFrom)
                    }
                }
            }
            else if self.lblTitle_type.text == "Custom" {
                UserDefaults.standard.set(self.lblColorSelected.text, forKey: GlobalClass.UD_PrimaryColor)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.setSelectedColor(isComeFrom: self.isComeFrom)
                    }
                }
            }
        }
        else if self.isComeFrom == "Accent" {
            if self.lblTitle_type.text == "Presets" {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.setSelectedColor(isComeFrom: self.isComeFrom)
                    }
                }
            }
            else if self.lblTitle_type.text == "Custom" {
                UserDefaults.standard.set(self.lblColorSelected.text, forKey: GlobalClass.UD_AccentColor)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.setSelectedColor(isComeFrom: self.isComeFrom)
                    }
                }
            }
        }
    }
    
    @IBAction func btnCancel_Clicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 19
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56.5, height: 56.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_Color.dequeueReusableCell(withReuseIdentifier: "cellColor", for: indexPath) as! ColorCell
        cell.backgroundColor = UIColor(hexString: self.colorArr[indexPath.row])
        cell.layer.cornerRadius = cell.bounds.height/2
        
        if self.isComeFrom == "Primary" {
            if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) != nil && UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String == self.colorArr[indexPath.row] {
                cell.img_selected.isHidden = false
            }
            else {
                cell.img_selected.isHidden = true
            }
        }
        else if self.isComeFrom == "Accent" {
            if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) != nil && UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String == self.colorArr[indexPath.row] {
                cell.img_selected.isHidden = false
            }
            else {
                cell.img_selected.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isComeFrom == "Primary" {
            UserDefaults.standard.set(self.colorArr[indexPath.row], forKey: GlobalClass.UD_PrimaryColor)
        }
        else if self.isComeFrom == "Accent" {
            UserDefaults.standard.set(self.colorArr[indexPath.row], forKey: GlobalClass.UD_AccentColor)
        }
        self.collection_Color.reloadData()
    }
    
    @IBAction func alpha_changed(_ sender: UISlider) {
        DispatchQueue.main.async {
            let alphaValue = Int(self.alphaSlider.value)
            self.lblAlpha_value.text = String(describing: alphaValue)
            let hexValue = "#" + String(format:"%02X", Int(self.lblRed_value.text!)!) + String(format:"%02X", Int(self.lblGreen_value.text!)!) + String(format:"%02X", Int(self.lblBlue_value.text!)!) + String(format:"%02X", Int(self.lblAlpha_value.text!)!)
            self.lblColorSelected.text = hexValue
            
            self.view_calculateColor.backgroundColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            if self.lblAlpha_value.text == "0" {
                self.alphaSlider.tintColor = UIColor(red: 240/255, green: 240/255, blue: 245/255, alpha: 1.0)
            }
        }
    }
    
    @IBAction func red_changed(_ sender: UISlider) {
        DispatchQueue.main.async {
            let redValue = Int(self.redSlider.value)
            self.lblRed_value.text = String(describing: redValue)
            let hexValue = "#" + String(format:"%02X", Int(self.lblRed_value.text!)!) + String(format:"%02X", Int(self.lblGreen_value.text!)!) + String(format:"%02X", Int(self.lblBlue_value.text!)!) + String(format:"%02X", Int(self.lblAlpha_value.text!)!)
            self.lblColorSelected.text = hexValue
            
            self.view_calculateColor.backgroundColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
        }
    }
    
    @IBAction func green_changed(_ sender: UISlider) {
        DispatchQueue.main.async {
            let greenValue = Int(self.greenSlider.value)
            self.lblGreen_value.text = String(describing: greenValue)
            let hexValue = "#" + String(format:"%02X", Int(self.lblRed_value.text!)!) + String(format:"%02X", Int(self.lblGreen_value.text!)!) + String(format:"%02X", Int(self.lblBlue_value.text!)!) + String(format:"%02X", Int(self.lblAlpha_value.text!)!)
            self.lblColorSelected.text = hexValue
            
            self.view_calculateColor.backgroundColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
        }
    }
    
    @IBAction func blue_changed(_ sender: UISlider) {
        DispatchQueue.main.async {
            let blueValue = Int(self.blueSlider.value)
            self.lblBlue_value.text = String(describing: blueValue)
            let hexValue = "#" + String(format:"%02X", Int(self.lblRed_value.text!)!) + String(format:"%02X", Int(self.lblGreen_value.text!)!) + String(format:"%02X", Int(self.lblBlue_value.text!)!) + String(format:"%02X", Int(self.lblAlpha_value.text!)!)
            self.lblColorSelected.text = hexValue
            
            self.view_calculateColor.backgroundColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.minimumTrackTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            
            self.alphaSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.redSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.blueSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
            self.greenSlider.thumbTintColor = UIColor(red: CGFloat(self.redSlider.value/255.0), green: CGFloat(self.greenSlider.value/255.0), blue: CGFloat(self.blueSlider.value/255.0), alpha: CGFloat(self.alphaSlider.value/255.0))
        }
    }
    
}
