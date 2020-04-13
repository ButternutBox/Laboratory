require 'sinatra/base'
require 'laboratory'
require 'laboratory/ui/helpers'

module Laboratory
  class UI < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views, "#{dir}/ui/views"
    set :public_folder, "#{dir}/ui/public"
    set :static, true
    set :method_override, true

    helpers Laboratory::UIHelpers

    get '/' do
      @experiments = Laboratory::Experiment.all
      erb :index
    end

    get '/experiments/:id/edit' do
      @experiment = Laboratory::Experiment.find(CGI.unescape(params[:id]))
      erb :edit
    end

    # params = {variants: { control => 40, variant_a => 60 }}
    post '/experiments/:id/update_percentages' do
      experiment = Laboratory::Experiment.find(CGI.unescape(params[:id]))

      params[:variants].each do |variant_id, percentage|
        variant = experiment.variants.find { |v| v.id == variant_id }
        variant.percentage = percentage.to_i
      end

      experiment.save
      redirect experiment_url(experiment)
    end

    # params = {variant_id: 'control', user_ids: []}
    post '/experiments/:id/assign_users' do
      experiment = Laboratory::Experiment.find(CGI.unescape(params[:id]))
      variant = experiment.variants.find { |v| v.id == params[:variant_id] }
      user_ids = params[:user_ids].split("\r\n")

      user_ids.each do |user_id|
        user = Laboratory::User.new(id: user_id)
        experiment.assign_to_variant(variant.id, user: user)
      end

      redirect experiment_url(experiment)
    end

    post '/experiments/:id/reset' do
      experiment = Laboratory::Experiment.find(CGI.unescape(params[:id]))
      experiment.reset
      redirect experiment_url(experiment)
    end
  end
end
