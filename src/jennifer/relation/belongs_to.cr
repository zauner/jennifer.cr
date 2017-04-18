module Jennifer
  module Relation
    class BelongsTo(T, Q) < Base(T, Q)
      def initialize(*opts)
        super
      end

      def condition_clause
        _foreign = foreign_field
        _primary = primary_field
        tree = T.c(_primary, @name) == Q.c(_foreign)
        @join_query ? tree & @join_query.not_nil!.clone : tree
      end

      def condition_clause(id)
        _tree = T.c(primary_field) == id
        @join_query ? _tree & @join_query.not_nil!.clone : _tree
      end

      def join_condition(query, type)
        this = self
        query.join(model_class, type: type, relation: @name) do |eb|
          this.condition_clause.not_nil!
        end
      end

      def join_condition(query, type, &block)
        this = self
        query.join(model_class, type: type, relation: @name) do |eb|
          this.condition_clause.not_nil! & (yield eb)
        end
        # if @join_table
        #  _foreign = foreign_field
        #  _primary = primary_field
        #  jt = @join_table.not_nil!
        #  jtk = @join_foreign || T.to_s.foreign_key

        #  q = query.join(jt, type: type) { Q.c(_primary) == c(_foreign) }.join(T, type: type) do |eb|
        #    (T.c(_primary) == c(jtk, jt)) & (yield eb)
        #  end
        #  if @join_query
        #    _tree = @join_query.not_nil!
        #    q.where { _tree }
        #  else
        #    q
        #  end
        # else
        #  query.join(model_class, type: type, relation: @name) do |eb|
        #    this.condition_clause.not_nil! & (yield eb)
        #  end
        # end
      end

      def query(primary_value)
        condition = condition_clause(primary_value)
        T.where { condition }
        # if @join_table
        #  jt = @join_table.not_nil!
        #  jtk = join_table_foreign_key
        #  _primary_value = primary_value
        #  _pf = primary_field
        #  _ff = foreign_field
        #  q = T.all.join(jt) { (c(jtk) == T.c(_pf)) & (c(_ff) == _primary_value) }
        #
        #  if @join_query
        #    _tree = @join_query.not_nil!
        #    q.where { _tree }
        #  else
        #    q
        #  end
        # else
        #  condition = condition_clause(primary_value)
        #  T.where { condition }
        # end
      end

      def insert(obj : Q, rel : Hash(String, Jennifer::DBAny))
        main_obj = T.create!(rel)
        obj.update_column(foreign_field, main_obj.attribute(primary_field))
        main_obj
      end

      def insert(obj : Q, rel : T)
        raise BaseException.new("Object already belongs to another object") unless obj.attribute(foreign_field).nil?
        obj.set_attribute(foreign_field, rel.attribute(primary_field))
        rel.save! if rel.new_record?
        rel
      end

      def remove(obj : Q, rel : T)
        obj.update_column(foreign_field, nil) if obj.attribute(foreign_field) == rel.attribute(primary_field)
        rel
      end

      def remove(obj : Q)
        obj.update_column(foreign_field, nil)
      end

      def foreign_field
        @foreign ||= T.singular_table_name + "_id"
      end

      def primary_field
        @primary ||= T.primary_field_name
      end
    end
  end
end
