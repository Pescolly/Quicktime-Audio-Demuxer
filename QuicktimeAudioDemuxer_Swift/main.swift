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

let filename = inputFileURL.lastPathComponent?.stringByReplacingOccurrencesOfString(".mov", withString: "_")

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

let singleChannelFileExporter = SingleChannelAssetExporter(inExportDirectory: exportDirectory!)

//dispatch group for track export threads
let trackGroup = dispatch_group_create();
let trackQ = dispatch_queue_create("com.mvf.trackexportq", DISPATCH_QUEUE_CONCURRENT);

switch audioTrackCount
{
	case 2:
		let multiChannelFileExporter = MultiChannelAssetExporter(inAsset: qtAsset, fileName: filename!+"AudioPairOne")
		multiChannelFileExporter.exportWaveFile(qtAudioTracks[0], selectedTrack2: qtAudioTracks[1])
//		singleChannelFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: filename!+"AudioPairOne")
	
	case 4:
		//assign each track to a async thread in the track export dispatch group.
		dispatch_group_async(trackGroup, trackQ,
			{
				//start async dispatch
//				singleChannelFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: filename!+"AudioPairOne")
			})

		dispatch_group_async(trackGroup, trackQ,
			{
				//start async dispatch
//				singleChannelFileExporter.exportStereoPair(qtAudioTracks[0], audioTrack2: qtAudioTracks[1], audioTrackName: filename!+"AudioPairTwo")
			})
	
	default:
		//off for testing !!!!!!!!!! WORKS !!!!!!!!!!!!!!!
/*		for i in 0...5
		{
			dispatch_group_async(trackGroup, trackQ,
			{
				singleChannelFileExporter.exportSingleStem(qtAudioTracks[i], audioTrackName: filename!+"Tr"+String(i+1))
			})
		}
*/
		//unwinding loop for extra channels
		//was having issues with loop and async dispatch
		guard audioTrackCount > 6 else
		{
			break;
		}
//		dispatch_group_async(trackGroup, trackQ,
//		{
			print("making tr7 & 8")
		
			let finalFilename = "/Users/akaramian/Desktop/PMT_OUTPUT_tr78.wav"// exportDirectory + "/" + filename! + String("Tr7") + "_" + String("Tr8")
			print(finalFilename)
			let multiChannelFileExporter = MultiChannelAssetExporter(inAsset: qtAsset, fileName: finalFilename)
			multiChannelFileExporter.exportWaveFile(qtAudioTracks[6], selectedTrack2: qtAudioTracks[7])
//			singleChannelFileExporter.exportStereoPair(qtAudioTracks[6], audioTrack2: qtAudioTracks[7], audioTrackName: filename!+String("Tr7")+"_"+String("Tr8"))
//		})

		guard audioTrackCount > 8 else
		{
			break;
		}
		
		dispatch_group_async(trackGroup, trackQ,
		{
//			singleChannelFileExporter.exportStereoPair(qtAudioTracks[8], audioTrack2: qtAudioTracks[9], audioTrackName: filename!+String("Tr9")+"_"+String("Tr10"))
		})

		guard audioTrackCount > 10 else
		{
			break;
		}
		
		dispatch_group_async(trackGroup, trackQ,
		{
//			singleChannelFileExporter.exportStereoPair(qtAudioTracks[10], audioTrack2: qtAudioTracks[11], audioTrackName: filename!+String("Tr11")+"_"+String("Tr12"))
		})
	
		guard audioTrackCount > 12 else
		{
			break;
		}
		
		dispatch_group_async(trackGroup, trackQ,
		{
//			singleChannelFileExporter.exportStereoPair(qtAudioTracks[12], audioTrack2: qtAudioTracks[13], audioTrackName: filename!+String("Tr13")+"_"+String("Tr14"))
		})

		guard audioTrackCount > 14 else
		{
			break;
		}
		
		dispatch_group_async(trackGroup, trackQ,
		{
//			singleChannelFileExporter.exportStereoPair(qtAudioTracks[14], audioTrack2: qtAudioTracks[15], audioTrackName: filename!+String("Tr14")+"_"+String("Tr15"))
		})


}

//wait for all async threads to finish
dispatch_group_wait(trackGroup, DISPATCH_TIME_FOREVER);

//loop thru tracks
//export on seperate thread
