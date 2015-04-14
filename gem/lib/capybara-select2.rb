require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = first(:css, options[:css])
      else
        select_name = options[:from]
        select2_container = first("label", text: select_name).find(:xpath, '..').find(".select2-container")
      end

      # Open select2 field
      select2_container.find(".select2-selection").click

      if options.has_key? :search
        find(:xpath, "//body").find(".select2-with-searchbox input.select2-input").set(value)
        page.execute_script(%|$("input.select2-input:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-dropdown"
      end

      [value].flatten.each do |value|
        find(:xpath, "//body").find("#{drop_container} li.select2-results__option span", text: /#{value}/i).click
      end
    end

    def select2_include?(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = first(:css, options[:css])
      else
        select_name = options[:from]
        label = first("label", text: select_name)
        select2_container = label.find(:xpath, '..').find(".select2-container")
      end

      # Open select2 field
      select2_container.find(".select2-selection").click

      # Search for value in pop up dropdown box
      find(:css, "span.select2-container--open span.select2-results ul#select2-#{label['for']}-results").text.include?(value)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
