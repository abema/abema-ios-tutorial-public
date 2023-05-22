#!/usr/bin/env ruby

require "optparse"
require "YAML"

params = {}

opt = OptionParser.new
opt.on("--update", "Update checksum files")
opt.parse!(ARGV, into: params)

podnames = ARGV
remaining = podnames.clone

YAML.load(File.read("Pods/Manifest.lock"))["SPEC CHECKSUMS"].each { |podname, updated|
  next unless podnames.empty? || podnames.include?(podname)

  remaining.delete(podname)

  Dir.mkdir "Pods/.checksums" unless Dir.exist?("Pods/.checksums")
  hashfile = "Pods/.checksums/#{podname}"

  current = File.exists?(hashfile) ? File.read(hashfile) : ""
  if current.empty?
    puts "#{podname} NEW #{updated}"
  elsif current != updated
    puts "#{podname} #{current} => #{updated}"
  end

  if params[:update]
    f = File.new(hashfile, "w")
    f.write(updated)
  end
}

remaining.each { |podname|
  puts "Pod '#{podname}' not found"
  exit 1
}
