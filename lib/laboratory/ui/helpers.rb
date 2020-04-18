module Laboratory
  module UIHelpers
    def url(*path_parts)
      [path_prefix, path_parts].join('/').squeeze('/')
    end

    def path_prefix
      request.env['SCRIPT_NAME']
    end

    def experiment_url(experiment)
      url('experiments', CGI.escape(experiment.id), 'edit')
    end

    def update_percentages_url(experiment)
      url('experiments', CGI.escape(experiment.id), 'update_percentages')
    end

    def assign_users_to_variant_url(experiment)
      url('experiments', CGI.escape(experiment.id), 'assign_users')
    end

    def reset_experiment_url(experiment)
      url('experiments', CGI.escape(experiment.id), 'reset')
    end

    def analysis_summary(experiment, event_id)
      return if experiment.variants.length < 2

      analysis = experiment.analysis_summary_for(event_id)

      "#{analysis.highest_performing_variant.id} is performing" \
      " #{analysis.performance_delta_between_highest_and_lowest * 100}%" \
      " better than #{analysis.lowest_performing_variant.id}. I'm" \
      " #{analysis.confidence_level_in_performance_delta * 100}% certain of" \
      ' this.'
    end
  end
end
