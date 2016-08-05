require File.expand_path '../../test_helper', __dir__

# Test class for Remove Dns Servers in Virtual Network Request
class TestRemoveDnsServersInVirtualNetwork < Minitest::Test
  def setup
    @service = Fog::Network::AzureRM.new(credentials)
    client = @service.instance_variable_get(:@network_client)
    @virtual_networks = client.virtual_networks
  end

  def test_remove_dns_servers_in_virtual_network_success
    promise_get = Concurrent::Promise.execute do
    end
    promise_create = Concurrent::Promise.execute do
    end

    mocked_response = ApiStub::Requests::Network::VirtualNetwork.create_virtual_network_response
    expected_response = ApiStub::Requests::Network::VirtualNetwork.create_virtual_network_response
    expected_response = Azure::ARM::Network::Models::VirtualNetwork.serialize_object(expected_response.body)
    expected_response['properties']['dhcpOptions']['dnsServers'].delete('10.1.0.5')

    promise_get.stub :value!, mocked_response do
      promise_create.stub :value!, mocked_response do
        @virtual_networks.stub :get, promise_get do
          @virtual_networks.stub :create_or_update, promise_create do
            assert_equal @service.remove_dns_servers_from_virtual_network('fog-test-rg', 'fog-test-virtual-network', ['10.1.0.5']), expected_response
          end
        end
      end
    end
  end

  def test_remove_dns_servers_in_virtual_network_failure
    promise = Concurrent::Promise.execute do
    end
    response = -> { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    promise.stub :value!, response do
      @virtual_networks.stub :get, promise do
        assert_raises RuntimeError do
          @service.remove_dns_servers_from_virtual_network('fog-test-rg', 'fog-test-virtual-network', ['10.1.0.5'])
        end
      end
    end
  end
end