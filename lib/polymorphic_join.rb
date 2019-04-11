# rubocop:disable BlockLength, AbcSize, Style/Documentation, MethodLength
# frozen_string_literal: true

require 'polymorphic_join/version'

module PolymorphicJoin
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:add_ref_polymorphic_scope)
  end

  module ClassMethods

    private

    def polymorphic_union_scope(types, *scopes)
      union = scopes[0]
      t2 = arel_table

      if scopes.length > 1
        (1..(scopes.length - 1)).each do |i|
          union = union.union(scopes[i])
        end
      end

      t1 = arel_table.create_table_alias(union, types)
      from(t2.create_join(t1, t2.create_on(t1[:id].eq(t2[:id]))))
    end

    def retrieve_all_polymorphic_types(type)
      pluck("#{type}_type").collect { |x| x.underscore.tableize.to_sym }
    end

    def add_ref_polymorphic_scope
      scope :ref_polymorphic, lambda { |type, refs = nil|
        polymorphic = if refs.nil?
                        retrieve_all_polymorphic_types(type)
                      else
                        refs
                      end
        columns = polymorphic.first.to_s.classify.constantize.column_names
        polymorphic.each do |p|
          columns &= p.to_s.classify.constantize.column_names
        end

        types = type.to_s.pluralize

        columns -= column_names
        selectable_columns = []
        columns.each do |column|
          selectable_columns << "#{types}.#{column}"
        end

        table = arel_table
        joins_statements = polymorphic.map do |join_type|
          join_table =
            join_type.to_s.classify.constantize.arel_table.alias(types)
          arel_table
            .project(table[Arel.star], *selectable_columns)
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

        polymorphic_union_scope(types, *joins_statements)
      }
    end
  end
end
# rubocop:enable all
