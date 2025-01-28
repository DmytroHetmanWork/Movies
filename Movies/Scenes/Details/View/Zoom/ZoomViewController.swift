import UIKit

final class ZoomViewController: UIViewController, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
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
        
        setupScrollView()
        setupImageView()
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
        
        let imageAspectRatio = image.size.width / image.size.height
        let screenAspectRatio = view.bounds.width / view.bounds.height
        
        var imageViewSize: CGSize
        
        if imageAspectRatio > screenAspectRatio {
            imageViewSize = CGSize(width: view.bounds.width, height: view.bounds.width / imageAspectRatio)
        } else {
            imageViewSize = CGSize(width: view.bounds.height * imageAspectRatio, height: view.bounds.height)
        }
        
        imageView.frame = CGRect(origin: .zero, size: imageViewSize)
        imageView.contentMode = .scaleAspectFit
        
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = imageView.frame.size
        
        let scale = min(view.bounds.width / imageView.frame.width, view.bounds.height / imageView.frame.height)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
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
