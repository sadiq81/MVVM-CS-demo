//
//  ValidateConfigs.swift
//  loyaltyapp
//
//  Created by Tommy Sadiq Hinrichsen on 08/12/2022.
//  Copyright © 2022 Dagrofa. All rights reserved.
//

import Foundation

@main
enum ValidateConfigsScript {

    static func main() {

        guard let projectDirectoy = ProcessInfo.processInfo.environment["PROJECT_DIR"] else { return }
        let path = "\(projectDirectoy)/customerapp/Resources/Config/"
        let url = URL(fileURLWithPath: path)

        var files = [URL]()
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return }
        for case let fileURL as URL in enumerator {
            guard (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false else { continue }
            guard fileURL.pathExtension == "xcconfig" else { continue }
            files.append(fileURL)

        }

        for file in files {
            guard let content = try? String(contentsOfFile: file.path, encoding: .utf8) else { return }
            let lines = content.components(separatedBy: "\n").dropFirst()
            let string = String(lines.joined())

            let range = NSRange(location: 0, length: string.utf8.count)

            guard let regex = try? NSRegularExpression(pattern: "key|secret|token|salt", options: [.caseInsensitive]) else { return }
            let match = regex.firstMatch(in: string, options: [], range: range)
            if match != nil { fatalError("\(file) contain illegal keys") }

        }
    }

}
