require 'spec_helper'
require 'benchmark'

describe Jedlik::Connection do
  describe "#post" do
    before do
      Time.stub!(:now).and_return(Time.at(1332635893)) # Sat Mar 24 20:38:13 -0400 2012
    end

    it "signs and posts a request" do
      mock_service = mock(Jedlik::SecurityTokenService,
        :session_token => "session_token",
        :access_key_id => "access_key_id",
        :secret_access_key => "secret_access_key"
      )

      stub_request(:post, "https://dynamodb.us-east-1.amazonaws.com/").
        with(
          :body     => "{}",
          :headers  => {
            'Content-Type'          => 'application/x-amz-json-1.0', 
            'Host'                  => 'dynamodb.us-east-1.amazonaws.com', 
            'X-Amz-Date'            => 'Sun, 25 Mar 2012 00:38:13 GMT', 
            'X-Amz-Security-Token'  => 'session_token', 
            'X-Amz-Target'          => 'DynamoDB_20111205.ListTables', 
            'X-Amzn-Authorization'  => 'AWS3 AWSAccessKeyId=access_key_id,Algorithm=HmacSHA256,Signature=2xa6v0WW+980q8Hgt+ym3/7C0D1DlkueGMugi1NWE+o='
          }
        ).
        to_return(
          :status => 200,
          :body => '{"TableNames":["example"]}',
          :headers => {}
        )

      Jedlik::SecurityTokenService.stub!(:new).and_return(mock_service)
      connection = Jedlik::Connection.new("key_id", "secret")
      result = connection.post :ListTables
      result.should == {"TableNames" => ["example"]}
    end
  end
end
