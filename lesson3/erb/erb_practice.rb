require 'erb'

def random_number
  (0..9).to_a.sample
end

content1 = ERB.new("<html><body><p>The number is: <%= random_number %>!</p></body></html>")
p content1.result

content2 = ERB.new("<html><body><p>The number is: <%= random_number %>!</p></body></html>")
p content2.result