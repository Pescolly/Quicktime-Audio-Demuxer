//
//  AudioFileExporter.swift
//  QuicktimeAudioDemuxer_Swift
//
//  Created by Armen Karamian on 4/15/16.
//  Copyright © 2016 Armen Karamian. All rights reserved.
//

import Foundation
import AVFoundation

class AudioFileExporter
{
	func exportStereoPair(audioTrack1:AVAssetTrack, audioTrack2:AVAssetTrack, audioTrackName:String)
	{
		print("Exporting",audioTrackName)
	}
	
	func exportSingleStem(audioTrack:AVAssetTrack, audioTrackName:String)
	{
		print("Exporting",audioTrackName)
	}
}