# Uses SHA1 algo to hash a string

require 'digest/sha1'
class PasswordDigester
  SALT_SIZE = 3
  def self.encode(password)
    salt = "%0#{SALT_SIZE}x" % rand(16**SALT_SIZE)
    digest salt, password
  end
  def self.check?(password, encrypted_password)
    salt = encrypted_password[0, SALT_SIZE]
    encrypted_password == digest(salt, password)
  end
  private
  def self.digest(salt, password)
    salt + Digest::SHA1.hexdigest(salt + password)
  end
end
# For testing
if $0 == __FILE__
  password = ARGV.shift
  encoded = PasswordDigester.encode password
  success = PasswordDigester.check? password, encoded
  puts encoded, success
end