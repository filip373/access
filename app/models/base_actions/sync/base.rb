module BaseActions
  module Sync
    class Base
      def initialize(api)
        @api = api
      end

      def now!(diff)
        sync(diff)
      end

      private

      def self.sync_items_methods(*items)
        items.each do |item|
          define_method("sync_#{item}") do |add, remove|
            add.each do |model, items|
              items.each { |itm| @api.method("add_#{item.singularize}").call(itm, model) }
            end

            remove.each do |model, items|
              items.each { |itm| @api.method("remove_#{item.singularize}").call(itm, model) }
            end
          end
        end
      end

      def self.new_team_items_methods(*items)
        items.each do |item|
          define_method("new_team_add_#{item}") do |item_collection, model|
            item_collection.each do |itm|
              @api.method("add_#{item}").call(itm, model)
            end
          end
        end
      end
    end
  end
end
