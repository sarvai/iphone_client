//
//  ViewController.swift
//  iPhone Client
//
//  Created by Nick Barkas on 2016-02-06.
//  Copyright © 2016 Sarv AI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var server: CameraServer?

  @IBOutlet weak var urlLabel: UILabel!

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    server = CameraServer()
    urlLabel.text = server!.webServer.serverURL.absoluteString
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

