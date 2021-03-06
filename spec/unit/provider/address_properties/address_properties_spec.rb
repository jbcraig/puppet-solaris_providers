require 'spec_helper'

describe Puppet::Type.type(:address_properties).provider(:address_properties) do

  let(:resource) {
    Puppet::Type.type(:address_properties).new(
      :name => 'myobj',
      :ensure => :present,
    )
  }
  let(:provider) { described_class.new(resource) }


  context 'with a multi-property interface' do
    before :each do
      described_class.stubs(:ipadm).with("show-addrprop", "-c", "-o",
                                         "ADDROBJ,PROPERTY,CURRENT,PERM").returns File.read(my_fixture('show-addrprop-ADDROBJ-PROPERTY-CURRENT-PERM.txt'))
    end

    it 'should find one object' do
      expect(described_class.instances.size).to eq(4)
    end

    it 'should parse the object properly' do
      expect(
        described_class.instances[0].
          instance_variable_get("@property_hash")).
        to eq( {
                 :name    => "lo0/v4",
                 :ensure     => :present,
                 :properties => {
                   "deprecated"=> "off",
                   "prefixlen" => "8",
                   "private"   => "off",
                   "transmit"  => "on",
                   "zone"      => "global"
                 }
               } )
    end
  end

  [ "exists?", "create" ].each do |method|
    it "should have a #{method} method" do
      expect(provider.class.method_defined?(method)).to eq(true)
    end
  end

  [ "properties" ].each do |property|
    it "should find a writer for #{property}" do
      expect(provider.class.method_defined?(property.to_s+"=")).to eq(true)
    end
  end

end
