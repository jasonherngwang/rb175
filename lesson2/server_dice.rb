require 'socket'

server = TCPServer.new('localhost', 3003) # Non-standard port

def parse_request(request_line)
    # Pass query parameters (key/value)
    # http://localhost:3003/?rolls=2&sides=6
    # http_method === 'GET'
    # path == '/'
    # params = { 'rolls' => '2', 'sides' => '6' }      # Note: Numbers are still strings.

    # Regex solution
    # http_method = request_line.match(/([A-Z]+) /)[1]
    # path = request_line.match(/(\/.*?)(\?| )/)[1]      # lazy regex
    # params = request_line.match(/\?(.+) /)[1]
    #   .split('&')
    #   .map { |param| param.split('=') }
    #   .to_h

    http_method, path_and_params, http_version = request_line.split
    path, params = path_and_params.split('?')
    params = params.split('&').map { |param| param.split('=') }.to_h
    
    [http_method, path, params, http_version]
end

# Listen on port, indefinitely.
loop do
  client = server.accept       # Accept incoming connection; return new TCPSocket object.

  request_line = client.gets   # First line of GET request.
  next if !request_line || request_line =~ /favicon/    # In case requestn /favicon.ico raises an exception.
  puts request_line

  http_method, path, params, http_version = parse_request(request_line)

  client.puts "HTTP/1.1 200 OK"                   # Chrome requires a well-formed response first.
  client.puts "Content-Type: text/html\r\n\r\n"  # Must have a blank line between status line and message body.
  
  client.puts <<~HTML
  <html>
  <body>
  <pre>
  #{http_method}
  #{path}
  #{params}
  </pre>
  <h1>Rolls!</h1>
  HTML
  # client.puts request_line     # IO#puts message body
  # client.puts http_method
  # client.puts path
  # client.puts params
  # client.puts http_version
  
  rolls = params['rolls'].to_i
  sides = params['sides'].to_i
  rolls.times do
    roll = rand(sides) + 1
    client.puts '<p>', roll, '</p>'      # Roll dice
  end

  client.puts '</body>'
  client.puts '</html>'
  
  client.close                 # IO#close
end

