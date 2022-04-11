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
    params = (params || '').split('&').map { |param| param.split('=') }.to_h   # Avoid nil.split
    
    [http_method, path, params, http_version]
end

# Listen on port, indefinitely.
loop do
  client = server.accept       # Accept incoming connection; return new TCPSocket object. Server starts listening on 3003.

  request_line = client.gets   # First line of GET request.
  next if !request_line || request_line =~ /favicon/    # In case requestn /favicon.ico raises an exception.
  puts request_line

  next unless request_line

  http_method, path, params, http_version = parse_request(request_line)

  # Whenever we use puts to write to the server, the server includes that text in its response.
  # Therefore we can see what we are writing on the web page.
  client.puts "HTTP/1.1 200 OK"                   # Chrome requires a well-formed response first.
  client.puts "Content-Type: text/html\r\n\r\n"  # Must have a blank line between status line and message body.
  
  # Note: href uses relative path
  number = params['number'].to_i
  client.puts <<~HTML
  <html>
  <body>
  <pre>
  #{http_method}
  #{path}
  #{params}
  </pre>
  <h1>Counter</h1>
  <p>The current number is #{number}.</p>
  <a href='?number=#{number + 1}'>Add one</a>
  <a href='?number=#{number - 1}'>Subtract one</a>
  </body>
  </html>
  HTML
  
  client.close                 # IO#close
end

