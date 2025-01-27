import UIKit

final class ZoomViewController: UIViewController, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    private var firstScrollToTop = false // Flag to track first scroll to top
    private var hasScrolledDown = false // Flag to track if the user has scrolled down by a certain threshold
    
    private let scrollThreshold: CGFloat = 50.0 // Threshold for a "downward scroll" action
    
    init(image: UIImage?) {
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCancelButton()
        setupScrollView()
        setupImageView()
    }
    
    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupScrollView() {
        scrollView.frame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        view.addSubview(scrollView)
    }
    
    private func setupImageView() {
        guard let image = imageView.image else { return }
        
        // Calculate the size for the image view to fill the screen while maintaining aspect ratio
        let imageAspectRatio = image.size.width / image.size.height
        let screenAspectRatio = view.bounds.width / view.bounds.height
        
        var imageViewSize: CGSize
        
        if imageAspectRatio > screenAspectRatio {
            // Image is wider than the screen
            imageViewSize = CGSize(width: view.bounds.width, height: view.bounds.width / imageAspectRatio)
        } else {
            // Image is taller than the screen
            imageViewSize = CGSize(width: view.bounds.height * imageAspectRatio, height: view.bounds.height)
        }
        
        // Set the image view's frame
        imageView.frame = CGRect(origin: .zero, size: imageViewSize)
        imageView.contentMode = .scaleAspectFit
        
        // Add the image view to the scroll view
        scrollView.addSubview(imageView)
        
        // Set the content size of the scroll view to match the image size
        scrollView.contentSize = imageView.frame.size
        
        // Set the initial zoom scale based on the image size
        let scale = min(view.bounds.width / imageView.frame.width, view.bounds.height / imageView.frame.height)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        // Center the image view initially (only once)
        let offsetX = (scrollView.bounds.width - imageView.frame.width) / 2
        let offsetY = (scrollView.bounds.height - imageView.frame.height) / 2
        imageView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        
        imageView.center = CGPoint(x: scrollView.contentSize.width / 2 + offsetX, y: scrollView.contentSize.height / 2 + offsetY)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -75 {
            dismiss(animated: true, completion: nil)
        }
    }

}
