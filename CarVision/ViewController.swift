import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var squareView: UIView!
    @IBOutlet private weak var squareWhiteView: UIView!
    @IBOutlet private weak var getStartedButton: UIButton!
    @IBOutlet private weak var carImage: UIImageView!
    @IBOutlet private weak var carName: UILabel!

    var recognizedCarModel: String?
    var recognizedCarImage: UIImage?
    var carDataParser: CarDataParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        displayDefaultCarDetails()
        
    }
    
    private func setupUI() {
        squareView.layer.cornerRadius = 30
        squareView.layer.masksToBounds = true
        let path = UIBezierPath(roundedRect: squareWhiteView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 30, height: 30))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        squareWhiteView.layer.mask = mask
        getStartedButton.layer.cornerRadius = 15
        getStartedButton.layer.masksToBounds = true
    }
    
    private func displayDefaultCarDetails() {
        carName.text = "Audi A7 2010"
        carImage.image = UIImage(named: "audi_a7.jpeg")
    }
    
}
