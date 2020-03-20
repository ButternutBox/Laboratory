# frozen_string_literal: true

RSpec.describe Laboratory::Config do
  it 'should have an attr_accessor called adapter' do
    expect(described_class).to have_attr_accessor(:adapter)
  end

  it 'should have an attr_accessor called current_user_id' do
    expect(described_class).to have_attr_accessor(:current_user_id)
  end

  it 'should have an attr_accessor called actor' do
    expect(described_class).to have_attr_accessor(:actor)
  end

  it 'should have an attr_accessor called on_assignment_to_variant' do
    expect(described_class).to have_attr_accessor(:on_assignment_to_variant)
  end

  it 'should have an attr_accessor called on_event_recorded' do
    expect(described_class).to have_attr_accessor(:on_event_recorded)
  end
end
