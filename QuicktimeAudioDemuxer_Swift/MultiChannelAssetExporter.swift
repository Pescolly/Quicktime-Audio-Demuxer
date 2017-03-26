//
//  StereoExport.swift
//  QuicktimeAudioDemuxer_Swift
//
//  Created by Armen Karamian on 4/18/16.
//  Copyright © 2016 Armen Karamian. All rights reserved.
//

import Foundation
import AVFoundation

class MultiChannelAssetExporter
{
	var sampleDataBuffers:[NSMutableData]?
	var asset:AVAsset!
	var filenameURL:NSURL!
	var outputSettings:[String : AnyObject]!
	
	init(inAsset : AVAsset, fileName : String)
	{
		self.asset = inAsset
		self.filenameURL = NSURL(fileURLWithPath: fileName)
		
		var acl = AudioChannelLayout()
		memset(&acl, 0, sizeof(AudioChannelLayout))
		acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
		
		outputSettings = [
			AVFormatIDKey : Int(kAudioFormatLinearPCM),
			AVLinearPCMBitDepthKey : 24,
			AVLinearPCMIsBigEndianKey : false,
			AVLinearPCMIsFloatKey : false,
			AVSampleRateKey : 48000,
			AVLinearPCMIsNonInterleaved : false,
			AVChannelLayoutKey : NSData(bytes:&acl, length:sizeof(AudioChannelLayout)),
			AVNumberOfChannelsKey : 2
		]
	}
	
	private func readSamplesIntoBuffer(selectedTrack : AVAssetTrack)
	{
		do
		{
			//setup asset reader and track output reader
			if let assetReader:AVAssetReader = try AVAssetReader(asset: self.asset)
			{
				
				
				//setup track output reader and buffer for data
				let assetReaderTrackOutput = AVAssetReaderTrackOutput(track: selectedTrack, outputSettings: self.outputSettings)
				assetReader.addOutput(assetReaderTrackOutput)
				let trackData = NSMutableData()
				
				//read sample bytes and place into track data list
				assetReader.startReading()
				
				while assetReader.status == .Reading
				{
					if let sampleBuffer = assetReaderTrackOutput.copyNextSampleBuffer()
					{
						if let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer)
						{
							let length = CMBlockBufferGetDataLength(blockBufferRef)
							let sampleBytes = UnsafeMutablePointer<Int>.alloc(length)
							CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, sampleBytes)
							trackData.appendBytes(sampleBytes, length: length)
						}
					}
				}
				
				if assetReader.status == .Completed
				{
					//put new track data into buffer list
					sampleDataBuffers?.append(trackData)
				}
			}
			
		}
		catch
		{
			print("Error")
		}
	}
	
	func exportWaveFile(selectedTrack1 : AVAssetTrack, selectedTrack2 : AVAssetTrack)
	{
		do
		{

			//setup asset reader and track output reader
			if let assetReader:AVAssetReader = try AVAssetReader(asset: self.asset)
			{
				
				//setup track output reader and buffer for data
				let assetReaderTrackOutput1 = AVAssetReaderTrackOutput(track: selectedTrack1, outputSettings: self.outputSettings)
				let assetReaderTrackOutput2 = AVAssetReaderTrackOutput(track: selectedTrack2, outputSettings: self.outputSettings)
				
				assetReader.addOutput(assetReaderTrackOutput1)
				assetReader.addOutput(assetReaderTrackOutput2)
				
				//read sample bytes and place into track data list
				let assetWriter = try AVAssetWriter(URL: self.filenameURL, fileType: AVFileTypeWAVE)
				let assetWriterInput1 = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: self.outputSettings)
				assetWriterInput1.expectsMediaDataInRealTime = false

				let assetWriterInput2 = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: self.outputSettings)
				assetWriterInput2.expectsMediaDataInRealTime = false

				
				if assetWriter.canAddInput(assetWriterInput1)
				{
					assetWriter.addInput(assetWriterInput1)
				}

				if assetWriter.canAddInput(assetWriterInput2)
				{
					assetWriter.addInput(assetWriterInput2)
				}

				
				assetWriter.startWriting()
				assetReader.startReading()

				let startTime = CMTimeMake(0, selectedTrack1.naturalTimeScale)
				assetWriter.startSessionAtSourceTime(startTime)

				var complete = false
				while !complete
				{
					if assetWriterInput1.readyForMoreMediaData
					{
						if let track1Buffer = assetReaderTrackOutput1.copyNextSampleBuffer()
						{
							assetWriterInput1.appendSampleBuffer(track1Buffer)
							
						}
						else
						{
							complete = true
						}

					}

					if assetWriterInput2.readyForMoreMediaData
					{
						
						if let track2Buffer = assetReaderTrackOutput2.copyNextSampleBuffer()
						{
							assetWriterInput2.appendSampleBuffer(track2Buffer)
						}
						else
						{
							complete = true
						}
					}

				
				}
				complete = false
				assetWriterInput1.markAsFinished()
				assetWriterInput2.markAsFinished()

				let sema = dispatch_semaphore_create(1)
				assetWriter.finishWritingWithCompletionHandler(
				{
					print("done")
					dispatch_semaphore_signal(sema)
					complete = true
				})
				dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
				while(!complete)
				{
					
				}
			}
		}
		catch
		{
			print("err")
		}
	}
	
}

