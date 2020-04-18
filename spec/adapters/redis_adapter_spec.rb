require 'fakeredis'
require 'json'

RSpec.describe Laboratory::Adapters::RedisAdapter do
  subject { described_class.new(url: 'redis://1234') }
  it_behaves_like 'an adapter'
end
