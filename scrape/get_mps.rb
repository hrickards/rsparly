require 'nokogiri'

votes = File.read('votest.txt').split("\n")
votes.map!{|r| r.split(" ").map{|v| Float(v).to_i}}
mp_ids = votes.map{|r| r[0]}
mps_data = File.read '../raw/members.xml'
doc = Nokogiri::XML mps_data

mps = []

mps_ids_maps = Hash.new

count = mp_ids.length
mp_ids.each_with_index do |mp_id, index|
  puts "#{index} of #{count}"
  
  mp = "uk.org.publicwhip/member/#{mp_id}"
  unless mps_ids_maps[mp]
    mps_ids_maps[mp] 
    the_mp = doc.xpath("//member[@id='#{mp}']").first
    mps_ids_maps[mp] = "#{the_mp['party']};#{the_mp['firstname']} #{the_mp['lastname']}, #{the_mp['party']} MP for #{the_mp['constituency']}"
  end

  mps << mps_ids_maps[mp]
end

File.open('mps_y_data.txt', 'w') { |f| f.write(mps.join("\n"))}
