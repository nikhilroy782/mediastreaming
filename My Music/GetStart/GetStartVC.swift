//
//  GetStartVC.swift
//  My Music
//
//  Created by ICON on 09/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class GetStartVC: UIViewController {
    
    @IBOutlet weak var btnGetStart: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnGetStart.layer.cornerRadius = self.btnGetStart.frame.size.height/2;
        GlobalClass.songTimer.invalidate()
        GlobalClass.homeTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnGetStart_Clicked(_ sender: UIButton) {
        
        UserDefaults.standard.set("1", forKey: GlobalClass.UD_GetStart)
        
        DispatchQueue.main.async {
            let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let leftViewController = self.storyboard?.instantiateViewController(withIdentifier: "SidemenuVC") as! SidemenuVC
            
            let nvc : UINavigationController = UINavigationController(rootViewController: mainViewController)
            nvc.isNavigationBarHidden = true
            
            let slidemenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
            slidemenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.75)
            UIApplication.shared.delegate?.window??.rootViewController = slidemenuController
        }
        self.performSegue(withIdentifier: "moveToHome", sender: self)
    }
    
}
