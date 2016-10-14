#!/usr/bin/ruby

require '../lib/vcs'

VCSRuby::Configuration.instance.verbose = true
# VCSRuby::Configuration.instance.capturer = :mplayer

video = VCSRuby::Video.new "ons3on3cup_hdtv.mp4"

# Always call valid? before you access the meta-information! 
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
  frame.filename = "blank.jpg"
  puts frame.filename

  frame.capture
  frame.filename = "evade.png"
  frame.format = :png
  frame.capture_and_evade

  cs = video.contact_sheet
  cs.thumbnail_width = 240
  cs.initialize_filename "cs.jpg"
  cs.build

  cs.initialize_filename "cs.png"
  cs.initialize_geometry(2, 2, nil)
  cs.thumbnail_width = 320
  cs.signature = nil
  cs.title = "Title"
  cs.build
end

puts "DONE"
