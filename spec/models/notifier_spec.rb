# encoding: utf-8

require 'spec_helper'

describe Notifier do
  describe "#create" do
    context "success" do
      let(:attributes) do
        {
          label: 'arbitrary_label',
          log_path: '/var/log/syslog',
          regexp: 'warn',
          exclude: 'exclude',
          email_from: 'spec@haikanko.com',
          roles: [Fabricate.build(:role_one), Fabricate.build(:role_two)],
          ircs: [Fabricate.build(:irc_one), Fabricate.build(:irc_two)],
          emails: [Fabricate.build(:email_one), Fabricate.build(:email_two)],
        }
      end
      subject { Notifier.create(attributes) }
      its('label') { should == attributes[:label] }
      its('regexp') { should == attributes[:regexp] }
      its('exclude') { should == attributes[:exclude] }
      its('roles') { should be_present }
      its('ircs') { should be_present }
      its('emails') { should be_present }
      it { Role.find(subject.roles.first.id).should be_present }
      it { Irc.find(subject.ircs.first.id).should be_present }
      it { Email.find(subject.emails.first.id).should be_present }
    end
  end

  describe "#update" do
    context "success" do
      let!(:resource) { Fabricate(:notifier) }
      let(:attributes) do
        {
          label: 'arbitrary_label',
          log_path: '/var/log/syslog',
          regexp: 'warn',
          exclude: 'exclude',
          email_from: 'spec@haikanko.com',
          roles: [Fabricate.build(:role_one), Fabricate.build(:role_two)],
          ircs: [Fabricate.build(:irc_one), Fabricate.build(:irc_two)],
          emails: [Fabricate.build(:email_one), Fabricate.build(:email_two)],
        }
      end
      subject { resource.tap{|r| r.update_attributes(attributes) } }
      its('label') { should == attributes[:label] }
      its('regexp') { should == attributes[:regexp] }
      its('exclude') { should == attributes[:exclude] }
      its('roles') { should be_present }
      its('ircs') { should be_present }
      its('emails') { should be_present }
      it { Role.find(subject.roles.first.id).should be_present }
      it { Irc.find(subject.ircs.first.id).should be_present }
      it { Email.find(subject.emails.first.id).should be_present }
    end
  end

  describe "#validates_uniqueness_of :label" do
    before { Fabricate(:notifier) }
    subject { Fabricate.build(:notifier) }
    before { subject.valid? }
    it { subject.errors.messages[:label].should == ["is already taken"] }
  end

  describe "#validates_regexp" do
    subject { Fabricate.build(:notifier, :regexp => '*') }
    before { subject.valid? }
    it { subject.errors.messages[:regexp].should == ["is invalid"] }
  end

  describe "#validates_exclude" do
    subject { Fabricate.build(:notifier, :exclude => '*') }
    before { subject.valid? }
    it { subject.errors.messages[:exclude].should == ["is invalid"] }
  end

end
