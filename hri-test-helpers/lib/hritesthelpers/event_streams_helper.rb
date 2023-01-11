module HRITestHelpers
  class EventStreamsHelper

    def initialize
      @request_helper = RequestHelper.new
    end

    def get_topics
      @request_helper.exec_command("ibmcloud es topics")[:stdout].split("\n").map { |t| t.strip }
    end

    def create_topic(topic, partitions)
      unless get_topics.include?(topic)
        @request_helper.exec_command("ibmcloud es topic-create #{topic} -p #{partitions}")
        Logger.new(STDOUT).info("Topic #{topic} created.")
      end
    end

    def delete_topic(topic)
      Logger.new(STDOUT).info("Deleting topic: #{topic}")
      @request_helper.exec_command("ibmcloud es topic-delete #{topic} -f")
    end

    def get_groups
      @request_helper.exec_command("ibmcloud es groups")[:stdout]
    end

    def reset_consumer_group(existing_groups, group, topic, mode)
      if existing_groups.include?(group)
        if @request_helper.exec_command("ibmcloud es group #{group}")[:stdout].include?(topic)
          Timeout.timeout(10) do
            while @request_helper.exec_command("ibmcloud es group-reset #{group} --mode #{mode} --topic #{topic} --execute")[:stdout].split("\n").last != 'OK' &&
              @request_helper.exec_command("ibmcloud es group #{group}")[:stdout].split("\n").select { |s| s.include?(topic) }[0].split(' ')[4].to_i != 0
              Logger.new(STDOUT).warn("Failed to reset consumer group #{group} to the latest offset")
              sleep 0.1
            end
          end
          Logger.new(STDOUT).info("Consumer group #{group} reset to the latest offset")
        end
      end
    end

    def consumer_group_current_offset(group, topic)
      if get_groups.include?(group)
        @request_helper.exec_command("ibmcloud es group #{group}")[:stdout].split("\n").select { |s| s.start_with?(topic) }[0].split(' ')[2].to_i
      end
    end

    def verify_topic_creation(expected_topics)
      Timeout.timeout(60, nil, 'Kafka topics not created after 60 seconds') do
        topics = get_topics
        until (topics & expected_topics).sort == expected_topics.sort
          sleep 1
          topics = get_topics
        end
      end
    end

  end
end