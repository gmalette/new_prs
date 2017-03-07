module NewPrs
  module CLI
    class Menu
      def initialize(cli)
        @cli = cli
        @commands = {}
        @sequences = []
      end

      def command(binding, title, &action)
        raise "binding must be a string" unless binding.is_a?(String)
        raise "expect single-character binding" unless binding.length == 1
        raise "binding already registered" unless @commands[binding].nil?
        @commands[binding] = [title, action]
        self
      end

      def list(list_menu, all: nil, each: nil)
        raise "can only have one list" if defined?(@list)
        raise "expected array of [title, Menu]" unless list_menu.is_a?(Array) || list_menu.respond_to?(:call)

        @list_menu = list_menu
        @all_command = all
        self
      end

      def run(command_sequence = [])
        while true
          if command_sequence&.empty?
            @cli.say(prompt)
            command_sequence = @cli.ask("? ").split("")
          end

          command = command_sequence.shift

          if title_and_action = @commands[command]
            puts "Executing command #{command}"
            action = title_and_action.last
            result = call_next(action, command_sequence)
            return if result == :term
          elsif (menu_index = command.to_i) > 0 && list_items
            puts "Executing index #{menu_index}"
            _title, menu = list_items[menu_index - 1]
            call_next(menu, command_sequence)
            command_sequence = []
          elsif @all_command && command == @all_command && list_items
            puts "Executing all"
            list_items.each do |(_title, menu)|
              call_next(menu, command_sequence.dup)
            end
            command_sequence = []
            return if list_items.empty?
          else
            puts "unknown command #{command}, available ones are #{@commands.keys}"
            return
          end
        end
      end

      private

      def list_items
        return @list_menu.call if @list_menu.respond_to?(:call)
        @list_menu
      end

      def call_next(action, sequence)
        if action.is_a?(self.class)
          action.run(sequence)
        else
          action.call
        end
      end

      def prompt
        output = []

        if list_items
          output += list_items.map.with_index { |(title, _), index| "#{index + 1}. #{title}" }
          output += ["#{@all_command}. All"] if @all_command
        end

        output += @commands.map { |binding, (title, _)| "#{binding}. #{title}" }

        output.join("\n")
      end
    end
  end
end
