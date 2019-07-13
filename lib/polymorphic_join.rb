# rubocop:disable MethodLength, AbcSize, ModuleLength
# frozen_string_literal: true

require 'polymorphic_join/version'

module PolymorphicJoin
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:add_ref_polymorphic_scope)
  end

  module ClassMethods
    def query_ref_polymorphic(type, refs)
      polymorphic = if refs.nil?
                      {
                        refs: retrieve_all_polymorphic_types(type),
                        map_columns: {}
                      }
                    else
                      process_input_refs(refs)
                    end

      columns =
        polymorphic[:refs]
        .first
        .to_s
        .classify
        .constantize
        .column_names

      polymorphic[:refs].each do |p|
        columns &= p.to_s.classify.constantize.column_names
      end

      polymorphic[:map_columns].values.each do |value|
        columns += value.values
      end

      columns.uniq!

      selectable_columns = {}
      types = type.to_s.pluralize
      polymorphic[:refs].each do |p|
        map_columns = polymorphic[:map_columns][p] || {}
        selectable_columns[p] = []

        p.to_s.classify.constantize.column_names.each do |column_name|
          if (alias_name = map_columns[column_name.to_sym]).present?
            selectable_columns[p] <<
              "#{types}.#{column_name} AS #{alias_name}"
          elsif columns.index(column_name)
            selectable_columns[p] <<
              "#{types}.#{column_name}"
          end
        end
      end

      table = arel_table
      joins_statements = polymorphic[:refs].map do |join_type|
        join_table =
          join_type.to_s.classify.constantize.arel_table.alias(types)
        arel_table
          .project(*(selectable_columns[join_type]))
          .join(
            join_table, Arel::Nodes::InnerJoin
          )
          .on(
            table["#{type}_type".to_sym]
            .eq(join_type.to_s.classify)
            .and(
              table["#{type}_id".to_sym].eq(join_table[:id])
            )
          )
      end

      polymorphic_union_scope(
        type, polymorphic[:refs], *joins_statements
      )
    end

    protected

    def polymorphic_union_scope(type, refs, *scopes)
      union = scopes[0]
      t2 = arel_table

      if scopes.length > 1
        (1..(scopes.length - 1)).each do |i|
          union = union.union(scopes[i])
        end
      end

      types = type.to_s.pluralize
      t1 = arel_table.create_table_alias(union, types)
      from(
        t2.create_join(
          t1,
          t2.create_on(
            t1[:id].eq(t2["#{type}_id".to_sym]).and(
              t2["#{type}_type"].in(
                refs.collect { |x| x.to_s.singularize.classify }
              )
            )
          )
        )
      ).distinct
    end

    def retrieve_all_polymorphic_types(type)
      distinct.pluck("#{type}_type").collect do |x|
        x.underscore.tableize.to_sym
      end
    end

    def process_input_refs(refs)
      poly_refs = []
      refs.each do |ref|
        poly_refs << (ref.is_a?(Symbol) ? ref : ref.keys.first)
      end

      {
        refs: poly_refs,
        map_columns: refs.each_with_object({}) do |el, hash|
          if el.is_a?(Symbol)
            hash[el] = {}
          else
            hash[el.keys.first] = el[el.keys.first]
          end
        end
      }
    end

    def add_ref_polymorphic_scope
      scope :ref_polymorphic, lambda { |type, refs = nil|
        query_ref_polymorphic(type, refs)
      }
    end
  end
end
# rubocop:disable all
