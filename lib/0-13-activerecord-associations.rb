# Allows us to use 0.14.x nullify and destroy
module ActiveRecord

  include ActiveRecord

  module Associations

    module ClassMethods

      def has_many(association_id, options = {})
        options.assert_valid_keys(
          :foreign_key, :class_name, :exclusively_dependent, :dependent,
          :conditions, :order, :finder_sql, :counter_sql,
          :before_add, :after_add, :before_remove, :after_remove
        )

        association_name, association_class_name, association_class_primary_key_name =
              associate_identification(association_id, options[:class_name], options[:foreign_key])

        require_association_class(association_class_name)

        raise ArgumentError, ':dependent and :exclusively_dependent are mutually exclusive options.  You may specify one or the other.' if options[:dependent] and options[:exclusively_dependent]

        # See HasManyAssociation#delete_records.  Dependent associations
        # delete children, otherwise foreign key is set to NULL.
        case options[:dependent]
          when :destroy, true
            module_eval "before_destroy '#{association_name}.each { |o| o.destroy }'"
          when :nullify
            module_eval "before_destroy { |record| #{association_class_name}.update_all(%(#{association_class_primary_key_name} = NULL),  %(#{association_class_primary_key_name} = \#{record.quoted_id})) }"
          when nil, false
            # pass
          else
            raise ArgumentError, 'The :dependent option expects either true, :destroy or :nullify'
        end

        if options[:exclusively_dependent]
          module_eval "before_destroy { |record| #{association_class_name}.delete_all(%(#{association_class_primary_key_name} = \#{record.quoted_id})) }"
        end

        add_multiple_associated_save_callbacks(association_name)
        add_association_callbacks(association_name, options)

        collection_accessor_methods(association_name, association_class_name, association_class_primary_key_name, options, HasManyAssociation)

        # deprecated api
        deprecated_collection_count_method(association_name)
        deprecated_add_association_relation(association_name)
        deprecated_remove_association_relation(association_name)
        deprecated_has_collection_method(association_name)
        deprecated_find_in_collection_method(association_name)
        deprecated_find_all_in_collection_method(association_name)
        deprecated_collection_create_method(association_name)
        deprecated_collection_build_method(association_name)
      end


      def has_one(association_id, options = {})
        options.assert_valid_keys(:class_name, :foreign_key, :remote, :conditions, :order, :dependent, :counter_cache)

        association_name, association_class_name, association_class_primary_key_name =
            associate_identification(association_id, options[:class_name], options[:foreign_key], false)

        require_association_class(association_class_name)

        module_eval do
          after_save <<-EOF
            association = instance_variable_get("@#{association_name}")
            unless association.nil?
              association["#{association_class_primary_key_name}"] = id
              association.save(true)
              association.send(:construct_sql)
            end
          EOF
        end

        association_accessor_methods(association_name, association_class_name, association_class_primary_key_name, options, HasOneAssociation)
        association_constructor_method(:build, association_name, association_class_name, association_class_primary_key_name, options, HasOneAssociation)
        association_constructor_method(:create, association_name, association_class_name, association_class_primary_key_name, options, HasOneAssociation)

        case options[:dependent]
          when :destroy, true
            module_eval "before_destroy '#{association_name}.destroy unless #{association_name}.nil?'"
          when :nullify
            module_eval "before_destroy '#{association_name}.update_attribute(\"#{association_class_primary_key_name}\", nil)'"
          when nil, false
            # pass
          else
            raise ArgumentError, "The :dependent option expects either :destroy or :nullify."
        end

        # deprecated api
        deprecated_has_association_method(association_name)
        deprecated_association_comparison_method(association_name, association_class_name)
      end

    end

  end

end
