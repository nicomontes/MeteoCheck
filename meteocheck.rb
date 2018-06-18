# encoding: UTF-8
require 'rubygems'
require 'watir'
require 'watir'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# Write time and RUN
puts Time.new.inspect
puts "-------"
puts "  Run  "
puts "-------"

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
data = Hash.new

dataNew = Hash.new
dataNew['cities'] = []
dataNew['cities']['name'] = ''
dataNew['cities']['zip'] = ''
dataNew['cities']['forecast'] = []
dataNew['cities']['forecast']['source'] = ''
dataNew['cities']['forecast']['date_from'] = ''
dataNew['cities']['forecast']['date_for'] = ''
dataNew['cities']['forecast']['weather'] = ''
dataNew['cities']['forecast']['t_min'] = ''
dataNew['cities']['forecast']['t_max'] = ''

i=0
# Browse JSON file
hash['cities'].each do |item|
	puts "City => " + item["name"]
	$browser.goto 'http://www.meteofrance.com/previsions-meteo-france/' + item['name'].to_s + '/' + item['zip'].to_s
	j = 0
	data[(date).to_s] = []
	$browser.div(:class => 'liste-jours').ul.lis.each do |li|
		data[(date).to_s][j] = {}
		data[(date).to_s][j][(date+j).to_s] = {}
		data[(date).to_s][j][(date+j).to_s]['MF'] = {}
		data[(date).to_s][j][(date+j).to_s]['MF']['weather'] = li.title.to_s
		data[(date).to_s][j][(date+j).to_s]['MF']['min_temp'] = /[\-0-9]*/.match(li.dl.dds[1].span(:class => 'min-temp').inner_html).to_s
		data[(date).to_s][j][(date+j).to_s]['MF']['max_temp'] = /[\-0-9]*/.match(li.dl.dds[1].span(:class => 'max-temp').inner_html).to_s
		j+=1
	end
	hash['cities'][i] = hash['cities'][i].merge(data)
	#puts date.to_s + " : weather history"
	k=0
	while hash['cities'][i].key?((date-k).to_s)
		#puts (date-k).to_s + " : " + hash['cities'][i][(date-k).to_s][k][(date).to_s]['weather'].to_s
		k+=1
	end

	# Erase Files
	l=0
	while hash['cities'][i].key?((date-l).to_s)
		m=0
		system 'mkdir', '-p', item["name"]
		hash['cities'][i][(date-l).to_s].each do |value|
				File.open(item["name"]+'/'+item["name"]+'_'+(date-l+m).to_s, 'w') { |f|
					f.write("date,weather,tempMax,tempMin\n")
					f.close
				}
			#puts 'le ' + (date-l).to_s + ' Météo France à prévu pour le ' + (date-l+m).to_s + ' cette météo : ' + value[(date-l+m).to_s]['weather'].to_s
			m+=1
		end
		l+=1
	end

	# Add in files
	l=0
	while hash['cities'][i].key?((date-l).to_s)
		m=0
		system 'mkdir', item["name"]
		hash['cities'][i][(date-l).to_s].each do |value|
			File.open(item["name"]+'/'+item["name"]+'_'+(date-l+m).to_s, 'a') { |f|
		  	f.puts((date-l).to_s + ',' + value[(date-l+m).to_s]['MF']['weather'].to_s + ',' + value[(date-l+m).to_s]['MF']['max_temp'] + ',' + value[(date-l+m).to_s]['MF']['min_temp'])
		  	f.close
			}
			#puts 'le ' + (date-l).to_s + ' Météo France à prévu pour le ' + (date-l+m).to_s + ' cette météo : ' + value[(date-l+m).to_s]['weather'].to_s
			m+=1
		end
		l+=1
	end
	
	
	i+=1
end



# Close browser
$browser.close

File.open('meteodata.json', 'w') { |f| 
  f.write(JSON.pretty_generate(hash))
  f.close
}

File.open('meteodataNew.json', 'w') { |f| 
  f.write(JSON.pretty_generate(dataNew))
  f.close
}

# Write Finish
puts "----------"
puts "  Finish  "
puts "----------"
puts Time.new.inspect
