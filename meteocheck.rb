# encoding: UTF-8
require 'rubygems'
require 'watir'
require 'watir'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'levenshtein'
require 'damerau-levenshtein'

# Write time and RUN
puts Time.new.inspect
puts "-------"
puts "  Run  "
puts "-------"

puts DamerauLevenshtein.distance('qsd', 'sqkf')

# Open Chrome
$browser = Watir::Browser.new :chrome, :switches => %w[--disable-popup-blocking --disable-translate]

# Open JSON file
file = File.open("meteodata.json", "r:UTF-8")
json_file = file.read
file.close

# date
date = Date.today

# Parse JSON file
hash = JSON.parse(json_file)

i=0
# Browse JSON file
hash['cities'].each do |item|
	puts "City => " + item["name"]
	# Check Météo France
	$browser.goto 'http://www.meteofrance.com/previsions-meteo-france/' + item['name'].to_s + '/' + item['zip'].to_s
	j = 0
	$browser.div(:class => 'liste-jours').ul.lis.each do |li|
		forecast = { 
			:source => 'Météo France', 
			:date_from => (date).to_s, 
			:date_for => (date+j).to_s,
			:weather => li.title.to_s,
			:t_min => /[\-0-9]*/.match(li.dl.dds[1].span(:class => 'min-temp').inner_html).to_s,
			:t_max => /[\-0-9]*/.match(li.dl.dds[1].span(:class => 'max-temp').inner_html).to_s
		}
		hash['cities'][i]['forecast'].push(forecast)
		j+=1
	end
	# Check Weather Channel
	# Check Météo Agricole
	
	# Erase Files
		system 'mkdir', '-p', hash['cities'][i]['name'].to_s
		hash['cities'][i]['forecast'].each do |forecast|
				File.open(hash['cities'][i]['name'].to_s+'/'+hash['cities'][i]['name'].to_s+'_'+forecast['date_for'].to_s, 'w') { |f|
					f.write("date,source,weather,tempMax,tempMin\n")
					f.close
				}
		end

	# Add in files
		system 'mkdir', hash['cities'][i]['name'].to_s
		hash['cities'][i]['forecast'].each do |forecast|
			File.open(hash['cities'][i]['name'].to_s+'/'+hash['cities'][i]['name'].to_s+'_'+forecast['date_for'].to_s, 'a') { |f|
		  	f.puts(forecast['date_from'].to_s + ',' + forecast['source'].to_s + ',' + forecast['weather'].to_s + ',' + forecast['t_max'].to_s + ',' + forecast['t_min'].to_s)
		  	f.close
			}
		end
		
		system 'rm', '-f', hash['cities'][i]['name'].to_s+'/'+hash['cities'][i]['name'].to_s+'_'
	
	i+=1
end



# Close browser
$browser.close

File.open('meteodata.json', 'w') { |f| 
  f.write(JSON.pretty_generate(hash))
  f.close
}

# Write Finish
puts "----------"
puts "  Finish  "
puts "----------"
puts Time.new.inspect
