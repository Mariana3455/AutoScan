//
//  ARViewController.swift
//  CarVision
//
//  Created by Ira Nazar on 2024-06-22.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var recognizedCarImage: UIImage?
    var recognizedCarModel: String?
    var additionalText: String?
    var carDataParser: CarDataParser?
    
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var carTextLabel: UILabel!
    @IBOutlet weak var addCar: UIButton!
    
    var carNode: SCNNode!
    var wheelNode: SCNNode!
    var windowNode: SCNNode!
    var engineNode: SCNNode!
    var doorNode: SCNNode!
    var lightsNode: SCNNode!
    private var currentModelNode: SCNNode?
    private var currentText: String?
    private var motionManager: CMMotionManager?
    
    
    private var addCarButtonEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupGestureRecognizers()
        resetLabelText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runWorldTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let floorNode = createFloor(for: planeAnchor)
        node.addChildNode(floorNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let floorNode = createFloor(for: planeAnchor)
        node.addChildNode(floorNode)
    }
    
  
    
    private func setupScene() {
        arView.delegate = self
        let scene = SCNScene(named: "scene.scn")!
        arView.scene = scene
    }
    
    private func runWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
    }
    
    // MARK: - Gesture Recognizers
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: arView)
        let hitTestResults = arView.hitTest(tapLocation, options: [:])
        
        guard let hitResult = hitTestResults.first else { return }
        let tappedNode = hitResult.node
        switch tappedNode.name {
        case "wheels":
            handleTapOnWheelsNode()
        case "engine":
            handleTapOnEngineNode()
        case "door":
            handleTapOnDoorNode()
        case "car":
            handleTapOnCarNode()
        default:
            resetLabelText()
        }
        
    }

    
    
    private func resetLabelText() {
            var details = "Tap on the car to get info\n"
            
            if let make = carDataParser?.carDetails?["Make"] {
                details += "Make: \(make)\n"
            } else {
                details += "Make not available\n"
            }
            
            if let popularity = carDataParser?.carDetails?["Popularity"] {
                details += "Popularity: \(popularity)\n"
            } else {
                details += "Popularity not available\n"
            }
            
            if let model = carDataParser?.carDetails?["Model"] {
                details += "Model: \(model)\n"
            } else {
                details += "Model not available\n"
            }
            
            if let year = carDataParser?.carDetails?["Year"] {
                details += "Year: \(year)\n"
            } else {
                details += "Year not available\n"
            }
            
            carTextLabel.text = details.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
    private func updateCarTextLabel(with text: String) {
        carTextLabel.text = text
    }
    @objc private func handleTapOnWheelsNode() {
        if let drivenWheels = carDataParser?.carDetails?["Driven_Wheels"] {
               updateCarTextLabel(with: "Driven Wheels: \(drivenWheels)")
           } else {
               updateCarTextLabel(with: "Driven Wheels not available")
           }
    }
    
    @objc private func handleTapOnCarNode() {
        if let car = carDataParser?.carDetails?["Vehicle Size"] {
            updateCarTextLabel(with: "Car Size: \(car)")
        } else {
            updateCarTextLabel(with: "Car Type not available")
        }
    }
    
//    @objc private func handleTapOnWindowNode() {
//        if let windowType = carDataParser?.carDetails?["Window_Type"] {
//            updateCarTextLabel(with: "Window Type: \(windowType)")
//        } else {
//            updateCarTextLabel(with: "Window Type not available")
//        }
//    }
    
    @objc private func handleTapOnEngineNode() {
        
        
        let details = fetchCarDetails(keys: ["Engine HP", "Engine Cylinders", "Engine Fuel Type","city mpg","highway MPG", "MSRP"])
               updateCarTextLabel(with: details)
    }
    
    @objc private func handleTapOnDoorNode() {
        let details = fetchCarDetails(keys: ["Vehicle Style"])
                updateCarTextLabel(with: details)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let carNode = self.carNode else { return }
        
        let translation = gesture.translation(in: arView)
        let xRotation = Float(translation.y) * (Float.pi / 180.0)
        let yRotation = Float(-translation.x) * (Float.pi / 180.0)
        
        let rotation = SCNAction.rotateBy(x: CGFloat(xRotation), y: CGFloat(yRotation), z: 0, duration: 0.1)
        carNode.runAction(rotation)
        
        gesture.setTranslation(.zero, in: arView)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let carNode = self.carNode else { return }
        
        switch gesture.state {
        case .changed:
            let pinchScaleX = Float(gesture.scale) * carNode.scale.x
            let pinchScaleY = Float(gesture.scale) * carNode.scale.y
            let pinchScaleZ = Float(gesture.scale) * carNode.scale.z
            carNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    private func fetchCarDetails(keys: [String]) -> String {
           var details = ""
           
           for key in keys {
               if let value = carDataParser?.carDetails?[key] {
                   details += "\(key): \(value)\n"
               } else {
                   details += "\(key) not available\n"
               }
           }
           
           return details.trimmingCharacters(in: .whitespacesAndNewlines)
       }
    
    // MARK: - Add Car Button Action
    private func enableAddCarButton() {
        addCar.isEnabled = true
        addCar.alpha = 1.0
        addCar.isHidden = false
        addCarButtonEnabled = true
    }
    
    @IBAction func addCar(_ sender: UIButton) {
        
        guard addCarButtonEnabled else {
            return
        }
        
        guard let pointOfView = arView.pointOfView else { return }
        let transform = pointOfView.transform
        
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43 - 370)
        
        let currentPositionOfCamera = SCNVector3(
            orientation.x + location.x,
            orientation.y + location.y,
            orientation.z + location.z
        )
        
        if let scene = SCNScene(named: "car3.scn") {
            print("Successfully loaded scene 'car2.scn'")
            
            let carContainerNode = SCNNode()
            
            if let carNode = scene.rootNode.childNode(withName: "car", recursively: true) {
                print("Found node with name 'car'")
                carNode.position = currentPositionOfCamera
              
                
                carContainerNode.addChildNode(carNode)
                self.carNode = carNode
                
                if let geometry = carNode.geometry {
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.gray
                    geometry.materials = [material]
                }
                
                if let wheelsNode = scene.rootNode.childNode(withName: "wheels", recursively: true) {
                    print("Found node with name 'wheels'")
                    
                    let rotation = SCNAction.rotateBy(x: .pi / 2, y: 0, z: 0, duration: 0.3)
                    wheelsNode.runAction(rotation)
                    
                    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
                    let moveUpAction = SCNAction.moveBy(x: 0, y: 0, z: -40, duration: 0.5)
                    let sequenceAction = SCNAction.sequence([fadeInAction, moveUpAction])
                    wheelsNode.runAction(sequenceAction)
                    
                    let wheelsPosition = SCNVector3(x: 0, y: 0, z: 0)
                    wheelsNode.position = wheelsPosition
                    
                    if let geometry = wheelsNode.geometry {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.black
                        geometry.materials = [material]
                    }
                    
                    carNode.addChildNode(wheelsNode)
                    self.wheelNode = wheelsNode
                } else {
                    print("Failed to find node with name 'wheels' in scene")
                }
                
                
                
                if let lightsNode = scene.rootNode.childNode(withName: "lights", recursively: true) {
                    print("Found node with name 'lights'")
                    
                    let rotation = SCNAction.rotateBy(x: -.pi/2, y: 0, z: 0, duration: 0.3)
                    lightsNode.runAction(rotation)
                    
                    let lightsPosition = SCNVector3(x: 0, y: 0, z: 0)
                    lightsNode.position = lightsPosition
                    
                    if let geometry = lightsNode.geometry {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.yellow
                        geometry.materials = [material]
                    }
                    
                    carNode.addChildNode(lightsNode)
                    self.wheelNode = lightsNode
                } else {
                    print("Failed to find node with name 'lights' in scene")
                }
                
                
                
                if let windowNode = scene.rootNode.childNode(withName: "window", recursively: true) {
                    print("Found node with name 'window'")
                    let moveDAction = SCNAction.moveBy(x: 0, y: 0, z: -170, duration: 0.5)
                    windowNode.runAction(moveDAction)
                    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
                    let moveUpAction = SCNAction.moveBy(x: 0, y: 0, z: 170, duration: 0.3)
                    let rotation = SCNAction.rotateBy(x: -.pi / 2, y: 0, z: 0, duration: 0.5)
                    let sequenceAction = SCNAction.sequence([fadeInAction, rotation,moveUpAction,])
                    windowNode.runAction(sequenceAction)
                    
                    let windowPosition = SCNVector3(x: 0, y: 0, z: 0)
                    windowNode.position = windowPosition
                    
                    if let geometry = windowNode.geometry {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.blue
                        geometry.materials = [material]
                    }
                    carNode.addChildNode(windowNode)
                } else {
                    print("Failed to find node with name 'window' in scene")
                }
                
                if let engineNode = scene.rootNode.childNode(withName: "engine", recursively: true) {
                    print("Found node with name 'engine'")
                    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
                    let rotation = SCNAction.rotateBy(x: -.pi / 2, y: 0, z: 0, duration: 0.5)
                    let sequenceAction = SCNAction.sequence([fadeInAction, rotation])
                    engineNode.runAction(sequenceAction)
                    
                    let enginePosition = SCNVector3(x: 0, y: 0, z: 0)
                    engineNode.position = enginePosition
                    
                    if let geometry = engineNode.geometry {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.darkGray
                        geometry.materials = [material]
                    }
                    
                    carNode.addChildNode(engineNode)
                } else {
                    print("Failed to find node with name 'engine' in scene")
                }
                
                if let doorNode = scene.rootNode.childNode(withName: "door", recursively: true) {
                    print("Found node with name 'door'")
                    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
                    let rotationAction = SCNAction.rotateTo(x: 0, y: .pi * 2, z: 0, duration: 0.5)
                    let moveUpAction = SCNAction.moveBy(x: 0, y: 0, z: 0, duration: 0.5)
                    let sequenceAction = SCNAction.sequence([fadeInAction, rotationAction, moveUpAction])
                    doorNode.runAction(sequenceAction)
                    
                    if let geometry = doorNode.geometry {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.lightGray
                        geometry.materials = [material]
                    }
                    carNode.addChildNode(doorNode)
                } else {
                    print("Failed to find node with name 'door' in scene")
                }
                
            } else {
                print("Failed to find node with name 'car' in scene")
                return
            }
            
            carContainerNode.position = currentPositionOfCamera
            
            arView.scene.rootNode.addChildNode(carContainerNode)
            
            addCar.isEnabled = false
            addCar.alpha = 0.5
            addCar.isHidden = true
            addCarButtonEnabled = false
        } else {
            print("Failed to load scene 'car2.scn'")
        }
    }
    
    
    // MARK: - Create Floor for Plane Anchor
    
    private func createFloor(for planeAnchor: ARPlaneAnchor) -> SCNNode {
        let floorNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                                   height: CGFloat(CGFloat(planeAnchor.extent.z))))
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.init(white: 0, alpha: 0.1)
        floorNode.geometry?.firstMaterial?.isDoubleSided = true
        floorNode.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z)
        floorNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        floorNode.physicsBody = staticBody
        return floorNode
    }
    
    
}
