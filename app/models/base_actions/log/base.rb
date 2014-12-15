module BaseActions
  module Log
    class Base
      def initialize(diff)
        @log = []
        @diff = diff
      end

      def now!
        generate_log
      end

      private

      def generate_log(models, items)
        return empty_diff if is_empty?(@diff)
        method("log_creating_#{models}").call
        items.each do |item_name|
          item_name = item_name.pluralize
          method("log_adding_#{item_name}").call
          method("log_removing_#{item_name}").call
        end
        @log
      end

      def self.log_creating_models(opts)
        define_method("log_creating_#{opts[:models]}") do
          @diff["create_#{opts[:models]}".to_sym].each do |model, h|
            @log << "[api] create #{opts[:model]} #{model[opts[:mod_prop]]}"
            opts[:new_model_items].each do |item_name|
              item_name = item_name.pluralize
              begin
                h["add_#{item_name}".to_sym].each do |i|
                  @log << "[api] add #{item_name.singularize} #{i} to #{opts[:model]} #{model[opts[:mod_prop]]}"
                end
              rescue NoMethodError
                @log << "[api] add #{item_name.singularize} #{h["add_#{item_name}".to_sym]} to #{opts[:model]} #{model[opts[:mod_prop]]}"
              end
            end
          end
        end
      end

      def self.log_adding_items(item_name, opts)
        item_name = item_name.pluralize
        define_method("log_adding_#{item_name}") do
          @diff["add_#{item_name}".to_sym].each do |model, items|
            items.each do |i|
              @log << "[api] add #{item_name.singularize} #{i} to #{opts[:model]} #{model[opts[:mod_prop]]}"
            end
          end
        end
      end

      def self.log_removing_items(item_name, opts)
        define_method("log_removing_#{item_name}") do
          @diff["remove_#{item_name}".to_sym].each do |model, items|
            items.each do |i|
              @log << "[api] remove #{item_name.singularize} #{i} from #{opts[:model]} #{model[opts[:mod_prop]]}"
            end
          end
        end
      end

      def self.create_model opts
        log_creating_models(opts)
        opts[:items].each do |item_name|
          log_adding_items(item_name, opts)
          log_removing_items(item_name, opts)
        end
      end

      def is_empty? diff
        diff.all? { |k,v| v == {} }
      end

      def empty_diff
        @log << "There are no changes."
      end
    end
  end
end
