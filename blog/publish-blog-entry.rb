#!/usr/bin/env ruby

if ARGV.length != 3
    puts "Usage: ./publish-blog-entry.rb <title> <description> <filename>"

(title, description, fname) = ARGV

HOME = `cd ~; pwd`.chomp
TARGET = "#{HOME}/github/benjaminrosenbaum/benjaminrosenbaum.github.io/blog"
SRC = "#{HOME}/bitbucket/benjaminrosenbaum.com/blogs"
MSG = "publishing blog entry: #{title.gsub("'", "")}"

LASTID = `ls -1 #{TARGET}/archives | sort | tail -1 | cut -d '.' -f 1`.chomp.gsub(/^0*/, '').to_i 
NEWID = (LASTID + 1).to_s.rjust(6, '0')

system("cd #{SRC}; git status; git commit -am '#{MSG}'; git push" )
system(%Q{cd #{TARGET}; ./new-blog.rb "#{title}" "description" < "#{SRC}/#{fname}" > "archives/#{NEWID}.html" })
system(%Q{cd #{TARGET}; git add archives; git commit -am "#{MSG}" git status; git pull; git push })





