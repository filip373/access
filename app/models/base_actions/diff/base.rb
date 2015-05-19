module BaseActions
  module Diff
    class Base
      def initialize(expected_models, api)
        @expected_models = expected_models
        @api = api
        @diff = {}
        # child
        # @diff = diff structure
        # @model_name = :sym
      end

      def now!
        generate_diff
        @diff
      end

      private

      def generate_diff
        # override in childclass
      end

      def map_members_to_users(members)
        members.map do |m|
          user = User.find(m)
          raise "Unknown user #{m}" if user.nil?
          yield(user)
        end
      end

      def self.create_methods_for_items(*args)
        args.each do |name|
          define_method "#{name}_diff" do |model, items|
            if model.respond_to?(:id)
              current_items = method("list_#{model_name}_#{name.pluralize}").call(model)
              add = items - current_items
              remove = current_items - items
              @diff["add_#{name}".to_sym][model] = add if add.any?
              @diff["remove_#{name}".to_sym][model] = remove if remove.any?
            else
              @diff["create_#{model_name.pluralize}".to_sym][model]["add_#{name}".to_sym] = items unless items.empty?
            end
          end
        end
      end

      def self.create_model_finder_method(model)
        models = model.pluralize

        define_method "find_or_create_#{model}" do |expected_model|
          model = method("get_#{model_name}").call(expected_model.name)
          return model unless model.nil?
          @diff["create_#{model_name.pluralize}".to_sym][expected_model] = {}
          expected_model
        end

        define_method "get_#{models}" do
          class_eval("attr_accessor :#{models}")
          return method(models).call unless method(models).call.nil?
          send("#{models}=", @api.send("list_#{models}"))
        end

        define_method "get_#{model}" do |m_name|
          method("get_#{models}").call.find { |m| m.name.downcase == m_name.downcase }
        end
      end
    end
  end
end
