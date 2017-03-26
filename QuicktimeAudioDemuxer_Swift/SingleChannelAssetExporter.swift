//
//  AudioFileExporter.swift
//  QuicktimeAudioDemuxer_Swift
//
//  Created by Armen Karamian on 4/15/16.
//  Copyright © 2016 Armen Karamian. All rights reserved.
//

import Foundation
import AVFoundation

class SingleChannelAssetExporter
{
	//main path where exports go
	let exportDirectory:NSURL?
	
	init(inExportDirectory:NSURL)
	{
		self.exportDirectory = inExportDirectory
	}
	
/*	NOT SUPPORTED BY SHIT API
	func exportStereoPair(audioTrack1:AVAssetTrack, audioTrack2:AVAssetTrack, audioTrackName:String)
	{
		print("Exporting Stereo Pair",audioTrackName)
		//setup export path
		let exportFileName = self.exportDirectory?.URLByAppendingPathComponent(audioTrackName+".wav")
		
		let assetExporter = MultichannelAssetExporter(inAsset: <#T##AVAsset#>)

	}
*/
	func exportSingleStem(audioTrack:AVAssetTrack, audioTrackName:String)
	{
		//setup export path
		let exportFileName = self.exportDirectory?.URLByAppendingPathComponent(audioTrackName+".wav")
		
		//setup export composition and track
		if let exportComposition = createExportComposition(audioTrack)
		{
			//create export session
			if let exportSession = createExportSession(exportComposition, exportFileName: exportFileName!)
			{
				//create semaphore and start export
				let exportDoneSemaphore = dispatch_semaphore_create(0);
				exportSession.exportAsynchronouslyWithCompletionHandler(
					{
						switch exportSession.status
						{
							case AVAssetExportSessionStatus.Completed:
								print("Export Complete", exportFileName?.path!)
								dispatch_semaphore_signal(exportDoneSemaphore)
							case AVAssetExportSessionStatus.Failed:
								print("Export Failed:",exportSession.error?.localizedDescription)
								print(exportSession.error?.localizedFailureReason)
								dispatch_semaphore_signal(exportDoneSemaphore)
							default:
								print("Cannot export")
								dispatch_semaphore_signal(exportDoneSemaphore)

						}
				})
				//wait for export to complete
				dispatch_semaphore_wait(exportDoneSemaphore, DISPATCH_TIME_FOREVER);
			}
		}
	}
	
	func createExportSession(exportComposition : AVMutableComposition, exportFileName : NSURL) -> AVAssetExportSession?
	{
		let exportSession = AVAssetExportSession(asset: exportComposition, presetName: AVAssetExportPresetPassthrough)
		
		//exportSession?.audioMix
		exportSession?.outputFileType = AVFileTypeWAVE
		exportSession?.outputURL = exportFileName
		return exportSession
	}
	
	func createExportComposition(audioTrack : AVAssetTrack) -> AVMutableComposition?
	{
		do
		{
			let exportComposition = AVMutableComposition()
			let exportTrack = exportComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
			try exportTrack.insertTimeRange(audioTrack.timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
			return exportComposition
		}
		catch
		{
			print("Cannot export")
			return nil
		}
	}
	/*	NOT SUPPORTED BY SHIT API
	func createStereoExportComposition(audioTrack1 : AVAssetTrack, audioTrack2 : AVAssetTrack) -> AVMutableComposition?
	{
		do
		{
			let exportComposition = AVMutableComposition()
			let exportTrack1 = exportComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
			try exportTrack1.insertTimeRange(audioTrack1.timeRange, ofTrack: audioTrack1, atTime: kCMTimeZero)
			
			let exportTrack2 = exportComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
			try exportTrack2.insertTimeRange(audioTrack2.timeRange, ofTrack: audioTrack2, atTime: kCMTimeZero)
			
			return exportComposition
		}
		catch
		{
			print("Cannot export")
			return nil
		}
	}*/
}