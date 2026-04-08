class SlugGenerator
  ALPHABET = (("a".."z").to_a + ("0".."9").to_a).freeze
  DEFAULT_LENGTH = 7

  def self.generate(length: DEFAULT_LENGTH)
    loop do
      slug = Array.new(length) { ALPHABET.sample }.join
      return slug unless Link.exists?(slug: slug)
    end
  end
end
