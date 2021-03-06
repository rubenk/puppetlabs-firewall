require 'spec_helper'

describe Puppet::Type.type(:firewall) do
  before :each do
    setup_resource(:firewall, {
      :name  => '000 test foo',
      :chain => 'INPUT',
      :jump  => 'ACCEPT'
    })
  end

  describe ':name' do
    it 'should accept a name' do
      @resource[:name] = '000-test-foo'
      @resource[:name].should == '000-test-foo'
    end

    it 'should not accept a name with non-ASCII chars' do
      lambda { @resource[:name] = '%*#^(#$' }.should raise_error(Puppet::Error)
    end
  end

  describe ':chain' do
    [:INPUT, :FORWARD, :OUTPUT, :PREROUTING, :POSTROUTING].each do |chain|
      it "should accept chain value #{chain}" do
        @resource[:chain] = chain
        @resource[:chain].should == chain
      end
    end

    it 'should fail when the chain value is not recognized' do
      lambda { @resource[:chain] = 'not valid' }.should raise_error(Puppet::Error)
    end
  end

  describe ':table' do
    [:nat, :mangle, :filter, :raw].each do |table|
      it "should accept table value #{table}" do
        @resource[:table] = table
        @resource[:table].should == table
      end
    end

    it "should fail when table value is not recognized" do
      lambda { @resource[:table] = 'foo' }.should raise_error(Puppet::Error)
    end
  end

  describe ':proto' do
    [:tcp, :udp, :icmp, :esp, :ah, :vrrp, :igmp, :all].each do |proto|
      it "should accept proto value #{proto}" do
        @resource[:proto] = proto
        @resource[:proto].should == proto
      end
    end

    it "should fail when proto value is not recognized" do
      lambda { @resource[:proto] = 'foo' }.should raise_error(Puppet::Error)
    end
  end

  describe ':jump' do
    [:ACCEPT, :DROP, :QUEUE, :RETURN, :REJECT, :DNAT, :SNAT, :LOG, :MASQUERADE, :REDIRECT].each do |jump|
      it "should accept jump value #{jump}" do
        @resource[:jump] = jump
        @resource[:jump].should == jump
      end
    end

    it "should fail when jump value is not recognized" do
      lambda { @resource[:proto] = 'jump' }.should raise_error(Puppet::Error)
    end
  end

  [:source, :destination].each do |addr|
    describe addr do
      it "should accept a #{addr} as a string" do
        @resource[addr] = '127.0.0.1'
        @resource[addr].should == ['127.0.0.1']
      end

      it "should accept a #{addr} as an array" do
        @resource[addr] = ['127.0.0.1', '4.2.2.2']
        @resource[addr].should == ['127.0.0.1', '4.2.2.2']
      end
    end
  end

  [:dport, :sport].each do |port|
    describe port do
      it "should accept a #{port} as string" do
        @resource[port] = '22'
        @resource[port].should == [22]
      end

      it "should accept a #{port} as an array" do
        @resource[port] = ['22','23']
        @resource[port].should == [22,23]
      end
    end
  end

  [:iniface, :outiface].each do |iface|
    describe iface do
      it "should accept #{iface} value as a string" do
        @resource[iface] = 'eth1'
        @resource[iface].should == 'eth1'
      end
    end
  end

  [:tosource, :todest].each do |addr|
    describe addr do
      it "should accept #{addr} value as a string" do
        @resource[addr] = '127.0.0.1'
      end
    end
  end

  describe ':icmp' do
    values = {
      '0' => 'echo-reply',
      '3' => 'destination-unreachable',
      '4' => 'source-quench',
      '6' => 'redirect',
      '8' => 'echo-request',
      '9' => 'router-advertisement',
      '10' => 'router-solicitation',
      '11' => 'time-exceeded',
      '12' => 'parameter-problem',
      '13' => 'timestamp-request',
      '14' => 'timestamp-reply',
      '17' => 'address-mask-request',
      '18' => 'address-mask-reply'
    }
    values.each do |k,v|
      it 'should convert icmp string to number' do
        @resource[:icmp] = v
        @resource[:icmp].should == k
      end
    end

    it 'should accept values as integers' do
      @resource[:icmp] = 9
      @resource[:icmp].should == 9
    end

    it 'should fail if icmp type is not recognized' do
      lambda { @resource[:icmp] = 'foo' }.should raise_error(Puppet::Error)
    end
  end

  describe ':state' do
    it 'should accept value as a string' do
      @resource[:state] = 'INVALID'
      @resource[:state].should == ['INVALID']
    end

    it 'should accept value as an array' do
      @resource[:state] = ['INVALID', 'NEW']
      @resource[:state].should == ['INVALID', 'NEW']
    end
  end

  describe ':burst' do
    it 'should accept numeric values' do
      @resource[:burst] = 12
      @resource[:burst].should == 12
    end

    it 'should fail if value is not numeric' do
      lambda { @resource[:burst] = 'foo' }.should raise_error(Puppet::Error)
    end
  end
end
