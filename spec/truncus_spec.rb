require "spec_helper"

RSpec.describe Truncus do
  it "has a version number" do
    expect(Truncus::VERSION).not_to be nil
  end


  describe 'expand_token' do
    it 'should return url' do
      VCR.use_cassette 'expanding' do
        url = Truncus::Client.expand_token 'X6tqvC'
        expect(url).to eq('http://google.com')
      end
    end
  end


  describe 'get_token' do
    it 'should return token' do
      VCR.use_cassette 'shortening' do
        token = Truncus::Client.get_token 'google.com'
        expect(token).not_to be_nil
        expect(token).to match(%r[[a-z0-9]{6,8}]i)
      end
    end
  end


  describe 'get_url' do
    it 'should return url' do
      VCR.use_cassette 'shortening' do
        url = Truncus::Client.get_url 'google.com'
        expect(url).to match(%r[https://trunc.us/[a-z0-9]{6,8}]i)
      end
    end
  end

end
