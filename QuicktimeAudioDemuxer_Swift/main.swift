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

//get path of export directory and append new stems folder
var exportDirectory = inputFileURL.URLByDeletingLastPathComponent
exportDirectory = exportDirectory?.URLByAppendingPathComponent("AUDIO_STEMS")

//create export path if it does not exist
let fm = NSFileManager.defaultManager()

if !fm.fileExistsAtPath(exportDirectory!.path!)
{
	do
	{
		print("creating direcotry at", exportDirectory!.path)
		try fm.createDirectoryAtURL(exportDirectory!, withIntermediateDirectories: false, attributes: nil)
	}
	catch
	{
		print("Cannot create directory at ",exportDirectory!.path)
	}
}


//create asset
let qtAsset = AVAsset(URL: inputFileURL)

//get tracks
let qtAudioTracks = qtAsset.tracksWithMediaType(AVMediaTypeAudio)

//determine number of tracks
let audioTrackCount = qtAudioTracks.count

let audioFileExporter = AudioFileExporter(inExportDirectory: exportDirectory!)

//dispatch group for track export threads
let trackGroup = dispatch_group_create();
let trackQ = dispatch_queue_create("com.mvf.trackexportq", DISPATCH_QUEUE_CONCURRENT);

switch audioTrackCount
{
	case 2:
		audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairOne")
	
	case 4:
		//assign each track to a async thread in the track export dispatch group.
		dispatch_group_async(trackGroup, trackQ,
			{
				//start async dispatch
				audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairOne")
			})

		dispatch_group_async(trackGroup, trackQ,
			{
				//start async dispatch
				audioFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: "AudioPairTwo")
			})
	
	default:
		for i in 0...5
		{
			dispatch_group_async(trackGroup, trackQ,
			{
				audioFileExporter.exportSingleStem(qtAudioTracks[i], audioTrackName: String(i+1))
			})
		}
		
		for var index = 6; index <= audioTrackCount-2; index += 2
		{
			if (index >= audioTrackCount)
			{
				break
			}
			dispatch_group_async(trackGroup, trackQ,
			{
				audioFileExporter.exportStereoPair(qtAudioTracks[index], audioTrack2: qtAudioTracks[index+1], audioTrackName: String(index+1)+"_"+String(index+2))
			})
		}
}

//wait for all async threads to finish
dispatch_group_wait(trackGroup, DISPATCH_TIME_FOREVER);

//loop thru tracks
//export on seperate thread
