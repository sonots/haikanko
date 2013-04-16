require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# @reference: http://blog.glidenote.com/blog/2012/07/15/fluentd-regex-debug/
format = /^(?<date>[^ ]+)\s+(?<duration>.*) (?<client address>.*) (?<result code>.*) (?<bytes>.*) (?<request method>.*) (?<url>.*) (?<rfc931>.*) (?<hierarchy code>.*) (?<type>.*)$/
parser = Fluent::TextParser::RegexpParser.new(format, 'time_format' => '')

describe "sample log" do
  subject { parser.call(@log)[1] }

  context 'when log text has all values' do
    before(:all) { @log = '1342297357.149    440 192.168.11.3 TCP_MISS/302 627 GET http://example.com - HIER_DIRECT/75.126.109.204 text/javascript' }
    it { subject.keys.should =~ [ "date", "duration", "client address", "result code", "bytes", "request method", "url", "rfc931", "hierarchy code", "type" ] }
  end

  context 'when log text does not have all values' do
    before(:all) { @log = '1342297357.149' }
    it { should be_nil }
  end
end
