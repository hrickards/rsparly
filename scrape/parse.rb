require 'rubygems'
require 'nokogiri'

mps = File.read('../output/mps.txt').split("\n")
mps_data = File.read '../raw/members.xml'

doc = Nokogiri::XML mps_data

parties = []
votes_x = []

def return_vote(vote)
  return case
  when vote == -9
    0
  when vote == 1
    1
  when vote == 2
    1
  when vote == 3
    0
  when vote == 4
    -1
  when vote == 5
    -1
  else
    0
  end
end

parties_mps = Hash.new

votes = File.read('votest.txt').split("\n")
votes.map!{|r| r.split(" ").map{|v| Float(v).to_i}}

puts votes.length

votes.each_with_index do |vote_row, index|
  puts index
  puts vote_row.first.inspect
  mp = "uk.org.publicwhip/member/#{vote_row.first}"
  unless parties_mps[mp]
    parties_mps[mp] = doc.xpath("//member[@id='#{mp}']/@party").first.content
  end
  parties << parties_mps[mp]
  votes_x << vote_row[1..vote_row.length].map{|v| return_vote(v) }
end

midpoint = ((votes_x.length)/2).ceil

votes_test_x = votes_x[0..midpoint]
parties_test = parties[0..midpoint]
votes_x = votes_x[midpoint..votes_x.length]
parties = parties[midpoint..parties.length]

File.open('parties.txt', 'w') { |f| f.write parties.join("\n") }
File.open('parties_test.txt', 'w') { |f| f.write parties_test.join("\n") }
File.open('x_data.txt', 'w') { |f| f.write votes_x.map{|r| r.join(" ")}.join("\n") }
File.open('test_x_data.txt', 'w') { |f| f.write votes_test_x.map{|r| r.join(" ")}.join("\n") }
