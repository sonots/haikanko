# encoding: utf-8
require 'spec_helper'

shared_context 'edit_email_controller' do |button = 'Create', params = {}|
  before do
    fill_in 'email[label]',     :with => params["label"]     if params["label"]
    fill_in 'email[mail_from]', :with => params["mail_from"] if params["mail_from"]
    fill_in 'email[email_to]',   :with => params["email_to"]   if params["email_to"]
    click_button button
  end
end

shared_examples_for "show_email_controller" do
  it { status_code.should == 200 }
  it { find_field("email[label]").should be_visible }
  it { find_field("email[mail_from]").should be_visible }
  it { find_field("email[email_to]").should be_visible }
end

describe Web::EmailController do
  describe "get /web/email/new" do
    before { visit "/web/email/new" }
    it_should_behave_like "show_email_controller"
  end

  describe "post /web/email/new" do
    before { visit "/web/email/new" }
    context 'success' do
      include_context 'edit_email_controller', 'Create'
      it_should_behave_like 'create_success_controller'
    end

    context 'failure' do
      include_context 'edit_email_controller', 'Create', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "Label can't be blank" }
    end
  end

  describe "get /web/email/:email_id" do
    before { visit "/web/email/new" }
    include_context 'edit_email_controller', 'Create'
    it_should_behave_like "show_email_controller"
  end

  describe "post /web/email/:email_id" do
    before { visit "/web/email/new" }
    include_context 'edit_email_controller', 'Create'

    context 'success' do
      include_context 'edit_email_controller', 'Update'
      it_should_behave_like 'success_controller'
    end

    context 'failure' do
      include_context 'edit_email_controller', 'Update', { "label" => "" }
      it_should_behave_like 'failure_controller'
      it { page.find("div.alert-error").find("p.code").text.should == "Label can't be blank" }
    end
  end

=begin
  # @todo: javascript test
  describe "post /web/email/:email_id/duplicate" do
    before { visit "/web/email/new" }
    include_context 'edit_email_controller', 'Create'

    context 'success' do
      let(:email_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/email/#{email_id}/duplicate" }
      it { status_code.should == 302 }
    end
  end
=end

  describe "post /web/email/:email_id/delete" do
    before { visit "/web/email/new" }
    include_context 'edit_email_controller', 'Create'

    context 'success' do
      let(:email_id) { File.basename URI.parse(page.current_url).path  }
      before { Capybara.current_session.driver.post "/web/email/#{email_id}/delete" }
      it { status_code.should == 302 }
    end
  end
end

