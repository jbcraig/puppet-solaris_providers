require 'spec_helper'

describe Puppet::Type.type(:ipmp_interface) do

  # Modify params inline to tests to change the resource
  # before it is generated
  let(:params) do
    {
      :name => "ipmp0",
      :interfaces => %w(net0 net1),
      :ensure => :present
    }
      end

  # Modify the resource inline to tests when you modeling the
  # behavior of the generated resource
  let(:resource) { described_class.new(params) }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }


  let(:error_pattern) { /Invalid/ }

  it "has :name as its keyattribute" do
    expect( described_class.key_attributes).to be == [:name]
  end

  describe "has property" do
    [ :interfaces ].each { |prop|
      it prop do
        expect(described_class.attrtype(prop)).to be == :property
      end
    }
  end

  describe "parameter validation" do
    context "accepts interfaces" do
      [ %w(net0),
        %w(net0 net1 net2),
        %w(ab1),
        %w(ab_1),
        %w(a1b1),
        [("a"*15) + "0"]
      ].each do |thing|
        it thing.inspect do
          params[:interfaces] = thing
          expect { resource }.not_to raise_error
        end
      end
    end # Accepts interface
    context "rejects interface" do
      %w(
        a1
        aaa
        aaaaaaaaaaaaaaa01
        Net0
      ).each do |thing|
        it thing.inspect do
          params[:interfaces] = thing
          expect { resource }.to raise_error(Puppet::Error, error_pattern)
        end
      end
    end # Rejects interface
    context "accepts temporary" do
      [:true,:false].each do |thing|
        it thing.inspect do
          params[:temporary] = thing
          expect { resource }.not_to raise_error
        end
      end
    end # Accepts temporary
    context "rejects temporary" do
      %w(yes no).each do |thing|
        it thing.inspect do
          params[:temporary] = thing
          expect { resource }.to raise_error(Puppet::Error, error_pattern)
        end
      end
    end # Rejects temporary
  end
  describe "autorequire" do
    context "ip_interface" do
      def add_resource(name,res_type)
        sg = Puppet::Type.type(res_type).new(:name => name)
        catalog.add_resource sg
        sg
      end
      it "does not require ip_interface when no matching resource exists" do
        add_resource("notnet0",'ip_interface')
        catalog.add_resource resource
        expect(resource.autorequire).to be_empty
      end
      it "requires ip_interface when matching resource exists" do
        new_res0 = add_resource('net0','ip_interface')
        new_res1 = add_resource('net1','ip_interface')
        catalog.add_resource resource
        reqs = resource.autorequire
        expect(reqs.count).to eq 2
        expect(reqs[0].source).to eq new_res0
        expect(reqs[0].target).to eq resource
        expect(reqs[1].source).to eq new_res1
        expect(reqs[1].target).to eq resource
      end
    end
  end
end
