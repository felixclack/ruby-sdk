require 'test_helper'

describe Transloadit::Response do
  REQUEST_URI = 'http://api2.jane.transloadit.com/assemblies/76fe5df1c93a0a530f3e583805cf98b4'
  
  it 'must allow delegate initialization' do
    response = Transloadit::Response.new('test')
    response.class.must_equal Transloadit::Response
  end
  
  describe 'when initialized' do
    before do
      VCR.use_cassette 'fetch_assembly' do
        @response = Transloadit::Response.new(
          RestClient::Resource.new(REQUEST_URI).get
        )
      end
    end
    
    it 'must parse the body' do
      @response.body.must_be_kind_of Hash
    end
    
    it 'must allow access to body attributes' do
      %w{ ok message assembly_id assembly_url }.each do |attribute|
        @response[attribute].must_equal @response.body[attribute]
      end
    end
    
    it 'must inspect as the body' do
      @response.inspect.must_equal @response.body.inspect
    end
  end
  
  describe 'when extended as an assembly' do
    before do
      VCR.use_cassette 'fetch_assembly' do
        @response = Transloadit::Response.new(
          RestClient::Resource.new(REQUEST_URI).get
        ).extend!(Transloadit::Response::Assembly)
      end
    end
    
    it 'must allow checking for completion' do
      @response.completed?.must_equal true
    end
    
    # TODO: can this be tested better?
    it 'must allow reloading the assembly' do
      VCR.use_cassette 'fetch_assembly' do
        @response.send(:__getobj__).
          wont_be_same_as @response.reload!.send(:__getobj__)
        
        @response.object_id.
          must_equal @response.reload!.object_id
      end
    end
    
    it 'must allow canceling' do
      VCR.use_cassette 'cancel_assembly' do
        @response.cancel!
        
        @response.completed?.must_equal false
        @response['ok']     .must_equal 'ASSEMBLY_CANCELED'
      end
    end
  end
end
