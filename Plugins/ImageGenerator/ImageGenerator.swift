//
//  ImageGenerator.swift
//  DesignSystem
//
//  Created by 강동영 on 11/4/25.
//

import PackagePlugin
import Foundation

@main
struct ImageGenerator: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let assetsPath = context.package.directoryURL.appending(path: "Sources/Component/Resources/Image.xcassets")
    let outputPath = context.package.directoryURL.appending(path:"Sources/Component/DesignSystem+Image.swift")
    
    print("💬 Generating images from: \(assetsPath)")
    print("💬 Output to: \(outputPath)")
    
    var generateCode = """
        import Foundation
        import SwiftUI
        
        public extension Image {
        """
    
    let fileManager = FileManager.default
    var imageNames: [String] = []

    func formatImageName(_ name: String) -> String {
      var result = name

      // 1. postfix "Image" 제거 (대소문자 무관)
      if result.lowercased().hasSuffix("image") {
        result = String(result.dropLast(5))
      }

      // 2. 특수문자(공백, -, &, 등)를 기준으로 단어 분리
      let components = result.components(separatedBy: CharacterSet.alphanumerics.inverted)

      // 3. 빈 문자열과 숫자만 있는 컴포넌트 필터링
      let filtered = components.filter { component in
        !component.isEmpty && !component.allSatisfy { $0.isNumber }
      }

      if filtered.isEmpty { return name } // 변환 실패시 원본 반환

      // 4. lowerCamelCase 적용
      let camelCased = filtered.enumerated().map { index, component in
        if index == 0 {
          return component.lowercased()
        } else {
          return component.prefix(1).uppercased() + component.dropFirst().lowercased()
        }
      }.joined()

      return camelCased
    }

    func findImagesets(in directory: String, imageNames: inout [String]) {
      guard let enumerator = fileManager.enumerator(atPath: directory) else { return }

      while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".imageset") {
          let imageName = String(file.dropLast(9)) // ".imageset" 제거
          let cleanName = URL(fileURLWithPath: imageName).lastPathComponent
          imageNames.append(cleanName)
        }
      }
    }
    
    findImagesets(in: assetsPath.path(), imageNames: &imageNames)
    imageNames.sort()

    for imageName in imageNames {
      let formattedName = formatImageName(imageName)
      generateCode += "\n    static let \(formattedName) = Image(\"\(imageName)\", bundle: .module)"
    }
    
    generateCode += "\n}\n"
    
    do {
      try generateCode.write(toFile: outputPath.path(), atomically: true, encoding: .utf8)
      print("✅ Successfully generated DesignSystem+Image.swift with \(imageNames.count) images")
    } catch {
      print("❌ Error writing file: \(error)")
      throw error
    }
  }
}

