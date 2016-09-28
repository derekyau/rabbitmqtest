class RMQClient
  attr_accessor :conn, :channel

  AMQP_SERVER = "amqp://guest:guest@localhost:5672"

  def initialize
    @conn = Bunny.new(AMQP_SERVER, threaded: true)
    @conn.start
    @channel = @conn.create_channel
  end

  def publish(exchange_name, event, data_hash)
    exchange = establish_exchange(exchange_name)
    exchange.publish(data_hash.to_json, routing_key: event, persistent: true, timestamp: Time.now.to_i)
  end

  def subscribe(exchange_name, &block)
    exchange = establish_exchange(exchange_name)
    client_queue_name = "#{exchange_name}_#{Rails.application.class.parent_name}"

    channel.queue(client_queue_name, durable: true).bind(exchange).subscribe do |delivery_info, metadata, payload|
      parsed_payload = JSON.parse(payload).deep_symbolize_keys!
      block.call(delivery_info, metadata, parsed_payload)
    end
  end

  private

    def establish_exchange(exchange_name)
      channel.fanout(exchange_name, durable: true)
    end

end
