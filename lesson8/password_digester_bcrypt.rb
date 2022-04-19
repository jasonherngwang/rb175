require 'bcrypt'
class PasswordDigester
  def self.encrypt(password)
    BCrypt::Password.create(password)
  end
  def self.check?(password, encrypted_password)
    BCrypt::Password.new(encrypted_password) == password
  end
end
# For testing
# if $0 == __FILE__
#   password = ARGV.shift
#   encrypted = PasswordDigester.encrypt password
#   success = PasswordDigester.check? password, encrypted
#   puts encrypted, success
# end