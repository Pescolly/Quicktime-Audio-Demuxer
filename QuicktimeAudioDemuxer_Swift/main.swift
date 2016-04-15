//
//  main.swift
//  QuicktimeAudioDemuxer_Swift
//
//  Created by Armen Karamian on 4/15/16.
//  Copyright © 2016 Armen Karamian. All rights reserved.
//

import Foundation
import AVFoundation

//get input info
let inputFile = Process.arguments[1]
let inputFileURL = NSURL(fileURLWithPath: inputFile)

//create asset
let qtAsset = AVAsset(URL: inputFileURL)

//get tracks
let qtAudioTracks = qtAsset.tracksWithMediaType(AVMediaTypeAudio)

//determine number of tracks
let audioTrackCount = qtAudioTracks.count

let audioFileExporter = AudioFileExporter()

switch audioTrackCount
{
	case 2:
		audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairOne")
	
	case 4:
		audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairOne")
		audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairTwo")
	
	default:
		for i in 0...5
		{
			audioFileExporter.exportSingleStem(qtAudioTracks[i], audioTrackName: String(i+1))
		}
		
		for var i=6; i < audioTrackCount-1; i += 2
		{
			audioFileExporter.exportStereoPair(qtAudioTracks[i], audioTrack2: qtAudioTracks[i+1], audioTrackName: String(i+1)+"_"+String(i+2))
		}
}

//loop thru tracks
//export on seperate thread
