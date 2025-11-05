//
//  ColorGenerator.swift
//  Common
//
//  Created by 강동영 on 10/1/25.
//

import PackagePlugin
import Foundation

@main
struct ColorGenerator: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let assetsPath = context.package.directoryURL.appending(path: "Sources/Component/Resources/Color.xcassets")
    let outputPath = context.package.directoryURL.appending(path:"Sources/Component/DesignSystem+Color.swift")
    
    print("💬 Generating colors from: \(assetsPath)")
    print("💬 Output to: \(outputPath)")
    
    var generateCode = """
        import Foundation
        import SwiftUI
        
        public extension Color {
        """
    
    let fileManager = FileManager.default
    var colorNames: [String] = []

    func formatColorName(_ name: String) -> String {
      var result = name

      // 1. postfix "Color" 제거 (대소문자 무관)
      if result.lowercased().hasSuffix("color") {
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

    func findColorsets(in directory: String, colorNames: inout [String]) {
      guard let enumerator = fileManager.enumerator(atPath: directory) else { return }

      while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".colorset") {
          let colorName = String(file.dropLast(9)) // ".colorset" 제거
          let cleanName = URL(fileURLWithPath: colorName).lastPathComponent
          colorNames.append(cleanName)
        }
      }
    }
    
    findColorsets(in: assetsPath.path(), colorNames: &colorNames)
    colorNames.sort()

    for colorName in colorNames {
      let formattedName = formatColorName(colorName)
      generateCode += "\n    static let \(formattedName) = Color(\"\(colorName)\", bundle: .module)"
    }
    
    generateCode += "\n}\n"
    
    do {
      try generateCode.write(toFile: outputPath.path(), atomically: true, encoding: .utf8)
      print("✅ Successfully generated DesignSystem+Color.swift with \(colorNames.count) colors")
    } catch {
      print("❌ Error writing file: \(error)")
      throw error
    }
  }
}
