# encoding: utf-8
require 'spec_helper'

shared_context 'edit_irc_controller' do |button = 'Create', params = {}|
  before do
    fill_in 'irc[label]',    :with => params["label"]      if params["label"]
    fill_in 'irc[channel]', :with => params["channel"] if params["channel"]
    fill_in 'irc[staff]',   :with => params["staff"]   if params["staff"]
    click_button button
  end
end

shared_examples_for "show_irc_controller" do
  it { status_code.should == 200 }
  it { find_field("irc[label]").should be_visible }
  it { find_field("irc[channel]").should be_visible }
  it { find_field("irc[staff]").should be_visible }
end

describe Web::IrcController do
  describe "get /web/irc/new" do
    before { visit "/web/irc/new" }
    it_should_behave_like "show_irc_controller"
  end

  describe "post /web/irc/new" do
    before { visit "/web/irc/new" }
    context 'success' do
      include_context 'edit_irc_controller', 'Create'
      it_should_behave_like 'create_success_controller'
    end

    context 'failure' do
      include_context 'edit_irc_controller', 'Create', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "Label can't be blank" }
    end
  end

  describe "get /web/irc/:irc_id" do
    before { visit "/web/irc/new" }
    include_context 'edit_irc_controller', 'Create'
    it_should_behave_like "show_irc_controller"
  end

  describe "post /web/irc/:irc_id" do
    before { visit "/web/irc/new" }
    include_context 'edit_irc_controller', 'Create'

    context 'success' do
      include_context 'edit_irc_controller', 'Update'
      it_should_behave_like 'success_controller'
    end

    context 'failure' do
      include_context 'edit_irc_controller', 'Update', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "Label can't be blank" }
    end
  end

=begin
  # @todo: javascript test
  describe "post /web/irc/:irc_id/duplicate" do
    before { visit "/web/irc/new" }
    include_context 'edit_irc_controller', 'Create'

    context 'success' do
      let(:irc_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/irc/#{irc_id}/duplicate" }
      it { status_code.should == 302 }
    end
  end
=end

  describe "post /web/irc/:irc_id/delete" do
    before { visit "/web/irc/new" }
    include_context 'edit_irc_controller', 'Create'

    context 'success' do
      let(:irc_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/irc/#{irc_id}/delete" }
      it { status_code.should == 302 }
    end
  end
end

