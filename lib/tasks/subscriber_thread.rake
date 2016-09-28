namespace :subscriber_thread do

  desc "Starts listen thread"
  task listen: :environment do

    RClient.subscribe('test_exchange') do |delivery, metadata, payload|
      puts "RabbitMQ message received!: #{payload}"
    end

    loop do
      puts 'listening...'
      sleep 5
    end
  end


end
