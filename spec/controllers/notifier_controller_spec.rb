# encoding: utf-8
require 'spec_helper'

shared_context 'edit_notifier_controller' do |button = 'Create', params = {}|
  before do
    # use default parameters
    fill_in 'notifier[label]',    :with => params["label"]    if params["label"]
    fill_in 'notifier[roles][0]',    :with => params["roles"][0]    if params["roles"]
    fill_in 'notifier[log_path]', :with => params["log_path"] if params["log_path"]
    fill_in 'notifier[regexp]',   :with => params["regexp"]   if params["regexp"]
    fill_in 'notifier[ircs][0]',   :with => params["ircs"][0]   if params["irc_label"]
    fill_in 'notifier[emails][0]', :with => params["emails"][0] if params["email_label"]
    click_button button
  end
end

shared_examples_for "show_notifier_controller" do
  it { status_code.should == 200 }
  it { find_field("notifier[label]").should be_visible }
  it { find_field("notifier[roles][0]").should be_visible }
  it { find_field("notifier[log_path]").should be_visible }
  it { find_field("notifier[regexp]").should be_visible }
  it { find_field("notifier[ircs][0]").should be_visible }
  it { find_field("notifier[emails][0]").should be_visible }
end

describe Web::NotifierController do
  describe "get /web/notifier/new" do
    before { visit "/web/notifier/new" }
    it_should_behave_like "show_notifier_controller"
  end

  describe "post /web/notifier/new" do
    before { visit "/web/notifier/new" }
    context 'success' do
      include_context 'edit_notifier_controller', 'Create'
      it_should_behave_like 'create_success_controller'
    end

    context 'failure' do
      include_context 'edit_notifier_controller', 'Create', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "#{Notifier.human_attribute_name(:label)} can't be blank" }
    end
  end

  describe "get /web/notifier/:notifier_id" do
    before { visit "/web/notifier/new" }
    include_context 'edit_notifier_controller', 'Create'
    it_should_behave_like "show_notifier_controller"
  end

  describe "post /web/notifier/:notifier_id" do
    before { visit "/web/notifier/new" }
    include_context 'edit_notifier_controller', 'Create'

    context 'success' do
      include_context 'edit_notifier_controller', 'Update'
      it_should_behave_like 'success_controller'
    end

    context 'failure' do
      include_context 'edit_notifier_controller', 'Update', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "#{Notifier.human_attribute_name(:label)} can't be blank" }
    end
  end

  # @todo: javascript test
=begin
  describe "post /web/notifier/:notifier_id/duplicate" do
    before { visit "/web/notifier/new" }
    include_context 'edit_notifier_controller', 'Create'

    context 'success' do
      let(:notifier_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/notifier/#{notifier_id}/duplicate" }
      it { status_code.should == 302 }
    end
  end
=end

  describe "post /web/notifier/:notifier_id/disable" do
    before { visit "/web/notifier/new" }
    include_context 'edit_notifier_controller', 'Create'

    context 'success' do
      let(:notifier_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/notifier/#{notifier_id}/disable" }
      it { status_code.should == 302 }

      context 'post /web/notifier/:notifier_id/enable' do
        before { Capybara.current_session.driver.post "/web/notifier/#{notifier_id}/enable" }
        it { status_code.should == 302 }
      end
    end
  end

  describe "post /web/notifier/:notifier_id/delete" do
    before { visit "/web/notifier/new" }
    include_context 'edit_notifier_controller', 'Create'

    context 'success' do
      let(:notifier_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/notifier/#{notifier_id}/delete" }
      it { status_code.should == 302 }
    end
  end
end

