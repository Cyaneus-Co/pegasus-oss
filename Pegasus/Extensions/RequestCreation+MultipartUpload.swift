import Siesta
import Foundation

extension Resource {
    /**
     Convenience method to initiate a request using multipart encoding in the message body.
     
     Based on code suggested by @Alex293 in https://github.com/bustoutsolutions/siesta/issues/190
     
     This convenience method just structures @Alex293’s example in a way that parallels the other convenience
     methods in this extension.
     
     The parameters have the following meanings:
     - values: [String:String] listing the names of various parts and their corresponding values
     - files: optional [String:FilePart] listing the the names of _files_ to upload, with the files represented via a helper FilePart struct (defined at the bottom of this source file)
     - order: optional [String] containing the keys from `values` and `files`—this comes into play if the server or service that accepts multipart requests also requires the parts in a particular order (e.g., S3 wants the `key` part first). The `order` array specifies the order to how the parts are sent. If `order` is not given, then the parts are enumerated in the order that Swift enumerates the keys of the `values` and `files` dictionaries (`values` enumerated first, then `files`)
     - requestMutation: same closure as in the other convenience methods
     */
    public func request(
        _ method: RequestMethod,
        multipart values: [String:String],
        files: [String:FilePart]?,
        order: [String]?,
        requestMutation: @escaping RequestMutation = { _ in })
    -> Request {
        func getNames() -> [String] {
            if let givenOrder = order {
                return givenOrder
            }
            var names = Array(values.keys)
            if files != nil {
                names.append(contentsOf: files!.keys)
            }
            return names
        }
        func append(_ body: NSMutableData, _ line: String)  {
            body.append(line.data(using: .utf8)!)
        }
        // Derived from https://github.com/bustoutsolutions/siesta/issues/190#issuecomment-294267686
        let boundary = "Boundary-\(NSUUID().uuidString)"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        let body = NSMutableData()
        let names = getNames()
        names.forEach { name in
            append(body, "--\(boundary)\r\n")
            if values.keys.contains(name), let value = values[name] {
                append(body, "Content-Disposition:form-data; name=\"\(name)\"\r\n\r\n")
                append(body, "\(value)\r\n")
            }
            else if let givenFiles = files, givenFiles.keys.contains(name), let filePart = givenFiles[name]{
                append(body, "Content-Disposition:form-data; name=\"\(name)\"; filename=\"\(filePart.filename)\"\r\n")
                append(body, "Content-Type: \(filePart.type)\r\n\r\n")
                body.append(filePart.data)
                append(body, "\r\n")
            }
        }
        append(body, "--\(boundary)--\r\n")
        return request(method, data: body as Data, contentType: contentType, requestMutation: requestMutation)
    }
}
public struct FilePart {
    let filename: String
    let type: String
    let data: Data
    init(filename: String, type: String, data: Data) {
        self.filename = filename
        self.type = type
        self.data = data
    }
}
