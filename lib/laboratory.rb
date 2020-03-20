require 'laboratory/version'
require 'laboratory/config'
require 'laboratory/user'
require 'laboratory/adapters/redis_adapter'
require 'laboratory/adapters/mock_adapter'
require 'laboratory/algorithms/random'
require 'laboratory/algorithms'
require 'laboratory/experiment'
require 'laboratory/experiment/variant'
require 'laboratory/experiment/changelog_item'
require 'laboratory/experiment/event'
require 'laboratory/experiment/event/recording'

module Laboratory
  class << self
    def config
      Laboratory::Config
    end
  end
end
