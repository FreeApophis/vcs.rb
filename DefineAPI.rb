require_relative 'lib/vcs'

VCSRuby::Configuration.instance.verbose = true

video = VCSRuby::Video.new "ons3on3cup_hdtv.mp4"
#video = VCSRuby::Video.new "fat_vs_flat.nsv"
#video = VCSRuby::Video.new "3years UT2k4_PPC_VGA.avi"

puts "valid?: #{video.valid?}"

if video.valid?
  # General Information about the file in general
  puts "Video duration: #{video.info.duration}"
  puts "Total bit rate: #{video.info.bit_rate}"
  puts "File size: #{video.info.size}"
  puts "Container format: #{video.info.format}"
  puts "Container file extension: #{video.info.extension}"
  
  puts video.info.raw.inspect

  # Info about the Video Stream
  puts "video_streams: #{video.video_streams.count}"
  
  # video_streams givs access to all video streams, video is always the first video stream in the movie
  puts "width: #{video.video.width}"
  puts "height: #{video.video.height}"
  puts "Video codec: #{video.video.codec}"
  puts "color_space: #{video.video.color_space}"
  puts "bit_rate: #{video.video.bit_rate}"
  puts "frame_rate: #{video.video.frame_rate}"
  puts "DAR: #{video.video.aspect_ratio}"
  
  puts video.video.raw.inspect

  # Info about the Audio Stream
  puts "audio_streams: #{video.audio_streams.count}"

  # audio_streams givs access to all audio streams, audio is always the first audio stream in the movie (or nil)
  puts "Audio codec: #{video.audio.codec}"
  puts "audio_sample_rate: #{video.audio.sample_rate}"
  puts "bit_rate: #{video.audio.bit_rate}"
  puts "audio_channels: #{video.audio.channels}"
  puts "channel_layout: #{video.audio.channel_layout}"
  

  puts video.audio.raw.inspect

  puts "File: #{video.full_path}"
  frame = video.frame VCSRuby::TimeIndex.new(0)
  frame.image_path = "blank.jpg"
  frame.capture
  frame.image_path = "evade.jpg"
  frame.capture_and_evade
  
  cs = video.contact_sheet
  cs.thumbnail_width = 240
  cs.build
end


puts "DONE"