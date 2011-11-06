parties = File.read("parties.txt").split("\n")
test_parties = File.read("parties_test.txt").split("\n")
uniq_parties = (parties+test_parties).uniq
parties_mapping = Hash.new
uniq_parties.each_with_index do |party, index|
  parties_mapping[index + 1] = party
end
y_data = []
test_y_data = []
parties.each do |party|
  y_data << parties_mapping.select {|key, value| value == party}.key(party)
end
test_parties.each do |party|
  test_y_data  << parties_mapping.select {|key, value| value == party}.key(party)
end

File.open('mapping.txt', 'w') { |f| f.write parties_mapping.inspect }

File.open('y_data.txt', 'w') { |f| f.write y_data.join("\n") }
File.open('test_y_data.txt', 'w') { |f| f.write test_y_data.join("\n") }
