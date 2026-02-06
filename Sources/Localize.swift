//
//  Localize.swift
//  xcloc-translator
//
//  Created by Daniel Bedrich on 01.02.26.
//

import Foundation
import ArgumentParser
import SwiftyXML

let UNSUPPORTED_DEEPL_LANGUAGES = [
    "zh-HK"
]

@main
struct Localize: AsyncParsableCommand {
    @Argument(help: "The path to the folder where the '.xcloc' files are.")
    var localizationsPath: String

    mutating func run() async throws {
        let filemanager = FileManager.default
        let filesAtPath = filemanager.subpaths(atPath: localizationsPath)
        let xliff = filesAtPath?.filter { $0.contains(".xliff")  }
        
        for file in xliff ?? [] {
            let url = URL(string: "file://\(localizationsPath)/\(file)")
            guard let url else { Localize.exit() }
            
            let fileName = url.lastPathComponent
            print("🌐 Localizing '\(fileName)'...")
            
            let xml = try XML(url: url)
            
            for file in xml.file {
                let targetLanguage = file.xmlAttributes["target-language"]
                let sourceLanguage = file.xmlAttributes["source-language"]
                
                guard let targetLanguage, let sourceLanguage else {
                    print("Could not fine target or source language. Skipping...")
                    continue
                }
                
                for body in file.body {
                    for transUnit in body.xmlChildren {
                        let sourceText = transUnit.source.xml?.xmlValue
                        let target = transUnit.target.xml
                        
                        guard let sourceText else { continue }
                        
                        if target != nil { continue }
                        
                        if UNSUPPORTED_DEEPL_LANGUAGES.contains(targetLanguage) {
                            print("Language '\(targetLanguage)' not supported by DeepL. Skipping...")
                            continue
                        }
                        
                        let params = [
                            "text": [sourceText],
                            "target_lang": targetLanguage,
                            "source_lang": sourceLanguage
                        ] as [String : Any]

                        var request = URLRequest(url: URL(string: "https://api-free.deepl.com/v2/translate")!)
                        request.httpMethod = "POST"
                        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                        request.addValue("DeepL-Auth-Key \(API_KEY)", forHTTPHeaderField: "Authorization")
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                        try await Task.sleep(for: .seconds(0.35))
                        
                        let (data, _) = try await URLSession.shared.data(for: request)
                        let fetchedData = try JSONDecoder().decode(DeepLResponse.self, from: data)
                        
                        let targetXml = XML(name: "target", attributes: [
                            "state": "translated"
                        ], value: fetchedData.translations[0].text)

                        transUnit.addChild(targetXml)
                    }
                }
            }
            
            let xmlData = xml.toXMLString().data(using: .utf8)
            let outputFolder = "\(localizationsPath)/outputs"
            let outputPath = "\(outputFolder)/\(fileName)"
            
            if !filemanager.fileExists(atPath: outputPath) {
                try filemanager.createDirectory(atPath: outputFolder, withIntermediateDirectories: true)
            }
            filemanager.createFile(atPath: outputPath, contents: xmlData)
        }
    }
}
