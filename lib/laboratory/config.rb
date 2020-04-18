module Laboratory
  class Config
    attr_accessor(
      :current_user_id,
      :adapter,
      :actor,
      :on_assignment_to_variant,
      :on_event_recorded
    )

    def current_user
      @current_user ||= Laboratory::User.new(id: current_user_id)
    end
  end
end
