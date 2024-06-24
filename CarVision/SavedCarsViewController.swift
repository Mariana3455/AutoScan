import UIKit

class SavedCarsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    var savedCars: [(model: String, image: UIImage)] = []
    var currentPage = 0
    let itemsPerPage = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadSavedCars()
    }

    private func loadSavedCars() {
        if let savedCarsArray = UserDefaults.standard.array(forKey: "savedCars") as? [[String: Any]] {
            for carDict in savedCarsArray {
                if let model = carDict["model"] as? String,
                   let imageData = carDict["image"] as? Data,
                   let carImage = UIImage(data: imageData) {
                    savedCars.append((model: model, image: carImage))
                }
            }
        }
        tableView.reloadData()
    }

    private func loadMoreCars() {
        tableView.reloadData()
    }
}

extension SavedCarsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min((currentPage + 1) * itemsPerPage, savedCars.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarInfoTableViewCell", for: indexPath) as? CarInfoTableViewCell else {
            return UITableViewCell()
        }
        let car = savedCars[indexPath.row]
        cell.carModel.text = car.model
        cell.carImg.image = car.image
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            if currentPage * itemsPerPage < savedCars.count {
                currentPage += 1
                loadMoreCars()
            }
        }
    }
}
