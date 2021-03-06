import UIKit
import ZamzamKit
import RealmSwift
import RateLimit

class RealmPostCollectionViewController: UICollectionViewController, CHTCollectionViewDelegateWaterfallLayout, PostControllable {

    var notificationToken: NotificationToken?
    var models: Results<Post>?
    let service = PostService()
    let cellNibName: String? = "PostCollectionViewCell"
    
    lazy var cellWidth: Int = {
        return Int(UIScreen.main.bounds.width / 2.0)
    }()
    
    var indexPathForSelectedItem: IndexPath? {
        return collectionView?.indexPathsForSelectedItems?.first
    }
    
    var termIDs: [Int] = [] {
        didSet {
            applyTerms(for: termIDs)
            didTermsSelect()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didDataControllableLoad()
        setupCollectionView()
        
        if let collectionView = collectionView, traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve latest posts not more than every X hours
        _ = AppGlobal.postRefreshLimit.execute {
            service.updateFromRemote()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(for: segue)
    }
    
    func didTermsSelect() {
    
    }
}

extension RealmPostCollectionViewController {
    
    func setupCollectionView() {
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Collection view attributes
        collectionView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView?.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        collectionView?.collectionViewLayout = layout
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView[indexPath] as! PostCollectionViewCell
        guard let model = models?[indexPath.row] else { return cell }
        return cell.bind(model)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        // Determine dynamic size
        guard let model = models?[indexPath.row], let media = model.media, !media.link.isEmpty && media.width > 0 && media.height > 0 else {
            // Placeholder image size if no image found
            return CGSize(width: cellWidth, height: 189)
        }
        
        let height = Int((Float(media.height) * Float(cellWidth) / Float(media.width)) + 48)
        return CGSize(width: cellWidth, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: PostDetailViewController.segueIdentifier, sender: nil)
    }
}

// MARK: - Add 3D Peek and Pop for posts
extension RealmPostCollectionViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location),
            let cell = collectionView?.cellForItem(at: indexPath),
            let model = models?[indexPath.row],
            let controller: PostPreviewViewController = UIStoryboard(for: .PostPreview, with: AppConstants.bundle).instantiateViewController()
                else { return nil }
        
        previewingContext.sourceRect = cell.frame
        
        controller.model = model
        controller.delegate = self
        
        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let sourceController = viewControllerToCommit as? PostPreviewViewController,
            let destinationController: PostDetailViewController = UIStoryboard(for: .PostDetail, with: AppConstants.bundle).instantiateViewController()
                else { return }
        
        destinationController.model = sourceController.model
        show(destinationController, sender: self)
    }
}
