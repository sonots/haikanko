# encoding: utf-8

require 'spec_helper'

%w(notifier irc).each do |type|
  describe type do
    let(:resource) { Fabricate.build(type.to_sym) }

    describe "#new?" do
      subject { resource.new? }

      context "true" do
        it { should == true }
      end

      context "false" do
        before  { resource.save }
        it { should == false }
      end
    end

    describe "#error?" do
      subject { resource.error? }

      context "false" do
        it { should == false }
      end

      context "true" do
        before  { resource.label = nil }
        it { should == true }
      end
    end

    describe "#enabled?" do
      subject { resource.enabled? }

      context "true" do
        it { should == true }
      end

      if type == "notifier"
        context "false" do
          before  { resource.disabled_at = Time.now }
          it { should == false }
        end
      end
    end

    describe "#duplicate" do
      before { resource.save! }
      subject { resource.duplicate }
      its(:id) { should_not == resource.id }
      its(:label) { should == resource.label }
    end
  end
end
