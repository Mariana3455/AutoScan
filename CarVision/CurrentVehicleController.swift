import UIKit
class CurrentVehicleController: UIViewController {
    @IBOutlet private weak var carImage: UIImageView!
    @IBOutlet private weak var carName: UILabel!
    @IBOutlet private weak var carModel: UILabel!
    @IBOutlet private weak var carTransmission: UILabel!
    @IBOutlet private weak var carNumOfDoors: UILabel!
    @IBOutlet private weak var carBodyType: UILabel!
    @IBOutlet private weak var carPower: UILabel!
    @IBOutlet private weak var saveCarInfoButton: UIButton!
    @IBOutlet weak var viewARButton: UIButton!

    var recognizedCarModel: String?
    var recognizedCarImage: UIImage?
    var carDataParser: CarDataParser?

    override func viewDidLoad() {
        super.viewDidLoad()
        carModel.text = recognizedCarModel
        carImage.image = recognizedCarImage
        viewARButton.layer.cornerRadius = 10
        viewARButton.layer.masksToBounds = true
        setupTapGesture()
        checkIfCarIsSaved()
        
        if let carModel = recognizedCarModel {
            let components = carModel.split(separator: " ")
            if components.count >= 3 {
                let make = String(components[0])
                let model = components.dropFirst().dropLast().joined(separator: " ")
                if let year = Int(components.last!) {
                    carDataParser = CarDataParser(targetMake: make, targetModel: model, targetYear: year)
                    carDataParser?.fetchAndParseCSV()
                    
                    if let carDetails = carDataParser?.carDetails {
                        carName.text = carDetails["Make"]
                        carTransmission.text = carDetails["Transmission Type"]
                        if let numOfDoors = carDetails["Number of Doors"] {
                            carNumOfDoors.text = "Doors: \(numOfDoors)"
                        }
                        carBodyType.text = carDetails["Vehicle Style"]
                        if let power = carDetails["Engine HP"] {
                            carPower.text = "\(power) hp"
                        }
                    } else {
                        print("Car details not found.")
                    }
                } else {
                    print("Invalid year format in recognized car model")
                }
            } else {
                print("Invalid car model format")
            }
        }
    }

    private func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !carImage.frame.contains(location) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let savedCarsVC = storyboard.instantiateViewController(withIdentifier: "SavedCarsViewController") as? SavedCarsViewController {
                navigationController?.pushViewController(savedCarsVC, animated: true)
            }
        }
    }

    @IBAction func saveCarInfoButtonTapped(_ sender: UIButton) {
        guard let carModel = recognizedCarModel, let carImage = recognizedCarImage else { return }
        
        var savedCars = UserDefaults.standard.array(forKey: "savedCars") as? [[String: Any]] ?? []
        
        if let index = savedCars.firstIndex(where: { ($0["model"] as? String) == carModel }) {
            savedCars.remove(at: index)
            UserDefaults.standard.set(savedCars, forKey: "savedCars")
            showAlert(title: "Removed", message: "Car information removed successfully.")
            saveCarInfoButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        } else {
            var carInfo: [String: Any] = ["model": carModel]
            if let imageData = carImage.pngData() {
                carInfo["image"] = imageData
            }
            if let carDetails = carDataParser?.carDetails {
                carInfo["details"] = carDetails
            }
            savedCars.append(carInfo)
                        UserDefaults.standard.set(savedCars, forKey: "savedCars")
                        showAlert(title: "Success", message: "Car information saved successfully.")
                        saveCarInfoButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                    }
                }
                
                @IBAction func viewARButtonTapped(_ sender: Any) {
                       performSegue(withIdentifier: "showARView", sender: self)
                   }
                   
                   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                       if segue.identifier == "showARView" {
                           if let destinationVC = segue.destination as? ARViewController {
                               destinationVC.recognizedCarModel = recognizedCarModel
                               destinationVC.recognizedCarImage = recognizedCarImage
                           }
                       }
                   }

                private func checkIfCarIsSaved() {
                    guard let carModel = recognizedCarModel else { return }
                    
                    let savedCars = UserDefaults.standard.array(forKey: "savedCars") as? [[String: Any]] ?? []
                    
                    if savedCars.contains(where: { ($0["model"] as? String) == carModel }) {
                        saveCarInfoButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                    } else {
                        saveCarInfoButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                    }
                }
                

                
                func showAlert(title: String, message: String) {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

                
            }
