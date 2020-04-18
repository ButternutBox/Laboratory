require 'rack/test'
require 'laboratory/ui'

RSpec.describe Laboratory::UI do
  include Rack::Test::Methods

  def app
    @app ||= described_class
  end

  it 'should respond to /' do
    get '/'
    expect(last_response).to be_ok
  end
end
