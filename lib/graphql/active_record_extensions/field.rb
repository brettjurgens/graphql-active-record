##
# This class allows GraphQL to translate ActiveRecord objects into
# GraphQL objects easily and does an auto-include to make it
# somewhat more efficient (hopefully)
module GraphQL
  module ActiveRecordExtensions
    class Field
      def self.generate(model:, resolve_type:, name: nil)
        n = name || model.name.underscore
        GraphQL::Field.define do
          name(n)
          type(resolve_type)
          description("Find a #{model.name} by ID/UUID")

          argument :id, !GraphQL::ID_TYPE
          argument :use_uuid, GraphQL::BOOLEAN_TYPE

          resolve -> (object, arguments, context) do
            GraphQL::ActiveRecordExtensions::Field.resolve_it(model, object, arguments, context)
          end
        end
      end

      ##
      # override of GraphQL::Field.resolve
      # basically just provides the final object (in this case an AR model)
      # can check RDoc for graphql-ruby gem
      #
      # @param object not used
      # @param arguments List[GraphQL::Argument] List of Arguments for the field (i.e. id, uuid, etc.)
      # @param ctx [GraphQL::Context] the context of the GraphQL query
      #
      # @return eager-loaded ActiveRecord model
      def self.resolve_it(model, object, arguments, ctx)
        includes = map_includes(model, ctx.ast_node.selections, ctx)

        model_with_includes = include_in_model(model, includes)

        if arguments['use_uuid']
          model_with_includes.find_by_uuid(arguments['id'])
        else
          model_with_includes.find(arguments['id'])
        end

        rescue ActiveRecord::ConfigurationError => e
          model.find(arguments['id'])
      end

      private

      def self.include_in_model(model, includes)
        includes.present? ? model.includes(*includes) : model
      end

      ##
      # generates an array for use in AR::QueryMethods.includes
      # allows for nested includes as well
      # supports fragments
      #
      # @param model [ActiveRecord::Base] an ActiveRecord model
      # @param selections [GraphQL::Selection] selections on the current model
      # @param ctx [GraphQL::Context] the context of the GraphQL query. Used to map fragments to models
      #
      # @return Array of tables to include in the query
      def self.map_includes(model, selections, ctx)
        selections.map do |selection|

          table_name, node = handle_fragments(selection, ctx)

          if node.present? && node.selections.present?
            singular = table_name.singularize
            plural   = table_name.pluralize

            # make sure that the next model is an ActiveRecord model
            next_model = singular.to_s.classify.safe_constantize

            if next_model.blank? || !(next_model < ActiveRecord::Base)
              next_model = model
            end

            nested = map_includes(next_model, node.selections, ctx)

            singular_reflection = model.reflections[singular] || model.reflections[singular.to_sym]
            plural_reflection = model.reflections[plural] || model.reflections[plural.to_sym]

            final_type =  if valid_association(singular_reflection)
                            # this is for has_one relationships
                            singular

                          elsif valid_association(plural_reflection)
                            # this is for has_many relationships
                            plural

                          else
                            # this is for non-AR models (i.e. Product)
                            # so they use the correct parent
                            # TODO Try to get possible_types and include those
                            nil
                          end

            if nested.present?
              if final_type
                # flatten is used for cases like Interfaces
                # i.e. Customer -> Product -> Loan
                # Product isn't an AR type
                { final_type => nested.flatten }
              else
                nested.compact
              end

            else
              final_type
            end
          else
            nil
          end
        end.flatten.compact
      end

      ##
      # method to handle fragments in GQL Query
      # works by finding the fragment reference in the context
      #
      # @param node [GraphQL::Language::Nodes::*] current node
      # @param ctx [GraphQL::Context] GQL Context used to map fragment to node
      #
      # @return [String, GraphQL::Language::Nodes::*] tuple of node name and node
      def self.handle_fragments(node, ctx)
        if node.is_a?(GraphQL::Language::Nodes::FragmentSpread)
          fragment = ctx.query.fragments[node.name]

          return [ fragment.type.underscore, fragment ] if fragment.type.is_a?(String)

          [fragment.type.name.underscore, fragment]
        elsif node.is_a?(GraphQL::Language::Nodes::InlineFragment)
          ##
          # avoid auto-including things in InlineFragments
          # If using an interface, not all fields are guaranteed to
          # exist in all of the implementing types, but at this point,
          # we can't tell if it will, because we don't know what type
          # we are dealing with.
          ##
          [nil, nil]
        else
          [node.name, node]
        end
      end

      ##
      # Method to check whether a reflection is valid.
      # Some things, like PowerEnum, have reflections but do not work properly
      # because they do not have an association_class. So ignore them.
      #
      # @param reflection [ActiveRecord::Associations::* | any | nil] Inputted Association
      # @return [boolean] Whether or not the association is valid
      def self.valid_association(reflection)
        return false if reflection.blank?
        return false unless reflection.respond_to?(:association_class)
        return (reflection.association_class < ActiveRecord::Associations::Association)
      end
    end
  end
end
