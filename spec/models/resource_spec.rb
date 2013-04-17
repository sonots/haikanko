# encoding: utf-8

require 'spec_helper'

%w(notifier visualizer irc host email role).each do |type|
  describe type do
    let(:resource) { Fabricate.build(type) }

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

    describe "#duplicate" do
      before { resource.save! }
      subject { resource.duplicate }
      its(:id) { should_not == resource.id }
      its(:label) { should == "Copy of #{resource.label}" }
    end

    describe "#enabled?" do
      subject { resource.enabled? }

      context "true" do
        it { should == true }
      end

      if Fabricate.build(type).respond_to?(:disabled_at)
        context "false" do
          before { resource.disable! }
          it { should == false }
        end
      end
    end

    describe "#disabled?" do
      before { resource.disable! }
      subject { resource.disabled? }

      if Fabricate.build(type).respond_to?(:disabled_at)
        context "true" do
          it { should == true }
        end
      end

      context "false" do
        before { resource.enable! }
        it { should == false }
      end
    end

    describe "#on_errors" do
      subject { resource.on_errors(12) }

      its(:id) { should == 12 }
      its(:created_at) { should_not be_nil }
    end

    describe "#finds" do
      before { resource.save! }
      subject { resource.class.finds([resource.label, resource.label]) }

      it { subject.first.should == resource }
    end
  end
end
