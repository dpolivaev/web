# frozen_string_literal: true

class IdGenerator

  ALPHABET = %w{
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h   j k l m n   p q r s t u v w x y z
  }.join.freeze

  def initialize(externals)
    @externals = externals
  end

  def id
    generated = 6.times.map{ ALPHABET[random_index] }.join
    if reserved?(generated)
      id
    else
      generated
    end
  end

  def self.id?(s)
    s.is_a?(String) &&
      s.length === 6 &&
        s.chars.all?{ |ch| ALPHABET.include?(ch) }
  end

  private

  SAVER_OFFLINE_ID = '999999'

  def reserved?(id)
    id === SAVER_OFFLINE_ID
  end

  def random_index
    random.rand(ALPHABET.size)
  end

  def random
    @externals.random
  end

end

# Similar to https://en.wikipedia.org/wiki/Base58
# o) includes the digits zero and one
#    (to be backwards compatible as hex)
# o) excludes the letters IO
#    (India,Oscar) both lowercase and uppercase
#
# Within a single server it is easy to guarantee
# there are no ID clashes. However, the larger
# the alphabet the less you have to worry about
# ID clashes when merging server sessions.
#
# 58^6 == 38,068,692,544 == 38 billion
