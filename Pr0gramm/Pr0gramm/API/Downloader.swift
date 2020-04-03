
import Foundation

class Downloader {
    /// Downloads a file asynchronously
    func loadFileAsync(url: URL, completion: @escaping (Bool) -> Void) {

        // create your document folder url
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        // your destination file url
        let destination = documentsUrl.appendingPathComponent(url.lastPathComponent)

        print("downloading file from URL: \(url.absoluteString)")
        
        if FileManager().fileExists(atPath: destination.path) {
            print("The file already exists at path, deleting and replacing with latest")

            if FileManager().isDeletableFile(atPath: destination.path){
                do{
                    try FileManager().removeItem(at: destination)
                    print("previous file deleted")
                    self.saveFile(url: url, destination: destination) { (complete) in
                        if complete{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }catch{
                    print("current file could not be deleted")
                }
            }
        // download the data from your url
        } else {
            self.saveFile(url: url, destination: destination) { (complete) in
                if complete{
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }


    func saveFile(url: URL, destination: URL, completion: @escaping (Bool) -> Void){
        URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
            // after downloading your data you need to save it to your destination url
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let location = location, error == nil
                else { print("error with the url response"); completion(false); return}
            do {
                try FileManager.default.moveItem(at: location, to: destination)
                print("new file saved")
                completion(true)
            } catch {
                print("file could not be saved: \(error)")
                completion(false)
            }
        }).resume()
    }
}

extension URL {
    static var documentsDirectory: URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(string: documentsDirectory)!
    }

    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = false ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

extension URL {
    var filesize: Int? {
        let set = Set.init([URLResourceKey.fileSizeKey])
        var filesize: Int?
        do {
            let values = try self.resourceValues(forKeys: set)
            if let theFileSize = values.fileSize {
                filesize = theFileSize
            }
        }
        catch {
            print("Error: \(error)")
        }
        return filesize
    }

    var filesizeNicelyformatted: String? {
        guard let fileSize = self.filesize else {
            return nil
        }
        return ByteCountFormatter.init().string(fromByteCount: Int64(fileSize))
    }
}

extension URL {
    var creationDate: Date {
        return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
    }
}
