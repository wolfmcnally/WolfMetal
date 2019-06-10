//
//  MetalTextureUtils.swift
//  WolfMetal
//
//  Created by Wolf McNally on 8/5/17.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Metal
import CoreGraphics

extension MTLTexture {
    func makeImage() -> CGImage {
        assert(textureType == .type2D)

        let bitsPerComponent = 8
        let componentsPerPixel = 4
        let pixelBytesAlignment = 4

        let bitsPerPixel = bitsPerComponent * componentsPerPixel
        let bytesPerPixel = bitsPerPixel / bitsPerComponent

        let bytesPerRow = width * bytesPerPixel
        let pixelBytesCount = bytesPerRow * height

        let pixelBytes = UnsafeMutableRawPointer.allocate(byteCount: pixelBytesCount, alignment: pixelBytesAlignment)
        defer { pixelBytes.deallocate() }

        let region = MTLRegionMake2D(0, 0, width, height)
        getBytes(pixelBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

        let pixelData = Data(bytes: pixelBytes, count: pixelBytesCount)
        let provider = CGDataProvider(data: pixelData as CFData)!

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let image = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!

        return image
    }
}
