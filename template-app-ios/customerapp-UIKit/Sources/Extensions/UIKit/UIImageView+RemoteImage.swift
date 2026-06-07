import UIKit

// MARK: - Image Cache
// Author: - Claude.ai

private final class ImageCache: @unchecked Sendable {

    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL

    private init() {
        // Setup cache limits
        self.cache.countLimit = 100 // Maximum 100 images in memory
        self.cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB memory limit

        // Setup disk cache directory
        let cacheDirectory = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.diskCacheURL = cacheDirectory.appendingPathComponent("RemoteImageCache", isDirectory: true)

        // Create cache directory if needed
        try? self.fileManager.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
    }

    // MARK: - Memory Cache

    func getImage(for url: URL) -> UIImage? {
        return self.cache.object(forKey: url as NSURL)
    }

    func setImage(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
        self.cache.setObject(image, forKey: url as NSURL, cost: cost)
    }

    // MARK: - Disk Cache

    private func diskCacheURL(for url: URL) -> URL {
        let filename = url.absoluteString.data(using: .utf8)!.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
        return self.diskCacheURL.appendingPathComponent(filename)
    }

    func getImageFromDisk(for url: URL) -> UIImage? {
        let fileURL = self.diskCacheURL(for: url)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        // Store in memory cache for faster access next time
        self.setImage(image, for: url)
        return image
    }

    func setImageToDisk(_ image: UIImage, for url: URL) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = self.diskCacheURL(for: url)
        try? data.write(to: fileURL)
    }

    func clearMemoryCache() {
        self.cache.removeAllObjects()
    }

    func clearDiskCache() {
        try? self.fileManager.removeItem(at: self.diskCacheURL)
        try? self.fileManager.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
    }
}

// MARK: - Image Download Task

private final class ImageDownloadTask {

    private var task: Task<UIImage, Error>?

    func load(from url: URL) -> Task<UIImage, Error> {
        if let existingTask = self.task {
            return existingTask
        }

        let newTask = Task<UIImage, Error> {
            // Try memory cache first
            if let cachedImage = ImageCache.shared.getImage(for: url) {
                return cachedImage
            }

            // Try disk cache
            if let diskImage = ImageCache.shared.getImageFromDisk(for: url) {
                return diskImage
            }

            // Download from network
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            // Cache the image
            ImageCache.shared.setImage(image, for: url)
            ImageCache.shared.setImageToDisk(image, for: url)

            return image
        }

        self.task = newTask
        return newTask
    }

    func cancel() {
        self.task?.cancel()
        self.task = nil
    }
}

// MARK: - UIImageView Extension

nonisolated(unsafe) private var downloadTaskKey: UInt8 = 0

extension UIImageView {

    private var downloadTask: ImageDownloadTask? {
        get {
            return objc_getAssociatedObject(self, &downloadTaskKey) as? ImageDownloadTask
        }
        set {
            objc_setAssociatedObject(self, &downloadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Load and display an image from a URL with caching
    /// - Parameters:
    ///   - url: The URL of the image to load
    ///   - placeholder: Optional placeholder image to show while loading
    ///   - transition: Whether to animate the image transition (default: true)
    func setImage(from url: URL?, placeholder: UIImage? = nil, transition: Bool = true) {
        // Cancel any existing download
        self.downloadTask?.cancel()

        // Set placeholder
        if let placeholder = placeholder {
            self.image = placeholder
        }

        guard let url = url else {
            self.image = placeholder
            return
        }

        // Create new download task
        let task = ImageDownloadTask()
        self.downloadTask = task

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            do {
                let image = try await task.load(from: url).value

                // Only update if this is still the current task
                guard self.downloadTask === task else { return }

                if transition {
                    UIView.transition(
                        with: self,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: { self.image = image }
                    )
                } else {
                    self.image = image
                }

                self.downloadTask = nil
            } catch {
                // Only clear if this is still the current task
                guard self.downloadTask === task else { return }

                // Keep placeholder on error
                self.downloadTask = nil
            }
        }
    }

    /// Load and display an image from a URL string with caching
    /// - Parameters:
    ///   - urlString: The URL string of the image to load
    ///   - placeholder: Optional placeholder image to show while loading
    ///   - transition: Whether to animate the image transition (default: true)
    func setImage(from urlString: String?, placeholder: UIImage? = nil, transition: Bool = true) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }

        self.setImage(from: url, placeholder: placeholder, transition: transition)
    }

    /// Cancel any ongoing image download
    func cancelImageLoad() {
        self.downloadTask?.cancel()
        self.downloadTask = nil
    }
}

// MARK: - Cache Management

extension UIImageView {

    /// Clear all cached images from memory
    static func clearMemoryCache() {
        ImageCache.shared.clearMemoryCache()
    }

    /// Clear all cached images from disk
    static func clearDiskCache() {
        ImageCache.shared.clearDiskCache()
    }

    /// Clear all cached images from both memory and disk
    static func clearAllCache() {
        self.clearMemoryCache()
        self.clearDiskCache()
    }
}
