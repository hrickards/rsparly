bills = []
bills_array = File.read('bills.txt').split("\n").map { |b| b.split(";;;") }
bills_array.each do |bill|
  bill_hash = {:id => bill[0], :question => bill[2]} 
  bills << bill_hash
end

File.open('bills_data.txt', 'w') { |f| Marshal.dump(bills, f) }
