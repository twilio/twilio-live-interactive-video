//
//  Copyright (C) 2020 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TwilioVideo

struct CameraConfig {
    let outputFormat: VideoFormat
    let inputFormat: VideoFormat
}

class CameraConfigFactory {
    func makeCameraConfigFactory(captureDevice: AVCaptureDevice) -> CameraConfig {
        var targetSize: CMVideoDimensions {
            // 640 x 480 squarish crop (1.13:1)
            return CMVideoDimensions(width: 544, height: 480)
        }
        var frameRate: UInt {
            return 24 // With simulcast enabled there are 3 temporal layers, allowing a frame rate of {f, f/2, f/4}
        }
        let cropRatio = CGFloat(targetSize.width) / CGFloat(targetSize.height)
        let preferredFormat = selectVideoFormatBySize(captureDevice: captureDevice, targetSize: targetSize)
        preferredFormat.frameRate = min(preferredFormat.frameRate, frameRate)
        
        let cropDimensions: CMVideoDimensions
        
        if preferredFormat.dimensions.width > preferredFormat.dimensions.height {
            cropDimensions = CMVideoDimensions(
                width: Int32(CGFloat(preferredFormat.dimensions.height) * cropRatio),
                height: preferredFormat.dimensions.height
            )
        } else {
            cropDimensions = CMVideoDimensions(
                width: preferredFormat.dimensions.width,
                height: Int32(CGFloat(preferredFormat.dimensions.width) * cropRatio)
            )
        }
        
        let outputFormat = VideoFormat()
        outputFormat.dimensions = cropDimensions
        outputFormat.pixelFormat = preferredFormat.pixelFormat
        outputFormat.frameRate = 0

        return CameraConfig(outputFormat: outputFormat, inputFormat: preferredFormat)
    }
    
    private func selectVideoFormatBySize(captureDevice: AVCaptureDevice, targetSize: CMVideoDimensions) -> VideoFormat {
        let supportedFormats = Array(CameraSource.supportedFormats(captureDevice: captureDevice)) as! [VideoFormat]
        
        // Cropping might be used if there is not an exact match
        for format in supportedFormats {
            guard
                format.pixelFormat == .formatYUV420BiPlanarFullRange &&
                    format.dimensions.width >= targetSize.width &&
                    format.dimensions.height >= targetSize.height
                else {
                    continue
            }
            
            return format
        }
        
        fatalError()
    }
}
