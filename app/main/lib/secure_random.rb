if RUBY_PLATFORM == 'opal'
  class SecureRandom
    # `SecureRandom.urlsafe_base64` is missing from opal
    def self.urlsafe_base64(length = 16)
      string = ''

      loop do
        string += `Math.random().toString(36).substr(2)`
        break if string.length >= length
      end

      string[0, length]
    end
  end
end
