//
//  ViewController+ARSCNViewDelegate.swift
//

import UIKit
import SceneKit
import ARKit

extension ViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        // Delegate rendering tasks to our `updateQueue` thread to keep things thread-safe!
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height

            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)

            // This bit is important. It helps us create occlusion so virtual things stay hidden behind the detected image
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha

            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1

            // Add the plane visualization to the scene
            node.addChildNode(mainNode)

            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {

                // Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth, refImage: imageAnchor.referenceImage)

                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth, refImage: imageAnchor.referenceImage)

            })
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - SceneKit Helpers
    
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat, refImage: ARReferenceImage) {
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25

        let detailNode = SCNNode(geometry: detailPlane)
        switch refImage.name {
        case "spain":
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "spain-sks")
            
        case "usa":
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "english-sks")

        case "germany":
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "german-sks")

        case "italy":
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "italian-sks")

        case "france":
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "french-sks")
        
        default:
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "spain-sks")
        }
        
        

        // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
        detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        detailNode.position.z -= 0.5
        detailNode.opacity = 0

        rootNode.addChildNode(detailNode)
        detailNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * -1.1, y: 0, z: -0.05, duration: 1.5),
            .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
            ])
        )
    }
    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat, refImage: ARReferenceImage) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            
            
            var request = URLRequest(url: URL(string: "https://www.inc.com/quora/feeling-lost-in-life-its-a-sign-you-might-be-better-off-than-you-think.html")!)
            switch refImage.name {
            case "spain":
                let theURLString = "https://youtu.be/kS9RTqlOqVc"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)
                
            case "usa":
                let theURLString = "https://youtu.be/IL1n6LuUIcQ"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)

            case "germany":
                let theURLString = "https://youtu.be/wjVCBewCOgg"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)

            case "italy":
                let theURLString = "https://es.wikipedia.org/wiki/Alessi"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)

            case "france":
                let theURLString = "https://www.disup.com/clasicos-juicy-salif-de-philippe-starck/"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)
                
            default:
                let theURLString = "https://es.wikipedia.org/wiki/Diseñador"
                guard let formatted = theURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { preconditionFailure("CAN'T FORMAT URL") }
                let url = URL(string: formatted)
                guard let urlFormatted = url else { preconditionFailure("CAN'T FORMAT URL") }
                request = URLRequest(url: urlFormatted)
            }
            
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
            webView.allowsInlineMediaPlayback = false
            webView.mediaPlaybackRequiresUserAction = true
            webView.loadRequest(request)

            let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
            webViewPlane.cornerRadius = 0.25

            let webViewNode = SCNNode(geometry: webViewPlane)

            // Set the web view as webViewPlane's primary texture
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0

            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
}
