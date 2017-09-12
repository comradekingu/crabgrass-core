#
#
# schema:
#
#   create_table :castle_gates_keys do |p|
#     p.integer :castle_id
#     p.string  :castle_type
#     p.integer :holder_code
#     p.integer :gate_bitfield, :default => 0
#   end
#
# About gate_bitfield:
#
# The gate_bitfield of a key always has the first bit turned on. Why?
# This allows us to quickly identify the difference between a set of keys
# with no access and a query that returned zero keys.
#
module CastleGates
  class Key < ActiveRecord::Base
    self.table_name = :castle_gates_keys

    belongs_to :castle, polymorphic: true

    # we store the codes as integers but generate them as strings.
    # So for comparison to work let's also read them as strings
    def holder_code
      read_attribute(:holder_code).to_s
    end

    #
    # queries keys that are associated with the holder, or any of its 'subholders'
    #
    scope(:for_holder, lambda { |holder|
      where holder_code: Holder[holder].all_codes
    })

    scope(:with_gate_bits, lambda { |bits|
      where("(#{bits} & ~castle_gates_keys.gate_bitfield) = 0")
    })

    #
    # only returns keys that correspond to the passed in holder names.
    #
    # OPTIMIZE: this is an inefficient finder. It would be better
    # to store the holder_code in a separate field in the keys table.
    #
    scope(:limit_by_holders, lambda { |holders|
      holders = [holders] unless holders.is_a?(Array)
      holder_codes = holders.collect { |holder| Holder[holder].code_prefix.to_s }
      # ^^ MySQL and SQLite both support substr of integers. For SQLite, however,
      # the value it is compared to must be a string. MySQL allows you to compare with
      # an integer. Here, we convert all the holder_codes to strings so it works in both cases.
      # As noted above, this is not very optimized.
      { conditions: ['substr(castle_gates_keys.holder_code,1,1) IN (?)', holder_codes] }
    })

    #
    # Returns the gate_bitfield for a set of keys (defined by the named scope, not
    # an array of actual key objects).
    #
    # This is not a method of the keys association because of how we do caching.
    #
    def self.gate_bitfield(keys_named_scope)
      return 0 unless keys_named_scope.any?
      if ActiveRecord::Base.connection.adapter_name == 'SQLite'
        keys_named_scope.all.inject(0) { |prior, key| prior | key.gate_bitfield }
      else
        keys_named_scope.calculate(:bit_or, :gate_bitfield)
      end
    end

    #
    # makes this key able to open these gates
    #
    # by default, the first bit is set. see note above.
    #
    def add_gates!(gates)
      self.gate_bitfield |= (1 | bits_for_gates(gates))
      changed? && save!
    end

    #
    # sets the key to only open the specified list of gates,
    # destroying any prior grants.
    #
    # the first bit is always set. see note above.
    #
    def set_gates!(gates)
      self.gate_bitfield = 1
      add_gates!(gates)
    end

    #
    # revoke access for the specified keys
    #
    def remove_gates!(gates)
      self.gate_bitfield &= ~ bits_for_gates(gates)
      changed? && save!
    end

    #
    # display the gate_bitfield in binary
    #
    def inspect
      "#<Key id:#{id}, castle_id:#{castle_id}, castle_type:#{castle_type}, holder_code:#{holder_code}, gate_bitfield:#{gate_bitfield.to_s(2)}>"
    end

    private

    #
    # Returns the bitmask for a set of gate names.
    #
    def bits_for_gates(gate_names)
      castle_type.constantize.gate_set.bits(gate_names)
    end
  end
end
