if RUBY_PLATFORM == 'opal'
  class URI
    # `URI.unescape` is missing from opal
    def self.unescape(value)
      `decodeURI(value)`
    end
  end
end
