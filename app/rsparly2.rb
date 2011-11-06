require 'sinatra'
require 'json'
require 'matrix'

get '/' do
  @votes = File.open("bills_data.txt", "r") {|f| Marshal.load(f) }

  erb :home
end

configure do  x_data = ""
  File.open("x_data.txt", "r") do |infile|
    while (line = infile.gets)
      x_data << line
    end
  end
  x_data = x_data.split("\n").map{|r| r.split(" ").map{ |v| v.to_i } }

  @@x_data = x_data

  mp_data = ""
  File.open("mps_y_data.txt", "r") do |infile|
    while (line = infile.gets)
      mp_data << line
    end
  end
  mp_data = mp_data.split("\n")
  @@mp_data = mp_data

  theta = []
  File.open("theta.txt", "r") do |infile|
    while (line = infile.gets)
      theta << line
    end
  end
  theta.map! { |t| t.split(" ").map{ |f| Float(f) } }
  theta = Matrix.rows(theta).transpose
  @@theta = theta

  mapping = ""
  File.open("mapping.txt", "r") do |infile|
    while (line = infile.gets)
      mapping << line
    end
  end

  mapping = mapping.gsub('"', "").gsub("{","").gsub("}","").split("=>").map { |el| el.split(", ") }.flatten
  mapping = mapping.values_at( *(0...mapping.size).map{|i| (i%2) != 0 && i || nil}.compact)
  @@mapping = mapping
end

post '/generate' do
  X_values = params.values.map { |v| v.to_i }

  lowest_mse = 10000000
  lowest_mp = {}
  @@x_data.each_with_index do |row, index|
    next if  row.length != 1273

    mse_arr = row.each_with_index.map{|v, i| (v - X_values[i])^2 }
    mse = mse_arr.inject{|sum, el| sum + el}.to_f/mse_arr.size
    if mse < lowest_mse
      lowest_mp = @@mp_data[index]
      lowest_mse = mse
    end
  end

  X_array = [1, X_values].flatten
  X = Matrix[X_array]
  arr = (X * @@theta).collect { |e| 1/(1+Math.exp(-e)) }.to_a[0]

  hash_arr = []

  arr.each_with_index do |pred, index|
    hash_arr << {:party => @@mapping[index], :percentage => pred, :colour => colour_for(@@mapping[index])} unless index == 5
  end

  content_type :json

  {:parties => hash_arr, :mp => lowest_mp}.to_json
end

def colour_for(party)
  case party
  when "Con"
    "#184050"
  when "Ind Con"
    "#184050"
  when "Lab"
    "#ee2d24"
  when "Lab/Co-op"
    "#ee2d24"
  when "Ind Lab"
    "#ee2d24"
  when "LDem"
    "#fdbb30"
  when "PC"
    "#3f8429"
  when "UKUP"
    "#9a00ce"
  when "SDLP"
    "#30ce2f"
  when "UUP"
    "#9d99ff"
  when "SNP"
    "#fff95d"
  when "DUP"
    "#c23200"
  else
    "#ffffff"
  end
end

__END__

@@layout
<html>
  <head>
    <script src="http://code.jquery.com/jquery-1.7.min.js" type="text/javascript"></script>
    <script src="highcharts.js" type="text/javascript"></script>
    <script type="text/javascript">
      var chart;
      $(document).ready(function() {
        $('#random').click(function() {
          $('form').each(function() {
            var random_val = Math.ceil(Math.random() * 3 - 2);
            $('input[value=' + random_val + ']', 'form#' + this.id).prop('checked', true);
          });
          $('form').first().submit();
        });

        $('input').change(function() {
          $(this).closest("form").submit();
        });

        $('form').submit(function() {
          $("#votes").animate({scrollTop: $("#votes").scrollTop() + 50}, 'slow');
          var votes_string = "";
          $('form').each(function() {
            votes_string = votes_string + this.id + "=" + $('input[name=vote]:checked', 'form#' + this.id).val() + "&";
          });

          $.ajax({
            type: 'POST',
            url: '/generate',
            data: votes_string,
            success: function(raw_data) {
              var data = raw_data['parties'];
              var values_array = [];
              var labels_array = [];
              var colours_array = [];
              $.each(data, function(index, value) {
                values_array.push(value['percentage']);
                labels_array.push(value['party']);
                colours_array.push(value['colour']);
              });

              options = {
                chart: {
                  renderTo: 'result',
                  defaultSeriesType: 'bar'
                },

                legend: {
                  enabled: false
                },

                plotOptions: {
                  series: {
                    animation: {
                      duration: 0
                    }
                  }
                },

                title: {
                  text: 'RSParly'
                },

                xAxis: {
                  categories: labels_array
                },

                yAxis: {
                  title: {
                    text: 'Similarity'
                  }
                },
    
                series: []
              };

              series = {data: []};

              $.each(values_array, function(index, value) {
                series.data.push({ y: value, color: colours_array[index] });
              });

              options.series.push(series);

              chart = new Highcharts.Chart(options);

              $('div#mp_result').html(raw_data['mp']);
            }
          });
          
          return false;
        });

        $("form").first().submit();
      });
    </script>
    <style type="text/css">
      div#votes {
        height: 200px;
        overflow: hidden;
      }
      div.vote {
        height: 50px;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <%= yield %>
  </body>
</html>

@@home
<div id="result">
</div>
Your similarity to overall parties is shown above. In terms of individual MPs, your views are the closest to: 
<div id="mp_result">
</div>
<a href="#" id="random">Random</a>
<div id="votes">
<% @votes.each do |vote| %>
  <div class="vote">
    <b><%= vote[:question] %></b>
    <form id="<%= vote[:id] %>">
      <input type="radio" name="vote" value="1">Yes</input>
      <input type="radio" name="vote" value="0" checked>Abstain</input>
      <input type="radio" name="vote" value="-1">No</input>
    </form>
  </div>
<% end %>
</div>
