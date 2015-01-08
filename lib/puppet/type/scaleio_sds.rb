Puppet::Type.newtype(:scaleio_sds) do
  @doc = "Manage ScaleIO SDS's"

  ensurable

  validate do
    validate_required(:pool_devices, :protection_domain, :ips)
  end

  newparam(:name, :namevar => true) do
    desc "The SDS name"
    validate do |value|
      fail("#{value} is not a valid value for SDS name.") unless value =~ /^[\w\-]+$/
    end
  end

  newproperty(:ips, :array_matching => :all) do
    desc "The SDS IP address/addresses"
    validate do |value|
      fail("#{value} is not a valid IPv4 address") unless IPAddr.new(value).ipv4?
    end
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:port) do
    desc "The SDS port address"
    validate do |value|
      fail("#{value} is not a valid value for SDS port.") unless value.is_a? Integer
    end
  end

  newproperty(:pool_devices) do
    desc "Pools and the devices of the SDS"
    validate do |value|
      fail("pool_devices should be a hash with the pool name as key and an array with the devices as value.") unless value.class == Hash
    end
  end

  newproperty(:protection_domain) do
    desc "The protection domain name"
  end

  autorequire(:scaleio_protection_domain) do
    [ self[:protection_domain] ].compact
  end

  autorequire(:scaleio_storage_pool) do
    self[:pool_devices].each do |storage_pool, devices|
      [ "#{self[:protection_domain]}:#{storage_pool}" ].compact
    end
  end

  # helper method, pass required parameters
  def validate_required(*required_parameters)
    if self[:ensure] == :present
      required_parameters.each do |req_param|
        raise ArgumentError, "parameter '#{req_param}' is required" if self[req_param].nil?
      end
    end
  end

end
