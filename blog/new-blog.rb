#!/usr/bin/env ruby
require 'date'
require 'htmlentities'

coder = HTMLEntities.new
now = DateTime.now

$platforms = %i{facebook bluesky mastodon tumblr}

if ARGV.length < 2
	puts "Usage: new-blog.rb [--edit] #{$platforms.map{|p| "[--#{p} URL]"}.join ' '} [--pandoc] title description [prev-id]  < blog-contents > output.html"
	puts "       supports --, <!--NEXT-ENTRY-LINK-->, and <!--CROSSPOST--> placeholders in blog body. CROSSPOST is where social media links go."
	exit 1
end

if ARGV.delete "--edit"
	$edit = true
end


if ARGV.delete "--pandoc"
	$pandoc = true
end

#todo make these Strategy objects so they can come in any order

$links = {}

while ($platforms.any? {|p| ARGV[0] == "--#{p}"} ) 
	puts "found: --#{p}"
	p = $1 if ARGV.shift =~ /--(\w*)/
	$links[p] = ARGV.shift
	puts $links
	puts "--------"
end


title = coder.encode ARGV[0].tap{|n| n[0].capitalize + n.slice(1) }, :named
description = coder.encode ARGV[1], :named
$prev = ARGV[2] || `ls -1 archives | sort | tail -1 | cut -d '.' -f 1`.chomp
if $prev.to_i == 0
	puts "bad previous id: #{$prev}"
	exit 1
end

$curr = ($prev.to_i + 1).to_s.rjust(6, "0")
$prev = $prev.to_i.to_s.rjust(6, "0")

def header title, description, now
	full_date = now.strftime "%A, %B %d, %Y"
	%Q{
	<html>		
			<head>
		  		<title>Benjamin Rosenbaum: #{title}</title>
		  		<link rel="stylesheet" href="../styles-site.css" type="text/css" />
		      <!--
		<rdf:RDF xmlns="https://web.resource.org/cc/"
         xmlns:dc="https://purl.org/dc/elements/1.1/"
         xmlns:rdf="https://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <Work rdf:about="https://www.benjaminrosenbaum.com/blog/archives/#{$curr}.html">
    <dc:title> #{title}</dc:title>
    <dc:description>#{description}</dc:description>
    <dc:creator>Benjamin Rosenbaum</dc:creator>
    <dc:date>#{now.strftime}</dc:date>
    <license rdf:resource="https://creativecommons.org/licenses/by-sa/1.0/" />
    </Work>
    <License rdf:about="https://creativecommons.org/licenses/by-sa/1.0/">
    <requires rdf:resource="https://web.resource.org/cc/Attribution" />
    <requires rdf:resource="https://web.resource.org/cc/Notice" />
    <requires rdf:resource="https://web.resource.org/cc/ShareAlike" />
    <permits rdf:resource="https://web.resource.org/cc/Reproduction" />
    <permits rdf:resource="https://web.resource.org/cc/Distribution" />
    <permits rdf:resource="https://web.resource.org/cc/DerivativeWorks" />
    </License>
    </rdf:RDF>
		       -->
			</head>
	<body>
				
		#{arrows}
	

  		<table BORDER="0" CELLSPACING="8" cellpadding="3" WIDTH="100%" >
  		  <tr>
  		    <td><img SRC="../images/journal.gif" height="368" width="152">
  		    </td>
  		    <td>
  		      <table BORDER=0 CELLSPACING=0 CELLPADDING=0 COLS=3 WIDTH="100%">
  		        <tr>
  		           <td width="100%">
  		          <center><b><font face="Copperplate Gothic Bold"><font size=+1>Journal Entry </font></font></b></center>
  		          </td>
  		       </tr>
  		      </table> 
		
  		<p><b><font face="Copperplate Gothic Light">
  		<a href="#">
  		   #{full_date} 
  		</a>
  		</font></b>


  <a name="#{$curr}"></a>
  <p><b><font face="Copperplate Gothic Light">
    <font size=-1>
    #{title} 
    </font>
  </font></b>}
end

def arrows 
	%Q{
		<div width="100%"><table width="100%">
		       <tr>
		          <td width="50%" class="left">
		             <a href='#{$prev}.html'>&lt;&lt; Previous Entry</a>
		          </td>
		        <td><center><a href="../index.html">To Index</a></center></td>
		          <td width="50%" class="right">
		             <!--NEXT-ENTRY-LINK--><a href='../index.html'>Next Entry &gt;&gt;</a>
		          </td>
		       </tr>
		       </table>
		    </div>
	}
end

def footer now
	full_time = now.strftime "%A, %B %d, %Y at %H:%M:%S"

	%Q{
	                    <span class="posted">#{ $edit ? "Last edited" : "Posted"} by Benjamin Rosenbaum at #{full_time}
	                    
	                    | <a href="../">Up to blog</a>
	                    <br /></span>
	                    
	                    </div>

				      </td>
				    </tr>
				  </table>
				</center> 

				#{arrows}


				<div align=right  style="padding-top: 20px">
					<a href="/"><img SRC="../images/br.gif" height=22 width=29></a>
				</div>
			</body>
		</html>
	}
end

unless $edit
	`cp index.html old-index.html; cp archives/#{$prev}.html prev-tmp`

	File.open('index.html', 'w') do |f| 
		File.readlines('old-index.html').each do |line|
			f.write(line) 
			if (line.start_with? "<!-- NEXT-ENTRY -->")
				f.write("<li>#{now.strftime "%Y-%m-%d"}: <a href=\"archives/#{$curr}.html\">#{title}</a>\n")
		  end
		end
	end

	File.open("archives/#{$prev}.html", 'w') do |f| 
		File.readlines('prev-tmp').each do |line|
			if (line.include? "<!--NEXT-ENTRY-LINK-->")
				f.write("		             <!--NEXT-ENTRY-LINK--><a href='#{$curr}.html'>Next Entry &gt;&gt;</a>\n")
		 	else
		    f.write(line)
		  end
		end
	end
end

def process_line line, add_para 
	 #p = -> (txt) { add_para ? "<p>#{txt}</p>" : "txt\n" }
	if (line =~ /^\s*--\s*$/)
	  	'<hr/>'
		"   <p><!--CROSSPOST-->#{cp}</p>"
	 else
	 		txt = line.chomp
	 		add_para ? "<p>#{txt}</p>" : "#{txt}\n"
	 end
end

def crosspost_line links
	threads = "thread#{links.length > 1 ? "s" : ""}"
	if links.any?
		"<p><!--CROSSPOST-->[You can comment on the #{links.map{|k,v| "<a href=\"#{v}\">#{k.capitalize}</a>"}.join(", ")} #{threads}.]</p>" 
	end
end


puts header title, description, now
if $pandoc
	File.write('.pandocable.md', $stdin.read)
	transformed = `pandoc --to HTML .pandocable.md | sed 's/\\<p\\>\\*\\*/\\<p\\>\\<b\\>/g' | sed 's/\\*\\*\\<\\/p>/<\\/b><\\/p>/g'`
	File.write('.pandocked.html', transformed)
	transformed.each_line { |line|  puts process_line line, false }
else
	STDIN.each {|line| puts process_line line, true}
end

puts crosspost_line $links

puts footer now




				