//
//  ViewController.swift
//  SwiftScale
//
//  Created by Mo DeJong on 10/20/16.
//  Copyright © 2016 HelpURock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var imageView : UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    assert(self.imageView != nil)

#if PNGSQUARED
    let nc = NotificationCenter.default
    nc.addObserver(forName:Notification.Name(rawValue:UIImagePNGSquaredAllReadyNotification),
                   object:nil,
                   queue:nil) {
                    notification in
                    self.allReadyNotification()
  }
#endif
  }

  func allReadyNotification()
  {
#if PNGSQUARED
    let image = UIImage(named: "one")
    self.imageView.image = image
#endif
    return;
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

