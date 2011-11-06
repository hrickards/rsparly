require 'net/http'

urls = ["http://www.publicwhip.org.uk/data/votematrix-1997.dat"]

votes = {}
bills = []

urls.each do |url|
  uri = URI.parse url

  data = Net::HTTP.get uri
  data = data.split("\n")
  len = data.first.split("\t").length
  data.map! { |d| d.split("\t") }
  new_bills = data.map { |d| [d[1], d[3]] }
  bills = new_bills[1..new_bills.length]
  
  len = data.first.length
  data.map! { |d| d[4..len] }

  data.first.map! {|mp_id| mp_id[4..mp_id.length]}

  File.open('votes.txt', 'w') { |f| f.write(data.map{|row| row.join(" ")}.join("\n"))}
end

bills = bills.each_with_index.map { |b, i| b.unshift i }
File.open("bills.txt", "w") { |f| f.write(bills.map{|row| row.join(";;;")}.join("\n"))}
