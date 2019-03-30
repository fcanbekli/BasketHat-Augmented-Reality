//
//  ViewController.swift
//  BasketHat
//
//  Created by Fatih Canbekli on 30.03.2019.
//  Copyright © 2019 Fatih Canbekli. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
  
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        sceneView.session.run(configuration)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let results = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        
        if let result = results.first {
            PlaceModel(result)
        }
    }
    
    
    func CreateModel(_ position: SCNVector3) -> SCNNode? {
        guard let modelUrl = Bundle.main.url(forResource: "Models.scnassets/cardbox", withExtension: "obj") else{
            NSLog("Cardboard could not found")
            return nil
        }
        guard let node = SCNReferenceNode(url: modelUrl) else {return nil}
        
        node.load()
        
        node.position = position
        
        return node;
    }
    
    func PlaceModel(_ result: ARHitTestResult){
        let transform = result.worldTransform
        
        let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        let modelNode = CreateModel(planePosition)
        sceneView.scene.rootNode.addChildNode(modelNode!)
    }
    private var planeNode: SCNNode?
  

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let _ = anchor as? ARPlaneAnchor else {
            return nil
        }
        planeNode = SCNNode()
        return planeNode
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        plane.materials = [planeMaterial]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        node.addChildNode(planeNode)
        
    }
    

}


