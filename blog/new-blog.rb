#!/usr/bin/env ruby
require 'date'
require 'htmlentities'

coder = HTMLEntities.new
now = DateTime.now

# regexes

if ARGV.length < 3
	puts "Usage: new-blog.rb [--edit] [--fblink URL] [--bslink URL] [--mslink URL] title description prev-id  < blog-contents > output.html"
	puts "       supports <!--NEXT-ENTRY-LINK--> and <!--CROSSPOST--> placeholders in blog body. CROSSPOST is where social media links go."
	exit 1
end

if ARGV[0] == "--edit"
	$edit = true
	ARGV.shift
end

if ARGV[0] == "--fblink"
	ARGV.shift
	$fblink = ARGV.shift
end

if ARGV[0] == "--bslink"
	ARGV.shift
	$bslink = ARGV.shift
end

if ARGV[0] == "--mslink"
	ARGV.shift
	$mslink = ARGV.shift
end



title = coder.encode ARGV[0].capitalize, :named
description = coder.encode ARGV[1], :named
$prev = ARGV[2]
if $prev.to_i == 0
	puts "bad previous id"
	exit 1
end

$curr = ($prev.to_i + 1).to_s.rjust(6, "0")

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


puts header title, description, now
STDIN.each do |line|
	 if (line =~ /^\s*--\s*$/)
	  	puts("<hr/>")
	 elsif (line =~ /<!--CROSSPOST-->/) 
	 		links = { :Facebook => $fblink, :Bluesky => $mslink, :Mastodon => $mslink }.reject{|k, v| !v}
	 		threads = "thread#{links.length > 1 ? "s" : ""}"
	 		cp = "[You can comment on the #{links.map{|k,v| "<a href=#{v}>#{k}</a>"}.join(", ")} #{threads}.]" if links.any?{|k,v| v}
	 		puts "   <p><!--CROSSPOST-->#{cp}</p>"
	 else
		puts "<p>#{line.chomp}</p>"
	 end
end
puts footer now




				